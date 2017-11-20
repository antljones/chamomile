/*
	Change to target database prior to running.
*/
IF schema_id(N'administration') IS NULL
  EXECUTE (N'CREATE SCHEMA administration;');

go

IF object_id(N'[administration].[defragment_index]', N'P') IS NOT NULL
  DROP PROCEDURE [administration].[defragment_index]; ;
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
	
	-- execute_as
	DECLARE @maximum_fragmentation    [INT] = 25
			, @minimum_page_count     [INT] = 500
			, @fillfactor             [INT] = NULL
			, @reorganize_demarcation [INT] = 25
			, @defrag_count_limit     [INT] = 2
			, @output                 [XML];
	EXECUTE [administration].[defragment_index]
		@maximum_fragmentation=@maximum_fragmentation
		, @minimum_page_count=@minimum_page_count
		, @fillfactor=@fillfactor
		, @reorganize_demarcation=@reorganize_demarcation
		, @defrag_count_limit=@defrag_count_limit
		, @output=@output OUTPUT;
	SELECT @output as [output];
	
*/
CREATE PROCEDURE [administration].[defragment_index] @maximum_fragmentation    [INT] = 25
                                                     , @minimum_page_count     [INT] = 500
                                                     , @fillfactor             [INT] = NULL
                                                     , @reorganize_demarcation [INT] = 25
                                                     , @defrag_count_limit     [INT] = NULL
                                                     , @output                 [XML] = NULL OUT
AS
  BEGIN
      DECLARE @schema                         [SYSNAME]
              , @table                        [SYSNAME]
              , @index                        [SYSNAME]
              , @average_fragmentation_before DECIMAL(10, 2)
              , @average_fragmentation_after  DECIMAL(10, 2)
              , @sql                          [NVARCHAR](max)
              , @xml_builder                  [XML]
              , @defrag_count                 [INT] = 0
              , @start                        DATETIME2
              , @complete                     DATETIME2
              , @elapsed                      DECIMAL(10, 2)
              --
              , @timestamp                    DATETIME = CURRENT_TIMESTAMP
              , @this                         NVARCHAR(1024) = quotename(db_name()) + N'.'
                + quotename(object_schema_name(@@PROCID))
                + N'.' + quotename(object_name(@@PROCID));

      --
      -------------------------------------------
      SELECT @output = COALESCE(@output, N'<index_list subject="' + @this
                                         + '" timestamp="'
                                         + CONVERT(SYSNAME, @timestamp, 126) + '"/>')
             , @defrag_count_limit = COALESCE(@defrag_count_limit, 1);
      --
      -------------------------------------------
	  set @output.modify(N'insert attribute maximum_fragmentation {sql:variable("@maximum_fragmentation")} as last into (/*)[1]');
	  set @output.modify(N'insert attribute minimum_page_count {sql:variable("@minimum_page_count")} as last into (/*)[1]');
	  set @output.modify(N'insert attribute fillfactor {sql:variable("@fillfactor")} as last into (/*)[1]');
	  set @output.modify(N'insert attribute reorganize_demarcation {sql:variable("@reorganize_demarcation")} as last into (/*)[1]');
	  set @output.modify(N'insert attribute defrag_count_limit {sql:variable("@defrag_count_limit")} as last into (/*)[1]');

      --
      -------------------------------------------
      DECLARE [table_cursor] CURSOR FOR
        SELECT [schemas].[name]                                              AS [schema]
               , [tables].[name]                                             AS [table]
               , [indexes].[name]                                            AS [index]
               , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] AS [average_fragmentation_before]
        FROM   [sys].[dm_db_index_physical_stats](db_id(), NULL, NULL, NULL, 'LIMITED') AS [dm_db_index_physical_stats]
               JOIN [sys].[indexes] AS [indexes]
                 ON [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                    AND [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
               JOIN [sys].[tables] AS [tables]
                 ON [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
               JOIN [sys].[schemas] AS [schemas]
                 ON [schemas].[schema_id] = [tables].[schema_id]
        WHERE  [indexes].[name] IS NOT NULL
               AND [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
			   AND [dm_db_index_physical_stats].[page_count] > @minimum_page_count
        ORDER  BY [dm_db_index_physical_stats].[avg_fragmentation_in_percent] DESC
                  , [schemas].[name]
                  , [tables].[name];

      --
      -------------------------------------------
      BEGIN
          OPEN [table_cursor];

          FETCH next FROM [table_cursor] INTO @schema, @table, @index, @average_fragmentation_before;

          WHILE @@FETCH_STATUS = 0
                AND ( @defrag_count < @defrag_count_limit )
            BEGIN
                IF @average_fragmentation_before > @reorganize_demarcation
                  BEGIN
                      SET @sql = 'alter index [' + @index + N'] on [' + @schema
                                 + N'].[' + @table + '] rebuild ';

                      IF @fillfactor IS NOT NULL
                        BEGIN
                            SET @sql = @sql + ' with (fillfactor='
                                       + cast(@fillfactor AS [SYSNAME]) + ')';
                        END;

                      SET @sql = @sql + ' ; ';
                  END;
                ELSE
                  BEGIN
                      SET @sql = 'alter index [' + @index + N'] on [' + @schema
                                 + N'].[' + @table + '] reorganize';
                  END;

                --
                -------------------------------
                IF @sql IS NOT NULL
                  BEGIN
                      --
                      ---------------------------
                      SET @start = CURRENT_TIMESTAMP;

                      EXECUTE (@sql);

                      SET @complete = CURRENT_TIMESTAMP;
                      SET @elapsed = datediff(millisecond, @start, @complete);
                      --
                      -- build output
                      ---------------------------
                      SET @xml_builder = (SELECT @schema                                                                               AS N'@schema'
                                                 , @table                                                                              AS N'@table'
                                                 , @index                                                                              AS N'@index'
                                                 , @average_fragmentation_before                                                       AS N'@average_fragmentation_before'
                                                 , cast([dm_db_index_physical_stats].[avg_fragmentation_in_percent] AS DECIMAL(10, 2)) AS N'@average_fragmentation_after'
                                                 , @elapsed                                                                            AS N'@elapsed_milliseconds'
                                                 , @sql                                                                                AS N'sql'
                                          FROM   [sys].[dm_db_index_physical_stats](db_id(), NULL, NULL, NULL, 'LIMITED') AS [dm_db_index_physical_stats]
                                                 JOIN [sys].[indexes] AS [indexes]
                                                   ON [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                                                      AND [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
                                                 JOIN [sys].[tables] AS [tables]
                                                   ON [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
                                                 JOIN [sys].[schemas] AS [schemas]
                                                   ON [schemas].[schema_id] = [tables].[schema_id]
                                          WHERE  [schemas].[name] = @schema
                                                 AND [tables].[name] = @table
                                                 AND [indexes].[name] = @index
                                          FOR xml path(N'result'), root(N'index'));

                      --
                      ---------------------------
                      IF @xml_builder IS NOT NULL
                        BEGIN
                            SET @output.modify(N'insert sql:variable("@xml_builder") as last into (/*)[1]');
                        END;
                  END;

                SET @defrag_count = @defrag_count + 1;

                FETCH next FROM [table_cursor] INTO @schema, @table, @index, @average_fragmentation_before;
            END;

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
    @name = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'Rebuild all indexes over @maximum_fragmentation.'
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
    @name = N'revision_20160106'
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
    @name = N'revision_20150810'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name = N'revision_20150810'
  , @value = N'KELightsey@gmail.com – created.'
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
    @name = N'package_administration'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name = N'package_administration'
  , @value = N'label_only'
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
    @name = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'execute [administration].[defragment_index];  
	DECLARE @maximum_fragmentation    [INT] = 85
			, @fillfactor             [INT] = NULL
			, @reorganize_demarcation [INT] = 25
			, @defrag_count_limit     [INT] = 2
			, @output                 [XML];
	EXECUTE [administration].[defragment_index]
		@maximum_fragmentation=@maximum_fragmentation
		, @fillfactor=@fillfactor
		, @reorganize_demarcation=@reorganize_demarcation
		, @defrag_count_limit=@defrag_count_limit
		, @output=@output OUTPUT;
	SELECT @output as [output];
	'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment_index', N'parameter', N'@minimum_page_count'))
  EXEC sys.sp_dropextendedproperty
    @name = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index'
    , @level2type = N'parameter'
    , @level2name = N'@minimum_page_count';

go

EXEC sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@minimum_page_count [INT] = 500 - Tables with page count less than this will not be defragmented. Default 500.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index'
  , @level2type = N'parameter'
  , @level2name = N'@minimum_page_count';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment_index', N'parameter', N'@fillfactor'))
  EXEC sys.sp_dropextendedproperty
    @name = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index'
    , @level2type = N'parameter'
    , @level2name = N'@fillfactor';

go

EXEC sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@fillfactor [INT] - The fill factor to be used if an index is rebuilt. If NULL, the existing fill factor will be used for the index. DEFAULT - NULL.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index'
  , @level2type = N'parameter'
  , @level2name = N'@fillfactor';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'todo', N'schema', N'administration', N'procedure', N'defragment_index', NULL, NULL))
  EXEC sys.sp_dropextendedproperty
    @name = N'todo'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index';

go

EXEC sys.sp_addextendedproperty
  @name = N'todo'
  , @value = N'-- Test rebuild/reorganize.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment_index', N'parameter', N'@reorganize_demarcation'))
  EXEC sys.sp_dropextendedproperty
    @name = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index'
    , @level2type = N'parameter'
    , @level2name = N'@reorganize_demarcation';

go

EXEC sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@reorganize_demarcation [INT] - The demarcation limit between a REORGANIZE vs REBUILD operation. Indexes having less than or equal to this level of fragmentation will be reorganized. Indexes with greater than this level of fragmentation will be rebuilt. DEFAULT - 25.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index'
  , @level2type = N'parameter'
  , @level2name = N'@reorganize_demarcation';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment_index', N'parameter', N'@maximum_fragmentation'))
  EXEC sys.sp_dropextendedproperty
    @name = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index'
    , @level2type = N'parameter'
    , @level2name = N'@maximum_fragmentation';

go

EXEC sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@maximum_fragmentation [INT] - The maximum fragmentation allowed before the procedure will attempt to defragment it. Indexes with fragmentation below this level will not be defragmented. DEFAULT 25.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index'
  , @level2type = N'parameter'
  , @level2name = N'@maximum_fragmentation';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment_index', N'parameter', N'@defrag_count_limit'))
  EXEC sys.sp_dropextendedproperty
    @name = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index'
    , @level2type = N'parameter'
    , @level2name = N'@defrag_count_limit';

go

EXEC sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@defrag_count_limit [INT] -  The maximum number of indexes to defragment. Used to limit the total time and resources to be consumed by a run. This will be used in conjunction with the @maximum_fragmentation parameter and should be considered to be the "TOP(n)" of indexes above the @maximum_fragmentation parameter. DEFAULT - NULL - Will be set to 1.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index'
  , @level2type = N'parameter'
  , @level2name = N'@defrag_count_limit';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment_index', N'parameter', N'@output'))
  EXEC sys.sp_dropextendedproperty
    @name = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'defragment_index'
    , @level2type = N'parameter'
    , @level2name = N'@output';

go

EXEC sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@output [XML] - An XML output construct containing the SQL used to defragment each index, the before and after fragmentation level, elapsed time in milliseconds, and other statistical information.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'defragment_index'
  , @level2type = N'parameter'
  , @level2name = N'@output';

go 
