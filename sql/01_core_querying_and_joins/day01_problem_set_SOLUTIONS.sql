/*
===============================================================================
Retail SQL for Data Engineering
DAY 1 REFERENCE SOLUTIONS — Core Querying + Joins
Dialect: Microsoft T-SQL for SQL Server
Database: RetailDEPractice

This file is the companion answer key for day01_starter_fixed.sql.
It contains the exact same 97 problem prompts in the exact same order.

IMPORTANT
---------
Use this only after attempting each problem yourself.

The queries below are reference solutions. Some SQL problems admit multiple
equally correct formulations. Where a business term is ambiguous, an explicit
assumption is documented in the solution rather than silently changing the
problem statement.

No execution results are fabricated in this file. Run each batch against your
validated RetailDEPractice database to verify it locally.
===============================================================================
*/

USE RetailDEPractice;
GO


-- ==============================================================================
-- A. SELECT / WHERE / ORDER BY
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 1
-------------------------------------------------------------------------------
-- Return active products with `product_id`, `sku`, `product_name`, `category`, and `list_price`.

-- OUTPUT GRAIN:
-- one row per active product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    sku,
    product_name,
    category,
    list_price
FROM retail.products
WHERE active_flag = 1;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 2
-------------------------------------------------------------------------------
-- Return products priced above $100.

-- OUTPUT GRAIN:
-- one row per qualifying product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    sku,
    product_name,
    list_price
FROM retail.products
WHERE list_price > 100.00;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 3
-------------------------------------------------------------------------------
-- Return the 10 most expensive products.

-- OUTPUT GRAIN:
-- one row per selected product

-- REFERENCE SOLUTION:
SELECT TOP (10)
    product_id,
    sku,
    product_name,
    list_price
FROM retail.products
ORDER BY list_price DESC, product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 4
-------------------------------------------------------------------------------
-- Return completed online orders.

-- OUTPUT GRAIN:
-- one row per qualifying order

-- REFERENCE SOLUTION:
SELECT
    order_id,
    customer_id,
    store_id,
    order_date,
    status,
    sales_channel
FROM retail.orders
WHERE status = N'Completed'
  AND sales_channel = N'Online';

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 5
-------------------------------------------------------------------------------
-- Return completed orders on or after `2026-04-01`.

-- OUTPUT GRAIN:
-- one row per qualifying order

-- REFERENCE SOLUTION:
SELECT
    order_id,
    customer_id,
    store_id,
    order_date,
    status
FROM retail.orders
WHERE status = N'Completed'
  AND order_date >= '2026-04-01';

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 6
-------------------------------------------------------------------------------
-- Return customers in Ontario or British Columbia.

-- OUTPUT GRAIN:
-- one row per qualifying customer

-- REFERENCE SOLUTION:
SELECT
    customer_id,
    customer_name,
    province
FROM retail.customers
WHERE province IN ('ON', 'BC');

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 7
-------------------------------------------------------------------------------
-- Return products outside the `Electronics` category.

-- OUTPUT GRAIN:
-- one row per qualifying product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    sku,
    product_name,
    category
FROM retail.products
WHERE category <> N'Electronics';

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 8
-------------------------------------------------------------------------------
-- Return orders with status `Completed`, `Shipped`, or `Processing`.

-- OUTPUT GRAIN:
-- one row per qualifying order

-- REFERENCE SOLUTION:
SELECT
    order_id,
    customer_id,
    store_id,
    order_date,
    status
FROM retail.orders
WHERE status IN (N'Completed', N'Shipped', N'Processing');

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 9
-------------------------------------------------------------------------------
-- Return products priced between $25 and $100 inclusive.

-- OUTPUT GRAIN:
-- one row per qualifying product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    product_name,
    list_price
FROM retail.products
WHERE list_price BETWEEN 25.00 AND 100.00;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 10
-------------------------------------------------------------------------------
-- Return customers newest signup first, then alphabetically.

-- OUTPUT GRAIN:
-- one row per customer

-- REFERENCE SOLUTION:
SELECT
    customer_id,
    customer_name,
    signup_date
FROM retail.customers
ORDER BY signup_date DESC, customer_name ASC;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 11
-------------------------------------------------------------------------------
-- Return inactive products.

-- OUTPUT GRAIN:
-- one row per inactive product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    sku,
    product_name,
    active_flag
FROM retail.products
WHERE active_flag = 0;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 12
-------------------------------------------------------------------------------
-- Return orders before noon.

-- OUTPUT GRAIN:
-- one row per qualifying order

-- REFERENCE SOLUTION:
SELECT
    order_id,
    order_date,
    status
FROM retail.orders
WHERE CAST(order_date AS time) < '12:00:00'
ORDER BY order_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 13
-------------------------------------------------------------------------------
-- Return the five earliest orders.

-- OUTPUT GRAIN:
-- one row per selected order

-- REFERENCE SOLUTION:
SELECT TOP (5)
    order_id,
    customer_id,
    store_id,
    order_date
FROM retail.orders
ORDER BY order_date ASC, order_id ASC;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 14
-------------------------------------------------------------------------------
-- Return distinct customer provinces.

-- OUTPUT GRAIN:
-- one row per distinct province

-- REFERENCE SOLUTION:
SELECT DISTINCT
    province
FROM retail.customers
ORDER BY province;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 15
-------------------------------------------------------------------------------
-- Return orders that are not completed.

-- OUTPUT GRAIN:
-- one row per non-completed order

-- REFERENCE SOLUTION:
SELECT
    order_id,
    customer_id,
    store_id,
    order_date,
    status
FROM retail.orders
WHERE status <> N'Completed';

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- B. Aggregates / GROUP BY / HAVING
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 16
-------------------------------------------------------------------------------
-- Count all orders.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    COUNT(*) AS order_count
FROM retail.orders;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 17
-------------------------------------------------------------------------------
-- Count orders with a non-NULL customer.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    COUNT(customer_id) AS orders_with_known_customer
FROM retail.orders;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 18
-------------------------------------------------------------------------------
-- Count distinct customers who placed an order.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    COUNT(DISTINCT customer_id) AS distinct_customers_with_orders
FROM retail.orders;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 19
-------------------------------------------------------------------------------
-- Sum quantity across all order-item rows.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    SUM(quantity) AS total_quantity
FROM retail.order_items;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 20
-------------------------------------------------------------------------------
-- Calculate gross line sales: `quantity * unit_price`.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    SUM(quantity * unit_price) AS gross_line_sales
FROM retail.order_items;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 21
-------------------------------------------------------------------------------
-- Calculate total discounts.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    SUM(discount_amount) AS total_discount_amount
FROM retail.order_items;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 22
-------------------------------------------------------------------------------
-- Calculate total net line sales.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    SUM((quantity * unit_price) - discount_amount) AS total_net_line_sales
FROM retail.order_items;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 23
-------------------------------------------------------------------------------
-- Find average list price.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    AVG(list_price) AS average_list_price
FROM retail.products;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 24
-------------------------------------------------------------------------------
-- Find minimum and maximum product costs.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    MIN(unit_cost) AS minimum_unit_cost,
    MAX(unit_cost) AS maximum_unit_cost
FROM retail.products;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 25
-------------------------------------------------------------------------------
-- Return product count by category.

-- OUTPUT GRAIN:
-- one row per product category

-- REFERENCE SOLUTION:
SELECT
    category,
    COUNT(*) AS product_count
FROM retail.products
GROUP BY category
ORDER BY category;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 26
-------------------------------------------------------------------------------
-- Return order count by status.

-- OUTPUT GRAIN:
-- one row per order status

-- REFERENCE SOLUTION:
SELECT
    status,
    COUNT(*) AS order_count
FROM retail.orders
GROUP BY status
ORDER BY status;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 27
-------------------------------------------------------------------------------
-- Return order count by sales channel.

-- OUTPUT GRAIN:
-- one row per sales channel

-- REFERENCE SOLUTION:
SELECT
    sales_channel,
    COUNT(*) AS order_count
FROM retail.orders
GROUP BY sales_channel
ORDER BY sales_channel;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 28
-------------------------------------------------------------------------------
-- Return total units sold by product.

-- OUTPUT GRAIN:
-- one row per product with order-item activity

-- REFERENCE SOLUTION:
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold
FROM retail.products AS p
INNER JOIN retail.order_items AS oi
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY p.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 29
-------------------------------------------------------------------------------
-- Return total net sales by order.

-- OUTPUT GRAIN:
-- one row per order

-- REFERENCE SOLUTION:
SELECT
    order_id,
    SUM((quantity * unit_price) - discount_amount) AS net_sales
FROM retail.order_items
GROUP BY order_id
ORDER BY order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 30
-------------------------------------------------------------------------------
-- Return total net sales by product.

-- OUTPUT GRAIN:
-- one row per product with order-item activity

-- REFERENCE SOLUTION:
SELECT
    p.product_id,
    p.product_name,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS net_sales
FROM retail.products AS p
INNER JOIN retail.order_items AS oi
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY p.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 31
-------------------------------------------------------------------------------
-- Return categories containing at least four products.

-- OUTPUT GRAIN:
-- one row per qualifying category

-- REFERENCE SOLUTION:
SELECT
    category,
    COUNT(*) AS product_count
FROM retail.products
GROUP BY category
HAVING COUNT(*) >= 4
ORDER BY category;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 32
-------------------------------------------------------------------------------
-- Return customers with at least two orders.

-- OUTPUT GRAIN:
-- one row per customer with at least two orders

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS order_count
FROM retail.customers AS c
INNER JOIN retail.orders AS o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(*) >= 2
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 33
-------------------------------------------------------------------------------
-- Return stores with at least four completed orders.

-- OUTPUT GRAIN:
-- one row per qualifying store

-- REFERENCE SOLUTION:
SELECT
    s.store_id,
    s.store_name,
    COUNT(*) AS completed_order_count
FROM retail.stores AS s
INNER JOIN retail.orders AS o
    ON o.store_id = s.store_id
WHERE o.status = N'Completed'
GROUP BY
    s.store_id,
    s.store_name
HAVING COUNT(*) >= 4
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 34
-------------------------------------------------------------------------------
-- Return customers whose completed lifetime net sales exceed $300.

-- OUTPUT GRAIN:
-- one row per qualifying customer

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_lifetime_net_sales
FROM retail.customers AS c
INNER JOIN retail.orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
HAVING SUM((oi.quantity * oi.unit_price) - oi.discount_amount) > 300.00
ORDER BY completed_lifetime_net_sales DESC;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 35
-------------------------------------------------------------------------------
-- Calculate average completed order value using distinct orders.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    AVG(CAST(order_net_sales AS DECIMAL(18,2))) AS average_completed_order_value
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
) AS completed_order_totals;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- C. CASE / NULL
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 36
-------------------------------------------------------------------------------
-- Classify products as `Budget`, `Midrange`, or `Premium`.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    product_name,
    list_price,
    CASE
        WHEN list_price < 25.00 THEN N'Budget'
        WHEN list_price < 100.00 THEN N'Midrange'
        ELSE N'Premium'
    END AS price_class
FROM retail.products;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 37
-------------------------------------------------------------------------------
-- Classify inventory rows as `Out of Stock`, `Low Stock`, or `Healthy`.

-- OUTPUT GRAIN:
-- one row per inventory snapshot record

-- REFERENCE SOLUTION:
SELECT
    store_id,
    product_id,
    snapshot_date,
    on_hand_qty,
    reorder_point,
    CASE
        WHEN on_hand_qty = 0 THEN N'Out of Stock'
        WHEN on_hand_qty <= reorder_point THEN N'Low Stock'
        ELSE N'Healthy'
    END AS stock_status
FROM retail.inventory_snapshots;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 38
-------------------------------------------------------------------------------
-- Replace NULL email with `NO_EMAIL`.

-- OUTPUT GRAIN:
-- one row per customer

-- REFERENCE SOLUTION:
SELECT
    customer_id,
    customer_name,
    COALESCE(email, N'NO_EMAIL') AS email
FROM retail.customers;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 39
-------------------------------------------------------------------------------
-- Replace NULL loyalty tier with `Unassigned`.

-- OUTPUT GRAIN:
-- one row per customer

-- REFERENCE SOLUTION:
SELECT
    customer_id,
    customer_name,
    COALESCE(loyalty_tier, N'Unassigned') AS loyalty_tier
FROM retail.customers;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 40
-------------------------------------------------------------------------------
-- Label guest versus known-customer orders.

-- OUTPUT GRAIN:
-- one row per order

-- REFERENCE SOLUTION:
SELECT
    order_id,
    customer_id,
    CASE
        WHEN customer_id IS NULL THEN N'Guest'
        ELSE N'Known'
    END AS customer_type
FROM retail.orders;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 41
-------------------------------------------------------------------------------
-- Count guest and known-customer orders.

-- OUTPUT GRAIN:
-- one row per customer-type classification

-- REFERENCE SOLUTION:
SELECT
    CASE
        WHEN customer_id IS NULL THEN N'Guest'
        ELSE N'Known'
    END AS customer_type,
    COUNT(*) AS order_count
FROM retail.orders
GROUP BY
    CASE
        WHEN customer_id IS NULL THEN N'Guest'
        ELSE N'Known'
    END;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 42
-------------------------------------------------------------------------------
-- Return completed/cancelled/other order counts per store with conditional aggregation.

-- OUTPUT GRAIN:
-- one row per store

-- REFERENCE SOLUTION:
SELECT
    s.store_id,
    s.store_name,
    SUM(CASE WHEN o.status = N'Completed' THEN 1 ELSE 0 END) AS completed_order_count,
    SUM(CASE WHEN o.status = N'Cancelled' THEN 1 ELSE 0 END) AS cancelled_order_count,
    SUM(CASE
            WHEN o.order_id IS NOT NULL
             AND o.status NOT IN (N'Completed', N'Cancelled')
            THEN 1 ELSE 0
        END) AS other_order_count
FROM retail.stores AS s
LEFT JOIN retail.orders AS o
    ON o.store_id = s.store_id
GROUP BY
    s.store_id,
    s.store_name
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 43
-------------------------------------------------------------------------------
-- Calculate discounted-line revenue separately from non-discounted-line revenue.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    SUM(CASE
            WHEN discount_amount > 0
            THEN (quantity * unit_price) - discount_amount
            ELSE 0
        END) AS discounted_line_revenue,
    SUM(CASE
            WHEN discount_amount = 0
            THEN quantity * unit_price
            ELSE 0
        END) AS non_discounted_line_revenue
FROM retail.order_items;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 44
-------------------------------------------------------------------------------
-- Return percentage of clean order-item rows carrying a discount.

-- OUTPUT GRAIN:
-- one summary row

-- REFERENCE SOLUTION:
SELECT
    CAST(
        100.0 * SUM(CASE WHEN discount_amount > 0 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(6,2)
    ) AS discounted_line_percentage
FROM retail.order_items;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 45
-------------------------------------------------------------------------------
-- Calculate gross margin per clean order line as net sales minus product cost.

-- OUTPUT GRAIN:
-- one row per clean order line

-- REFERENCE SOLUTION:
SELECT
    oi.order_id,
    oi.line_number,
    oi.product_id,
    (oi.quantity * oi.unit_price) - oi.discount_amount AS net_sales,
    oi.quantity * p.unit_cost AS line_cost,
    ((oi.quantity * oi.unit_price) - oi.discount_amount)
        - (oi.quantity * p.unit_cost) AS gross_margin
FROM retail.order_items AS oi
INNER JOIN retail.products AS p
    ON p.product_id = oi.product_id
ORDER BY oi.order_id, oi.line_number;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- D. INNER JOIN / LEFT JOIN
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 46
-------------------------------------------------------------------------------
-- Return each order with its store name.

-- OUTPUT GRAIN:
-- one row per order

-- REFERENCE SOLUTION:
SELECT
    o.order_id,
    o.order_date,
    o.status,
    s.store_id,
    s.store_name
FROM retail.orders AS o
INNER JOIN retail.stores AS s
    ON s.store_id = o.store_id
ORDER BY o.order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 47
-------------------------------------------------------------------------------
-- Return each known-customer order with customer name.

-- OUTPUT GRAIN:
-- one row per known-customer order

-- REFERENCE SOLUTION:
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.customer_name
FROM retail.orders AS o
INNER JOIN retail.customers AS c
    ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 48
-------------------------------------------------------------------------------
-- Return all orders, including guest orders, with customer name if present.

-- OUTPUT GRAIN:
-- one row per order

-- REFERENCE SOLUTION:
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    c.customer_name
FROM retail.orders AS o
LEFT JOIN retail.customers AS c
    ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 49
-------------------------------------------------------------------------------
-- Return full order-line detail with product name and net line revenue.

-- OUTPUT GRAIN:
-- one row per order line

-- REFERENCE SOLUTION:
SELECT
    o.order_id,
    oi.line_number,
    o.order_date,
    p.product_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    (oi.quantity * oi.unit_price) - oi.discount_amount AS net_line_revenue
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN retail.products AS p
    ON p.product_id = oi.product_id
ORDER BY o.order_id, oi.line_number;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 50
-------------------------------------------------------------------------------
-- Return completed net sales by store.

-- OUTPUT GRAIN:
-- one row per store with completed sales

-- REFERENCE SOLUTION:
SELECT
    s.store_id,
    s.store_name,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
FROM retail.stores AS s
INNER JOIN retail.orders AS o
    ON o.store_id = s.store_id
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY
    s.store_id,
    s.store_name
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 51
-------------------------------------------------------------------------------
-- Return completed net sales by store province.

-- OUTPUT GRAIN:
-- one row per store province with completed sales

-- REFERENCE SOLUTION:
SELECT
    s.province,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
FROM retail.stores AS s
INNER JOIN retail.orders AS o
    ON o.store_id = s.store_id
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY s.province
ORDER BY s.province;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 52
-------------------------------------------------------------------------------
-- Return completed net sales by product category.

-- OUTPUT GRAIN:
-- one row per product category with completed sales

-- REFERENCE SOLUTION:
SELECT
    p.category,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN retail.products AS p
    ON p.product_id = oi.product_id
WHERE o.status = N'Completed'
GROUP BY p.category
ORDER BY p.category;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 53
-------------------------------------------------------------------------------
-- Return completed net sales by customer.

-- OUTPUT GRAIN:
-- one row per customer with completed sales

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
FROM retail.customers AS c
INNER JOIN retail.orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 54
-------------------------------------------------------------------------------
-- Return every customer and completed lifetime sales, including zero-sales customers.

-- OUTPUT GRAIN:
-- one row per customer

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount),
        0.00
    ) AS completed_lifetime_sales
FROM retail.customers AS c
LEFT JOIN retail.orders AS o
    ON o.customer_id = c.customer_id
   AND o.status = N'Completed'
LEFT JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 55
-------------------------------------------------------------------------------
-- Return every product and total units sold, including never-sold products.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold
FROM retail.products AS p
LEFT JOIN retail.order_items AS oi
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY p.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 56
-------------------------------------------------------------------------------
-- Find products never sold.

-- OUTPUT GRAIN:
-- one row per never-sold product

-- REFERENCE SOLUTION:
SELECT
    p.product_id,
    p.sku,
    p.product_name
FROM retail.products AS p
LEFT JOIN retail.order_items AS oi
    ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL
ORDER BY p.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 57
-------------------------------------------------------------------------------
-- Find customers who never placed an order.

-- OUTPUT GRAIN:
-- one row per customer with no orders

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name
FROM retail.customers AS c
LEFT JOIN retail.orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 58
-------------------------------------------------------------------------------
-- Return each store's latest inventory snapshot date.

-- OUTPUT GRAIN:
-- one row per store

-- REFERENCE SOLUTION:
SELECT
    s.store_id,
    s.store_name,
    MAX(i.snapshot_date) AS latest_snapshot_date
FROM retail.stores AS s
LEFT JOIN retail.inventory_snapshots AS i
    ON i.store_id = s.store_id
GROUP BY
    s.store_id,
    s.store_name
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 59
-------------------------------------------------------------------------------
-- Return low-stock SKUs on the latest available snapshot **for each store**.

-- OUTPUT GRAIN:
-- one row per low-stock store/product on that store's latest snapshot

-- REFERENCE SOLUTION:
SELECT
    latest.store_id,
    s.store_name,
    latest.latest_snapshot_date,
    i.product_id,
    p.sku,
    p.product_name,
    i.on_hand_qty,
    i.reorder_point
FROM
(
    SELECT
        store_id,
        MAX(snapshot_date) AS latest_snapshot_date
    FROM retail.inventory_snapshots
    GROUP BY store_id
) AS latest
INNER JOIN retail.inventory_snapshots AS i
    ON i.store_id = latest.store_id
   AND i.snapshot_date = latest.latest_snapshot_date
INNER JOIN retail.stores AS s
    ON s.store_id = latest.store_id
INNER JOIN retail.products AS p
    ON p.product_id = i.product_id
WHERE i.on_hand_qty <= i.reorder_point
ORDER BY latest.store_id, i.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 60
-------------------------------------------------------------------------------
-- Return products bought by each customer.

-- OUTPUT GRAIN:
-- one row per distinct customer/product pair

-- REFERENCE SOLUTION:
-- Assumption: "bought" means the order reached Completed status.
SELECT DISTINCT
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name
FROM retail.customers AS c
INNER JOIN retail.orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN retail.products AS p
    ON p.product_id = oi.product_id
WHERE o.status = N'Completed'
ORDER BY c.customer_id, p.product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 61
-------------------------------------------------------------------------------
-- Return completed sales by customer province.

-- OUTPUT GRAIN:
-- one row per customer province with completed sales

-- REFERENCE SOLUTION:
SELECT
    c.province,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
FROM retail.customers AS c
INNER JOIN retail.orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY c.province
ORDER BY c.province;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 62
-------------------------------------------------------------------------------
-- Return gross margin by product category.

-- OUTPUT GRAIN:
-- one row per product category

-- REFERENCE SOLUTION:
-- Assumption: realized gross margin is calculated on Completed orders.
SELECT
    p.category,
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
GROUP BY p.category
ORDER BY p.category;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- E. Join Cardinality / Duplicate Explosions
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 63
-------------------------------------------------------------------------------
-- Predict and then verify the grain after joining `orders` to `order_items`.

-- OUTPUT GRAIN:
-- one row per order line

-- REFERENCE SOLUTION:
-- Prediction:
-- retail.orders is one row per order.
-- retail.order_items is one row per order line.
-- A one-to-many join therefore produces one row per order line.
SELECT
    o.order_id,
    oi.line_number,
    o.order_date,
    oi.product_id,
    oi.quantity
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
ORDER BY o.order_id, oi.line_number;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 64
-------------------------------------------------------------------------------
-- Predict and verify the grain after joining `orders → order_items → products`.

-- OUTPUT GRAIN:
-- one row per order line enriched with product attributes

-- REFERENCE SOLUTION:
-- Adding products is many-to-one from each order line to one product,
-- so the grain remains one row per order line.
SELECT
    o.order_id,
    oi.line_number,
    p.product_id,
    p.product_name,
    oi.quantity
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN retail.products AS p
    ON p.product_id = oi.product_id
ORDER BY o.order_id, oi.line_number;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 65
-------------------------------------------------------------------------------
-- Explain why `COUNT(*)` after joining orders to items is not an order count.

-- OUTPUT GRAIN:
-- one summary row comparing joined rows with distinct orders

-- REFERENCE SOLUTION:
-- COUNT(*) counts joined order-line rows, not logical orders.
SELECT
    COUNT(*) AS joined_row_count,
    COUNT(DISTINCT o.order_id) AS distinct_order_count
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 66
-------------------------------------------------------------------------------
-- Correctly count distinct completed orders by store after joining to items.

-- OUTPUT GRAIN:
-- one row per store with completed order-item activity

-- REFERENCE SOLUTION:
SELECT
    s.store_id,
    s.store_name,
    COUNT(DISTINCT o.order_id) AS completed_order_count
FROM retail.stores AS s
INNER JOIN retail.orders AS o
    ON o.store_id = s.store_id
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY
    s.store_id,
    s.store_name
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 67
-------------------------------------------------------------------------------
-- Compute completed store revenue without double-counting.

-- OUTPUT GRAIN:
-- one row per store with completed sales

-- REFERENCE SOLUTION:
SELECT
    s.store_id,
    s.store_name,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
FROM retail.stores AS s
INNER JOIN retail.orders AS o
    ON o.store_id = s.store_id
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY
    s.store_id,
    s.store_name
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 68
-------------------------------------------------------------------------------
-- Write an intentionally wrong query that overcounts orders due to the order-item join; then fix it.

-- OUTPUT GRAIN:
-- one row per store in each demonstration result set

-- REFERENCE SOLUTION:
-- WRONG: COUNT(*) counts one row per order line after the join.
SELECT
    o.store_id,
    COUNT(*) AS wrong_order_count
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY o.store_id
ORDER BY o.store_id;

-- CORRECT: count the order key at the intended order grain.
SELECT
    o.store_id,
    COUNT(DISTINCT o.order_id) AS correct_order_count
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY o.store_id
ORDER BY o.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 69
-------------------------------------------------------------------------------
-- Show the number of line rows produced per order after joining.

-- OUTPUT GRAIN:
-- one row per order

-- REFERENCE SOLUTION:
SELECT
    o.order_id,
    COUNT(oi.line_number) AS line_row_count
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
GROUP BY o.order_id
ORDER BY o.order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 70
-------------------------------------------------------------------------------
-- Identify the order(s) with the largest number of lines.

-- OUTPUT GRAIN:
-- one row per order tied for the maximum line count

-- REFERENCE SOLUTION:
SELECT TOP (1) WITH TIES
    o.order_id,
    COUNT(*) AS line_count
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
GROUP BY o.order_id
ORDER BY COUNT(*) DESC;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 71
-------------------------------------------------------------------------------
-- Pre-aggregate order-item revenue to one row per order, then join to `orders`.

-- OUTPUT GRAIN:
-- one row per order

-- REFERENCE SOLUTION:
SELECT
    o.order_id,
    o.customer_id,
    o.store_id,
    o.order_date,
    item_totals.net_sales
FROM retail.orders AS o
INNER JOIN
(
    SELECT
        order_id,
        SUM((quantity * unit_price) - discount_amount) AS net_sales
    FROM retail.order_items
    GROUP BY order_id
) AS item_totals
    ON item_totals.order_id = o.order_id
ORDER BY o.order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 72
-------------------------------------------------------------------------------
-- Pre-aggregate inventory to one row per store and join it to a store-level sales aggregation without causing multiplication.

-- OUTPUT GRAIN:
-- one row per store

-- REFERENCE SOLUTION:
-- Both derived tables are reduced to one row per store before the join.
SELECT
    s.store_id,
    s.store_name,
    COALESCE(sales.completed_net_sales, 0.00) AS completed_net_sales,
    inventory.latest_snapshot_date,
    COALESCE(inventory.latest_on_hand_qty, 0) AS latest_on_hand_qty
FROM retail.stores AS s
LEFT JOIN
(
    SELECT
        o.store_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
    FROM retail.orders AS o
    INNER JOIN retail.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.status = N'Completed'
    GROUP BY o.store_id
) AS sales
    ON sales.store_id = s.store_id
LEFT JOIN
(
    SELECT
        latest.store_id,
        latest.latest_snapshot_date,
        SUM(i.on_hand_qty) AS latest_on_hand_qty
    FROM
    (
        SELECT
            store_id,
            MAX(snapshot_date) AS latest_snapshot_date
        FROM retail.inventory_snapshots
        GROUP BY store_id
    ) AS latest
    INNER JOIN retail.inventory_snapshots AS i
        ON i.store_id = latest.store_id
       AND i.snapshot_date = latest.latest_snapshot_date
    GROUP BY
        latest.store_id,
        latest.latest_snapshot_date
) AS inventory
    ON inventory.store_id = s.store_id
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 73
-------------------------------------------------------------------------------
-- Explain why joining two one-to-many child tables directly through a common parent can create a multiplicative explosion.

-- OUTPUT GRAIN:
-- conceptual explanation; no result-set grain

-- REFERENCE SOLUTION:
-- Explanation:
-- If a parent has N rows in child A and M rows in child B, joining both child
-- tables directly through the parent can produce N * M rows for that parent.
--
-- Example: an order with 3 order-item rows and 2 payment rows can produce
-- 3 * 2 = 6 joined rows. Measures from either child would then be repeated.
--
-- The usual fix is to pre-aggregate each child to the parent grain (for
-- example, one row per order) before joining the child results together.

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- F. UNION ALL
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 74
-------------------------------------------------------------------------------
-- Combine customer provinces and store provinces with `UNION ALL`.

-- OUTPUT GRAIN:
-- one row per contributing customer/store province occurrence; duplicates retained

-- REFERENCE SOLUTION:
SELECT
    province
FROM retail.customers

UNION ALL

SELECT
    province
FROM retail.stores;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 75
-------------------------------------------------------------------------------
-- Produce `(entity_type, entity_id, province)` for both customers and stores.

-- OUTPUT GRAIN:
-- one row per customer or store entity

-- REFERENCE SOLUTION:
SELECT
    N'Customer' AS entity_type,
    customer_id AS entity_id,
    province
FROM retail.customers

UNION ALL

SELECT
    N'Store' AS entity_type,
    store_id AS entity_id,
    province
FROM retail.stores;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 76
-------------------------------------------------------------------------------
-- Compare `UNION` and `UNION ALL` by executing both against province lists.

-- OUTPUT GRAIN:
-- one row per province value in each result set

-- REFERENCE SOLUTION:
-- UNION removes duplicate province values.
SELECT province
FROM retail.customers
UNION
SELECT province
FROM retail.stores
ORDER BY province;

-- UNION ALL retains every contributed row.
SELECT province
FROM retail.customers
UNION ALL
SELECT province
FROM retail.stores
ORDER BY province;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 77
-------------------------------------------------------------------------------
-- Combine completed and cancelled orders into one labeled result.

-- OUTPUT GRAIN:
-- one row per completed/cancelled order

-- REFERENCE SOLUTION:
SELECT
    N'Completed branch' AS branch_label,
    order_id,
    customer_id,
    store_id,
    order_date,
    status
FROM retail.orders
WHERE status = N'Completed'

UNION ALL

SELECT
    N'Cancelled branch' AS branch_label,
    order_id,
    customer_id,
    store_id,
    order_date,
    status
FROM retail.orders
WHERE status = N'Cancelled'
ORDER BY order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 78
-------------------------------------------------------------------------------
-- Build a data-quality summary containing multiple check names and counts using `UNION ALL`.

-- OUTPUT GRAIN:
-- one row per data-quality check

-- REFERENCE SOLUTION:
SELECT
    N'Customers with NULL email' AS check_name,
    COUNT(*) AS issue_count
FROM retail.customers
WHERE email IS NULL

UNION ALL

SELECT
    N'Customers with unassigned loyalty tier',
    COUNT(*)
FROM retail.customers
WHERE loyalty_tier IS NULL

UNION ALL

SELECT
    N'Guest orders',
    COUNT(*)
FROM retail.orders
WHERE customer_id IS NULL

UNION ALL

SELECT
    N'Inactive products',
    COUNT(*)
FROM retail.products
WHERE active_flag = 0

UNION ALL

SELECT
    N'Out-of-stock inventory rows',
    COUNT(*)
FROM retail.inventory_snapshots
WHERE on_hand_qty = 0;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- G. Date Functions
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 79
-------------------------------------------------------------------------------
-- Extract year, month, and day from order dates.

-- OUTPUT GRAIN:
-- one row per order

-- REFERENCE SOLUTION:
SELECT
    order_id,
    order_date,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    DAY(order_date) AS order_day
FROM retail.orders
ORDER BY order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 80
-------------------------------------------------------------------------------
-- Return order count by calendar year/month.

-- OUTPUT GRAIN:
-- one row per calendar year/month

-- REFERENCE SOLUTION:
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS order_count
FROM retail.orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 81
-------------------------------------------------------------------------------
-- Using `@as_of_date = '2026-08-15'`, return orders from the preceding 30 days.

-- OUTPUT GRAIN:
-- one row per qualifying order

-- REFERENCE SOLUTION:
DECLARE @as_of_date date = '2026-08-15';

SELECT
    order_id,
    order_date,
    status
FROM retail.orders
WHERE order_date >= DATEADD(DAY, -30, @as_of_date)
  AND order_date <  DATEADD(DAY, 1, @as_of_date)
ORDER BY order_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 82
-------------------------------------------------------------------------------
-- Return days between signup and first order for every customer who ordered.

-- OUTPUT GRAIN:
-- one row per customer who has ordered

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name,
    c.signup_date,
    MIN(o.order_date) AS first_order_date,
    DATEDIFF(DAY, c.signup_date, MIN(o.order_date)) AS days_signup_to_first_order
FROM retail.customers AS c
INNER JOIN retail.orders AS o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.signup_date
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 83
-------------------------------------------------------------------------------
-- Return month-end for each order using `EOMONTH`.

-- OUTPUT GRAIN:
-- one row per order

-- REFERENCE SOLUTION:
SELECT
    order_id,
    order_date,
    EOMONTH(order_date) AS order_month_end
FROM retail.orders
ORDER BY order_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 84
-------------------------------------------------------------------------------
-- Return inventory snapshots in June 2026.

-- OUTPUT GRAIN:
-- one row per June 2026 inventory snapshot

-- REFERENCE SOLUTION:
SELECT
    store_id,
    product_id,
    snapshot_date,
    on_hand_qty,
    reorder_point
FROM retail.inventory_snapshots
WHERE snapshot_date >= '2026-06-01'
  AND snapshot_date <  '2026-07-01'
ORDER BY store_id, product_id, snapshot_date;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 85
-------------------------------------------------------------------------------
-- Return completed sales by quarter.

-- OUTPUT GRAIN:
-- one row per calendar year/quarter

-- REFERENCE SOLUTION:
SELECT
    YEAR(o.order_date) AS order_year,
    DATEPART(QUARTER, o.order_date) AS order_quarter,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY
    YEAR(o.order_date),
    DATEPART(QUARTER, o.order_date)
ORDER BY
    order_year,
    order_quarter;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 86
-------------------------------------------------------------------------------
-- Return completed sales by month.

-- OUTPUT GRAIN:
-- one row per calendar year/month

-- REFERENCE SOLUTION:
SELECT
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS completed_net_sales
FROM retail.orders AS o
INNER JOIN retail.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status = N'Completed'
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    order_year,
    order_month;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 87
-------------------------------------------------------------------------------
-- Return the first and last order date for each customer.

-- OUTPUT GRAIN:
-- one row per customer

-- REFERENCE SOLUTION:
SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM retail.customers AS c
LEFT JOIN retail.orders AS o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 88
-------------------------------------------------------------------------------
-- Return customers whose second order occurred within 30 days of their first.

-- OUTPUT GRAIN:
-- one row per qualifying customer with at least two orders

-- REFERENCE SOLUTION:
-- This Day 1 solution uses only joins and aggregates.
-- Among all chronological order pairs for a customer, MIN(o2.order_date)
-- is the second chronological order date.
SELECT
    c.customer_id,
    c.customer_name,
    MIN(o1.order_date) AS first_order_date,
    MIN(o2.order_date) AS second_order_date,
    DATEDIFF(DAY, MIN(o1.order_date), MIN(o2.order_date)) AS days_between
FROM retail.customers AS c
INNER JOIN retail.orders AS o1
    ON o1.customer_id = c.customer_id
INNER JOIN retail.orders AS o2
    ON o2.customer_id = c.customer_id
   AND
   (
       o2.order_date > o1.order_date
       OR (o2.order_date = o1.order_date AND o2.order_id > o1.order_id)
   )
GROUP BY
    c.customer_id,
    c.customer_name
HAVING DATEDIFF(DAY, MIN(o1.order_date), MIN(o2.order_date)) <= 30
ORDER BY c.customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- H. String Functions
-- ==============================================================================

-------------------------------------------------------------------------------
-- PROBLEM 89
-------------------------------------------------------------------------------
-- Uppercase customer names.

-- OUTPUT GRAIN:
-- one row per customer

-- REFERENCE SOLUTION:
SELECT
    customer_id,
    UPPER(customer_name) AS customer_name_upper
FROM retail.customers
ORDER BY customer_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 90
-------------------------------------------------------------------------------
-- Trim incoming customer emails.

-- OUTPUT GRAIN:
-- one row per incoming customer record

-- REFERENCE SOLUTION:
SELECT
    ingestion_id,
    email_raw,
    TRIM(email_raw) AS trimmed_email
FROM staging.customers_incoming
ORDER BY ingestion_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 91
-------------------------------------------------------------------------------
-- Return first three characters of every SKU.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    sku,
    LEFT(sku, 3) AS sku_prefix
FROM retail.products
ORDER BY product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 92
-------------------------------------------------------------------------------
-- Build `SKU - Product Name`.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    CONCAT(sku, N' - ', product_name) AS product_display_label
FROM retail.products
ORDER BY product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 93
-------------------------------------------------------------------------------
-- Return product-name lengths.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    product_name,
    LEN(product_name) AS product_name_length
FROM retail.products
ORDER BY product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 94
-------------------------------------------------------------------------------
-- Replace spaces in product names with hyphens.

-- OUTPUT GRAIN:
-- one row per product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    product_name,
    REPLACE(product_name, N' ', N'-') AS hyphenated_product_name
FROM retail.products
ORDER BY product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 95
-------------------------------------------------------------------------------
-- Find products whose names contain `Wireless`.

-- OUTPUT GRAIN:
-- one row per matching product

-- REFERENCE SOLUTION:
SELECT
    product_id,
    sku,
    product_name
FROM retail.products
WHERE product_name LIKE N'%Wireless%'
ORDER BY product_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

-------------------------------------------------------------------------------
-- PROBLEM 96
-------------------------------------------------------------------------------
-- Create one comma-separated product list per category using `STRING_AGG`.

-- OUTPUT GRAIN:
-- one row per product category

-- REFERENCE SOLUTION:
SELECT
    category,
    STRING_AGG(product_name, N', ')
        WITHIN GROUP (ORDER BY product_name) AS product_names
FROM retail.products
GROUP BY category
ORDER BY category;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO


-- ==============================================================================
-- Day 1 Capstone
-- ==============================================================================

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
-- one row per store

-- REFERENCE SOLUTION:
-- Sales and inventory are each pre-aggregated to one row per store before
-- they are joined, so inventory rows cannot multiply sales rows.
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
LEFT JOIN
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
) AS sa
    ON sa.store_id = s.store_id
LEFT JOIN
(
    SELECT
        latest.store_id,
        latest.latest_snapshot_date,
        SUM(
            CASE
                WHEN i.on_hand_qty <= i.reorder_point THEN 1
                ELSE 0
            END
        ) AS low_stock_sku_count
    FROM
    (
        SELECT
            store_id,
            MAX(snapshot_date) AS latest_snapshot_date
        FROM retail.inventory_snapshots
        GROUP BY store_id
    ) AS latest
    INNER JOIN retail.inventory_snapshots AS i
        ON i.store_id = latest.store_id
       AND i.snapshot_date = latest.latest_snapshot_date
    GROUP BY
        latest.store_id,
        latest.latest_snapshot_date
) AS inv
    ON inv.store_id = s.store_id
ORDER BY s.store_id;

-- LOCAL TEST RESULT:
-- Execute this batch against RetailDEPractice and record your own result if desired.

GO

