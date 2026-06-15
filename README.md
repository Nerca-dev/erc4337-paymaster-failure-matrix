# ERC-4337 paymaster failure matrix

This repo backs my Dune dashboard on ERC-4337 paymaster failures.

The dashboard looks at failed UserOperations, failed fee spend, sender concentration, bundler concentration, and paymasters with unusual failure patterns.

## Dashboard

TODO: paste Dune dashboard link here

## Query

Dune query ID: `7726940`

TODO: paste the final SQL into:

`queries/7726940_paymaster_failure_matrix.sql`

## Why I made this

Most Account Abstraction dashboards focus on volume. I wanted the failure side.

Paymasters sponsor gas for UserOperations. Repeated failures can point to bad integration, weak paymaster policy, griefing risk, or wasted infrastructure spend.

This dashboard is meant to make those patterns easier to inspect.

## What it tracks

- Total UserOperations per paymaster
- Successful and failed operations
- Failure rate
- Total fee spend
- Failed fee spend
- Unique sender count
- Top failed sender
- Top bundler
- Bundler concentration

## Files

- `queries.yml` maps the Dune query ID to the local SQL file.
- `queries/7726940_paymaster_failure_matrix.sql` is where the final Dune SQL goes.
- `assets/` is for screenshots or exports from the dashboard.

## TODO

- Paste the Dune dashboard link.
- Paste the final SQL query.
- Add a dashboard screenshot if needed.
