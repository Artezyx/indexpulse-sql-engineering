USE IndexPulse;
GO
CREATE OR ALTER PROCEDURE dbo.ReserveProduct
    @RequestKey NVARCHAR(128),
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @RequestKey IS NULL OR LEN(LTRIM(RTRIM(@RequestKey))) = 0
       OR @ProductId IS NULL OR @ProductId <= 0 OR @Quantity IS NULL OR @Quantity <= 0
    BEGIN
        THROW 50001, 'A request key, product and positive quantity are required.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @PriorProduct INT;
        DECLARE @PriorQuantity INT;

        -- Unique-key-range lock serializes concurrent attempts with the same key.
        SELECT @PriorProduct = ProductId, @PriorQuantity = Quantity
        FROM dbo.InventoryReservations WITH (UPDLOCK, HOLDLOCK)
        WHERE RequestKey = @RequestKey;

        IF @PriorProduct IS NOT NULL
        BEGIN
            IF @PriorProduct <> @ProductId OR @PriorQuantity <> @Quantity
                THROW 50002, 'Idempotency key already belongs to a different reservation.', 1;
            COMMIT TRANSACTION;
            SELECT @RequestKey AS RequestKey, @ProductId AS ProductId,
                   @Quantity AS Quantity, CAST(1 AS BIT) AS Replayed;
            RETURN;
        END;

        UPDATE dbo.Products WITH (UPDLOCK)
        SET Available = Available - @Quantity
        WHERE ProductId = @ProductId AND Available >= @Quantity;
        IF @@ROWCOUNT <> 1
            THROW 50003, 'Product not found or insufficient stock.', 1;

        INSERT dbo.InventoryReservations (RequestKey, ProductId, Quantity)
        VALUES (@RequestKey, @ProductId, @Quantity);
        INSERT dbo.InventoryMovements (ProductId, RequestKey, QuantityDelta)
        VALUES (@ProductId, @RequestKey, -@Quantity);
        COMMIT TRANSACTION;

        SELECT @RequestKey AS RequestKey, @ProductId AS ProductId,
               @Quantity AS Quantity, CAST(0 AS BIT) AS Replayed;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
