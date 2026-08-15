/*
    Seed validation for RetailDEPractice.
    Run AFTER retail_tsql_practice_setup.sql.

    This script verifies that the practice database actually contains
    the deterministic edge cases required by the problem set.
*/

USE RetailDEPractice;
GO

SET NOCOUNT ON;

-- Clean-model sanity.
IF (SELECT COUNT(*) FROM retail.customers) < 25
    THROW 51000, 'Seed validation failed: insufficient customers.', 1;

IF (SELECT COUNT(*) FROM retail.products) < 25
    THROW 51001, 'Seed validation failed: insufficient products.', 1;

IF (SELECT COUNT(*) FROM retail.orders) < 40
    THROW 51002, 'Seed validation failed: insufficient orders.', 1;

IF NOT EXISTS (SELECT 1 FROM retail.orders WHERE customer_id IS NULL)
    THROW 51003, 'Seed validation failed: no guest order.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM retail.customers AS c
    WHERE NOT EXISTS
    (
        SELECT 1 FROM retail.orders AS o WHERE o.customer_id = c.customer_id
    )
)
    THROW 51004, 'Seed validation failed: no customer without orders.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM retail.products AS p
    WHERE NOT EXISTS
    (
        SELECT 1 FROM retail.order_items AS oi WHERE oi.product_id = p.product_id
    )
)
    THROW 51005, 'Seed validation failed: no never-sold product.', 1;

IF NOT EXISTS (SELECT 1 FROM retail.order_items WHERE discount_amount > 0)
    THROW 51006, 'Seed validation failed: no discounted line.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM retail.inventory_snapshots
    WHERE on_hand_qty = 0
)
    THROW 51007, 'Seed validation failed: no out-of-stock inventory row.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM retail.inventory_snapshots
    WHERE on_hand_qty <= reorder_point
)
    THROW 51008, 'Seed validation failed: no low-stock inventory row.', 1;

IF (SELECT MAX(snapshot_date) FROM retail.inventory_snapshots WHERE store_id = 8) <> '2026-06-30'
    THROW 51009, 'Seed validation failed: store-specific latest snapshot edge case missing.', 1;

-- Guaranteed ranking tie: products 121 and 122 have equal completed revenue.
DECLARE @rev121 DECIMAL(18,2);
DECLARE @rev122 DECIMAL(18,2);

SELECT @rev121 = SUM(oi.quantity * oi.unit_price - oi.discount_amount)
FROM retail.order_items AS oi
JOIN retail.orders AS o ON o.order_id = oi.order_id
WHERE oi.product_id = 121 AND o.status = N'Completed';

SELECT @rev122 = SUM(oi.quantity * oi.unit_price - oi.discount_amount)
FROM retail.order_items AS oi
JOIN retail.orders AS o ON o.order_id = oi.order_id
WHERE oi.product_id = 122 AND o.status = N'Completed';

IF @rev121 IS NULL OR @rev122 IS NULL OR @rev121 <> @rev122
    THROW 51010, 'Seed validation failed: deterministic ranking tie missing.', 1;

-- File replay.
IF NOT EXISTS
(
    SELECT file_checksum
    FROM staging.ingestion_batches
    GROUP BY source_entity, file_checksum
    HAVING COUNT(*) > 1
)
    THROW 51011, 'Seed validation failed: duplicate-file checksum case missing.', 1;

-- Incoming customer defects.
IF NOT EXISTS
(
    SELECT email_raw
    FROM staging.customers_incoming
    WHERE NULLIF(LTRIM(RTRIM(email_raw)), N'') IS NOT NULL
    GROUP BY email_raw
    HAVING COUNT(*) > 1
)
    THROW 51012, 'Seed validation failed: duplicate incoming customer email missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.customers_incoming
    WHERE customer_id_raw IS NOT NULL
      AND TRY_CONVERT(INT, customer_id_raw) IS NULL
)
    THROW 51013, 'Seed validation failed: malformed customer ID missing.', 1;

-- Incoming product defects.
IF NOT EXISTS
(
    SELECT sku_raw
    FROM staging.products_incoming
    WHERE sku_raw IS NOT NULL
    GROUP BY sku_raw
    HAVING COUNT(*) > 1
)
    THROW 51014, 'Seed validation failed: duplicate incoming SKU missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.products_incoming
    WHERE TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) < 0
)
    THROW 51015, 'Seed validation failed: negative product cost missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.products_incoming
    WHERE TRY_CONVERT(DECIMAL(10,2), list_price_raw) < 0
)
    THROW 51016, 'Seed validation failed: negative product price missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.products_incoming
    WHERE TRY_CONVERT(DECIMAL(10,2), unit_cost_raw)
        > TRY_CONVERT(DECIMAL(10,2), list_price_raw)
)
    THROW 51017, 'Seed validation failed: cost-above-price case missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.products_incoming
    WHERE unit_cost_raw IS NOT NULL
      AND TRY_CONVERT(DECIMAL(10,2), unit_cost_raw) IS NULL
)
    THROW 51018, 'Seed validation failed: malformed product cost missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.products_incoming
    WHERE UPPER(change_type_raw) = N'DELETE'
)
    THROW 51019, 'Seed validation failed: product tombstone missing.', 1;

-- Incoming order duplicates / tie / invalid values.
IF NOT EXISTS
(
    SELECT source_order_id_raw
    FROM staging.orders_incoming
    WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NOT NULL
    GROUP BY source_order_id_raw
    HAVING COUNT(*) > 1
)
    THROW 51020, 'Seed validation failed: duplicate incoming order versions missing.', 1;

IF NOT EXISTS
(
    SELECT source_order_id_raw, modified_at_raw
    FROM staging.orders_incoming
    WHERE NULLIF(LTRIM(RTRIM(source_order_id_raw)), N'') IS NOT NULL
    GROUP BY source_order_id_raw, modified_at_raw
    HAVING COUNT(*) > 1
)
    THROW 51021, 'Seed validation failed: deduplication timestamp tie missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.orders_incoming
    WHERE source_order_id_raw IS NULL OR LTRIM(RTRIM(source_order_id_raw)) = N''
)
    THROW 51022, 'Seed validation failed: missing order business key case missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.orders_incoming
    WHERE order_date_raw IS NOT NULL
      AND TRY_CONVERT(DATETIME2(0), order_date_raw) IS NULL
)
    THROW 51023, 'Seed validation failed: malformed order date missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.orders_incoming
    WHERE TRY_CONVERT(DATETIME2(0), order_date_raw) > '2026-08-15T23:59:59'
)
    THROW 51024, 'Seed validation failed: future-dated order missing.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM staging.orders_incoming AS s
    WHERE TRY_CONVERT(INT, s.customer_id_raw) IS NOT NULL
      AND s.customer_id_raw IS NOT NULL
      AND NOT EXISTS
      (
          SELECT 1
          FROM retail.customers AS c
          WHERE c.customer_id = TRY_CONVERT(INT, s.customer_id_raw)
      )
)
    THROW 51025, 'Seed validation failed: orphan incoming customer reference missing.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM staging.orders_incoming AS s
    WHERE TRY_CONVERT(INT, s.store_id_raw) IS NOT NULL
      AND NOT EXISTS
      (
          SELECT 1
          FROM retail.stores AS st
          WHERE st.store_id = TRY_CONVERT(INT, s.store_id_raw)
      )
)
    THROW 51026, 'Seed validation failed: orphan incoming store reference missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.orders_incoming
    WHERE status_raw NOT IN (N'Processing', N'Shipped', N'Completed', N'Cancelled', N'Refunded')
)
    THROW 51027, 'Seed validation failed: invalid order status missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.orders_incoming
    WHERE sales_channel_raw NOT IN (N'Online', N'InStore')
)
    THROW 51028, 'Seed validation failed: invalid sales channel missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.orders_incoming
    WHERE UPPER(change_type_raw) = N'DELETE'
)
    THROW 51029, 'Seed validation failed: order tombstone missing.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM staging.orders_incoming
    WHERE ingested_at >= '2026-08-14'
      AND TRY_CONVERT(DATETIME2(0), order_date_raw) < '2026-08-05'
)
    THROW 51030, 'Seed validation failed: late-arriving order missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.orders_incoming
    WHERE TRY_CONVERT(INT, source_order_id_raw) = 1012
)
    THROW 51031, 'Seed validation failed: existing-target correction missing.', 1;

-- Incoming item defects.
IF NOT EXISTS
(
    SELECT 1 FROM staging.order_items_incoming
    WHERE TRY_CONVERT(INT, quantity_raw) = 0
)
    THROW 51032, 'Seed validation failed: zero quantity missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.order_items_incoming
    WHERE TRY_CONVERT(INT, quantity_raw) < 0
)
    THROW 51033, 'Seed validation failed: negative quantity missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.order_items_incoming
    WHERE quantity_raw IS NOT NULL AND TRY_CONVERT(INT, quantity_raw) IS NULL
)
    THROW 51034, 'Seed validation failed: malformed quantity missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.order_items_incoming
    WHERE TRY_CONVERT(DECIMAL(10,2), unit_price_raw) < 0
)
    THROW 51035, 'Seed validation failed: negative unit price missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.order_items_incoming
    WHERE unit_price_raw IS NOT NULL
      AND TRY_CONVERT(DECIMAL(10,2), unit_price_raw) IS NULL
)
    THROW 51036, 'Seed validation failed: malformed unit price missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.order_items_incoming
    WHERE TRY_CONVERT(DECIMAL(10,2), discount_amount_raw) < 0
)
    THROW 51037, 'Seed validation failed: negative discount missing.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM staging.order_items_incoming
    WHERE TRY_CONVERT(INT, quantity_raw) > 0
      AND TRY_CONVERT(DECIMAL(10,2), unit_price_raw) >= 0
      AND TRY_CONVERT(DECIMAL(10,2), discount_amount_raw)
          > TRY_CONVERT(INT, quantity_raw) * TRY_CONVERT(DECIMAL(10,2), unit_price_raw)
)
    THROW 51038, 'Seed validation failed: excessive discount missing.', 1;

IF NOT EXISTS
(
    SELECT source_order_id_raw, line_number_raw
    FROM staging.order_items_incoming
    WHERE source_order_id_raw IS NOT NULL AND line_number_raw IS NOT NULL
    GROUP BY source_order_id_raw, line_number_raw
    HAVING COUNT(*) > 1
)
    THROW 51039, 'Seed validation failed: duplicate incoming order-line key missing.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM staging.order_items_incoming AS i
    WHERE TRY_CONVERT(INT, i.product_id_raw) IS NOT NULL
      AND NOT EXISTS
      (
          SELECT 1
          FROM retail.products AS p
          WHERE p.product_id = TRY_CONVERT(INT, i.product_id_raw)
      )
)
    THROW 51040, 'Seed validation failed: orphan product reference missing.', 1;

-- Incoming inventory defects.
IF NOT EXISTS
(
    SELECT store_id_raw, product_id_raw, snapshot_date_raw
    FROM staging.inventory_incoming
    GROUP BY store_id_raw, product_id_raw, snapshot_date_raw
    HAVING COUNT(*) > 1
)
    THROW 51041, 'Seed validation failed: duplicate inventory snapshot version missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.inventory_incoming
    WHERE TRY_CONVERT(INT, on_hand_qty_raw) < 0
)
    THROW 51042, 'Seed validation failed: negative inventory quantity missing.', 1;

IF NOT EXISTS
(
    SELECT 1 FROM staging.inventory_incoming
    WHERE on_hand_qty_raw IS NOT NULL AND TRY_CONVERT(INT, on_hand_qty_raw) IS NULL
)
    THROW 51043, 'Seed validation failed: malformed inventory quantity missing.', 1;

PRINT 'ALL SEED VALIDATION CHECKS PASSED';
GO
