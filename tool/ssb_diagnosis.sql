/*
	--
	--	description
	---------------------------------------------
		sql service broker diagnosis
			Validate Infrastructure Objects - Service Broker is dependent on five of infrastructure objects in 
			order to operate properly.  As such, once you have created your Service Broker objects, it is wise 
			to validate that all of the objects have been created.  The queries below would validate that the 
			objects exist.  These queries should be issued in both the initiator and target databases to 
			validate that the objects exist in both SQL Server environments.



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
	http://www.mssqltips.com/sqlservertip/1197/service-broker-troubleshooting/
	http://www.sqlteam.com/article/how-to-troubleshoot-service-broker-problems

*/
-- ssbdiagnose -E -d chamomile -S MCK790L8159\INSTANCE_2014_01 CONFIGURATION FROM SERVICE //chamomile.katherinelightsey.com/command_stack/initiator_service TO SERVICE //chamomile.katherinelightsey.com/command_stack/target_service;
-- ssbdiagnose -E -d oltp -S MCK790L8159\INSTANCE_2014_01 CONFIGURATION FROM SERVICE //chamomile.katherinelightsey.com/command_stack/initiator_service TO SERVICE //chamomile.katherinelightsey.com/command_stack/target_service;
-- ssbdiagnose CONFIGURATION FROM SERVICE //InstDB/2InstSample/InitiatorService -S MCK790L8159\CHAMOMILE_OLTP -d InstInitiatorDB TO SERVICE //TgtDB/2InstSample/TargetService -S MCK790L8159\CHAMOMILE -d InstTargetDB ON CONTRACT //BothDB/2InstSample/SimpleContract
-- ssbdiagnose runtime connect to -S MCK790L8159\CHAMOMILE_OLTP connect to -S MCK790L8159\CHAMOMILE
--------------------------------------------------------------------------
select *
from   sys.service_message_types;

-- Contracts
select *
from   sys.service_contracts;

-- Services
select *
from   sys.services;

-- Endpoints
select *
from   sys.endpoints;

/*
	Troubleshooting the Service Broker Queues - Once you start adding messages to your queues 
	and receiving data from your queues, it is necessary to ensure you are not having any issues 
	with your endpoints, services and contracts.  If you are experiencing issues, then this query 
	may identify the conversations that are having issues and additional research may be necessary 
	to troubleshoot the issues further.
	http://www.mssqltips.com/sqlservertip/1197/service-broker-troubleshooting/
*/
--------------------------------------------------------------------------
select conversation_handle
       , is_initiator
       , s.name  as 'local service'
       , far_service
       , sc.name 'contract'
       , state_desc
from   sys.conversation_endpoints ce
       left join sys.services s
              on ce.service_id = s.service_id
       left join sys.service_contracts sc
              on ce.service_contract_id = sc.service_contract_id;

/*
	Another key queue to keep in mind when troubleshooting Service Broker is the sys.transmission_queue.  
	This is the queue that receives any records that are not written to the user defined queue appropriately.  
	If your overall Service Broker infrastructure is setup properly, then this may be the next logical place 
	to start troubleshooting the issue.  You are able to validate the conversation as well as take a peek at 
	the xml (message_body) and find out the error message (transmission_status) for the record.
	http://www.mssqltips.com/sqlservertip/1197/service-broker-troubleshooting/
*/
--------------------------------------------------------------------------
-- Error messages in the queue
-- An error occurred while receiving data: '10054(An existing connection was forcibly closed by the remote host.)'.
select *
from   sys.transmission_queue;

/*
	Removing all records from the sys.transmission_queue - Odds are that if your Service Broker infrastructure 
	is setup properly and records are in the sys.transmission_queue, they probably need to be removed to continue 
	to build and test the application.  As such, the END CONVERSATION command should be issued with the conversation 
	handle and the 'WITH CLEANUP' parameter.  Below is an example command:
	http://www.mssqltips.com/sqlservertip/1197/service-broker-troubleshooting/
*/
--------------------------------------------------------------------------
--END CONVERSATION 'conversation handle' WITH CLEANUP;
/*
SQL Server Error Log

The next place that should be researched when troubleshooting Service Broker is the SQL Server error log.  Some of 
the issues may not be written to the views above, so the SQL Server error log is another valuable source of information.  
Below outlines two examples, although based on the issue, the errors could differ:
Date 1/1/2007 00:00:00 AM 
Log SQL Server (Current - 1/1/2007 00:00:00 AM 
Source spid62
Message Service Broker needs to access the master key in the database 'YourDatabaseName'. Error code:25. The master 
key has to exist and the service master key encryption is required

Date 1/1/2007 00:00:00 AM 
Log SQL Server (Current - 1/1/2007 00:00:00 AM 
Source spid16

Message The Service Broker protocol transport is disabled or not configured
*/
--
-- returns a row for each Service Broker network connection.
--------------------------------------------------------------------------
select *
from   sys.dm_broker_connections;

--
-- returns a row for each Service Broker message that an instance of SQL Server is in the process of forwarding.
--------------------------------------------------------------------------
select *
from   sys.dm_broker_forwarded_messages

--
-- http://technet.microsoft.com/en-us/library/ms166044(v=sql.105).aspx
--------------------------------------------------------------------------
select is_broker_enabled
from   sys.databases
where  database_id = db_id();

--
-- Contains a row for each object in the database that is a service queue, with sys.objects.type = SQ
-- http://technet.microsoft.com/en-us/library/ms166102(v=sql.105).aspx
--------------------------------------------------------------------------
select *
from   [sys].[service_queues];

--
-- returns a row for each stored procedure activated by Service Broker. It can be joined to dm_exec_sessions.session_id via the spid column.
-- http://technet.microsoft.com/en-us/library/ms175029(v=sql.105).aspx
--------------------------------------------------------------------------
select *
from   sys.dm_broker_activated_tasks

--
-- Make sure that activation stored procedures are correctly started.
-- returns a row for each queue monitor in the instance. A queue monitor manages activation for a queue.
-- http://technet.microsoft.com/en-us/library/ms166102(v=sql.105).aspx
-- ALTER QUEUE [target_queue] WITH STATUS = ON
--------------------------------------------------------------------------
select *
from   [sys].[dm_broker_queue_monitors];

select [databases].[name]                                 as [database]
       , [service_queues].[name]                          as [queue]
       , [service_queues].[activation_procedure]          as [activation_procedure]
       , [service_queues].[is_activation_enabled]         as [is_activation_enabled]
       , [dm_broker_queue_monitors].[state]               as [state]
       , [dm_broker_queue_monitors].[tasks_waiting]       as [tasks_waiting]
       , [dm_broker_queue_monitors].[last_activated_time] as [last_activated_time]
       , *
from   [sys].[dm_broker_queue_monitors] as [dm_broker_queue_monitors]
       join [sys].[service_queues] as [service_queues]
         on [service_queues].[object_id] = [dm_broker_queue_monitors].[queue_id]
       join [sys].[databases] as [databases]
         on [databases].[database_id] = [dm_broker_queue_monitors].[database_id];

select t1.name                                       as [service_name]
       , t3.name                                     as [schema_name]
       , t2.name                                     as [queue_name]
       , case
           when t4.state is null then 'Not available'
           else t4.state
         end                                         as [queue_state]
       , case
           when t4.tasks_waiting is null then '--'
           else convert(varchar, t4.tasks_waiting)
         end                                         as tasks_waiting
       , case
           when t4.last_activated_time is null then '--'
           else convert(varchar, t4.last_activated_time)
         end                                         as last_activated_time
       , case
           when t4.last_empty_rowset_time is null then '--'
           else convert(varchar, t4.last_empty_rowset_time)
         end                                         as last_empty_rowset_time
       , (select count(*)
          from   sys.transmission_queue t6
          where  ( t6.from_service_name = t1.name )) as [tran_message_count]
from   sys.services t1
       inner join sys.service_queues t2
               on ( t1.service_queue_id = t2.object_id )
       inner join sys.schemas t3
               on ( t2.schema_id = t3.schema_id )
       left outer join sys.dm_broker_queue_monitors t4
                    on ( t2.object_id = t4.queue_id
                         and t4.database_id = db_id() )
       inner join sys.databases t5
               on ( t5.database_id = db_id() ) 
