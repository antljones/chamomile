-- https://www.mssqltips.com/sqlservertip/1394/how-to-store-longer-sql-agent-job-step-output-messages/
exec dbo.sp_help_jobsteplog
  @job_name = N'test2';

go

select j.name                                        as 'JobName'
       , run_date
       , run_time
       , run_duration
       , run_duration / 10000                        Hours
       , --hours
       run_duration / 100%100                        Minutes
       , --minutes
       run_duration%100                              Seconds --seconds
       , msdb.dbo.agent_datetime(run_date, run_time) as 'RunDateTime'
From   msdb.dbo.sysjobhistory h
       join msdb.dbo.sysjobs j
         ON j.job_id = h.job_id
--where  j.enabled = 1 --Only Enabled Jobs
where  j.name = N'expire.session'
order  by JobName
          , RunDateTime asc; 

declare @job   [sysname] = N'refresh.DWReporting.daily',
        @begin [datetime] = N'20150901',
        @end   [datetime] = null;

select [sysjobs].[name]                            as [job_name]
       , [sysjobsteps].[step_name]                 as [step_name]
       , [sysjobsteps].[step_id]                   as [step_id]
       , [msdb].[dbo].[agent_datetime](run_date
                                       , run_time) as [run_datetime]
       , [sysjobhistory].[message]                 as [message]
from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
       inner join [msdb].[dbo].[sysjobs] as [sysjobs]
               on [sysjobs].[job_id] = [sysjobhistory].[job_id]
       inner join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
               on [sysjobsteps].[job_id] = [sysjobhistory].[job_id]
                  and [sysjobsteps].[step_id] = [sysjobhistory].[step_id]
where  [sysjobs].[name] like @job + N'%'
       and ( [msdb].[dbo].[agent_datetime]([run_date]
                                           , [run_time]) >= @begin )
       and ( [msdb].[dbo].[agent_datetime]([run_date]
                                           , [run_time]) <= @end
              or @end is null )
order  by [sysjobs].[name]
          , [sysjobsteps].[job_id]
          , [sysjobsteps].[step_id]
          , [sysjobhistory].[run_date] desc
          , [sysjobhistory].[run_time] desc;

with [last_run]
     as (select [sysjobs].[name]             as [job]
                , [sysjobsteps].[step_name]  as [step]
                , [sysjobhistory].[run_time] as [start]
         from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
                  on [sysjobsteps].[job_id] = [sysjobhistory].[job_id]
                     and [sysjobsteps].[step_id] = [sysjobhistory].[step_id]
                join [msdb].[dbo].[sysjobs] as [sysjobs]
                  on [sysjobs].[job_id] = [sysjobhistory].[job_id]
         where  [sysjobs].[name] like N'%' + @job + N'%'
         group  by [sysjobs].[name]
                   , [sysjobsteps].[step_name]
                   , [sysjobhistory].[run_time])
select [sysjobs].[name]     as [job]
       , [step]             as [step]
       , [last_run].[start] as [start]
from   [msdb].[dbo].[sysjobs] as [sysjobs]
       join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
         on [sysjobsteps].[job_id] = [sysjobs].[job_id]
       join [last_run] as [last_run]
         on [last_run].[job] = [sysjobs].[name]
order  by [job]
          , [step]
          , [last_run].[start] desc;
/*

select * from  [msdb].[dbo].[sysjobhistory] as [sysjobhistory]

select [sysjobs].[name]                                                                                                                 as [job],
       [sysjobhistory].[step_name]                                                                                                      as [step],
       Cast(Str([sysjobhistory].run_date, 8, 0) as [datetime]) 
       + Cast(Stuff(Stuff(right('000000' + Cast ([sysjobhistory].run_time as [nvarchar](6)), 6), 5, 0, ':'), 3, 0, ':') as [datetime])  as [start], 
       Dateadd(second, ( ( [sysjobhistory].[run_duration] / 1000000 ) * 86400 ) + ( ( ( [sysjobhistory].[run_duration] - ( ( 
                                                                                        [sysjobhistory].[run_duration] / 1000000 ) 
                                                                                                                           * 1000000 ) ) /
                                                                                                      10000 ) * 3600 ) + ( ( (
                       [sysjobhistory].[run_duration] - ( ( 
                       [sysjobhistory].[run_duration] / 10000 ) * 10000 ) ) / 100 ) * 60 ) + ( [sysjobhistory].[run_duration] - ( 
                                                                                               [sysjobhistory].[run_duration] / 100 
                                                                                                                                ) * 100 ),
       Cast(Str([sysjobhistory].run_date, 8, 0) as [datetime]) 
       + Cast(Stuff(Stuff(right('000000' + Cast ([sysjobhistory].run_time as [nvarchar](6)), 6), 5, 0, ':'), 3, 0, ':') as [datetime])) as [end], 
       Stuff(Stuff(Replace(Str([run_duration], 6, 0), ' ', '0'), 3, 0, ':'), 6, 0, ':')                                                 as [duration],
       case [sysjobhistory].[run_status] 
         when 0 then 'failed' 
         when 1 then 'Succeded' 
         when 2 then 'Retry' 
         when 3 then 'Cancelled' 
         when 4 then 'In Progress' 
       end                                                                                                                              as [status],
       [sysjobhistory].[message]                                                                                                        as [message]
from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory] 
       inner join [msdb].[dbo].[sysjobs] as [sysjobs] 
               on [sysjobs].job_id = [sysjobhistory].job_id 
where  [sysjobs].[name] like N'%' + @job + N'%' 
order  by [start] desc; 
*/
