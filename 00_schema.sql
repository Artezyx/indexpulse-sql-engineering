-- Execute using SSMS or sqlcmd. Creates the isolated IndexPulse database.
IF DB_ID(N'IndexPulse') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE IndexPulse');
END;
GO
USE IndexPulse;
GO
IF OBJECT_ID('dbo.Customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customers (
        CustomerId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        FullName NVARCHAR(150) NOT NULL,
        Region CHAR(2) NOT NULL,
        Email NVARCHAR(220) NOT NULL UNIQUE
    );
END;
GO
IF OBJECT_ID('dbo.Products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Products (
        ProductId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Sku VARCHAR(70) NOT NULL UNIQUE,
        UnitPrice DECIMAL(12,2) NOT NULL,
        SeededAvailable INT NOT NULL,
        Available INT NOT NULL,
        CONSTRAINT CK_Products_UnitPrice CHECK (UnitPrice >= 0),
        CONSTRAINT CK_Products_Stock CHECK (Available >= 0)
    );
END;
GO
IF OBJECT_ID('dbo.SalesOrders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SalesOrders (
        OrderId BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CustomerId INT NOT NULL REFERENCES dbo.Customers(CustomerId),
        OrderDate DATETIME2(0) NOT NULL,
        Status VARCHAR(20) NOT NULL,
        OrderTotal DECIMAL(12,2) NOT NULL,
        CONSTRAINT CK_SalesOrders_Total CHECK (OrderTotal >= 0),
        CONSTRAINT CK_SalesOrders_Status CHECK (Status IN ('PAID','SHIPPED','CANCELLED'))
    );
END;
GO
IF OBJECT_ID('dbo.SalesOrderLines', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SalesOrderLines (
        OrderLineId BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        OrderId BIGINT NOT NULL REFERENCES dbo.SalesOrders(OrderId),
        ProductId INT NOT NULL REFERENCES dbo.Products(ProductId),
        Quantity INT NOT NULL CHECK (Quantity > 0)
    );
END;
GO
IF OBJECT_ID('dbo.InventoryReservations', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.InventoryReservations (
        RequestKey NVARCHAR(128) NOT NULL PRIMARY KEY,
        ProductId INT NOT NULL REFERENCES dbo.Products(ProductId),
        Quantity INT NOT NULL CHECK (Quantity > 0),
        CreatedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO
IF OBJECT_ID('dbo.InventoryMovements', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.InventoryMovements (
        MovementId BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ProductId INT NOT NULL REFERENCES dbo.Products(ProductId),
        RequestKey NVARCHAR(128) NOT NULL REFERENCES dbo.InventoryReservations(RequestKey),
        QuantityDelta INT NOT NULL CHECK (QuantityDelta < 0),
        OccurredAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT UQ_InventoryMovements_Request UNIQUE (RequestKey)
    );
END;
GO
-- Optional Query Store configuration; requires sufficient database permissions.
ALTER DATABASE IndexPulse SET QUERY_STORE = ON;
GO
