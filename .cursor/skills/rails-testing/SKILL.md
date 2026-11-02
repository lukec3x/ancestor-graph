---
name: rails-testing
description: Apply Rails testing standards with Minitest, fixtures, and pragmatic coverage boundaries. Use when creating tests, reviewing test quality, or improving flaky and slow Rails test suites in apps/api.
---

# Rails Testing

Use for test-writing and test-review tasks in `apps/api`.

## This repository

`apps/api` is a JSON API. There is no Hotwire, Turbo, Stimulus, or Action Text. Skip those assertions.

There is no tenant and no `Current.account` until an accounts pack exists. Do not add tenancy setup to tests.

The web app is Vue in `apps/web`. Do not cover it with Rails system tests. Browser checks for Vue screens belong to `ce-test-browser`.

Pack tests live under the pack's `test/`, mirroring the pack layout in `CLAUDE.md`.

Sections below that mention Turbo, Action Text, Solid Queue jobs, or multi-tenant `Current` do not apply here.

## Defaults

- Minitest + fixtures. No RSpec, no FactoryBot.
- Test behavior, not implementation details.
- Keep tests deterministic and fast; `parallelize(workers: :number_of_processors)`.
- Tests ship in the same commit as the feature. Security fixes always include a regression test.
- Never add production complexity for testability.

## Coverage Budget

- **Heavy:** model tests (domain invariants) and request tests (full request cycle, status, JSON body).
- **Light:** a request smoke test for the critical happy path of the slice.
- **None:** view tests, Vue unit tests from the Rails suite, exhaustive coverage of trivial delegation.
- Don't duplicate the same behavior assertion at multiple layers.

## Fixtures

- Express relationships by label, not ID; use ERB for relative timestamps (`created_at: <%= 1.hour.ago %>`) and shared computed values.
- Mirror the pack's model layout under its `test/` directory.
- UUID primary keys break fixture ordering: generate deterministic, label-derived UUIDv7s in fixtures so `.first` and `.last` are stable and runtime records are always newer.

## Good Practices

- Use request tests for HTTP workflows; model tests for domain invariants.
- `travel_to` for time-based logic.
- Mock or stub only at boundaries (external APIs, network, time, `SecureRandom`).
- Correlated count changes in one assertion: `assert_difference({ -> { Link.count } => +1 })`.
- Controllers that respond with JSON: assert status and body.
- Reset shared global state per test in parallel suites.

## Red Flags

- Adding production complexity only for testability.
- Over-mocking internal app code.
- Duplicate tests for the same behavior at multiple layers.
- Slow suites caused by unnecessary setup in each test.
- Time-dependent assertions without `travel_to`.
