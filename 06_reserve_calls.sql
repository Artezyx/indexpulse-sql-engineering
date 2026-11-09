USE IndexPulse;
GO
-- First call reserves 2 units.
EXEC dbo.ReserveProduct
    @RequestKey = N'IP-RESERVE-0001', @ProductId = 1, @Quantity = 2;
GO
-- Same key/payload is a replay: inventory and ledger remain unchanged.
EXEC dbo.ReserveProduct
    @RequestKey = N'IP-RESERVE-0001', @ProductId = 1, @Quantity = 2;
GO
SELECT ProductId, SeededAvailable, Available FROM dbo.Products WHERE ProductId = 1;
SELECT * FROM dbo.InventoryReservations WHERE RequestKey = N'IP-RESERVE-0001';
SELECT * FROM dbo.InventoryMovements WHERE RequestKey = N'IP-RESERVE-0001';
GO
-- To check payload conflicts, run the following line separately; expected error 50002.
-- EXEC dbo.ReserveProduct @RequestKey = N'IP-RESERVE-0001', @ProductId = 1, @Quantity = 3;
