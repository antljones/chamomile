-- https://www.mssqltips.com/sqlservertip/1394/how-to-store-longer-sql-agent-job-step-output-messages/
exec dbo.sp_help_jobsteplog
  @job_name = N'test2';

go

--
----------------------------------------------
select [sysjobs].[name]                                        as [job_name]
       , [sysjobhistory].[run_duration] / 10000                as [hours]
       , [sysjobhistory].[run_duration] / 100%100              as [minutes]
       , [sysjobhistory].[run_duration]%100                    as [seconds]
       , [msdb].[dbo].[agent_datetime]([run_date], [run_time]) as [run_date_time]
       , [sysjobhistory].[message]                             as [message]
       , [sysjobhistory].[retries_attempted]                   as [retries_attempted]
from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
       join [msdb].[dbo].[sysjobs] as [sysjobs]
         on [sysjobs].[job_id] = [sysjobhistory].[job_id]
where  1 = 1
       -- and [sysjobs].[enabled] = 1 -- only enabled jobs
       and [sysjobs].[name] = N'<job_name>'
order  by [job_name]
          , [run_date_time] desc; 


declare @job   [sysname] = N'<job_name>',
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

-- 
-- Jobs with frequency
-- https://www.sqlprofessionals.com/blog/sql-scripts/2014/10/06/insight-into-sql-agent-job-schedules/
--
SELECT	 [JobName] = [jobs].[name]
		,[Category] = [categories].[name]
		,[Owner] = SUSER_SNAME([jobs].[owner_sid])
		,[Enabled] = CASE [jobs].[enabled] WHEN 1 THEN 'Yes' ELSE 'No' END
		,[Scheduled] = CASE [schedule].[enabled] WHEN 1 THEN 'Yes' ELSE 'No' END
		,[Description] = [jobs].[description]
		,[Occurs] = 
				CASE [schedule].[freq_type]
					WHEN   1 THEN 'Once'
					WHEN   4 THEN 'Daily'
					WHEN   8 THEN 'Weekly'
					WHEN  16 THEN 'Monthly'
					WHEN  32 THEN 'Monthly relative'
					WHEN  64 THEN 'When SQL Server Agent starts'
					WHEN 128 THEN 'Start whenever the CPU(s) become idle' 
					ELSE ''
				END
		,[Occurs_detail] = 
				CASE [schedule].[freq_type]
					WHEN   1 THEN 'O'
					WHEN   4 THEN 'Every ' + CONVERT(VARCHAR, [schedule].[freq_interval]) + ' day(s)'
					WHEN   8 THEN 'Every ' + CONVERT(VARCHAR, [schedule].[freq_recurrence_factor]) + ' weeks(s) on ' + 
						LEFT(
							CASE WHEN [schedule].[freq_interval] &  1 =  1 THEN 'Sunday, '    ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] &  2 =  2 THEN 'Monday, '    ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] &  4 =  4 THEN 'Tuesday, '   ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] &  8 =  8 THEN 'Wednesday, ' ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] & 16 = 16 THEN 'Thursday, '  ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] & 32 = 32 THEN 'Friday, '    ELSE '' END + 
							CASE WHEN [schedule].[freq_interval] & 64 = 64 THEN 'Saturday, '  ELSE '' END , 
							LEN(
								CASE WHEN [schedule].[freq_interval] &  1 =  1 THEN 'Sunday, '    ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] &  2 =  2 THEN 'Monday, '    ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] &  4 =  4 THEN 'Tuesday, '   ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] &  8 =  8 THEN 'Wednesday, ' ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] & 16 = 16 THEN 'Thursday, '  ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] & 32 = 32 THEN 'Friday, '    ELSE '' END + 
								CASE WHEN [schedule].[freq_interval] & 64 = 64 THEN 'Saturday, '  ELSE '' END 
							) - 1
						)
					WHEN  16 THEN 'Day ' + CONVERT(VARCHAR, [schedule].[freq_interval]) + ' of every ' + CONVERT(VARCHAR, [schedule].[freq_recurrence_factor]) + ' month(s)'
					WHEN  32 THEN 'The ' + 
							CASE [schedule].[freq_relative_interval]
								WHEN  1 THEN 'First'
								WHEN  2 THEN 'Second'
								WHEN  4 THEN 'Third'
								WHEN  8 THEN 'Fourth'
								WHEN 16 THEN 'Last' 
							END +
							CASE [schedule].[freq_interval]
								WHEN  1 THEN ' Sunday'
								WHEN  2 THEN ' Monday'
								WHEN  3 THEN ' Tuesday'
								WHEN  4 THEN ' Wednesday'
								WHEN  5 THEN ' Thursday'
								WHEN  6 THEN ' Friday'
								WHEN  7 THEN ' Saturday'
								WHEN  8 THEN ' Day'
								WHEN  9 THEN ' Weekday'
								WHEN 10 THEN ' Weekend Day' 
							END + ' of every ' + CONVERT(VARCHAR, [schedule].[freq_recurrence_factor]) + ' month(s)' 
					ELSE ''
				END
		,[Frequency] = 
				CASE [schedule].[freq_subday_type]
					WHEN 1 THEN 'Occurs once at ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
					WHEN 2 THEN 'Occurs every ' + 
								CONVERT(VARCHAR, [schedule].[freq_subday_interval]) + ' Seconds(s) between ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':') + ' and ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
					WHEN 4 THEN 'Occurs every ' + 
								CONVERT(VARCHAR, [schedule].[freq_subday_interval]) + ' Minute(s) between ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':') + ' and ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
					WHEN 8 THEN 'Occurs every ' + 
								CONVERT(VARCHAR, [schedule].[freq_subday_interval]) + ' Hour(s) between ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':') + ' and ' + 
								STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [schedule].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
					ELSE ''
				END
		,[AvgDurationInSec] = CONVERT(DECIMAL(18, 2), [jobhistory].[AvgDuration])
		,[Next_Run_Date] = 
				CASE [jobschedule].[next_run_date]
					WHEN 0 THEN CONVERT(DATETIME, '1900/1/1')
					ELSE CONVERT(DATETIME, CONVERT(CHAR(8), [jobschedule].[next_run_date], 112) + ' ' + 
						 STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), [jobschedule].[next_run_time]), 6), 5, 0, ':'), 3, 0, ':'))
				END
FROM	 [msdb].[dbo].[sysjobs] AS [jobs] WITh(NOLOCK) 
		 LEFT OUTER JOIN [msdb].[dbo].[sysjobschedules] AS [jobschedule] WITh(NOLOCK) 
				 ON [jobs].[job_id] = [jobschedule].[job_id] 
		 LEFT OUTER JOIN [msdb].[dbo].[sysschedules] AS [schedule] WITh(NOLOCK) 
				 ON [jobschedule].[schedule_id] = [schedule].[schedule_id] 
		 INNER JOIN [msdb].[dbo].[syscategories] [categories] WITh(NOLOCK) 
				 ON [jobs].[category_id] = [categories].[category_id] 
		 LEFT OUTER JOIN 
					(	SELECT	 [job_id], [AvgDuration] = (SUM((([run_duration] / 10000 * 3600) + 
																(([run_duration] % 10000) / 100 * 60) + 
																 ([run_duration] % 10000) % 100)) * 1.0) / COUNT([job_id])
						FROM	 [msdb].[dbo].[sysjobhistory] WITh(NOLOCK)
						WHERE	 [step_id] = 0 
						GROUP BY [job_id]
					 ) AS [jobhistory] 
				 ON [jobhistory].[job_id] = [jobs].[job_id];
GO
