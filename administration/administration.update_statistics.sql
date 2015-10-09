/*
	Change to target database prior to running.
*/
if schema_id(N'administration') is null
  execute (N'create schema administration');

go

set ansi_nulls on;

go

set quoted_identifier on;

go

if object_id(N'[administration].[update_statistics]'
             , N'P') is not null
  drop procedure [administration].[update_statistics];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'administration', @object [sysname] = N'update_statistics';
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
	
	execute [administration].[update_statistics];
	
*/
create procedure [administration].[update_statistics]
as
  begin
      declare @view  nvarchar(1024)
              , @sql nvarchar(max);

      --
      -- update statistics on all objects other than indexed views
      -----------------------------------------------
      print N'Executing [sys].[sp_updatestats] to update statistics on all objects other than indexed views.';

      execute [sys].[sp_updatestats];

      print N'Executing [sys].[sp_updatestats] complete.';

      --
      -- update statistics for indexed views
      -----------------------------------------------
      print N'Updating statistics for indexed views.';

      declare [view_cursor] cursor local fast_forward for
        select quotename([schemas].name, N'[') + N'.'
               + quotename([objects].name, N'[') as view_name
        from   [sys].[objects] [objects]
               inner join [sys].[schemas] [schemas]
                       on [schemas].[schema_id] = [objects].[schema_id]
               inner join [sys].[indexes] [indexes]
                       on [indexes].[object_id] = [objects].[object_id]
               inner join [sys].[sysindexes] [sysindexes]
                       on [sysindexes].id = [indexes].[object_id]
                          and [sysindexes].indid = [indexes].index_id
        where  [objects].type = 'V'
        group  by quotename([schemas].name, N'[') + N'.'
                  + quotename([objects].name, N'[')
        having max([sysindexes].rowmodctr) > 0;

      --
      -----------------------------------------
      begin
          open [view_cursor];

          fetch next from [view_cursor] into @view;

          while ( @@fetch_status = 0 )
            begin
                print N'   Updating stats for view ' + @view;

                set @sql = N'update statistics ' + @view;

                execute (@sql);

                fetch next from [view_cursor] into @view;
            end;

          close [view_cursor];

          deallocate [view_cursor];
      end;

      print N'Updating statistics for indexed views. complete.';
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'update_statistics'
                                          , default
                                          , default))
  exec [sys].sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'update_statistics';

go

exec [sys].sp_addextendedproperty
  @name = N'description',
  @value = N'Refresh procedure for [administration].[claimLineFt].
  Based on a script from:
  Rhys Jones, 7th Feb 2008
	http://www.rmjcs.com/SQLServer/ThingsYouMightNotKnow/sp_updatestatsDoesNotUpdateIndexedViewStats/tabid/414/Default.aspx
	Update stats in indexed views because indexed view stats are not updated by sp_updatestats.
	Only does an update if rowmodctr is non-zero.
	No error handling, does not deal with disabled clustered indexes.
	Does not respect existing sample rate.
	[sys].sysindexes.rowmodctr is not completely reliable in SQL Server 2005.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'update_statistics';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150810'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'update_statistics'
                                          , default
                                          , default))
  exec [sys].sp_dropextendedproperty
    @name = N'revision_20150810',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'update_statistics';

go

exec [sys].sp_addextendedproperty
  @name = N'revision_20150810',
  @value = N'KELightsey@gmail.com � created.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'update_statistics';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_administration'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'update_statistics'
                                          , default
                                          , default))
  exec [sys].sp_dropextendedproperty
    @name = N'package_administration',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'update_statistics';

go

exec [sys].sp_addextendedproperty
  @name = N'package_administration',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'update_statistics';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'update_statistics'
                                          , default
                                          , default))
  exec [sys].sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'update_statistics';

go

exec [sys].sp_addextendedproperty
  @name = N'execute_as',
  @value = N'execute [administration].[update_statistics];',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'update_statistics';

go 