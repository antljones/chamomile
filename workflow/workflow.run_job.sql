use [chamomile];

go

if schema_id(N'workflow') is null
 execute(N'create schema workflow');
go
 
if object_id(N'[workflow].[run_job]'
             , N'P') is not null
  drop procedure [workflow].[run_job];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'workflow', @object [sysname] = N'run_job';
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
create procedure [workflow].[run_job] @header          [sysname]
                                       , @last_step     [int]=1000
                                       , @step_delay    [sysname]=N'00:00:15'
                                       , @process_delay [sysname]=N'00:00:15'
as
  begin
      set nocount on;

      declare @step_name       [sysname]=N'step_',
              @step_in_process [sysname],
              @job             [nvarchar](1000),
              @step            [int] = -1;

      if @header is null
        raiserror (N'@header is a required parameter.',10,1);

  ;
      while @step < @last_step
        begin
            --
            -------------------------------------
            set @step = @step + 1;

            --
            -- delay between steps so that each step is executed independently
            -- disallows running next step while any step in the job (as defined by @header)
            --	is still running.
            -------------------------------------
            while exists (select *
                          from   [msdb].[workflow].[sysjobactivity] as [sysjobactivity]
                                 left join [msdb].[workflow].[sysjobhistory] as [sysjobhistory]
                                        on [sysjobactivity].job_history_id = [sysjobhistory].[instance_id]
                                 join [msdb].[workflow].[sysjobs] as [sysjobs]
                                   on [sysjobactivity].[job_id] = [sysjobs].[job_id]
                                 join [msdb].[workflow].[sysjobsteps] as [sysjobsteps]
                                   on [sysjobactivity].[job_id] = [sysjobsteps].[job_id]
                                      and isnull([sysjobactivity].[last_executed_step_id], 0)
                                          + 1 = [sysjobsteps].[step_id]
                          where  [sysjobactivity].[session_id] = (select top (1) [session_id]
                                                                  from   [msdb].[workflow].[syssessions]
                                                                  order  by [agent_start_date] desc)
                                 and [start_execution_date] is not null
                                 and [stop_execution_date] is null
                                 and [sysjobs].[name] like @header + N'%'
                                 and [sysjobs].[name] != @header + N'.controller')
              waitfor delay @step_delay;

            --
            -------------------------------------
            declare [job_cursor] cursor for
              select [sysjobs].[name]
              from   [msdb].[workflow].[sysjobs] as [sysjobs]
              where  [sysjobs].[name] like @header + N'.' + @step_name
                                           + right(N'000'+cast(@step as [sysname]), 3)
                                           + N'%'
                     and ( [sysjobs].[name] != @header + N'.controller' );

            --
            open [job_cursor];

            fetch next from [job_cursor] into @job;

            while @@fetch_status = 0
              begin
                  print N'starting job: ' + @job + N'. Step: '
                        + cast(@step as [sysname]);

                  --
                  execute [msdb].[dbo].[sp_start_job]
                    @job;

                  --
                  -- delay to give job time to start prior to starting next cycle
                  -------------------------------
                  waitfor delay @process_delay;

                  --
                  fetch next from [job_cursor] into @job;
              end

            close [job_cursor];

            deallocate [job_cursor];
        end;
  end;

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'[workflow].[run_job] is a job scheduling utility. It looks for jobs named 
  "<header>.step_<step_number>". Jobs with the same step number are run in parallel. Each iteration
  does not run until all jobs with that header name prefix complete, so while jobs with the same
  step number are run in parallel, each step is run separate from the others. The steps are run in 
  order from 1 to 1000.
  ',
  @level0type = N'schema',
  @level0name = N'workflow',
  @level1type = N'procedure',
  @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'revision_20150810',
  @value = N'KLightsey@gmail.com – created.',
  @level0type = N'schema',
  @level0name = N'workflow',
  @level1type = N'procedure',
  @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'package_refresh',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'workflow',
  @level1type = N'procedure',
  @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'
  declare @header [sysname]=N''refresh.<label>.daily'';
  execute [workflow].[run_job] @header=@header;',
  @level0type = N'schema',
  @level0name = N'workflow',
  @level1type = N'procedure',
  @level1name = N'run_job';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'@header [sysname]',
  @level0type = N'schema',
  @level0name = N'workflow',
  @level1type = N'procedure',
  @level1name = N'run_job',
  @level2type = N'parameter',
  @level2name = N'@header';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'@last_step [int]=1000 - defaults to 999 maximum steps (<@last_step). Increase to add additional jobs or decrease
	to only run a subset of the jobs. For example; to run all jobs except for the defragment and refresh statistics jobs, pass in @last_step=900.
	As the defragment and refresh statistics jobs are "900" jobs they would not run.',
  @level0type = N'schema',
  @level0name = N'workflow',
  @level1type = N'procedure',
  @level1name = N'run_job',
  @level2type = N'parameter',
  @level2name = N'@last_step';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'@step_delay [sysname]=N''00:00:15'' -  the delay between steps, used to give the
	job time to start and appear in [msdb] so that the step check can pick it up as a running job.',
  @level0type = N'schema',
  @level0name = N'workflow',
  @level1type = N'procedure',
  @level1name = N'run_job',
  @level2type = N'parameter',
  @level2name = N'@step_delay';

go

--
------------------------------------------------- 
exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'@process_delay [sysname]=N''00:00:15'' - the delay after each job is started, used to give the
	job time to start and appear in [msdb] so that the step check can pick it up as a running job.',
  @level0type = N'schema',
  @level0name = N'workflow',
  @level1type = N'procedure',
  @level1name = N'run_job',
  @level2type = N'parameter',
  @level2name = N'@process_delay';

go 
