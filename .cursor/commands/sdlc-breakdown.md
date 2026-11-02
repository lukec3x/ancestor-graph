---
description: Corta este projeto em fatias verticais. Grava docs/slices.md e, depois da aprovação, espelha cada fatia numa issue do GitHub.
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

Não estime prazo. Não proponha flag. A lista mora neste arquivo. A issue no GitHub é o espelho, e só abre depois da aprovação. O id da fatia continua `S1`; o número do GitHub não vira id de branch nem de spec.

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

Issue: https://github.com/<owner>/<repo>/issues/<n>
```

A linha `Issue` entra no passo 5, com a URL que o `gh` devolveu. Numere `S3`, `S4`, na ordem de construção. Cada `AD-` de `docs/architecture.md` aparece em `Consumes` de alguma fatia, ou numa seção final `## Not sliced` com o motivo. `## Not sliced` não vira issue. Sem tarefas, sem nomes de arquivo, sem estimativa.

3. Leia e siga a skill `ce-doc-review` sobre `docs/slices.md`. Achado que muda o corte, a ordem ou o que uma fatia consome não é aplicado: ele volta no gate, como ajuste. Correção de redação que deixa o corte intacto entra no arquivo. O gate mostra o resultado da review, inclusive o que ficou aberto e por quê.

4. Pare. Mostre o caminho do arquivo, a ordem das fatias, todo `AD-` que nenhuma fatia cita e o resultado da review. Pergunte se aprova, se ajusta, ou se descarta. Não faça commit, push nem issue antes do sim.

5. No sim, espelhe e depois commite. O commit fica local. Não faça push.

   Sem `origin`, ou com remoto que não é GitHub, ou com `gh` sem autenticação: não abra issue. Diga qual dessas três foi a causa. O commit segue o `CLAUDE.md` e leva só `docs/slices.md`: `docs: record project slices`.

   Com `origin` no GitHub e `gh` autenticado, na ordem das fatias:

   - Fatia com `Status: dropped`: `gh issue close <n> --comment "<motivo>"` quando houver linha `Issue`. A seção permanece no arquivo, com o motivo. Não reabra.
   - Fatia ativa com linha `Issue`: `gh issue edit <n> --title "S1. <outcome>" --body "<corpo>"`. Se a issue estiver fechada, `gh issue reopen <n>`.
   - Fatia ativa sem linha `Issue`: `gh issue create --title "S1. <outcome>" --body "<corpo>" --assignee @me`. Grave a URL devolvida na linha `Issue` dessa seção.

   O título é o cabeçalho da seção, sem os `#`. O corpo, em inglês, são as linhas `Done when`, `Consumes` e `Blocked by`. Quando o bloqueio nomeia uma fatia que já tem URL, a URL entra entre parênteses nessa linha. `## Not sliced` não vira issue.

   Falha numa issue para antes do commit. O arquivo fica com o link das que já abriram. A próxima execução trata as que têm link como edição e abre as que não têm.

   Com as linhas `Issue` gravadas, o commit segue o `CLAUDE.md` e leva só `docs/slices.md`: `docs: record project slices`.

## Revisão

Se `docs/slices.md` já existe, esta execução é revisão. Mude só o que o usuário apontou ou o que um `AD-` novo deixou de fora. Não apague uma fatia em silêncio: marque `Status: dropped — <motivo>` na seção. Os passos 3, 4 e 5 valem antes de commitar.
