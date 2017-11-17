--
-- Get statistics dates
-- NOTE that rebuilding an index does NOT update all statistics
-- RE: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-stats-properties-transact-sql
-------------------------------------------------
SELECT quotename(db_name()) + N'.'
       + quotename([schemas].[name]) + N'.'
       + quotename([objects].[name])                     AS [object]
       , [objects].[type_desc]                           AS [object_type]
       , [indexes].[name]                                AS [index]
       , [indexes].[type_desc]                           AS [index_type]
       , [dm_db_stats_properties].[last_updated]         AS [last_updated]
       , [dm_db_stats_properties].[rows]				 AS [rows]
       , [dm_db_stats_properties].[modification_counter] AS [modification_counter]
       , *
FROM   [sys].[indexes] AS [indexes]
       JOIN [sys].[objects] AS [objects]
         ON [objects].[object_id] = [indexes].[object_id]
       JOIN [sys].[schemas] AS [schemas]
         ON [schemas].[schema_id] = [objects].[schema_id]
       CROSS apply [sys].[dm_db_stats_properties]([objects].[object_id], [indexes].[index_id]) AS [dm_db_stats_properties]
ORDER BY [dm_db_stats_properties].[last_updated] ASC;
