---
name: sdlc-doc-review
description: Esta skill deve ser usada quando o usuário pede para "revisar a spec", "revisar o plano", "review da spec", "review do plano", "o plano está pronto para executar?", "a spec está pronta?", "doc review", ou pede review de um documento em docs/specs/ ou docs/plans/ (s<n>) antes do build. Faz review report-only de spec (requirements-only) ou plano (implementation-ready). Diferente do ce-doc-review, que audita forma e aplica correções, não edita o documento e audita se a base aguenta e o que o executor decidiria sozinho.
---

# Review de spec e plano (SDLC)

Report-only, antes de qualquer código: não editar o documento, não implementar, não abrir
branch.

Não refazer o que já roda: `script/plan-contract.sh` e o `ce-plan` auditam a forma; o
`ce-doc-review` pega citação errada, contradição entre seções e cenário não escrevível; o
`layered-rails-planner` escolhe a camada. Sobra: **a base aguenta, ou o documento cobre um
problema estrutural com código novo?** e **o que o executor decide sozinho porque o
documento não decidiu?**

## 0. Alvo

Arquivo, diretório (todos os documentos dentro), chave (`s1` → `docs/specs/s1.md` e
`docs/plans/s1.md`) ou a branch atual. Sem alvo, pela branch:

```bash
key=$(git branch --show-current | grep -oE '^s[0-9]+' | head -1)
ls "docs/specs/$key.md" "docs/plans/$key.md" 2>/dev/null
```

Revisar cada arquivo que existir, cada um com a sua calibração. Sem chave ou sem arquivo:
perguntar o alvo. Um diff passado junto é o **foco** da rodada: achados só nos trechos que
ele toca e no que depende deles.

Ler junto o que o documento linka (`docs/architecture.md`, `docs/slices.md`, `CLAUDE.md`).
Link inacessível para o executor é achado do eixo 5; inacessível só para o revisor vai
para Cobertura.

**Calibração por `artifact_readiness`** (frontmatter). Cobrar o que o estágio não tem é ruído:

- **`requirements-only`** (spec, `/sdlc-spec`): sem Units, `Files`, Verification Contract
  nem DoD, e a ausência deles não é achado. O contrato são `R<n>`, Acceptance Examples e
  Scope Boundaries. Arquitetura aqui: requisito que só se cumpre empilhando condicional,
  `Means` fixado sem alternativa, conceito redefinido no requisito, colateral pré-existente
  que a entrega agrava.
- **`implementation-ready`** (plano, `/sdlc-plan`): tudo entra, e a arquitetura é avaliada
  como proposta.
- **Sem frontmatter:** extrair as afirmações verificáveis e dizer que extraiu. Nunca
  inventar o contrato.

**Orçamento de código**, fechado, de dentro do worktree: (1) os `path:line` que o documento
cita; (2) `grep` dos símbolos que ele muda, contorna, redefine ou substitui, para contar
consumidores; (3) `wc -l` dos arquivos que a entrega toca ou faz crescer; (4) `grep` do
mecanismo que ele propõe criar, para achar um que já existe. Nada além. Achado de
arquitetura sem código aberto é impressão: cortar. Sem app ainda, o eixo 2 vira advisory
e entra em Cobertura.

Cabeçalho em uma linha: arquivo(s), `artifact_readiness`, worktree, ids usados como
contrato (`R<n>`, `U<n>`, critérios, bullets).

## 1. Revisores em paralelo

Despachar os quatro numa única mensagem (`Agent`, `generalPurpose`). Cada um recebe o
caminho do documento (e da spec, se o alvo é o plano), o foco da rodada, a calibração, o
orçamento de código, o caminho de `references/axes.md` com as seções da sua lente, e devolve
achados no formato da § Saída, cada um com o cenário: lê a seção X, conclui Y, implementa Z,
quebra W. Nenhum edita nada.

| Revisor | Eixos de `references/axes.md` |
|---|---|
| **Produto** | 1. UX/UI · 4. Ambiguidade |
| **Base** | 2. Arquitetura e estratégia · 7. Risco e mitigação |
| **Domínio** | 3. Regras de parentesco (contra o `CLAUDE.md`) |
| **Coerência** | 5. Contexto que ficou de fora · 6. Inconsistência entre requisitos |

## 2. Verificação de cada achado

Juntar os achados, unir repetidos e despachar, numa única mensagem, um agente por achado.
Ele relê o documento inteiro (e o código do orçamento), não edita nada e dá nota de 0 a 100:

- **0:** o documento já responde em outra seção (Scope Boundaries cobrem muito buraco
  aparente), ou é falso.
- **25:** pode ser real, mas não confirmou.
- **50:** real, mas não muda a execução.
- **75:** confirmado; Critical/Major com o caminho concreto escrito até a decisão errada
  do executor.
- **100:** confirmado com evidência direta (trecho do documento, `path:line`, trecho do
  `CLAUDE.md`).

**Abaixo de 75, fora dos Achados:** de 50 a 74 vai a **Não enviados**, uma linha cada, e
não conta no veredito; abaixo de 50, descartar. Antes da nota, reclassificar: arranjo
diferente com o mesmo resultado é **Minor advisory**; achado estrutural sem o
**multiplicador escrito** (o que fica mais caro e quando cobra) é gosto arquitetural e
vira Minor.

## Severidade e relevância

| Severidade | Quando |
|---|---|
| **Critical** | ao pé da letra produz resultado errado, perda ou corrupção de dado, exposição de dado, ou contradiz o `CLAUDE.md`; ou é achado estrutural pré-requisito (construir por cima multiplica o custo do conserto) |
| **Major** | retrabalho, ou o executor decide sozinho algo que muda o resultado (ambiguidade, contexto faltante, requisito sem verificação) |
| **Minor** | advisory: arranjo diferente com o mesmo resultado, observação que não muda a execução |
| **Trivial** | redação: termo, nome, formatação |

**Relevante:** Critical sempre; Major, Minor e Trivial só se afetam correção do que será
construído, segurança, regra de parentesco, contrato com outra fatia ou `AD-`, ou deixam
sem teste um comportamento do escopo. O resto vai a **Não enviados**, uma linha cada, e
não segura a etapa.

## Saída

Cabeçalho do § 0 e veredito em uma linha. Com dois documentos, a Saída inteira para cada
um, spec primeiro.

- **pronto para executar**: nenhum Achado
- **executável com ressalvas**: os achados cabem nesta entrega
- **resolve a base primeiro**: há achado estrutural pré-requisito
- **volta para o autor**: o documento não decide o que precisa decidir

**Achados**, do Critical ao Trivial:

```
[Critical|Major|Minor|Trivial] <título curto> (nota <n>)
- Onde: <seção ou R<n>/U<n>, linha se houver>
- Defeito: <uma frase>
- Consequência: <a decisão errada do executor; estrutural: o que fica mais caro e quando>
- Conserto: <a redação mínima, escrita, não descrita>
```

Depois:

- **Não enviados**: uma linha cada.
- **Perguntas bloqueantes**: só as que documento e código não respondem; numeradas, cada
  uma com a opção recomendada.
- **Dívida estrutural aceita**: o que o documento propaga de propósito, com a frase dele
  que registra a decisão. Dívida não declarada é achado do eixo 2.
- **Cobertura**: eixos não avaliados e por quê (sem worktree, sem app, sem doc linkado,
  `requirements-only`, revisor que falhou); silêncio parece aprovação.

Nada sobreviveu → dizer isso; não fabricar achados para justificar a rodada.
