USE IndexPulse;
GO
-- Index usage counters; clear on restart and other engine events.
SELECT OBJECT_NAME(i.object_id) AS TableName, i.name AS IndexName,
       COALESCE(s.user_seeks, 0) AS Seeks,
       COALESCE(s.user_scans, 0) AS Scans,
       COALESCE(s.user_updates, 0) AS Writes
FROM sys.indexes AS i
LEFT JOIN sys.dm_db_index_usage_stats AS s
  ON s.object_id = i.object_id AND s.index_id = i.index_id AND s.database_id = DB_ID()
WHERE i.object_id = OBJECT_ID('dbo.SalesOrders') AND i.index_id > 0;
GO
-- Query Store operational status and recent query costs.
SELECT actual_state_desc, desired_state_desc,
       current_storage_size_mb, max_storage_size_mb
FROM sys.database_query_store_options;
GO
SELECT TOP (10) q.query_id, SUM(rs.count_executions) AS Executions,
       CAST(SUM(rs.avg_duration * rs.count_executions) / NULLIF(SUM(rs.count_executions),0) AS DECIMAL(18,2)) AS MeanDurationMicroseconds
FROM sys.query_store_query AS q
JOIN sys.query_store_plan AS p ON p.query_id = q.query_id
JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id = p.plan_id
GROUP BY q.query_id
ORDER BY MeanDurationMicroseconds DESC;
GO
-- Maintenance: update statistics off-peak in a controlled environment.
-- UPDATE STATISTICS dbo.SalesOrders WITH FULLSCAN;
