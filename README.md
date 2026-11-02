# Ancestor Graph

A platform to register people and kinship and show them as a graph. Parents, spouses, children, and other unions are links between people. The screen lays those links out by generation.

The repository is in English: code, comments, commit messages, and the interface.

## Status

The stack and the data model are chosen. The Vue app and the Rails API are not scaffolded yet, so there is nothing to install or run.

## Stack

One repository, two apps:

- `apps/web` — **Vite**, **Vue 3**, and **TypeScript**. **Vue Flow** and **elkjs** draw the graph, with one rank per generation.
- `apps/api` — **Rails** API and **PostgreSQL**. Kinship lives in one pack, `kinship`.

The screen calls the API. The API is the only process that opens the database. The JSON response is the contract.

Accounts wait until more than one person uses the same database. Importing GEDCOM, citations, and more than one tree per user wait until a person can be created and shown with their parents and spouse.

## Data model

- `people` — name, sex, birth, death, notes
- `unions` — a couple or other union, with start and end
- `links` — `parent_child` or `spouse`

`parent_child` stores the parent in `from` and the child in `to`. A spouse link is one row for the pair. Ancestors, descendants, and generation come from recursive queries. The graph is not stored as a strict tree: a person may have any number of parents, and marriages are not required to form a hierarchy. Generation on screen is a layout rank, not a stored column.
