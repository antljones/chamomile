use [chamomile];

go

if schema_id(N'log') is null
  execute (N'create schema log');

go

if object_id(N'[log].[set]'
             , N'P') is not null
  drop procedure [log].[set];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'log', @object [sysname] = N'set';
	--
	-------------------------------------------------
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
*/
create procedure [log].[set] @source        [sysname]
                             , @category    [sysname]
                             , @class       [sysname]
                             , @type        [sysname]
                             , @value       [sysname] = null
                             , @entry       [xml] = null
                             , @description [nvarchar](max) = null
                             , @active      [datetime] = null
                             , @expire      [datetime] = null
                             , @identity    [uniqueidentifier] = null output
as
  begin
      declare @inserted table
        (
           [id] [uniqueidentifier]
        );

      insert into [repository_secure].[immutable]
                  ([source],
                   [category],
                   [class],
                   [type],
                   [value],
                   [entry],
                   [description])
      output      inserted.[id]
      into @inserted
      values      (@source,
                   @category,
                   @class,
                   @type,
                   @value,
                   @entry,
                   @description);

      set @identity=(select top(1) [id]
                     from   @inserted);
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set'

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Primary mutator method for [log_secure].[log]. Only an insert is provided for. In this manner the log trail is maintained.',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set'

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20140804'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140804',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set'

exec sys.sp_addextendedproperty
  @name = N'revision_20140804',
  @value = N'KELightsey@gmail.com � created.',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set'

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_log'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_log',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set'

exec sys.sp_addextendedproperty
  @name = N'package_log',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set'

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'release_00.93.00'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'release_00.93.00',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set'

exec sys.sp_addextendedproperty
  @name = N'release_00.93.00',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set'

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set'

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'
execute [log].[set]
@source=N''log'',
@category=N''category'',
@class=N''class'',
@type=N''type'',
@value=N''value'',
@description=N''description'';',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set'

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , N'column'
                                          , N'@category'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set',
    @level2type = N'column',
    @level2name = N'@category';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'The value to be matched with or inserted into the [category] column.',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set',
  @level2type = N'parameter',
  @level2name = N'@category';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , N'column'
                                          , N'@class'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set',
    @level2type = N'column',
    @level2name = N'@class';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'The value to be matched with or inserted into the [class] column.',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set',
  @level2type = N'parameter',
  @level2name = N'@class';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , N'column'
                                          , N'@description'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set',
    @level2type = N'column',
    @level2name = N'@description';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'The value to be inserted into the [description] column.',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set',
  @level2type = N'parameter',
  @level2name = N'@description';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , N'column'
                                          , N'@entry'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set',
    @level2type = N'column',
    @level2name = N'@entry';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'The value to be inserted into the [entry] column.',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set',
  @level2type = N'parameter',
  @level2name = N'@entry';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , N'column'
                                          , N'@type'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set',
    @level2type = N'column',
    @level2name = N'@type';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'The value to be matched with or inserted into the [type] column.',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set',
  @level2type = N'parameter',
  @level2name = N'@type';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'log'
                                          , N'procedure'
                                          , N'set'
                                          , N'column'
                                          , N'@identity'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'log',
    @level1type = N'procedure',
    @level1name = N'set',
    @level2type = N'column',
    @level2name = N'@identity';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@identity [int] = null output; outputs the identity column value for the updated or inserted column.',
  @level0type = N'schema',
  @level0name = N'log',
  @level1type = N'procedure',
  @level1name = N'set',
  @level2type = N'parameter',
  @level2name = N'@identity';

go 
