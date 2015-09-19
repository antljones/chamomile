use [chamomile];

go

if schema_id(N'test') is null
  execute (N'create schema test');

go

if object_id(N'[test].[run]'
             , N'P') is not null
  drop procedure [test].[run];

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'test'
            , @object [sysname] = N'run';
    select [schemas].[name]                as [schema]
           , [objects].[name]              as [object]
           , [extended_properties].[name]  as [property]
           , [extended_properties].[value] as [value]
    from   [sys].[extended_properties] as [extended_properties]
           join [sys].[objects] as [objects]
             on [objects].[object_id] = [extended_properties].[major_id]
           join [sys].[schemas] as [schemas]
             on [objects].[schema_id] = [schemas].[schema_id]
    where  [schemas].[name] = @schema
           and [objects].[name] = @object;
*/
create procedure [test].[run] @stack xml([chamomile].[xsc]) = null output
as
  begin
      set nocount on;

      declare @test_tree           [xml],
              @application_message [xml],
              @sql                 [nvarchar](max),
              @parameters          [nvarchar](max),
              @procedure           [sysname],
              @count               [int],
              @error_stack         [xml],
              @error               [xml],
              @builder             [xml],
              @string              [nvarchar](max),
              @schema_filter       [sysname],
              @procedure_filter    [sysname],
              @subject_fqn         [nvarchar](1000),
              @object_fqn          [nvarchar](1000),
              @object              [sysname];
      declare @chamomile_xsc_prototype [nvarchar](max)= N'[chamomile].[xsc].[stack].[prototype]',
              @test_suite_prototype    [nvarchar](max)= N'[chamomile].[test].[test_suite].[stack].[prototype]',
              @test_stack_prototype    [nvarchar](max) = N'[chamomile].[test].[test_stack].[stack].[prototype]',
              @test_prototype          [nvarchar](max) = N'[chamomile].[test].[test].[stack].[prototype]';
      declare @stack_builder              [xml] = [utility].[get_prototype](@chamomile_xsc_prototype),
              @test_suite                 [xml] = [utility].[get_prototype](@test_suite_prototype),
              @test_stack                 [xml] = [utility].[get_prototype](@test_stack_prototype),
              @test                       [xml] = [utility].[get_prototype](@test_prototype),
              @stack_result_description   [nvarchar](max) = N'Individual results are contained within the tests. No aggregate result is expected for this stack.',
              @default_test_schema_suffix [sysname] = [utility].[get_meta_data](N'[chamomile].[constant].[test].[default].[suffix]'),
              @test_suite_description     [nvarchar](max) = N'an aggregation of all test stacks executed within this method, along with counts of all tests and results.',
              @timestamp                  [sysname] = convert([sysname], current_timestamp, 126);

      --
      -------------------------------------------
      execute [sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      set @subject_fqn = @builder.value(N'(/*/fqn/@fqn)[1]'
                                        , N'[nvarchar](1000)');
      --
      -------------------------------------------
      set @test_suite.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@subject_fqn")');
      set @test_suite.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_suite_description")');
      set @test_suite.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
      --
      -------------------------------------------
      set @stack_builder.modify(N'replace value of (/*/subject/@fqn)[1] with sql:variable("@subject_fqn")');
      set @stack_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
      set @stack_builder.modify(N'replace value of (/*/result/description/text())[1] with sql:variable("@stack_result_description")');

      --
      ------------------------------------------------------------------------------------------------
      if @stack is null
        begin
            declare test_list cursor for
              select N'['
                     + object_schema_name([procedures].[object_id])
                     + N'].['
                     + object_name([procedures].[object_id])
                     + N']'
              from   [sys].[procedures] as [procedures]
              where  object_schema_name([procedures].[object_id]) like N'%' + @default_test_schema_suffix;
        end;
      else
        begin
            set @builder = @stack;

            declare test_list cursor for
              select t.c.value(N'data (./@fqn)'
                               , N'[nvarchar](1000)')
              from   @builder.nodes(N'(/*/object/*/command)') as t(c);
        end;

      begin
          open test_list;

          fetch next from test_list into @procedure;

          while @@fetch_status = 0
            begin
                set @sql = N'execute ' + @procedure
                           + N' @stack=@test_stack output;';
                set @parameters = N'@test_stack [xml] output';

                --
                begin try
                    set @test_stack = null;

                    if object_id(@procedure
                                 , N'P') is not null
                      execute sp_executesql
                        @sql =@sql,
                        @parameters =@parameters,
                        @test_stack =@test_stack output;

                    set @test_stack = @test_stack.query(N'(/*)');
                end try

                --
                begin catch
                    set @test_stack = [utility].[get_prototype](@test_stack_prototype);
                    set @test_stack.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@procedure")');
                    set @error_stack=null;
                    set @application_message=N'<application_message>
							<sql>' + @sql + N'</sql>
							<parameters>'
                                             + @parameters + N'</parameters>	
						</application_message>';

                    --
                    execute [utility].[handle_error]
                      @stack = @error_stack output,
                      @procedure_id =@@procid,
                      @application_message =@application_message;

                    select @error = @error_stack.query(N'/*/result/*[local-name()="error"]');

                    set @test_stack.modify(N'insert sql:variable("@error") as last into (/*)[1]');
                end catch;

                --
                set @test_suite.modify(N'insert sql:variable("@test_stack") as last into (/*)[1]');

                fetch next from test_list into @procedure;
            end

          close test_list;

          deallocate test_list;

          --
          -- build totals
          -------------------------------------------
          set @count = @test_suite.value(N'count (//test_stack)'
                                         , N'[int]');
          set @test_suite.modify(N'replace value of (/*/@stack_count)[1] with sql:variable("@count")');
          set @count = cast(@test_suite.value(N'count (//test)'
                                              , N'[int]') as [int]);
          set @test_suite.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
          set @count = cast(@test_suite.value(N'sum (//@pass_count)'
                                              , N'[float]') as [int]);
          set @test_suite.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
          set @count = cast(@test_suite.value(N'count (//error)', N'[int]') as [int])
                       + cast(@test_suite.value(N'sum (//@error_count)', N'[float]') as [int]);
          set @test_suite.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
          --
          -------------------------------------------
          set @stack_builder.modify(N'insert sql:variable("@test_suite") as last into (/*/result)[1]');
          set @stack = @stack_builder;
      end
  end

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'test'
                                            , N'procedure'
                                            , N'run'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'test',
    @level1type=N'procedure',
    @level1name=N'run'

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'Executes the list of tests passed in and totals the results.',
  @level0type=N'SCHEMA',
  @level0name=N'test',
  @level1type=N'procedure',
  @level1name=N'run'

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'test'
                                            , N'procedure'
                                            , N'run'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'test',
    @level1type=N'procedure',
    @level1name=N'run'

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](null, N''[chamomile].[documentation].[license]'')',
  @level0type=N'SCHEMA',
  @level0name=N'test',
  @level1type=N'procedure',
  @level1name=N'run'

if exists (select *
           from   ::fn_listextendedproperty(N'todo'
                                            , N'SCHEMA'
                                            , N'test'
                                            , N'procedure'
                                            , N'run'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'todo',
    @level0type=N'SCHEMA',
    @level0name=N'test',
    @level1type=N'procedure',
    @level1name=N'run'

exec sys.sp_addextendedproperty
  @name =N'todo',
  @value =N'<ol>
		<li>get "result" from meta data</li>
		<li>add @schema{_filter} to parameters, run only tests in that schema.</li>
	</ol>',
  @level0type=N'SCHEMA',
  @level0name=N'test',
  @level1type=N'procedure',
  @level1name=N'run'

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140706'
                                            , N'SCHEMA'
                                            , N'test'
                                            , N'procedure'
                                            , N'run'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140706',
    @level0type=N'SCHEMA',
    @level0name=N'test',
    @level1type=N'procedure',
    @level1name=N'run'

exec sys.sp_addextendedproperty
  @name =N'revision_20140706',
  @value =N'Katherine E. Lightsey - created.',
  @level0type=N'SCHEMA',
  @level0name=N'test',
  @level1type=N'procedure',
  @level1name=N'run'

if exists (select *
           from   ::fn_listextendedproperty(N'package_dpr_2012_313_0002_compliance_cms_audit_program'
                                            , N'SCHEMA'
                                            , N'test'
                                            , N'procedure'
                                            , N'run'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_dpr_2012_313_0002_compliance_cms_audit_program',
    @level0type=N'SCHEMA',
    @level0name=N'test',
    @level1type=N'procedure',
    @level1name=N'run'

exec sys.sp_addextendedproperty
  @name =N'package_dpr_2012_313_0002_compliance_cms_audit_program',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'test',
  @level1type=N'procedure',
  @level1name=N'run'

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'test'
                                            , N'procedure'
                                            , N'run'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'test',
    @level1type=N'procedure',
    @level1name=N'run'

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'declare @stack xml([chamomile].[xsc])= N''<chamomile:stack xmlns:chamomile="http://www.katherinelightsey.com/" timestamp="2014-06-30T18:37:43.61">
    	  <subject fqn="[computer_physical_netbios].[machine].[instance].[database].[schema].[subject]" unique="false" />
    	  <object>
			<command_stack fqn="[computer_physical_netbios].[machine].[instance].[chamomile].[test].[run]" recursion_level="1">
    				<command fqn="[test_test].[trigger_test]" timestamp="2014-06-30T18:37:43.61"/>
    		</command_stack>
    	  </object>
    	</chamomile:stack>'';
execute [test].[run]
  @stack=@stack output;
select @stack as N''@stack'';
--
-- run all tests
-------------------------------------------------
declare @stack xml = null;
execute [test].[run]
  @stack=@stack output;
select @stack as N''[test_suite]'';',
  @level0type=N'SCHEMA',
  @level0name=N'test',
  @level1type=N'procedure',
  @level1name=N'run'

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'test'
                                            , N'procedure'
                                            , N'run'
                                            , N'parameter'
                                            , N'@stack'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'test',
    @level1type=N'procedure',
    @level1name=N'run',
    @level2type=N'parameter',
    @level2name=N'@stack';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'[@stack] [xml] - A list of tests to run.',
  @level0type=N'schema',
  @level0name=N'test',
  @level1type=N'procedure',
  @level1name=N'run',
  @level2type=N'parameter',
  @level2name=N'@stack'; 
