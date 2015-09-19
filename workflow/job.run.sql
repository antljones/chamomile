set ansi_nulls on;

go

set quoted_identifier on;

go

if object_id(N'[job].[run]'
             , N'P') is not null
  drop procedure [job].[run];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'job', @object [sysname] = N'run';
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
	
	execute [job].[run] @prefix=N'refresh.DWReporting.daily', @first_step=9000;
*/
create procedure [job].[run] @prefix          [sysname]
                             , @first_step    [int] = 1
                             , @last_step     [int]=10000
                             , @step_delay    [sysname]=N'00:00:15'
                             , @process_delay [sysname]=N'00:00:15'
as
  begin
      set nocount on;

      declare @step_prefix [sysname]=N'step_',
              @job         [nvarchar](1000),
              @step        [int] = @first_step;

      if @prefix is null
        raiserror (N'@prefix is a required parameter.',10,1);

      while @step < @last_step
        begin
        /*  
        Delay between steps so that each step is executed independently  
        disallows running next step while any jobs (as defined by @prefix) 
        are still running, other than the ".controller". 
        */
            -------------------------------------  
            while exists (select *
                          from   [msdb].[job].[sysjobactivity] as [sysjobactivity]
                                 left join [msdb].[job].[sysjobhistory] as [sysjobhistory]
                                        on [sysjobactivity].[job_history_id] = [sysjobhistory].[instance_id]
                                 join [msdb].[job].[sysjobs] as [sysjobs]
                                   on [sysjobactivity].[job_id] = [sysjobs].[job_id]
                                 join [msdb].[job].[sysjobsteps] as [sysjobsteps]
                                   on [sysjobactivity].[job_id] = [sysjobsteps].[job_id]
                                      and isnull([sysjobactivity].[last_executed_step_id], 0)
                                          + 1 = [sysjobsteps].[step_id]
                          where  [sysjobactivity].[session_id] = (select top (1) [session_id]
                                                                  from   [msdb].[job].[syssessions]
                                                                  order  by [agent_start_date] desc)
                                 and [start_execution_date] is not null
                                 and [stop_execution_date] is null
                                 and [sysjobs].[name] like @prefix + N'%'
                                 and [sysjobs].[name] != @prefix + N'.controller')
              waitfor delay @step_delay;

            --  
            -- run all jobs with the same "step_" in parallel 
            -------------------------------------  
            begin
                declare [job_cursor] cursor for
                  select [sysjobs].[name]
                  from   [msdb].[job].[sysjobs] as [sysjobs]
                  where  [sysjobs].[name] like @prefix + N'.' + @step_prefix
                                               + right(N'0000'+cast(@step as [sysname]), 4)
                                               + N'%'
                         and ( [sysjobs].[name] != @prefix + N'.controller' );

                --  
                open [job_cursor];

                fetch next from [job_cursor] into @job;

                while @@fetch_status = 0
                  begin
                      --  
                      execute [msdb].[job].[sp_start_job]
                        @job;

                      --  
                      -- delay to give each job time to start prior to starting next job  
                      ---------------------------  
                      waitfor delay @process_delay;

                      --  
                      fetch next from [job_cursor] into @job;
                  end;

                -- 
                --------------------------------- 
                close [job_cursor];

                deallocate [job_cursor];
            end;

            --  
            -------------------------------------  
            set @step = @step + 1;
        end;
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'run'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'run';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'[job].[run] is a job scheduling utility. It looks for jobs named 
  "<header>.step_<step_number>". Jobs with the same step number are run in parallel. Each iteration
  does not run until all jobs with that header name prefix complete, so while jobs with the same
  step number are run in parallel, each step is run separate from the others. The steps are run in 
  order from 1 to 1000.
  ',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'run';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150824'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'run'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20150824',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'run';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20150824',
  @value = N'KELightsey@gmail.com � created.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'run';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_workflow'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'run'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_workflow',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'run';

go

exec sys.sp_addextendedproperty
  @name = N'package_workflow',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'run';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'run'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'run';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'
  declare @prefix [sysname]=N''refresh.DWReporting.daily'';
  execute [job].[run] @prefix=@prefix;',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'run';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'run'
                                          , N'parameter'
                                          , N'@prefix'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'run',
    @level2type = N'parameter',
    @level2name = N'@prefix';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@prefix [sysname]',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'run',
  @level2type = N'parameter',
  @level2name = N'@prefix';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'run'
                                          , N'parameter'
                                          , N'@last_step'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'run',
    @level2type = N'parameter',
    @level2name = N'@last_step';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@last_step [int]=1000 - defaults to 999 maximum steps (<@last_step). Increase to add additional jobs or decrease
	to only run a subset of the jobs. For example; to run all jobs except for the defragment and refresh statistics jobs, pass in @last_step=900.
	As the defragment and refresh statistics jobs are "900" jobs they would not run.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'run',
  @level2type = N'parameter',
  @level2name = N'@last_step';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'run'
                                          , N'parameter'
                                          , N'@step_delay'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'run',
    @level2type = N'parameter',
    @level2name = N'@step_delay';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@step_delay [sysname]=N''00:00:15'' -  the delay between steps, used to give the
	job time to start and appear in [msdb] so that the step check can pick it up as a running job.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'run',
  @level2type = N'parameter',
  @level2name = N'@step_delay';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'job'
                                          , N'procedure'
                                          , N'run'
                                          , N'parameter'
                                          , N'@process_delay'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'job',
    @level1type = N'procedure',
    @level1name = N'run',
    @level2type = N'parameter',
    @level2name = N'@process_delay';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'@process_delay [sysname]=N''00:00:15'' - the delay after each job is started, used to give the
	job time to start and appear in [msdb] so that the step check can pick it up as a running job.',
  @level0type = N'schema',
  @level0name = N'job',
  @level1type = N'procedure',
  @level1name = N'run',
  @level2type = N'parameter',
  @level2name = N'@process_delay';

go 
