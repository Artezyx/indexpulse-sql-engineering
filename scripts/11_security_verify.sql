-- CI-safe authorization checks without creating any server logins.
-- Validates object-level permission metadata for the application role.
USE IndexPulse;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='indexpulse_app' AND type='R')
    THROW 51001, 'Missing indexpulse_app role', 1;
GO
IF NOT EXISTS (
 SELECT 1 FROM sys.database_permissions p
 JOIN sys.database_principals r ON r.principal_id=p.grantee_principal_id
 WHERE r.name='indexpulse_app' AND p.class=1
   AND p.major_id=OBJECT_ID('dbo.ReserveProduct') AND p.permission_name='EXECUTE' AND p.state='G'
)
    THROW 51002, 'Application role cannot execute reservation procedure', 1;
GO
DECLARE @table SYSNAME;
DECLARE cursor_check CURSOR LOCAL FAST_FORWARD FOR
 SELECT name FROM (VALUES ('Products'),('InventoryReservations'),('InventoryMovements')) AS v(name);
OPEN cursor_check;
FETCH NEXT FROM cursor_check INTO @table;
WHILE @@FETCH_STATUS=0
BEGIN
 IF (SELECT COUNT(*) FROM sys.database_permissions p
     JOIN sys.database_principals r ON r.principal_id=p.grantee_principal_id
     WHERE r.name='indexpulse_app' AND p.class=1
       AND p.major_id=OBJECT_ID('dbo.'+@table)
       AND p.state='D' AND p.permission_name IN ('INSERT','UPDATE','DELETE')) <> 3
     THROW 51003, 'Required table write denial missing', 1;
 FETCH NEXT FROM cursor_check INTO @table;
END;
CLOSE cursor_check;
DEALLOCATE cursor_check;
PRINT 'Least privilege permissions verified';
GO
