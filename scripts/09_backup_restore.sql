-- SQL Server instance administrator only. Linux Docker paths are shown.
-- Ensure /var/opt/mssql/backups exists and SQL Server can write to it.
-- Do not run against a production database without an approved recovery plan.
USE master;
GO
BACKUP DATABASE IndexPulse
TO DISK = N'/var/opt/mssql/backups/IndexPulse_full.bak'
WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;
GO
RESTORE VERIFYONLY
FROM DISK = N'/var/opt/mssql/backups/IndexPulse_full.bak'
WITH CHECKSUM;
GO
-- Inspect logical file names before restoration. For a default CREATE DATABASE,
-- these are usually IndexPulse and IndexPulse_log; change MOVE names if needed.
RESTORE FILELISTONLY FROM DISK = N'/var/opt/mssql/backups/IndexPulse_full.bak';
GO
IF DB_ID(N'IndexPulse_Recovery') IS NOT NULL
    THROW 51009, 'Recovery database exists. Drop it explicitly before retrying.', 1;
GO
RESTORE DATABASE IndexPulse_Recovery
FROM DISK = N'/var/opt/mssql/backups/IndexPulse_full.bak'
WITH MOVE N'IndexPulse' TO N'/var/opt/mssql/data/IndexPulse_Recovery.mdf',
     MOVE N'IndexPulse_log' TO N'/var/opt/mssql/data/IndexPulse_Recovery_log.ldf',
     RECOVERY, CHECKSUM, STATS = 10;
GO
SELECT name, state_desc FROM sys.databases
WHERE name IN (N'IndexPulse', N'IndexPulse_Recovery');
GO
-- Verification after restore:
SELECT COUNT_BIG(*) AS RecoveredOrders FROM IndexPulse_Recovery.dbo.SalesOrders;
GO
