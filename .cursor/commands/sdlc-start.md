---
description: Abre a branch e a worktree de uma fatia a partir de master. Não escreve spec.
argument-hint: "[S1] — omita para escolher em docs/slices.md"
---

# Start de uma fatia

Prepara uma fatia para o laço spec, plan, build e ship. Não escreve spec, não planeja e não implementa.

Fale com o usuário em português.

## Entrada

Leia `docs/slices.md`. Sem ele, pare e diga para rodar `/sdlc-breakdown`.

A fatia vem do argumento (`S1`) ou, se vier vazio, da lista do arquivo. Pergunte qual, com no máximo quatro opções e *Other* para texto livre. Não escolha sozinho.

Se `Blocked by` não for `none`, diga qual fatia segura esta e pergunte se corta mesmo assim. Sem resposta, pare.

## Base

A base é `master`. Confira que `master` tem commit. Sem commit, pare: a branch da fatia não tem de onde sair.

## Passos

1. Leia e siga a skill `ce-worktree` para uma branch nova a partir de `master`. O nome é `s<n>/<kebab>`, com `<n>` da fatia e `<kebab>` curto, em inglês, tirado do título. Exemplo: `s1/register-person-and-parent`.

   Não reaproveite o checkout de outra fatia. Se o nome já existir, pare e mostre a branch. Não apague.

2. Grave a base na branch:

```bash
git config "branch.<final-branch>.sdlc-base" master
```

3. Diga o caminho da worktree, o nome da branch e a base. Peça para abrir uma conversa nova nessa worktree e rodar `/sdlc-spec` lá. Não continue nesta conversa.

Nada é commitado aqui. Nada é enviado ao remoto.
