USE IndexPulse;
GO
-- Rerunning a reservation with exactly the same payload must not change stock.
DECLARE @p INT = (SELECT TOP(1) ProductId FROM dbo.Products WHERE Available >= 2 ORDER BY ProductId);
IF @p IS NULL THROW 51101, 'Seed at least one product with Available >= 2', 1;
DECLARE @before INT = (SELECT Available FROM dbo.Products WHERE ProductId=@p);
DECLARE @key NVARCHAR(128) = CONCAT(N'ci-repeat-',CONVERT(NVARCHAR(36),NEWID()));
EXEC dbo.ReserveProduct @RequestKey=@key,@ProductId=@p,@Quantity=1;
EXEC dbo.ReserveProduct @RequestKey=@key,@ProductId=@p,@Quantity=1;
IF (SELECT Available FROM dbo.Products WHERE ProductId=@p) <> @before-1
    THROW 51102, 'Idempotent replay deducted inventory twice', 1;
IF (SELECT COUNT(*) FROM dbo.InventoryMovements WHERE RequestKey=@key) <> 1
    THROW 51103, 'Unexpected number of inventory movement ledger rows', 1;
PRINT 'Idempotency repeat verified';
GO
