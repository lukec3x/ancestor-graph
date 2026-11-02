---
name: rails-migrations
description: Write and review Rails database migrations safely, including reversible changes, lock-aware operations, and rollout sequencing. Use when adding or changing schema, indexes, constraints, or backfills in apps/api.
---

# Rails Migrations

Use for schema changes and migration safety in `apps/api`.

## This repository

Postgres is the only database. There is no SQLite, no Solid Queue database, and no tenant column. Skip multi-tenant index strategy and multi-adapter guards.

Foreign keys are allowed. Pick one posture in the migration and stay with it.

## Rules

- Make migrations reversible whenever possible (`reversible` blocks with explicit up/down SQL for data moves).
- Use raw SQL for data manipulation inside migrations; avoid referencing app models that drift over time.
- Avoid long table locks on large tables; split risky work into multiple deploy-safe steps.
- Separate schema changes from heavy data backfills.
- Prefer database operations that remain safe when rerun (`table_exists?` / `column_exists?` guards where migrations may run against varied states).
- Small inline backfills are fine in one migration (add column, `execute "UPDATE ..."`, tighten constraint). Anything long-running moves out of the migration path entirely.

## Script Backfills

Long-running or risky data backfills live in `script/migrations/*.rb` and are run manually, not in the deploy migration window:

- Document preconditions and run instructions in the header comment.
- Preflight queries print scope before mutating.
- Idempotent: skip rows already processed so reruns are safe.
- Batched (`find_each` / `in_batches`), never one giant write.

## Safe Patterns

- Add nullable column, backfill, then enforce `NOT NULL`.
- Add index concurrently when supported and needed.
- Dedupe data with raw SQL immediately before adding a unique index.
- Data-only migrations are legitimate: `find_each` + `update!` up, `update_all` down.
- Batched backfills instead of one giant write.

## Constraints

- Prefer a database unique index over ActiveRecord `validates uniqueness` (the validation races; the index does not).
- Foreign keys are a tradeoff. Either posture is fine when it is consistent and written down.
- Enforce odd invariants with a cheap schema trick where a CHECK constraint is awkward.

## Staged Rollout

- **Column replacement:** add the nullable column, dual-write and backfill, read from the new column, then enforce constraints and drop the old column in a later change.
- **Constraint hardening:** clean the data first, add the index or constraint only after the data complies, then let application code rely on it.
- **Destructive changes:** stop reads and writes in application code, remove the usage, then drop the column or table after a confirmation window.

## Red Flags

- Irreversible migrations without an explicit reason.
- Combining a schema rewrite and a heavy data migration in one step.
- Large backfills inside the default transaction of `db:migrate`.
- Dropping columns or tables without staged deprecation.
- Referencing app models in migrations.
- Adding a unique index without first deduping existing data.
- `validates uniqueness` with no backing unique index.
