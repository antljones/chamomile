/*
	--
	--	description
	---------------------------------------------
		List all tables in a database along with sizes.
		If you want to separate table space from index space, you need to use AND i.index_id IN (0,1) 
			for the table space (index_id = 0 is the heap space, index_id = 1 is the size of the 
			clustered index = data pages) and AND i.index_id > 1 for the index-only space
*/
SELECT [schemas].[name]                                                                       AS [schema]
       , [tables].[name]                                                                      AS [table]
       , [partitions].[rows]                                                                  AS [row_count]
       , SUM([allocation_units].[total_pages]) * 8                                            AS [total_space_kb]
       , SUM([allocation_units].[used_pages]) * 8                                             AS [used_space_kb]
       , ( SUM([allocation_units].[total_pages]) - SUM([allocation_units].[used_pages]) ) * 8 AS [unused_space_kb]
FROM   [sys].[tables] AS [tables]
       INNER JOIN [sys].[schemas] AS [schemas]
               ON [schemas].[schema_id] = [tables].[schema_id]
       INNER JOIN [sys].[indexes] AS [indexes]
               ON [tables].[object_id] = [indexes].[object_id]
       INNER JOIN [sys].[partitions] AS [partitions]
               ON [indexes].[object_id] = [partitions].[object_id]
                  AND [indexes].[index_id] = [partitions].[index_id]
       INNER JOIN [sys].[allocation_units] AS [allocation_units]
               ON [partitions].[partition_id] = [allocation_units].[container_id]
WHERE  [tables].[name] NOT LIKE 'dt%'
       AND [tables].[is_ms_shipped] = 0
       AND [indexes].[object_id] > 255
GROUP  BY [schemas].[name]
          , [tables].[name]
          , [partitions].[rows]
--ORDER  BY SUM([allocation_units].[total_pages]) * 8;
ORDER  BY [schemas].[name]
          , [tables].[name];
--ORDER  BY [row_count] DESC; 
