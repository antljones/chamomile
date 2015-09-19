--
--
--
-- build parameters
--------------------------------------------------------------------------
declare @list [nvarchar](max);

select @list = coalesce(@list + N', ', N'') + N'@'
               + columns.name + case
               --
               when types.name = N'varchar' then N' [nvarchar] ('+cast(columns.max_length as [sysname]) + N')'
               --
               when types.name = N'decimal' then N' [' +types.name + '] ('+ cast(columns.precision as [sysname])+N', '+cast(columns.scale as [sysname])+')'
               --
               else N' [' +types.name + '] '
               --
               end
               --
               + N' = null'
from   sys.columns as columns
       join sys.tables as tables
         on tables.object_id = columns.object_id
       join sys.types as types
         on types.user_type_id = columns.user_type_id
where  object_schema_name(tables.object_id) = N'equity'
       and tables.name = N'order'
order  by columns.name;

select @list;

-- todo - build from remote database, call procedure remotely?
-- todo - create views
--------------------------------------------------------------------------
declare @table_schema     [sysname]=N'dbo',
        @table            [sysname] =N'letters_exhibits',
        @procedure_schema [sysname]=N'letter',
        @procedure        [sysname]=N'set_set_exhibit',
        @builder          [nvarchar](max),
        @sql              [nvarchar](max);

select @builder = coalesce(@builder + N', ', N'') + N'@'
                  + [columns].[name] +
                  --
                  case when [types].[name]=N'varchar' then N' [' + [types].[name] + N']('+cast([columns].[max_length] as [sysname]) + N')'
                  --
                  when [types].[name]=N'nvarchar' then N' [' + [types].[name] + N']('+cast([columns].[max_length]/2 as [sysname]) + N')'
                  --
                  when [types].[name] in (N'datetime', N'int') then N' [' + [types].[name] + N']'
                  --
                  else N' [' + [types].[name] + N'] ' end + N' = null '
from   [sys].[columns] as [columns]
       join [sys].[types] as [types]
         on [types].[user_type_id] = [columns].[user_type_id]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [columns].[object_id]
where  object_schema_name([tables].[object_id]) = @table_schema
       and [tables].[name] = @table;

/*
if schema_id(N'' + @procedure_schema + '') is null
  execute (N'create schema ' + @procedure_schema + '');

if object_id(N'[' + @procedure_schema + N'].[' + @procedure + ']'
             , N'P') is not null
  execute (N'drop procedure [' + @procedure_schema + N'].[' + @procedure+N']');
*/
set @sql = N'if object_id(N''[' + @procedure_schema
           + N'].[' + @procedure
           + ']'', N''P'') is not null drop procedure ['
           + @procedure_schema + N'].[' + @procedure + ']';
set @sql = @sql + N'create procedure ['
           + @procedure_schema + N'].[' + @procedure + N'] '
           + @builder + N' as begin            
				set nocount on;
				execute as user = N''replace_me-secure_schema_user'';
				select N''replace_me''; 
           end  ';

select @sql;

/*
execute sp_executesql
  @sql = @sql;
*/
go 
