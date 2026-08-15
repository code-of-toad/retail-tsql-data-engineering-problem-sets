/*
===============================================================================
Retail SQL for Data Engineering
DAY 1 STARTER — Core Querying + Joins
Dialect: Microsoft T-SQL for SQL Server
Database: RetailDEPractice

PURPOSE
-------
Use this file to write and execute your own solutions for every Day 1 problem.

WORKING RULES
-------------
1. Write executable T-SQL.
2. State the output grain in a comment.
3. Do not use SELECT * unless specifically asked.
4. When a join could multiply rows, explain why your aggregation is safe.
5. Do not put solutions from external sources into this file before attempting
   the problem yourself.

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
GO separates problems into independent batches. This is useful for practice
because variables declared in one problem will not leak into another.
===============================================================================
*/

USE RetailDEPractice;
GO


-- ===============================================================================
-- A. SELECT / WHERE / ORDER BY
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 1
-------------------------------------------------------------------------------
-- Return active products with `product_id`, `sku`, `product_name`, `category`, and `list_price`.

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
-- PROBLEM 2
-------------------------------------------------------------------------------
-- Return products priced above $100.

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
-- PROBLEM 3
-------------------------------------------------------------------------------
-- Return the 10 most expensive products.

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
-- PROBLEM 4
-------------------------------------------------------------------------------
-- Return completed online orders.

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
-- PROBLEM 5
-------------------------------------------------------------------------------
-- Return completed orders on or after `2026-04-01`.

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
-- PROBLEM 6
-------------------------------------------------------------------------------
-- Return customers in Ontario or British Columbia.

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
-- PROBLEM 7
-------------------------------------------------------------------------------
-- Return products outside the `Electronics` category.

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
-- PROBLEM 8
-------------------------------------------------------------------------------
-- Return orders with status `Completed`, `Shipped`, or `Processing`.

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
-- PROBLEM 9
-------------------------------------------------------------------------------
-- Return products priced between $25 and $100 inclusive.

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
-- PROBLEM 10
-------------------------------------------------------------------------------
-- Return customers newest signup first, then alphabetically.

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
-- PROBLEM 11
-------------------------------------------------------------------------------
-- Return inactive products.

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
-- PROBLEM 12
-------------------------------------------------------------------------------
-- Return orders before noon.

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
-- PROBLEM 13
-------------------------------------------------------------------------------
-- Return the five earliest orders.

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
-- PROBLEM 14
-------------------------------------------------------------------------------
-- Return distinct customer provinces.

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
-- PROBLEM 15
-------------------------------------------------------------------------------
-- Return orders that are not completed.

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
-- B. Aggregates / GROUP BY / HAVING
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 16
-------------------------------------------------------------------------------
-- Count all orders.

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
-- PROBLEM 17
-------------------------------------------------------------------------------
-- Count orders with a non-NULL customer.

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
-- PROBLEM 18
-------------------------------------------------------------------------------
-- Count distinct customers who placed an order.

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
-- PROBLEM 19
-------------------------------------------------------------------------------
-- Sum quantity across all order-item rows.

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
-- PROBLEM 20
-------------------------------------------------------------------------------
-- Calculate gross line sales: `quantity * unit_price`.

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
-- PROBLEM 21
-------------------------------------------------------------------------------
-- Calculate total discounts.

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
-- PROBLEM 22
-------------------------------------------------------------------------------
-- Calculate total net line sales.

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
-- PROBLEM 23
-------------------------------------------------------------------------------
-- Find average list price.

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
-- PROBLEM 24
-------------------------------------------------------------------------------
-- Find minimum and maximum product costs.

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
-- PROBLEM 25
-------------------------------------------------------------------------------
-- Return product count by category.

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
-- PROBLEM 26
-------------------------------------------------------------------------------
-- Return order count by status.

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
-- PROBLEM 27
-------------------------------------------------------------------------------
-- Return order count by sales channel.

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
-- PROBLEM 28
-------------------------------------------------------------------------------
-- Return total units sold by product.

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
-- PROBLEM 29
-------------------------------------------------------------------------------
-- Return total net sales by order.

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
-- PROBLEM 30
-------------------------------------------------------------------------------
-- Return total net sales by product.

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
-- PROBLEM 31
-------------------------------------------------------------------------------
-- Return categories containing at least four products.

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
-- PROBLEM 32
-------------------------------------------------------------------------------
-- Return customers with at least two orders.

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
-- PROBLEM 33
-------------------------------------------------------------------------------
-- Return stores with at least four completed orders.

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
-- PROBLEM 34
-------------------------------------------------------------------------------
-- Return customers whose completed lifetime net sales exceed $300.

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
-- PROBLEM 35
-------------------------------------------------------------------------------
-- Calculate average completed order value using distinct orders.

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
-- C. CASE / NULL
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 36
-------------------------------------------------------------------------------
-- Classify products as `Budget`, `Midrange`, or `Premium`.

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
-- PROBLEM 37
-------------------------------------------------------------------------------
-- Classify inventory rows as `Out of Stock`, `Low Stock`, or `Healthy`.

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
-- PROBLEM 38
-------------------------------------------------------------------------------
-- Replace NULL email with `NO_EMAIL`.

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
-- PROBLEM 39
-------------------------------------------------------------------------------
-- Replace NULL loyalty tier with `Unassigned`.

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
-- PROBLEM 40
-------------------------------------------------------------------------------
-- Label guest versus known-customer orders.

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
-- PROBLEM 41
-------------------------------------------------------------------------------
-- Count guest and known-customer orders.

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
-- PROBLEM 42
-------------------------------------------------------------------------------
-- Return completed/cancelled/other order counts per store with conditional aggregation.

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
-- PROBLEM 43
-------------------------------------------------------------------------------
-- Calculate discounted-line revenue separately from non-discounted-line revenue.

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
-- PROBLEM 44
-------------------------------------------------------------------------------
-- Return percentage of clean order-item rows carrying a discount.

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
-- PROBLEM 45
-------------------------------------------------------------------------------
-- Calculate gross margin per clean order line as net sales minus product cost.

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
-- D. INNER JOIN / LEFT JOIN
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 46
-------------------------------------------------------------------------------
-- Return each order with its store name.

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
-- PROBLEM 47
-------------------------------------------------------------------------------
-- Return each known-customer order with customer name.

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
-- PROBLEM 48
-------------------------------------------------------------------------------
-- Return all orders, including guest orders, with customer name if present.

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
-- PROBLEM 49
-------------------------------------------------------------------------------
-- Return full order-line detail with product name and net line revenue.

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
-- PROBLEM 50
-------------------------------------------------------------------------------
-- Return completed net sales by store.

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
-- PROBLEM 51
-------------------------------------------------------------------------------
-- Return completed net sales by store province.

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
-- PROBLEM 52
-------------------------------------------------------------------------------
-- Return completed net sales by product category.

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
-- PROBLEM 53
-------------------------------------------------------------------------------
-- Return completed net sales by customer.

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
-- PROBLEM 54
-------------------------------------------------------------------------------
-- Return every customer and completed lifetime sales, including zero-sales customers.

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
-- PROBLEM 55
-------------------------------------------------------------------------------
-- Return every product and total units sold, including never-sold products.

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
-- PROBLEM 56
-------------------------------------------------------------------------------
-- Find products never sold.

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
-- PROBLEM 57
-------------------------------------------------------------------------------
-- Find customers who never placed an order.

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
-- PROBLEM 58
-------------------------------------------------------------------------------
-- Return each store's latest inventory snapshot date.

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
-- PROBLEM 59
-------------------------------------------------------------------------------
-- Return low-stock SKUs on the latest available snapshot **for each store**.

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
-- PROBLEM 60
-------------------------------------------------------------------------------
-- Return products bought by each customer.

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
-- PROBLEM 61
-------------------------------------------------------------------------------
-- Return completed sales by customer province.

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
-- PROBLEM 62
-------------------------------------------------------------------------------
-- Return gross margin by product category.

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
-- E. Join Cardinality / Duplicate Explosions
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 63
-------------------------------------------------------------------------------
-- Predict and then verify the grain after joining `orders` to `order_items`.

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
-- PROBLEM 64
-------------------------------------------------------------------------------
-- Predict and verify the grain after joining `orders → order_items → products`.

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
-- PROBLEM 65
-------------------------------------------------------------------------------
-- Explain why `COUNT(*)` after joining orders to items is not an order count.

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
-- PROBLEM 66
-------------------------------------------------------------------------------
-- Correctly count distinct completed orders by store after joining to items.

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
-- PROBLEM 67
-------------------------------------------------------------------------------
-- Compute completed store revenue without double-counting.

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
-- PROBLEM 68
-------------------------------------------------------------------------------
-- Write an intentionally wrong query that overcounts orders due to the order-item join; then fix it.

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
-- PROBLEM 69
-------------------------------------------------------------------------------
-- Show the number of line rows produced per order after joining.

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
-- PROBLEM 70
-------------------------------------------------------------------------------
-- Identify the order(s) with the largest number of lines.

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
-- PROBLEM 71
-------------------------------------------------------------------------------
-- Pre-aggregate order-item revenue to one row per order, then join to `orders`.

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
-- PROBLEM 72
-------------------------------------------------------------------------------
-- Pre-aggregate inventory to one row per store and join it to a store-level sales aggregation without causing multiplication.

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
-- PROBLEM 73
-------------------------------------------------------------------------------
-- Explain why joining two one-to-many child tables directly through a common parent can create a multiplicative explosion.

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
-- F. UNION ALL
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 74
-------------------------------------------------------------------------------
-- Combine customer provinces and store provinces with `UNION ALL`.

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
-- PROBLEM 75
-------------------------------------------------------------------------------
-- Produce `(entity_type, entity_id, province)` for both customers and stores.

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
-- PROBLEM 76
-------------------------------------------------------------------------------
-- Compare `UNION` and `UNION ALL` by executing both against province lists.

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
-- PROBLEM 77
-------------------------------------------------------------------------------
-- Combine completed and cancelled orders into one labeled result.

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
-- PROBLEM 78
-------------------------------------------------------------------------------
-- Build a data-quality summary containing multiple check names and counts using `UNION ALL`.

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
-- G. Date Functions
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 79
-------------------------------------------------------------------------------
-- Extract year, month, and day from order dates.

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
-- PROBLEM 80
-------------------------------------------------------------------------------
-- Return order count by calendar year/month.

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
-- PROBLEM 81
-------------------------------------------------------------------------------
-- Using `@as_of_date = '2026-08-15'`, return orders from the preceding 30 days.

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
-- PROBLEM 82
-------------------------------------------------------------------------------
-- Return days between signup and first order for every customer who ordered.

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
-- PROBLEM 83
-------------------------------------------------------------------------------
-- Return month-end for each order using `EOMONTH`.

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
-- PROBLEM 84
-------------------------------------------------------------------------------
-- Return inventory snapshots in June 2026.

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
-- PROBLEM 85
-------------------------------------------------------------------------------
-- Return completed sales by quarter.

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
-- PROBLEM 86
-------------------------------------------------------------------------------
-- Return completed sales by month.

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
-- PROBLEM 87
-------------------------------------------------------------------------------
-- Return the first and last order date for each customer.

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
-- PROBLEM 88
-------------------------------------------------------------------------------
-- Return customers whose second order occurred within 30 days of their first.

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
-- H. String Functions
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 89
-------------------------------------------------------------------------------
-- Uppercase customer names.

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
-- PROBLEM 90
-------------------------------------------------------------------------------
-- Trim incoming customer emails.

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
-- PROBLEM 91
-------------------------------------------------------------------------------
-- Return first three characters of every SKU.

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
-- PROBLEM 92
-------------------------------------------------------------------------------
-- Build `SKU - Product Name`.

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
-- PROBLEM 93
-------------------------------------------------------------------------------
-- Return product-name lengths.

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
-- PROBLEM 94
-------------------------------------------------------------------------------
-- Replace spaces in product names with hyphens.

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
-- PROBLEM 95
-------------------------------------------------------------------------------
-- Find products whose names contain `Wireless`.

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
-- PROBLEM 96
-------------------------------------------------------------------------------
-- Create one comma-separated product list per category using `STRING_AGG`.

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
-- Day 1 Capstone
-- ===============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 97
-------------------------------------------------------------------------------
-- Produce **one row per store** containing:
-- - store ID/name/province
-- - distinct completed order count
-- - distinct completed customer count
-- - units sold
-- - gross sales
-- - discount amount
-- - net sales
-- - gross margin
-- - average order value
-- - latest inventory snapshot date
-- - count of low-stock SKUs on that store's latest snapshot
-- 
-- You must prevent sales/inventory join multiplication.

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

