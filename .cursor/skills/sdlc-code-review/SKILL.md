---
name: sdlc-code-review
description: Esta skill deve ser usada quando alguém pede review de código da branch atual — "revisa o código", "code review da branch", "review do diff", "o código está pronto?", "revisa o código da s<n>" — e quando o /sdlc-build revisa o diff contra a spec e o plano. Report-only. Achados Critical/Major/Minor/Trivial no formato onde, defeito, consequência, conserto.
---

# SDLC Code Review

Review report-only da branch, contra a spec e o plano da fatia. Cinco revisores em
paralelo, cada um com uma lente; depois, cada achado é verificado por um agente
independente, e só sobrevive o que ele confirma. Não editar, não commitar, não fazer
checkout nem mexer no índice.

## 0. Alvo e escopo

Nada vale se o diff estiver errado. Declarar em uma linha o fluxo escolhido.

| Token | Fluxo |
|---|---|
| `s<n>` ou nome de branch | **branch nomeada**, sem checkout |
| `<sha>..<sha>` junto com a branch | **rodada incremental** |
| nada disso | **branch local** (a atual) |

A base é `git config --get branch.<branch>.sdlc-base`. Sem a chave, a base é `master`.
Não exige remoto. Se `origin` existir, `git fetch origin <base>` pode falhar: seguir com
a base local.

- **Branch nomeada:** branch = o nome dado, ou a única `refs/heads/s<n>/*` (nenhuma ou
  mais de uma: parar). Diff = `git diff "$(git merge-base <branch> <base>)" <branch>`.
  Ler com `git show <branch>:<arquivo>`.
- **Rodada incremental (`<a>..<b>`):** arquivos = `git log --no-merges --name-only --format= <a>..<b>`;
  diff = `git diff <base>...<b> -- <esses arquivos>`.
- **Branch local:** diff = `git diff "$(git merge-base HEAD <base>)"` mais os untracked
  (`git ls-files -o --exclude-standard`), lidos inteiros. Ler da árvore, não de `HEAD`:
  o não commitado e os untracked só existem nela. Esperados, não param: commits do
  pipeline em `docs/specs/` e `docs/plans/`. Outros commits que não são da fatia
  (merge de outra branch, arquivos fora do `Files` do plano) → parar e dizer.

Tags, a partir de `git diff --name-only` do alvo: `db/migrate` → `migrations`; `*.rb` →
`rails`; `apps/web` com `*.vue` ou `*.ts` → `ui`. `git diff --stat` dá o tamanho.

**Documento:** o passado, ou `docs/specs/s<n>.md` e `docs/plans/s<n>.md` da fatia (o `s<n>`
sai da branch `s<n>/…`), mais `docs/architecture.md` quando o plano cita `AD-`. Sem
documento: dizer e seguir sem a lente 1.

## 1. Revisores em paralelo

Despachar os cinco numa única mensagem (`Agent`, `generalPurpose`). Cada um recebe o
comando de diff, como ler o código, as tags, o caminho do documento e só a sua lente, e
devolve achados no formato da § Saída, cada um com o cenário de falha. Nenhum edita nada.

1. **Conformidade:** cada R-ID, `AD-` e cenário de teste do plano → implementado, parcial
   ou ausente, com `arquivo:linha`. Também o contrário: o que o diff faz e o documento não
   previu. Divergência justificada no documento é decisão, não achado. Preferência por
   outro arranjo é advisory. Inviabilidade genuína é achado com severidade cheia.
2. **Bugs nas linhas alteradas:** lógica, borda (vazio, nulo, zero, último item), erro
   engolido, caller quebrado pela mudança. Pela tag `migrations`: reversibilidade e
   compatibilidade. Performance só com cenário de resultado errado ou indisponibilidade.
3. **Testes:** cenários do plano sem teste; teste que passaria com a lógica revertida;
   asserção frouxa demais para pegar a regressão; mock no lugar do código sob teste.
   Para cada caminho crítico descoberto, escrever o caso de teste que falta. Teste Rails
   segue a skill `rails-testing`.
4. **Histórico:** `git log -L` e `git blame` das linhas alteradas. Procura a mudança que
   desfaz um conserto antigo.
5. **Regras do repo:** o `CLAUDE.md` da raiz e dos diretórios tocados, os comentários do
   código alterado e a convenção do arquivo vizinho (que vence a regra genérica). Inclui
   dívida introduzida pelo diff: TODO, workaround, teste pulado.

## 2. Verificação de cada achado

Juntar os achados, unir os repetidos (o mesmo defeito em vários arquivos vira um achado
com todos os lugares) e despachar, numa única mensagem, um agente por achado. O agente
tenta **refutar** o achado, em três passos: análise (o que o achado afirma e onde),
investigação (o código, a spec, o plano e os `AD-` da área) e refutação (a evidência
contrária: a linha não está no diff, o estado não acontece, um teste já cobre, uma
decisão registrada aceita a consequência). Ele lê o código como os revisores e devolve
uma nota de 0 a 100:

- **0:** falso positivo, ou já existia antes do diff.
- **25:** pode ser real, mas não conseguiu confirmar; ou é estilo que nenhuma regra do
  repo pede.
- **50:** real, mas raro, ou menor (não toca nenhum item de **Relevante**) diante do resto do diff.
- **75:** confirmado no código, acontece na prática e o diff não trata.
- **100:** confirmado, acontece com frequência, a evidência é direta.

Para dar a nota, responde: está nas linhas do diff? Qual entrada e estado levam à saída
errada? Que teste quebraria com a linha revertida (nenhum → o achado vira "falta o
teste")? Achado de regra do repo: a regra diz isso de fato? O verificador não edita.

**Abaixo de 75, fora dos Achados:** de 50 a 74 vai a **Não enviados**, uma linha cada, e
não conta no veredito; abaixo de 50, descartar. Também são falsos positivos: o que o
linter ou o typecheck pegam; nitpick que um sênior não apontaria; mudança de
comportamento intencional e coerente com o plano; problema em linha que o diff não tocou.

## Severidade e relevância

| Severidade | Quando |
|---|---|
| **Critical** | vulnerabilidade, perda ou corrupção de dado, crash, regra de parentesco quebrada no caminho principal |
| **Major** | bug, regressão, comportamento do escopo sem teste, contrato com outra fatia ou `AD-` violado |
| **Minor** | melhoria menor com efeito no comportamento ou na manutenção |
| **Trivial** | cosmético: nome, comentário, formatação |

**Relevante:** afeta correção, segurança, regra de parentesco, contrato com outra fatia
ou `AD-`, ou deixa sem teste um comportamento do escopo. Critical sempre é. O resto vai
a **Não enviados**, uma linha cada.

## Saída

Cabeçalho: fluxo, documento, base e merge base, comando de diff com arquivos/linhas, tags.

Achados relevantes por severidade:

```
[Critical|Major|Minor|Trivial] <título curto> (nota <n>)
- Onde: <arquivo:linha>, …
- Defeito: <uma frase>
- Consequência: <entrada e estado → saída errada>
- Conserto: <mudança mínima, ou o caso de teste escrito>
```

Depois: **Conformidade** (item → implementado/parcial/ausente), **Não enviados**,
**Cobertura** (o que não foi revisado e por quê, inclusive revisor que falhou) e
**Veredito:** `limpo` ou `achados relevantes: <n>`.

Nada sobreviveu à verificação → dizer isso. Um review vazio e honesto vale mais que
achados inventados.
