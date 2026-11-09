# Query tuning benchmark

**Environment**

- SQL Server version:
- CPU / RAM / storage:
- Database row count:
- Execution-plan collection date:

| Metric | Before indexes / rewrite | After indexes / rewrite |
|---|---:|---:|
| Logical reads: SalesOrders | To measure | To measure |
| CPU time (ms) | To measure | To measure |
| Elapsed time (ms) | To measure | To measure |
| Plan operator | To inspect | To inspect |

**Procedure**

1. Execute `02_baseline.sql` three times before indexing and record the median.
2. Apply `03_indexes.sql`.
3. Execute `04_optimized.sql` three times with the same customer and reporting window.
4. Capture actual execution plans and note the source of improvements (sargability, seek predicates, covering index).
5. Consider cache effects, optimizer choices, cardinality and concurrent workload when interpreting metrics.

Do not fill in performance numbers without reproducing the measurements.
