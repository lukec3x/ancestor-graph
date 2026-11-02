---
description: Plano de arquitetura deste projeto Rails. Grava docs/architecture.md e para no gate, antes de qualquer issue.
---

# Brainstorm do projeto

Fase de planejamento deste repositório. Decide como o sistema entrega o que o `CLAUDE.md` já fixou. Não fatia issues, não escreve spec e não implementa.

Fale com o usuário em português. O arquivo de arquitetura sai em inglês, como o resto do repositório.

## O que já está decidido

Leia `CLAUDE.md` e `README.md` na raiz. Decisão marcada como fechada fica fechada. Não reabra stack, modelo de dados, fronteira entre `apps/web` e `apps/api`, nem a regra de que o controller fica fora do pack e a regra de parentesco fica no domínio. Contradição entre esses arquivos e o que o usuário pede agora vai para ele, em texto, antes de desenhar.

Não invente o produto.

## Código

Se o repositório tem código, ancore o desenho nele. Cada afirmação de reuso leva arquivo e linha. Se ainda não há app, diga isso e desenhe a partir dos docs. Não construa grafo de código para esta fase.

## O que esta fase decide

Só o que ainda está aberto e vale para o projeto inteiro: contratos entre as partes, quem é dono de cada estado, a forma do que entra e do que sai, e onde cada regra mora.

Fica para a issue: nome de arquivo, nome de método, unidade de implementação, cenário de teste, texto e estilo.

Não liste issues. Não conte as fatias. Isso é o breakdown.

## Passos

1. Diga, nas palavras do sistema, o que o produto exige: o que entra, o que sai, o que falha, e o que os docs já travaram. Pergunte, uma pergunta por vez, com no máximo quatro opções e *Other* para texto livre: confirmar ou ajustar. Ajuste que muda o produto para e volta ao usuário.

2. Se uma decisão ainda aberta for qual camada do Rails é dona de uma responsabilidade, invoque o subagente `layered-rails-planner` com o `CLAUDE.md` e essa decisão. A resposta entra como opção no passo 3. Não é decisão. Fronteira já fechada no `CLAUDE.md` não vai para o planner. Se não houver fronteira aberta, pule o planner e diga isso.

3. Para cada decisão ainda aberta, compare no máximo três opções. Cada opção diz o que ela fixa e o que ela custa. A opção recomendada vem primeiro. Decisão já travada no `CLAUDE.md` não entra na comparação.

4. Escreva `docs/architecture.md` na raiz, só depois da confirmação do passo 1. Estrutura:

```markdown
# Architecture

## System design

Uma página. O que cada parte do sistema faz, e o que ela não faz.

## Decisions

### AD-01. Título

A decisão, em uma frase.

Por quê. A opção recusada e o motivo, quando houve comparação.

O que isso governa.
```

Numere `AD-02`, `AD-03`, na ordem. Sem issues, sem tarefas, sem estimativa.

5. Leia e siga a skill `ce-doc-review` sobre `docs/architecture.md`. Achado que muda ou acrescenta uma decisão não é aplicado: ele volta no gate, como ajuste. Correção de redação que deixa a decisão intacta entra no arquivo. O gate mostra o resultado da review, inclusive o que ficou aberto e por quê.

6. Pare. Mostre o caminho do arquivo, a lista dos `AD-` e o resultado da review. Pergunte se aprova, se ajusta, ou se descarta. Não faça commit nem push antes do sim. No sim, o commit segue o `CLAUDE.md`: `docs: record project architecture`.

## Revisão

Se `docs/architecture.md` já existe, esta execução é revisão. Leia os `AD-` atuais. Mude só o que o usuário apontou ou o que o código contradiz, com a evidência. Um `AD-` alterado ganha uma linha no fim do bloco: o que mudou e por quê. Não apague um `AD-` em silêncio. Os passos 5 e 6 valem antes de commitar.
