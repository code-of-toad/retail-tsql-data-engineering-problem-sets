# Retail T-SQL Data Engineering — 3-Day Comprehensive Problem Sets

**Dialect:** Microsoft T-SQL for SQL Server  
**Context:** Retail  
**Solutions:** Intentionally omitted.

## Practice schema

Assume these schemas and tables exist:

### `retail.customers`
- `customer_id INT` — primary key
- `customer_name NVARCHAR(100)`
- `email NVARCHAR(255)` — nullable
- `province CHAR(2)`
- `signup_date DATE`
- `loyalty_tier NVARCHAR(20)` — nullable

### `retail.stores`
- `store_id INT` — primary key
- `store_name NVARCHAR(100)`
- `city NVARCHAR(100)`
- `province CHAR(2)`
- `opened_date DATE`

### `retail.products`
- `product_id INT` — primary key
- `sku NVARCHAR(30)` — unique
- `product_name NVARCHAR(150)`
- `category NVARCHAR(50)`
- `unit_cost DECIMAL(10,2)`
- `list_price DECIMAL(10,2)`
- `active_flag BIT`

### `retail.orders`
- `order_id INT` — primary key
- `customer_id INT` — nullable foreign key to `customers`
- `store_id INT` — foreign key to `stores`
- `order_date DATETIME2`
- `status NVARCHAR(20)`
- `sales_channel NVARCHAR(20)`
- `last_modified DATETIME2`

### `retail.order_items`
- `order_id INT`
- `line_number INT`
- `product_id INT`
- `quantity INT`
- `unit_price DECIMAL(10,2)`
- `discount_amount DECIMAL(10,2)`
- primary key: `(order_id, line_number)`

### `retail.inventory_snapshots`
- `store_id INT`
- `product_id INT`
- `snapshot_date DATE`
- `on_hand_qty INT`
- `reorder_point INT`
- primary key: `(store_id, product_id, snapshot_date)`

### `staging.orders_incoming`
Deliberately contains duplicates and invalid rows:
- `ingestion_id INT IDENTITY`
- `source_order_id INT`
- `customer_id INT NULL`
- `store_id INT`
- `order_date DATETIME2 NULL`
- `status NVARCHAR(20)`
- `sales_channel NVARCHAR(20)`
- `modified_at DATETIME2`
- `ingested_at DATETIME2`
- `source_file NVARCHAR(255)`

---

# DAY 1 — Core Querying + Joins

## Set 1A — SELECT, WHERE, ORDER BY

1. Return every active product.
2. Return `product_id`, `product_name`, and `list_price` for products costing more than $100.
3. Return the 10 most expensive products by `list_price`.
4. Return all orders placed through the `Online` sales channel.
5. Return all completed orders placed on or after `2026-01-01`.
6. Return all customers in Ontario (`ON`) or British Columbia (`BC`).
7. Return products whose category is not `Electronics`.
8. Return orders whose status is either `Completed`, `Shipped`, or `Processing`.
9. Return all products priced between $25 and $100 inclusive.
10. Return customers sorted by `signup_date` newest first, then `customer_name` alphabetically.

## Set 1B — Aggregation

11. Count all rows in `retail.orders`.
12. Count how many orders have a non-null `customer_id`.
13. Count distinct customers who have placed at least one order.
14. Calculate total quantity sold across all order-item rows.
15. Calculate gross item revenue before discounts as `quantity * unit_price`.
16. Calculate total discount amount across all order-item rows.
17. Calculate net item revenue as `(quantity * unit_price) - discount_amount`.
18. Calculate average product `list_price`.
19. Return the minimum and maximum `unit_cost` in `retail.products`.
20. Return total net revenue by `product_id`.
21. Return total net revenue by `order_id`.
22. Return order count by `status`.
23. Return order count by `sales_channel`.
24. Return product count by `category`.
25. Return categories with at least 3 products.
26. Return stores with more than 3 completed orders.
27. Return customers whose lifetime net sales exceed $500.
28. Return average order value, defined as total net sales divided by distinct completed orders.

## Set 1C — CASE and NULL handling

29. Label each product:
   - `Budget` if `list_price < 25`
   - `Midrange` if `25 <= list_price < 100`
   - `Premium` otherwise.
30. Create a `stock_status` for inventory rows:
   - `Out of Stock` if `on_hand_qty = 0`
   - `Low Stock` if `on_hand_qty <= reorder_point`
   - `Healthy` otherwise.
31. Return customers with `email`; replace NULL email values with `NO_EMAIL`.
32. Return customers with `loyalty_tier`; replace NULL tiers with `Unassigned`.
33. Calculate each order item's effective selling price after its discount.
34. Create a flag showing whether an order has a known customer (`Known`) or is a guest order (`Guest`).
35. Count guest orders and known-customer orders in a single grouped query.
36. Use conditional aggregation to return, per store:
   - completed order count
   - cancelled order count
   - all other order count.
37. Return net sales by category and separately calculate net sales from discounted lines only.
38. Return the percentage of order-item rows that have a positive discount.

## Set 1D — INNER JOIN / LEFT JOIN

39. Return each order with its store name.
40. Return each order with customer name where a customer exists.
41. Return all orders, including guest orders, with customer name if available.
42. Return order line detail with:
   - order ID
   - order date
   - product name
   - quantity
   - unit price
   - discount
   - net line revenue.
43. Return completed net sales by store.
44. Return completed net sales by province.
45. Return completed net sales by product category.
46. Return completed net sales by customer.
47. Return every customer and their total completed net sales, including customers with no purchases.
48. Return every product and its total units sold, including products that have never sold.
49. Find products that have never appeared in `order_items`.
50. Find customers who have never placed an order.
51. Return each store's latest inventory snapshot date.
52. Return all products that were low-stock at any store on the most recent snapshot date for that store.

## Set 1E — Join cardinality and duplicate explosions

For each question, first predict the output grain before writing SQL.

53. Join `orders` to `order_items`. What does one result row represent?
54. Join `orders` → `order_items` → `products`. What does one result row represent?
55. Explain why `COUNT(*)` after joining `orders` to `order_items` does **not** equal order count.
56. Write a query that correctly counts distinct orders by store after joining to `order_items`.
57. Write a query that computes total store revenue without double-counting.
58. Create an intentionally incorrect query that double-counts order-level rows because of a one-to-many join. Then rewrite it correctly.
59. Suppose one order has 4 items. After joining `orders` to `order_items`, how many rows represent that order?
60. Suppose you join `orders` to both `order_items` and a hypothetical `order_payments` table with 2 payment rows for the same order. If the order has 4 items, how many rows could result? Explain the multiplication.
61. Write a strategy using pre-aggregation to avoid the multiplication problem in Question 60.

## Set 1F — UNION ALL

62. Return a single list of all store provinces and customer provinces using `UNION ALL`.
63. Produce one result containing:
   - `entity_type`
   - `entity_id`
   - `province`

   for both customers and stores.
64. Explain the difference between `UNION` and `UNION ALL`.
65. Rewrite a `UNION` query as `UNION ALL` where retaining duplicates is logically correct.
66. Combine completed and cancelled orders into one result using two queries and `UNION ALL`, adding a text column that identifies which branch each row came from.

## Set 1G — Basic date functions

67. Return the calendar year, month, and day of each order.
68. Return order count by year and month.
69. Return orders from the last 30 days relative to a supplied variable `@as_of_date`.
70. Return the number of days between customer signup and their first order.
71. Return each order's month-end date using `EOMONTH`.
72. Return inventory snapshots taken during the same calendar month as a supplied date.
73. Return completed sales by calendar quarter.
74. Return products sold in the 7-day period beginning with each order date—then explain why the wording is logically odd and restate the requirement correctly.

## Set 1H — Basic string functions

75. Return customer names in uppercase.
76. Trim whitespace from customer emails.
77. Extract the first 3 characters from every product SKU.
78. Build a display label in the form `SKU - Product Name`.
79. Return the length of each product name.
80. Replace spaces in product names with hyphens.
81. Find products whose names contain the word `Wireless`.
82. Produce one comma-separated product-name list per category using `STRING_AGG`.

## Day 1 Capstone

83. Produce one row per store with:
- store ID
- store name
- province
- distinct completed order count
- distinct completed customer count
- units sold
- gross sales
- discount amount
- net sales
- gross margin, where line cost = `quantity * unit_cost`
- average order value
- latest inventory snapshot date
- count of low-stock SKUs on that latest snapshot.

You must prevent join multiplication.

---

# DAY 2 — Critical Data Engineering SQL

## Set 2A — CTEs

84. Rewrite Question 83 using at least three CTEs.
85. Create a CTE called `completed_sales` containing completed order-line detail and query total sales by province from it.
86. Create separate CTEs for:
   - order totals
   - customer lifetime totals

   and return customers ranked by lifetime sales.
87. Use chained CTEs representing:
   - `raw_lines`
   - `clean_lines`
   - `enriched_lines`
   - `aggregated_sales`.
88. Write a CTE that identifies products with no sales.
89. Write a CTE that calculates monthly store sales, then a second CTE that calculates company-wide monthly sales, and return each store's percentage contribution.
90. Refactor a deeply nested subquery of your own design into CTEs and explain which version is easier to maintain.

## Set 2B — Subqueries

91. Return products priced above the average product price.
92. Return orders whose net value exceeds the average order value.
93. Return customers whose lifetime sales exceed the average customer lifetime sales.
94. Return the highest-revenue product in each category using a subquery-based approach.
95. Return stores whose completed sales exceed the average completed sales across stores.
96. Write a correlated subquery that returns each product with its total quantity sold.
97. Replace Question 96 with a join or CTE and compare readability.
98. Find each customer's first order using a subquery.

## Set 2C — EXISTS / NOT EXISTS

99. Return customers who have placed at least one order.
100. Return customers with no orders using `NOT EXISTS`.
101. Return products that have sold at least once.
102. Return products that have never sold.
103. Return stores that currently have at least one low-stock product.
104. Return orders containing at least one discounted line.
105. Return customers who have bought at least one product from the `Electronics` category.
106. Return customers who have never bought an `Electronics` product.
107. Identify `order_items` whose `order_id` does not correspond to an order. Assume constraints are temporarily disabled for this exercise.
108. Identify `order_items` whose `product_id` does not correspond to a product.

## Set 2D — Window functions: ROW_NUMBER / RANK

109. Number orders chronologically within each customer using `ROW_NUMBER`.
110. Return each customer's most recent order using `ROW_NUMBER`.
111. Return each customer's first order using `ROW_NUMBER`.
112. Rank products by completed net sales from highest to lowest.
113. Rank products by completed net sales within category.
114. Return the top 3 products by completed net sales within each category.
115. Demonstrate the difference among `ROW_NUMBER`, `RANK`, and `DENSE_RANK` on product sales.
116. Rank stores by completed net sales within province.
117. Return the second-highest revenue product within every category.
118. For each store and product, return the most recent inventory snapshot.

## Set 2E — LAG / LEAD

119. Return each customer order and the date of their previous order.
120. Calculate days since previous order for every customer.
121. Return each inventory snapshot with the previous `on_hand_qty` for the same store/product.
122. Calculate inventory quantity change from the previous snapshot.
123. Flag inventory rows where stock decreased relative to the prior snapshot.
124. Return each order and the customer's next order date.
125. Determine whether a customer returned within 30 days after each order.

## Set 2F — Windowed SUM

126. Calculate running completed net sales by date.
127. Calculate running completed net sales separately by store.
128. Calculate each product's percentage of category revenue using a windowed `SUM`.
129. Calculate each store's percentage of company revenue using a window function.
130. Calculate cumulative units sold by product over time.
131. Calculate a 3-row moving average of daily sales.

## Set 2G — Deduplication

Assume `staging.orders_incoming` may contain multiple versions of the same `source_order_id`.

132. Show every duplicate `source_order_id`.
133. Return the number of incoming versions per `source_order_id`.
134. Keep only the most recently modified version of each source order using `ROW_NUMBER`.
135. If two rows share the same `modified_at`, break ties using newest `ingested_at`.
136. If those are also tied, use highest `ingestion_id`.
137. Return only superseded duplicate records instead of the winners.
138. Create a query that distinguishes:
   - unique records
   - winning duplicate versions
   - superseded duplicate versions.
139. Explain why `SELECT DISTINCT` is not an adequate general deduplication strategy for versioned records.
140. Insert only the deduplicated winning records into a clean staging table.

## Set 2H — Data-quality checks

Write one query per rule.

141. Detect NULL `source_order_id`.
142. Detect NULL `order_date`.
143. Detect invalid order statuses outside the approved domain.
144. Detect stores that do not exist in `retail.stores`.
145. Detect customers that do not exist in `retail.customers`, excluding guest orders where customer is NULL.
146. Detect future-dated orders relative to `@as_of_date`.
147. Detect products where `unit_cost < 0`.
148. Detect products where `list_price < 0`.
149. Detect product rows where `unit_cost > list_price`.
150. Detect order-item rows where `quantity <= 0`.
151. Detect order-item rows where `discount_amount < 0`.
152. Detect order-item rows where the discount exceeds gross line value.
153. Detect duplicate customer emails, ignoring NULL.
154. Detect duplicate SKUs.
155. Return one summary result with:
   - check name
   - failure count

   for at least 8 quality checks using `UNION ALL`.

## Set 2I — Grain, keys, and constraints

156. State the grain of every core table.
157. Identify the primary key of every core table.
158. Explain why `order_items` needs a composite key.
159. Explain why `(store_id, product_id, snapshot_date)` is a sensible key for `inventory_snapshots`.
160. Identify every foreign-key relationship in the practice schema.
161. Give an example of an orphaned order-item record.
162. Explain the difference between a natural key and surrogate key.
163. Identify a plausible natural key for `products`.
164. Explain why an order-level measure should not be stored on an order-item grain without care.

## Set 2J — DDL and constraints

165. Create a schema named `warehouse`.
166. Create `warehouse.dim_store` with a surrogate identity key.
167. Create `warehouse.dim_product` with:
   - surrogate key
   - source product ID
   - SKU
   - product name
   - category
   - current cost
   - current list price.
168. Create `warehouse.fact_sales` at one row per order line.
169. Add appropriate primary keys.
170. Add foreign keys to the fact table.
171. Add `NOT NULL` constraints to required columns.
172. Add a `CHECK (quantity > 0)` constraint.
173. Add a `CHECK (unit_price >= 0)` constraint.
174. Add a `DEFAULT` constraint for a load timestamp.
175. Create a unique constraint on SKU where appropriate.
176. Alter a table to add `load_batch_id BIGINT`.
177. Explain when you would use `TRUNCATE TABLE` instead of `DELETE`.

## Set 2K — DML

178. Insert one new store.
179. Insert multiple new products in one statement.
180. Insert rows into a clean staging table using `INSERT ... SELECT`.
181. Increase `reorder_point` by 5 for a supplied category.
182. Set inactive products to `active_flag = 0` based on a supplied list.
183. Delete staging rows older than a supplied retention date.
184. Wrap a dangerous `UPDATE` in a transaction, inspect the affected rows, then roll it back.
185. Write an `UPDATE` that uses a join.
186. Write a `DELETE` that uses a join or `EXISTS`.

## Day 2 Capstone

187. Build a T-SQL script that processes `staging.orders_incoming` into a hypothetical `staging.orders_clean` table:

1. Flag invalid records.
2. Separate rejected records.
3. Deduplicate valid records using latest `modified_at`.
4. Retain the winning record per `source_order_id`.
5. Load only the valid winners.
6. Produce a run summary with counts for:
   - rows read
   - invalid rows
   - duplicate/superseded rows
   - clean winners loaded.
7. Ensure your logic has an explicit and defensible grain.

---

# DAY 3 — Think Like a Data Engineer

## Set 3A — Staging → cleaned → curated

188. Define the purpose of each layer:
   - raw
   - staging
   - cleaned/validated
   - curated
   - warehouse.
189. Design table names and grains for a retail pipeline flowing through those layers.
190. Write a CTE-based transformation representing the layers.
191. Explain which layer should preserve malformed source records and why.
192. Explain where business rules such as `quantity > 0` should be enforced.
193. Explain where derived metrics such as `net_sales` should be calculated.

## Set 3B — Full vs incremental loads

194. Define a full load.
195. Define an incremental load.
196. Give two cases where a full load may be acceptable.
197. Give three reasons incremental loads are preferred for large retail history.
198. Write a query that selects only rows modified after `@last_successful_load`.
199. Explain the danger of using `>` when two records can share the same watermark timestamp.
200. Design a compound watermark using timestamp plus source ID.
201. Write a query that loads a bounded window with `@lower_bound` and `@upper_bound`.

## Set 3C — Watermarks

202. Design a `control.pipeline_watermark` table.
203. Store:
   - pipeline name
   - last successful timestamp
   - last successful source ID
   - updated timestamp.
204. Write a query that reads the current watermark.
205. Write a query that calculates the next high watermark from source data.
206. Explain why the watermark should normally advance only after a successful load.
207. Describe what happens if the pipeline crashes after target rows are loaded but before the watermark updates.

## Set 3D — Upserts

208. Given a staging table and target `retail.products`, classify source rows as:
   - insert
   - update
   - unchanged.
209. Write the classification query.
210. Write an `UPDATE` for changed products.
211. Write an `INSERT` for new products.
212. Explain how this two-statement approach can be made transactional.
213. Write a conceptual `MERGE` statement performing the same upsert.
214. Add logic for a source record representing a deletion/inactivation.
215. Explain what business key you would use to match products.

## Set 3E — Idempotency

216. Define idempotency in the context of ETL.
217. Show how a naive `INSERT INTO target SELECT ... FROM staging` can create duplicates on rerun.
218. Rewrite it so rerunning the same batch does not duplicate rows.
219. Design a `load_batch_id` approach.
220. Design a unique-key approach.
221. Design a delete-and-reload approach for one bounded date partition.
222. Explain which of those strategies is safest for immutable transaction facts.
223. Explain what makes a pipeline deterministic.

## Set 3F — Transactions

224. Wrap an upsert process in `BEGIN TRANSACTION`, `COMMIT`, and `ROLLBACK`.
225. Add `TRY...CATCH`.
226. Use `XACT_STATE()` in your error handling.
227. Explain what happens if product updates succeed but inserts fail without a transaction.
228. Write a transaction that:
   - loads a batch
   - validates its target count
   - rolls back if the count is wrong.
229. Explain why transactions should not necessarily be held open for extremely long ETL jobs.

## Set 3G — Fact/dimension modeling

230. Define a fact table.
231. Define a dimension table.
232. Define a star schema.
233. Design a retail star schema for sales analysis.
234. State the grain of `fact_sales`.
235. Choose dimensions for:
   - customer
   - product
   - store
   - date.
236. Identify which columns are measures.
237. Explain why `quantity` belongs in the fact table.
238. Explain why `product_name` normally belongs in a dimension rather than the fact.
239. Explain why fact grain must be declared before selecting columns.
240. Design a separate `fact_inventory_snapshot`.
241. State its grain.
242. Explain why inventory snapshot facts should not be blindly summed across dates.

## Set 3H — Surrogate keys

243. Define a surrogate key.
244. Explain why a warehouse might use `product_key` even when the source has `product_id`.
245. Create `dim_product(product_key INT IDENTITY, source_product_id INT, ...)`.
246. Write a fact load that looks up the product surrogate key.
247. Decide what to do if the dimension row cannot be found.
248. Explain the concept of an `Unknown` dimension row.

## Set 3I — SCD Type 1 vs Type 2

249. Explain SCD Type 1.
250. Explain SCD Type 2.
251. Give one retail attribute suited to Type 1.
252. Give one retail attribute suited to Type 2.
253. Add these columns to a Type 2 dimension:
   - `effective_from`
   - `effective_to`
   - `is_current`.
254. Detect changed product attributes between staging and current dimension rows.
255. Expire the old current row.
256. Insert the new current row.
257. Ensure exactly one current row exists per source product.
258. Query the dimension as it existed on a supplied historical date.
259. Join historical sales to the correct Type 2 product version based on order date.

## Set 3J — Index basics

260. Explain the difference between a heap and clustered index.
261. Explain clustered vs nonclustered indexes.
262. Choose an index for frequent lookups of `orders` by `order_id`.
263. Choose an index for queries filtering by `order_date`.
264. Choose an index for queries filtering by `store_id` and date range.
265. Design a composite index and justify column order.
266. Explain a covering index.
267. Propose included columns for a common store-sales query.
268. Explain why "index every column" is a bad strategy.

## Set 3K — SARGability

For each pair, identify the more SARGable form and explain why.

269. `YEAR(order_date) = 2026` versus a date range.
270. `UPPER(status) = 'COMPLETED'` versus storing/normalizing comparable values.
271. `ISNULL(customer_id, 0) = 42` versus `customer_id = 42`.
272. Rewrite a query that casts the indexed column in the `WHERE` clause.
273. Rewrite a date filter using an inclusive lower bound and exclusive upper bound.
274. Explain why `%wireless%` is generally harder to seek efficiently than `wireless%`.

## Set 3L — Execution-plan basics

275. Explain index seek.
276. Explain index scan.
277. Explain table scan.
278. Explain nested loops join.
279. Explain hash join.
280. Explain merge join.
281. Explain sort operators.
282. Explain key lookups.
283. Given a query that scans millions of order rows for one day of data, list three things you would inspect.
284. Compare estimated versus actual execution plans conceptually.
285. Explain why an execution plan is evidence rather than a command to "always avoid scans."

## Set 3M — Partitioning / clustering concepts

286. Define table partitioning.
287. Explain partition elimination.
288. Propose a partitioning column for a very large sales fact table.
289. Explain why partitioning every small table is unnecessary.
290. Explain how date partitioning can help retention/deletion operations.
291. Explain the conceptual difference between SQL Server indexing/partitioning and cloud-warehouse "clustering".
292. For a 5-billion-row fact table, explain why physical data organization matters.

## Set 3N — ETL failure scenarios

For each scenario, describe:
1. detection,
2. desired behavior,
3. recovery strategy,
4. SQL mechanisms involved.

293. The source sends the same file twice.
294. The source sends duplicate business keys in one file.
295. The pipeline fails halfway through target inserts.
296. A source table adds a new nullable column.
297. A source column changes from integer-like strings to malformed text.
298. Yesterday's orders arrive two days late.
299. A previously loaded product is corrected.
300. A source deletes a product.
301. A fact references a dimension member that has not arrived yet.
302. The same record arrives with a newer `modified_at`.
303. A batch has the expected row count but wrong revenue totals.
304. The database becomes unavailable after staging succeeds.
305. A retry begins after some—but not all—target changes committed.

## Day 3 Capstone — End-to-End Retail Incremental Load

306. Design and write the core T-SQL for this pipeline:

**Source:** `staging.orders_incoming`  
**Target:** curated order tables / warehouse sales fact

Required behavior:

1. Read the previous watermark.
2. Select only the eligible incremental source window.
3. Validate technical and business rules.
4. Quarantine invalid records.
5. Deduplicate valid source versions.
6. Resolve foreign keys.
7. Classify records as inserts/updates/unchanged.
8. Apply changes transactionally.
9. Prevent duplicate results on rerun.
10. Update the watermark only after success.
11. Write an audit row containing:
    - run ID
    - start/end timestamps
    - rows read
    - rows rejected
    - rows inserted
    - rows updated
    - rows unchanged
    - status.
12. Roll back appropriately on failure.
13. Produce a reconciliation:
    - source eligible count
    - accepted count
    - rejected count
    - target count impact.
14. Explain how late-arriving records are handled.
15. Explain how the design would change for billions of historical rows.

---

# FINAL MIXED INTERVIEW SET

Do these without notes.

307. What is the grain of an order-item table?
308. Why can a join increase row count?
309. Write net sales by store.
310. Find customers with no orders.
311. Return each customer's latest order.
312. Deduplicate incoming orders by latest modification timestamp.
313. Detect orphaned product references.
314. Explain `WHERE` versus `HAVING`.
315. Explain `ROW_NUMBER` versus `RANK`.
316. Explain `UNION` versus `UNION ALL`.
317. Write a running sales total.
318. Design an incremental-load watermark.
319. Explain idempotency.
320. Design an upsert.
321. Explain why transactions matter during an ETL load.
322. Explain Type 1 versus Type 2 dimensions.
323. State the grain of a sales fact table.
324. Explain surrogate keys.
325. Rewrite a non-SARGable date predicate.
326. Explain clustered versus nonclustered indexes.
327. What would you inspect when a query is unexpectedly slow?
328. How would you handle late-arriving data?
329. How would you prevent a duplicated source file from duplicating warehouse facts?
330. The pipeline succeeded but revenue totals differ from source totals. What do you do?
331. Sketch a complete retail pipeline from source to trusted analytical tables.

---

# Suggested 3-Day Execution Order

## Day 1 must-do
1–61, 67–74, 83.

## Day 1 stretch
62–66, 75–82.

## Day 2 must-do
84–140, 155–187.

## Day 2 stretch
141–154 if your data-quality reasoning is already strong.

## Day 3 must-do
188–228, 230–259, 260–285, 293–306.

## Day 3 stretch
286–292.

## Final
307–331 under timed conditions.

# Mastery rule

For coding questions, do not count a problem as mastered unless you can:
1. write the query without looking up the pattern,
2. state the output grain,
3. explain why joins do not duplicate the intended measure,
4. identify important NULL behavior,
5. explain at least one plausible edge case.

For conceptual questions, require a 30–60 second spoken explanation plus one concrete retail example.
