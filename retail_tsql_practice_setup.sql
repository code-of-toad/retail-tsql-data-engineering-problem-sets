/*
    Retail SQL for Data Engineering
    SQL Server / Microsoft T-SQL
    Practice database setup

    WARNING:
    This script DROPS and recreates RetailDEPractice.
*/

USE master;
GO

IF DB_ID(N'RetailDEPractice') IS NOT NULL
BEGIN
    ALTER DATABASE RetailDEPractice SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RetailDEPractice;
END;
GO

CREATE DATABASE RetailDEPractice;
GO

USE RetailDEPractice;
GO

SET NOCOUNT ON;
GO

CREATE SCHEMA retail;
GO
CREATE SCHEMA staging;
GO

/* =========================================================
   CLEAN OPERATIONAL TABLES
   ========================================================= */

CREATE TABLE retail.customers
(
    customer_id      INT            NOT NULL,
    customer_name    NVARCHAR(100)  NOT NULL,
    email            NVARCHAR(255)  NULL,
    province         CHAR(2)        NOT NULL,
    signup_date      DATE           NOT NULL,
    loyalty_tier     NVARCHAR(20)   NULL,

    CONSTRAINT PK_customers PRIMARY KEY (customer_id),
    CONSTRAINT CK_customers_province CHECK
    (
        province IN ('AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT')
    ),
    CONSTRAINT CK_customers_loyalty CHECK
    (
        loyalty_tier IS NULL OR loyalty_tier IN (N'Bronze', N'Silver', N'Gold')
    )
);

CREATE TABLE retail.stores
(
    store_id         INT            NOT NULL,
    store_name       NVARCHAR(100)  NOT NULL,
    city             NVARCHAR(100)  NOT NULL,
    province         CHAR(2)        NOT NULL,
    opened_date      DATE           NOT NULL,

    CONSTRAINT PK_stores PRIMARY KEY (store_id),
    CONSTRAINT CK_stores_province CHECK
    (
        province IN ('AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT')
    )
);

CREATE TABLE retail.products
(
    product_id       INT            NOT NULL,
    sku              NVARCHAR(30)   NOT NULL,
    product_name     NVARCHAR(150)  NOT NULL,
    category         NVARCHAR(50)   NOT NULL,
    unit_cost        DECIMAL(10,2)  NOT NULL,
    list_price       DECIMAL(10,2)  NOT NULL,
    active_flag      BIT            NOT NULL
        CONSTRAINT DF_products_active_flag DEFAULT (1),

    CONSTRAINT PK_products PRIMARY KEY (product_id),
    CONSTRAINT UQ_products_sku UNIQUE (sku),
    CONSTRAINT CK_products_unit_cost CHECK (unit_cost >= 0),
    CONSTRAINT CK_products_list_price CHECK (list_price >= 0)
);

CREATE TABLE retail.orders
(
    order_id         INT            NOT NULL,
    customer_id      INT            NULL,
    store_id         INT            NOT NULL,
    order_date       DATETIME2(0)   NOT NULL,
    status           NVARCHAR(20)   NOT NULL,
    sales_channel    NVARCHAR(20)   NOT NULL,
    last_modified    DATETIME2(0)   NOT NULL,

    CONSTRAINT PK_orders PRIMARY KEY (order_id),
    CONSTRAINT FK_orders_customer FOREIGN KEY (customer_id)
        REFERENCES retail.customers(customer_id),
    CONSTRAINT FK_orders_store FOREIGN KEY (store_id)
        REFERENCES retail.stores(store_id),
    CONSTRAINT CK_orders_status CHECK
    (
        status IN (N'Processing', N'Shipped', N'Completed', N'Cancelled', N'Refunded')
    ),
    CONSTRAINT CK_orders_channel CHECK
    (
        sales_channel IN (N'Online', N'InStore')
    )
);

CREATE TABLE retail.order_items
(
    order_id          INT           NOT NULL,
    line_number       INT           NOT NULL,
    product_id        INT           NOT NULL,
    quantity          INT           NOT NULL,
    unit_price        DECIMAL(10,2) NOT NULL,
    discount_amount   DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_order_items_discount DEFAULT (0),

    CONSTRAINT PK_order_items PRIMARY KEY (order_id, line_number),
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id)
        REFERENCES retail.orders(order_id),
    CONSTRAINT FK_order_items_product FOREIGN KEY (product_id)
        REFERENCES retail.products(product_id),
    CONSTRAINT CK_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT CK_order_items_unit_price CHECK (unit_price >= 0),
    CONSTRAINT CK_order_items_discount CHECK (discount_amount >= 0),
    CONSTRAINT CK_order_items_discount_not_excessive
        CHECK (discount_amount <= quantity * unit_price)
);

CREATE TABLE retail.inventory_snapshots
(
    store_id          INT   NOT NULL,
    product_id        INT   NOT NULL,
    snapshot_date     DATE  NOT NULL,
    on_hand_qty       INT   NOT NULL,
    reorder_point     INT   NOT NULL,

    CONSTRAINT PK_inventory_snapshots
        PRIMARY KEY (store_id, product_id, snapshot_date),
    CONSTRAINT FK_inventory_store FOREIGN KEY (store_id)
        REFERENCES retail.stores(store_id),
    CONSTRAINT FK_inventory_product FOREIGN KEY (product_id)
        REFERENCES retail.products(product_id),
    CONSTRAINT CK_inventory_on_hand CHECK (on_hand_qty >= 0),
    CONSTRAINT CK_inventory_reorder CHECK (reorder_point >= 0)
);

/* =========================================================
   RAW / INCOMING TABLES

   These are intentionally permissive.
   Source values are stored as NVARCHAR so malformed values
   can be loaded first and validated later.
   ========================================================= */

CREATE TABLE staging.ingestion_batches
(
    batch_id          BIGINT         NOT NULL,
    source_entity     NVARCHAR(50)   NOT NULL,
    source_file       NVARCHAR(255)  NOT NULL,
    file_checksum     NVARCHAR(64)   NOT NULL,
    arrived_at        DATETIME2(0)   NOT NULL,

    CONSTRAINT PK_ingestion_batches PRIMARY KEY (batch_id)
);

CREATE TABLE staging.customers_incoming
(
    ingestion_id      BIGINT IDENTITY(1,1) NOT NULL,
    batch_id          BIGINT         NOT NULL,
    source_row_number INT            NOT NULL,
    customer_id_raw   NVARCHAR(50)   NULL,
    customer_name_raw NVARCHAR(200)  NULL,
    email_raw         NVARCHAR(255)  NULL,
    province_raw      NVARCHAR(20)   NULL,
    signup_date_raw   NVARCHAR(50)   NULL,
    loyalty_tier_raw  NVARCHAR(50)   NULL,
    modified_at_raw   NVARCHAR(50)   NULL,
    change_type_raw   NVARCHAR(20)   NULL,
    ingested_at       DATETIME2(0)   NOT NULL,

    CONSTRAINT PK_customers_incoming PRIMARY KEY (ingestion_id)
);

CREATE TABLE staging.products_incoming
(
    ingestion_id       BIGINT IDENTITY(1,1) NOT NULL,
    batch_id           BIGINT         NOT NULL,
    source_row_number  INT            NOT NULL,
    product_id_raw     NVARCHAR(50)   NULL,
    sku_raw            NVARCHAR(100)  NULL,
    product_name_raw   NVARCHAR(250)  NULL,
    category_raw       NVARCHAR(100)  NULL,
    unit_cost_raw      NVARCHAR(50)   NULL,
    list_price_raw     NVARCHAR(50)   NULL,
    active_flag_raw    NVARCHAR(20)   NULL,
    modified_at_raw    NVARCHAR(50)   NULL,
    change_type_raw    NVARCHAR(20)   NULL,
    ingested_at        DATETIME2(0)   NOT NULL,

    CONSTRAINT PK_products_incoming PRIMARY KEY (ingestion_id)
);

CREATE TABLE staging.orders_incoming
(
    ingestion_id       BIGINT IDENTITY(1,1) NOT NULL,
    batch_id           BIGINT         NOT NULL,
    source_row_number  INT            NOT NULL,
    source_order_id_raw NVARCHAR(50)  NULL,
    customer_id_raw    NVARCHAR(50)   NULL,
    store_id_raw       NVARCHAR(50)   NULL,
    order_date_raw     NVARCHAR(50)   NULL,
    status_raw         NVARCHAR(50)   NULL,
    sales_channel_raw  NVARCHAR(50)   NULL,
    modified_at_raw    NVARCHAR(50)   NULL,
    change_type_raw    NVARCHAR(20)   NULL,
    ingested_at        DATETIME2(0)   NOT NULL,

    CONSTRAINT PK_orders_incoming PRIMARY KEY (ingestion_id)
);

CREATE TABLE staging.order_items_incoming
(
    ingestion_id       BIGINT IDENTITY(1,1) NOT NULL,
    batch_id           BIGINT         NOT NULL,
    source_row_number  INT            NOT NULL,
    source_order_id_raw NVARCHAR(50)  NULL,
    line_number_raw    NVARCHAR(50)   NULL,
    product_id_raw     NVARCHAR(50)   NULL,
    quantity_raw       NVARCHAR(50)   NULL,
    unit_price_raw     NVARCHAR(50)   NULL,
    discount_amount_raw NVARCHAR(50)  NULL,
    modified_at_raw    NVARCHAR(50)   NULL,
    change_type_raw    NVARCHAR(20)   NULL,
    ingested_at        DATETIME2(0)   NOT NULL,

    CONSTRAINT PK_order_items_incoming PRIMARY KEY (ingestion_id)
);

CREATE TABLE staging.inventory_incoming
(
    ingestion_id       BIGINT IDENTITY(1,1) NOT NULL,
    batch_id           BIGINT         NOT NULL,
    source_row_number  INT            NOT NULL,
    store_id_raw       NVARCHAR(50)   NULL,
    product_id_raw     NVARCHAR(50)   NULL,
    snapshot_date_raw  NVARCHAR(50)   NULL,
    on_hand_qty_raw    NVARCHAR(50)   NULL,
    reorder_point_raw  NVARCHAR(50)   NULL,
    modified_at_raw    NVARCHAR(50)   NULL,
    ingested_at        DATETIME2(0)   NOT NULL,

    CONSTRAINT PK_inventory_incoming PRIMARY KEY (ingestion_id)
);

/* =========================================================
   CLEAN SEED DATA
   ========================================================= */

INSERT INTO retail.customers
(customer_id, customer_name, email, province, signup_date, loyalty_tier)
VALUES
(1,  N'Ava Chen',          N'ava@example.ca',       'ON', '2025-01-10', N'Gold'),
(2,  N'Liam Singh',        N'liam@example.ca',      'ON', '2025-02-15', N'Silver'),
(3,  N'Noah Tremblay',     N'noah@example.ca',      'QC', '2025-03-20', NULL),
(4,  N'Emma Brown',        N'emma@example.ca',      'BC', '2025-04-05', N'Gold'),
(5,  N'Olivia Martin',     NULL,                    'AB', '2025-04-22', N'Bronze'),
(6,  N'Jackson Wilson',    N'jackson@example.ca',   'MB', '2025-05-12', NULL),
(7,  N'Sophia Taylor',     N'sophia@example.ca',    'ON', '2025-06-07', N'Silver'),
(8,  N'Lucas Anderson',    N'lucas@example.ca',     'BC', '2025-06-30', N'Bronze'),
(9,  N'Mia Thomas',        N'mia@example.ca',       'NS', '2025-07-18', NULL),
(10, N'Ethan Moore',       N'ethan@example.ca',     'ON', '2025-08-01', N'Gold'),
(11, N'Isla White',        N'isla@example.ca',      'AB', '2025-08-19', N'Silver'),
(12, N'Leo Harris',        NULL,                    'QC', '2025-09-08', NULL),
(13, N'Amelia Clark',      N'amelia@example.ca',    'ON', '2025-09-15', N'Gold'),
(14, N'Benjamin Lewis',    N'ben@example.ca',       'BC', '2025-10-03', N'Bronze'),
(15, N'Charlotte Walker',  N'charlotte@example.ca', 'ON', '2025-11-11', NULL),
(16, N'Henry Hall',        N'henry@example.ca',     'SK', '2025-11-20', N'Silver'),
(17, N'Evelyn Young',      N'evelyn@example.ca',    'ON', '2025-12-01', N'Bronze'),
(18, N'Alexander King',    N'alex@example.ca',      'AB', '2025-12-10', NULL),
(19, N'Harper Wright',     N'harper@example.ca',    'BC', '2025-12-18', N'Silver'),
(20, N'William Scott',     N'william@example.ca',   'ON', '2026-01-05', NULL),
(21, N'Grace Adams',       N'grace@example.ca',     'NB', '2026-01-08', N'Bronze'),
(22, N'Jack Baker',        N'jack@example.ca',      'NL', '2026-01-11', NULL),
(23, N'Chloe Nelson',      N'chloe@example.ca',     'PE', '2026-01-15', N'Silver'),
(24, N'Mason Carter',      N'mason@example.ca',     'ON', '2026-01-20', N'Gold'),
(25, N'No Purchase Customer', N'nopurchase@example.ca', 'ON', '2026-02-01', NULL);

INSERT INTO retail.stores
(store_id, store_name, city, province, opened_date)
VALUES
(1, N'Mississauga Central', N'Mississauga', 'ON', '2018-05-01'),
(2, N'Toronto East',        N'Toronto',      'ON', '2019-02-14'),
(3, N'Vancouver Downtown',  N'Vancouver',    'BC', '2017-09-20'),
(4, N'Calgary North',       N'Calgary',      'AB', '2020-03-15'),
(5, N'Montreal Centre',     N'Montreal',     'QC', '2016-11-11'),
(6, N'Winnipeg South',      N'Winnipeg',     'MB', '2021-06-01'),
(7, N'Halifax Harbour',     N'Halifax',      'NS', '2022-04-10'),
(8, N'Regina East',         N'Regina',       'SK', '2023-01-20');

INSERT INTO retail.products
(product_id, sku, product_name, category, unit_cost, list_price, active_flag)
VALUES
(101, N'ELEC-001',  N'Wireless Mouse',              N'Electronics', 12.00,  29.99, 1),
(102, N'ELEC-002',  N'Wireless Keyboard',           N'Electronics', 22.00,  49.99, 1),
(103, N'ELEC-003',  N'USB-C Hub',                   N'Electronics', 18.00,  44.99, 1),
(104, N'ELEC-004',  N'27-inch Monitor',             N'Electronics', 150.00, 249.99,1),
(105, N'ELEC-005',  N'Noise Cancelling Headphones', N'Electronics', 85.00,  159.99,1),
(106, N'HOME-001',  N'Ceramic Mug',                 N'Home',        4.00,   12.99, 1),
(107, N'HOME-002',  N'Cotton Towel Set',            N'Home',        16.00,  39.99, 1),
(108, N'HOME-003',  N'Desk Lamp',                   N'Home',        14.00,  34.99, 1),
(109, N'HOME-004',  N'Storage Bin',                 N'Home',        7.50,   19.99, 1),
(110, N'GROC-001',  N'Coffee Beans 1kg',            N'Grocery',     13.00,  24.99, 1),
(111, N'GROC-002',  N'Green Tea 100ct',             N'Grocery',     6.00,   14.99, 1),
(112, N'GROC-003',  N'Olive Oil 1L',                N'Grocery',     8.00,   17.99, 1),
(113, N'SPORT-001', N'Yoga Mat',                    N'Sports',      11.00,  29.99, 1),
(114, N'SPORT-002', N'Adjustable Dumbbell',         N'Sports',      38.00,  79.99, 1),
(115, N'SPORT-003', N'Water Bottle',                N'Sports',      5.00,   14.99, 1),
(116, N'APP-001',   N'Classic Hoodie',               N'Apparel',     18.00,  44.99, 1),
(117, N'APP-002',   N'Running Socks',                N'Apparel',     4.00,   12.99, 1),
(118, N'APP-003',   N'Winter Jacket',                N'Apparel',     70.00,  139.99,1),
(119, N'TOY-001',   N'Building Block Set',           N'Toys',        20.00,  49.99, 1),
(120, N'TOY-002',   N'Board Game',                   N'Toys',        14.00,  34.99, 0),
(121, N'ACC-001',   N'Braided USB Cable',            N'Accessories', 6.00,   19.99, 1),
(122, N'ACC-002',   N'Phone Charging Cable',         N'Accessories', 6.50,   19.99, 1),
(123, N'ACC-003',   N'Cable Organizer',              N'Accessories', 3.00,   9.99,  1),
(124, N'HOME-005',  N'Decorative Vase',              N'Home',        10.00,  27.99, 1),
(125, N'SPORT-004', N'Resistance Bands',             N'Sports',      9.00,   24.99, 1);

INSERT INTO retail.orders
(order_id, customer_id, store_id, order_date, status, sales_channel, last_modified)
VALUES
(1001,1,1,'2026-01-03T10:15:00',N'Completed',N'Online','2026-01-03T10:30:00'),
(1002,2,1,'2026-01-05T13:20:00',N'Completed',N'InStore','2026-01-05T13:45:00'),
(1003,3,5,'2026-01-08T09:10:00',N'Cancelled',N'Online','2026-01-08T10:00:00'),
(1004,4,3,'2026-01-10T18:25:00',N'Completed',N'InStore','2026-01-10T18:40:00'),
(1005,NULL,2,'2026-01-12T12:00:00',N'Completed',N'InStore','2026-01-12T12:10:00'),
(1006,5,4,'2026-01-15T14:32:00',N'Shipped',N'Online','2026-01-16T08:00:00'),
(1007,1,1,'2026-01-18T11:11:00',N'Completed',N'Online','2026-01-18T11:25:00'),
(1008,6,6,'2026-01-22T16:47:00',N'Completed',N'InStore','2026-01-22T17:00:00'),
(1009,7,2,'2026-02-01T09:00:00',N'Processing',N'Online','2026-02-01T09:05:00'),
(1010,8,3,'2026-02-03T20:10:00',N'Completed',N'Online','2026-02-03T20:20:00'),
(1011,9,7,'2026-02-07T15:05:00',N'Completed',N'InStore','2026-02-07T15:20:00'),
(1012,10,1,'2026-02-10T10:30:00',N'Completed',N'Online','2026-02-10T10:40:00'),
(1013,11,4,'2026-02-14T13:15:00',N'Cancelled',N'Online','2026-02-14T13:50:00'),
(1014,12,5,'2026-02-20T08:25:00',N'Completed',N'InStore','2026-02-20T08:40:00'),
(1015,13,2,'2026-03-02T19:20:00',N'Completed',N'Online','2026-03-02T19:35:00'),
(1016,14,3,'2026-03-05T12:12:00',N'Completed',N'InStore','2026-03-05T12:30:00'),
(1017,15,1,'2026-03-08T14:45:00',N'Completed',N'Online','2026-03-08T15:00:00'),
(1018,16,8,'2026-03-12T17:25:00',N'Completed',N'InStore','2026-03-12T17:35:00'),
(1019,17,2,'2026-03-18T10:10:00',N'Refunded',N'Online','2026-03-19T09:00:00'),
(1020,18,4,'2026-03-25T11:40:00',N'Completed',N'Online','2026-03-25T11:55:00'),
(1021,19,3,'2026-04-02T16:16:00',N'Completed',N'InStore','2026-04-02T16:30:00'),
(1022,20,1,'2026-04-06T09:50:00',N'Completed',N'Online','2026-04-06T10:05:00'),
(1023,2,2,'2026-04-10T18:05:00',N'Completed',N'Online','2026-04-10T18:20:00'),
(1024,4,3,'2026-04-15T13:35:00',N'Completed',N'InStore','2026-04-15T13:50:00'),
(1025,1,1,'2026-05-01T10:00:00',N'Completed',N'Online','2026-05-01T10:15:00'),
(1026,7,2,'2026-05-07T12:30:00',N'Completed',N'Online','2026-05-07T12:45:00'),
(1027,10,1,'2026-05-11T15:20:00',N'Cancelled',N'InStore','2026-05-11T16:00:00'),
(1028,13,2,'2026-05-18T09:40:00',N'Completed',N'Online','2026-05-18T09:55:00'),
(1029,18,4,'2026-06-03T14:10:00',N'Completed',N'Online','2026-06-03T14:25:00'),
(1030,19,3,'2026-06-09T11:05:00',N'Completed',N'InStore','2026-06-09T11:20:00'),
(1031,21,7,'2026-06-15T12:00:00',N'Completed',N'Online','2026-06-15T12:10:00'),
(1032,22,5,'2026-06-20T13:00:00',N'Completed',N'Online','2026-06-20T13:12:00'),
(1033,23,7,'2026-06-25T14:00:00',N'Completed',N'InStore','2026-06-25T14:15:00'),
(1034,24,1,'2026-07-01T09:00:00',N'Completed',N'Online','2026-07-01T09:10:00'),
(1035,5,4,'2026-07-05T10:00:00',N'Completed',N'InStore','2026-07-05T10:10:00'),
(1036,6,6,'2026-07-10T11:00:00',N'Completed',N'Online','2026-07-10T11:10:00'),
(1037,8,3,'2026-07-15T12:00:00',N'Completed',N'Online','2026-07-15T12:10:00'),
(1038,11,4,'2026-07-20T13:00:00',N'Completed',N'Online','2026-07-20T13:10:00'),
(1039,14,3,'2026-07-21T13:00:00',N'Completed',N'Online','2026-07-21T13:10:00'),
(1040,17,2,'2026-07-25T14:00:00',N'Completed',N'InStore','2026-07-25T14:10:00');

INSERT INTO retail.order_items
(order_id, line_number, product_id, quantity, unit_price, discount_amount)
VALUES
(1001,1,101,2,29.99,5.00),(1001,2,110,1,24.99,0.00),
(1002,1,104,1,249.99,20.00),(1002,2,106,4,12.99,0.00),
(1003,1,105,1,159.99,0.00),
(1004,1,118,1,139.99,10.00),(1004,2,117,3,12.99,0.00),
(1005,1,106,2,12.99,0.00),(1005,2,111,1,14.99,0.00),
(1006,1,114,2,79.99,15.00),
(1007,1,102,1,49.99,0.00),(1007,2,103,1,44.99,5.00),(1007,3,108,1,34.99,0.00),
(1008,1,113,1,29.99,0.00),(1008,2,115,2,14.99,0.00),
(1009,1,105,1,159.99,10.00),
(1010,1,104,2,239.99,25.00),(1010,2,101,1,29.99,0.00),
(1011,1,119,2,49.99,5.00),(1011,2,120,1,34.99,0.00),
(1012,1,105,1,149.99,20.00),(1012,2,110,3,24.99,0.00),
(1013,1,118,1,139.99,0.00),
(1014,1,112,4,17.99,0.00),(1014,2,111,2,14.99,2.00),
(1015,1,104,1,249.99,0.00),(1015,2,102,2,49.99,10.00),
(1016,1,116,2,44.99,5.00),(1016,2,117,5,12.99,0.00),
(1017,1,103,2,44.99,0.00),(1017,2,108,2,34.99,5.00),
(1018,1,114,1,79.99,0.00),(1018,2,113,2,29.99,5.00),
(1019,1,105,1,159.99,0.00),
(1020,1,104,1,249.99,15.00),(1020,2,105,1,159.99,10.00),
(1021,1,119,1,49.99,0.00),(1021,2,106,6,12.99,5.00),
(1022,1,101,3,29.99,0.00),(1022,2,102,1,49.99,0.00),(1022,3,110,2,24.99,0.00),
(1023,1,118,1,139.99,20.00),(1023,2,116,2,44.99,0.00),
(1024,1,104,1,249.99,25.00),(1024,2,108,3,34.99,0.00),
(1025,1,105,2,159.99,30.00),(1025,2,103,1,44.99,0.00),
(1026,1,114,2,79.99,5.00),(1026,2,115,4,14.99,0.00),
(1027,1,119,1,49.99,0.00),
(1028,1,102,2,49.99,0.00),(1028,2,101,2,29.99,5.00),
(1029,1,104,1,249.99,0.00),(1029,2,118,1,139.99,10.00),
(1030,1,119,2,49.99,10.00),(1030,2,110,2,24.99,0.00),
(1031,1,107,2,39.99,0.00),(1031,2,123,2,9.99,0.00),
(1032,1,112,3,17.99,0.00),(1032,2,110,1,24.99,0.00),
(1033,1,113,2,29.99,0.00),(1033,2,125,1,24.99,0.00),
(1034,1,101,1,29.99,0.00),(1034,2,103,2,44.99,0.00),
(1035,1,116,1,44.99,0.00),(1035,2,107,1,39.99,0.00),
(1036,1,110,2,24.99,0.00),(1036,2,111,2,14.99,0.00),
(1037,1,118,1,139.99,0.00),(1037,2,115,2,14.99,0.00),
-- Intentional exact revenue tie inside Accessories:
(1038,1,121,2,19.99,0.00),
(1039,1,122,2,19.99,0.00),
(1040,1,123,1,9.99,0.00),(1040,2,119,1,49.99,0.00);

;WITH snapshot_dates AS
(
    SELECT CONVERT(date, '2026-05-31') AS snapshot_date, 1 AS seq
    UNION ALL SELECT CONVERT(date, '2026-06-30'), 2
    UNION ALL SELECT CONVERT(date, '2026-07-31'), 3
),
store_product AS
(
    SELECT s.store_id, p.product_id
    FROM retail.stores AS s
    CROSS JOIN retail.products AS p
)
INSERT INTO retail.inventory_snapshots
(store_id, product_id, snapshot_date, on_hand_qty, reorder_point)
SELECT
    sp.store_id,
    sp.product_id,
    d.snapshot_date,
    (sp.store_id * 7 + sp.product_id * 3 + d.seq * 5) % 31,
    7 + (sp.product_id % 5)
FROM store_product AS sp
CROSS JOIN snapshot_dates AS d;

-- Make store 8's latest available snapshot June 30 to force per-store MAX(date) logic.
DELETE FROM retail.inventory_snapshots
WHERE store_id = 8
  AND snapshot_date = '2026-07-31';

-- Guarantee explicit out-of-stock and low-stock rows on latest snapshots.
UPDATE retail.inventory_snapshots
SET on_hand_qty = 0
WHERE store_id = 1
  AND product_id = 101
  AND snapshot_date = '2026-07-31';

UPDATE retail.inventory_snapshots
SET on_hand_qty = reorder_point
WHERE store_id = 3
  AND product_id = 104
  AND snapshot_date = '2026-07-31';

/* =========================================================
   RAW BATCH METADATA
   ========================================================= */

INSERT INTO staging.ingestion_batches
(batch_id, source_entity, source_file, file_checksum, arrived_at)
VALUES
(9001,N'orders',N'orders_20260810_0900.csv',N'CHK-ORD-A','2026-08-10T09:05:00'),
(9002,N'orders',N'orders_20260810_0900_REPLAY.csv',N'CHK-ORD-A','2026-08-10T10:05:00'), -- exact file replay
(9003,N'orders',N'orders_20260811_0900.csv',N'CHK-ORD-B','2026-08-11T09:05:00'),
(9004,N'orders',N'orders_20260814_LATE.csv',N'CHK-ORD-C','2026-08-14T15:00:00'),
(9101,N'order_items',N'order_items_20260810.csv',N'CHK-ITEM-A','2026-08-10T09:06:00'),
(9102,N'order_items',N'order_items_20260810_REPLAY.csv',N'CHK-ITEM-A','2026-08-10T10:06:00'),
(9201,N'products',N'products_20260810.csv',N'CHK-PROD-A','2026-08-10T08:00:00'),
(9202,N'products',N'products_20260811.csv',N'CHK-PROD-B','2026-08-11T08:00:00'),
(9301,N'customers',N'customers_20260810.csv',N'CHK-CUST-A','2026-08-10T08:10:00'),
(9401,N'inventory',N'inventory_20260810.csv',N'CHK-INV-A','2026-08-10T08:20:00');

/* =========================================================
   DIRTY / VERSIONED CUSTOMER SOURCE DATA
   ========================================================= */

INSERT INTO staging.customers_incoming
(batch_id, source_row_number, customer_id_raw, customer_name_raw, email_raw, province_raw,
 signup_date_raw, loyalty_tier_raw, modified_at_raw, change_type_raw, ingested_at)
VALUES
(9301,1,N'1',N'Ava Chen',N'ava@example.ca',N'ON',N'2025-01-10',N'Gold',N'2026-08-10T07:00:00',N'UPSERT','2026-08-10T08:10:00'),
(9301,2,N'26',N'New Customer',N'new@example.ca',N'ON',N'2026-08-01',N'Bronze',N'2026-08-10T07:01:00',N'UPSERT','2026-08-10T08:10:00'),
(9301,3,N'27',N'Duplicate Email One',N'dupe@example.ca',N'BC',N'2026-08-02',N'Silver',N'2026-08-10T07:02:00',N'UPSERT','2026-08-10T08:10:00'),
(9301,4,N'28',N'Duplicate Email Two',N'dupe@example.ca',N'AB',N'2026-08-03',N'Gold',N'2026-08-10T07:03:00',N'UPSERT','2026-08-10T08:10:00'),
(9301,5,N'ABC',N'Bad Customer Id',N'badid@example.ca',N'ON',N'2026-08-04',N'Bronze',N'2026-08-10T07:04:00',N'UPSERT','2026-08-10T08:10:00'),
(9301,6,N'29',N'Bad Province',N'badprovince@example.ca',N'XX',N'2026-08-05',N'Bronze',N'2026-08-10T07:05:00',N'UPSERT','2026-08-10T08:10:00'),
(9301,7,N'30',N'Bad Signup Date',N'baddate@example.ca',N'ON',N'not-a-date',N'Bronze',N'2026-08-10T07:06:00',N'UPSERT','2026-08-10T08:10:00'),
(9301,8,N'31',N'Bad Loyalty Tier',N'badtier@example.ca',N'ON',N'2026-08-06',N'Platinum',N'2026-08-10T07:07:00',N'UPSERT','2026-08-10T08:10:00'),
(9301,9,NULL,N'Missing Customer Id',N'missing@example.ca',N'ON',N'2026-08-06',N'Bronze',N'2026-08-10T07:08:00',N'UPSERT','2026-08-10T08:10:00');

/* =========================================================
   DIRTY / VERSIONED PRODUCT SOURCE DATA
   ========================================================= */

INSERT INTO staging.products_incoming
(batch_id, source_row_number, product_id_raw, sku_raw, product_name_raw, category_raw,
 unit_cost_raw, list_price_raw, active_flag_raw, modified_at_raw, change_type_raw, ingested_at)
VALUES
-- Existing product correction / Type 1 candidate:
(9201,1,N'105',N'ELEC-005',N'Noise Cancelling Headphones',N'Electronics',N'85.00',N'169.99',N'1',N'2026-08-10T07:00:00',N'UPSERT','2026-08-10T08:00:00'),
-- Existing product attribute change suitable for SCD2 practice:
(9201,2,N'114',N'SPORT-002',N'Adjustable Dumbbell',N'Sports',N'38.00',N'84.99',N'1',N'2026-08-10T07:01:00',N'UPSERT','2026-08-10T08:00:00'),
(9202,1,N'114',N'SPORT-002',N'Adjustable Dumbbell',N'Fitness',N'39.00',N'89.99',N'1',N'2026-08-11T07:01:00',N'UPSERT','2026-08-11T08:00:00'),
-- New product:
(9201,3,N'126',N'ELEC-006',N'Webcam',N'Electronics',N'30.00',N'69.99',N'1',N'2026-08-10T07:02:00',N'UPSERT','2026-08-10T08:00:00'),
-- Duplicate SKU within incoming data:
(9201,4,N'127',N'ELEC-006',N'Duplicate SKU Product',N'Electronics',N'20.00',N'49.99',N'1',N'2026-08-10T07:03:00',N'UPSERT','2026-08-10T08:00:00'),
-- Negative cost:
(9201,5,N'128',N'BAD-001',N'Negative Cost',N'Home',N'-5.00',N'20.00',N'1',N'2026-08-10T07:04:00',N'UPSERT','2026-08-10T08:00:00'),
-- Negative price:
(9201,6,N'129',N'BAD-002',N'Negative Price',N'Home',N'5.00',N'-20.00',N'1',N'2026-08-10T07:05:00',N'UPSERT','2026-08-10T08:00:00'),
-- Cost greater than list price:
(9201,7,N'130',N'BAD-003',N'Cost Above Price',N'Home',N'50.00',N'20.00',N'1',N'2026-08-10T07:06:00',N'UPSERT','2026-08-10T08:00:00'),
-- Malformed numeric:
(9201,8,N'131',N'BAD-004',N'Malformed Cost',N'Home',N'abc',N'20.00',N'1',N'2026-08-10T07:07:00',N'UPSERT','2026-08-10T08:00:00'),
-- Delete/tombstone of existing product:
(9202,2,N'120',N'TOY-002',N'Board Game',N'Toys',N'14.00',N'34.99',N'0',N'2026-08-11T07:02:00',N'DELETE','2026-08-11T08:00:00'),
-- Missing business key:
(9201,9,NULL,N'BAD-005',N'Missing Product Id',N'Home',N'10.00',N'20.00',N'1',N'2026-08-10T07:08:00',N'UPSERT','2026-08-10T08:00:00');

/* =========================================================
   DIRTY / VERSIONED ORDER SOURCE DATA
   ========================================================= */

INSERT INTO staging.orders_incoming
(batch_id, source_row_number, source_order_id_raw, customer_id_raw, store_id_raw,
 order_date_raw, status_raw, sales_channel_raw, modified_at_raw, change_type_raw, ingested_at)
VALUES
-- Valid new order, older version:
(9001,1,N'2001',N'1',N'1',N'2026-08-10T08:00:00',N'Processing',N'Online',N'2026-08-10T08:05:00',N'UPSERT','2026-08-10T09:05:00'),
-- Same business key, newer version:
(9003,1,N'2001',N'1',N'1',N'2026-08-10T08:00:00',N'Completed',N'Online',N'2026-08-11T08:00:00',N'UPSERT','2026-08-11T09:05:00'),
(9001,2,N'2002',N'2',N'2',N'2026-08-10T08:30:00',N'Completed',N'InStore',N'2026-08-10T08:35:00',N'UPSERT','2026-08-10T09:05:00'),
-- Guest order:
(9001,3,N'2003',NULL,N'1',N'2026-08-10T09:00:00',N'Completed',N'InStore',N'2026-08-10T09:01:00',N'UPSERT','2026-08-10T09:05:00'),
-- NULL business key:
(9001,4,NULL,N'4',N'3',N'2026-08-10T09:10:00',N'Completed',N'Online',N'2026-08-10T09:11:00',N'UPSERT','2026-08-10T09:05:00'),
-- Blank business key:
(9001,5,N'',N'4',N'3',N'2026-08-10T09:20:00',N'Completed',N'Online',N'2026-08-10T09:21:00',N'UPSERT','2026-08-10T09:05:00'),
-- Orphan customer:
(9001,6,N'2004',N'999',N'1',N'2026-08-10T09:30:00',N'Completed',N'Online',N'2026-08-10T09:31:00',N'UPSERT','2026-08-10T09:05:00'),
-- Orphan store:
(9001,7,N'2005',N'5',N'999',N'2026-08-10T09:40:00',N'Completed',N'Online',N'2026-08-10T09:41:00',N'UPSERT','2026-08-10T09:05:00'),
-- Malformed store:
(9001,8,N'2006',N'5',N'ABC',N'2026-08-10T09:50:00',N'Completed',N'Online',N'2026-08-10T09:51:00',N'UPSERT','2026-08-10T09:05:00'),
-- Invalid status:
(9001,9,N'2007',N'6',N'6',N'2026-08-10T10:00:00',N'UNKNOWN',N'Online',N'2026-08-10T10:01:00',N'UPSERT','2026-08-10T09:05:00'),
-- Invalid channel:
(9001,10,N'2008',N'7',N'2',N'2026-08-10T10:10:00',N'Completed',N'MobileApp',N'2026-08-10T10:11:00',N'UPSERT','2026-08-10T09:05:00'),
-- Malformed date:
(9001,11,N'2009',N'8',N'3',N'not-a-date',N'Completed',N'Online',N'2026-08-10T10:21:00',N'UPSERT','2026-08-10T09:05:00'),
-- Future date relative to project date:
(9001,12,N'2010',N'9',N'7',N'2099-01-01T10:00:00',N'Completed',N'Online',N'2026-08-10T10:31:00',N'UPSERT','2026-08-10T09:05:00'),
-- Malformed customer:
(9001,13,N'2011',N'XYZ',N'1',N'2026-08-10T11:00:00',N'Completed',N'Online',N'2026-08-10T11:01:00',N'UPSERT','2026-08-10T09:05:00'),
-- Existing target correction:
(9003,2,N'1012',N'10',N'1',N'2026-02-10T10:30:00',N'Completed',N'Online',N'2026-08-11T08:10:00',N'UPSERT','2026-08-11T09:05:00'),
-- Existing target deletion/tombstone:
(9003,3,N'1020',N'18',N'4',N'2026-03-25T11:40:00',N'Completed',N'Online',N'2026-08-11T08:20:00',N'DELETE','2026-08-11T09:05:00'),
-- Tie case: same business key and same modified timestamp, different ingested_at:
(9003,4,N'2012',N'11',N'4',N'2026-08-11T11:00:00',N'Processing',N'Online',N'2026-08-11T11:05:00',N'UPSERT','2026-08-11T11:10:00'),
(9003,5,N'2012',N'11',N'4',N'2026-08-11T11:00:00',N'Shipped',N'Online',N'2026-08-11T11:05:00',N'UPSERT','2026-08-11T11:11:00'),
-- Late-arriving valid business event: old order_date and modified_at, much later ingestion:
(9004,1,N'2013',N'12',N'5',N'2026-08-03T12:00:00',N'Completed',N'Online',N'2026-08-03T12:05:00',N'UPSERT','2026-08-14T15:00:00');

-- Exact replay of the first three valid source rows from batch 9001 under same checksum.
INSERT INTO staging.orders_incoming
(batch_id, source_row_number, source_order_id_raw, customer_id_raw, store_id_raw,
 order_date_raw, status_raw, sales_channel_raw, modified_at_raw, change_type_raw, ingested_at)
VALUES
(9002,1,N'2001',N'1',N'1',N'2026-08-10T08:00:00',N'Processing',N'Online',N'2026-08-10T08:05:00',N'UPSERT','2026-08-10T10:05:00'),
(9002,2,N'2002',N'2',N'2',N'2026-08-10T08:30:00',N'Completed',N'InStore',N'2026-08-10T08:35:00',N'UPSERT','2026-08-10T10:05:00'),
(9002,3,N'2003',NULL,N'1',N'2026-08-10T09:00:00',N'Completed',N'InStore',N'2026-08-10T09:01:00',N'UPSERT','2026-08-10T10:05:00');

/* =========================================================
   DIRTY ORDER-ITEM SOURCE DATA
   ========================================================= */

INSERT INTO staging.order_items_incoming
(batch_id, source_row_number, source_order_id_raw, line_number_raw, product_id_raw,
 quantity_raw, unit_price_raw, discount_amount_raw, modified_at_raw, change_type_raw, ingested_at)
VALUES
-- Valid:
(9101,1,N'2001',N'1',N'101',N'2',N'29.99',N'0.00',N'2026-08-10T08:05:00',N'UPSERT','2026-08-10T09:06:00'),
(9101,2,N'2001',N'2',N'110',N'1',N'24.99',N'2.00',N'2026-08-10T08:05:00',N'UPSERT','2026-08-10T09:06:00'),
(9101,3,N'2002',N'1',N'104',N'1',N'249.99',N'10.00',N'2026-08-10T08:35:00',N'UPSERT','2026-08-10T09:06:00'),
-- Orphan source order:
(9101,4,N'9999',N'1',N'101',N'1',N'29.99',N'0.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Orphan product:
(9101,5,N'2002',N'2',N'999',N'1',N'10.00',N'0.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Zero quantity:
(9101,6,N'2002',N'3',N'101',N'0',N'29.99',N'0.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Negative quantity:
(9101,7,N'2002',N'4',N'101',N'-2',N'29.99',N'0.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Malformed quantity:
(9101,8,N'2002',N'5',N'101',N'two',N'29.99',N'0.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Negative unit price:
(9101,9,N'2002',N'6',N'101',N'1',N'-29.99',N'0.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Malformed unit price:
(9101,10,N'2002',N'7',N'101',N'1',N'abc',N'0.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Negative discount:
(9101,11,N'2002',N'8',N'101',N'1',N'29.99',N'-1.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Discount greater than gross:
(9101,12,N'2002',N'9',N'101',N'1',N'29.99',N'50.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Missing line number:
(9101,13,N'2002',NULL,N'101',N'1',N'29.99',N'0.00',N'2026-08-10T09:00:00',N'UPSERT','2026-08-10T09:06:00'),
-- Duplicate composite business key/version:
(9101,14,N'2003',N'1',N'106',N'2',N'12.99',N'0.00',N'2026-08-10T09:01:00',N'UPSERT','2026-08-10T09:06:00'),
(9101,15,N'2003',N'1',N'106',N'3',N'12.99',N'0.00',N'2026-08-10T09:10:00',N'UPSERT','2026-08-10T09:11:00');

-- Replay valid item rows under identical file checksum.
INSERT INTO staging.order_items_incoming
(batch_id, source_row_number, source_order_id_raw, line_number_raw, product_id_raw,
 quantity_raw, unit_price_raw, discount_amount_raw, modified_at_raw, change_type_raw, ingested_at)
VALUES
(9102,1,N'2001',N'1',N'101',N'2',N'29.99',N'0.00',N'2026-08-10T08:05:00',N'UPSERT','2026-08-10T10:06:00'),
(9102,2,N'2001',N'2',N'110',N'1',N'24.99',N'2.00',N'2026-08-10T08:05:00',N'UPSERT','2026-08-10T10:06:00'),
(9102,3,N'2002',N'1',N'104',N'1',N'249.99',N'10.00',N'2026-08-10T08:35:00',N'UPSERT','2026-08-10T10:06:00');

/* =========================================================
   DIRTY INVENTORY SOURCE DATA
   ========================================================= */

INSERT INTO staging.inventory_incoming
(batch_id, source_row_number, store_id_raw, product_id_raw, snapshot_date_raw,
 on_hand_qty_raw, reorder_point_raw, modified_at_raw, ingested_at)
VALUES
(9401,1,N'1',N'101',N'2026-08-10',N'12',N'8',N'2026-08-10T07:00:00','2026-08-10T08:20:00'),
(9401,2,N'1',N'101',N'2026-08-10',N'10',N'8',N'2026-08-10T07:05:00','2026-08-10T08:20:00'), -- duplicate version
(9401,3,N'999',N'101',N'2026-08-10',N'10',N'8',N'2026-08-10T07:10:00','2026-08-10T08:20:00'), -- orphan store
(9401,4,N'1',N'999',N'2026-08-10',N'10',N'8',N'2026-08-10T07:11:00','2026-08-10T08:20:00'), -- orphan product
(9401,5,N'1',N'102',N'not-a-date',N'10',N'8',N'2026-08-10T07:12:00','2026-08-10T08:20:00'), -- malformed date
(9401,6,N'1',N'103',N'2026-08-10',N'-5',N'8',N'2026-08-10T07:13:00','2026-08-10T08:20:00'), -- negative on hand
(9401,7,N'1',N'104',N'2026-08-10',N'abc',N'8',N'2026-08-10T07:14:00','2026-08-10T08:20:00'), -- malformed on hand
(9401,8,N'1',N'105',N'2026-08-10',N'10',N'-1',N'2026-08-10T07:15:00','2026-08-10T08:20:00'); -- negative reorder point

PRINT 'RetailDEPractice created successfully.';
PRINT 'Next: run sql/00_setup/retail_tsql_seed_validation.sql';
GO
