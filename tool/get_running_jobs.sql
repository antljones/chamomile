declare @header [sysname]=N'refresh.DWReporting.daily';

select [sysjobactivity].[job_id]                 as [job_id]
       , [sysjobs].[name]                        as [job_name]
       , [sysjobactivity].[start_execution_date] as [start_execution_date]
       , isnull(last_executed_step_id, 0) + 1    as [current_executed_step_id]
       , [sysjobsteps].[step_name]               as [step_name]
from   [msdb].[dbo].[sysjobactivity] as [sysjobactivity]
       left join [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
              on [sysjobactivity].[job_history_id] = [sysjobhistory].[instance_id]
       join [msdb].[dbo].[sysjobs] as [sysjobs]
         on [sysjobactivity].[job_id] = [sysjobs].[job_id]
       join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
         on [sysjobactivity].[job_id] = [sysjobsteps].[job_id]
            and isnull([sysjobactivity].[last_executed_step_id], 0)
                + 1 = [sysjobsteps].[step_id]
where  [sysjobactivity].[session_id] = (select top (1) [session_id]
                                        from   [msdb].[dbo].[syssessions]
                                        order  by [agent_start_date] desc)
       and [start_execution_date] is not null
       and [stop_execution_date] is null
       and [sysjobs].[name] like @header + N'%'
       and [sysjobs].[name] != @header + N'.controller';

go

--execute msdb.dbo.sp_stop_job @job_name=N'refresh.DWReporting.daily.step_220.claimLineFt', @job_id=N'<job_id{uniqueidentifier}>',@originating_server=N'<originating_server{sysname}>', @server_name=N'<server_name{uniqueidentifier}>';
go 
