use [equity_dw]

go

insert into [equity_dimension].[symbol]
            ([symbol],
             [name],
             [exchange],
             [sector],
             [industry],
             [summary_quote])
select [symbol].[symbol]
       , [symbol].[name]
       , [exchange].[name]
       , [sector].[name]
       , [industry].[name]
       , [symbol].[summary_quote]
from   [equity_ods].[equity].[symbol] as [symbol]
       join [equity_ods].[equity].[exchange] as [exchange]
         on [exchange].[id] = [symbol].[exchange]
       join [equity_ods].[equity].[sector] as [sector]
         on [sector].[id] = [symbol].[exchange]
       join [equity_ods].[equity].[industry] as [industry]
         on [industry].[id] = [symbol].[industry];

go 
