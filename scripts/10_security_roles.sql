-- Apply only after dbo.ReserveProduct exists. SQL Server 2022+.
-- Least-privilege application boundary: deny direct table changes.
USE IndexPulse;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'indexpulse_app')
    CREATE ROLE indexpulse_app;
GO
DENY INSERT, UPDATE, DELETE ON OBJECT::dbo.Products TO indexpulse_app;
DENY INSERT, UPDATE, DELETE ON OBJECT::dbo.InventoryReservations TO indexpulse_app;
DENY INSERT, UPDATE, DELETE ON OBJECT::dbo.InventoryMovements TO indexpulse_app;
GRANT EXECUTE ON OBJECT::dbo.ReserveProduct TO indexpulse_app;
GO
-- Create a uniquely named login/user separately using a secret manager.
-- Then grant ALTER ROLE indexpulse_app ADD MEMBER [application_user];
-- The app must not connect as dbo or sa.
