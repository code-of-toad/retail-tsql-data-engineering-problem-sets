# Retail SQL for Data Engineering

A hands-on Microsoft T-SQL practice repository for mastering SQL in a retail data-engineering context. The project focuses on querying, data quality, ETL patterns, dimensional modeling, incremental processing, performance, and production-oriented SQL Server workflows.

## Goals

This repository is designed to build practical SQL skills for data engineering, including the ability to:

- Query and transform relational data confidently
- Work with joins, aggregation, CTEs, subqueries, and window functions
- Design and modify database objects with DDL
- Insert, update, and delete data safely with DML
- Detect duplicates, invalid records, and referential-integrity problems
- Build staging, cleansing, and curated-data workflows
- Implement incremental loads, watermarks, and upserts
- Design fact and dimension tables
- Implement Slowly Changing Dimensions
- Write idempotent and transaction-safe ETL logic
- Understand indexing, SARGability, and execution-plan fundamentals
- Reason through common production ETL failure scenarios

## SQL Dialect

All exercises use **Microsoft T-SQL for SQL Server**.

## Retail Data Model

The practice environment includes:

```text
retail.customers
retail.stores
retail.products
retail.orders
retail.order_items
retail.inventory_snapshots

staging.orders_incoming
```

The model supports realistic retail scenarios involving customers, products, stores, orders, sales, inventory, data quality, and incoming source-system data.

## Repository Contents

```text
.
├── README.md
├── retail_tsql_practice_setup.sql
└── retail_tsql_data_engineering_problem_sets.md
```

### `retail_tsql_practice_setup.sql`

Creates the SQL Server practice database, schemas, tables, constraints, sample retail data, inventory snapshots, and deliberately dirty incoming records for data-engineering exercises.

### `retail_tsql_data_engineering_problem_sets.md`

Contains a comprehensive problem bank covering SQL from core querying through production-oriented data-engineering patterns.

## Curriculum

### Day 1 — Core Querying and Joins

- `SELECT`, `WHERE`, `ORDER BY`
- `GROUP BY`, `HAVING`
- Aggregate functions
- `CASE`
- NULL handling
- `INNER JOIN`, `LEFT JOIN`
- Join cardinality and duplicate multiplication
- `UNION ALL`
- Date functions
- String functions

### Day 2 — Critical Data Engineering SQL

- Common Table Expressions
- Subqueries
- `EXISTS` / `NOT EXISTS`
- Window functions
- Deduplication
- Data-quality checks
- Grain and keys
- DDL
- Constraints
- DML
- `INSERT ... SELECT`
- Joined `UPDATE` and `DELETE`

### Day 3 — Data Engineering Patterns

- Raw, staging, clean, curated, and warehouse layers
- Full versus incremental loads
- Watermarks
- Upserts
- `MERGE` concepts
- Idempotency
- Transactions
- Fact and dimension tables
- Star schemas
- Surrogate keys
- SCD Type 1 and Type 2
- Indexing
- SARGability
- Execution-plan fundamentals
- Partitioning concepts
- ETL failure and recovery scenarios

## Capstone Exercises

The repository includes progressively larger exercises such as:

1. Building a store-level retail performance query without double-counting measures
2. Validating and deduplicating incoming source records
3. Loading clean data into trusted staging tables
4. Designing an incremental retail ETL process
5. Implementing transaction-safe upserts
6. Building dimensional warehouse structures
7. Handling late-arriving, duplicated, malformed, and corrected source data

## Getting Started

1. Install or connect to Microsoft SQL Server.
2. Open `retail_tsql_practice_setup.sql`.
3. Execute the script to create the `RetailDEPractice` database.
4. Open `retail_tsql_data_engineering_problem_sets.md`.
5. Work through the exercises in order.
6. Write and execute each solution directly against the practice database.

## Practice Standard

For each coding exercise, aim to be able to:

1. Write the query without looking up the pattern.
2. State the output grain.
3. Explain how joins affect row counts.
4. Handle NULLs and edge cases correctly.
5. Explain why the approach is appropriate.
6. Recognize major performance or reliability concerns.

## Scope

This repository focuses specifically on **SQL mastery for data engineering**. It is not intended to teach every SQL Server administrative feature or replace broader study of orchestration tools, distributed processing systems, cloud platforms, or programming languages used in modern data engineering.

## Status

Active learning project focused on building interview-ready and production-oriented T-SQL data-engineering skills.
