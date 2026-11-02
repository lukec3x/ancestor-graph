---
description: Implementa o plano aprovado, um commit por unidade, sem push.
argument-hint: "[S1] — inferida da branch s<n>/… se omitida"
---

# Build de uma fatia

Fase de código desta fatia. O plano aprovado é a entrada. Não se reescreve o plano aqui e não se faz push.

Fale com o usuário em português. Código, comentário e commit saem em inglês, como o `CLAUDE.md` manda.

## Entrada

A fatia sai da branch atual (`s1/register-person` → `S1`) ou do argumento. Sem as duas, pare e pergunte. Não adivinhe.

O plano `docs/plans/s<n>.md` tem de estar no `HEAD` e a worktree tem de estar igual a esse commit:

```bash
git cat-file -e HEAD:docs/plans/s<n>.md
git diff --quiet HEAD -- docs/plans/s<n>.md
```

Qualquer falha para e manda rodar `/sdlc-plan`. Não conserte o plano aqui.

Rode `script/plan-contract.sh docs/plans/s<n>.md --require implementation-ready`. Falha para e manda rodar `/sdlc-plan`. Não conserte o plano aqui.

Leia o Goal Capsule, as unidades, o Verification Contract e a Definition of Done. Os `R` são o contrato.

A base é `git config --get branch.<branch>.sdlc-base`. Sem essa chave, a base é `master`.

## Passos

1. Leia e siga a skill `ce-work` com `mode:return-to-caller` e o caminho `docs/plans/s<n>.md`. Não implemente inline no lugar dela. Diga na invocação:

   - Um subagente novo por unidade. Unidades acopladas rodam em série, não inline.
   - Um commit por unidade concluída. Nunca push.
   - Cada unidade obedece o Patterns to follow do plano e o `CLAUDE.md`.
   - Unidade que escreve teste Rails segue a skill `rails-testing`.
   - Unidade que mexe em `db/migrate` segue a skill `rails-migrations`.

   O retorno é o envelope da skill (`status`, `verification_evidence`, `u_ids_completed`, `unit_receipts`). Prosa no lugar do envelope quer dizer que a invocação não terminou: invoque de novo. Não invente os campos.

2. Rode os comandos do Verification Contract do plano, mais o lint que o repositório tiver. Confira cada `R` contra a unidade que o cita. Corrija a falha.

   Se o diff mexe em tela Vue, leia e siga a skill `ce-test-browser` nas rotas afetadas. Sem tela, não rode e diga isso.

3. Traga arquivo novo para o diff sem commitar:

```bash
git ls-files -o --exclude-standard -z | xargs -0 git add -N --
```

   Leia e siga a skill `ce-code-review` com a base `git merge-base HEAD <base>`. Só relatório.

   Leia e siga a skill `sdlc-code-review` no fluxo de branch local, contra `docs/specs/s<n>.md` e `docs/plans/s<n>.md`. Só relatório.

   Se o diff tem Ruby, invoque o subagente `layered-rails-reviewer`. Sem Ruby, não invoque e diga isso.

   Achado que procede se corrige, com teste quando muda comportamento. Critical confirmado e achado que não é óbvio vão ao gate, sem correção antes.

4. Leia e siga a skill `ponytail-review` sobre o diff. Corte o que ela apontar e rode o Verification Contract de novo.

5. Pare. Mostre, por recibo: o envelope do `ce-work`, o veredito do `ce-code-review`, o veredito do `sdlc-code-review`, o que o reviewer de Rails disse ou por que não rodou, o que o browser disse ou por que não rodou, e o que o ponytail cortou. Pergunte só se está pronto para o ship. Não faça push. Aprovado, aponte o `/sdlc-ship`. Senão, volte ao passo 1.
