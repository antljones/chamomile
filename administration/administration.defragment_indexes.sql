use [chamomile];

go

if object_id(N'[administration].[defragment_indexes]'
             , N'P') is not null
  drop procedure [administration].[defragment_indexes];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'administration', @object [sysname] = N'defragment_indexes';
	--
	select N'[' + object_schema_name([extended_properties].[major_id]) +N'].['+
       case when Object_name([objects].[parent_object_id]) is not null 
			then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
			else Object_name([objects].[object_id]) +N']' + 
				case when [parameters].[parameter_id] > 0
					then coalesce(N'.['+[parameters].[name] + N']', N'') 
					else N'' 
				end +
				case when columnproperty ([objects].[object_id], [parameters].[name], N'IsOutParam') = 1  then N' output'
					else N''
				end
		end                                                                     as [object]
       ,case when [extended_properties].[minor_id]=0 then [objects].[type_desc]
			else N'PARAMETER'
        end                                                                     as [type]
		   ,[extended_properties].[name]                                        as [property]
		   ,[extended_properties].[value]                                       as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id]=[objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id]=[parameters].[object_id] and
					 [parameters].[parameter_id]=[extended_properties].[minor_id]
	where  [schemas].[name]=@schema and [objects].[name]=@object
	order  by [parameters].[parameter_id],[object],[type],[property]; 
	
	execute [administration].[defragment_indexes];
	
*/
create procedure [administration].[defragment_indexes] @maximum_fragmentation [int] = 25
                                                       , @fillfactor          [int] = 90
as
  begin
      declare @schema                       [sysname],
              @table                        [sysname],
              @index                        [sysname],
              @average_fragmentation_before [int],
              @average_fragmentation_after  [int],
              @sql                          [nvarchar](max);
      --
      -------------------------------------------
      declare [table_cursor] cursor for
        select object_schema_name([dm_db_index_physical_stats].[object_id])                       as [schema]
               , object_name([dm_db_index_physical_stats].[object_id])                            as [table]
               , [indexes].[name]                                                                 as [index]
               , cast([dm_db_index_physical_stats].[avg_fragmentation_in_percent] * 100 as [int]) as [average_fragmentation_before]
        from   sys.dm_db_index_physical_stats(db_id()
                                              , null
                                              , null
                                              , null
                                              , 'LIMITED') as [dm_db_index_physical_stats]
               inner join sys.[indexes] as [indexes]
                       on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                          and [dm_db_index_physical_stats].index_id = [indexes].index_id
        where  [dm_db_index_physical_stats].[avg_fragmentation_in_percent] * 100 > @maximum_fragmentation;

      --
      begin
          open [table_cursor];

          fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;

          while @@fetch_status = 0
            begin
                set @sql = 'alter index [' + @index + N'] on [' + @schema
                           + N'].[' + @table
                           + '] rebuild with (fillfactor='
                           + cast(@fillfactor as [sysname]) + ')';

                --
                -------------------------------
                if @sql is not null
                  begin
                      execute (@sql);

                      --
                      -- output
                      ---------------------------
                      select @sql                                                                               as [@sql]
                             , @average_fragmentation_before                                                    as [average_fragmentation_before]
                             , cast([dm_db_index_physical_stats].[avg_fragmentation_in_percent] * 100 as [int]) as [average_fragmentation_after]
                      from   sys.dm_db_index_physical_stats(db_id()
                                                            , null
                                                            , null
                                                            , null
                                                            , 'LIMITED') as [dm_db_index_physical_stats]
                             inner join sys.[indexes] as [indexes]
                                     on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                                        and [dm_db_index_physical_stats].index_id = [indexes].index_id
                      where  object_schema_name([dm_db_index_physical_stats].[object_id]) = @schema
                             and object_name([dm_db_index_physical_stats].[object_id]) = @table
                             and [indexes].[name] = @index;
                  end;

                fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;
            end

          close [table_cursor];

          deallocate [table_cursor];
      end;
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'defragment_indexes'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'defragment_indexes';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Rebuild all indexes over @maximum_fragmentation.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'defragment_indexes';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150810'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'defragment_indexes'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20150810',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'defragment_indexes';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20150810',
  @value = N'KLightsey@hcpnv.com – created.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'defragment_indexes';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_refresh_dwreporting'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'defragment_indexes'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_refresh_dwreporting',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'defragment_indexes';

go

exec sys.sp_addextendedproperty
  @name = N'package_refresh_dwreporting',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'defragment_indexes';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'defragment_indexes'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'defragment_indexes';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'execute [administration].[defragment_indexes];',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'defragment_indexes';

go 
