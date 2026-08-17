/*
===============================================================================
Retail SQL for Data Engineering
DAY 2 REFERENCE SOLUTIONS — Critical Data-Engineering SQL
Dialect: Microsoft T-SQL for SQL Server
Database: RetailDEPractice

This file is the companion answer key for day02_problem_set_starter.sql.
It contains the exact same Day 2 problem prompts in the exact same order.

IMPORTANT
---------
Use this only after attempting each problem yourself.

The queries below are reference solutions. Some SQL problems admit multiple
correct formulations. Where a business term is ambiguous, an explicit assumption
is documented rather than silently changing the problem statement.

Problems 221–251 create or modify objects only in practice_dw. They are designed
to be executed sequentially after a fresh setup/seed validation. The capstone
recreates its own practice tables and is safe to rerun.

No execution results are fabricated in this file. Run each batch against your
validated RetailDEPractice database to verify it locally.
===============================================================================
*/

USE RetailDEPractice;
GO


-- ==============================================================================
-- I. CTEs
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 98
-------------------------------------------------------------------------------
-- Rewrite the Day 1 capstone with separate sales and inventory CTEs.

-- OUTPUT GRAIN:
-- one row per store

-- REFERENCE SOLUTION:
-- Sales and inventory are each reduced to one row per store before the final
-- join, preventing the inventory snapshots from multiplying sales rows.
WITH sales AS
(
    SELECT
        o.store_id,
        COUNT(DISTINCT o.order_id) AS completed_order_count,
        COUNT(DISTINCT o.customer_id) AS completed_customer_count,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS gross_sales,
        SUM(oi.discount_amount) AS discount_amount,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS net_sales,
        SUM(
            ((oi.quantity * oi.unit_price) - oi.discount_amount)
            - (oi.quantity * p.unit_cost)
        ) AS gross_margin
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN retail.products AS p
        ON p.product_id = oi.product_id
    WHERE o.status = N'Completed'
    GROUP BY o.store_id
),
latest_inventory AS
(
    SELECT
        store_id,
        MAX(snapshot_date) AS latest_snapshot_date
    FROM retail.inventory_snapshots
    GROUP BY store_id
),
inventory AS
(
    SELECT
        li.store_id,
        li.latest_snapshot_date,
        SUM(CASE WHEN i.on_hand_qty <= i.reorder_point THEN 1 ELSE 0 END)
            AS low_stock_sku_count
    FROM latest_inventory AS li
    INNER JOIN retail.inventory_snapshots AS i
        ON i.store_id = li.store_id
       AND i.snapshot_date = li.latest_snapshot_date
    GROUP BY li.store_id, li.latest_snapshot_date
)
SELECT
    s.store_id,
    s.store_name,
    s.province,
    COALESCE(sa.completed_order_count, 0) AS completed_order_count,
    COALESCE(sa.completed_customer_count, 0) AS completed_customer_count,
    COALESCE(sa.units_sold, 0) AS units_sold,
    COALESCE(sa.gross_sales, 0.00) AS gross_sales,
    COALESCE(sa.discount_amount, 0.00) AS discount_amount,
    COALESCE(sa.net_sales, 0.00) AS net_sales,
    COALESCE(sa.gross_margin, 0.00) AS gross_margin,
    CAST(
        sa.net_sales / NULLIF(sa.completed_order_count, 0)
        AS DECIMAL(18,2)
    ) AS average_order_value,
    inv.latest_snapshot_date,
    COALESCE(inv.low_stock_sku_count, 0) AS low_stock_sku_count
FROM retail.stores AS s
LEFT JOIN sales AS sa
    ON sa.store_id = s.store_id
LEFT JOIN inventory AS inv
    ON inv.store_id = s.store_id
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 99
-------------------------------------------------------------------------------
-- Build a `completed_sales` CTE and aggregate it by province.

-- OUTPUT GRAIN:
-- one row per customer province with completed sales

-- REFERENCE SOLUTION:
-- Assumption: "province" means the customer's province; guest orders have no
-- customer province and are therefore excluded.
WITH completed_sales AS
(
    SELECT
        c.province,
        (oi.quantity * oi.unit_price) - oi.discount_amount AS net_sales
    FROM retail.orders AS o
    INNER JOIN retail.customers AS c
        ON c.customer_id = o.customer_id
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
)
SELECT
    province,
    SUM(net_sales) AS completed_net_sales
FROM completed_sales
GROUP BY province
ORDER BY province;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 100
-------------------------------------------------------------------------------
-- Build chained CTEs named `raw_lines`, `clean_lines`, `enriched_lines`, and `aggregated_sales`.

-- OUTPUT GRAIN:
-- one row per product category represented by valid incoming item rows

-- REFERENCE SOLUTION:
WITH raw_lines AS
(
    SELECT
        ingestion_id,
        source_order_id_raw,
        line_number_raw,
        product_id_raw,
        quantity_raw,
        unit_price_raw,
        discount_amount_raw
    FROM staging.order_items_incoming
),
clean_lines AS
(
    SELECT
        ingestion_id,
        TRY_CONVERT(INT, source_order_id_raw) AS source_order_id,
        TRY_CONVERT(INT, line_number_raw) AS line_number,
        TRY_CONVERT(INT, product_id_raw) AS product_id,
        TRY_CONVERT(INT, quantity_raw) AS quantity,
        TRY_CONVERT(DECIMAL(10,2), unit_price_raw) AS unit_price,
        TRY_CONVERT(DECIMAL(10,2), discount_amount_raw) AS discount_amount
    FROM raw_lines
    WHERE TRY_CONVERT(INT, source_order_id_raw) IS NOT NULL
      AND TRY_CONVERT(INT, line_number_raw) IS NOT NULL
      AND TRY_CONVERT(INT, product_id_raw) IS NOT NULL
      AND TRY_CONVERT(INT, quantity_raw) > 0
      AND TRY_CONVERT(DECIMAL(10,2), unit_price_raw) >= 0
      AND TRY_CONVERT(DECIMAL(10,2), discount_amount_raw) >= 0
      AND TRY_CONVERT(DECIMAL(10,2), discount_amount_raw)
            <= TRY_CONVERT(INT, quantity_raw)
             * TRY_CONVERT(DECIMAL(10,2), unit_price_raw)
),
enriched_lines AS
(
    SELECT
        cl.*,
        p.category,
        (cl.quantity * cl.unit_price) - cl.discount_amount AS net_sales
    FROM clean_lines AS cl
    INNER JOIN retail.products AS p
        ON p.product_id = cl.product_id
),
aggregated_sales AS
(
    SELECT
        category,
        SUM(quantity) AS units,
        SUM(net_sales) AS net_sales
    FROM enriched_lines
    GROUP BY category
)
SELECT
    category,
    units,
    net_sales
FROM aggregated_sales
ORDER BY category;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 101
-------------------------------------------------------------------------------
-- Use a CTE to find never-sold products.

-- OUTPUT GRAIN:
-- one row per never-sold product

-- REFERENCE SOLUTION:
WITH sold_products AS
(
    SELECT DISTINCT product_id
    FROM retail.order_items
)
SELECT
    p.product_id,
    p.sku,
    p.product_name
FROM retail.products AS p
LEFT JOIN sold_products AS sp
    ON sp.product_id = p.product_id
WHERE sp.product_id IS NULL
ORDER BY p.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 102
-------------------------------------------------------------------------------
-- Use two CTEs to calculate store monthly sales and company monthly sales, then contribution percentage.

-- OUTPUT GRAIN:
-- one row per store per sales month

-- REFERENCE SOLUTION:
WITH store_monthly_sales AS
(
    SELECT
        o.store_id,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS sales_month,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS store_net_sales
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY
        o.store_id,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
),
company_monthly_sales AS
(
    SELECT
        sales_month,
        SUM(store_net_sales) AS company_net_sales
    FROM store_monthly_sales
    GROUP BY sales_month
)
SELECT
    sms.store_id,
    sms.sales_month,
    sms.store_net_sales,
    cms.company_net_sales,
    CAST(
        100.0 * sms.store_net_sales / NULLIF(cms.company_net_sales, 0)
        AS DECIMAL(9,2)
    ) AS contribution_pct
FROM store_monthly_sales AS sms
INNER JOIN company_monthly_sales AS cms
    ON cms.sales_month = sms.sales_month
ORDER BY sms.sales_month, sms.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 103
-------------------------------------------------------------------------------
-- Use a CTE to calculate customer lifetime sales and rank customers.

-- OUTPUT GRAIN:
-- one row per customer

-- REFERENCE SOLUTION:
WITH customer_lifetime_sales AS
(
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(
            CASE WHEN o.status = N'Completed'
                 THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                 ELSE 0 END
        ), 0.00) AS lifetime_net_sales
    FROM retail.customers AS c
    LEFT JOIN retail.orders AS o
        ON o.customer_id = c.customer_id
    LEFT JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    lifetime_net_sales,
    RANK() OVER (ORDER BY lifetime_net_sales DESC) AS sales_rank
FROM customer_lifetime_sales
ORDER BY sales_rank, customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 104
-------------------------------------------------------------------------------
-- Refactor one nested subquery into multiple CTEs.

-- OUTPUT GRAIN:
-- one row per completed order above the average completed order value

-- REFERENCE SOLUTION:
-- This is a CTE refactor of the common nested-subquery pattern used to compare
-- per-order totals with the average of those totals.
WITH order_values AS
(
    SELECT
        o.order_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_net_sales
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY o.order_id
),
average_order_value AS
(
    SELECT AVG(CAST(order_net_sales AS DECIMAL(18,2))) AS avg_order_value
    FROM order_values
)
SELECT
    ov.order_id,
    ov.order_net_sales
FROM order_values AS ov
CROSS JOIN average_order_value AS a
WHERE ov.order_net_sales > a.avg_order_value
ORDER BY ov.order_net_sales DESC, ov.order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- J. Subqueries
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 105
-------------------------------------------------------------------------------
-- Products priced above average list price.

-- OUTPUT GRAIN:
-- one row per product priced above the overall average

-- REFERENCE SOLUTION:
SELECT
    product_id,
    sku,
    product_name,
    list_price
FROM retail.products
WHERE list_price >
(
    SELECT AVG(list_price)
    FROM retail.products
)
ORDER BY list_price DESC, product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 106
-------------------------------------------------------------------------------
-- Orders whose net value exceeds average completed order value.

-- OUTPUT GRAIN:
-- one row per qualifying completed order

-- REFERENCE SOLUTION:
SELECT
    order_values.order_id,
    order_values.order_net_sales
FROM
(
    SELECT
        o.order_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_net_sales
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY o.order_id
) AS order_values
WHERE order_values.order_net_sales >
(
    SELECT AVG(CAST(completed_orders.order_net_sales AS DECIMAL(18,2)))
    FROM
    (
        SELECT
            o2.order_id,
            SUM((oi2.quantity * oi2.unit_price) - oi2.discount_amount) AS order_net_sales
        FROM retail.orders AS o2
        INNER JOIN retail.order_items AS oi2
            ON oi2.order_id = o2.order_id
        WHERE o2.status = N'Completed'
        GROUP BY o2.order_id
    ) AS completed_orders
)
ORDER BY order_values.order_net_sales DESC, order_values.order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 107
-------------------------------------------------------------------------------
-- Customers whose lifetime sales exceed average customer lifetime sales.

-- OUTPUT GRAIN:
-- one row per qualifying customer

-- REFERENCE SOLUTION:
-- Assumption: the comparison population is customers who have completed sales.
SELECT
    customer_sales.customer_id,
    customer_sales.customer_name,
    customer_sales.lifetime_net_sales
FROM
(
    SELECT
        c.customer_id,
        c.customer_name,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS lifetime_net_sales
    FROM retail.customers AS c
    INNER JOIN retail.orders AS o
        ON o.customer_id = c.customer_id
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY c.customer_id, c.customer_name
) AS customer_sales
WHERE customer_sales.lifetime_net_sales >
(
    SELECT AVG(CAST(x.lifetime_net_sales AS DECIMAL(18,2)))
    FROM
    (
        SELECT
            o2.customer_id,
            SUM((oi2.quantity * oi2.unit_price) - oi2.discount_amount) AS lifetime_net_sales
        FROM retail.orders AS o2
        INNER JOIN retail.order_items AS oi2
            ON oi2.order_id = o2.order_id
        WHERE o2.status = N'Completed'
          AND o2.customer_id IS NOT NULL
        GROUP BY o2.customer_id
    ) AS x
)
ORDER BY customer_sales.lifetime_net_sales DESC, customer_sales.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 108
-------------------------------------------------------------------------------
-- Stores whose sales exceed average store sales.

-- OUTPUT GRAIN:
-- one row per qualifying store

-- REFERENCE SOLUTION:
-- Assumption: "sales" means completed net sales, and the average is among
-- stores that have completed sales.
SELECT
    store_sales.store_id,
    store_sales.store_net_sales
FROM
(
    SELECT
        o.store_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS store_net_sales
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY o.store_id
) AS store_sales
WHERE store_sales.store_net_sales >
(
    SELECT AVG(CAST(x.store_net_sales AS DECIMAL(18,2)))
    FROM
    (
        SELECT
            o2.store_id,
            SUM((oi2.quantity * oi2.unit_price) - oi2.discount_amount) AS store_net_sales
        FROM retail.orders AS o2
        INNER JOIN retail.order_items AS oi2
            ON oi2.order_id = o2.order_id
        WHERE o2.status = N'Completed'
        GROUP BY o2.store_id
    ) AS x
)
ORDER BY store_sales.store_net_sales DESC, store_sales.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 109
-------------------------------------------------------------------------------
-- Return each customer's first order using a subquery.

-- OUTPUT GRAIN:
-- one row per customer who placed at least one order

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM retail.customers AS c
INNER JOIN retail.orders AS o
    ON o.order_id =
    (
        SELECT TOP (1) o2.order_id
        FROM retail.orders AS o2
        WHERE o2.customer_id = c.customer_id
        ORDER BY o2.order_date, o2.order_id
    )
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 110
-------------------------------------------------------------------------------
-- Return each product with total quantity sold using a correlated subquery.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    COALESCE(
        (
            SELECT SUM(oi.quantity)
            FROM retail.order_items AS oi
            WHERE oi.product_id = p.product_id
        ),
        0
    ) AS total_quantity_sold
FROM retail.products AS p
ORDER BY p.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 111
-------------------------------------------------------------------------------
-- Rewrite Question 110 with a join/CTE and compare.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
WITH product_units AS
(
    SELECT
        product_id,
        SUM(quantity) AS total_quantity_sold
    FROM retail.order_items
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    COALESCE(pu.total_quantity_sold, 0) AS total_quantity_sold
FROM retail.products AS p
LEFT JOIN product_units AS pu
    ON pu.product_id = p.product_id
ORDER BY p.product_id;

-- Compared with the correlated subquery in Problem 110, this formulation
-- aggregates order_items once and then joins the result, which is typically
-- easier to reason about and can scale better for large child tables.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 112
-------------------------------------------------------------------------------
-- Return products with completed revenue above their category average.

-- OUTPUT GRAIN:
-- one row per product whose completed revenue is above its category average

-- REFERENCE SOLUTION:
SELECT
    pr.product_id,
    pr.product_name,
    pr.category,
    pr.completed_revenue
FROM
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_revenue
    FROM retail.products AS p
    INNER JOIN retail.order_items AS oi
        ON oi.product_id = p.product_id
    INNER JOIN retail.orders AS o
        ON o.order_id = oi.order_id
    WHERE o.status = N'Completed'
    GROUP BY p.product_id, p.product_name, p.category
) AS pr
WHERE pr.completed_revenue >
(
    SELECT AVG(CAST(category_products.completed_revenue AS DECIMAL(18,2)))
    FROM
    (
        SELECT
            p2.product_id,
            SUM((oi2.quantity * oi2.unit_price) - oi2.discount_amount) AS completed_revenue
        FROM retail.products AS p2
        INNER JOIN retail.order_items AS oi2
            ON oi2.product_id = p2.product_id
        INNER JOIN retail.orders AS o2
            ON o2.order_id = oi2.order_id
        WHERE o2.status = N'Completed'
          AND p2.category = pr.category
        GROUP BY p2.product_id
    ) AS category_products
)
ORDER BY pr.category, pr.completed_revenue DESC, pr.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- K. EXISTS / NOT EXISTS
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 113
-------------------------------------------------------------------------------
-- Customers with at least one order.

-- OUTPUT GRAIN:
-- one row per customer with at least one order

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name
FROM retail.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM retail.orders AS o
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 114
-------------------------------------------------------------------------------
-- Customers with no orders.

-- OUTPUT GRAIN:
-- one row per customer with no orders

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name
FROM retail.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM retail.orders AS o
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 115
-------------------------------------------------------------------------------
-- Products sold at least once.

-- OUTPUT GRAIN:
-- one row per product sold at least once

-- REFERENCE SOLUTION:
SELECT
    p.product_id,
    p.sku,
    p.product_name
FROM retail.products AS p
WHERE EXISTS
(
    SELECT 1
    FROM retail.order_items AS oi
    WHERE oi.product_id = p.product_id
)
ORDER BY p.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 116
-------------------------------------------------------------------------------
-- Products never sold.

-- OUTPUT GRAIN:
-- one row per product never sold

-- REFERENCE SOLUTION:
SELECT
    p.product_id,
    p.sku,
    p.product_name
FROM retail.products AS p
WHERE NOT EXISTS
(
    SELECT 1
    FROM retail.order_items AS oi
    WHERE oi.product_id = p.product_id
)
ORDER BY p.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 117
-------------------------------------------------------------------------------
-- Stores whose latest snapshot has at least one low-stock product.

-- OUTPUT GRAIN:
-- one row per store whose own latest snapshot contains low stock

-- REFERENCE SOLUTION:
SELECT
    s.store_id,
    s.store_name
FROM retail.stores AS s
WHERE EXISTS
(
    SELECT 1
    FROM retail.inventory_snapshots AS i
    WHERE i.store_id = s.store_id
      AND i.snapshot_date =
      (
          SELECT MAX(i2.snapshot_date)
          FROM retail.inventory_snapshots AS i2
          WHERE i2.store_id = s.store_id
      )
      AND i.on_hand_qty <= i.reorder_point
)
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 118
-------------------------------------------------------------------------------
-- Orders with at least one discounted line.

-- OUTPUT GRAIN:
-- one row per order containing at least one discounted line

-- REFERENCE SOLUTION:
SELECT
    o.order_id,
    o.order_date,
    o.status
FROM retail.orders AS o
WHERE EXISTS
(
    SELECT 1
    FROM retail.order_items AS oi
    WHERE oi.order_id = o.order_id
      AND oi.discount_amount > 0
)
ORDER BY o.order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 119
-------------------------------------------------------------------------------
-- Customers who bought Electronics.

-- OUTPUT GRAIN:
-- one row per customer who completed an Electronics purchase

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name
FROM retail.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN retail.products AS p
        ON p.product_id = oi.product_id
    WHERE o.customer_id = c.customer_id
      AND o.status = N'Completed'
      AND p.category = N'Electronics'
)
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 120
-------------------------------------------------------------------------------
-- Customers who never bought Electronics.

-- OUTPUT GRAIN:
-- one row per customer who has never completed an Electronics purchase

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name
FROM retail.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN retail.products AS p
        ON p.product_id = oi.product_id
    WHERE o.customer_id = c.customer_id
      AND o.status = N'Completed'
      AND p.category = N'Electronics'
)
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 121
-------------------------------------------------------------------------------
-- Incoming orders with valid numeric customer IDs that do not exist in `retail.customers`.

-- OUTPUT GRAIN:
-- one row per incoming order with an orphan numeric customer reference

-- REFERENCE SOLUTION:
SELECT
    s.ingestion_id,
    s.source_order_id_raw,
    s.customer_id_raw,
    TRY_CONVERT(INT, s.customer_id_raw) AS customer_id
FROM staging.orders_incoming AS s
WHERE NULLIF(LTRIM(RTRIM(s.customer_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, s.customer_id_raw) IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM retail.customers AS c
      WHERE c.customer_id = TRY_CONVERT(INT, s.customer_id_raw)
  )
ORDER BY s.ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 122
-------------------------------------------------------------------------------
-- Incoming order items with valid numeric product IDs that do not exist in `retail.products`.

-- OUTPUT GRAIN:
-- one row per incoming item with an orphan numeric product reference

-- REFERENCE SOLUTION:
SELECT
    i.ingestion_id,
    i.source_order_id_raw,
    i.line_number_raw,
    i.product_id_raw,
    TRY_CONVERT(INT, i.product_id_raw) AS product_id
FROM staging.order_items_incoming AS i
WHERE NULLIF(LTRIM(RTRIM(i.product_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, i.product_id_raw) IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM retail.products AS p
      WHERE p.product_id = TRY_CONVERT(INT, i.product_id_raw)
  )
ORDER BY i.ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- L. Window Functions — ROW_NUMBER / RANK / DENSE_RANK
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 123
-------------------------------------------------------------------------------
-- Number each customer's orders chronologically.

-- OUTPUT GRAIN:
-- one row per known-customer order

-- REFERENCE SOLUTION:
SELECT
    o.customer_id,
    o.order_id,
    o.order_date,
    ROW_NUMBER() OVER
    (
        PARTITION BY o.customer_id
        ORDER BY o.order_date, o.order_id
    ) AS customer_order_number
FROM retail.orders AS o
WHERE o.customer_id IS NOT NULL
ORDER BY o.customer_id, customer_order_number;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 124
-------------------------------------------------------------------------------
-- Return each customer's most recent order.

-- OUTPUT GRAIN:
-- one row per customer who placed at least one order

-- REFERENCE SOLUTION:
WITH ranked_orders AS
(
    SELECT
        o.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY o.order_date DESC, o.order_id DESC
        ) AS rn
    FROM retail.orders AS o
    WHERE o.customer_id IS NOT NULL
)
SELECT
    customer_id,
    order_id,
    order_date,
    status,
    sales_channel
FROM ranked_orders
WHERE rn = 1
ORDER BY customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 125
-------------------------------------------------------------------------------
-- Return each customer's first order.

-- OUTPUT GRAIN:
-- one row per customer who placed at least one order

-- REFERENCE SOLUTION:
WITH ranked_orders AS
(
    SELECT
        o.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY o.order_date, o.order_id
        ) AS rn
    FROM retail.orders AS o
    WHERE o.customer_id IS NOT NULL
)
SELECT
    customer_id,
    order_id,
    order_date,
    status,
    sales_channel
FROM ranked_orders
WHERE rn = 1
ORDER BY customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 126
-------------------------------------------------------------------------------
-- Rank products by completed net sales.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
WITH product_revenue AS
(
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(SUM(
            CASE WHEN o.status = N'Completed'
                 THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                 ELSE 0 END
        ), 0.00) AS completed_revenue
    FROM retail.products AS p
    LEFT JOIN retail.order_items AS oi
        ON oi.product_id = p.product_id
    LEFT JOIN retail.orders AS o
        ON o.order_id = oi.order_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    completed_revenue,
    RANK() OVER (ORDER BY completed_revenue DESC) AS revenue_rank
FROM product_revenue
ORDER BY revenue_rank, product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 127
-------------------------------------------------------------------------------
-- Rank products by completed net sales within category.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
WITH product_revenue AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(
            CASE WHEN o.status = N'Completed'
                 THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                 ELSE 0 END
        ), 0.00) AS completed_revenue
    FROM retail.products AS p
    LEFT JOIN retail.order_items AS oi
        ON oi.product_id = p.product_id
    LEFT JOIN retail.orders AS o
        ON o.order_id = oi.order_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    product_id,
    product_name,
    category,
    completed_revenue,
    RANK() OVER
    (
        PARTITION BY category
        ORDER BY completed_revenue DESC
    ) AS category_revenue_rank
FROM product_revenue
ORDER BY category, category_revenue_rank, product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 128
-------------------------------------------------------------------------------
-- Return top 3 products by revenue within each category.

-- OUTPUT GRAIN:
-- up to three product rows per category

-- REFERENCE SOLUTION:
WITH product_revenue AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(
            CASE WHEN o.status = N'Completed'
                 THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                 ELSE 0 END
        ), 0.00) AS completed_revenue
    FROM retail.products AS p
    LEFT JOIN retail.order_items AS oi
        ON oi.product_id = p.product_id
    LEFT JOIN retail.orders AS o
        ON o.order_id = oi.order_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY completed_revenue DESC, product_id
        ) AS rn
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    completed_revenue,
    rn AS category_position
FROM ranked
WHERE rn <= 3
ORDER BY category, rn;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 129
-------------------------------------------------------------------------------
-- Demonstrate `ROW_NUMBER`, `RANK`, and `DENSE_RANK` on the Accessories category. Your output must expose the seeded tie.

-- OUTPUT GRAIN:
-- one row per Accessories product

-- REFERENCE SOLUTION:
WITH product_revenue AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(
            CASE WHEN o.status = N'Completed'
                 THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                 ELSE 0 END
        ), 0.00) AS completed_revenue
    FROM retail.products AS p
    LEFT JOIN retail.order_items AS oi
        ON oi.product_id = p.product_id
    LEFT JOIN retail.orders AS o
        ON o.order_id = oi.order_id
    WHERE p.category = N'Accessories'
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    product_id,
    product_name,
    completed_revenue,
    ROW_NUMBER() OVER
    (
        ORDER BY completed_revenue DESC, product_id
    ) AS row_number_value,
    RANK() OVER
    (
        ORDER BY completed_revenue DESC
    ) AS rank_value,
    DENSE_RANK() OVER
    (
        ORDER BY completed_revenue DESC
    ) AS dense_rank_value
FROM product_revenue
ORDER BY completed_revenue DESC, product_id;

-- Seed expectation: products 121 and 122 have equal completed revenue. Their
-- ROW_NUMBER values differ, while RANK and DENSE_RANK assign the same rank.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 130
-------------------------------------------------------------------------------
-- Rank stores by revenue within province.

-- OUTPUT GRAIN:
-- one row per store

-- REFERENCE SOLUTION:
WITH store_revenue AS
(
    SELECT
        s.store_id,
        s.store_name,
        s.province,
        COALESCE(SUM(
            CASE WHEN o.status = N'Completed'
                 THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                 ELSE 0 END
        ), 0.00) AS completed_revenue
    FROM retail.stores AS s
    LEFT JOIN retail.orders AS o
        ON o.store_id = s.store_id
    LEFT JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    GROUP BY s.store_id, s.store_name, s.province
)
SELECT
    store_id,
    store_name,
    province,
    completed_revenue,
    RANK() OVER
    (
        PARTITION BY province
        ORDER BY completed_revenue DESC
    ) AS province_revenue_rank
FROM store_revenue
ORDER BY province, province_revenue_rank, store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 131
-------------------------------------------------------------------------------
-- Return the second-highest revenue product per category.

-- OUTPUT GRAIN:
-- one row per product at the second distinct revenue level in its category

-- REFERENCE SOLUTION:
WITH product_revenue AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(
            CASE WHEN o.status = N'Completed'
                 THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                 ELSE 0 END
        ), 0.00) AS completed_revenue
    FROM retail.products AS p
    LEFT JOIN retail.order_items AS oi
        ON oi.product_id = p.product_id
    LEFT JOIN retail.orders AS o
        ON o.order_id = oi.order_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked AS
(
    SELECT
        *,
        DENSE_RANK() OVER
        (
            PARTITION BY category
            ORDER BY completed_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    completed_revenue
FROM ranked
WHERE revenue_rank = 2
ORDER BY category, product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 132
-------------------------------------------------------------------------------
-- Return latest inventory snapshot per store/product.

-- OUTPUT GRAIN:
-- one row per store/product pair

-- REFERENCE SOLUTION:
WITH ranked_inventory AS
(
    SELECT
        i.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY i.store_id, i.product_id
            ORDER BY i.snapshot_date DESC
        ) AS rn
    FROM retail.inventory_snapshots AS i
)
SELECT
    store_id,
    product_id,
    snapshot_date,
    on_hand_qty,
    reorder_point
FROM ranked_inventory
WHERE rn = 1
ORDER BY store_id, product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 133
-------------------------------------------------------------------------------
-- Return the top-selling order line within each completed order.

-- OUTPUT GRAIN:
-- one row per completed order

-- REFERENCE SOLUTION:
-- Assumption: "top-selling" means highest net line revenue.
WITH ranked_lines AS
(
    SELECT
        o.order_id,
        oi.line_number,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.discount_amount,
        (oi.quantity * oi.unit_price) - oi.discount_amount AS net_line_sales,
        ROW_NUMBER() OVER
        (
            PARTITION BY o.order_id
            ORDER BY
                ((oi.quantity * oi.unit_price) - oi.discount_amount) DESC,
                oi.line_number
        ) AS rn
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
)
SELECT
    order_id,
    line_number,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    net_line_sales
FROM ranked_lines
WHERE rn = 1
ORDER BY order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- M. LAG / LEAD
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 134
-------------------------------------------------------------------------------
-- Previous order date per customer.

-- OUTPUT GRAIN:
-- one row per known-customer order

-- REFERENCE SOLUTION:
SELECT
    customer_id,
    order_id,
    order_date,
    LAG(order_date) OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS previous_order_date
FROM retail.orders
WHERE customer_id IS NOT NULL
ORDER BY customer_id, order_date, order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 135
-------------------------------------------------------------------------------
-- Days since previous order.

-- OUTPUT GRAIN:
-- one row per known-customer order

-- REFERENCE SOLUTION:
WITH sequenced AS
(
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER
        (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_date
    FROM retail.orders
    WHERE customer_id IS NOT NULL
)
SELECT
    customer_id,
    order_id,
    order_date,
    previous_order_date,
    DATEDIFF(DAY, previous_order_date, order_date) AS days_since_previous_order
FROM sequenced
ORDER BY customer_id, order_date, order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 136
-------------------------------------------------------------------------------
-- Previous on-hand quantity per store/product.

-- OUTPUT GRAIN:
-- one row per inventory snapshot

-- REFERENCE SOLUTION:
SELECT
    store_id,
    product_id,
    snapshot_date,
    on_hand_qty,
    LAG(on_hand_qty) OVER
    (
        PARTITION BY store_id, product_id
        ORDER BY snapshot_date
    ) AS previous_on_hand_qty
FROM retail.inventory_snapshots
ORDER BY store_id, product_id, snapshot_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 137
-------------------------------------------------------------------------------
-- Inventory change since previous snapshot.

-- OUTPUT GRAIN:
-- one row per inventory snapshot

-- REFERENCE SOLUTION:
WITH sequenced AS
(
    SELECT
        store_id,
        product_id,
        snapshot_date,
        on_hand_qty,
        LAG(on_hand_qty) OVER
        (
            PARTITION BY store_id, product_id
            ORDER BY snapshot_date
        ) AS previous_on_hand_qty
    FROM retail.inventory_snapshots
)
SELECT
    store_id,
    product_id,
    snapshot_date,
    on_hand_qty,
    previous_on_hand_qty,
    on_hand_qty - previous_on_hand_qty AS inventory_change
FROM sequenced
ORDER BY store_id, product_id, snapshot_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 138
-------------------------------------------------------------------------------
-- Flag inventory decreases.

-- OUTPUT GRAIN:
-- one row per inventory snapshot

-- REFERENCE SOLUTION:
WITH sequenced AS
(
    SELECT
        store_id,
        product_id,
        snapshot_date,
        on_hand_qty,
        LAG(on_hand_qty) OVER
        (
            PARTITION BY store_id, product_id
            ORDER BY snapshot_date
        ) AS previous_on_hand_qty
    FROM retail.inventory_snapshots
)
SELECT
    store_id,
    product_id,
    snapshot_date,
    on_hand_qty,
    previous_on_hand_qty,
    CASE
        WHEN previous_on_hand_qty IS NOT NULL
         AND on_hand_qty < previous_on_hand_qty THEN 1
        ELSE 0
    END AS inventory_decreased_flag
FROM sequenced
ORDER BY store_id, product_id, snapshot_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 139
-------------------------------------------------------------------------------
-- Next order date per customer.

-- OUTPUT GRAIN:
-- one row per known-customer order

-- REFERENCE SOLUTION:
SELECT
    customer_id,
    order_id,
    order_date,
    LEAD(order_date) OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS next_order_date
FROM retail.orders
WHERE customer_id IS NOT NULL
ORDER BY customer_id, order_date, order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 140
-------------------------------------------------------------------------------
-- Flag whether a customer returned within 30 days.

-- OUTPUT GRAIN:
-- one row per known-customer order

-- REFERENCE SOLUTION:
WITH sequenced AS
(
    SELECT
        customer_id,
        order_id,
        order_date,
        LEAD(order_date) OVER
        (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS next_order_date
    FROM retail.orders
    WHERE customer_id IS NOT NULL
)
SELECT
    customer_id,
    order_id,
    order_date,
    next_order_date,
    CASE
        WHEN next_order_date < DATEADD(DAY, 30, order_date)
          OR next_order_date = DATEADD(DAY, 30, order_date)
        THEN 1
        ELSE 0
    END AS returned_within_30_days_flag
FROM sequenced
ORDER BY customer_id, order_date, order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 141
-------------------------------------------------------------------------------
-- Compare each month's completed sales with the prior month.

-- OUTPUT GRAIN:
-- one row per month with completed sales

-- REFERENCE SOLUTION:
WITH monthly_sales AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS sales_month,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
),
sequenced AS
(
    SELECT
        sales_month,
        completed_net_sales,
        LAG(completed_net_sales) OVER (ORDER BY sales_month) AS prior_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    completed_net_sales,
    prior_month_sales,
    completed_net_sales - prior_month_sales AS change_from_prior_month
FROM sequenced
ORDER BY sales_month;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- N. Windowed Aggregates
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 142
-------------------------------------------------------------------------------
-- Running completed net sales by date.

-- OUTPUT GRAIN:
-- one row per completed-sales calendar date

-- REFERENCE SOLUTION:
WITH daily_sales AS
(
    SELECT
        CAST(o.order_date AS DATE) AS sales_date,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS daily_net_sales
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY CAST(o.order_date AS DATE)
)
SELECT
    sales_date,
    daily_net_sales,
    SUM(daily_net_sales) OVER
    (
        ORDER BY sales_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_completed_net_sales
FROM daily_sales
ORDER BY sales_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 143
-------------------------------------------------------------------------------
-- Running completed net sales by store.

-- OUTPUT GRAIN:
-- one row per store per completed-sales date

-- REFERENCE SOLUTION:
WITH store_daily_sales AS
(
    SELECT
        o.store_id,
        CAST(o.order_date AS DATE) AS sales_date,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS daily_net_sales
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY o.store_id, CAST(o.order_date AS DATE)
)
SELECT
    store_id,
    sales_date,
    daily_net_sales,
    SUM(daily_net_sales) OVER
    (
        PARTITION BY store_id
        ORDER BY sales_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_store_net_sales
FROM store_daily_sales
ORDER BY store_id, sales_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 144
-------------------------------------------------------------------------------
-- Product percentage of category revenue.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
WITH product_revenue AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(
            CASE WHEN o.status = N'Completed'
                 THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                 ELSE 0 END
        ), 0.00) AS completed_revenue
    FROM retail.products AS p
    LEFT JOIN retail.order_items AS oi
        ON oi.product_id = p.product_id
    LEFT JOIN retail.orders AS o
        ON o.order_id = oi.order_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    product_id,
    product_name,
    category,
    completed_revenue,
    CAST(
        100.0 * completed_revenue
        / NULLIF(SUM(completed_revenue) OVER (PARTITION BY category), 0)
        AS DECIMAL(9,2)
    ) AS category_revenue_pct
FROM product_revenue
ORDER BY category, completed_revenue DESC, product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 145
-------------------------------------------------------------------------------
-- Store percentage of company revenue.

-- OUTPUT GRAIN:
-- one row per store

-- REFERENCE SOLUTION:
WITH store_revenue AS
(
    SELECT
        s.store_id,
        s.store_name,
        COALESCE(SUM(
            CASE WHEN o.status = N'Completed'
                 THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                 ELSE 0 END
        ), 0.00) AS completed_revenue
    FROM retail.stores AS s
    LEFT JOIN retail.orders AS o
        ON o.store_id = s.store_id
    LEFT JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    GROUP BY s.store_id, s.store_name
)
SELECT
    store_id,
    store_name,
    completed_revenue,
    CAST(
        100.0 * completed_revenue
        / NULLIF(SUM(completed_revenue) OVER (), 0)
        AS DECIMAL(9,2)
    ) AS company_revenue_pct
FROM store_revenue
ORDER BY completed_revenue DESC, store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 146
-------------------------------------------------------------------------------
-- Cumulative units sold per product over time.

-- OUTPUT GRAIN:
-- one row per product per completed-sales date

-- REFERENCE SOLUTION:
WITH product_daily_units AS
(
    SELECT
        oi.product_id,
        CAST(o.order_date AS DATE) AS sales_date,
        SUM(oi.quantity) AS daily_units
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY oi.product_id, CAST(o.order_date AS DATE)
)
SELECT
    product_id,
    sales_date,
    daily_units,
    SUM(daily_units) OVER
    (
        PARTITION BY product_id
        ORDER BY sales_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_units_sold
FROM product_daily_units
ORDER BY product_id, sales_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 147
-------------------------------------------------------------------------------
-- Three-row moving average of daily completed sales.

-- OUTPUT GRAIN:
-- one row per completed-sales calendar date

-- REFERENCE SOLUTION:
WITH daily_sales AS
(
    SELECT
        CAST(o.order_date AS DATE) AS sales_date,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS daily_net_sales
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY CAST(o.order_date AS DATE)
)
SELECT
    sales_date,
    daily_net_sales,
    CAST(
        AVG(CAST(daily_net_sales AS DECIMAL(18,2))) OVER
        (
            ORDER BY sales_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )
        AS DECIMAL(18,2)
    ) AS three_row_moving_avg
FROM daily_sales
ORDER BY sales_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 148
-------------------------------------------------------------------------------
-- Running order count by customer.

-- OUTPUT GRAIN:
-- one row per known-customer order

-- REFERENCE SOLUTION:
SELECT
    customer_id,
    order_id,
    order_date,
    COUNT(*) OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_order_count
FROM retail.orders
WHERE customer_id IS NOT NULL
ORDER BY customer_id, order_date, order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- O. Safe Type Conversion / Raw Source Inspection
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 149
-------------------------------------------------------------------------------
-- Return incoming orders with safely converted integer order/customer/store IDs.

-- OUTPUT GRAIN:
-- one row per incoming order source row

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    TRY_CONVERT(INT, source_order_id_raw) AS source_order_id,
    customer_id_raw,
    TRY_CONVERT(INT, customer_id_raw) AS customer_id,
    store_id_raw,
    TRY_CONVERT(INT, store_id_raw) AS store_id
FROM staging.orders_incoming
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 150
-------------------------------------------------------------------------------
-- Return incoming orders where order ID cannot be converted to `INT`.

-- OUTPUT GRAIN:
-- one row per incoming order with a malformed nonblank order ID

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, source_order_id_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 151
-------------------------------------------------------------------------------
-- Return incoming order dates that cannot be converted to `DATETIME2`.

-- OUTPUT GRAIN:
-- one row per incoming order with a malformed nonblank order date

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    order_date_raw
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(order_date_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(DATETIME2(0), order_date_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 152
-------------------------------------------------------------------------------
-- Return malformed incoming item quantities.

-- OUTPUT GRAIN:
-- one row per incoming item with a malformed nonblank quantity

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw,
    quantity_raw
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(quantity_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, quantity_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 153
-------------------------------------------------------------------------------
-- Return malformed incoming item unit prices.

-- OUTPUT GRAIN:
-- one row per incoming item with a malformed nonblank unit price

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw,
    unit_price_raw
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(unit_price_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), unit_price_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 154
-------------------------------------------------------------------------------
-- Convert valid incoming product cost/price strings to decimals.

-- OUTPUT GRAIN:
-- one row per incoming product whose cost and price both convert successfully

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    product_id_raw,
    unit_cost_raw,
    TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) AS unit_cost,
    list_price_raw,
    TRY_CONVERT(DECIMAL(10,2), list_price_raw) AS list_price
FROM staging.products_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), list_price_raw) IS NOT NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 155
-------------------------------------------------------------------------------
-- Explain why `CAST` is dangerous for a mixed-validity raw batch and demonstrate the safer alternative.

-- OUTPUT GRAIN:
-- one row per incoming product source row

-- REFERENCE SOLUTION:
-- CAST/CONVERT can terminate the batch when even one source value is malformed.
-- For example, the following is intentionally NOT executed because the seed
-- contains unit_cost_raw = 'abc':
--
-- SELECT CAST(unit_cost_raw AS DECIMAL(10,2))
-- FROM staging.products_incoming;
--
-- TRY_CONVERT instead returns NULL for rows that cannot be converted, allowing
-- the pipeline to identify and quarantine those records without aborting.
SELECT
    ingestion_id,
    product_id_raw,
    unit_cost_raw,
    TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) AS safe_unit_cost
FROM staging.products_incoming
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- P. Deduplication
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 156
-------------------------------------------------------------------------------
-- Show duplicate incoming `source_order_id_raw` values.

-- OUTPUT GRAIN:
-- one row per duplicated nonblank raw source order ID

-- REFERENCE SOLUTION:
SELECT
    source_order_id_raw,
    COUNT(*) AS row_count
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NOT NULL
GROUP BY source_order_id_raw
HAVING COUNT(*) > 1
ORDER BY TRY_CONVERT(INT, source_order_id_raw), source_order_id_raw;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 157
-------------------------------------------------------------------------------
-- Count versions per source order.

-- OUTPUT GRAIN:
-- one row per nonblank source order ID

-- REFERENCE SOLUTION:
SELECT
    source_order_id_raw,
    COUNT(*) AS version_count
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NOT NULL
GROUP BY source_order_id_raw
ORDER BY TRY_CONVERT(INT, source_order_id_raw), source_order_id_raw;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

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
-- one row per incoming row with a valid numeric order business key, with dedup rank attached

-- REFERENCE SOLUTION:
WITH ranked AS
(
    SELECT
        s.*,
        TRY_CONVERT(INT, s.source_order_id_raw) AS source_order_id,
        TRY_CONVERT(DATETIME2(0), s.modified_at_raw) AS modified_at,
        ROW_NUMBER() OVER
        (
            PARTITION BY TRY_CONVERT(INT, s.source_order_id_raw)
            ORDER BY
                TRY_CONVERT(DATETIME2(0), s.modified_at_raw) DESC,
                s.ingested_at DESC,
                s.ingestion_id DESC
        ) AS dedup_rn
    FROM staging.orders_incoming AS s
    WHERE NULLIF(LTRIM(RTRIM(s.source_order_id_raw)), N'') IS NOT NULL
      AND TRY_CONVERT(INT, s.source_order_id_raw) IS NOT NULL
)
SELECT
    ingestion_id,
    source_order_id,
    status_raw,
    modified_at,
    ingested_at,
    dedup_rn
FROM ranked
ORDER BY source_order_id, dedup_rn;

-- Note: this problem applies business-key version ranking only. File replay is
-- handled separately in Section Q; therefore replay rows still participate here.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 159
-------------------------------------------------------------------------------
-- Return only winning records.

-- OUTPUT GRAIN:
-- one row per valid numeric source order business key

-- REFERENCE SOLUTION:
WITH ranked AS
(
    SELECT
        s.*,
        TRY_CONVERT(INT, s.source_order_id_raw) AS source_order_id,
        TRY_CONVERT(DATETIME2(0), s.modified_at_raw) AS modified_at,
        ROW_NUMBER() OVER
        (
            PARTITION BY TRY_CONVERT(INT, s.source_order_id_raw)
            ORDER BY
                TRY_CONVERT(DATETIME2(0), s.modified_at_raw) DESC,
                s.ingested_at DESC,
                s.ingestion_id DESC
        ) AS rn
    FROM staging.orders_incoming AS s
    WHERE NULLIF(LTRIM(RTRIM(s.source_order_id_raw)), N'') IS NOT NULL
      AND TRY_CONVERT(INT, s.source_order_id_raw) IS NOT NULL
)
SELECT
    ingestion_id,
    source_order_id,
    customer_id_raw,
    store_id_raw,
    order_date_raw,
    status_raw,
    sales_channel_raw,
    modified_at,
    change_type_raw,
    ingested_at
FROM ranked
WHERE rn = 1
ORDER BY source_order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 160
-------------------------------------------------------------------------------
-- Return only superseded records.

-- OUTPUT GRAIN:
-- one row per superseded incoming order version

-- REFERENCE SOLUTION:
WITH ranked AS
(
    SELECT
        s.*,
        TRY_CONVERT(INT, s.source_order_id_raw) AS source_order_id,
        TRY_CONVERT(DATETIME2(0), s.modified_at_raw) AS modified_at,
        ROW_NUMBER() OVER
        (
            PARTITION BY TRY_CONVERT(INT, s.source_order_id_raw)
            ORDER BY
                TRY_CONVERT(DATETIME2(0), s.modified_at_raw) DESC,
                s.ingested_at DESC,
                s.ingestion_id DESC
        ) AS rn
    FROM staging.orders_incoming AS s
    WHERE NULLIF(LTRIM(RTRIM(s.source_order_id_raw)), N'') IS NOT NULL
      AND TRY_CONVERT(INT, s.source_order_id_raw) IS NOT NULL
)
SELECT
    ingestion_id,
    source_order_id,
    status_raw,
    modified_at,
    ingested_at,
    rn AS version_position
FROM ranked
WHERE rn > 1
ORDER BY source_order_id, rn;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 161
-------------------------------------------------------------------------------
-- Label each row as `UNIQUE`, `WINNER`, or `SUPERSEDED`.

-- OUTPUT GRAIN:
-- one row per incoming order row with a valid numeric business key

-- REFERENCE SOLUTION:
WITH ranked AS
(
    SELECT
        s.*,
        TRY_CONVERT(INT, s.source_order_id_raw) AS source_order_id,
        ROW_NUMBER() OVER
        (
            PARTITION BY TRY_CONVERT(INT, s.source_order_id_raw)
            ORDER BY
                TRY_CONVERT(DATETIME2(0), s.modified_at_raw) DESC,
                s.ingested_at DESC,
                s.ingestion_id DESC
        ) AS rn,
        COUNT(*) OVER
        (
            PARTITION BY TRY_CONVERT(INT, s.source_order_id_raw)
        ) AS version_count
    FROM staging.orders_incoming AS s
    WHERE NULLIF(LTRIM(RTRIM(s.source_order_id_raw)), N'') IS NOT NULL
      AND TRY_CONVERT(INT, s.source_order_id_raw) IS NOT NULL
)
SELECT
    ingestion_id,
    source_order_id,
    status_raw,
    modified_at_raw,
    ingested_at,
    CASE
        WHEN version_count = 1 THEN N'UNIQUE'
        WHEN rn = 1 THEN N'WINNER'
        ELSE N'SUPERSEDED'
    END AS dedup_status
FROM ranked
ORDER BY source_order_id, rn;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 162
-------------------------------------------------------------------------------
-- Show the seeded `modified_at` tie and prove your tie-break is deterministic.

-- OUTPUT GRAIN:
-- one row per incoming order row participating in a modified_at tie

-- REFERENCE SOLUTION:
WITH tied AS
(
    SELECT
        s.*,
        TRY_CONVERT(INT, s.source_order_id_raw) AS source_order_id,
        TRY_CONVERT(DATETIME2(0), s.modified_at_raw) AS modified_at,
        COUNT(*) OVER
        (
            PARTITION BY
                TRY_CONVERT(INT, s.source_order_id_raw),
                TRY_CONVERT(DATETIME2(0), s.modified_at_raw)
        ) AS tied_timestamp_count,
        ROW_NUMBER() OVER
        (
            PARTITION BY TRY_CONVERT(INT, s.source_order_id_raw)
            ORDER BY
                TRY_CONVERT(DATETIME2(0), s.modified_at_raw) DESC,
                s.ingested_at DESC,
                s.ingestion_id DESC
        ) AS deterministic_rn
    FROM staging.orders_incoming AS s
    WHERE TRY_CONVERT(INT, s.source_order_id_raw) IS NOT NULL
)
SELECT
    ingestion_id,
    source_order_id,
    status_raw,
    modified_at,
    ingested_at,
    deterministic_rn
FROM tied
WHERE tied_timestamp_count > 1
ORDER BY source_order_id, modified_at, deterministic_rn;

-- For the seeded 2012 tie, modified_at is identical. The later ingested_at wins;
-- ingestion_id remains a final deterministic tie-break if both timestamps tie.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 163
-------------------------------------------------------------------------------
-- Deduplicate incoming order items by `(source_order_id, line_number)`.

-- OUTPUT GRAIN:
-- one row per valid incoming (source_order_id, line_number) business key

-- REFERENCE SOLUTION:
WITH ranked AS
(
    SELECT
        i.*,
        TRY_CONVERT(INT, i.source_order_id_raw) AS source_order_id,
        TRY_CONVERT(INT, i.line_number_raw) AS line_number,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                TRY_CONVERT(INT, i.source_order_id_raw),
                TRY_CONVERT(INT, i.line_number_raw)
            ORDER BY
                TRY_CONVERT(DATETIME2(0), i.modified_at_raw) DESC,
                i.ingested_at DESC,
                i.ingestion_id DESC
        ) AS rn
    FROM staging.order_items_incoming AS i
    WHERE TRY_CONVERT(INT, i.source_order_id_raw) IS NOT NULL
      AND TRY_CONVERT(INT, i.line_number_raw) IS NOT NULL
)
SELECT
    ingestion_id,
    source_order_id,
    line_number,
    product_id_raw,
    quantity_raw,
    unit_price_raw,
    discount_amount_raw,
    modified_at_raw,
    ingested_at
FROM ranked
WHERE rn = 1
ORDER BY source_order_id, line_number;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 164
-------------------------------------------------------------------------------
-- Deduplicate incoming inventory by `(store_id, product_id, snapshot_date)`.

-- OUTPUT GRAIN:
-- one row per valid incoming (store, product, snapshot date) business key

-- REFERENCE SOLUTION:
WITH ranked AS
(
    SELECT
        i.*,
        TRY_CONVERT(INT, i.store_id_raw) AS store_id,
        TRY_CONVERT(INT, i.product_id_raw) AS product_id,
        TRY_CONVERT(DATE, i.snapshot_date_raw) AS snapshot_date,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                TRY_CONVERT(INT, i.store_id_raw),
                TRY_CONVERT(INT, i.product_id_raw),
                TRY_CONVERT(DATE, i.snapshot_date_raw)
            ORDER BY
                TRY_CONVERT(DATETIME2(0), i.modified_at_raw) DESC,
                i.ingested_at DESC,
                i.ingestion_id DESC
        ) AS rn
    FROM staging.inventory_incoming AS i
    WHERE TRY_CONVERT(INT, i.store_id_raw) IS NOT NULL
      AND TRY_CONVERT(INT, i.product_id_raw) IS NOT NULL
      AND TRY_CONVERT(DATE, i.snapshot_date_raw) IS NOT NULL
)
SELECT
    ingestion_id,
    store_id,
    product_id,
    snapshot_date,
    on_hand_qty_raw,
    reorder_point_raw,
    modified_at_raw,
    ingested_at
FROM ranked
WHERE rn = 1
ORDER BY store_id, product_id, snapshot_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 165
-------------------------------------------------------------------------------
-- Explain why `DISTINCT` is insufficient for versioned-source deduplication.

-- OUTPUT GRAIN:
-- conceptual answer; no row-producing grain

-- REFERENCE SOLUTION:
-- DISTINCT removes rows only when every projected value is identical. Versioned
-- source records normally differ in modified_at, ingested_at, status, quantity,
-- or another attribute, so DISTINCT does not identify which version is current.
-- Deterministic deduplication requires a business-key PARTITION BY plus an
-- explicit precedence rule such as ROW_NUMBER() ORDER BY modified_at DESC,
-- ingested_at DESC, ingestion_id DESC.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- Q. Duplicate File / Replay Detection
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 166
-------------------------------------------------------------------------------
-- Find duplicate source files by `(source_entity, file_checksum)`.

-- OUTPUT GRAIN:
-- one row per duplicated (source_entity, file_checksum)

-- REFERENCE SOLUTION:
SELECT
    source_entity,
    file_checksum,
    COUNT(*) AS batch_count,
    MIN(arrived_at) AS first_arrived_at,
    MAX(arrived_at) AS last_arrived_at
FROM staging.ingestion_batches
GROUP BY source_entity, file_checksum
HAVING COUNT(*) > 1
ORDER BY source_entity, file_checksum;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 167
-------------------------------------------------------------------------------
-- Identify replayed order batches.

-- OUTPUT GRAIN:
-- one row per replayed order batch after the earliest batch for a checksum

-- REFERENCE SOLUTION:
WITH ranked_batches AS
(
    SELECT
        b.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY b.source_entity, b.file_checksum
            ORDER BY b.arrived_at, b.batch_id
        ) AS checksum_rn
    FROM staging.ingestion_batches AS b
    WHERE b.source_entity = N'orders'
)
SELECT
    batch_id,
    source_file,
    file_checksum,
    arrived_at
FROM ranked_batches
WHERE checksum_rn > 1
ORDER BY arrived_at, batch_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 168
-------------------------------------------------------------------------------
-- Return all order rows belonging to a replayed checksum.

-- OUTPUT GRAIN:
-- one row per incoming order row whose checksum appears in more than one order batch

-- REFERENCE SOLUTION:
WITH replayed_checksums AS
(
    SELECT
        source_entity,
        file_checksum
    FROM staging.ingestion_batches
    WHERE source_entity = N'orders'
    GROUP BY source_entity, file_checksum
    HAVING COUNT(*) > 1
)
SELECT
    o.ingestion_id,
    o.batch_id,
    b.source_file,
    b.file_checksum,
    o.source_order_id_raw,
    o.source_row_number
FROM staging.orders_incoming AS o
INNER JOIN staging.ingestion_batches AS b
    ON b.batch_id = o.batch_id
INNER JOIN replayed_checksums AS rc
    ON rc.source_entity = b.source_entity
   AND rc.file_checksum = b.file_checksum
ORDER BY b.arrived_at, o.source_row_number, o.ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 169
-------------------------------------------------------------------------------
-- Design a query that chooses only the earliest accepted batch for a checksum.

-- OUTPUT GRAIN:
-- one row per unique (source_entity, file_checksum)

-- REFERENCE SOLUTION:
WITH ranked_batches AS
(
    SELECT
        b.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY b.source_entity, b.file_checksum
            ORDER BY b.arrived_at, b.batch_id
        ) AS checksum_rn
    FROM staging.ingestion_batches AS b
)
SELECT
    batch_id,
    source_entity,
    source_file,
    file_checksum,
    arrived_at
FROM ranked_batches
WHERE checksum_rn = 1
ORDER BY source_entity, arrived_at, batch_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 170
-------------------------------------------------------------------------------
-- Explain how checksum-level idempotency differs from business-key deduplication.

-- OUTPUT GRAIN:
-- conceptual answer; no row-producing grain

-- REFERENCE SOLUTION:
-- Checksum-level idempotency answers: "Have I already accepted this exact source
-- file/content?" It prevents a replayed file from being processed twice.
--
-- Business-key deduplication answers: "When several accepted source records refer
-- to the same business entity, which version wins?" It resolves legitimate
-- corrections/versions such as multiple rows for the same order ID.
--
-- A robust pipeline needs both: reject/skip replayed checksums first, then dedup
-- business keys among the accepted files.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- R. Data Quality — Orders
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 171
-------------------------------------------------------------------------------
-- Missing/blank source order keys.

-- OUTPUT GRAIN:
-- one row per incoming order with a missing/blank source order key

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    batch_id,
    source_row_number,
    source_order_id_raw
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 172
-------------------------------------------------------------------------------
-- Malformed order IDs.

-- OUTPUT GRAIN:
-- one row per incoming order with a malformed nonblank order ID

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, source_order_id_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 173
-------------------------------------------------------------------------------
-- Malformed customer IDs, excluding NULL guest customers.

-- OUTPUT GRAIN:
-- one row per incoming order with a malformed nonblank customer ID

-- REFERENCE SOLUTION:
-- NULL customer_id_raw is a legitimate guest order and is intentionally excluded.
SELECT
    ingestion_id,
    source_order_id_raw,
    customer_id_raw
FROM staging.orders_incoming
WHERE customer_id_raw IS NOT NULL
  AND NULLIF(LTRIM(RTRIM(customer_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, customer_id_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 174
-------------------------------------------------------------------------------
-- Malformed store IDs.

-- OUTPUT GRAIN:
-- one row per incoming order with a malformed nonblank store ID

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    store_id_raw
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(store_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, store_id_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 175
-------------------------------------------------------------------------------
-- Malformed order dates.

-- OUTPUT GRAIN:
-- one row per incoming order with a malformed nonblank order date

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    order_date_raw
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(order_date_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(DATETIME2(0), order_date_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 176
-------------------------------------------------------------------------------
-- Future-dated orders using `@as_of_date = '2026-08-15'`.

-- OUTPUT GRAIN:
-- one row per incoming order dated after the as-of calendar date

-- REFERENCE SOLUTION:
DECLARE @as_of_date DATE = '2026-08-15';

SELECT
    ingestion_id,
    source_order_id_raw,
    order_date_raw,
    TRY_CONVERT(DATETIME2(0), order_date_raw) AS order_date
FROM staging.orders_incoming
WHERE TRY_CONVERT(DATETIME2(0), order_date_raw)
      >= DATEADD(DAY, 1, CAST(@as_of_date AS DATETIME2(0)))
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 177
-------------------------------------------------------------------------------
-- Invalid status values.

-- OUTPUT GRAIN:
-- one row per incoming order with an invalid status

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    status_raw
FROM staging.orders_incoming
WHERE status_raw IS NULL
   OR status_raw NOT IN
      (N'Processing', N'Shipped', N'Completed', N'Cancelled', N'Refunded')
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 178
-------------------------------------------------------------------------------
-- Invalid sales channels.

-- OUTPUT GRAIN:
-- one row per incoming order with an invalid sales channel

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    sales_channel_raw
FROM staging.orders_incoming
WHERE sales_channel_raw IS NULL
   OR sales_channel_raw NOT IN (N'Online', N'InStore')
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 179
-------------------------------------------------------------------------------
-- Orphan customers.

-- OUTPUT GRAIN:
-- one row per incoming order with a numeric customer ID absent from retail.customers

-- REFERENCE SOLUTION:
SELECT
    s.ingestion_id,
    s.source_order_id_raw,
    s.customer_id_raw,
    TRY_CONVERT(INT, s.customer_id_raw) AS customer_id
FROM staging.orders_incoming AS s
WHERE s.customer_id_raw IS NOT NULL
  AND TRY_CONVERT(INT, s.customer_id_raw) IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM retail.customers AS c
      WHERE c.customer_id = TRY_CONVERT(INT, s.customer_id_raw)
  )
ORDER BY s.ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 180
-------------------------------------------------------------------------------
-- Orphan stores.

-- OUTPUT GRAIN:
-- one row per incoming order with a numeric store ID absent from retail.stores

-- REFERENCE SOLUTION:
SELECT
    s.ingestion_id,
    s.source_order_id_raw,
    s.store_id_raw,
    TRY_CONVERT(INT, s.store_id_raw) AS store_id
FROM staging.orders_incoming AS s
WHERE TRY_CONVERT(INT, s.store_id_raw) IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM retail.stores AS st
      WHERE st.store_id = TRY_CONVERT(INT, s.store_id_raw)
  )
ORDER BY s.ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 181
-------------------------------------------------------------------------------
-- Unsupported `change_type_raw`.

-- OUTPUT GRAIN:
-- one row per incoming order with an unsupported change type

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    change_type_raw
FROM staging.orders_incoming
WHERE change_type_raw IS NULL
   OR UPPER(LTRIM(RTRIM(change_type_raw))) NOT IN (N'UPSERT', N'DELETE')
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 182
-------------------------------------------------------------------------------
-- Produce a single order-quality summary using `UNION ALL`.

-- OUTPUT GRAIN:
-- one row per order-quality check

-- REFERENCE SOLUTION:
DECLARE @as_of_date DATE = '2026-08-15';

SELECT N'missing_or_blank_order_key' AS check_name, COUNT_BIG(*) AS failure_count
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NULL
UNION ALL
SELECT N'malformed_order_id', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, source_order_id_raw) IS NULL
UNION ALL
SELECT N'malformed_customer_id', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE customer_id_raw IS NOT NULL
  AND NULLIF(LTRIM(RTRIM(customer_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, customer_id_raw) IS NULL
UNION ALL
SELECT N'malformed_store_id', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(store_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, store_id_raw) IS NULL
UNION ALL
SELECT N'malformed_order_date', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(order_date_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(DATETIME2(0), order_date_raw) IS NULL
UNION ALL
SELECT N'future_order_date', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE TRY_CONVERT(DATETIME2(0), order_date_raw)
      >= DATEADD(DAY, 1, CAST(@as_of_date AS DATETIME2(0)))
UNION ALL
SELECT N'invalid_status', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE status_raw IS NULL
   OR status_raw NOT IN
      (N'Processing', N'Shipped', N'Completed', N'Cancelled', N'Refunded')
UNION ALL
SELECT N'invalid_sales_channel', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE sales_channel_raw IS NULL
   OR sales_channel_raw NOT IN (N'Online', N'InStore')
UNION ALL
SELECT N'orphan_customer', COUNT_BIG(*)
FROM staging.orders_incoming AS s
WHERE s.customer_id_raw IS NOT NULL
  AND TRY_CONVERT(INT, s.customer_id_raw) IS NOT NULL
  AND NOT EXISTS
      (SELECT 1 FROM retail.customers AS c
       WHERE c.customer_id = TRY_CONVERT(INT, s.customer_id_raw))
UNION ALL
SELECT N'orphan_store', COUNT_BIG(*)
FROM staging.orders_incoming AS s
WHERE TRY_CONVERT(INT, s.store_id_raw) IS NOT NULL
  AND NOT EXISTS
      (SELECT 1 FROM retail.stores AS st
       WHERE st.store_id = TRY_CONVERT(INT, s.store_id_raw))
UNION ALL
SELECT N'unsupported_change_type', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE change_type_raw IS NULL
   OR UPPER(LTRIM(RTRIM(change_type_raw))) NOT IN (N'UPSERT', N'DELETE');

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- S. Data Quality — Order Items
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 183
-------------------------------------------------------------------------------
-- Missing line number.

-- OUTPUT GRAIN:
-- one row per incoming item with a missing/blank line number

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(line_number_raw)), N'') IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 184
-------------------------------------------------------------------------------
-- Malformed line number.

-- OUTPUT GRAIN:
-- one row per incoming item with a malformed nonblank line number

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(line_number_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, line_number_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 185
-------------------------------------------------------------------------------
-- Zero quantity.

-- OUTPUT GRAIN:
-- one row per incoming item with zero quantity

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw,
    quantity_raw
FROM staging.order_items_incoming
WHERE TRY_CONVERT(INT, quantity_raw) = 0
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 186
-------------------------------------------------------------------------------
-- Negative quantity.

-- OUTPUT GRAIN:
-- one row per incoming item with negative quantity

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw,
    quantity_raw
FROM staging.order_items_incoming
WHERE TRY_CONVERT(INT, quantity_raw) < 0
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 187
-------------------------------------------------------------------------------
-- Malformed quantity.

-- OUTPUT GRAIN:
-- one row per incoming item with malformed nonblank quantity

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw,
    quantity_raw
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(quantity_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, quantity_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 188
-------------------------------------------------------------------------------
-- Negative unit price.

-- OUTPUT GRAIN:
-- one row per incoming item with negative unit price

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw,
    unit_price_raw
FROM staging.order_items_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), unit_price_raw) < 0
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 189
-------------------------------------------------------------------------------
-- Malformed unit price.

-- OUTPUT GRAIN:
-- one row per incoming item with malformed nonblank unit price

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw,
    unit_price_raw
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(unit_price_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), unit_price_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 190
-------------------------------------------------------------------------------
-- Negative discount.

-- OUTPUT GRAIN:
-- one row per incoming item with negative discount

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw,
    discount_amount_raw
FROM staging.order_items_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), discount_amount_raw) < 0
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 191
-------------------------------------------------------------------------------
-- Discount greater than gross line value.

-- OUTPUT GRAIN:
-- one row per incoming item whose discount exceeds gross line value

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    source_order_id_raw,
    line_number_raw,
    quantity_raw,
    unit_price_raw,
    discount_amount_raw
FROM staging.order_items_incoming
WHERE TRY_CONVERT(INT, quantity_raw) > 0
  AND TRY_CONVERT(DECIMAL(10,2), unit_price_raw) >= 0
  AND TRY_CONVERT(DECIMAL(10,2), discount_amount_raw)
      > TRY_CONVERT(INT, quantity_raw)
        * TRY_CONVERT(DECIMAL(10,2), unit_price_raw)
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 192
-------------------------------------------------------------------------------
-- Orphan products.

-- OUTPUT GRAIN:
-- one row per incoming item with a numeric product ID absent from retail.products

-- REFERENCE SOLUTION:
SELECT
    i.ingestion_id,
    i.source_order_id_raw,
    i.line_number_raw,
    i.product_id_raw
FROM staging.order_items_incoming AS i
WHERE TRY_CONVERT(INT, i.product_id_raw) IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM retail.products AS p
      WHERE p.product_id = TRY_CONVERT(INT, i.product_id_raw)
  )
ORDER BY i.ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 193
-------------------------------------------------------------------------------
-- Orphan source orders.

-- OUTPUT GRAIN:
-- one row per incoming item whose numeric source order ID is absent from incoming orders

-- REFERENCE SOLUTION:
SELECT
    i.ingestion_id,
    i.source_order_id_raw,
    i.line_number_raw
FROM staging.order_items_incoming AS i
WHERE TRY_CONVERT(INT, i.source_order_id_raw) IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM staging.orders_incoming AS o
      WHERE TRY_CONVERT(INT, o.source_order_id_raw)
            = TRY_CONVERT(INT, i.source_order_id_raw)
  )
ORDER BY i.ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 194
-------------------------------------------------------------------------------
-- Duplicate composite `(order,line)` keys.

-- OUTPUT GRAIN:
-- one row per duplicated valid (source_order_id, line_number) composite key

-- REFERENCE SOLUTION:
SELECT
    TRY_CONVERT(INT, source_order_id_raw) AS source_order_id,
    TRY_CONVERT(INT, line_number_raw) AS line_number,
    COUNT(*) AS version_count
FROM staging.order_items_incoming
WHERE TRY_CONVERT(INT, source_order_id_raw) IS NOT NULL
  AND TRY_CONVERT(INT, line_number_raw) IS NOT NULL
GROUP BY
    TRY_CONVERT(INT, source_order_id_raw),
    TRY_CONVERT(INT, line_number_raw)
HAVING COUNT(*) > 1
ORDER BY source_order_id, line_number;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 195
-------------------------------------------------------------------------------
-- Produce an item-quality summary.

-- OUTPUT GRAIN:
-- one row per item-quality check

-- REFERENCE SOLUTION:
SELECT N'missing_line_number' AS check_name, COUNT_BIG(*) AS failure_count
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(line_number_raw)), N'') IS NULL
UNION ALL
SELECT N'malformed_line_number', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(line_number_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, line_number_raw) IS NULL
UNION ALL
SELECT N'zero_quantity', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE TRY_CONVERT(INT, quantity_raw) = 0
UNION ALL
SELECT N'negative_quantity', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE TRY_CONVERT(INT, quantity_raw) < 0
UNION ALL
SELECT N'malformed_quantity', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(quantity_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, quantity_raw) IS NULL
UNION ALL
SELECT N'negative_unit_price', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), unit_price_raw) < 0
UNION ALL
SELECT N'malformed_unit_price', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(unit_price_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), unit_price_raw) IS NULL
UNION ALL
SELECT N'negative_discount', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), discount_amount_raw) < 0
UNION ALL
SELECT N'discount_above_gross', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE TRY_CONVERT(INT, quantity_raw) > 0
  AND TRY_CONVERT(DECIMAL(10,2), unit_price_raw) >= 0
  AND TRY_CONVERT(DECIMAL(10,2), discount_amount_raw)
      > TRY_CONVERT(INT, quantity_raw)
        * TRY_CONVERT(DECIMAL(10,2), unit_price_raw)
UNION ALL
SELECT N'orphan_product', COUNT_BIG(*)
FROM staging.order_items_incoming AS i
WHERE TRY_CONVERT(INT, i.product_id_raw) IS NOT NULL
  AND NOT EXISTS
      (SELECT 1 FROM retail.products AS p
       WHERE p.product_id = TRY_CONVERT(INT, i.product_id_raw))
UNION ALL
SELECT N'orphan_source_order', COUNT_BIG(*)
FROM staging.order_items_incoming AS i
WHERE TRY_CONVERT(INT, i.source_order_id_raw) IS NOT NULL
  AND NOT EXISTS
      (SELECT 1 FROM staging.orders_incoming AS o
       WHERE TRY_CONVERT(INT, o.source_order_id_raw)
             = TRY_CONVERT(INT, i.source_order_id_raw))
UNION ALL
SELECT N'duplicate_order_line_key', COUNT_BIG(*)
FROM
(
    SELECT
        TRY_CONVERT(INT, source_order_id_raw) AS source_order_id,
        TRY_CONVERT(INT, line_number_raw) AS line_number
    FROM staging.order_items_incoming
    WHERE TRY_CONVERT(INT, source_order_id_raw) IS NOT NULL
      AND TRY_CONVERT(INT, line_number_raw) IS NOT NULL
    GROUP BY
        TRY_CONVERT(INT, source_order_id_raw),
        TRY_CONVERT(INT, line_number_raw)
    HAVING COUNT(*) > 1
) AS d;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- T. Data Quality — Products / Customers / Inventory
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 196
-------------------------------------------------------------------------------
-- Duplicate incoming SKUs.

-- OUTPUT GRAIN:
-- one row per duplicated nonblank normalized incoming SKU

-- REFERENCE SOLUTION:
SELECT
    LTRIM(RTRIM(sku_raw)) AS sku,
    COUNT(*) AS row_count
FROM staging.products_incoming
WHERE NULLIF(LTRIM(RTRIM(sku_raw)), N'') IS NOT NULL
GROUP BY LTRIM(RTRIM(sku_raw))
HAVING COUNT(*) > 1
ORDER BY sku;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 197
-------------------------------------------------------------------------------
-- Negative product cost.

-- OUTPUT GRAIN:
-- one row per incoming product with negative converted cost

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    product_id_raw,
    unit_cost_raw
FROM staging.products_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) < 0
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 198
-------------------------------------------------------------------------------
-- Negative product price.

-- OUTPUT GRAIN:
-- one row per incoming product with negative converted price

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    product_id_raw,
    list_price_raw
FROM staging.products_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), list_price_raw) < 0
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 199
-------------------------------------------------------------------------------
-- Product cost greater than list price.

-- OUTPUT GRAIN:
-- one row per incoming product whose converted cost exceeds converted list price

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    product_id_raw,
    unit_cost_raw,
    list_price_raw
FROM staging.products_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), unit_cost_raw)
      > TRY_CONVERT(DECIMAL(10,2), list_price_raw)
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 200
-------------------------------------------------------------------------------
-- Malformed product cost.

-- OUTPUT GRAIN:
-- one row per incoming product with malformed nonblank cost

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    product_id_raw,
    unit_cost_raw
FROM staging.products_incoming
WHERE NULLIF(LTRIM(RTRIM(unit_cost_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 201
-------------------------------------------------------------------------------
-- Missing product business key.

-- OUTPUT GRAIN:
-- one row per incoming product with a missing/blank business key

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    product_id_raw,
    sku_raw,
    product_name_raw
FROM staging.products_incoming
WHERE NULLIF(LTRIM(RTRIM(product_id_raw)), N'') IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 202
-------------------------------------------------------------------------------
-- Duplicate incoming customer emails ignoring NULL/blank.

-- OUTPUT GRAIN:
-- one row per duplicated normalized nonblank incoming customer email

-- REFERENCE SOLUTION:
SELECT
    LOWER(LTRIM(RTRIM(email_raw))) AS normalized_email,
    COUNT(*) AS row_count
FROM staging.customers_incoming
WHERE NULLIF(LTRIM(RTRIM(email_raw)), N'') IS NOT NULL
GROUP BY LOWER(LTRIM(RTRIM(email_raw)))
HAVING COUNT(*) > 1
ORDER BY normalized_email;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 203
-------------------------------------------------------------------------------
-- Invalid customer provinces.

-- OUTPUT GRAIN:
-- one row per incoming customer with an invalid province

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    customer_id_raw,
    province_raw
FROM staging.customers_incoming
WHERE province_raw IS NULL
   OR UPPER(LTRIM(RTRIM(province_raw))) NOT IN
      (N'AB',N'BC',N'MB',N'NB',N'NL',N'NS',N'NT',N'NU',N'ON',N'PE',N'QC',N'SK',N'YT')
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 204
-------------------------------------------------------------------------------
-- Invalid loyalty tiers.

-- OUTPUT GRAIN:
-- one row per incoming customer with an invalid nonblank loyalty tier

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    customer_id_raw,
    loyalty_tier_raw
FROM staging.customers_incoming
WHERE NULLIF(LTRIM(RTRIM(loyalty_tier_raw)), N'') IS NOT NULL
  AND loyalty_tier_raw NOT IN (N'Bronze', N'Silver', N'Gold')
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 205
-------------------------------------------------------------------------------
-- Malformed customer signup dates.

-- OUTPUT GRAIN:
-- one row per incoming customer with a missing or malformed signup date

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    customer_id_raw,
    signup_date_raw
FROM staging.customers_incoming
WHERE NULLIF(LTRIM(RTRIM(signup_date_raw)), N'') IS NULL
   OR TRY_CONVERT(DATE, signup_date_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 206
-------------------------------------------------------------------------------
-- Negative incoming inventory quantity.

-- OUTPUT GRAIN:
-- one row per incoming inventory row with negative on-hand quantity

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    store_id_raw,
    product_id_raw,
    on_hand_qty_raw
FROM staging.inventory_incoming
WHERE TRY_CONVERT(INT, on_hand_qty_raw) < 0
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 207
-------------------------------------------------------------------------------
-- Malformed incoming inventory quantity.

-- OUTPUT GRAIN:
-- one row per incoming inventory row with malformed nonblank on-hand quantity

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    store_id_raw,
    product_id_raw,
    on_hand_qty_raw
FROM staging.inventory_incoming
WHERE NULLIF(LTRIM(RTRIM(on_hand_qty_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, on_hand_qty_raw) IS NULL
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 208
-------------------------------------------------------------------------------
-- Negative reorder point.

-- OUTPUT GRAIN:
-- one row per incoming inventory row with negative reorder point

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    store_id_raw,
    product_id_raw,
    reorder_point_raw
FROM staging.inventory_incoming
WHERE TRY_CONVERT(INT, reorder_point_raw) < 0
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 209
-------------------------------------------------------------------------------
-- Orphan inventory store/product references.

-- OUTPUT GRAIN:
-- one row per incoming inventory row with an orphan numeric store and/or product reference

-- REFERENCE SOLUTION:
SELECT
    i.ingestion_id,
    i.store_id_raw,
    i.product_id_raw,
    CASE
        WHEN TRY_CONVERT(INT, i.store_id_raw) IS NOT NULL
         AND NOT EXISTS
             (SELECT 1 FROM retail.stores AS s
              WHERE s.store_id = TRY_CONVERT(INT, i.store_id_raw))
        THEN 1 ELSE 0
    END AS orphan_store_flag,
    CASE
        WHEN TRY_CONVERT(INT, i.product_id_raw) IS NOT NULL
         AND NOT EXISTS
             (SELECT 1 FROM retail.products AS p
              WHERE p.product_id = TRY_CONVERT(INT, i.product_id_raw))
        THEN 1 ELSE 0
    END AS orphan_product_flag
FROM staging.inventory_incoming AS i
WHERE
    (TRY_CONVERT(INT, i.store_id_raw) IS NOT NULL
     AND NOT EXISTS
         (SELECT 1 FROM retail.stores AS s
          WHERE s.store_id = TRY_CONVERT(INT, i.store_id_raw)))
 OR (TRY_CONVERT(INT, i.product_id_raw) IS NOT NULL
     AND NOT EXISTS
         (SELECT 1 FROM retail.products AS p
          WHERE p.product_id = TRY_CONVERT(INT, i.product_id_raw)))
ORDER BY i.ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 210
-------------------------------------------------------------------------------
-- Duplicate inventory snapshots.

-- OUTPUT GRAIN:
-- one row per duplicated valid inventory snapshot business key

-- REFERENCE SOLUTION:
SELECT
    TRY_CONVERT(INT, store_id_raw) AS store_id,
    TRY_CONVERT(INT, product_id_raw) AS product_id,
    TRY_CONVERT(DATE, snapshot_date_raw) AS snapshot_date,
    COUNT(*) AS version_count
FROM staging.inventory_incoming
WHERE TRY_CONVERT(INT, store_id_raw) IS NOT NULL
  AND TRY_CONVERT(INT, product_id_raw) IS NOT NULL
  AND TRY_CONVERT(DATE, snapshot_date_raw) IS NOT NULL
GROUP BY
    TRY_CONVERT(INT, store_id_raw),
    TRY_CONVERT(INT, product_id_raw),
    TRY_CONVERT(DATE, snapshot_date_raw)
HAVING COUNT(*) > 1
ORDER BY store_id, product_id, snapshot_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 211
-------------------------------------------------------------------------------
-- Build a cross-entity quality-check summary with at least 15 checks.

-- OUTPUT GRAIN:
-- one row per cross-entity quality check

-- REFERENCE SOLUTION:
SELECT N'orders' AS entity, N'missing_order_key' AS check_name, COUNT_BIG(*) AS failure_count
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NULL
UNION ALL
SELECT N'orders', N'malformed_store_id', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(store_id_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, store_id_raw) IS NULL
UNION ALL
SELECT N'orders', N'malformed_order_date', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE NULLIF(LTRIM(RTRIM(order_date_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(DATETIME2(0), order_date_raw) IS NULL
UNION ALL
SELECT N'orders', N'invalid_status', COUNT_BIG(*)
FROM staging.orders_incoming
WHERE status_raw IS NULL
   OR status_raw NOT IN (N'Processing',N'Shipped',N'Completed',N'Cancelled',N'Refunded')
UNION ALL
SELECT N'orders', N'orphan_customer', COUNT_BIG(*)
FROM staging.orders_incoming AS o
WHERE o.customer_id_raw IS NOT NULL
  AND TRY_CONVERT(INT, o.customer_id_raw) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM retail.customers AS c
                  WHERE c.customer_id = TRY_CONVERT(INT, o.customer_id_raw))
UNION ALL
SELECT N'order_items', N'missing_line_number', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(line_number_raw)), N'') IS NULL
UNION ALL
SELECT N'order_items', N'nonpositive_quantity', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE TRY_CONVERT(INT, quantity_raw) <= 0
UNION ALL
SELECT N'order_items', N'malformed_quantity', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE NULLIF(LTRIM(RTRIM(quantity_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, quantity_raw) IS NULL
UNION ALL
SELECT N'order_items', N'invalid_unit_price', COUNT_BIG(*)
FROM staging.order_items_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), unit_price_raw) < 0
   OR (NULLIF(LTRIM(RTRIM(unit_price_raw)), N'') IS NOT NULL
       AND TRY_CONVERT(DECIMAL(10,2), unit_price_raw) IS NULL)
UNION ALL
SELECT N'order_items', N'orphan_product', COUNT_BIG(*)
FROM staging.order_items_incoming AS i
WHERE TRY_CONVERT(INT, i.product_id_raw) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM retail.products AS p
                  WHERE p.product_id = TRY_CONVERT(INT, i.product_id_raw))
UNION ALL
SELECT N'products', N'duplicate_sku', COUNT_BIG(*)
FROM
(
    SELECT LTRIM(RTRIM(sku_raw)) AS sku
    FROM staging.products_incoming
    WHERE NULLIF(LTRIM(RTRIM(sku_raw)), N'') IS NOT NULL
    GROUP BY LTRIM(RTRIM(sku_raw))
    HAVING COUNT(*) > 1
) AS d
UNION ALL
SELECT N'products', N'negative_cost', COUNT_BIG(*)
FROM staging.products_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) < 0
UNION ALL
SELECT N'products', N'negative_price', COUNT_BIG(*)
FROM staging.products_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), list_price_raw) < 0
UNION ALL
SELECT N'products', N'cost_above_price', COUNT_BIG(*)
FROM staging.products_incoming
WHERE TRY_CONVERT(DECIMAL(10,2), unit_cost_raw)
      > TRY_CONVERT(DECIMAL(10,2), list_price_raw)
UNION ALL
SELECT N'products', N'malformed_cost', COUNT_BIG(*)
FROM staging.products_incoming
WHERE NULLIF(LTRIM(RTRIM(unit_cost_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) IS NULL
UNION ALL
SELECT N'customers', N'duplicate_email', COUNT_BIG(*)
FROM
(
    SELECT LOWER(LTRIM(RTRIM(email_raw))) AS email
    FROM staging.customers_incoming
    WHERE NULLIF(LTRIM(RTRIM(email_raw)), N'') IS NOT NULL
    GROUP BY LOWER(LTRIM(RTRIM(email_raw)))
    HAVING COUNT(*) > 1
) AS e
UNION ALL
SELECT N'customers', N'invalid_province', COUNT_BIG(*)
FROM staging.customers_incoming
WHERE province_raw IS NULL
   OR UPPER(LTRIM(RTRIM(province_raw))) NOT IN
      (N'AB',N'BC',N'MB',N'NB',N'NL',N'NS',N'NT',N'NU',N'ON',N'PE',N'QC',N'SK',N'YT')
UNION ALL
SELECT N'customers', N'invalid_loyalty_tier', COUNT_BIG(*)
FROM staging.customers_incoming
WHERE NULLIF(LTRIM(RTRIM(loyalty_tier_raw)), N'') IS NOT NULL
  AND loyalty_tier_raw NOT IN (N'Bronze',N'Silver',N'Gold')
UNION ALL
SELECT N'inventory', N'negative_on_hand', COUNT_BIG(*)
FROM staging.inventory_incoming
WHERE TRY_CONVERT(INT, on_hand_qty_raw) < 0
UNION ALL
SELECT N'inventory', N'malformed_on_hand', COUNT_BIG(*)
FROM staging.inventory_incoming
WHERE NULLIF(LTRIM(RTRIM(on_hand_qty_raw)), N'') IS NOT NULL
  AND TRY_CONVERT(INT, on_hand_qty_raw) IS NULL
UNION ALL
SELECT N'inventory', N'negative_reorder_point', COUNT_BIG(*)
FROM staging.inventory_incoming
WHERE TRY_CONVERT(INT, reorder_point_raw) < 0;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- U. Grain / Keys / Relational Design
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 212
-------------------------------------------------------------------------------
-- State the grain of every `retail.*` table.

-- OUTPUT GRAIN:
-- one row per retail table

-- REFERENCE SOLUTION:
SELECT table_name, table_grain
FROM
(
    VALUES
        (N'retail.customers', N'one row per customer'),
        (N'retail.stores', N'one row per store'),
        (N'retail.products', N'one row per product'),
        (N'retail.orders', N'one row per order'),
        (N'retail.order_items', N'one row per order line: (order_id, line_number)'),
        (N'retail.inventory_snapshots', N'one row per store/product/snapshot date')
) AS g(table_name, table_grain)
ORDER BY table_name;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 213
-------------------------------------------------------------------------------
-- State the grain of every `staging.*_incoming` table.

-- OUTPUT GRAIN:
-- one row per staging *_incoming table

-- REFERENCE SOLUTION:
SELECT table_name, table_grain
FROM
(
    VALUES
        (N'staging.customers_incoming', N'one row per ingested customer source record/version'),
        (N'staging.products_incoming', N'one row per ingested product source record/version'),
        (N'staging.orders_incoming', N'one row per ingested order source record/version'),
        (N'staging.order_items_incoming', N'one row per ingested order-item source record/version'),
        (N'staging.inventory_incoming', N'one row per ingested inventory source record/version')
) AS g(table_name, table_grain)
ORDER BY table_name;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 214
-------------------------------------------------------------------------------
-- Identify all primary keys.

-- OUTPUT GRAIN:
-- one row per primary-key constraint in retail or staging

-- REFERENCE SOLUTION:
SELECT
    s.name AS schema_name,
    t.name AS table_name,
    kc.name AS primary_key_name,
    STRING_AGG(c.name, N', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS key_columns
FROM sys.key_constraints AS kc
INNER JOIN sys.tables AS t
    ON t.object_id = kc.parent_object_id
INNER JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
INNER JOIN sys.index_columns AS ic
    ON ic.object_id = kc.parent_object_id
   AND ic.index_id = kc.unique_index_id
INNER JOIN sys.columns AS c
    ON c.object_id = ic.object_id
   AND c.column_id = ic.column_id
WHERE kc.type = N'PK'
  AND s.name IN (N'retail', N'staging')
GROUP BY s.name, t.name, kc.name
ORDER BY s.name, t.name;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 215
-------------------------------------------------------------------------------
-- Explain why `retail.order_items` has a composite key.

-- OUTPUT GRAIN:
-- conceptual answer; no row-producing grain

-- REFERENCE SOLUTION:
-- retail.order_items is one row per line within an order. line_number is only
-- unique inside its parent order, while order_id repeats across all lines in that
-- order. Therefore neither column alone identifies a row; the composite
-- (order_id, line_number) key matches the table's declared grain.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 216
-------------------------------------------------------------------------------
-- Explain why inventory uses `(store_id, product_id, snapshot_date)`.

-- OUTPUT GRAIN:
-- conceptual answer; no row-producing grain

-- REFERENCE SOLUTION:
-- Inventory is a periodic snapshot. A store can carry the same product on many
-- dates, and a product can appear in many stores on the same date. The complete
-- grain is therefore one row per (store_id, product_id, snapshot_date), which is
-- also the natural composite primary key.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 217
-------------------------------------------------------------------------------
-- Identify foreign-key relationships in the clean model.

-- OUTPUT GRAIN:
-- one row per foreign-key relationship in the retail schema

-- REFERENCE SOLUTION:
SELECT
    fk.name AS foreign_key_name,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) + N'.' + OBJECT_NAME(fk.parent_object_id)
        AS child_table,
    pc.name AS child_column,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) + N'.' + OBJECT_NAME(fk.referenced_object_id)
        AS parent_table,
    rc.name AS parent_column
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc
    ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.columns AS pc
    ON pc.object_id = fkc.parent_object_id
   AND pc.column_id = fkc.parent_column_id
INNER JOIN sys.columns AS rc
    ON rc.object_id = fkc.referenced_object_id
   AND rc.column_id = fkc.referenced_column_id
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = N'retail'
ORDER BY child_table, foreign_key_name, fkc.constraint_column_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 218
-------------------------------------------------------------------------------
-- Explain why raw incoming tables intentionally do not enforce those foreign keys.

-- OUTPUT GRAIN:
-- conceptual answer; no row-producing grain

-- REFERENCE SOLUTION:
-- staging.*_incoming models data before validation. It intentionally accepts
-- malformed strings, missing keys, and orphan references so source defects remain
-- observable and can be quarantined. Enforcing clean-model foreign keys there
-- would reject those rows during ingestion and hide the evidence needed for data
-- quality diagnostics and controlled recovery.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 219
-------------------------------------------------------------------------------
-- Explain natural versus surrogate keys using `sku` and a future `product_key`.

-- OUTPUT GRAIN:
-- conceptual answer; no row-producing grain

-- REFERENCE SOLUTION:
-- sku is a natural/business key: it comes from the business/source domain and
-- has meaning outside the warehouse. A future product_key is a surrogate key:
-- a warehouse-generated identifier with no business meaning. Surrogate keys
-- decouple warehouse relationships from mutable source keys and enable multiple
-- historical dimension versions (for example SCD Type 2) for one source product.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 220
-------------------------------------------------------------------------------
-- Explain why fact-table grain must be defined before choosing measures.

-- OUTPUT GRAIN:
-- conceptual answer; no row-producing grain

-- REFERENCE SOLUTION:
-- Grain defines exactly what one fact row represents. Only after that can you
-- decide whether a measure is valid and additive at that level. If the grain is
-- ambiguous, measures such as revenue or order count can be duplicated when rows
-- are joined or aggregated, producing numerically plausible but incorrect facts.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- V. DDL — Executable
-- ==============================================================================

-- Perform these in a new schema called `practice_dw`.

-------------------------------------------------------------------------------
-- PROBLEM 221
-------------------------------------------------------------------------------
-- `CREATE SCHEMA practice_dw`.

-- OUTPUT GRAIN:
-- DDL operation; creates at most one schema

-- REFERENCE SOLUTION:
IF SCHEMA_ID(N'practice_dw') IS NULL
    EXEC(N'CREATE SCHEMA practice_dw AUTHORIZATION dbo;');

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 222
-------------------------------------------------------------------------------
-- Create `practice_dw.dim_store` with an `IDENTITY` surrogate key.

-- OUTPUT GRAIN:
-- DDL operation; creates one dimension table

-- REFERENCE SOLUTION:
IF OBJECT_ID(N'practice_dw.dim_store', N'U') IS NULL
BEGIN
    CREATE TABLE practice_dw.dim_store
    (
        store_key    INT IDENTITY(1,1) NOT NULL,
        store_id     INT NULL,
        store_name   NVARCHAR(100) NULL,
        city         NVARCHAR(100) NULL,
        province     CHAR(2) NULL,
        opened_date  DATE NULL
    );
END;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 223
-------------------------------------------------------------------------------
-- Create `practice_dw.dim_product`.

-- OUTPUT GRAIN:
-- DDL operation; creates one dimension table

-- REFERENCE SOLUTION:
IF OBJECT_ID(N'practice_dw.dim_product', N'U') IS NULL
BEGIN
    CREATE TABLE practice_dw.dim_product
    (
        product_key   INT IDENTITY(1,1) NOT NULL,
        product_id    INT NULL,
        sku           NVARCHAR(30) NULL,
        product_name  NVARCHAR(150) NULL,
        category      NVARCHAR(50) NULL,
        unit_cost     DECIMAL(10,2) NULL,
        list_price    DECIMAL(10,2) NULL,
        active_flag   BIT NULL
    );
END;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 224
-------------------------------------------------------------------------------
-- Create `practice_dw.dim_customer`.

-- OUTPUT GRAIN:
-- DDL operation; creates one dimension table

-- REFERENCE SOLUTION:
IF OBJECT_ID(N'practice_dw.dim_customer', N'U') IS NULL
BEGIN
    CREATE TABLE practice_dw.dim_customer
    (
        customer_key   INT IDENTITY(1,1) NOT NULL,
        customer_id    INT NULL,
        customer_name  NVARCHAR(100) NULL,
        email          NVARCHAR(255) NULL,
        province       CHAR(2) NULL,
        signup_date    DATE NULL,
        loyalty_tier   NVARCHAR(20) NULL
    );
END;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 225
-------------------------------------------------------------------------------
-- Create `practice_dw.dim_date`.

-- OUTPUT GRAIN:
-- DDL operation; creates one dimension table

-- REFERENCE SOLUTION:
IF OBJECT_ID(N'practice_dw.dim_date', N'U') IS NULL
BEGIN
    CREATE TABLE practice_dw.dim_date
    (
        date_key       INT NOT NULL,
        full_date      DATE NULL,
        calendar_year  SMALLINT NULL,
        calendar_month TINYINT NULL,
        month_name     NVARCHAR(20) NULL,
        calendar_day   TINYINT NULL
    );
END;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 226
-------------------------------------------------------------------------------
-- Create `practice_dw.fact_sales` at one row per order line.

-- OUTPUT GRAIN:
-- DDL operation; creates one fact table at order-line grain

-- REFERENCE SOLUTION:
IF OBJECT_ID(N'practice_dw.fact_sales', N'U') IS NULL
BEGIN
    CREATE TABLE practice_dw.fact_sales
    (
        sales_key        BIGINT IDENTITY(1,1) NOT NULL,
        order_id         INT NULL,
        line_number      INT NULL,
        date_key         INT NULL,
        store_key        INT NULL,
        product_key      INT NULL,
        customer_key     INT NULL,
        quantity         INT NULL,
        unit_price       DECIMAL(10,2) NULL,
        discount_amount  DECIMAL(10,2) NULL
    );
END;

-- Declared fact grain: one row per source order line (order_id, line_number).

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 227
-------------------------------------------------------------------------------
-- Add appropriate primary keys.

-- OUTPUT GRAIN:
-- DDL operations; one primary key per practice dimension/fact table

-- REFERENCE SOLUTION:
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK_practice_dim_store')
    ALTER TABLE practice_dw.dim_store
        ADD CONSTRAINT PK_practice_dim_store PRIMARY KEY (store_key);

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK_practice_dim_product')
    ALTER TABLE practice_dw.dim_product
        ADD CONSTRAINT PK_practice_dim_product PRIMARY KEY (product_key);

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK_practice_dim_customer')
    ALTER TABLE practice_dw.dim_customer
        ADD CONSTRAINT PK_practice_dim_customer PRIMARY KEY (customer_key);

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK_practice_dim_date')
    ALTER TABLE practice_dw.dim_date
        ADD CONSTRAINT PK_practice_dim_date PRIMARY KEY (date_key);

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'PK_practice_fact_sales')
    ALTER TABLE practice_dw.fact_sales
        ADD CONSTRAINT PK_practice_fact_sales PRIMARY KEY (sales_key);

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 228
-------------------------------------------------------------------------------
-- Add foreign keys from fact to dimensions.

-- OUTPUT GRAIN:
-- DDL operations; foreign keys from fact_sales to dimensions

-- REFERENCE SOLUTION:
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_practice_fact_sales_date')
    ALTER TABLE practice_dw.fact_sales
        ADD CONSTRAINT FK_practice_fact_sales_date
        FOREIGN KEY (date_key) REFERENCES practice_dw.dim_date(date_key);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_practice_fact_sales_store')
    ALTER TABLE practice_dw.fact_sales
        ADD CONSTRAINT FK_practice_fact_sales_store
        FOREIGN KEY (store_key) REFERENCES practice_dw.dim_store(store_key);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_practice_fact_sales_product')
    ALTER TABLE practice_dw.fact_sales
        ADD CONSTRAINT FK_practice_fact_sales_product
        FOREIGN KEY (product_key) REFERENCES practice_dw.dim_product(product_key);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_practice_fact_sales_customer')
    ALTER TABLE practice_dw.fact_sales
        ADD CONSTRAINT FK_practice_fact_sales_customer
        FOREIGN KEY (customer_key) REFERENCES practice_dw.dim_customer(customer_key);

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 229
-------------------------------------------------------------------------------
-- Add `NOT NULL` constraints where appropriate.

-- OUTPUT GRAIN:
-- DDL operations; required business attributes and fact columns become NOT NULL

-- REFERENCE SOLUTION:
-- customer_key remains nullable in the fact so guest orders can be represented.
ALTER TABLE practice_dw.dim_store ALTER COLUMN store_id INT NOT NULL;
ALTER TABLE practice_dw.dim_store ALTER COLUMN store_name NVARCHAR(100) NOT NULL;
ALTER TABLE practice_dw.dim_store ALTER COLUMN city NVARCHAR(100) NOT NULL;
ALTER TABLE practice_dw.dim_store ALTER COLUMN province CHAR(2) NOT NULL;
ALTER TABLE practice_dw.dim_store ALTER COLUMN opened_date DATE NOT NULL;

ALTER TABLE practice_dw.dim_product ALTER COLUMN product_id INT NOT NULL;
ALTER TABLE practice_dw.dim_product ALTER COLUMN sku NVARCHAR(30) NOT NULL;
ALTER TABLE practice_dw.dim_product ALTER COLUMN product_name NVARCHAR(150) NOT NULL;
ALTER TABLE practice_dw.dim_product ALTER COLUMN category NVARCHAR(50) NOT NULL;
ALTER TABLE practice_dw.dim_product ALTER COLUMN unit_cost DECIMAL(10,2) NOT NULL;
ALTER TABLE practice_dw.dim_product ALTER COLUMN list_price DECIMAL(10,2) NOT NULL;
ALTER TABLE practice_dw.dim_product ALTER COLUMN active_flag BIT NOT NULL;

ALTER TABLE practice_dw.dim_customer ALTER COLUMN customer_id INT NOT NULL;
ALTER TABLE practice_dw.dim_customer ALTER COLUMN customer_name NVARCHAR(100) NOT NULL;
ALTER TABLE practice_dw.dim_customer ALTER COLUMN province CHAR(2) NOT NULL;
ALTER TABLE practice_dw.dim_customer ALTER COLUMN signup_date DATE NOT NULL;

ALTER TABLE practice_dw.dim_date ALTER COLUMN full_date DATE NOT NULL;
ALTER TABLE practice_dw.dim_date ALTER COLUMN calendar_year SMALLINT NOT NULL;
ALTER TABLE practice_dw.dim_date ALTER COLUMN calendar_month TINYINT NOT NULL;
ALTER TABLE practice_dw.dim_date ALTER COLUMN month_name NVARCHAR(20) NOT NULL;
ALTER TABLE practice_dw.dim_date ALTER COLUMN calendar_day TINYINT NOT NULL;

ALTER TABLE practice_dw.fact_sales ALTER COLUMN order_id INT NOT NULL;
ALTER TABLE practice_dw.fact_sales ALTER COLUMN line_number INT NOT NULL;
ALTER TABLE practice_dw.fact_sales ALTER COLUMN date_key INT NOT NULL;
ALTER TABLE practice_dw.fact_sales ALTER COLUMN store_key INT NOT NULL;
ALTER TABLE practice_dw.fact_sales ALTER COLUMN product_key INT NOT NULL;
ALTER TABLE practice_dw.fact_sales ALTER COLUMN quantity INT NOT NULL;
ALTER TABLE practice_dw.fact_sales ALTER COLUMN unit_price DECIMAL(10,2) NOT NULL;
ALTER TABLE practice_dw.fact_sales ALTER COLUMN discount_amount DECIMAL(10,2) NOT NULL;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 230
-------------------------------------------------------------------------------
-- Add `CHECK (quantity > 0)`.

-- OUTPUT GRAIN:
-- DDL operation; one CHECK constraint

-- REFERENCE SOLUTION:
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_practice_fact_sales_quantity')
    ALTER TABLE practice_dw.fact_sales
        ADD CONSTRAINT CK_practice_fact_sales_quantity CHECK (quantity > 0);

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 231
-------------------------------------------------------------------------------
-- Add `CHECK (unit_price >= 0)`.

-- OUTPUT GRAIN:
-- DDL operation; one CHECK constraint

-- REFERENCE SOLUTION:
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_practice_fact_sales_unit_price')
    ALTER TABLE practice_dw.fact_sales
        ADD CONSTRAINT CK_practice_fact_sales_unit_price CHECK (unit_price >= 0);

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 232
-------------------------------------------------------------------------------
-- Add a default load timestamp.

-- OUTPUT GRAIN:
-- DDL operation; adds one load timestamp column with a default

-- REFERENCE SOLUTION:
IF COL_LENGTH(N'practice_dw.fact_sales', N'load_timestamp') IS NULL
BEGIN
    ALTER TABLE practice_dw.fact_sales
        ADD load_timestamp DATETIME2(0) NOT NULL
            CONSTRAINT DF_practice_fact_sales_load_timestamp DEFAULT (SYSUTCDATETIME());
END;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 233
-------------------------------------------------------------------------------
-- Add a unique constraint on a natural/business key where appropriate.

-- OUTPUT GRAIN:
-- DDL operation; one unique business-key constraint

-- REFERENCE SOLUTION:
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_practice_dim_product_sku')
    ALTER TABLE practice_dw.dim_product
        ADD CONSTRAINT UQ_practice_dim_product_sku UNIQUE (sku);

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 234
-------------------------------------------------------------------------------
-- `ALTER TABLE` to add `load_batch_id BIGINT`.

-- OUTPUT GRAIN:
-- DDL operation; adds one nullable load batch column

-- REFERENCE SOLUTION:
IF COL_LENGTH(N'practice_dw.fact_sales', N'load_batch_id') IS NULL
    ALTER TABLE practice_dw.fact_sales ADD load_batch_id BIGINT NULL;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 235
-------------------------------------------------------------------------------
-- Create a nonclustered index supporting store/date fact lookups.

-- OUTPUT GRAIN:
-- DDL operation; creates one nonclustered index

-- REFERENCE SOLUTION:
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'practice_dw.fact_sales')
      AND name = N'IX_practice_fact_sales_store_date'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_practice_fact_sales_store_date
        ON practice_dw.fact_sales (store_key, date_key)
        INCLUDE (product_key, quantity, unit_price, discount_amount);
END;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 236
-------------------------------------------------------------------------------
-- Create a view exposing a simple sales mart.

-- OUTPUT GRAIN:
-- view grain: one row per fact_sales order line

-- REFERENCE SOLUTION:
CREATE OR ALTER VIEW practice_dw.vw_sales_mart
AS
SELECT
    f.sales_key,
    f.order_id,
    f.line_number,
    d.full_date AS sales_date,
    s.store_id,
    s.store_name,
    s.province AS store_province,
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    c.customer_id,
    c.customer_name,
    f.quantity,
    f.unit_price,
    f.discount_amount,
    f.quantity * f.unit_price AS gross_sales,
    (f.quantity * f.unit_price) - f.discount_amount AS net_sales,
    f.load_timestamp,
    f.load_batch_id
FROM practice_dw.fact_sales AS f
INNER JOIN practice_dw.dim_date AS d
    ON d.date_key = f.date_key
INNER JOIN practice_dw.dim_store AS s
    ON s.store_key = f.store_key
INNER JOIN practice_dw.dim_product AS p
    ON p.product_key = f.product_key
LEFT JOIN practice_dw.dim_customer AS c
    ON c.customer_key = f.customer_key;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 237
-------------------------------------------------------------------------------
-- Create and then drop a disposable practice table.

-- OUTPUT GRAIN:
-- DDL operation; disposable table exists only inside this batch

-- REFERENCE SOLUTION:
DROP TABLE IF EXISTS practice_dw.disposable_demo;

CREATE TABLE practice_dw.disposable_demo
(
    demo_id INT NOT NULL PRIMARY KEY,
    note NVARCHAR(100) NULL
);

INSERT INTO practice_dw.disposable_demo (demo_id, note)
VALUES (1, N'temporary row');

SELECT demo_id, note
FROM practice_dw.disposable_demo;

DROP TABLE practice_dw.disposable_demo;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 238
-------------------------------------------------------------------------------
-- Demonstrate `TRUNCATE TABLE` safely on a disposable table and explain `DELETE` vs `TRUNCATE` vs `DROP`.

-- OUTPUT GRAIN:
-- DDL/DML demonstration; disposable table is empty before being dropped

-- REFERENCE SOLUTION:
DROP TABLE IF EXISTS practice_dw.truncate_demo;

CREATE TABLE practice_dw.truncate_demo
(
    demo_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    note NVARCHAR(100) NULL
);

INSERT INTO practice_dw.truncate_demo (note)
VALUES (N'row 1'), (N'row 2'), (N'row 3');

TRUNCATE TABLE practice_dw.truncate_demo;

SELECT COUNT(*) AS rows_after_truncate
FROM practice_dw.truncate_demo;

DROP TABLE practice_dw.truncate_demo;

-- DELETE removes qualifying rows and can use WHERE; it is fully row-oriented DML.
-- TRUNCATE removes all rows from a table, cannot use WHERE, and typically uses
-- less logging while resetting an IDENTITY seed; it preserves the table itself.
-- DROP removes the table object, its data, and its metadata definition entirely.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- W. DML — Executable
-- ==============================================================================

-- Use only disposable/practice tables where destructive changes would affect seeded data.

-------------------------------------------------------------------------------
-- PROBLEM 239
-------------------------------------------------------------------------------
-- Insert one dimension row.

-- OUTPUT GRAIN:
-- DML operation; inserts at most one dimension row

-- REFERENCE SOLUTION:
IF NOT EXISTS (SELECT 1 FROM practice_dw.dim_store WHERE store_id = 9001)
BEGIN
    INSERT INTO practice_dw.dim_store
        (store_id, store_name, city, province, opened_date)
    VALUES
        (9001, N'DML Test Store', N'Toronto', 'ON', '2026-01-01');
END;

SELECT
    store_key,
    store_id,
    store_name,
    city,
    province,
    opened_date
FROM practice_dw.dim_store
WHERE store_id = 9001;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 240
-------------------------------------------------------------------------------
-- Insert multiple dimension rows.

-- OUTPUT GRAIN:
-- DML operation; inserts up to two dimension rows

-- REFERENCE SOLUTION:
INSERT INTO practice_dw.dim_customer
    (customer_id, customer_name, email, province, signup_date, loyalty_tier)
SELECT
    v.customer_id,
    v.customer_name,
    v.email,
    v.province,
    v.signup_date,
    v.loyalty_tier
FROM
(
    VALUES
        (9001, N'DML Test Customer A', N'test-a@example.ca', 'ON', CAST('2026-01-01' AS DATE), N'Bronze'),
        (9002, N'DML Test Customer B', N'test-b@example.ca', 'BC', CAST('2026-01-02' AS DATE), N'Silver')
) AS v(customer_id, customer_name, email, province, signup_date, loyalty_tier)
WHERE NOT EXISTS
(
    SELECT 1
    FROM practice_dw.dim_customer AS d
    WHERE d.customer_id = v.customer_id
);

SELECT
    customer_id,
    customer_name,
    province
FROM practice_dw.dim_customer
WHERE customer_id IN (9001, 9002)
ORDER BY customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 241
-------------------------------------------------------------------------------
-- Populate a dimension with `INSERT ... SELECT`.

-- OUTPUT GRAIN:
-- DML operation; one inserted row per retail product not already in dim_product

-- REFERENCE SOLUTION:
INSERT INTO practice_dw.dim_product
    (product_id, sku, product_name, category, unit_cost, list_price, active_flag)
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    p.unit_cost,
    p.list_price,
    p.active_flag
FROM retail.products AS p
WHERE NOT EXISTS
(
    SELECT 1
    FROM practice_dw.dim_product AS d
    WHERE d.product_id = p.product_id
);

SELECT COUNT(*) AS dim_product_row_count
FROM practice_dw.dim_product;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 242
-------------------------------------------------------------------------------
-- Update dimension attributes from a staging-derived dataset.

-- OUTPUT GRAIN:
-- DML operation; updates existing dimension rows with latest valid incoming product attributes

-- REFERENCE SOLUTION:
WITH typed AS
(
    SELECT
        ingestion_id,
        TRY_CONVERT(INT, product_id_raw) AS product_id,
        sku_raw AS sku,
        product_name_raw AS product_name,
        category_raw AS category,
        TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) AS unit_cost,
        TRY_CONVERT(DECIMAL(10,2), list_price_raw) AS list_price,
        TRY_CONVERT(BIT, active_flag_raw) AS active_flag,
        TRY_CONVERT(DATETIME2(0), modified_at_raw) AS modified_at,
        ingested_at,
        ROW_NUMBER() OVER
        (
            PARTITION BY TRY_CONVERT(INT, product_id_raw)
            ORDER BY
                TRY_CONVERT(DATETIME2(0), modified_at_raw) DESC,
                ingested_at DESC,
                ingestion_id DESC
        ) AS rn
    FROM staging.products_incoming
    WHERE TRY_CONVERT(INT, product_id_raw) IS NOT NULL
      AND TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) >= 0
      AND TRY_CONVERT(DECIMAL(10,2), list_price_raw) >= 0
      AND TRY_CONVERT(DECIMAL(10,2), unit_cost_raw)
            <= TRY_CONVERT(DECIMAL(10,2), list_price_raw)
      AND TRY_CONVERT(BIT, active_flag_raw) IS NOT NULL
      AND TRY_CONVERT(DATETIME2(0), modified_at_raw) IS NOT NULL
)
UPDATE d
SET
    d.product_name = s.product_name,
    d.category = s.category,
    d.unit_cost = s.unit_cost,
    d.list_price = s.list_price,
    d.active_flag = s.active_flag
FROM practice_dw.dim_product AS d
INNER JOIN typed AS s
    ON s.product_id = d.product_id
   AND s.rn = 1;

SELECT
    product_id,
    sku,
    product_name,
    category,
    unit_cost,
    list_price,
    active_flag
FROM practice_dw.dim_product
WHERE product_id IN (105, 114, 120)
ORDER BY product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 243
-------------------------------------------------------------------------------
-- Delete a deliberately inserted test row.

-- OUTPUT GRAIN:
-- DML operation; deletes the deliberately inserted test store row

-- REFERENCE SOLUTION:
DELETE FROM practice_dw.dim_store
WHERE store_id = 9001;

SELECT COUNT(*) AS remaining_test_rows
FROM practice_dw.dim_store
WHERE store_id = 9001;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 244
-------------------------------------------------------------------------------
-- Perform an `UPDATE` using a join.

-- OUTPUT GRAIN:
-- DML operation; updates matching dimension rows

-- REFERENCE SOLUTION:
UPDATE d
SET d.product_name = p.product_name
FROM practice_dw.dim_product AS d
INNER JOIN retail.products AS p
    ON p.product_id = d.product_id;

SELECT
    product_id,
    product_name
FROM practice_dw.dim_product
ORDER BY product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 245
-------------------------------------------------------------------------------
-- Perform a `DELETE` using `EXISTS`.

-- OUTPUT GRAIN:
-- DML operation; deletes matching disposable/test dimension rows

-- REFERENCE SOLUTION:
DELETE d
FROM practice_dw.dim_customer AS d
WHERE EXISTS
(
    SELECT 1
    FROM (VALUES (9001), (9002)) AS x(customer_id)
    WHERE x.customer_id = d.customer_id
);

SELECT COUNT(*) AS remaining_test_customer_rows
FROM practice_dw.dim_customer
WHERE customer_id IN (9001, 9002);

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 246
-------------------------------------------------------------------------------
-- Wrap an update in a transaction, inspect the result, then roll back.

-- OUTPUT GRAIN:
-- transaction demonstration; persistent table state is unchanged after ROLLBACK

-- REFERENCE SOLUTION:
SELECT product_id, list_price AS price_before
FROM practice_dw.dim_product
WHERE product_id = 105;

BEGIN TRANSACTION;

UPDATE practice_dw.dim_product
SET list_price = list_price + 1.00
WHERE product_id = 105;

SELECT product_id, list_price AS price_inside_transaction
FROM practice_dw.dim_product
WHERE product_id = 105;

ROLLBACK TRANSACTION;

SELECT product_id, list_price AS price_after_rollback
FROM practice_dw.dim_product
WHERE product_id = 105;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 247
-------------------------------------------------------------------------------
-- Insert only valid, deduplicated incoming orders into a clean practice table.

-- OUTPUT GRAIN:
-- one row per accepted, deduplicated incoming order business key

-- REFERENCE SOLUTION:
DROP TABLE IF EXISTS practice_dw.orders_clean;

CREATE TABLE practice_dw.orders_clean
(
    source_order_id INT NOT NULL PRIMARY KEY,
    customer_id INT NULL,
    store_id INT NOT NULL,
    order_date DATETIME2(0) NOT NULL,
    status NVARCHAR(20) NOT NULL,
    sales_channel NVARCHAR(20) NOT NULL,
    modified_at DATETIME2(0) NOT NULL,
    change_type NVARCHAR(20) NOT NULL,
    source_ingestion_id BIGINT NOT NULL,
    ingested_at DATETIME2(0) NOT NULL
);

WITH accepted_batches AS
(
    SELECT batch_id
    FROM
    (
        SELECT
            b.batch_id,
            ROW_NUMBER() OVER
            (
                PARTITION BY b.source_entity, b.file_checksum
                ORDER BY b.arrived_at, b.batch_id
            ) AS rn
        FROM staging.ingestion_batches AS b
        WHERE b.source_entity = N'orders'
    ) AS x
    WHERE rn = 1
),
typed AS
(
    SELECT
        s.ingestion_id,
        TRY_CONVERT(INT, s.source_order_id_raw) AS source_order_id,
        CASE WHEN s.customer_id_raw IS NULL THEN NULL
             ELSE TRY_CONVERT(INT, s.customer_id_raw) END AS customer_id,
        TRY_CONVERT(INT, s.store_id_raw) AS store_id,
        TRY_CONVERT(DATETIME2(0), s.order_date_raw) AS order_date,
        s.status_raw AS status,
        s.sales_channel_raw AS sales_channel,
        TRY_CONVERT(DATETIME2(0), s.modified_at_raw) AS modified_at,
        UPPER(LTRIM(RTRIM(s.change_type_raw))) AS change_type,
        s.ingested_at
    FROM staging.orders_incoming AS s
    INNER JOIN accepted_batches AS ab
        ON ab.batch_id = s.batch_id
),
valid AS
(
    SELECT t.*
    FROM typed AS t
    WHERE t.source_order_id IS NOT NULL
      AND t.store_id IS NOT NULL
      AND t.order_date IS NOT NULL
      AND t.order_date < '2026-08-16T00:00:00'
      AND t.status IN (N'Processing',N'Shipped',N'Completed',N'Cancelled',N'Refunded')
      AND t.sales_channel IN (N'Online',N'InStore')
      AND t.modified_at IS NOT NULL
      AND t.change_type IN (N'UPSERT',N'DELETE')
      AND EXISTS (SELECT 1 FROM retail.stores AS st WHERE st.store_id = t.store_id)
      AND (t.customer_id IS NULL
           OR EXISTS (SELECT 1 FROM retail.customers AS c WHERE c.customer_id = t.customer_id))
),
ranked AS
(
    SELECT
        v.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY v.source_order_id
            ORDER BY v.modified_at DESC, v.ingested_at DESC, v.ingestion_id DESC
        ) AS rn
    FROM valid AS v
)
INSERT INTO practice_dw.orders_clean
(
    source_order_id,
    customer_id,
    store_id,
    order_date,
    status,
    sales_channel,
    modified_at,
    change_type,
    source_ingestion_id,
    ingested_at
)
SELECT
    source_order_id,
    customer_id,
    store_id,
    order_date,
    status,
    sales_channel,
    modified_at,
    change_type,
    ingestion_id,
    ingested_at
FROM ranked
WHERE rn = 1;

SELECT
    source_order_id,
    customer_id,
    store_id,
    order_date,
    status,
    sales_channel,
    modified_at,
    change_type,
    source_ingestion_id,
    ingested_at
FROM practice_dw.orders_clean
ORDER BY source_order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 248
-------------------------------------------------------------------------------
-- Insert rejected rows into a reject table with `rejection_reason`.

-- OUTPUT GRAIN:
-- one row per rejected incoming order source row

-- REFERENCE SOLUTION:
DROP TABLE IF EXISTS practice_dw.orders_rejects;

CREATE TABLE practice_dw.orders_rejects
(
    ingestion_id BIGINT NOT NULL PRIMARY KEY,
    batch_id BIGINT NOT NULL,
    source_order_id_raw NVARCHAR(50) NULL,
    rejection_reason NVARCHAR(200) NOT NULL,
    rejected_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_practice_orders_rejects_rejected_at DEFAULT (SYSUTCDATETIME())
);

WITH accepted_batches AS
(
    SELECT batch_id
    FROM
    (
        SELECT
            b.batch_id,
            ROW_NUMBER() OVER
            (
                PARTITION BY b.source_entity, b.file_checksum
                ORDER BY b.arrived_at, b.batch_id
            ) AS rn
        FROM staging.ingestion_batches AS b
        WHERE b.source_entity = N'orders'
    ) AS x
    WHERE rn = 1
),
evaluated AS
(
    SELECT
        s.*,
        CASE
            WHEN NULLIF(LTRIM(RTRIM(s.source_order_id_raw)), N'') IS NULL
                THEN N'MISSING_ORDER_KEY'
            WHEN TRY_CONVERT(INT, s.source_order_id_raw) IS NULL
                THEN N'MALFORMED_ORDER_ID'
            WHEN s.customer_id_raw IS NOT NULL
             AND TRY_CONVERT(INT, s.customer_id_raw) IS NULL
                THEN N'MALFORMED_CUSTOMER_ID'
            WHEN TRY_CONVERT(INT, s.store_id_raw) IS NULL
                THEN N'MALFORMED_STORE_ID'
            WHEN TRY_CONVERT(DATETIME2(0), s.order_date_raw) IS NULL
                THEN N'MALFORMED_ORDER_DATE'
            WHEN TRY_CONVERT(DATETIME2(0), s.order_date_raw) >= '2026-08-16T00:00:00'
                THEN N'FUTURE_ORDER_DATE'
            WHEN s.status_raw NOT IN
                 (N'Processing',N'Shipped',N'Completed',N'Cancelled',N'Refunded')
                THEN N'INVALID_STATUS'
            WHEN s.sales_channel_raw NOT IN (N'Online',N'InStore')
                THEN N'INVALID_SALES_CHANNEL'
            WHEN TRY_CONVERT(DATETIME2(0), s.modified_at_raw) IS NULL
                THEN N'MALFORMED_MODIFIED_AT'
            WHEN UPPER(LTRIM(RTRIM(s.change_type_raw))) NOT IN (N'UPSERT',N'DELETE')
                THEN N'INVALID_CHANGE_TYPE'
            WHEN s.customer_id_raw IS NOT NULL
             AND TRY_CONVERT(INT, s.customer_id_raw) IS NOT NULL
             AND NOT EXISTS
                 (SELECT 1 FROM retail.customers AS c
                  WHERE c.customer_id = TRY_CONVERT(INT, s.customer_id_raw))
                THEN N'ORPHAN_CUSTOMER'
            WHEN TRY_CONVERT(INT, s.store_id_raw) IS NOT NULL
             AND NOT EXISTS
                 (SELECT 1 FROM retail.stores AS st
                  WHERE st.store_id = TRY_CONVERT(INT, s.store_id_raw))
                THEN N'ORPHAN_STORE'
            ELSE NULL
        END AS rejection_reason
    FROM staging.orders_incoming AS s
    INNER JOIN accepted_batches AS ab
        ON ab.batch_id = s.batch_id
)
INSERT INTO practice_dw.orders_rejects
    (ingestion_id, batch_id, source_order_id_raw, rejection_reason)
SELECT
    ingestion_id,
    batch_id,
    source_order_id_raw,
    rejection_reason
FROM evaluated
WHERE rejection_reason IS NOT NULL;

SELECT
    ingestion_id,
    batch_id,
    source_order_id_raw,
    rejection_reason,
    rejected_at
FROM practice_dw.orders_rejects
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 249
-------------------------------------------------------------------------------
-- Update a clean practice target when a newer source version exists.

-- OUTPUT GRAIN:
-- DML operation; one row per target order that has a newer valid source winner

-- REFERENCE SOLUTION:
DROP TABLE IF EXISTS practice_dw.orders_upsert_target;

CREATE TABLE practice_dw.orders_upsert_target
(
    source_order_id INT NOT NULL PRIMARY KEY,
    customer_id INT NULL,
    store_id INT NOT NULL,
    order_date DATETIME2(0) NOT NULL,
    status NVARCHAR(20) NOT NULL,
    sales_channel NVARCHAR(20) NOT NULL,
    last_modified DATETIME2(0) NOT NULL
);

-- Seed an intentionally older 2001 target plus an existing clean target order.
INSERT INTO practice_dw.orders_upsert_target
    (source_order_id, customer_id, store_id, order_date, status, sales_channel, last_modified)
VALUES
    (2001, 1, 1, '2026-08-10T08:00:00', N'Processing', N'Online', '2026-08-10T08:05:00');

INSERT INTO practice_dw.orders_upsert_target
    (source_order_id, customer_id, store_id, order_date, status, sales_channel, last_modified)
SELECT
    o.order_id,
    o.customer_id,
    o.store_id,
    o.order_date,
    o.status,
    o.sales_channel,
    o.last_modified
FROM retail.orders AS o
WHERE o.order_id = 1012;

WITH source_winners AS
(
    SELECT
        source_order_id,
        customer_id,
        store_id,
        order_date,
        status,
        sales_channel,
        modified_at,
        change_type,
        rn
    FROM
    (
        SELECT
            TRY_CONVERT(INT, source_order_id_raw) AS source_order_id,
            CASE WHEN customer_id_raw IS NULL THEN NULL
                 ELSE TRY_CONVERT(INT, customer_id_raw) END AS customer_id,
            TRY_CONVERT(INT, store_id_raw) AS store_id,
            TRY_CONVERT(DATETIME2(0), order_date_raw) AS order_date,
            status_raw AS status,
            sales_channel_raw AS sales_channel,
            TRY_CONVERT(DATETIME2(0), modified_at_raw) AS modified_at,
            UPPER(change_type_raw) AS change_type,
            ROW_NUMBER() OVER
            (
                PARTITION BY TRY_CONVERT(INT, source_order_id_raw)
                ORDER BY
                    TRY_CONVERT(DATETIME2(0), modified_at_raw) DESC,
                    ingested_at DESC,
                    ingestion_id DESC
            ) AS rn
        FROM staging.orders_incoming
        WHERE TRY_CONVERT(INT, source_order_id_raw) IS NOT NULL
          AND TRY_CONVERT(INT, store_id_raw) IS NOT NULL
          AND TRY_CONVERT(DATETIME2(0), order_date_raw) IS NOT NULL
          AND TRY_CONVERT(DATETIME2(0), modified_at_raw) IS NOT NULL
          AND status_raw IN (N'Processing',N'Shipped',N'Completed',N'Cancelled',N'Refunded')
          AND sales_channel_raw IN (N'Online',N'InStore')
          AND UPPER(change_type_raw) = N'UPSERT'
    ) AS x
    WHERE rn = 1
)
UPDATE t
SET
    t.customer_id = s.customer_id,
    t.store_id = s.store_id,
    t.order_date = s.order_date,
    t.status = s.status,
    t.sales_channel = s.sales_channel,
    t.last_modified = s.modified_at
FROM practice_dw.orders_upsert_target AS t
INNER JOIN source_winners AS s
    ON s.source_order_id = t.source_order_id
WHERE s.modified_at > t.last_modified;

SELECT
    source_order_id,
    customer_id,
    store_id,
    order_date,
    status,
    sales_channel,
    last_modified
FROM practice_dw.orders_upsert_target
ORDER BY source_order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 250
-------------------------------------------------------------------------------
-- Insert source business keys not already in the target.

-- OUTPUT GRAIN:
-- DML operation; one row inserted per valid source winner not already in the target

-- REFERENCE SOLUTION:
WITH source_winners AS
(
    SELECT
        source_order_id,
        customer_id,
        store_id,
        order_date,
        status,
        sales_channel,
        modified_at,
        change_type,
        rn
    FROM
    (
        SELECT
            TRY_CONVERT(INT, source_order_id_raw) AS source_order_id,
            CASE WHEN customer_id_raw IS NULL THEN NULL
                 ELSE TRY_CONVERT(INT, customer_id_raw) END AS customer_id,
            TRY_CONVERT(INT, store_id_raw) AS store_id,
            TRY_CONVERT(DATETIME2(0), order_date_raw) AS order_date,
            status_raw AS status,
            sales_channel_raw AS sales_channel,
            TRY_CONVERT(DATETIME2(0), modified_at_raw) AS modified_at,
            UPPER(change_type_raw) AS change_type,
            ROW_NUMBER() OVER
            (
                PARTITION BY TRY_CONVERT(INT, source_order_id_raw)
                ORDER BY
                    TRY_CONVERT(DATETIME2(0), modified_at_raw) DESC,
                    ingested_at DESC,
                    ingestion_id DESC
            ) AS rn
        FROM staging.orders_incoming
        WHERE TRY_CONVERT(INT, source_order_id_raw) IS NOT NULL
          AND TRY_CONVERT(INT, store_id_raw) IS NOT NULL
          AND TRY_CONVERT(DATETIME2(0), order_date_raw) IS NOT NULL
          AND TRY_CONVERT(DATETIME2(0), order_date_raw) < '2026-08-16T00:00:00'
          AND TRY_CONVERT(DATETIME2(0), modified_at_raw) IS NOT NULL
          AND status_raw IN (N'Processing',N'Shipped',N'Completed',N'Cancelled',N'Refunded')
          AND sales_channel_raw IN (N'Online',N'InStore')
          AND UPPER(change_type_raw) = N'UPSERT'
          AND (customer_id_raw IS NULL
               OR EXISTS
                  (SELECT 1 FROM retail.customers AS c
                   WHERE c.customer_id = TRY_CONVERT(INT, customer_id_raw)))
          AND EXISTS
              (SELECT 1 FROM retail.stores AS st
               WHERE st.store_id = TRY_CONVERT(INT, store_id_raw))
    ) AS x
    WHERE rn = 1
)
INSERT INTO practice_dw.orders_upsert_target
    (source_order_id, customer_id, store_id, order_date, status, sales_channel, last_modified)
SELECT
    s.source_order_id,
    s.customer_id,
    s.store_id,
    s.order_date,
    s.status,
    s.sales_channel,
    s.modified_at
FROM source_winners AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM practice_dw.orders_upsert_target AS t
    WHERE t.source_order_id = s.source_order_id
);

SELECT
    source_order_id,
    customer_id,
    store_id,
    order_date,
    status,
    sales_channel,
    last_modified
FROM practice_dw.orders_upsert_target
ORDER BY source_order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- Day 2 Capstone
-- ==============================================================================

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
-- pipeline outputs: clean orders at one row per source order; clean items at one row per source order line; audit at one row per entity

-- REFERENCE SOLUTION:
/*
CAPSTONE DESIGN
---------------
1. Accept only the earliest batch for each source checksum (file idempotency).
2. Type raw strings with TRY_CONVERT.
3. Quarantine invalid technical/business/reference rows.
4. Deduplicate valid versions deterministically.
5. Load clean order winners, preserving NULL customer IDs for guest orders.
6. Validate/deduplicate items and require every accepted line to resolve to an
   accepted clean order and a clean retail product.
7. Reconcile read = rejected + superseded + accepted for each entity and assert
   that no accepted line is orphaned from its accepted order.
*/

DROP TABLE IF EXISTS practice_dw.pipeline_order_items_clean;
DROP TABLE IF EXISTS practice_dw.pipeline_orders_clean;
DROP TABLE IF EXISTS practice_dw.pipeline_rejects;
DROP TABLE IF EXISTS practice_dw.pipeline_audit;

CREATE TABLE practice_dw.pipeline_orders_clean
(
    source_order_id INT NOT NULL PRIMARY KEY,
    customer_id INT NULL,
    store_id INT NOT NULL,
    order_date DATETIME2(0) NOT NULL,
    status NVARCHAR(20) NOT NULL,
    sales_channel NVARCHAR(20) NOT NULL,
    modified_at DATETIME2(0) NOT NULL,
    change_type NVARCHAR(20) NOT NULL,
    source_ingestion_id BIGINT NOT NULL,
    ingested_at DATETIME2(0) NOT NULL,
    CONSTRAINT FK_pipeline_orders_customer FOREIGN KEY (customer_id)
        REFERENCES retail.customers(customer_id),
    CONSTRAINT FK_pipeline_orders_store FOREIGN KEY (store_id)
        REFERENCES retail.stores(store_id)
);

CREATE TABLE practice_dw.pipeline_order_items_clean
(
    source_order_id INT NOT NULL,
    line_number INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    modified_at DATETIME2(0) NOT NULL,
    change_type NVARCHAR(20) NOT NULL,
    source_ingestion_id BIGINT NOT NULL,
    ingested_at DATETIME2(0) NOT NULL,
    CONSTRAINT PK_pipeline_order_items PRIMARY KEY (source_order_id, line_number),
    CONSTRAINT FK_pipeline_items_order FOREIGN KEY (source_order_id)
        REFERENCES practice_dw.pipeline_orders_clean(source_order_id),
    CONSTRAINT FK_pipeline_items_product FOREIGN KEY (product_id)
        REFERENCES retail.products(product_id),
    CONSTRAINT CK_pipeline_items_quantity CHECK (quantity > 0),
    CONSTRAINT CK_pipeline_items_unit_price CHECK (unit_price >= 0),
    CONSTRAINT CK_pipeline_items_discount CHECK
        (discount_amount >= 0 AND discount_amount <= quantity * unit_price)
);

CREATE TABLE practice_dw.pipeline_rejects
(
    entity_name NVARCHAR(30) NOT NULL,
    ingestion_id BIGINT NOT NULL,
    batch_id BIGINT NOT NULL,
    business_key NVARCHAR(100) NULL,
    rejection_reason NVARCHAR(200) NOT NULL,
    rejected_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_pipeline_rejects_rejected_at DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_pipeline_rejects PRIMARY KEY (entity_name, ingestion_id)
);

CREATE TABLE practice_dw.pipeline_audit
(
    entity_name NVARCHAR(30) NOT NULL PRIMARY KEY,
    source_rows_total INT NOT NULL,
    replay_rows_skipped INT NOT NULL,
    read_count INT NOT NULL,
    rejected_count INT NOT NULL,
    superseded_count INT NOT NULL,
    accepted_count INT NOT NULL,
    reconciled_flag BIT NOT NULL
);

BEGIN TRY
    BEGIN TRANSACTION;

    /* -----------------------------------------------------
       Accepted file batches: earliest batch per checksum.
       ----------------------------------------------------- */
    CREATE TABLE #accepted_batches
    (
        batch_id BIGINT NOT NULL PRIMARY KEY,
        source_entity NVARCHAR(50) NOT NULL
    );

    WITH ranked_batches AS
    (
        SELECT
            b.*,
            ROW_NUMBER() OVER
            (
                PARTITION BY b.source_entity, b.file_checksum
                ORDER BY b.arrived_at, b.batch_id
            ) AS rn
        FROM staging.ingestion_batches AS b
        WHERE b.source_entity IN (N'orders', N'order_items')
    )
    INSERT INTO #accepted_batches (batch_id, source_entity)
    SELECT batch_id, source_entity
    FROM ranked_batches
    WHERE rn = 1;

    /* -----------------------------------------------------
       ORDERS: type + validate + quarantine.
       ----------------------------------------------------- */
    SELECT
        s.ingestion_id,
        s.batch_id,
        s.source_row_number,
        s.source_order_id_raw,
        s.customer_id_raw,
        s.store_id_raw,
        s.order_date_raw,
        s.status_raw,
        s.sales_channel_raw,
        s.modified_at_raw,
        s.change_type_raw,
        s.ingested_at,
        TRY_CONVERT(INT, s.source_order_id_raw) AS source_order_id,
        CASE WHEN s.customer_id_raw IS NULL THEN NULL
             ELSE TRY_CONVERT(INT, s.customer_id_raw) END AS customer_id,
        TRY_CONVERT(INT, s.store_id_raw) AS store_id,
        TRY_CONVERT(DATETIME2(0), s.order_date_raw) AS order_date,
        TRY_CONVERT(DATETIME2(0), s.modified_at_raw) AS modified_at,
        UPPER(LTRIM(RTRIM(s.change_type_raw))) AS change_type,
        CAST(NULL AS NVARCHAR(200)) AS rejection_reason
    INTO #orders_typed
    FROM staging.orders_incoming AS s
    INNER JOIN #accepted_batches AS ab
        ON ab.batch_id = s.batch_id
       AND ab.source_entity = N'orders';

    UPDATE t
    SET rejection_reason =
        CASE
            WHEN NULLIF(LTRIM(RTRIM(t.source_order_id_raw)), N'') IS NULL
                THEN N'MISSING_ORDER_KEY'
            WHEN t.source_order_id IS NULL
                THEN N'MALFORMED_ORDER_ID'
            WHEN t.customer_id_raw IS NOT NULL
             AND NULLIF(LTRIM(RTRIM(t.customer_id_raw)), N'') IS NULL
                THEN N'BLANK_CUSTOMER_ID'
            WHEN t.customer_id_raw IS NOT NULL
             AND t.customer_id IS NULL
                THEN N'MALFORMED_CUSTOMER_ID'
            WHEN t.store_id IS NULL
                THEN N'MALFORMED_STORE_ID'
            WHEN t.order_date IS NULL
                THEN N'MALFORMED_ORDER_DATE'
            WHEN t.order_date >= '2026-08-16T00:00:00'
                THEN N'FUTURE_ORDER_DATE'
            WHEN t.status_raw NOT IN
                 (N'Processing',N'Shipped',N'Completed',N'Cancelled',N'Refunded')
                THEN N'INVALID_STATUS'
            WHEN t.sales_channel_raw NOT IN (N'Online',N'InStore')
                THEN N'INVALID_SALES_CHANNEL'
            WHEN t.modified_at IS NULL
                THEN N'MALFORMED_MODIFIED_AT'
            WHEN t.change_type NOT IN (N'UPSERT',N'DELETE')
                THEN N'INVALID_CHANGE_TYPE'
            WHEN t.customer_id IS NOT NULL
             AND NOT EXISTS
                 (SELECT 1 FROM retail.customers AS c
                  WHERE c.customer_id = t.customer_id)
                THEN N'ORPHAN_CUSTOMER'
            WHEN NOT EXISTS
                 (SELECT 1 FROM retail.stores AS st
                  WHERE st.store_id = t.store_id)
                THEN N'ORPHAN_STORE'
            ELSE NULL
        END
    FROM #orders_typed AS t;

    INSERT INTO practice_dw.pipeline_rejects
        (entity_name, ingestion_id, batch_id, business_key, rejection_reason)
    SELECT
        N'orders',
        ingestion_id,
        batch_id,
        source_order_id_raw,
        rejection_reason
    FROM #orders_typed
    WHERE rejection_reason IS NOT NULL;

    SELECT
        t.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY t.source_order_id
            ORDER BY t.modified_at DESC, t.ingested_at DESC, t.ingestion_id DESC
        ) AS rn
    INTO #orders_ranked
    FROM #orders_typed AS t
    WHERE t.rejection_reason IS NULL;

    INSERT INTO practice_dw.pipeline_orders_clean
    (
        source_order_id,
        customer_id,
        store_id,
        order_date,
        status,
        sales_channel,
        modified_at,
        change_type,
        source_ingestion_id,
        ingested_at
    )
    SELECT
        source_order_id,
        customer_id,
        store_id,
        order_date,
        status_raw,
        sales_channel_raw,
        modified_at,
        change_type,
        ingestion_id,
        ingested_at
    FROM #orders_ranked
    WHERE rn = 1;

    /* -----------------------------------------------------
       ORDER ITEMS: type + validate + quarantine + dedup.
       Parent resolution is against accepted order winners.
       ----------------------------------------------------- */
    SELECT
        i.ingestion_id,
        i.batch_id,
        i.source_row_number,
        i.source_order_id_raw,
        i.line_number_raw,
        i.product_id_raw,
        i.quantity_raw,
        i.unit_price_raw,
        i.discount_amount_raw,
        i.modified_at_raw,
        i.change_type_raw,
        i.ingested_at,
        TRY_CONVERT(INT, i.source_order_id_raw) AS source_order_id,
        TRY_CONVERT(INT, i.line_number_raw) AS line_number,
        TRY_CONVERT(INT, i.product_id_raw) AS product_id,
        TRY_CONVERT(INT, i.quantity_raw) AS quantity,
        TRY_CONVERT(DECIMAL(10,2), i.unit_price_raw) AS unit_price,
        TRY_CONVERT(DECIMAL(10,2), i.discount_amount_raw) AS discount_amount,
        TRY_CONVERT(DATETIME2(0), i.modified_at_raw) AS modified_at,
        UPPER(LTRIM(RTRIM(i.change_type_raw))) AS change_type,
        CAST(NULL AS NVARCHAR(200)) AS rejection_reason
    INTO #items_typed
    FROM staging.order_items_incoming AS i
    INNER JOIN #accepted_batches AS ab
        ON ab.batch_id = i.batch_id
       AND ab.source_entity = N'order_items';

    UPDATE t
    SET rejection_reason =
        CASE
            WHEN t.source_order_id IS NULL THEN N'MALFORMED_OR_MISSING_ORDER_ID'
            WHEN NULLIF(LTRIM(RTRIM(t.line_number_raw)), N'') IS NULL
                THEN N'MISSING_LINE_NUMBER'
            WHEN t.line_number IS NULL THEN N'MALFORMED_LINE_NUMBER'
            WHEN t.product_id IS NULL THEN N'MALFORMED_PRODUCT_ID'
            WHEN t.quantity IS NULL THEN N'MALFORMED_QUANTITY'
            WHEN t.quantity = 0 THEN N'ZERO_QUANTITY'
            WHEN t.quantity < 0 THEN N'NEGATIVE_QUANTITY'
            WHEN t.unit_price IS NULL THEN N'MALFORMED_UNIT_PRICE'
            WHEN t.unit_price < 0 THEN N'NEGATIVE_UNIT_PRICE'
            WHEN t.discount_amount IS NULL THEN N'MALFORMED_DISCOUNT'
            WHEN t.discount_amount < 0 THEN N'NEGATIVE_DISCOUNT'
            WHEN t.discount_amount > t.quantity * t.unit_price
                THEN N'DISCOUNT_ABOVE_GROSS'
            WHEN t.modified_at IS NULL THEN N'MALFORMED_MODIFIED_AT'
            WHEN t.change_type NOT IN (N'UPSERT',N'DELETE')
                THEN N'INVALID_CHANGE_TYPE'
            WHEN NOT EXISTS
                 (SELECT 1 FROM retail.products AS p
                  WHERE p.product_id = t.product_id)
                THEN N'ORPHAN_PRODUCT'
            WHEN NOT EXISTS
                 (SELECT 1 FROM practice_dw.pipeline_orders_clean AS o
                  WHERE o.source_order_id = t.source_order_id)
                THEN N'ORPHAN_ACCEPTED_ORDER'
            ELSE NULL
        END
    FROM #items_typed AS t;

    INSERT INTO practice_dw.pipeline_rejects
        (entity_name, ingestion_id, batch_id, business_key, rejection_reason)
    SELECT
        N'order_items',
        ingestion_id,
        batch_id,
        CONCAT(source_order_id_raw, N'/', COALESCE(line_number_raw, N'<NULL>')),
        rejection_reason
    FROM #items_typed
    WHERE rejection_reason IS NOT NULL;

    SELECT
        t.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY t.source_order_id, t.line_number
            ORDER BY t.modified_at DESC, t.ingested_at DESC, t.ingestion_id DESC
        ) AS rn
    INTO #items_ranked
    FROM #items_typed AS t
    WHERE t.rejection_reason IS NULL;

    INSERT INTO practice_dw.pipeline_order_items_clean
    (
        source_order_id,
        line_number,
        product_id,
        quantity,
        unit_price,
        discount_amount,
        modified_at,
        change_type,
        source_ingestion_id,
        ingested_at
    )
    SELECT
        source_order_id,
        line_number,
        product_id,
        quantity,
        unit_price,
        discount_amount,
        modified_at,
        change_type,
        ingestion_id,
        ingested_at
    FROM #items_ranked
    WHERE rn = 1;

    /* -----------------------------------------------------
       Audit and reconciliation metrics.
       read_count means rows actually considered after replay
       exclusion. replay_rows_skipped is reported separately.
       ----------------------------------------------------- */
    DECLARE @order_source_total INT = (SELECT COUNT(*) FROM staging.orders_incoming);
    DECLARE @order_read INT = (SELECT COUNT(*) FROM #orders_typed);
    DECLARE @order_rejected INT =
        (SELECT COUNT(*) FROM #orders_typed WHERE rejection_reason IS NOT NULL);
    DECLARE @order_superseded INT =
        (SELECT COUNT(*) FROM #orders_ranked WHERE rn > 1);
    DECLARE @order_accepted INT =
        (SELECT COUNT(*) FROM practice_dw.pipeline_orders_clean);

    DECLARE @item_source_total INT = (SELECT COUNT(*) FROM staging.order_items_incoming);
    DECLARE @item_read INT = (SELECT COUNT(*) FROM #items_typed);
    DECLARE @item_rejected INT =
        (SELECT COUNT(*) FROM #items_typed WHERE rejection_reason IS NOT NULL);
    DECLARE @item_superseded INT =
        (SELECT COUNT(*) FROM #items_ranked WHERE rn > 1);
    DECLARE @item_accepted INT =
        (SELECT COUNT(*) FROM practice_dw.pipeline_order_items_clean);

    INSERT INTO practice_dw.pipeline_audit
    (
        entity_name,
        source_rows_total,
        replay_rows_skipped,
        read_count,
        rejected_count,
        superseded_count,
        accepted_count,
        reconciled_flag
    )
    VALUES
    (
        N'orders',
        @order_source_total,
        @order_source_total - @order_read,
        @order_read,
        @order_rejected,
        @order_superseded,
        @order_accepted,
        CASE WHEN @order_read = @order_rejected + @order_superseded + @order_accepted
             THEN 1 ELSE 0 END
    ),
    (
        N'order_items',
        @item_source_total,
        @item_source_total - @item_read,
        @item_read,
        @item_rejected,
        @item_superseded,
        @item_accepted,
        CASE WHEN @item_read = @item_rejected + @item_superseded + @item_accepted
             THEN 1 ELSE 0 END
    );

    IF EXISTS
    (
        SELECT 1
        FROM practice_dw.pipeline_audit
        WHERE reconciled_flag = 0
    )
        THROW 52001, 'Capstone row-count reconciliation failed.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM practice_dw.pipeline_order_items_clean AS i
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM practice_dw.pipeline_orders_clean AS o
            WHERE o.source_order_id = i.source_order_id
        )
    )
        THROW 52002, 'Accepted order-item reconciliation failed: orphan clean line.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- Final observable outputs.
SELECT
    source_order_id,
    customer_id,
    store_id,
    order_date,
    status,
    sales_channel,
    modified_at,
    change_type,
    source_ingestion_id,
    ingested_at
FROM practice_dw.pipeline_orders_clean
ORDER BY source_order_id;

SELECT
    source_order_id,
    line_number,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    modified_at,
    change_type,
    source_ingestion_id,
    ingested_at
FROM practice_dw.pipeline_order_items_clean
ORDER BY source_order_id, line_number;

SELECT
    entity_name,
    ingestion_id,
    batch_id,
    business_key,
    rejection_reason,
    rejected_at
FROM practice_dw.pipeline_rejects
ORDER BY entity_name, ingestion_id;

SELECT
    entity_name,
    source_rows_total,
    replay_rows_skipped,
    read_count,
    rejected_count,
    superseded_count,
    accepted_count,
    reconciled_flag
FROM practice_dw.pipeline_audit
ORDER BY entity_name;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO
