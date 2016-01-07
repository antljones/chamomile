/*
	Change to target database prior to running.
*/
IF schema_id(N'administration') IS NULL
  EXECUTE (N'CREATE SCHEMA administration');

go

IF object_id(N'[administration].[defragment_index]', N'P') IS NOT NULL
  DROP PROCEDURE [administration].[defragment_index];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'administration', @object [sysname] = N'defragment_index';
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
	
	execute [administration].[defragment_index];
	
*/
CREATE PROCEDURE [administration].[defragment_index] @maximum_fragmentation [INT] = 25
                                                     , @fillfactor          [INT] = 90
                                                     , @table_filter        [SYSNAME] = NULL
AS
  BEGIN
      DECLARE @schema                         [SYSNAME]
              , @table                        [SYSNAME]
              , @index                        [SYSNAME]
              , @average_fragmentation_before [INT]
              , @average_fragmentation_after  [INT]
              , @sql                          [NVARCHAR](max);
      --
      -------------------------------------------
      DECLARE [table_cursor] CURSOR FOR
        SELECT object_schema_name([dm_db_index_physical_stats].[object_id])                       AS [schema]
               , object_name([dm_db_index_physical_stats].[object_id])                            AS [table]
               , [indexes].[name]                                                                 AS [index]
               , cast([dm_db_index_physical_stats].[avg_fragmentation_in_percent] * 100 AS [INT]) AS [average_fragmentation_before]
        FROM   sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'LIMITED') AS [dm_db_index_physical_stats]
               INNER JOIN sys.[indexes] AS [indexes]
                       ON [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                          AND [dm_db_index_physical_stats].index_id = [indexes].index_id
        WHERE  [dm_db_index_physical_stats].[avg_fragmentation_in_percent] * 100 > @maximum_fragmentation
               AND ( ( object_name([indexes].[object_id]) LIKE N'%' + @table_filter + N'%' )
                      OR ( @table_filter IS NULL ) );

      --
      BEGIN
          OPEN [table_cursor];

          FETCH next FROM [table_cursor] INTO @schema, @table, @index, @average_fragmentation_before;

          WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @sql = 'alter index [' + @index + N'] on [' + @schema
                           + N'].[' + @table
                           + '] rebuild with (fillfactor='
                           + cast(@fillfactor AS [SYSNAME]) + ')';

                --
                -------------------------------
                IF @sql IS NOT NULL
                  BEGIN
                      EXECUTE (@sql);

                      --
                      -- output
                      ---------------------------
                      SELECT @sql                                                                               AS [@sql]
                             , @average_fragmentation_before                                                    AS [average_fragmentation_before]
                             , cast([dm_db_index_physical_stats].[avg_fragmentation_in_percent] * 100 AS [INT]) AS [average_fragmentation_after]
                      FROM   sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'LIMITED') AS [dm_db_index_physical_stats]
                             INNER JOIN sys.[indexes] AS [indexes]
                                     ON [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                                        AND [dm_db_index_physical_stats].index_id = [indexes].index_id
                      WHERE  object_schema_name([dm_db_index_physical_stats].[object_id]) = @schema
                             AND object_name([dm_db_index_physical_stats].[object_id]) = @table
                             AND [indexes].[name] = @index;
                  END;

                FETCH next FROM [table_cursor] INTO @schema, @table, @index, @average_fragmentation_before;
            END

          CLOSE [table_cursor];

          DEALLOCATE [table_cursor];
      END;
  END;

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment_index', DEFAULT, DEFAULT))
  EXEC sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'Rebuild all indexes over @maximum_fragmentation.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'revision_20160106', N'schema', N'administration', N'procedure', N'defragment_index', DEFAULT, DEFAULT))
  EXEC sys.sp_dropextendedproperty
    @name         = N'revision_20160106'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name         = N'revision_20160106'
  , @value      = N'KELightsey@gmail.com – Added @table_filter parameter to allow defragging for only a specified table (using LIKE constraint).'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'revision_20150810', N'schema', N'administration', N'procedure', N'defragment_index', DEFAULT, DEFAULT))
  EXEC sys.sp_dropextendedproperty
    @name         = N'revision_20150810'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name         = N'revision_20150810'
  , @value      = N'KELightsey@gmail.com – created.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'package_administration', N'schema', N'administration', N'procedure', N'defragment_index', DEFAULT, DEFAULT))
  EXEC sys.sp_dropextendedproperty
    @name         = N'package_administration'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name         = N'package_administration'
  , @value      = N'label_only'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'execute_as', N'schema', N'administration', N'procedure', N'defragment_index', DEFAULT, DEFAULT))
  EXEC sys.sp_dropextendedproperty
    @name         = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name         = N'execute_as'
  , @value      = N'execute [administration].[defragment_index];'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment_index', N'parameter', N'@table_filter'))
  EXEC sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index'
    , @level2type = N'parameter'
    , @level2name = N'@table_filter';

go

EXEC sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'@table [sysname] NOT NULL - optional parameter, if used, constrains the defrag to tables matching on LIKE syntax.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index'
  , @level2type = N'parameter'
  , @level2name = N'@table_filter';

go 
