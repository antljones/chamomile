/*
	--
	--	description
	---------------------------------------------
		List all tables in a database along with sizes.
		If you want to separate table space from index space, you need to use AND i.index_id IN (0,1) 
			for the table space (index_id = 0 is the heap space, index_id = 1 is the size of the 
			clustered index = data pages) and AND i.index_id > 1 for the index-only space

	--
	--	notes
	---------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--
	
	--
	-- references
	---------------------------------------------
*/
select [schemas].[name]                                                                   	as [schema]
       , [tables].[name]                                                                  	as [table]
       , [partitions].[rows]                                                              	as [row_count]
       , sum([allocation_units].[total_pages]) * 8                                          	as [total_space_kb]
       , sum([allocation_units].[used_pages]) * 8                                           	as [used_space_kb]
       , ( sum([allocation_units].[total_pages]) - sum([allocation_units].[used_pages]) ) * 8 	as [unused_space_kb]
from   [sys].[tables] as [tables]
       inner join [sys].[schemas] as [schemas]
               on [schemas].[schema_id] = [tables].[schema_id]
       inner join [sys].[indexes] as [indexes]
               on [tables].[object_id] = [indexes].[object_id]
       inner join [sys].[partitions] as [partitions]
               on [indexes].[object_id] = [partitions].[object_id]
                  and [indexes].[index_id] = [partitions].[index_id]
       inner join [sys].[allocation_units] as [allocation_units]
               on [partitions].[partition_id] = [allocation_units].[container_id]
where  [tables].[name] not like 'dt%'
       and [tables].[is_ms_shipped] = 0
       and [indexes].[object_id] > 255
group  by [schemas].[name]
          , [tables].[name]
          , [partitions].[rows]
--order by sum([allocation_units].[total_pages]) * 8;
--order by [schemas].[name], [tables].[name];
order  by [row_count] desc; 
