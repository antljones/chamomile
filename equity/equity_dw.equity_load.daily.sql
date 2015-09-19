use [equity_dw];

go

use [equity_dw]

go

insert into [equity_report].[daily]
            ([equity.data.id],
             [symbol],
             [company],
             [exchange],
             [industry],
             [sector],
             [date],
             [close],
             [volume],
             [open],
             [high],
             [low])
select [equity.data].[id]                                  as [equity.data.id]
       , [symbol].[symbol]                                 as [symbol]
       , [symbol].[name]                                   as [company]
       , [exchange].[name]                                 as [exchange]
       , [industry].[name]                                 as [industry]
       , [sector].[name]                                   as [sector]
       , cast([date.dimension].[datetimeoffset] as [date]) as [date]
       , [close]                                           as [close]
       , [volume]                                          as [volume]
       , [open]                                            as [open]
       , [high]                                            as [high]
       , [low]                                             as [low]
from   [equity_ods].[equity].[data] as [equity.data]
       join [equity_ods].[equity].[symbol] as [symbol]
         on [symbol].[id] = [equity.data].[symbol]
       join [date].[dimension] as [date.dimension]
         on [date.dimension].[id] = [equity.data].[date]
       join [equity_ods].[equity].[exchange] as [exchange]
         on [exchange].[id] = [symbol].[exchange]
       join [equity_ods].[equity].[industry] as [industry]
         on [industry].[id] = [symbol].[industry]
       join [equity_ods].[equity].[sector] as [sector]
         on [sector].[id] = [symbol].[sector]; 
