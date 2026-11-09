USE IndexPulse;
GO
-- SARGable date range: permits a seek against IX_Orders_Customer_Date.
-- Compare logical reads and CPU/elapsed time to 02_baseline.sql.
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
DECLARE @cutoff DATE = CONVERT(DATE, DATEADD(DAY, -180, SYSUTCDATETIME()));
SELECT o.CustomerId, o.Status, COUNT_BIG(*) AS OrderCount, SUM(o.OrderTotal) AS Revenue
FROM dbo.SalesOrders AS o
WHERE o.CustomerId = 42 AND o.OrderDate >= @cutoff
GROUP BY o.CustomerId, o.Status
ORDER BY o.Status;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
-- To isolate rewriting from indexing, compare 02 before 03 then 04 after 03.
