# Retail T-SQL Data Engineering — Comprehensive 3-Day Problem Set

**Dialect:** Microsoft T-SQL for SQL Server  
**Database:** `RetailDEPractice`  
**Solutions:** intentionally omitted.

Run the setup and seed-validation scripts before beginning.

---

# Working Rules

For every coding problem:

1. Write executable T-SQL.
2. State the **output grain** in a comment.
3. Do not use `SELECT *` unless specifically asked.
4. Where raw source values are involved, use safe conversion patterns such as `TRY_CONVERT`.
5. Do not disable clean-table constraints to manufacture errors.
6. When a join could multiply rows, explain why your aggregation is safe.

---

# DAY 1 — Core Querying + Joins

## A. SELECT / WHERE / ORDER BY

1. Return active products with `product_id`, `sku`, `product_name`, `category`, and `list_price`.
2. Return products priced above $100.
3. Return the 10 most expensive products.
4. Return completed online orders.
5. Return completed orders on or after `2026-04-01`.
6. Return customers in Ontario or British Columbia.
7. Return products outside the `Electronics` category.
8. Return orders with status `Completed`, `Shipped`, or `Processing`.
9. Return products priced between $25 and $100 inclusive.
10. Return customers newest signup first, then alphabetically.
11. Return inactive products.
12. Return orders before noon.
13. Return the five earliest orders.
14. Return distinct customer provinces.
15. Return orders that are not completed.

## B. Aggregates / GROUP BY / HAVING

16. Count all orders.
17. Count orders with a non-NULL customer.
18. Count distinct customers who placed an order.
19. Sum quantity across all order-item rows.
20. Calculate gross line sales: `quantity * unit_price`.
21. Calculate total discounts.
22. Calculate total net line sales.
23. Find average list price.
24. Find minimum and maximum product costs.
25. Return product count by category.
26. Return order count by status.
27. Return order count by sales channel.
28. Return total units sold by product.
29. Return total net sales by order.
30. Return total net sales by product.
31. Return categories containing at least four products.
32. Return customers with at least two orders.
33. Return stores with at least four completed orders.
34. Return customers whose completed lifetime net sales exceed $300.
35. Calculate average completed order value using distinct orders.

## C. CASE / NULL

36. Classify products as `Budget`, `Midrange`, or `Premium`.
37. Classify inventory rows as `Out of Stock`, `Low Stock`, or `Healthy`.
38. Replace NULL email with `NO_EMAIL`.
39. Replace NULL loyalty tier with `Unassigned`.
40. Label guest versus known-customer orders.
41. Count guest and known-customer orders.
42. Return completed/cancelled/other order counts per store with conditional aggregation.
43. Calculate discounted-line revenue separately from non-discounted-line revenue.
44. Return percentage of clean order-item rows carrying a discount.
45. Calculate gross margin per clean order line as net sales minus product cost.

## D. INNER JOIN / LEFT JOIN

46. Return each order with its store name.
47. Return each known-customer order with customer name.
48. Return all orders, including guest orders, with customer name if present.
49. Return full order-line detail with product name and net line revenue.
50. Return completed net sales by store.
51. Return completed net sales by store province.
52. Return completed net sales by product category.
53. Return completed net sales by customer.
54. Return every customer and completed lifetime sales, including zero-sales customers.
55. Return every product and total units sold, including never-sold products.
56. Find products never sold.
57. Find customers who never placed an order.
58. Return each store's latest inventory snapshot date.
59. Return low-stock SKUs on the latest available snapshot **for each store**.
60. Return products bought by each customer.
61. Return completed sales by customer province.
62. Return gross margin by product category.

## E. Join Cardinality / Duplicate Explosions

63. Predict and then verify the grain after joining `orders` to `order_items`.
64. Predict and verify the grain after joining `orders → order_items → products`.
65. Explain why `COUNT(*)` after joining orders to items is not an order count.
66. Correctly count distinct completed orders by store after joining to items.
67. Compute completed store revenue without double-counting.
68. Write an intentionally wrong query that overcounts orders due to the order-item join; then fix it.
69. Show the number of line rows produced per order after joining.
70. Identify the order(s) with the largest number of lines.
71. Pre-aggregate order-item revenue to one row per order, then join to `orders`.
72. Pre-aggregate inventory to one row per store and join it to a store-level sales aggregation without causing multiplication.
73. Explain why joining two one-to-many child tables directly through a common parent can create a multiplicative explosion.

## F. UNION ALL

74. Combine customer provinces and store provinces with `UNION ALL`.
75. Produce `(entity_type, entity_id, province)` for both customers and stores.
76. Compare `UNION` and `UNION ALL` by executing both against province lists.
77. Combine completed and cancelled orders into one labeled result.
78. Build a data-quality summary containing multiple check names and counts using `UNION ALL`.

## G. Date Functions

79. Extract year, month, and day from order dates.
80. Return order count by calendar year/month.
81. Using `@as_of_date = '2026-08-15'`, return orders from the preceding 30 days.
82. Return days between signup and first order for every customer who ordered.
83. Return month-end for each order using `EOMONTH`.
84. Return inventory snapshots in June 2026.
85. Return completed sales by quarter.
86. Return completed sales by month.
87. Return the first and last order date for each customer.
88. Return customers whose second order occurred within 30 days of their first.

## H. String Functions

89. Uppercase customer names.
90. Trim incoming customer emails.
91. Return first three characters of every SKU.
92. Build `SKU - Product Name`.
93. Return product-name lengths.
94. Replace spaces in product names with hyphens.
95. Find products whose names contain `Wireless`.
96. Create one comma-separated product list per category using `STRING_AGG`.

## Day 1 Capstone

97. Produce **one row per store** containing:
- store ID/name/province
- distinct completed order count
- distinct completed customer count
- units sold
- gross sales
- discount amount
- net sales
- gross margin
- average order value
- latest inventory snapshot date
- count of low-stock SKUs on that store's latest snapshot

You must prevent sales/inventory join multiplication.

---

# DAY 2 — Critical Data-Engineering SQL

## I. CTEs

98. Rewrite the Day 1 capstone with separate sales and inventory CTEs.
99. Build a `completed_sales` CTE and aggregate it by province.
100. Build chained CTEs named `raw_lines`, `clean_lines`, `enriched_lines`, and `aggregated_sales`.
101. Use a CTE to find never-sold products.
102. Use two CTEs to calculate store monthly sales and company monthly sales, then contribution percentage.
103. Use a CTE to calculate customer lifetime sales and rank customers.
104. Refactor one nested subquery into multiple CTEs.

## J. Subqueries

105. Products priced above average list price.
106. Orders whose net value exceeds average completed order value.
107. Customers whose lifetime sales exceed average customer lifetime sales.
108. Stores whose sales exceed average store sales.
109. Return each customer's first order using a subquery.
110. Return each product with total quantity sold using a correlated subquery.
111. Rewrite Question 110 with a join/CTE and compare.
112. Return products with completed revenue above their category average.

## K. EXISTS / NOT EXISTS

113. Customers with at least one order.
114. Customers with no orders.
115. Products sold at least once.
116. Products never sold.
117. Stores whose latest snapshot has at least one low-stock product.
118. Orders with at least one discounted line.
119. Customers who bought Electronics.
120. Customers who never bought Electronics.
121. Incoming orders with valid numeric customer IDs that do not exist in `retail.customers`.
122. Incoming order items with valid numeric product IDs that do not exist in `retail.products`.

## L. Window Functions — ROW_NUMBER / RANK / DENSE_RANK

123. Number each customer's orders chronologically.
124. Return each customer's most recent order.
125. Return each customer's first order.
126. Rank products by completed net sales.
127. Rank products by completed net sales within category.
128. Return top 3 products by revenue within each category.
129. Demonstrate `ROW_NUMBER`, `RANK`, and `DENSE_RANK` on the Accessories category. Your output must expose the seeded tie.
130. Rank stores by revenue within province.
131. Return the second-highest revenue product per category.
132. Return latest inventory snapshot per store/product.
133. Return the top-selling order line within each completed order.

## M. LAG / LEAD

134. Previous order date per customer.
135. Days since previous order.
136. Previous on-hand quantity per store/product.
137. Inventory change since previous snapshot.
138. Flag inventory decreases.
139. Next order date per customer.
140. Flag whether a customer returned within 30 days.
141. Compare each month's completed sales with the prior month.

## N. Windowed Aggregates

142. Running completed net sales by date.
143. Running completed net sales by store.
144. Product percentage of category revenue.
145. Store percentage of company revenue.
146. Cumulative units sold per product over time.
147. Three-row moving average of daily completed sales.
148. Running order count by customer.

## O. Safe Type Conversion / Raw Source Inspection

149. Return incoming orders with safely converted integer order/customer/store IDs.
150. Return incoming orders where order ID cannot be converted to `INT`.
151. Return incoming order dates that cannot be converted to `DATETIME2`.
152. Return malformed incoming item quantities.
153. Return malformed incoming item unit prices.
154. Convert valid incoming product cost/price strings to decimals.
155. Explain why `CAST` is dangerous for a mixed-validity raw batch and demonstrate the safer alternative.

## P. Deduplication

156. Show duplicate incoming `source_order_id_raw` values.
157. Count versions per source order.
158. Deduplicate orders by:
   1. valid business key,
   2. newest converted `modified_at`,
   3. newest `ingested_at`,
   4. highest `ingestion_id`.
159. Return only winning records.
160. Return only superseded records.
161. Label each row as `UNIQUE`, `WINNER`, or `SUPERSEDED`.
162. Show the seeded `modified_at` tie and prove your tie-break is deterministic.
163. Deduplicate incoming order items by `(source_order_id, line_number)`.
164. Deduplicate incoming inventory by `(store_id, product_id, snapshot_date)`.
165. Explain why `DISTINCT` is insufficient for versioned-source deduplication.

## Q. Duplicate File / Replay Detection

166. Find duplicate source files by `(source_entity, file_checksum)`.
167. Identify replayed order batches.
168. Return all order rows belonging to a replayed checksum.
169. Design a query that chooses only the earliest accepted batch for a checksum.
170. Explain how checksum-level idempotency differs from business-key deduplication.

## R. Data Quality — Orders

171. Missing/blank source order keys.
172. Malformed order IDs.
173. Malformed customer IDs, excluding NULL guest customers.
174. Malformed store IDs.
175. Malformed order dates.
176. Future-dated orders using `@as_of_date = '2026-08-15'`.
177. Invalid status values.
178. Invalid sales channels.
179. Orphan customers.
180. Orphan stores.
181. Unsupported `change_type_raw`.
182. Produce a single order-quality summary using `UNION ALL`.

## S. Data Quality — Order Items

183. Missing line number.
184. Malformed line number.
185. Zero quantity.
186. Negative quantity.
187. Malformed quantity.
188. Negative unit price.
189. Malformed unit price.
190. Negative discount.
191. Discount greater than gross line value.
192. Orphan products.
193. Orphan source orders.
194. Duplicate composite `(order,line)` keys.
195. Produce an item-quality summary.

## T. Data Quality — Products / Customers / Inventory

196. Duplicate incoming SKUs.
197. Negative product cost.
198. Negative product price.
199. Product cost greater than list price.
200. Malformed product cost.
201. Missing product business key.
202. Duplicate incoming customer emails ignoring NULL/blank.
203. Invalid customer provinces.
204. Invalid loyalty tiers.
205. Malformed customer signup dates.
206. Negative incoming inventory quantity.
207. Malformed incoming inventory quantity.
208. Negative reorder point.
209. Orphan inventory store/product references.
210. Duplicate inventory snapshots.
211. Build a cross-entity quality-check summary with at least 15 checks.

## U. Grain / Keys / Relational Design

212. State the grain of every `retail.*` table.
213. State the grain of every `staging.*_incoming` table.
214. Identify all primary keys.
215. Explain why `retail.order_items` has a composite key.
216. Explain why inventory uses `(store_id, product_id, snapshot_date)`.
217. Identify foreign-key relationships in the clean model.
218. Explain why raw incoming tables intentionally do not enforce those foreign keys.
219. Explain natural versus surrogate keys using `sku` and a future `product_key`.
220. Explain why fact-table grain must be defined before choosing measures.

## V. DDL — Executable

Perform these in a new schema called `practice_dw`.

221. `CREATE SCHEMA practice_dw`.
222. Create `practice_dw.dim_store` with an `IDENTITY` surrogate key.
223. Create `practice_dw.dim_product`.
224. Create `practice_dw.dim_customer`.
225. Create `practice_dw.dim_date`.
226. Create `practice_dw.fact_sales` at one row per order line.
227. Add appropriate primary keys.
228. Add foreign keys from fact to dimensions.
229. Add `NOT NULL` constraints where appropriate.
230. Add `CHECK (quantity > 0)`.
231. Add `CHECK (unit_price >= 0)`.
232. Add a default load timestamp.
233. Add a unique constraint on a natural/business key where appropriate.
234. `ALTER TABLE` to add `load_batch_id BIGINT`.
235. Create a nonclustered index supporting store/date fact lookups.
236. Create a view exposing a simple sales mart.
237. Create and then drop a disposable practice table.
238. Demonstrate `TRUNCATE TABLE` safely on a disposable table and explain `DELETE` vs `TRUNCATE` vs `DROP`.

## W. DML — Executable

Use only disposable/practice tables where destructive changes would affect seeded data.

239. Insert one dimension row.
240. Insert multiple dimension rows.
241. Populate a dimension with `INSERT ... SELECT`.
242. Update dimension attributes from a staging-derived dataset.
243. Delete a deliberately inserted test row.
244. Perform an `UPDATE` using a join.
245. Perform a `DELETE` using `EXISTS`.
246. Wrap an update in a transaction, inspect the result, then roll back.
247. Insert only valid, deduplicated incoming orders into a clean practice table.
248. Insert rejected rows into a reject table with `rejection_reason`.
249. Update a clean practice target when a newer source version exists.
250. Insert source business keys not already in the target.

## Day 2 Capstone

251. Build an executable pipeline from `staging.orders_incoming` and `staging.order_items_incoming` into practice clean tables:

- exclude replayed files
- safely type-convert raw fields
- validate business rules
- quarantine invalid rows
- deduplicate valid source versions deterministically
- resolve customer/store/product references
- preserve guest orders
- load clean winners
- calculate read/rejected/superseded/accepted counts
- reconcile accepted order lines to accepted orders

---

# DAY 3 — Think Like a Data Engineer

## X. Layered Architecture

252. Define raw, staging, clean, curated, and warehouse layers using this repo.
253. Decide which existing tables correspond most closely to each layer.
254. Design names/grains for clean incoming-order tables.
255. Write a CTE chain representing raw → typed → valid → deduplicated → enriched.
256. Explain why malformed source rows must remain observable rather than silently disappearing.

## Y. Full vs Incremental Loads

257. Define full load and incremental load.
258. Give two reasonable full-load use cases.
259. Give three reasons incremental loads matter for large retail history.
260. Select rows ingested after `@last_successful_ingestion`.
261. Select rows modified after `@last_successful_modified`.
262. Compare ingestion-time and source-modification-time watermarks using the seeded late-arriving order.
263. Explain which watermark would miss the late arrival and why.
264. Implement a bounded incremental window.
265. Design a lookback-window strategy for late data.

## Z. Watermarks / Control Tables

266. Create `practice_dw.pipeline_watermark`.
267. Store pipeline name, last ingestion watermark, source watermark, last business key, and update timestamp.
268. Insert an initial watermark.
269. Read it into variables.
270. Calculate a candidate high watermark.
271. Update the watermark only after successful target work.
272. Explain crash behavior if target commit succeeds but watermark update does not.

## AA. Upserts

273. Classify incoming products as `INSERT`, `UPDATE`, `UNCHANGED`, `DELETE`, or `INVALID`.
274. Implement changed-product updates in a practice target.
275. Insert new valid products.
276. Apply delete/tombstone logic as soft deactivation.
277. Wrap the update/insert/deactivate sequence in a transaction.
278. Write a conceptual `MERGE` version.
279. Explain why production SQL Server teams may prefer explicit `UPDATE` + `INSERT` patterns over `MERGE`.

## AB. Idempotency

280. Demonstrate a naive duplicate-producing reload in a disposable table.
281. Prevent duplication using a unique business key.
282. Prevent replayed files using checksum metadata.
283. Prevent duplicate facts using the natural source line key.
284. Design a `load_batch_id` strategy.
285. Implement delete-and-reload for one bounded date slice.
286. Explain which strategy is appropriate for immutable fact rows versus mutable dimensions.
287. Prove by rerunning your load twice that target row counts remain unchanged.

## AC. Transactions / Error Handling

288. Wrap a multi-table load in `BEGIN TRANSACTION`.
289. Add `TRY...CATCH`.
290. Use `XACT_STATE()` correctly.
291. Force a deliberate error in a disposable pipeline and prove rollback.
292. Validate expected target row counts before commit.
293. Explain why very large ETL transactions can be operationally expensive.

## AD. Dimensional Modeling

294. Define fact table, dimension table, and star schema.
295. Design a retail sales star schema.
296. State `fact_sales` grain.
297. Identify additive measures.
298. Explain why product/customer descriptive attributes belong in dimensions.
299. Design `fact_inventory_snapshot`.
300. State its grain.
301. Explain why inventory balances are semi-additive across time.
302. Design an `Unknown` dimension member strategy.

## AE. Surrogate Keys

303. Explain why `product_key` differs from source `product_id`.
304. Populate dimension surrogate keys.
305. Load facts by looking up customer/product/store surrogate keys.
306. Route unresolved members to `Unknown`.
307. Explain late-arriving dimension handling.

## AF. SCD Type 1 / Type 2

308. Explain Type 1 and Type 2.
309. Choose product attributes appropriate for each.
310. Create an SCD2 product dimension with:
   - surrogate key
   - source product ID
   - tracked attributes
   - `effective_from`
   - `effective_to`
   - `is_current`
311. Load the baseline clean products.
312. Detect seeded incoming changes for product 114.
313. Expire the old current row.
314. Insert the new version.
315. Enforce/logically verify one current row per source product.
316. Query product 114 historically as of two supplied dates.
317. Join historical sales to the correct product version by order date.

## AG. Indexes

318. Explain heap vs clustered index.
319. Explain clustered vs nonclustered index.
320. Propose an index for order-date filtering.
321. Propose a composite store/date index.
322. Explain key column order.
323. Explain covering indexes and included columns.
324. Explain write overhead caused by excessive indexes.

## AH. SARGability

325. Rewrite `YEAR(order_date) = 2026` as a SARGable range.
326. Rewrite a predicate that applies `ISNULL` to the indexed column.
327. Rewrite a date equality test against `DATETIME2` as a half-open range.
328. Explain leading-wildcard search limitations.
329. Show why converting the column side of a predicate can inhibit efficient access.

## AI. Execution Plans

330. Explain seek, scan, and table scan.
331. Explain nested loops, hash join, and merge join.
332. Explain sort and key lookup operators.
333. Inspect an actual execution plan for a supplied sales query.
334. Add an index and compare the before/after plan.
335. Explain estimated vs actual plans.
336. Explain why scans are not automatically bad.

## AJ. Partitioning / Clustering Concepts

337. Define partitioning.
338. Define partition elimination.
339. Choose a partition key for a multi-billion-row sales fact.
340. Explain why small tables do not automatically benefit.
341. Explain retention advantages of date partitioning.
342. Contrast SQL Server partitioning/indexing conceptually with cloud-warehouse clustering.

## AK. Failure Scenarios

For each: explain detection, desired behavior, recovery, and relevant SQL mechanisms.

343. Exact source file arrives twice.
344. Duplicate business keys exist within one file.
345. Pipeline fails halfway through multi-table writes.
346. Source adds a nullable column.
347. Numeric source field starts containing text.
348. Order arrives 11 days late.
349. Existing product is corrected.
350. Source sends a deletion/tombstone.
351. Fact arrives before its dimension member.
352. Newer source version arrives after an older one is loaded.
353. Row counts reconcile but revenue does not.
354. Database becomes unavailable after raw staging succeeds.
355. Retry starts after only part of prior work committed.

## Day 3 Capstone — End-to-End Incremental Retail Load

356. Build an end-to-end T-SQL design using the provided raw sources. Your implementation must include:

1. ingestion/file replay detection
2. incremental window selection
3. safe type conversion
4. technical validation
5. business validation
6. reject/quarantine storage
7. deterministic deduplication
8. foreign-key/dimension resolution
9. insert/update/delete classification
10. transaction-safe target application
11. idempotent reruns
12. watermark advancement only after success
13. audit/run metrics
14. row-count reconciliation
15. revenue reconciliation
16. late-arriving-data strategy
17. rollback/error behavior
18. explanation of how the design changes at billion-row scale

---

# FINAL MIXED INTERVIEW SET

Do these without looking at section headings or prior solutions.

357. State the grain of `retail.order_items`.
358. Why can a join increase row count?
359. Write completed net sales by store.
360. Find customers with no orders.
361. Return each customer's latest order.
362. Deduplicate incoming orders deterministically.
363. Detect orphan incoming product references.
364. Explain `WHERE` vs `HAVING`.
365. Explain `ROW_NUMBER` vs `RANK` vs `DENSE_RANK`.
366. Explain `UNION` vs `UNION ALL`.
367. Write a running sales total.
368. Explain why `TRY_CONVERT` matters in raw ingestion.
369. Detect duplicate source-file replay.
370. Design an incremental watermark.
371. Explain how the seeded late-arriving order challenges a source-modification watermark.
372. Explain idempotency.
373. Design an upsert.
374. Explain transaction boundaries in ETL.
375. Explain SCD Type 1 vs Type 2.
376. State the grain of a sales fact.
377. Explain surrogate keys.
378. Rewrite a non-SARGable date predicate.
379. Explain clustered vs nonclustered indexes.
380. What do you inspect when a query is unexpectedly slow?
381. How do you handle a fact whose dimension member has not arrived?
382. How do you prevent a replayed source file from duplicating target facts?
383. Counts reconcile but revenue does not. What do you inspect?
384. Sketch source → raw → validated → deduplicated → curated → warehouse.
385. Explain why the clean operational tables and dirty raw tables deliberately have different constraint strategies.

---

# Three-Day Priority Path

The complete bank is for mastery. For a three-day sprint, prioritize:

**Day 1:** 1–73 and 97  
**Day 2:** 98–195, 211–251  
**Day 3:** 252–336, 343–356  
**Final:** 357–385 timed

Stretch sections can be completed afterward.

# Mastery Standard

For coding questions, do not mark a problem complete unless you can:

- produce a correct executable query,
- state its output grain,
- explain duplicate/cardinality risk,
- explain NULL/malformed-value behavior,
- identify at least one edge case,
- and defend the approach verbally.
