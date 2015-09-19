use [chamomile];

go

if schema_id(N'repository_secure') is null
  execute (N'create schema repository_secure');

go

if object_id(N'[repository_secure].[get_entry]'
             , N'FN') is not null
  drop function [repository_secure].[get_entry];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'repository_secure', @object [sysname] = N'get_entry';
	--
	-------------------------------------------------
	select N'[' + object_schema_name([extended_properties].[major_id]) +N'].['+
		   case when Object_name([objects].[parent_object_id]) is not null 
				then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
				else Object_name([objects].[object_id]) +N']' + 
					case when [parameters].[parameter_id] > 0
						then coalesce(N'.['+[parameters].[name] + N']', N'') 
						else N'' 
					end 
			end                                                                     as [object]
		   ,case when [extended_properties].[minor_id]=0 then [objects].[type_desc]
				else N'PARAMETER'
			end                                                                     as [type]
		   ,[extended_properties].[name]                                            as [property]
		   ,[extended_properties].[value]                                           as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id]=[objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id]=[parameters].[object_id] and
					 [parameters].[parameter_id]=[extended_properties].[minor_id]
	where  [schemas].[name]=@schema and
		   [objects].[name]=@object
	order  by [parameters].[name],[object],[type],[property]; 
*/
create function [repository_secure].[get_entry] (@id          [uniqueidentifier]
                                                 , @source    [sysname]
                                                 , @category  [sysname]
                                                 , @class     [sysname]
                                                 , @type      [sysname]
                                                 , @timestamp [datetime])
returns [xml]
as
  begin
      declare @entry [xml];

      if @id is not null
        set @entry = (select [entry]
                      from   [repository_secure].[data]
                      where  [id] = @id
                             and [source] = @source)
      else
        set @entry = (select top(1) [entry]
                      from   [repository_secure].[data]
                      where  [source] = @source
                             and [category] = @category
                             and [class] = @class
                             and [type] = @type
                             and ( [created] = @timestamp
                                    or @timestamp is null )
                      order  by [created] desc);

      return @entry;
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'data'
                                          , N'function'
                                          , N'get_entry'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository_secure',
    @level1type = N'function',
    @level1name = N'get_entry';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Returns a specific [entry] for a match on [category].[class].[type].[created]',
  @level0type = N'schema',
  @level0name = N'repository_secure',
  @level1type = N'function',
  @level1name = N'get_entry';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20140804'
                                          , N'schema'
                                          , N'data'
                                          , N'function'
                                          , N'get_entry'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140804',
    @level0type = N'schema',
    @level0name = N'repository_secure',
    @level1type = N'function',
    @level1name = N'get_entry';

exec sys.sp_addextendedproperty
  @name = N'revision_20140804',
  @value = N'KELightsey@gmail.com – created.',
  @level0type = N'schema',
  @level0name = N'repository_secure',
  @level1type = N'function',
  @level1name = N'get_entry';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_log'
                                          , N'schema'
                                          , N'data'
                                          , N'function'
                                          , N'get_entry'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_log',
    @level0type = N'schema',
    @level0name = N'repository_secure',
    @level1type = N'function',
    @level1name = N'get_entry';

exec sys.sp_addextendedproperty
  @name = N'package_log',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'repository_secure',
  @level1type = N'function',
  @level1name = N'get_entry';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'release_00.93.00'
                                          , N'schema'
                                          , N'data'
                                          , N'function'
                                          , N'get_entry'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'release_00.93.00',
    @level0type = N'schema',
    @level0name = N'repository_secure',
    @level1type = N'function',
    @level1name = N'get_entry';

exec sys.sp_addextendedproperty
  @name = N'release_00.93.00',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'repository_secure',
  @level1type = N'function',
  @level1name = N'get_entry';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'data'
                                          , N'function'
                                          , N'get_entry'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'repository_secure',
    @level1type = N'function',
    @level1name = N'get_entry';

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'
	select [repository_secure].[get_entry] (N''category'', N''class'', N''type'');',
  @level0type = N'schema',
  @level0name = N'repository_secure',
  @level1type = N'function',
  @level1name = N'get_entry';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'data'
                                          , N'function'
                                          , N'get_entry'
                                          , N'column'
                                          , N'@category'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository_secure',
    @level1type = N'function',
    @level1name = N'get_entry',
    @level2type = N'column',
    @level2name = N'@category';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Matches against [category] column.',
  @level0type = N'schema',
  @level0name = N'repository_secure',
  @level1type = N'function',
  @level1name = N'get_entry',
  @level2type = N'parameter',
  @level2name = N'@category';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'data'
                                          , N'function'
                                          , N'get_entry'
                                          , N'column'
                                          , N'@class'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository_secure',
    @level1type = N'function',
    @level1name = N'get_entry',
    @level2type = N'column',
    @level2name = N'@class';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Matches against [class] column.',
  @level0type = N'schema',
  @level0name = N'repository_secure',
  @level1type = N'function',
  @level1name = N'get_entry',
  @level2type = N'parameter',
  @level2name = N'@class';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'data'
                                          , N'function'
                                          , N'get_entry'
                                          , N'column'
                                          , N'@type'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository_secure',
    @level1type = N'function',
    @level1name = N'get_entry',
    @level2type = N'column',
    @level2name = N'@type';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Matches against [type] column.',
  @level0type = N'schema',
  @level0name = N'repository_secure',
  @level1type = N'function',
  @level1name = N'get_entry',
  @level2type = N'parameter',
  @level2name = N'@type';

go 
