USE IndexPulse;
GO
SET NOCOUNT ON;
-- Fails if available balance does not match the original seed + movement ledger.
IF EXISTS (
    SELECT 1 FROM dbo.Products p
    OUTER APPLY (SELECT COALESCE(SUM(m.QuantityDelta), 0) AS MovementTotal
                 FROM dbo.InventoryMovements m WHERE m.ProductId = p.ProductId) x
    WHERE p.Available <> p.SeededAvailable + x.MovementTotal
)
    THROW 51001, 'Inventory and movement ledger are inconsistent.', 1;
IF EXISTS (
    SELECT 1 FROM dbo.InventoryReservations r
    LEFT JOIN dbo.InventoryMovements m ON m.RequestKey = r.RequestKey
    WHERE m.MovementId IS NULL OR m.ProductId <> r.ProductId OR m.QuantityDelta <> -r.Quantity
)
    THROW 51002, 'Reservation is missing a matching movement.', 1;
IF EXISTS (SELECT 1 FROM dbo.Products WHERE Available < 0)
    THROW 51003, 'Negative inventory detected.', 1;
SELECT 'PASS' AS IntegrityStatus,
       (SELECT COUNT(*) FROM dbo.InventoryReservations) AS Reservations,
       (SELECT COUNT(*) FROM dbo.InventoryMovements) AS Movements;
GO
