/*
===============================================================================
Retail SQL for Data Engineering
DAY 2 STARTER — Critical Data-Engineering SQL
Dialect: Microsoft T-SQL for SQL Server
Database: RetailDEPractice

PURPOSE
-------
Use this file to write and execute your own solutions for every Day 2 problem.

WORKING RULES
-------------
1. Write executable T-SQL.
2. State the output grain in a comment.
3. Do not use SELECT * unless specifically asked.
4. Where raw source values are involved, use safe conversion patterns such as
   TRY_CONVERT.
5. Do not disable clean-table constraints to manufacture errors.
6. When a join could multiply rows, explain why your aggregation is safe.
7. Do not put reference solutions into this file before attempting the problem
   yourself.

HOW TO USE EACH PROBLEM BLOCK
-----------------------------
- Fill in OUTPUT GRAIN before or immediately after solving.
- Write your T-SQL beneath ANSWER.
- Execute only the problem you are working on.
- Record the execution/test outcome beneath TEST RESULT.
- Keep failed attempts if they teach you something; comment them out rather
  than deleting them if you want a record of your reasoning.

NOTE
----
GO separates problems into independent T-SQL batches, so variables declared in
one problem will not leak into another. Some later DDL/DML exercises intentionally
build on practice_dw objects created by earlier Day 2 problems.
===============================================================================
*/

USE RetailDEPractice;
GO


-- ===============================================================================
-- I. CTEs
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 98
-------------------------------------------------------------------------------
-- Rewrite the Day 1 capstone with separate sales and inventory CTEs.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 99
-------------------------------------------------------------------------------
-- Build a `completed_sales` CTE and aggregate it by province.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 100
-------------------------------------------------------------------------------
-- Build chained CTEs named `raw_lines`, `clean_lines`, `enriched_lines`, and `aggregated_sales`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 101
-------------------------------------------------------------------------------
-- Use a CTE to find never-sold products.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 102
-------------------------------------------------------------------------------
-- Use two CTEs to calculate store monthly sales and company monthly sales, then contribution percentage.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 103
-------------------------------------------------------------------------------
-- Use a CTE to calculate customer lifetime sales and rank customers.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 104
-------------------------------------------------------------------------------
-- Refactor one nested subquery into multiple CTEs.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- J. Subqueries
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 105
-------------------------------------------------------------------------------
-- Products priced above average list price.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 106
-------------------------------------------------------------------------------
-- Orders whose net value exceeds average completed order value.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 107
-------------------------------------------------------------------------------
-- Customers whose lifetime sales exceed average customer lifetime sales.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 108
-------------------------------------------------------------------------------
-- Stores whose sales exceed average store sales.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 109
-------------------------------------------------------------------------------
-- Return each customer's first order using a subquery.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 110
-------------------------------------------------------------------------------
-- Return each product with total quantity sold using a correlated subquery.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 111
-------------------------------------------------------------------------------
-- Rewrite Question 110 with a join/CTE and compare.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 112
-------------------------------------------------------------------------------
-- Return products with completed revenue above their category average.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- K. EXISTS / NOT EXISTS
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 113
-------------------------------------------------------------------------------
-- Customers with at least one order.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 114
-------------------------------------------------------------------------------
-- Customers with no orders.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 115
-------------------------------------------------------------------------------
-- Products sold at least once.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 116
-------------------------------------------------------------------------------
-- Products never sold.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 117
-------------------------------------------------------------------------------
-- Stores whose latest snapshot has at least one low-stock product.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 118
-------------------------------------------------------------------------------
-- Orders with at least one discounted line.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 119
-------------------------------------------------------------------------------
-- Customers who bought Electronics.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 120
-------------------------------------------------------------------------------
-- Customers who never bought Electronics.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 121
-------------------------------------------------------------------------------
-- Incoming orders with valid numeric customer IDs that do not exist in `retail.customers`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 122
-------------------------------------------------------------------------------
-- Incoming order items with valid numeric product IDs that do not exist in `retail.products`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- L. Window Functions — ROW_NUMBER / RANK / DENSE_RANK
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 123
-------------------------------------------------------------------------------
-- Number each customer's orders chronologically.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 124
-------------------------------------------------------------------------------
-- Return each customer's most recent order.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 125
-------------------------------------------------------------------------------
-- Return each customer's first order.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 126
-------------------------------------------------------------------------------
-- Rank products by completed net sales.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 127
-------------------------------------------------------------------------------
-- Rank products by completed net sales within category.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 128
-------------------------------------------------------------------------------
-- Return top 3 products by revenue within each category.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 129
-------------------------------------------------------------------------------
-- Demonstrate `ROW_NUMBER`, `RANK`, and `DENSE_RANK` on the Accessories category. Your output must expose the seeded tie.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 130
-------------------------------------------------------------------------------
-- Rank stores by revenue within province.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 131
-------------------------------------------------------------------------------
-- Return the second-highest revenue product per category.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 132
-------------------------------------------------------------------------------
-- Return latest inventory snapshot per store/product.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 133
-------------------------------------------------------------------------------
-- Return the top-selling order line within each completed order.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- M. LAG / LEAD
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 134
-------------------------------------------------------------------------------
-- Previous order date per customer.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 135
-------------------------------------------------------------------------------
-- Days since previous order.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 136
-------------------------------------------------------------------------------
-- Previous on-hand quantity per store/product.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 137
-------------------------------------------------------------------------------
-- Inventory change since previous snapshot.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 138
-------------------------------------------------------------------------------
-- Flag inventory decreases.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 139
-------------------------------------------------------------------------------
-- Next order date per customer.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 140
-------------------------------------------------------------------------------
-- Flag whether a customer returned within 30 days.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 141
-------------------------------------------------------------------------------
-- Compare each month's completed sales with the prior month.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- N. Windowed Aggregates
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 142
-------------------------------------------------------------------------------
-- Running completed net sales by date.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 143
-------------------------------------------------------------------------------
-- Running completed net sales by store.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 144
-------------------------------------------------------------------------------
-- Product percentage of category revenue.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 145
-------------------------------------------------------------------------------
-- Store percentage of company revenue.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 146
-------------------------------------------------------------------------------
-- Cumulative units sold per product over time.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 147
-------------------------------------------------------------------------------
-- Three-row moving average of daily completed sales.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 148
-------------------------------------------------------------------------------
-- Running order count by customer.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- O. Safe Type Conversion / Raw Source Inspection
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 149
-------------------------------------------------------------------------------
-- Return incoming orders with safely converted integer order/customer/store IDs.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 150
-------------------------------------------------------------------------------
-- Return incoming orders where order ID cannot be converted to `INT`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 151
-------------------------------------------------------------------------------
-- Return incoming order dates that cannot be converted to `DATETIME2`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 152
-------------------------------------------------------------------------------
-- Return malformed incoming item quantities.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 153
-------------------------------------------------------------------------------
-- Return malformed incoming item unit prices.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 154
-------------------------------------------------------------------------------
-- Convert valid incoming product cost/price strings to decimals.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 155
-------------------------------------------------------------------------------
-- Explain why `CAST` is dangerous for a mixed-validity raw batch and demonstrate the safer alternative.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- P. Deduplication
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 156
-------------------------------------------------------------------------------
-- Show duplicate incoming `source_order_id_raw` values.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 157
-------------------------------------------------------------------------------
-- Count versions per source order.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 158
-------------------------------------------------------------------------------
-- Deduplicate orders by:
-- 1. valid business key,
-- 2. newest converted `modified_at`,
-- 3. newest `ingested_at`,
-- 4. highest `ingestion_id`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 159
-------------------------------------------------------------------------------
-- Return only winning records.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 160
-------------------------------------------------------------------------------
-- Return only superseded records.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 161
-------------------------------------------------------------------------------
-- Label each row as `UNIQUE`, `WINNER`, or `SUPERSEDED`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 162
-------------------------------------------------------------------------------
-- Show the seeded `modified_at` tie and prove your tie-break is deterministic.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 163
-------------------------------------------------------------------------------
-- Deduplicate incoming order items by `(source_order_id, line_number)`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 164
-------------------------------------------------------------------------------
-- Deduplicate incoming inventory by `(store_id, product_id, snapshot_date)`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 165
-------------------------------------------------------------------------------
-- Explain why `DISTINCT` is insufficient for versioned-source deduplication.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- Q. Duplicate File / Replay Detection
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 166
-------------------------------------------------------------------------------
-- Find duplicate source files by `(source_entity, file_checksum)`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 167
-------------------------------------------------------------------------------
-- Identify replayed order batches.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 168
-------------------------------------------------------------------------------
-- Return all order rows belonging to a replayed checksum.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 169
-------------------------------------------------------------------------------
-- Design a query that chooses only the earliest accepted batch for a checksum.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 170
-------------------------------------------------------------------------------
-- Explain how checksum-level idempotency differs from business-key deduplication.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- R. Data Quality — Orders
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 171
-------------------------------------------------------------------------------
-- Missing/blank source order keys.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 172
-------------------------------------------------------------------------------
-- Malformed order IDs.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 173
-------------------------------------------------------------------------------
-- Malformed customer IDs, excluding NULL guest customers.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 174
-------------------------------------------------------------------------------
-- Malformed store IDs.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 175
-------------------------------------------------------------------------------
-- Malformed order dates.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 176
-------------------------------------------------------------------------------
-- Future-dated orders using `@as_of_date = '2026-08-15'`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 177
-------------------------------------------------------------------------------
-- Invalid status values.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 178
-------------------------------------------------------------------------------
-- Invalid sales channels.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 179
-------------------------------------------------------------------------------
-- Orphan customers.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 180
-------------------------------------------------------------------------------
-- Orphan stores.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 181
-------------------------------------------------------------------------------
-- Unsupported `change_type_raw`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 182
-------------------------------------------------------------------------------
-- Produce a single order-quality summary using `UNION ALL`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- S. Data Quality — Order Items
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 183
-------------------------------------------------------------------------------
-- Missing line number.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 184
-------------------------------------------------------------------------------
-- Malformed line number.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 185
-------------------------------------------------------------------------------
-- Zero quantity.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 186
-------------------------------------------------------------------------------
-- Negative quantity.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 187
-------------------------------------------------------------------------------
-- Malformed quantity.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 188
-------------------------------------------------------------------------------
-- Negative unit price.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 189
-------------------------------------------------------------------------------
-- Malformed unit price.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 190
-------------------------------------------------------------------------------
-- Negative discount.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 191
-------------------------------------------------------------------------------
-- Discount greater than gross line value.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 192
-------------------------------------------------------------------------------
-- Orphan products.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 193
-------------------------------------------------------------------------------
-- Orphan source orders.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 194
-------------------------------------------------------------------------------
-- Duplicate composite `(order,line)` keys.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 195
-------------------------------------------------------------------------------
-- Produce an item-quality summary.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- T. Data Quality — Products / Customers / Inventory
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 196
-------------------------------------------------------------------------------
-- Duplicate incoming SKUs.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 197
-------------------------------------------------------------------------------
-- Negative product cost.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 198
-------------------------------------------------------------------------------
-- Negative product price.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 199
-------------------------------------------------------------------------------
-- Product cost greater than list price.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 200
-------------------------------------------------------------------------------
-- Malformed product cost.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 201
-------------------------------------------------------------------------------
-- Missing product business key.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 202
-------------------------------------------------------------------------------
-- Duplicate incoming customer emails ignoring NULL/blank.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 203
-------------------------------------------------------------------------------
-- Invalid customer provinces.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 204
-------------------------------------------------------------------------------
-- Invalid loyalty tiers.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 205
-------------------------------------------------------------------------------
-- Malformed customer signup dates.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 206
-------------------------------------------------------------------------------
-- Negative incoming inventory quantity.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 207
-------------------------------------------------------------------------------
-- Malformed incoming inventory quantity.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 208
-------------------------------------------------------------------------------
-- Negative reorder point.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 209
-------------------------------------------------------------------------------
-- Orphan inventory store/product references.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 210
-------------------------------------------------------------------------------
-- Duplicate inventory snapshots.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 211
-------------------------------------------------------------------------------
-- Build a cross-entity quality-check summary with at least 15 checks.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- U. Grain / Keys / Relational Design
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 212
-------------------------------------------------------------------------------
-- State the grain of every `retail.*` table.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 213
-------------------------------------------------------------------------------
-- State the grain of every `staging.*_incoming` table.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 214
-------------------------------------------------------------------------------
-- Identify all primary keys.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 215
-------------------------------------------------------------------------------
-- Explain why `retail.order_items` has a composite key.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 216
-------------------------------------------------------------------------------
-- Explain why inventory uses `(store_id, product_id, snapshot_date)`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 217
-------------------------------------------------------------------------------
-- Identify foreign-key relationships in the clean model.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 218
-------------------------------------------------------------------------------
-- Explain why raw incoming tables intentionally do not enforce those foreign keys.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 219
-------------------------------------------------------------------------------
-- Explain natural versus surrogate keys using `sku` and a future `product_key`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 220
-------------------------------------------------------------------------------
-- Explain why fact-table grain must be defined before choosing measures.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- V. DDL — Executable
-- ===============================================================================

-- Perform these in a new schema called `practice_dw`.

-------------------------------------------------------------------------------
-- PROBLEM 221
-------------------------------------------------------------------------------
-- `CREATE SCHEMA practice_dw`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 222
-------------------------------------------------------------------------------
-- Create `practice_dw.dim_store` with an `IDENTITY` surrogate key.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 223
-------------------------------------------------------------------------------
-- Create `practice_dw.dim_product`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 224
-------------------------------------------------------------------------------
-- Create `practice_dw.dim_customer`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 225
-------------------------------------------------------------------------------
-- Create `practice_dw.dim_date`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 226
-------------------------------------------------------------------------------
-- Create `practice_dw.fact_sales` at one row per order line.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 227
-------------------------------------------------------------------------------
-- Add appropriate primary keys.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 228
-------------------------------------------------------------------------------
-- Add foreign keys from fact to dimensions.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 229
-------------------------------------------------------------------------------
-- Add `NOT NULL` constraints where appropriate.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 230
-------------------------------------------------------------------------------
-- Add `CHECK (quantity > 0)`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 231
-------------------------------------------------------------------------------
-- Add `CHECK (unit_price >= 0)`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 232
-------------------------------------------------------------------------------
-- Add a default load timestamp.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 233
-------------------------------------------------------------------------------
-- Add a unique constraint on a natural/business key where appropriate.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 234
-------------------------------------------------------------------------------
-- `ALTER TABLE` to add `load_batch_id BIGINT`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 235
-------------------------------------------------------------------------------
-- Create a nonclustered index supporting store/date fact lookups.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 236
-------------------------------------------------------------------------------
-- Create a view exposing a simple sales mart.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 237
-------------------------------------------------------------------------------
-- Create and then drop a disposable practice table.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 238
-------------------------------------------------------------------------------
-- Demonstrate `TRUNCATE TABLE` safely on a disposable table and explain `DELETE` vs `TRUNCATE` vs `DROP`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- W. DML — Executable
-- ===============================================================================

-- Use only disposable/practice tables where destructive changes would affect seeded data.

-------------------------------------------------------------------------------
-- PROBLEM 239
-------------------------------------------------------------------------------
-- Insert one dimension row.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 240
-------------------------------------------------------------------------------
-- Insert multiple dimension rows.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 241
-------------------------------------------------------------------------------
-- Populate a dimension with `INSERT ... SELECT`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 242
-------------------------------------------------------------------------------
-- Update dimension attributes from a staging-derived dataset.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 243
-------------------------------------------------------------------------------
-- Delete a deliberately inserted test row.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 244
-------------------------------------------------------------------------------
-- Perform an `UPDATE` using a join.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 245
-------------------------------------------------------------------------------
-- Perform a `DELETE` using `EXISTS`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 246
-------------------------------------------------------------------------------
-- Wrap an update in a transaction, inspect the result, then roll back.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 247
-------------------------------------------------------------------------------
-- Insert only valid, deduplicated incoming orders into a clean practice table.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 248
-------------------------------------------------------------------------------
-- Insert rejected rows into a reject table with `rejection_reason`.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 249
-------------------------------------------------------------------------------
-- Update a clean practice target when a newer source version exists.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO

-------------------------------------------------------------------------------
-- PROBLEM 250
-------------------------------------------------------------------------------
-- Insert source business keys not already in the target.

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO


-- ===============================================================================
-- Day 2 Capstone
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 251
-------------------------------------------------------------------------------
-- Build an executable pipeline from `staging.orders_incoming` and `staging.order_items_incoming` into practice clean tables:
--
-- - exclude replayed files
-- - safely type-convert raw fields
-- - validate business rules
-- - quarantine invalid rows
-- - deduplicate valid source versions deterministically
-- - resolve customer/store/product references
-- - preserve guest orders
-- - load clean winners
-- - calculate read/rejected/superseded/accepted counts
-- - reconcile accepted order lines to accepted orders

-- OUTPUT GRAIN:
-- One row per ...

-- ANSWER:


-- TEST RESULT:
-- [ ] Executed successfully
-- Rows returned:
-- Result/behaviour observed:
-- Edge case(s) checked:
-- Notes:

GO
