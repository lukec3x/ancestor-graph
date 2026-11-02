#!/usr/bin/env bash
# plan-contract — este arquivo é um artefato ce-unified-plan/v1 de verdade, ou prosa
# que só se parece com um? Gate determinístico compartilhado pelo /sdlc-spec, pelo
# /sdlc-plan e pelo /sdlc-build, para "o plano está completo" nunca
# ser autodeclarado.
#
#   script/plan-contract.sh <file> [--require requirements-only|implementation-ready]
#
# Exit 0 o artefato cumpre o contrato (e o readiness do --require)
#      1 não cumpre — cada elemento que falta sai impresso, um por linha
#      2 erro de uso / arquivo ilegível
#
# Por que existe: quem escreve o artefato é o ce-plan; quem reconstrói um à mão
# produz um plano legado (sem frontmatter, sem Goal Capsule, sem Verification
# Contract) que o ce-work ainda aceita — em silêncio, pelo ramo legado dele. Essa
# degradação é invisível sem uma checagem como esta.
#
# O contrato vem do ce-plan do compound-engineering,
# references/plan-sections.md: "Section ID Registry" (nomes E níveis dos
# cabeçalhos são o contrato estável) e "Implementation-ready hard floor".
set -uo pipefail
#
# NOTA: todo `grep -q` abaixo lê de uma HERESTRING, nunca de um pipe.
# O `grep -q` sai no primeiro casamento; um `printf ... | grep -q` mata o escritor
# com SIGPIPE, e sob `pipefail` o pipeline devolve 141 — então uma seção que ESTÁ
# lá às vezes sai como ausente. Isso fazia este gate falhar ~1 execução em 6 num
# artefato válido. Não reintroduza o pipe.

file="" ; require=""
while [ $# -gt 0 ]; do
  case "$1" in
    --require) require="${2:-}"; shift 2 || true ;;
    --require=*) require="${1#*=}"; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    -*) echo "unknown flag: $1" >&2; exit 2 ;;
    *) file="$1"; shift ;;
  esac
done

[ -n "$file" ] || { echo "usage: $0 <file> [--require requirements-only|implementation-ready]" >&2; exit 2; }
[ -f "$file" ] || { echo "missing: $file does not exist" >&2; exit 2; }
[ -s "$file" ] || { echo "missing: $file is empty" >&2; exit 2; }

case "${require:-}" in
  ""|requirements-only|implementation-ready) ;;
  *) echo "unknown --require value: $require" >&2; exit 2 ;;
esac

fail=0
miss() { echo "  missing: $1"; fail=1; }
warn() { echo "  warn   : $1"; }

total_lines="$(wc -l < "$file")"

# Body of the section opened at line $1, up to the next heading of level <= $2.
section_body() {
  local start="$1" depth="$2" next
  next="$(awk -v s="$start" -v d="$depth" '
    NR>s {
      match($0, /^#+/)
      if (RSTART == 1 && RLENGTH <= d) { print NR; exit }
    }' "$file")"
  [ -n "$next" ] || next=$((total_lines + 1))
  sed -n "$((start+1)),$((next-1))p" "$file"
}

heading_line() { grep -nE "^$1[[:space:]]*$" "$file" | head -1 | cut -d: -f1; }

# --- frontmatter -------------------------------------------------------------
# Only a leading `---` block with a CLOSING `---` counts. An opening delimiter
# with no close would otherwise swallow the whole body as "frontmatter", and a
# file whose prose happens to carry the keys would validate.
readiness=""
if [ "$(sed -n '1p' "$file")" != "---" ]; then
  miss "YAML frontmatter (the file opens without a \`---\` block — ce-work reads this as a legacy plan)"
  fm=""
else
  fm_close="$(awk 'NR>1 && /^---[[:space:]]*$/ { print NR; exit }' "$file")"
  if [ -z "$fm_close" ]; then
    miss "the closing \`---\` of the frontmatter block (an unterminated block is not frontmatter)"
    fm=""
  else
    fm="$(sed -n "2,$((fm_close-1))p" "$file")"
  fi
fi

if [ -n "$fm" ]; then
  fm_get() { printf '%s\n' "$fm" | sed -nE "s/^$1:[[:space:]]*[\"']?([^\"']*[^\"' ])[\"']?[[:space:]]*$/\1/p" | head -1; }
  contract="$(fm_get artifact_contract)"
  readiness="$(fm_get artifact_readiness)"
  execution="$(fm_get execution)"
  source_field="$(fm_get product_contract_source)"

  [ "$contract" = "ce-unified-plan/v1" ] || miss "frontmatter \`artifact_contract: ce-unified-plan/v1\` (found: ${contract:-none})"
  [ "$execution" = "code" ]              || miss "frontmatter \`execution: code\` (found: ${execution:-none})"
  [ -n "$source_field" ]                 || miss "frontmatter \`product_contract_source:\` (where the Product Contract came from)"

  case "$readiness" in
    requirements-only|implementation-ready) ;;
    active|in_progress|completed|done)
      miss "valid \`artifact_readiness\` — \`$readiness\` is a progress value, and readiness answers \"can this be executed?\", not \"has it been executed?\"" ;;
    "") miss "frontmatter \`artifact_readiness:\`" ;;
    *)  miss "valid \`artifact_readiness\` (found: $readiness)" ;;
  esac
fi

if [ -n "$require" ] && [ "$readiness" != "$require" ]; then
  miss "\`artifact_readiness: $require\` (found: ${readiness:-none})"
fi

# --- sections ----------------------------------------------------------------
# Level is part of the contract: consumers anchor on `## <name>`, so an artifact
# that renders every section at `###` is not one they can navigate.
need2() { grep -qE "^## $1[[:space:]]*$" "$file" || miss "section \`## $1\` at heading level 2 — the Section ID Registry name and level are the contract"; }

need2 "Goal Capsule"
need2 "Product Contract"

pc_ln="$(heading_line '## Product Contract')"
req_body=""
if [ -n "$pc_ln" ]; then
  pc_body="$(section_body "$pc_ln" 2)"
  if grep -qE '^### Requirements[[:space:]]*$' <<< "$pc_body"; then
    req_ln="$(heading_line '### Requirements')"
    req_body="$(section_body "$req_ln" 3)"
  else
    miss "section \`### Requirements\` nested under \`## Product Contract\` (the R-IDs downstream units cite)"
  fi
fi

# R-IDs are the traceability spine: units cite them, review reads them, and an
# empty Requirements section makes every downstream "Covers R…" unresolvable.
# Both `R1.` (canonical) and `**R1**` are accepted — the contract is the ID, not
# its emphasis.
rids=""
if [ -n "$req_body" ]; then
  rids="$(printf '%s\n' "$req_body" \
    | grep -oE '^[[:space:]]*([-*][[:space:]]*)?\**R[0-9]+\**[.:) —-]' \
    | grep -oE 'R[0-9]+' | sort -u)"
fi
if [ -n "$pc_ln" ] && [ -n "$req_body" ] && [ -z "$rids" ]; then
  miss "at least one requirement with a stable R-ID under \`### Requirements\` (e.g. \`R1. …\`) — an empty section leaves every unit citation dangling"
fi

# The floor that separates an executable plan from a Product Contract. Checked
# whenever the artifact claims implementation-ready, or the caller demanded it.
if [ "$readiness" = "implementation-ready" ] || [ "$require" = "implementation-ready" ]; then
  need2 "Planning Contract"
  need2 "Implementation Units"
  need2 "Verification Contract"
  need2 "Definition of Done"

  units="$(grep -cE '^### U[0-9]+\.' "$file")"
  if [ "$units" -eq 0 ]; then
    miss "at least one \`### U<n>.\` implementation unit — ce-work keys u_ids_completed and unit_receipts off these, and a plan with none collapses into a single inline pass"
  else
    # Files is load-bearing: /sdlc-build's per-unit dispatch hands it to the
    # subagent. An R-ID citation is what makes the unit traceable back to the
    # approved contract. The rest of the per-unit floor is reported, not enforced.
    missing_files="" ; missing_rids="" ; touched=""
    while IFS=: read -r ln uid; do
      [ -n "$ln" ] || continue
      body="$(section_body "$ln" 3)"
      # The Files field runs from its label to the next field or the end of the
      # unit. ce-plan's default shape is a bullet list *under* the label, so
      # reading only the label line finds no paths — and then the stack checks
      # below see an empty `touched` and pass by omission, which is worse than
      # not having them.
      files_field="$(printf '%s\n' "$body" | awk '
        /^[[:space:]]*[-*]?[[:space:]]*\**[Ff]iles\**[[:space:]]*:/ { f=1; print; next }
        f && /^[[:space:]]*\**[A-Za-z][A-Za-z ]*\**[[:space:]]*:/ { exit }
        f { print }')"
      unit_paths="$(printf '%s\n' "$files_field" | grep -oE '[A-Za-z0-9_@.-]+(/[A-Za-z0-9_@.<>-]+)+' | sort -u)"
      if [ -z "$files_field" ]; then
        missing_files="$missing_files $uid"
      elif [ -z "$unit_paths" ]; then
        missing_files="$missing_files $uid(no path)"
      else
        touched="$touched
$unit_paths"
      fi
      if [ -n "$rids" ]; then
        cited=""
        for r in $rids; do
          grep -qE "(^|[^A-Za-z0-9])$r([^0-9]|\$)" <<< "$body" && { cited=1; break; }
        done
        [ -n "$cited" ] || missing_rids="$missing_rids $uid"
      fi
      grep -qiE '^[[:space:]]*[-*]?[[:space:]]*\**(Test Scenarios|Verification|Goal)\**[[:space:]]*:' <<< "$body" \
        || warn "$uid names no Goal / Test Scenarios / Verification"
    done < <(grep -nE '^### U[0-9]+\.' "$file" | sed -E 's/^([0-9]+):### (U[0-9]+)\..*/\1:\2/')
    [ -z "$missing_files" ] || miss "a \`Files:\` field naming at least one repo path on unit(s):$missing_files — the per-unit dispatch has nothing to hand the subagent"
    [ -z "$missing_rids" ]  || miss "an R-ID citation on unit(s):$missing_rids — a unit that cites no requirement cannot be traced back to the approved contract"
  fi

  # --- verification actually covers what the units touch ----------------------
  # "Run the tests" is the shape a plan takes when nobody planned the testing.
  # Judge the COMMANDS, not the prose around them: a contract that merely
  # mentions RAILS_ENV=test in a sentence, next to an unrelated command, would
  # otherwise pass while nothing it actually runs targets the test database.
  vc_ln="$(heading_line '## Verification Contract')"
  if [ -n "$vc_ln" ]; then
    vc="$(section_body "$vc_ln" 2)"
    # A command is a line inside a fenced block, or a span in single backticks.
    vc_cmds="$(printf '%s\n' "$vc" | awk '/^[[:space:]]*```/ { f = !f; next } f { print }'
               printf '%s\n' "$vc" | grep -oE '`[^`]+`' | tr -d '`')"
    vc_cmds="$(printf '%s\n' "$vc_cmds" | sed '/^[[:space:]]*$/d')"

    if [ -z "$vc_cmds" ]; then
      miss "a real command in \`## Verification Contract\` (no backticked or fenced command found — \"run the tests\" is not a verification contract)"
    else
      # $touched was accumulated from the units' parsed Files paths above, so a
      # non-Rails/Vue repo is unaffected and a multiline list still counts.
      case "$touched" in
        *apps/api/*)
          grep -q 'RAILS_ENV=test' <<< "$vc_cmds" \
            || miss "a Verification Contract **command** carrying \`RAILS_ENV=test\` — units touch \`apps/api/\`, and database.yml reads ENV[DATABASE_NAME] with no _test suffix, so an unprefixed command runs against the dev database (prose mentioning it does not count)" ;;
      esac
      case "$touched" in
        *apps/web/*)
          grep -qi 'vitest' <<< "$vc_cmds" \
            || miss "a Verification Contract **command** running \`vitest\` — units touch \`apps/web/\`, and the Rails suite does not cover it" ;;
      esac
    fi
  fi
fi

if [ "$fail" -eq 0 ]; then
  echo "ok: $file satisfies ce-unified-plan/v1 (${readiness:-unknown}${units:+, $units units})"
else
  echo "FAIL: $file does not satisfy ce-unified-plan/v1 — have ce-plan produce or enrich it; do not hand-write the gaps." >&2
fi
exit "$fail"
