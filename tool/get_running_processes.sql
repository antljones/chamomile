/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		List all running processes within the database along with the sql text.



	--
	--	notes
	---------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--
	
	--
	-- references
	---------------------------------------------

*/
select session_id
       , status
       , blocking_session_id
       , wait_type
       , wait_time
       , wait_resource
       , transaction_id
       , *
from   sys.dm_exec_requests
where  status = N'suspended';

go

select [dm_exec_sql_text].[text] as [sql_text]
       , [dm_exec_requests].*
from   [sys].[dm_exec_requests] as [dm_exec_requests]
       cross apply [sys].[dm_exec_sql_text]([sql_handle]) as [dm_exec_sql_text];

select object_schema_name([sql_modules].[object_id]) as [schema]
       , object_name([sql_modules].[object_id])      as [method]
       , [sql_modules].[definition]                  as [sql_text]
from   [sys].[sql_modules] as [sql_modules]
where  [sql_modules].[definition] like N'%<find_this_column>%';

--
-- track a running job by changes to the index
-------------------------------------------------
select [sysindexes].[name]        as [name]
       , [sysindexes].[rows]      as [rows]
       , [sysindexes].[rowmodctr] as [rowmodctr]
       , *
from   [sys].[sysindexes] as [sysindexes] with (nolock)
where  [sysindexes].[id] = object_id('[equity].[data]')
order  by [sysindexes].[name];

select *
from   [sys].[dm_tran_active_transactions]
where  [name] like N'equity_load%';

select *
from   sys.dm_tran_active_transactions
where  name like N'%claimHeaderFact%'
order  by name;

-- http://stackoverflow.com/questions/980143/how-to-check-that-there-is-transaction-that-is-not-yet-committed-in-sql-server-2
select trans.session_id             as [session id]
       , eses.host_name             as [host name]
       , login_name                 as [login name]
       , trans.transaction_id       as [transaction id]
       , tas.name                   as [transaction name]
       , tas.transaction_begin_time as [transaction begin time]
       , tds.database_id            as [database id]
       , dbs.name                   as [database name]
from   sys.dm_tran_active_transactions tas
       join sys.dm_tran_session_transactions trans
         on ( trans.transaction_id = tas.transaction_id )
       left outer join sys.dm_tran_database_transactions tds
                    on ( tas.transaction_id = tds.transaction_id )
       left outer join sys.databases as dbs
                    on tds.database_id = dbs.database_id
       left outer join sys.dm_exec_sessions as eses
                    on trans.session_id = eses.session_id
where  eses.session_id is not null;

--
-- or 
select count(*)
from   [dbo].[claimlineft] with (nolock)

--
-------------------------------------------------
exec sp_who2

go

--
-------------------------------------------------
select *
from   [sys].[dm_tran_active_transactions] -- where name like N'%TX%';

--
-------------------------------------------------
select [blocking_session_id]
       , *
from   sys.dm_exec_requests
where  blocking_session_id <> 0;

go

dbcc inputbuffer(131)

go

kill 102 with statusonly;

go

--
-------------------------------------------------
select object_schema_name([dm_exec_sql_text].[objectid]
                          , [dm_exec_requests].[database_id]) as [schema]
       , object_name([dm_exec_sql_text].[objectid]
                     , [dm_exec_requests].[database_id])      as [object]
       , [dm_exec_requests].[session_id]                      as [session_id]
       , [dm_exec_requests].[blocking_session_id]             as [blocking_session_id]
       , [dm_exec_sql_text].[text]                            as [text]
       , [objectid]                                           as [objectid]
       , *
from   sys.dm_exec_requests as [dm_exec_requests]
       cross apply sys.dm_exec_sql_text([dm_exec_requests].[sql_handle]) as [dm_exec_sql_text];

--
-------------------------------------------------
declare @sqltext varbinary(199)

select @sqltext = sql_handle
from   sys.sysprocesses
where  spid = 61

select text
from   sys.dm_exec_sql_text(@sqltext)

go

declare @sqltext varbinary(128)

select @sqltext = sql_handle
from   sys.sysprocesses
where  spid = 61

select text
from   ::fn_get_sql(@sqltext)

go

execute sp_lock;

select session_id
       , wait_duration_ms
       , wait_type
       , blocking_session_id
from   sys.dm_os_waiting_tasks
where  blocking_session_id <> 0

kill 68 with statusonly;

go

select spid
       , status
       , loginame=substring(loginame
                            , 1
                            , 12)
       , hostname=substring(hostname
                            , 1
                            , 12)
       , blk = convert(char(3), blocked)
       , dbname=substring(db_name(dbid)
                          , 1
                          , 10)
       , cmd
       , waittype
from   master.dbo.sysprocesses
where  spid in (select blocked
                from   master.dbo.sysprocesses)

declare @databasename nvarchar(50) = N'DWReporting'
declare @sql varchar(max)

set @sql = ''

select @sql = @sql + 'Kill ' + convert(varchar, spid) + ';'
from   master..sysprocesses
where  dbid = db_id(@databasename)
       and spid <> @@spid
       and spid in (select blocked
                    from   master.dbo.sysprocesses)

--You can see the kill Processes ID
select @sql

--Kill the Processes
exec(@sql) 
