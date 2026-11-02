---
description: Escreve a spec de uma fatia, só requisitos, e commita depois da aprovação.
argument-hint: "[S1] — inferida da branch s<n>/… se omitida"
---

# Spec de uma fatia

Fase de requisitos desta fatia. Decide o que tem de ficar verdadeiro. Não desenha arquivo, não lista unidade e não implementa.

Fale com o usuário em português. A spec sai em inglês, como o resto do repositório.

## Entrada

Rode na worktree da fatia. A fatia sai da branch atual (`s1/register-person` → `S1`) ou do argumento. Sem as duas, pare e pergunte. Não adivinhe.

Leia a fatia em `docs/slices.md`, os `AD-` que ela consome em `docs/architecture.md`, e o `CLAUDE.md`. Sem a fatia no arquivo, pare.

Se o código existir, ancore o requisito nele, com arquivo e linha. Grave esse mapa em `$(git rev-parse --git-dir)/sdlc-grounding.md`, uma linha por arquivo: caminho, símbolo e papel. O `/sdlc-plan` parte dele. Sem app, diga isso.

Requisito que contradiz um `AD-` não é decidido aqui. Pare e mande revisar com `/sdlc-brainstorm`.

## Passos

1. Escreva `docs/specs/s<n>.md`. Frontmatter, para o `/sdlc-plan` enriquecer este arquivo no lugar:

```yaml
---
artifact_contract: ce-unified-plan/v1
artifact_readiness: requirements-only
product_contract_source: sdlc-spec
execution: code
origin: docs/slices.md#S<n>
---
```

Seções:

- `## Goal Capsule` — o resultado, e quando parar.
- `## Product Contract` — `### Summary`, `### Problem Frame`, `### Requirements` com `R1.` em texto puro, nunca em negrito. `### Acceptance Examples` quando um requisito depende de uma condição. `### Scope Boundaries` para o que esta fatia não faz. `### Key Decisions` com um item por `AD-` consumido: a decisão e o que ela governa.

Não escreva unidades, arquivos, verificação nem definição de pronto. Isso é o plano.

2. Leia e siga a skill `grilling` sobre o que a spec afirma e o que ainda não foi decidido. O arquivo pode existir como rascunho. Não avance ao passo 3 antes do entendimento compartilhado.

3. Rode `script/plan-contract.sh docs/specs/s<n>.md --require requirements-only`. Falha volta ao passo 1. Não complete seção faltante à mão.

   Leia e siga a skill `sdlc-doc-review` sobre `docs/specs/s<n>.md`. Ela só relata. Achado que muda um requisito ou um `AD-` volta no gate.

   Leia e siga a skill `ce-doc-review` sobre o mesmo arquivo. Ausência de unidades, arquivos e verificação não é achado: a spec é `requirements-only`. Achado que muda um requisito ou um `AD-` não é aplicado. Correção de redação que deixa o requisito intacto entra no arquivo.

4. Pare. Mostre o caminho da spec, os `R` e o resultado da review. Pergunte se aprova, se ajusta, ou se descarta. Não faça commit antes do sim. No sim, o commit segue o `CLAUDE.md` e leva só este arquivo: `docs: spec s<n>`.

5. Aponte o `/sdlc-plan`. Não o rode nesta conversa.

## Revisão

Se `docs/specs/s<n>.md` já existe, esta execução é revisão. Mude requisito só com o usuário. Não apague um `R` em silêncio. Os passos 3 e 4 valem antes de commitar.
