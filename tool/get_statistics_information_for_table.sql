--
-- RE: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-stats-properties-transact-sql
------------------------------------------------------------
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

--
-- http://www.sommarskog.se/query-plan-mysteries.html#statinfo
------------------------------------------------------------
/*
	If you believe statistics are out of date, you can use this command:

	UPDATE STATISTICS tbl WITH FULLSCAN, INDEX
	This updates all statistics related to indexes on the table by scanning them in full. FULLSCAN is not necessary, but I have been burned too often by inaccurate statistics to be really comfortable with sampled statistics (which is the default). Restricting the statistics update to indexes only reduces execution time considerably, because SQL Server scans the table once for each non-index statistics.

	You can also update statistics for a single index. The syntax for this is not what you may expect:

	UPDATE STATISTICS tbl indexname WITH FULLSCAN

	Note that after updating statistics, you may see an immediate performance improvement in the application. This does necessarily prove that outdated statistics was the problem. Since updated statistics causes recompilation, the parameters may be re-sniffed and you get a better plan.

	DBCC SHOW_STATISTICS (Orders, OrderDate)
*/
-------------------------------------------------
DECLARE @tbl NVARCHAR(265);

SELECT @tbl = '<table_name>';

SELECT [o].[name]
       , [s].[stats_id]
       , [s].[name]
       , [s].[auto_created]
       , [s].[user_created]
       , SUBSTRING([scols].[cols]
                   , 3
                   , LEN([scols].[cols])) AS [stat_cols]
       , STATS_DATE([o].[object_id]
                    , [s].[stats_id])     AS [stats_date]
       , [s].[filter_definition]
FROM   [sys].[objects] [o]
       JOIN [sys].[stats] [s]
         ON [s].[object_id] = [o].[object_id]
       CROSS APPLY (SELECT ', ' + [c].[name]
                    FROM   [sys].[stats_columns] [sc]
                           JOIN [sys].[columns] [c]
                             ON [sc].[object_id] = [c].[object_id]
                                AND [sc].[column_id] = [c].[column_id]
                    WHERE  [sc].[object_id] = [s].[object_id]
                           AND [sc].[stats_id] = [s].[stats_id]
                    ORDER  BY [sc].[stats_column_id]
                    FOR XML PATH('')) AS [scols] ( [cols] )
WHERE  [o].[name] = @tbl
ORDER  BY [o].[name]
          , [s].[stats_id]; 
