use [master];

go

if object_id(N'[dbo].[sp_chamomile_documentation_get_schema]'
             , N'P') is not null
  drop procedure [dbo].[sp_chamomile_documentation_get_schema];

go

/*
	select *
      from fn_listextendedproperty(default, N'schema', N'dbo', N'procedure', N'sp_chamomile_documentation_get_schema', default, default); 
    
*/
create procedure [dbo].[sp_chamomile_documentation_get_schema] @object_fqn         [nvarchar](max)
                                                               , @timestamp_output [bit] = 0
                                                               , @bcp_command      [nvarchar](max) = null output
                                                               , @documentation    [nvarchar](max) = null output
                                                               , @stack            [xml] = null output
as
  begin
      declare @parameter_list          [nvarchar](max),
              @execute_as              [xml],
              @builder                 [xml],
              @server                  [sysname],
              @normalized_server       [sysname],
              @output                  [nvarchar](max),
              @procedure_documentation [nvarchar](max),
              @table_documentation     [nvarchar](max),
              @subject_fqn             [nvarchar](max),
              @message                 [nvarchar](max),
              @timestamp               [sysname] = convert([sysname], current_timestamp, 126),
              @object_type             [sysname],
              @schema                  [sysname],
              @object                  [sysname],
              @sql                     [nvarchar](max),
              @parameters              [nvarchar](max),
              @schema_properties       [nvarchar](max),
              @log_prototype           [xml],
              @stripped_timestamp      [sysname];

      --
      -------------------------------------------------
      execute [sp_chamomile_documentation_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      --
      set @server=@builder.value(N'(/*/server/@name)[1]'
                                 , N'[nvarchar](1000)');
      set @normalized_server=@builder.value(N'(/*/normalized_server/@name)[1]'
                                            , N'[nvarchar](1000)');
      set @subject_fqn=@builder.value(N'(/*/fqn/@fqn)[1]'
                                      , N'[nvarchar](1000)');
      set @server=@builder.value(N'(/*/server/@name)[1]'
                                 , N'[nvarchar](1000)');
      set @stripped_timestamp = @builder.value(N'(/*/@stripped_timestamp)[1]'
                                               , N'[sysname]');

      --
      select @schema = parsename(@object_fqn
                                 , 1);

      --
      if not exists (select *
                     from   [sys].[schemas]
                     where  [name] = @schema)
        begin
            set @message = @subject_fqn
                           + N' is only used to format schemas. '
                           + @schema + N' is not found.';

            raiserror(510000,@message,1);
        end;

      --
      -------------------------------------------
      select @schema_properties = coalesce(@schema_properties + N' ', N'')
                                  + N'<details id="fourth_indent"><summary>['
                                  + [extended_properties].[name]
                                  + N']</summary>'
                                  + cast([extended_properties].[value] as [nvarchar](max))
                                  + N'</details>'
      from   [sys].[schemas] as [schemas]
             left join [sys].[extended_properties] as [extended_properties]
                    on [extended_properties].[major_id] = [schemas].[schema_id]
      where  [schemas].[name] = @schema;

      --
      -------------------------------------------
      begin
          declare get_procedure cursor for
            select N'[' + @schema + N'].[' + [name] + N']'
            from   [sys].[procedures]
            where  object_schema_name([object_id]) = @schema
            order  by [name];

          open get_procedure;

          fetch next from get_procedure into @object;

          while @@fetch_status = 0
            begin
                execute [dbo].[sp_chamomile_documentation_get_procedure]
                  @object_fqn =@object,
                  @documentation = @output output;

                set @procedure_documentation = coalesce(@procedure_documentation, N'')
                                               + @output;

                fetch next from get_procedure into @object;
            end;

          close get_procedure;

          deallocate get_procedure;

          --
          set @procedure_documentation = N'<details id="second_indent"><summary>[procedure_documentation]</summary>'
                                         + @procedure_documentation + N'</details>';
      end;

      --
      -------------------------------------------
      begin
          declare get_table cursor for
            select N'[' + @schema + N'].[' + [name] + N']'
            from   [sys].[tables]
            where  object_schema_name([object_id]) = @schema
            order  by [name];

          open get_table;

          fetch next from get_table into @object;

          while @@fetch_status = 0
            begin
                execute [dbo].[sp_chamomile_documentation_get_table]
                  @object_fqn =@object,
                  @documentation = @output output;

                set @table_documentation = coalesce(@table_documentation, N'')
                                           + @output;

                fetch next from get_table into @object;
            end;

          close get_table;

          deallocate get_table;

          --
          set @table_documentation = N'<details id="second_indent"><summary>[table_documentation]</summary>'
                                     + @table_documentation + N'</details>';
      end;

      --
      -------------------------------------------
      set @documentation = N'<details id="third_indent"><summary>['
                           + @schema + N']<span class="note">{'
                           + @timestamp + N'}</span></summary>'
                           + coalesce(@schema_properties, N'')
                           + coalesce(@procedure_documentation, N'')
                           + coalesce(@table_documentation, N'')
                           + N'</details>';

      --
      -- load documentation into repository and create bcp extraction command
      -------------------------------------------
      begin
          set @log_prototype =[chamomile].[utility].[get_prototype](N'[chamomile].[log].[stack].[prototype]');
          set @log_prototype.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');
          set @log_prototype.modify(N'replace value of (/log/description/text())[1] with sql:variable("@documentation")');
          --
          -------------------------------------------
          set @stack = null;

          execute [chamomile].[utility].[set_log]
            @object_fqn = @object_fqn,
            @log = @log_prototype,
            @sequence = 1,
            @stack = @stack output;

          --
          -------------------------------------------
          if @timestamp_output = 1
            set @message = N'_' + @stripped_timestamp;
          else
            set @message = N'';

          --
          -------------------------------------------
          set @bcp_command = N'BCP "select [chamomile].[documentation].[get_formatted_html]([chamomile].[utility].[get_log_text](N'''
                             + @object_fqn + N'''));" queryout '
                             + @subject_fqn + '_' + @object_fqn + @message
                             + N'.html' + N' -t, -T -c -d ' + db_name()
                             + N' -S ' + @server + N';';
      end;
  end;

go

exec [sp_ms_marksystemobject]
  N'sp_chamomile_documentation_get_schema';

go

if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'dbo'
                                          , N'procedure'
                                          , N'sp_chamomile_documentation_get_schema'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'dbo',
    @level1type = N'procedure',
    @level1name = N'sp_chamomile_documentation_get_schema',
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'use [chamomile_oltp];
go
declare @bcp_command     [nvarchar](max)
        , @documentation [nvarchar](max)
        , @stack         [xml]
        , @object_fqn    [nvarchar](max) = ''[flower].[set]'';
execute [dbo].[sp_chamomile_documentation_get_schema]
  @object_fqn      =@object_fqn
  , @documentation = @documentation output
  , @bcp_command   =@bcp_command output
  , @stack         =@stack output;
select @bcp_command                                                                                          as [@bcp_command]
       , @documentation                                                                                      as [@documentation]
       , [chamomile].[documentation].[get_formatted_html](@documentation)                                    as [html_output]
       , @stack                                                                                              as [@stack]
       , [chamomile].[utility].[get_log_text](@object_fqn)                                                   as [log_text]
       , [chamomile].[documentation].[get_formatted_html]([chamomile].[utility].[get_log_text](@object_fqn)) as [formatted_log_text]; ',
  @level0type = N'schema',
  @level0name = N'dbo',
  @level1type = N'procedure',
  @level1name = N'sp_chamomile_documentation_get_schema',
  @level2type = null,
  @level2name =null; 
