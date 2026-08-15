# Edge-Case Coverage

This document records the deterministic seed cases used by the problem set.

## Why the data is split

`retail.*` is the clean operational model and enforces keys/constraints.

`staging.*_incoming` is intentionally permissive so source defects can exist before validation. This mirrors a real ingestion pipeline and avoids disabling production constraints merely to manufacture bad records.

## Clean operational cases

| Case | Seed |
|---|---|
| Guest order | `retail.orders.order_id = 1005` |
| Customer with no orders | `customer_id = 25` |
| Product never sold | `product_id = 124` |
| NULL customer email | customers 5 and 12 |
| NULL loyalty tiers | multiple customers |
| Discounted order lines | multiple rows |
| Cancelled / refunded / processing / shipped statuses | multiple orders |
| Multi-line orders | multiple orders |
| Deterministic ranking tie | products 121 and 122 have equal completed revenue |
| Out-of-stock inventory | store 1 / product 101 / 2026-07-31 |
| Low-stock inventory | guaranteed rows |
| Different latest snapshot by store | store 8 stops at 2026-06-30 |

## Batch / file cases

| Case | Seed |
|---|---|
| Exact source-file replay | batches 9001/9002 share `CHK-ORD-A` |
| Exact item-file replay | batches 9101/9102 share `CHK-ITEM-A` |
| Later independent order batch | batch 9003 |
| Late-arriving batch | batch 9004 |

## Customer incoming cases

- duplicate email
- malformed customer ID
- missing customer ID
- invalid province
- malformed signup date
- invalid loyalty tier
- valid new customer

## Product incoming cases

- existing product price correction
- multiple versions of an existing product
- category change for SCD Type 2 practice
- new product
- duplicate SKU
- negative cost
- negative price
- cost greater than list price
- malformed numeric cost
- missing product business key
- deletion/tombstone

## Order incoming cases

- multiple versions of the same order
- exact file replay duplicates
- guest order
- NULL business key
- blank business key
- orphan customer
- orphan store
- malformed customer/store IDs
- invalid status
- invalid sales channel
- malformed order date
- future-dated order
- correction to an existing target order
- deletion/tombstone for an existing target order
- same `modified_at` tie requiring `ingested_at` tie-break
- late-arriving event with old business/modification date but recent ingestion

## Order-item incoming cases

- valid lines
- replayed lines
- orphan order
- orphan product
- zero quantity
- negative quantity
- malformed quantity
- negative unit price
- malformed unit price
- negative discount
- discount greater than gross line value
- missing line number
- duplicate `(source_order_id, line_number)` versions

## Inventory incoming cases

- duplicate snapshot version
- orphan store
- orphan product
- malformed snapshot date
- negative on-hand quantity
- malformed on-hand quantity
- negative reorder point

## Automated verification

Run:

```text
sql/00_setup/retail_tsql_seed_validation.sql
```

The script uses `THROW` assertions. Do not begin the exercises unless it finishes with:

```text
ALL SEED VALIDATION CHECKS PASSED
```
