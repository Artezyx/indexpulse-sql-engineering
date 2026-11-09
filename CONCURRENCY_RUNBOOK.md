# Concurrency verification

Run `00_schema.sql`, `01_seed.sql` and `05_reservation_procedure.sql`. Open **two separate SSMS query windows** connected to `IndexPulse`.

1. Run the following in **session A**. It intentionally holds a transaction open for ten seconds after reserving:

```sql
USE IndexPulse;
BEGIN TRANSACTION;
EXEC dbo.ReserveProduct @RequestKey=N'CONCURRENT-R-001', @ProductId=2, @Quantity=300;
WAITFOR DELAY '00:00:10';
COMMIT TRANSACTION;
```

2. During those ten seconds, run this in **session B**:

```sql
USE IndexPulse;
EXEC dbo.ReserveProduct @RequestKey=N'CONCURRENT-R-001', @ProductId=2, @Quantity=300;
```

3. Once session A commits, session B should return `Replayed=1` for the same key. Check that only one reservation and one movement exist:

```sql
SELECT COUNT(*) FROM dbo.InventoryReservations WHERE RequestKey=N'CONCURRENT-R-001';
SELECT COUNT(*) FROM dbo.InventoryMovements WHERE RequestKey=N'CONCURRENT-R-001';
SELECT Available FROM dbo.Products WHERE ProductId=2;
```

4. Expected available stock: 200 units (initial 500 minus one 300-unit reservation). Run `07_integrity_audit.sql` afterward.

For tests of *different keys* against scarce stock, use two sessions with different keys and quantities higher than the remaining inventory. At most one may succeed. Always use distinct keys for each separate run and reset disposable data between controlled tests.
