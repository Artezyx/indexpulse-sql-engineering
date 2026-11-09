USE IndexPulse;
GO
-- Equality on CustomerId, then range on OrderDate; includes aggregate columns.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_Customer_Date'
                  AND object_id = OBJECT_ID('dbo.SalesOrders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_Customer_Date
        ON dbo.SalesOrders (CustomerId, OrderDate)
        INCLUDE (Status, OrderTotal);
END;
GO
-- Helps investigative queries by status and time range.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_Status_Date'
                  AND object_id = OBJECT_ID('dbo.SalesOrders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_Status_Date
        ON dbo.SalesOrders (Status, OrderDate)
        INCLUDE (CustomerId, OrderTotal);
END;
GO
