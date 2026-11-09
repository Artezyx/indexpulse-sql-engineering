USE IndexPulse;
GO
SET NOCOUNT ON;
IF NOT EXISTS (SELECT 1 FROM dbo.Customers)
BEGIN
    ;WITH n AS (
        SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS x
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    )
    INSERT dbo.Customers (FullName, Region, Email)
    SELECT CONCAT(N'Customer ', x),
           CASE WHEN x % 4 = 0 THEN 'MX' WHEN x % 4 = 1 THEN 'US'
                WHEN x % 4 = 2 THEN 'CA' ELSE 'BR' END,
           CONCAT('customer', x, '@indexpulse.local')
    FROM n;
END;
GO
IF NOT EXISTS (SELECT 1 FROM dbo.Products)
BEGIN
    ;WITH n AS (
        SELECT TOP (100) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS x
        FROM sys.all_objects
    )
    INSERT dbo.Products (Sku, UnitPrice, SeededAvailable, Available)
    SELECT CONCAT('PRD-', RIGHT(CONCAT('0000', x), 4)),
           CAST(25 + (x % 75) * 3.5 AS DECIMAL(12,2)),
           500, 500
    FROM n;
END;
GO
IF NOT EXISTS (SELECT 1 FROM dbo.SalesOrders)
BEGIN
    ;WITH n AS (
        SELECT TOP (50000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS x
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    )
    INSERT dbo.SalesOrders (CustomerId, OrderDate, Status, OrderTotal)
    SELECT 1 + ((x - 1) % 1000),
           DATEADD(MINUTE, -(x % 525600), SYSUTCDATETIME()),
           CASE WHEN x % 10 = 0 THEN 'CANCELLED'
                WHEN x % 3 = 0 THEN 'SHIPPED' ELSE 'PAID' END,
           CAST(50 + (x % 700) * 1.35 AS DECIMAL(12,2))
    FROM n;
END;
GO
IF NOT EXISTS (SELECT 1 FROM dbo.SalesOrderLines)
BEGIN
    INSERT dbo.SalesOrderLines (OrderId, ProductId, Quantity)
    SELECT OrderId, 1 + (OrderId % 100), 1 + (OrderId % 3)
    FROM dbo.SalesOrders;
END;
GO
SELECT
    (SELECT COUNT(*) FROM dbo.Customers) AS CustomerCount,
    (SELECT COUNT(*) FROM dbo.Products) AS ProductCount,
    (SELECT COUNT(*) FROM dbo.SalesOrders) AS OrderCount,
    (SELECT COUNT(*) FROM dbo.SalesOrderLines) AS LineCount;
