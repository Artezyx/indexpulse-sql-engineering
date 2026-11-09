USE IndexPulse;
GO
-- Capture the actual execution plan (Ctrl+M in SSMS) before running.
-- Applying CONVERT to OrderDate makes the filter non-SARGable.
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT o.CustomerId, o.Status, COUNT_BIG(*) AS OrderCount, SUM(o.OrderTotal) AS Revenue
FROM dbo.SalesOrders AS o
WHERE o.CustomerId = 42
  AND CONVERT(DATE, o.OrderDate) >= CONVERT(DATE, DATEADD(DAY, -180, SYSUTCDATETIME()))
GROUP BY o.CustomerId, o.Status
ORDER BY o.Status;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
