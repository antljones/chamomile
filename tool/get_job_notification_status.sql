use [msdb];

go

select [j].[name] as [JobName]
from   [dbo].[sysjobs] [j]
       left join [dbo].[sysoperators] [o]
              on ( [j].[notify_email_operator_id] = [o].[id] )
where  [j].[enabled] = 1
       and [j].[notify_level_email] not in ( 1, 2, 3 )

GO

select [j].name   as [JobName]
       , [j].[notify_level_email]
       , [e].name as [EmailOperator]
       , [j].[notify_level_netsend]
       , [n].name as [NetSendOperator]
       , [j].[notify_level_page]
       , [p].name as [PagerOperator]
       , [j].[notify_level_eventlog]
       , [j].[delete_level]
from   dbo.[sysjobs] [j]
       left join dbo.[sysoperators] [e]
              on [j].[notify_email_operator_id] = [e].[id]
       left join dbo.[sysoperators] [n]
              on [j].[notify_netsend_operator_id] = [n].[id]
       left join dbo.[sysoperators] [p]
              on [j].[notify_page_operator_id] = [p].[id];

go

use [msdb];

GO

with jobStates
     as (select 0            as [Level]
                , 'Disabled' as [Description]
         union all
         select 1
                , 'On Success'
         union all
         select 2
                , 'On Failure'
         union all
         select 3
                , 'On Completion')
select [j].[job_id]
       , [j].name
       , [es].[Description]     as [EmailOnJobState]
       , [e].name             as [EmailOperatorName]
       , [e].[email_address]    as [EmailOperatorEmailAddress]
       , [ps].[Description]     as [PageOnJobState]
       , [p].name             as [PageOperatorName]
       , [p].[pager_address]    as [PageOperatorPagerAddress]
       , [nss].[Description]    as [NetSendOnJobState]
       , [ns].name            as [NetSendOperatorName]
       , [ns].[netsend_address] as [NetSendOperatorNetSendAddress]
       , [els].[Description]    as [EventLogOnJobState]
       , [ds].[Description]     as [DeleteJobOnJobState]
from   [dbo].[sysjobs] [j]
       inner join jobStates [es]
               on [es].[Level] = [j].[notify_level_email]
       inner join jobStates [ps]
               on [ps].[Level] = [j].[notify_level_page]
       inner join jobStates [nss]
               on [nss].[Level] = [j].[notify_level_netsend]
       inner join jobStates [els]
               on [els].[Level] = [j].[notify_level_eventlog]
       inner join jobStates [ds]
               on [ds].[Level] = [j].[delete_level]
       left outer join [dbo].[sysoperators] [e]
                    on ( [j].[notify_level_email] > 0 )
                       and ( [e].[id] = [j].[notify_email_operator_id] )
       left outer join [dbo].[sysoperators] [p]
                    on ( [j].[notify_level_page] > 0 )
                       and ( [p].[id] = [j].[notify_page_operator_id] )
       left outer join [dbo].[sysoperators] [ns]
                    on ( [j].[notify_level_netsend] > 0 )
                       and ( [ns].[id] = [j].[notify_netsend_operator_id] ); 
