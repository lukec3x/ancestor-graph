---
description: Enriquece a spec aprovada num plano de implementação. Não escreve código.
argument-hint: "[S1] — inferida da branch s<n>/… se omitida"
---

# Plano de uma fatia

Fase de implementação desta fatia. O plano diz arquivos, unidades e verificação. Não escreve código de aplicação e não roda teste.

Fale com o usuário em português. O plano sai em inglês, como o resto do repositório.

Quem escreve o plano é a skill `ce-plan`. Não escreva o plano à mão e não parafraseie a skill.

## Entrada

A fatia sai da branch atual (`s1/register-person` → `S1`) ou do argumento. Sem as duas, pare e pergunte. Não adivinhe.

`docs/specs/s<n>.md` tem de existir. Sem ele, pare e mande rodar `/sdlc-spec`.

Leia os `AD-` citados em `### Key Decisions` da spec e o bloco de cada um em `docs/architecture.md`. Se a arquitetura mudou depois do commit da spec, pare e mande rodar `/sdlc-spec` de novo.

Se `$(git rev-parse --git-dir)/sdlc-grounding.md` existir, ele é o mapa inicial do código.

## Passos

1. Copie a spec, literal, para `docs/plans/s<n>.md`. O `ce-plan` enriquece esse caminho. Não crie arquivo com timestamp.

2. Invoque o subagente `layered-rails-planner` com a spec, o `CLAUDE.md` e os `AD-` consumidos. São restrições a conferir, não decisões a reabrir. Fronteira já fechada no `CLAUDE.md` permanece. O retorno entra no passo 3. Não monte um plano a partir dele.

3. Leia e siga a skill `ce-plan` em `docs/plans/s<n>.md`. Diga na invocação:

   - Enriqueça esse caminho, no lugar, até `artifact_readiness: implementation-ready` e `execution: code`, em markdown.
   - Os `R` da spec ficam com o mesmo texto e o mesmo id. As unidades os citam.
   - Acrescente `## Planning Contract`, `## Implementation Units` (`### U1.` e seguintes, cada uma com Goal, Requirements, Files, Approach, Test Scenarios, Verification e Patterns to follow), `## Verification Contract` e `## Definition of Done`.
   - Patterns to follow cita a seção do `CLAUDE.md` que a unidade tem de obedecer.
   - Os achados do planner entram nas Key Technical Decisions.
   - Cada `AD-` consumido ganha uma entrada em `### Architecture Decision Validation`: `holds`, `conflict` ou `invalid`, com arquivo e linha quando houver código. `invalid` não se contorna.
   - Os comandos de verificação são os que o repositório tem. Teste Rails leva `RAILS_ENV=test`. Sem suíte ainda, o plano nomeia o comando que a fatia cria e diz que a suíte não existe.
   - Uma unidade fica num app, salvo quando o fluxo da fatia atravessa `apps/web` e `apps/api`.
   - Pare no plano. Não ofereça `ce-work`.

   A skill roda o `ce-doc-review`. Se ela não rodou, rode você sobre `docs/plans/s<n>.md`. Achado que muda unidade, arquivo ou requisito volta ao `ce-plan` no mesmo caminho. Não edite o plano à mão.

   Leia e siga a skill `sdlc-doc-review` sobre `docs/plans/s<n>.md`. Ela só relata. Achado que muda unidade, arquivo ou requisito volta ao `ce-plan`.

4. Rode `script/plan-contract.sh docs/plans/s<n>.md --require implementation-ready`. Falha volta ao `ce-plan`. Não complete seção faltante à mão. Além do script, confira uma validação por `AD-` consumido: o script não olha isso. Lacuna volta ao `ce-plan`.

5. Pare. Mostre o caminho do plano, o objetivo, as unidades com os arquivos, os comandos de verificação e a validação de cada `AD-`. `invalid` bloqueia a aprovação: revise com `/sdlc-brainstorm`, rode `/sdlc-spec` de novo e volte aqui. `conflict` o usuário aceita ou manda revisar do mesmo jeito. Pergunte se aprova, se ajusta, ou se descarta. Ajuste volta ao `ce-plan`, nunca à mão. Não faça commit antes do sim. No sim, o commit segue o `CLAUDE.md` e leva só este arquivo: `docs: plan s<n>`.

6. Aponte o `/sdlc-build`. Não o rode nesta conversa.
