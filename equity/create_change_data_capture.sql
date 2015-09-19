/*
	All content is licensed as [chamomile] (http://www.chamomilesql.com/source/license.html) and  
	copyright Katherine Elizabeth Lightsey (http://www.kelightsey.com/), 1959-2015 (aka; my life), all rights reserved, 
	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		manage change data capture for [equity].[equity].[data]
*/
--
-- code block begin
-------------------------------------------------
use [equity];

go

if schema_id(N'equity') is null
  execute (N'create schema equity');

go

if (select [is_cdc_enabled]
    from   [sys].[databases]
    where  [name] = N'equity') = 1
  exec [sys].[sp_cdc_disable_db];

go

--
-------------------------------------------------
exec [sys].[sp_cdc_enable_db];

go

--
--  Disable Change Data Tracking for [equity].[data] 
-------------------------------------------------
if exists (select [tables].[is_tracked_by_cdc]
           from   [sys].[tables] as [tables]
           where  [tables].[name] = N'data'
                  and [is_tracked_by_cdc] = 1)
  execute [sys].sp_cdc_disable_table
    @source_schema = N'equity',
    @source_name = N'data',
    @capture_instance = N'equity.data';

go

-- 
-------------------------------------------------
exec [sys].[sp_cdc_enable_table]
  @source_schema = N'equity',
  @source_name = N'data',
  @role_name = null,
  @capture_instance =N'equity.data',
  @supports_net_changes = 1;

go

--
-- Getting information about the change data capture enabled table 
-------------------------------------------------
execute [sys].[sp_cdc_help_change_data_capture]
  @source_schema = N'equity',
  @source_name = N'data';

--
-------------------------------------------------
execute [sys].[sp_cdc_get_captured_columns]
  @capture_instance = 'equity_data';

go

--
--  Notice that there are new objects and functions created for the change data capture enabled table 
-------------------------------------------------
select object_schema_name([objects].[object_id]) as [schema]
       , [name]
       , [type_desc]
       , [create_date]
from   [sys].[objects] as [objects]
where  lower([objects].[name]) like lower(N'%data%')
order  by [schema]
          , [name];

--
--  fn_cdc_get_all_changes_: Returns one row for each change applied to the source table within the specified log sequence number (LSN) range. 
--  fn_cdc_get_net_changes_: Returns one net change row for each source row changed within the specified LSN range.
-------------------------------------------------
select [tables].[name]                      as [source_table]
       , [capture_table].[name]             as [capture_table]
       , [change_tables].[capture_instance] as [capture_instance]
       , [captured_columns].[column_name]   as [column_name]
       , [captured_columns].[column_type]   as [column_type]
from   [cdc].[captured_columns] as [captured_columns]
       join [cdc].[change_tables] as [change_tables]
         on [change_tables].[object_id] = [captured_columns].[object_id]
       join [sys].[tables] as [capture_table]
         on [capture_table].[object_id] = [captured_columns].[object_id]
       join [sys].[tables] as [tables]
         on [tables].[object_id] = [change_tables].[source_object_id]
       join [sys].[schemas] as [schemas]
         on [schemas].[schema_id] = [tables].[schema_id]
where  [schemas].[name] = N'equity'
       and [tables].[name] = N'data';

go

--
--  Returns one row for each change table in the database. 
-------------------------------------------------
select *
from   [cdc].[change_tables];

--
--  Returns one row for each index column associated with a change table. 
select *
from   [cdc].[index_columns];

go

--
-- Returns one row for each transaction having rows in a change table.  
select *
from   [cdc].[lsn_time_mapping];

go

-- 
-- [cdc].fn_cdc_get_all_changes_ - returns all changes for a tracked table 
-------------------------------------------------
declare @from_lsn binary(10),
        @to_lsn   binary(10)

set @from_lsn = [sys].[fn_cdc_get_min_lsn]('equity.data');
set @to_lsn = [sys].[fn_cdc_get_max_lsn]();

/*
	If the specified LSN range does not fall within the change tracking timeline for the capture instance, the function returns error 208 ("An insufficient number of arguments were supplied for the procedure or function cdc.fn_cdc_get_all_changes.").
*/
select *
from   [cdc].[fn_cdc_get_all_changes_equity.data] (@from_lsn
                                                   , @to_lsn
                                                   , N'all');

go

--
-- Get changes for a specific primary key value 
-- Join to [cdc].lsn_time_mapping to return transaction start and end times 
-------------------------------------------------
declare @from_lsn binary(10),
        @to_lsn   binary(10)

set @from_lsn = [sys].fn_cdc_get_min_lsn('equity_data');
set @to_lsn = [sys].fn_cdc_get_max_lsn();

select case [change_data_function].__$operation
         when 1 then N'DELETE'
         when 2 then N'INSERT'
         when 3 then N'UPDATE1'
         when 4 then N'UPDATE2'
       end as N'Operation'
       , [change_data_function].[id]
       , [change_data_function].[symbol]
       , [change_data_function].[open]
       , lst.tran_begin_time
       , lst.tran_end_time
       , [change_data_function].*
from   [cdc].[fn_cdc_get_all_changes_equity.data] (@from_lsn
                                                   , @to_lsn
                                                   , N'all') as [change_data_function]
       join [cdc].lsn_time_mapping as lst
         on [change_data_function].__$start_lsn = lst.start_lsn
where  [change_data_function].[id] = 1
order  by [change_data_function].[id]
          , [change_data_function].__$start_lsn
          , [change_data_function].__$seqval;

go 
