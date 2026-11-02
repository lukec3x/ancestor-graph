#!/usr/bin/env bash
# brakeman-before-push — Rails security scan before `git push`.
#
# Cursor beforeShellExecution hook. On `git push`, scans with Brakeman and
# denies the command on high-confidence warnings. Fails open if Brakeman
# cannot run, so missing tooling never wedges a push.
#
# The Rails app is apps/api/. Until that app and the brakeman gem exist,
# the hook allows the push.
set -uo pipefail

payload="$(cat)"
cmd="$(printf '%s' "$payload" | jq -r '.command // .tool_input.command // ""' 2>/dev/null || true)"

allow() {
  printf '%s\n' '{"permission":"allow"}'
  exit 0
}

case "$cmd" in
  *"git push"*) ;;
  *) allow ;;
esac

root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$root" ] || ! cd "$root"; then
  echo "brakeman-before-push: cannot resolve the project root — skipping scan (push allowed)" >&2
  allow
fi

if [ -d apps/api ] && [ -f apps/api/Gemfile ]; then
  app="apps/api"
else
  echo "brakeman-before-push: apps/api is not a Rails app yet — skipping scan (push allowed)" >&2
  allow
fi

if [ -x "$app/bin/brakeman" ]; then
  runner=(bin/brakeman)
elif ( cd "$app" && command -v bundle >/dev/null 2>&1 && bundle show brakeman >/dev/null 2>&1 ); then
  runner=(bundle exec brakeman)
elif command -v brakeman >/dev/null 2>&1; then
  runner=(brakeman)
else
  echo "brakeman-before-push: brakeman not found in $app — skipping scan (push allowed)" >&2
  allow
fi

out="$( ( cd "$app" && "${runner[@]}" -q --no-pager -w3 --exit-on-warn ) 2>&1 )"; code=$?

if [ "$code" -eq 3 ]; then
  jq -n --arg out "$out" '{
    permission: "deny",
    user_message: "Brakeman found high-confidence security warnings. Push blocked.",
    agent_message: ("Brakeman blocked this git push. Fix the warnings, or adjust .cursor/hooks/brakeman-before-push.sh.\n" + $out)
  }'
  exit 0
elif [ "$code" -ne 0 ]; then
  echo "brakeman-before-push: brakeman exited $code (scan error, not findings) — push allowed" >&2
  allow
fi

allow
