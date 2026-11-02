---
description: Corta este projeto em fatias verticais. Grava docs/slices.md e para no gate, antes de qualquer spec.
---

# Breakdown do projeto

Fase de corte deste repositório. Lê a arquitetura aprovada e divide o trabalho em fatias. Não reabre decisão, não escreve spec e não implementa.

Fale com o usuário em português. O arquivo de fatias sai em inglês, como o resto do repositório.

## Entrada

Leia `CLAUDE.md`, `README.md` e `docs/architecture.md`. Sem `docs/architecture.md`, pare e diga para rodar `/sdlc-brainstorm`. Não fatie no escuro.

Os `AD-` estão decididos. Se o corte mostra que um não se sustenta, pare e mande revisar com `/sdlc-brainstorm`. Não corrija o `AD-` aqui.

## Código

Se o repositório tem código, ancore o reuso nele, com arquivo e linha. Se ainda não há app, diga isso e corte a partir dos docs.

## Como cortar

Cada fatia é um fluxo de ponta a ponta: dado, API e tela. Uma fatia pronta é algo que uma pessoa usa. Não corte por camada (`Rails`, `Vue`, `testes`) nem por prioridade solta.

A primeira fatia é o menor caminho que prova o fluxo inteiro. No `CLAUDE.md` esse caminho é cadastrar uma pessoa, ligar um pai ou cônjuge e ver os dois no grafo. As seguintes engrossam esse caminho e ficam depois dela quando dependem dele de verdade.

Não estime prazo. Não proponha flag. Não crie issue fora deste arquivo.

## Passos

1. Diga, em poucas linhas, o corte que vai propor: a primeira fatia e o que fica para as seguintes. Pergunte, uma pergunta por vez, com no máximo quatro opções e *Other* para texto livre: confirmar ou ajustar. Ajuste que muda um `AD-` para e volta ao brainstorm.

2. Escreva `docs/slices.md` na raiz, só depois da confirmação. Estrutura:

```markdown
# Slices

## S1. Outcome in one line

Done when: what a person can do.

Consumes: AD-01

Blocked by: none

## S2. Outcome in one line

Done when: what a person can do.

Consumes: AD-02

Blocked by: S1
```

Numere `S3`, `S4`, na ordem de construção. Cada `AD-` de `docs/architecture.md` aparece em `Consumes` de alguma fatia, ou numa seção final `## Not sliced` com o motivo. Sem tarefas, sem nomes de arquivo, sem estimativa.

3. Leia e siga a skill `ce-doc-review` sobre `docs/slices.md`. Achado que muda o corte, a ordem ou o que uma fatia consome não é aplicado: ele volta no gate, como ajuste. Correção de redação que deixa o corte intacto entra no arquivo. O gate mostra o resultado da review, inclusive o que ficou aberto e por quê.

4. Pare. Mostre o caminho do arquivo, a ordem das fatias, todo `AD-` que nenhuma fatia cita e o resultado da review. Pergunte se aprova, se ajusta, ou se descarta. Não faça commit nem push antes do sim. No sim, o commit segue o `CLAUDE.md`: `docs: record project slices`.

## Revisão

Se `docs/slices.md` já existe, esta execução é revisão. Mude só o que o usuário apontou ou o que um `AD-` novo deixou de fora. Não apague uma fatia em silêncio: marque o que saiu e por quê. Os passos 3 e 4 valem antes de commitar.
