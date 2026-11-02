# Eixos do review de documento

As lentes dos revisores do `SKILL.md`.

## 1. UX/UI

- Cada fluxo tem estado vazio, carregando, erro e sucesso? O de erro é o que mais falta.
- O que o usuário vê quando a operação demora, falha parcialmente ou já foi feita?
- A mensagem de erro está redigida, ou o executor vai inventar a copy?
- Responsivo, foco e teclado, leitor de tela: omissão declarada é escopo; silenciosa é achado.
- Muda uma tela existente? Dizer o que acontece com o comportamento atual: mantido,
  substituído ou convivendo.

Sem tela (API pura, migração): dizer em Cobertura.

## 2. Arquitetura e estratégia

**Sintoma × causa raiz.** Para cada símbolo que o documento muda, contorna ou substitui,
`grep` dos consumidores. Guarda só no caminho que a fatia nomeia deixa os irmãos
quebrados. Achado: os consumidores que seguem errados, nomeados.

**Conceito redefinido.** Segunda definição de algo que existe (segunda fonte de verdade,
segunda constante para o mesmo limite, segundo caminho para a mesma ação). Ou corrige a
antiga, ou responde: por que convivem, qual manda em qual superfície, o que acontece
quando divergem. Faltando as três, é achado.

**Segunda implementação × abstração especulativa.** Reescrever mecânica que já existe no
repo, ou generalizar o que tem um consumidor. Extrair porque já há dois é contenção;
porque talvez haja, é dívida.

**Contenção e raio.** Arquivos, camadas e apps tocados, e por quê. A API é a única
processo que abre o Postgres. O controller fica fora do pack e chama `Kinship`. Arquivo
que cresce: o número do `wc -l`, não impressão.

**Precedência.** O problema de base em que o trabalho pisa só é achado com **custo de
arrumar agora**, **juro de não arrumar** (o que encarece e quando) e **quem decide**.
Declarado é dívida aceita; não mencionado é achado.

**Ordem e reversibilidade.** A sequência das unidades deixa a base quebrada no meio?
Migração sem volta? Mudança de comportamento existente sem um jeito de voltar: silêncio
é achado.

**Estratégia.** Foi comparada com uma abordagem mais barata? Fork técnico em aberto que
decide a forma do resultado é decisão que faltou.

**AD de projeto.** Documento que consome `AD-` de `docs/architecture.md` deve segui-lo.
Contornar um AD na fatia é achado; o conserto é revisar o AD com `/sdlc-brainstorm`.

## 3. Regras de parentesco, contra o CLAUDE.md

Ler o modelo de domínio no `CLAUDE.md`. Nunca inventar regra de parentesco.

1. Extrair toda afirmação de domínio: pessoa, união, `parent_child`, `spouse`, direção
   do link, `union_id`, geração, ciclo por casamento.
2. Cada uma confere, contradiz ou não está no `CLAUDE.md`. **Contradiz** → Critical,
   com a seção citada. **Não está** → regra nova (o documento diz que é nova e quem
   decidiu) ou buraco (voltar ao `/sdlc-brainstorm`).
3. Bordas: a pessoa sem pai, com um pai, com mais de dois; os dois extremos do link são
   a mesma pessoa; `union_id` desconhecido; união encerrada; cônjuge que também é
   ancestral.
4. Direção: `from` é o pai e `to` é o filho em `parent_child`. `spouse` é uma linha por
   par, sem ordem. Geração é rank de layout, não coluna.

Sem afirmação de domínio: dizer em Cobertura.

## 4. Ambiguidade

Ambíguo é o trecho que dois executores competentes implementam diferente. Citar a frase,
escrever **as duas leituras concretas** e dizer qual muda o resultado para o usuário. Sem
as duas leituras, não é achado. Suspeitos: "adequado", "se necessário", "tratar o erro",
"validar os dados", "atualizar a tela", verbo sem sujeito, prazo ou limite sem número.

## 5. Contexto que ficou de fora

O que o documento precisa e não carrega porque o autor já sabia:

- sistema afetado não citado: a tela do grafo, o contrato JSON, a migração;
- dado prévio: seed, backfill, configuração por ambiente;
- chamador a montante e consumidor a jusante que quebram junto;
- decisão que só existe na conversa;
- documento linkado quebrado ou inacessível para o executor.

Para cada um: o que falta, onde aparece na execução e a pergunta única que resolve.

## 6. Inconsistência entre requisitos

Conflito, não incompletude:

- dois requisitos que não podem valer juntos;
- termo com dois sentidos no documento;
- escopo declarado fora e assumido dentro por outra seção;
- só em `implementation-ready`: requisito que o DoD não verifica, verificação sem
  requisito, unidade que não serve requisito, requisito sem unidade.

## 7. Risco e mitigação

Só riscos que **este documento** cria ou agrava, cada um como: gatilho concreto → o que dá
errado → como detectar → mitigação no documento. Sem mitigação acionável, cortar.

Prioridade: perda ou corrupção de dado de parentesco, link com os extremos trocados,
ciclo tratado como árvore, migração sem volta.
