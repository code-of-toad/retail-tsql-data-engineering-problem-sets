/*
Retail T-SQL Data Engineering Practice Database
Dialect: Microsoft SQL Server T-SQL
Purpose: Supports the companion 3-day problem sets.

WARNING:
This script drops and recreates the practice database.
*/

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

CREATE SCHEMA retail;
GO
CREATE SCHEMA staging;
GO
CREATE SCHEMA control;
GO
CREATE SCHEMA warehouse;
GO

CREATE TABLE retail.customers (
    customer_id     INT            NOT NULL CONSTRAINT PK_customers PRIMARY KEY,
    customer_name   NVARCHAR(100)  NOT NULL,
    email           NVARCHAR(255)  NULL,
    province        CHAR(2)        NOT NULL,
    signup_date     DATE           NOT NULL,
    loyalty_tier    NVARCHAR(20)   NULL
);

CREATE TABLE retail.stores (
    store_id        INT            NOT NULL CONSTRAINT PK_stores PRIMARY KEY,
    store_name      NVARCHAR(100)  NOT NULL,
    city            NVARCHAR(100)  NOT NULL,
    province        CHAR(2)        NOT NULL,
    opened_date     DATE           NOT NULL
);

CREATE TABLE retail.products (
    product_id      INT            NOT NULL CONSTRAINT PK_products PRIMARY KEY,
    sku             NVARCHAR(30)   NOT NULL CONSTRAINT UQ_products_sku UNIQUE,
    product_name    NVARCHAR(150)  NOT NULL,
    category        NVARCHAR(50)   NOT NULL,
    unit_cost       DECIMAL(10,2)  NOT NULL,
    list_price      DECIMAL(10,2)  NOT NULL,
    active_flag     BIT            NOT NULL CONSTRAINT DF_products_active DEFAULT (1)
);

CREATE TABLE retail.orders (
    order_id        INT            NOT NULL CONSTRAINT PK_orders PRIMARY KEY,
    customer_id     INT            NULL,
    store_id        INT            NOT NULL,
    order_date      DATETIME2(0)   NOT NULL,
    status          NVARCHAR(20)   NOT NULL,
    sales_channel   NVARCHAR(20)   NOT NULL,
    last_modified   DATETIME2(0)   NOT NULL,
    CONSTRAINT FK_orders_customer FOREIGN KEY (customer_id)
        REFERENCES retail.customers(customer_id),
    CONSTRAINT FK_orders_store FOREIGN KEY (store_id)
        REFERENCES retail.stores(store_id)
);

CREATE TABLE retail.order_items (
    order_id         INT           NOT NULL,
    line_number      INT           NOT NULL,
    product_id       INT           NOT NULL,
    quantity         INT           NOT NULL,
    unit_price       DECIMAL(10,2) NOT NULL,
    discount_amount  DECIMAL(10,2) NOT NULL CONSTRAINT DF_order_items_discount DEFAULT (0),
    CONSTRAINT PK_order_items PRIMARY KEY (order_id, line_number),
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id)
        REFERENCES retail.orders(order_id),
    CONSTRAINT FK_order_items_product FOREIGN KEY (product_id)
        REFERENCES retail.products(product_id),
    CONSTRAINT CK_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT CK_order_items_price CHECK (unit_price >= 0),
    CONSTRAINT CK_order_items_discount CHECK (discount_amount >= 0)
);

CREATE TABLE retail.inventory_snapshots (
    store_id        INT   NOT NULL,
    product_id      INT   NOT NULL,
    snapshot_date   DATE  NOT NULL,
    on_hand_qty     INT   NOT NULL,
    reorder_point   INT   NOT NULL,
    CONSTRAINT PK_inventory_snapshots
        PRIMARY KEY (store_id, product_id, snapshot_date),
    CONSTRAINT FK_inventory_store FOREIGN KEY (store_id)
        REFERENCES retail.stores(store_id),
    CONSTRAINT FK_inventory_product FOREIGN KEY (product_id)
        REFERENCES retail.products(product_id),
    CONSTRAINT CK_inventory_on_hand CHECK (on_hand_qty >= 0),
    CONSTRAINT CK_inventory_reorder CHECK (reorder_point >= 0)
);

CREATE TABLE staging.orders_incoming (
    ingestion_id     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_orders_incoming PRIMARY KEY,
    source_order_id  INT               NULL,
    customer_id      INT               NULL,
    store_id         INT               NOT NULL,
    order_date       DATETIME2(0)      NULL,
    status           NVARCHAR(20)      NOT NULL,
    sales_channel    NVARCHAR(20)      NOT NULL,
    modified_at      DATETIME2(0)      NOT NULL,
    ingested_at      DATETIME2(0)      NOT NULL,
    source_file      NVARCHAR(255)     NOT NULL
);

INSERT INTO retail.customers
(customer_id, customer_name, email, province, signup_date, loyalty_tier)
VALUES
(1,N'Ava Chen',N'ava@example.ca','ON','2025-01-10',N'Gold'),
(2,N'Liam Singh',N'liam@example.ca','ON','2025-02-15',N'Silver'),
(3,N'Noah Tremblay',N'noah@example.ca','QC','2025-03-20',NULL),
(4,N'Emma Brown',N'emma@example.ca','BC','2025-04-05',N'Gold'),
(5,N'Olivia Martin',NULL,'AB','2025-04-22',N'Bronze'),
(6,N'Jackson Wilson',N'jackson@example.ca','MB','2025-05-12',NULL),
(7,N'Sophia Taylor',N'sophia@example.ca','ON','2025-06-07',N'Silver'),
(8,N'Lucas Anderson',N'lucas@example.ca','BC','2025-06-30',N'Bronze'),
(9,N'Mia Thomas',N'mia@example.ca','NS','2025-07-18',NULL),
(10,N'Ethan Moore',N'ethan@example.ca','ON','2025-08-01',N'Gold'),
(11,N'Isla White',N'isla@example.ca','AB','2025-08-19',N'Silver'),
(12,N'Leo Harris',NULL,'QC','2025-09-08',NULL),
(13,N'Amelia Clark',N'amelia@example.ca','ON','2025-09-15',N'Gold'),
(14,N'Benjamin Lewis',N'ben@example.ca','BC','2025-10-03',N'Bronze'),
(15,N'Charlotte Walker',N'charlotte@example.ca','ON','2025-11-11',NULL),
(16,N'Henry Hall',N'henry@example.ca','SK','2025-11-20',N'Silver'),
(17,N'Evelyn Young',N'evelyn@example.ca','ON','2025-12-01',N'Bronze'),
(18,N'Alexander King',N'alex@example.ca','AB','2025-12-10',NULL),
(19,N'Harper Wright',N'harper@example.ca','BC','2025-12-18',N'Silver'),
(20,N'William Scott',N'william@example.ca','ON','2026-01-05',NULL),
(21,N'No Purchase Customer',N'nopurchase@example.ca','ON','2026-01-10',NULL);

INSERT INTO retail.stores
(store_id, store_name, city, province, opened_date)
VALUES
(1,N'Mississauga Central',N'Mississauga','ON','2018-05-01'),
(2,N'Toronto East',N'Toronto','ON','2019-02-14'),
(3,N'Vancouver Downtown',N'Vancouver','BC','2017-09-20'),
(4,N'Calgary North',N'Calgary','AB','2020-03-15'),
(5,N'Montreal Centre',N'Montreal','QC','2016-11-11'),
(6,N'Winnipeg South',N'Winnipeg','MB','2021-06-01'),
(7,N'Halifax Harbour',N'Halifax','NS','2022-04-10'),
(8,N'Regina East',N'Regina','SK','2023-01-20');

INSERT INTO retail.products
(product_id, sku, product_name, category, unit_cost, list_price, active_flag)
VALUES
(101,N'ELEC-001',N'Wireless Mouse',N'Electronics',12.00,29.99,1),
(102,N'ELEC-002',N'Wireless Keyboard',N'Electronics',22.00,49.99,1),
(103,N'ELEC-003',N'USB-C Hub',N'Electronics',18.00,44.99,1),
(104,N'ELEC-004',N'27-inch Monitor',N'Electronics',150.00,249.99,1),
(105,N'ELEC-005',N'Noise Cancelling Headphones',N'Electronics',85.00,159.99,1),
(106,N'HOME-001',N'Ceramic Mug',N'Home',4.00,12.99,1),
(107,N'HOME-002',N'Cotton Towel Set',N'Home',16.00,39.99,1),
(108,N'HOME-003',N'Desk Lamp',N'Home',14.00,34.99,1),
(109,N'HOME-004',N'Storage Bin',N'Home',7.50,19.99,1),
(110,N'GROC-001',N'Coffee Beans 1kg',N'Grocery',13.00,24.99,1),
(111,N'GROC-002',N'Green Tea 100ct',N'Grocery',6.00,14.99,1),
(112,N'GROC-003',N'Olive Oil 1L',N'Grocery',8.00,17.99,1),
(113,N'SPORT-001',N'Yoga Mat',N'Sports',11.00,29.99,1),
(114,N'SPORT-002',N'Adjustable Dumbbell',N'Sports',38.00,79.99,1),
(115,N'SPORT-003',N'Water Bottle',N'Sports',5.00,14.99,1),
(116,N'APP-001',N'Classic Hoodie',N'Apparel',18.00,44.99,1),
(117,N'APP-002',N'Running Socks',N'Apparel',4.00,12.99,1),
(118,N'APP-003',N'Winter Jacket',N'Apparel',70.00,139.99,1),
(119,N'TOY-001',N'Building Block Set',N'Toys',20.00,49.99,1),
(120,N'TOY-002',N'Board Game',N'Toys',14.00,34.99,0),
(121,N'HOME-005',N'Never Sold Vase',N'Home',10.00,27.99,1);

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
(1030,19,3,'2026-06-09T11:05:00',N'Completed',N'InStore','2026-06-09T11:20:00');

INSERT INTO retail.order_items
(order_id,line_number,product_id,quantity,unit_price,discount_amount)
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
(1030,1,119,2,49.99,10.00),(1030,2,110,2,24.99,0.00);

-- Three snapshot dates for every store/product pair.
;WITH dates AS (
    SELECT CONVERT(date,'2026-05-31') AS snapshot_date, 1 AS d
    UNION ALL SELECT '2026-06-30', 2
    UNION ALL SELECT '2026-07-31', 3
),
pairs AS (
    SELECT s.store_id, p.product_id
    FROM retail.stores s
    CROSS JOIN retail.products p
)
INSERT INTO retail.inventory_snapshots
(store_id, product_id, snapshot_date, on_hand_qty, reorder_point)
SELECT
    p.store_id,
    p.product_id,
    d.snapshot_date,
    ABS(CHECKSUM(CONCAT(p.store_id,':',p.product_id,':',d.d))) % 40,
    6 + (p.product_id % 5)
FROM pairs p
CROSS JOIN dates d;

-- Deliberately dirty / duplicate incoming order versions.
INSERT INTO staging.orders_incoming
(source_order_id,customer_id,store_id,order_date,status,sales_channel,modified_at,ingested_at,source_file)
VALUES
(2001,1,1,'2026-08-01T10:00:00',N'Processing',N'Online','2026-08-01T10:05:00','2026-08-01T11:00:00',N'orders_20260801.csv'),
(2001,1,1,'2026-08-01T10:00:00',N'Completed',N'Online','2026-08-01T10:30:00','2026-08-01T11:05:00',N'orders_20260801_retry.csv'),
(2002,2,2,'2026-08-01T11:00:00',N'Completed',N'InStore','2026-08-01T11:10:00','2026-08-01T11:15:00',N'orders_20260801.csv'),
(2003,NULL,1,'2026-08-01T12:00:00',N'Completed',N'InStore','2026-08-01T12:10:00','2026-08-01T12:15:00',N'orders_20260801.csv'),
(2004,4,3,NULL,N'Completed',N'Online','2026-08-01T13:10:00','2026-08-01T13:15:00',N'orders_20260801.csv'),
(2005,999,1,'2026-08-01T14:00:00',N'Completed',N'Online','2026-08-01T14:10:00','2026-08-01T14:15:00',N'orders_20260801.csv'),
(2006,5,999,'2026-08-01T15:00:00',N'Completed',N'Online','2026-08-01T15:10:00','2026-08-01T15:15:00',N'orders_20260801.csv'),
(2007,6,6,'2026-08-01T16:00:00',N'INVALID_STATUS',N'Online','2026-08-01T16:10:00','2026-08-01T16:15:00',N'orders_20260801.csv'),
(NULL,7,2,'2026-08-01T17:00:00',N'Completed',N'Online','2026-08-01T17:10:00','2026-08-01T17:15:00',N'orders_20260801.csv'),
(2008,8,3,'2026-08-02T09:00:00',N'Processing',N'Online','2026-08-02T09:10:00','2026-08-02T09:15:00',N'orders_20260802.csv'),
(2008,8,3,'2026-08-02T09:00:00',N'Shipped',N'Online','2026-08-02T09:20:00','2026-08-02T09:25:00',N'orders_20260802.csv'),
(2008,8,3,'2026-08-02T09:00:00',N'Completed',N'Online','2026-08-02T09:30:00','2026-08-02T09:35:00',N'orders_20260802.csv'),
(2009,9,7,'2026-08-02T10:00:00',N'Completed',N'InStore','2026-08-02T10:10:00','2026-08-02T10:15:00',N'orders_20260802.csv'),
(2010,10,1,'2026-08-02T11:00:00',N'Completed',N'Online','2026-08-02T11:10:00','2026-08-02T11:15:00',N'orders_20260802.csv'),
(2010,10,1,'2026-08-02T11:00:00',N'Completed',N'Online','2026-08-02T11:10:00','2026-08-02T11:16:00',N'orders_20260802_retry.csv');

PRINT 'RetailDEPractice created successfully.';
GO
