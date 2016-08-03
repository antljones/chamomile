--
-- http://www.sommarskog.se/query-plan-mysteries.html#statinfo
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
