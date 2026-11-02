---
description: Sincroniza a fatia com a base e envia a branch se houver remoto. O merge é do usuário.
argument-hint: "[S1] — inferida da branch s<n>/… se omitida"
---

# Ship de uma fatia

Entrega o build aprovado. Não apaga `docs/specs/` nem `docs/plans/`. Não faz merge. Não resolve conflito.

Fale com o usuário em português. Commit sai em inglês, no estilo do `CLAUDE.md`.

## Entrada

A fatia sai da branch atual (`s1/register-person` → `S1`) ou do argumento. Sem as duas, pare e pergunte. Não adivinhe.

A base é `git config --get branch.<branch>.sdlc-base`. Sem essa chave, a base é `master`.

Leia a spec `docs/specs/s<n>.md` e o plano `docs/plans/s<n>.md`. Sem um dos dois no `HEAD`, pare e diga qual fase falta.

## Passos

1. Sincronize com a base e rode de novo os comandos do Verification Contract:

```bash
git fetch origin "$BASE" 2>/dev/null || true
git merge "$BASE"
```

Sem remoto, o merge é contra a branch local `master`. Conflito: mostre os arquivos e pare. Não resolva.

2. Monte o roteiro de QA na conversa, a partir dos arquivos, não da memória. Um caso por acceptance example. Sem nome de classe, arquivo ou símbolo dentro do caso. Seções: o que faz, caminho feliz, borda que a spec nomeia, o que não é bug, o que a suíte não cobre, fora de escopo. Não commite esse roteiro.

3. Lição não óbvia, uma por vez: leia e siga a skill `ce-compound`. Três lições, três invocações em série. O que o código, o git, a spec ou o `CLAUDE.md` já dizem não vira documento. Nenhuma lição: não escreva nada e diga isso.

   Lição nova que prova errado um documento existente: leia e siga a skill `ce-compound-refresh` nesse documento. Não deixe os dois lado a lado.

4. Commite o que ainda estiver solto, só desta fatia, título convencional, sem trailer. Não apague spec nem plano.

   Sem `origin`, pare aqui. Diga que a branch está pronta e que não há remoto.

   Com `origin`, envie a branch. O push passa pelo hook `brakeman-before-push`. Sem `apps/api`, ou sem o brakeman no Gemfile, ele deixa passar. Aviso de alta confiança barra o push. Se o remoto for GitHub e o `gh` estiver autenticado, abra o pull request para a base, título em inglês, assignee quem abre. Sem `gh`, entregue o comando de push e pare. Não use `glab`.

5. O merge na base é do usuário. Depois do merge, a worktree pode sair com `git worktree remove`. Não faça nenhum dos dois nesta fase.
