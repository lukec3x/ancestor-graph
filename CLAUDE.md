# CLAUDE.md — Ancestor Graph

Agent-facing doc. `README.md` is for people using the project.

Ancestor Graph is a platform to register people and kinship and show them as a graph. A person can have parents, spouses, children, and non-marital unions. The graph is a set of typed edges, not a strict tree.

The apps are not scaffolded. This repository currently holds these two docs. Decisions below are locked. Do not reopen them unless asked.

## Language

Repository language is English: code, identifiers, comments, commit messages, docs, UI copy, and this file.

Comments explain why, not what the next line already says. Skip a comment when the name is enough.

## Workspace

One repository, two apps. pnpm belongs to the Vue app. Rails has its own Gemfile. No shared TypeScript package for the API contract. The contract is JSON.

| Path | Role |
| --- | --- |
| `apps/web` | Vite, Vue 3, TypeScript. Screens only. Calls the API. |
| `apps/api` | Rails API. The only process that opens Postgres. |

Do not add Next.js, React, Drizzle, a Node API, or a graph database.

## Stack

| Layer | Choice |
| --- | --- |
| Web | Vite, Vue 3, TypeScript |
| Graph UI | Vue Flow and elkjs. One rank per generation. |
| API | Rails, API only |
| Boundaries | One pack, `kinship`, with the folder anatomy below. Packwerk enforcement waits for a second pack. |
| Database | PostgreSQL |
| Auth | None until a second person uses the database. Then an `accounts` pack. |

Postgres recursive queries answer ancestors, descendants, and generation. A graph database waits until the question is path-finding across a large graph, not "who descends from whom."

## Web

Atoms are the controls that repeat outside the canvas: button, text field, date field, sex badge. Molecules assemble those into the person form and the kinship picker. The canvas is one organism. Inside it, Vue Flow's nodes and edges are the components. Do not split handles, edges, or generation ranks into atoms.

One page, the tree, composes the canvas and the editor panel. The panel calls the API. The canvas does not know about ActiveRecord.

## Rails pack

`packs/kinship/` is the kinship capability. Create it when the first use case is implemented. Do not add an empty pack for GEDCOM, citations, or accounts.

```text
packs/kinship/
├── package.yml
├── app/
│   ├── public/kinship.rb    the only door
│   ├── use_cases/           one business operation each
│   ├── domain/              link rules, no ActiveRecord
│   └── models/              Person, Union, Link
└── test/
```

The public door is `Kinship`. Callers outside the pack use that module and do not reference a use case class. The first operations are `register_person`, `link_parent`, `link_spouse`, and `graph`. `graph` returns people and links for the screen to draw. It does not return coordinates.

Controllers stay outside the pack. A controller turns the HTTP request into a call on `Kinship` and the result into a status. The pack does not know about the request.

`package.yml` can state the boundary. Turn on `enforce_dependencies` and `enforce_privacy` when a second pack exists. Until then Packwerk has no cross-pack edge to check.

Link direction lives in the domain. For `parent_child`, `from` is the parent and `to` is the child. A spouse link is one row for the pair; the two ids are not ordered. The two endpoints are different people. `union_id` on a spouse link is that pair's union. On a parent_child link it is the union the child is attributed to, when known.

## Domain model

Three tables:

- `people` — `name`, `sex` (`female`, `male`, `unknown`), `birth_date`, `death_date`, `notes`. Dates are calendar dates. Year-only or approximate dates are not modeled yet.
- `unions` — a couple or other union, with `started_on` and `ended_on`
- `links` — `parent_child` or `spouse`

Parentage, adoption, and marriage are data, not separate products. A person may have zero, one, or more than two parents. Spouses and unions can introduce cycles; do not assume the stored graph is a tree or a DAG.

Generation on screen is a layout rank, computed for display. It is not a column that has to stay in sync on every write.

## Graph UI

Layout is layered by generation. Each rank is one generation. elkjs computes that layout. Vue Flow handles pan, zoom, selection, and the person node.

Do not use a force-directed layout. Kinship turns into a hairball as soon as aunts, uncles, and marriages appear.

A click on a person opens edit. Creating a person and linking a parent or spouse is the first vertical slice. Do not build a second visualization beside it.

## Out of scope until asked

- GEDCOM import and export
- Sources and citations
- More than one tree per user
- Accounts, sharing, and permissions
- A graph database
- Empty packs, and Packwerk enforcement before a second pack exists

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/).

```
type(optional-scope): short description
```

- Types: `feat` (user-facing change), `fix`, `docs`, `refactor`, `style` (formatting only), `chore` (tooling, ignore files), `perf`, `test`, `ci`.
- Description: imperative, lowercase, no trailing period, about 72 characters. English.
- Body only when the why is not obvious from the subject.
- Examples: `docs: record the vue and rails split` · `feat: show a person and their parents on the graph`

## Editing conventions

- Match the stack table. A new library needs a reason tied to a task already in scope.
- Kinship rules live in the pack domain. Do not scatter parent and spouse checks across controllers and Vue components.
- Schema changes are Rails migrations reviewed as SQL.
- Do not add auth, GEDCOM, or a graph database as part of an unrelated change.

There is no `ai/INDEX.md` and no `*.skills.md`. This file is the canonical agent doc.
