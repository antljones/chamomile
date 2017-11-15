--
-------------------------------------------------
SELECT quotename(object_schema_name([dm_exec_query_plan].[objectid]))
       + N'.'
       + quotename(object_name([dm_exec_query_plan].[objectid]))                                             AS [object]
       , avg([dm_exec_query_stats].[total_worker_time] / [dm_exec_query_stats].[execution_count]) / 1000000  AS [average_cpu_time_seconds]
       , avg([dm_exec_query_stats].[total_elapsed_time] / [dm_exec_query_stats].[execution_count]) / 1000000 AS [average_run_time_seconds]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS apply [sys].[dm_exec_sql_text]([dm_exec_query_stats].[plan_handle]) AS [dm_exec_sql_txt]
       CROSS apply [sys].[dm_exec_query_plan]([dm_exec_query_stats].[plan_handle]) AS [dm_exec_query_plan]
WHERE  DB_NAME([dm_exec_sql_txt].[dbid]) = @database
GROUP  BY quotename(object_schema_name([dm_exec_query_plan].[objectid]))
          + N'.'
          + quotename(object_name([dm_exec_query_plan].[objectid]))
ORDER  BY [average_cpu_time_seconds] DESC;

--
-- http://www.codeproject.com/Articles/579593/How-to-Find-the-Top-Most-Expens
-- Top 10 Total CPU Consuming Queries
-------------------------------------------------
SELECT TOP 10 [dm_exec_sql_text].[text]                                                             AS [sql_text]
              , [dm_exec_query_plan].[query_plan]                                                   AS [query_plan]
              , [dm_exec_query_stats].[total_worker_time]                                           AS [cpu_time]
              , [dm_exec_query_stats].[execution_count]                                             AS [execution_count]
              , [dm_exec_query_stats].[total_worker_time] / [dm_exec_query_stats].[execution_count] AS [average_cpu_time_microseconds]
              , [dm_exec_sql_text].[text]                                                           AS [sql_text]
              , DB_NAME([dm_exec_sql_text].[dbid])                                                  AS [database]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY SYS.[dm_exec_sql_text] ([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
       CROSS APPLY SYS.[dm_exec_query_plan] ([dm_exec_query_stats].[plan_handle]) AS [dm_exec_query_plan]
WHERE  DB_NAME ([dm_exec_sql_text].[dbid]) = @database
ORDER  BY [dm_exec_query_stats].[total_worker_time] DESC;

--
-- Top 10 I/O Intensive Queries
-------------------------------------------------
SELECT TOP 10 [dm_exec_query_stats].[total_logical_reads]      AS [total_logical_reads]
              , [dm_exec_query_stats].[total_logical_writes]   AS [total_logical_writes]
              , [dm_exec_query_stats].[execution_count]        AS [execution_count]
              , [dm_exec_query_stats].[total_logical_reads]
                + [dm_exec_query_stats].[total_logical_writes] AS [total_io]
              , [dm_exec_sql_text].[text]                      AS [sql_text]
              , DB_NAME([dm_exec_sql_text].[dbid])             AS [database]
              , [dm_exec_sql_text].[objectid]                  AS [object_id]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY [sys].[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
WHERE  [dm_exec_query_stats].[total_logical_reads]
       + [dm_exec_query_stats].[total_logical_writes] > 0
       AND DB_NAME ([dm_exec_sql_text].[dbid]) = @database
ORDER  BY [total_io] DESC;

--
-- Execution Count of Each Query
-------------------------------------------------
SELECT [dm_exec_query_stats].[execution_count] AS [execution_count]
       , [dm_exec_sql_text].[text]             AS [sql_text]
       , [dm_exec_sql_text].[dbid]             AS [dbid]
       , [dm_exec_sql_text].[objectid]         AS [object_id]
       , DB_NAME([dm_exec_sql_text].[dbid])    AS [database]
       , [dm_exec_query_stats].*
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY [sys].[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
WHERE  DB_NAME ([dm_exec_sql_text].[dbid]) = @database
ORDER  BY [dm_exec_query_stats].[execution_count] DESC; 
