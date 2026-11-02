# Architecture

## System design

Ancestor Graph is two processes. The browser shows one page, the tree. That page is a canvas and an editor panel. The Rails process is an API, and it is the only process that opens Postgres. The database is the whole product: one graph, every person, union, and link.

The canvas draws that graph with Vue Flow. elkjs places one generation on each rank. The canvas owns pan, zoom, selection, coordinates, and generation rank. It draws the document the panel hands it. It does not call the API.

The panel is the only part of the page that calls the API. It registers a person, replaces that person's fields, links a parent, and links a spouse. A click on a person opens that person's fields in the panel. After a successful write, the panel reads the graph again and replaces the document the canvas draws.

Controllers sit outside the kinship pack. A controller turns an HTTP request into arguments, calls the `Kinship` module, and turns the result into a status and a JSON body. The pack does not see the request. Link rules are not in the controller.

`Kinship` is the only door into the pack. Each operation is one use case. Link rules live in the domain, with no ActiveRecord: the two endpoints of a link are different people; on a parent link, `from` is the parent and `to` is the child; a spouse link is one unordered pair. Person, Union, and Link are the models. Sex and calendar dates are checked on the person model. A spouse-link operation creates that pair's union. A parent link may store an existing union, and it does not require the parent to be a spouse of that union.

Postgres stores `people`, `unions`, and `links`. Generation is not a column. A parent cycle, a repeated link, and a death date earlier than the birth date are stored. Name, notes, birth, death, and union dates may be empty. Sex is one of `female`, `male`, and `unknown`.

The system does not delete a person, remove a link, or change a union after the spouse link that created it. It does not keep accounts, a second tree, GEDCOM, citations, or a second visualization.

## Decisions

### AD-01. One database is the whole graph

The screen shows every person, union, and link in the database. No request carries a tree id or an account id.

Why. A view centered on one person, limited to ancestors and descendants, was refused. The page draws the stored graph, and a second tree waits until it is asked for.

What this governs. The graph read, and the absence of a scope key on every write.

### AD-02. The browser owns generation rank

The graph document contains people, unions, and links. It contains neither a generation rank nor coordinates. People who belong to the same parent cycle share one rank. That rank is 0 when no parent outside the cycle points at the cycle. Otherwise it is one greater than the highest rank among those outside parents. A person who is not in a cycle and has no parent is rank 0. Any other person's rank is one greater than the highest rank among their parents. Spouse links do not change rank. elkjs draws one rank per generation, and spouses keep their own ranks when those ranks differ.

Why. Returning a rank computed in Postgres was refused: rank is a display fact, and the graph read returns people and links. Letting elkjs assign layers from every edge, spouse edges included, was refused: spouse links may form cycles, and a rank would stop meaning one generation. Skipping one parent link along a single walk was refused: when every person in a cycle has a parent, that walk picks a different rank depending on where it starts.

What this governs. The graph payload and the canvas. When a later operation asks who descends from whom, Postgres recursive queries answer that. The graph read does not.

People in one parent cycle now share a rank. The earlier walk skipped one repeating link and assigned a different rank depending on its starting person.

### AD-03. Writes are resources, and a spouse link creates the union

The contract is JSON in snake_case. The routes are:

- `GET /graph` returns people, unions, and links. An empty database returns three empty arrays.
- `POST /people` creates a person.
- `PUT /people/:id` replaces that person's fields with the body: `name`, `sex`, `birth_date`, `death_date`, and `notes`.
- `POST /parent_links` creates a parent link from `parent_id`, `child_id`, and an optional `union_id`.
- `POST /spouse_links` creates the union and the spouse link from `person_ids`, `started_on`, and `ended_on`.

Ids in responses are database primary keys. The client does not mint them. A person response carries `id`, `name`, `sex`, `birth_date`, `death_date`, and `notes`. A union response carries `id`, `started_on`, and `ended_on`. A parent link carries `id`, `type` of `parent_child`, `parent_id`, `child_id`, and `union_id`. A spouse link carries `id`, `type` of `spouse`, `person_ids` as an unordered pair, and `union_id`. `POST /spouse_links` returns the link and the union. The other writes return the record they wrote.

There is no route to delete a person, remove a link, create a union on its own, or update a union later.

Why. URLs named after use cases were refused: callers outside the pack use the `Kinship` module and do not take a dependency on use case names. One RPC endpoint was refused: the graph is a read of the whole collection. A union resource with its own create and update was refused: the union comes into existence with the spouse link.

What this governs. The JSON both apps share.

### AD-04. Person attributes fail on the person model

Sex and calendar dates are checked on the person model, and the database repeats that check. `sex` is required and is one of `female`, `male`, and `unknown`. A birth or death value that is present and is not a calendar date fails on that model. An empty birth or death is stored. The controller passes the values into the pack and maps the failure to a status. Link rules stay in the domain.

Why. A domain object for sex and dates was refused: the domain is link rules with no ActiveRecord, and the person would exist twice. Checking sex and dates in the controller was refused: another caller of `Kinship` would skip the check, and the controller would own a rule instead of mapping a result to a status.

What this governs. Every write of a person's fields, from the HTTP controller or from any later caller of `Kinship`.

### AD-05. Known failures return one error envelope

A failed request returns `{ "errors": [ { "code", "field" } ] }`. `field` names the argument when the failure is about one argument, and it is null when the failure is the whole operation. The pack returns a result: the written records, or a failure with these codes. It does not return an HTTP status. The controller chooses the status.

| Code | Status | When |
| --- | --- | --- |
| `invalid` | 422 | The body is not the contract. A spouse `person_ids` that is not a pair of two ids fails here and does not enter the pack. |
| `not_found` | 404 | A person id or a union id on the write does not exist. |
| `same_person` | 422 | The two endpoints are the same person. This includes a spouse pair of two equal ids, which does enter the pack. |
| `invalid_sex` | 422 | `sex` is missing or outside `female`, `male`, and `unknown`. |
| `invalid_date` | 422 | A present `birth_date` or `death_date` is not a calendar date. |

`GET /graph` of an empty database is 200, not an error. Creates return 201. A person replace returns 200.

Why. Raising as the way to report a known failure was refused: a failure that escapes the controller becomes a 500, and the controller is specified to turn a result into a status. Returning nil was refused: the controller cannot choose a status without a reason.

What this governs. The pack result and every error body the page reads.

### AD-06. The canvas draws the last graph it was given

A successful write does not change the canvas by itself. The panel requests `GET /graph` again and replaces the canvas document with that response.

Why. Returning the whole graph from every write was refused: the write result is the record just written, and the graph document would otherwise exist twice. Patching people and links inside the browser was refused: the browser would be a second writer of kinship.

What this governs. The panel after every successful create or replace.
