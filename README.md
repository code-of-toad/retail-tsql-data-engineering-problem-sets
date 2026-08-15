# Retail T-SQL Data Engineering Problem Sets

Hands-on Microsoft T-SQL practice for mastering SQL in realistic retail data-engineering workflows: querying, data quality, ETL, incremental processing, dimensional modeling, reliability, and performance.

## Purpose

This repository is a deliberately engineered SQL practice environment for data engineering. It is designed so that coding problems can be written and executed against a reproducible SQL Server database rather than answered only on paper.

The practice data includes both:

- **clean operational tables** with production-like keys and constraints; and
- **raw/staging tables** containing deliberate defects such as duplicates, malformed values, orphan references, late-arriving records, corrections, deletions, and replayed source files.

## Dialect

**Microsoft T-SQL for SQL Server**

## Repository Structure

```text
retail-tsql-data-engineering-problem-sets/
├── docs/
│   ├── EDGE_CASE_COVERAGE.md
│   └── retail_tsql_data_engineering_problem_sets.md
├── sql/
│   ├── 00_setup/
│   │   ├── retail_tsql_practice_setup.sql
│   │   └── retail_tsql_seed_validation.sql
│   ├── 01_core_querying_and_joins/
│   │   ├── day01_problem_set_SOLUTIONS.sql
│   │   └── day01_problem_set_starter.sql
│   └── 02_critical_data_engineering_sql/
├── .gitignore
├── LICENSE
└── README.md
```

## Repository Organization

### `docs/`

Contains the master curriculum and documentation describing the deterministic edge cases built into the practice data.

- `retail_tsql_data_engineering_problem_sets.md` — the complete three-day SQL problem bank.
- `EDGE_CASE_COVERAGE.md` — documents the seeded cases used to support data-quality, deduplication, replay, late-arriving-data, and other engineering exercises.

### `sql/00_setup/`

Contains the scripts required to create and validate the practice environment.

- `retail_tsql_practice_setup.sql` — drops/recreates `RetailDEPractice`, creates the schemas and tables, and loads the clean and deliberately dirty seed data.
- `retail_tsql_seed_validation.sql` — verifies that the required deterministic edge cases are actually present.

### `sql/01_core_querying_and_joins/`

Contains the Day 1 executable practice material.

- `day01_problem_set_starter.sql` — starter file for writing and testing your own solutions.
- `day01_problem_set_SOLUTIONS.sql` — reference solutions for the exact same Day 1 problems.

### `sql/02_critical_data_engineering_sql/`

Reserved for the Day 2 executable problem set and solution files covering critical data-engineering SQL.

Additional numbered SQL directories can be added as later phases are converted into executable starter and solution files.

## Core Operational Model

```text
retail.customers
retail.stores
retail.products
retail.orders
retail.order_items
retail.inventory_snapshots
```

## Raw / Incoming Data

```text
staging.ingestion_batches
staging.customers_incoming
staging.products_incoming
staging.orders_incoming
staging.order_items_incoming
staging.inventory_incoming
```

Incoming tables are intentionally permissive and mostly text-typed so malformed source values can actually be stored and validated using T-SQL.

## Curriculum

### Day 1 — Core Querying + Joins

- `SELECT`, `WHERE`, `ORDER BY`
- `GROUP BY`, `HAVING`
- `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- `CASE`
- NULL handling
- `INNER JOIN`, `LEFT JOIN`
- Join cardinality and duplicate explosions
- `UNION ALL`
- Date functions
- String functions

### Day 2 — Critical Data-Engineering SQL

- CTEs
- Subqueries
- `EXISTS` / `NOT EXISTS`
- Window functions
- Deduplication
- Data-quality checks
- Grain
- Primary, foreign, and composite keys
- DDL
- Constraints
- DML
- `INSERT ... SELECT`
- Joined `UPDATE` / `DELETE`

### Day 3 — Data-Engineering Patterns

- Raw → staging → clean → curated → warehouse
- Full versus incremental loads
- Watermarks
- Upserts
- `MERGE` conceptually
- Idempotency
- Transactions and error handling
- Fact/dimension tables
- Star schemas
- Surrogate keys
- SCD Type 1 / Type 2
- Index basics
- SARGability
- Execution-plan basics
- Partitioning / clustering concepts
- ETL failure and recovery scenarios

## Getting Started

1. Connect to a Microsoft SQL Server instance.
2. Run:

   ```text
   sql/00_setup/retail_tsql_practice_setup.sql
   ```

3. Run:

   ```text
   sql/00_setup/retail_tsql_seed_validation.sql
   ```

4. Do not begin the exercises until the validation script prints:

   ```text
   ALL SEED VALIDATION CHECKS PASSED
   ```

5. Review the master curriculum:

   ```text
   docs/retail_tsql_data_engineering_problem_sets.md
   ```

6. Begin Day 1 in:

   ```text
   sql/01_core_querying_and_joins/day01_problem_set_starter.sql
   ```

7. Write and execute your own answers in the starter file. Use the companion solution file only after attempting a problem yourself:

   ```text
   sql/01_core_querying_and_joins/day01_problem_set_SOLUTIONS.sql
   ```

## Important Design Choice

The clean `retail.*` tables enforce legitimate constraints, so impossible production states are not injected into them merely to create exercises.

Instead, malformed records live in `staging.*_incoming`, exactly where a real data pipeline would encounter them before validation. This allows executable exercises involving:

- malformed numeric/date strings
- duplicate business keys
- duplicate file ingestion
- orphan foreign keys
- invalid domains
- negative quantities/prices
- excessive discounts
- late-arriving data
- corrections
- deletions/tombstones
- deterministic deduplication ties

## Practice Standard

A coding problem is not considered mastered until you can:

1. Write the T-SQL without copying a pattern.
2. State the output grain.
3. Explain how joins affect row counts.
4. Handle NULLs and malformed values correctly.
5. Explain important edge cases.
6. Defend the approach from a data-engineering perspective.

## Scope

This repository is intentionally SQL-centric. It develops the SQL reasoning expected of a data engineer, but does not replace study of orchestration, distributed processing, cloud platforms, Python, Spark, or broader system design.
