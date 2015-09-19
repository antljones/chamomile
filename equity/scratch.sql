/*

*/
use [equity]

go

select top(100) [equity.data].[id]       as [equity.data.id]
                , [equity.data].[symbol] as [symbol]
                , [symbol].[id]          as [symbol.id]
                , [equity.data].[date]   as [date]
                , [date.dimension].[id]  as [date.dimension.id]
                , [equity.data].[close]
                , [equity.data].[volume]
                , [equity.data].[open]
                , [equity.data].[high]
                , [equity.data].[low]
from   [equity].[data] as [equity.data]
       join [equity].[symbol] as [symbol]
         on [symbol].[symbol] = [equity.data].[symbol]
       join [chamomile].[date].[dimension] as [date.dimension]
         on [date.dimension].[datetimeoffset] = cast([equity.data].[date] as [datetimeoffset])

go

select top(100)*
from   [equity].[symbol] as [symbol]
       join [equity].[data] as [data]
         on [data].[symbol] = [symbol].[symbol];

select max([date])
from   [equity].[data];

truncate table [equity_staging].[data];

select count(*)
from   [equity].[data];

select count(*)
from   [equity_staging].[data];

select top 1000 [symbol]
                , [date]
                , [open]
                , [high]
                , [low]
                , [close]
                , [volume]
from   [equity_staging].[data]
where  isnumeric([close]) = 0
        or isdate([date]) = 0

select *
from   [sys].[dm_tran_active_transactions]
where  [name] like N'equity_load%'; 
