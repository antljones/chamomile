use [equity]

go

insert into [equity].[symbol]
            ([symbol],
             [name],
             [last_sale],
             [market_cap],
             [ipo_year],
             [exchange],
             [sector],
             [industry],
             [summary_quote])
select [symbol].[symbol]                     as [symbol]
       , [symbol].[name]                     as [name]
       , try_convert([float]
                     , [symbol].[last_sale]) as [last_sale]
       , case
           when right([symbol].[market_cap]
                      , 1) = N'B' then cast(cast(left([symbol].[market_cap]
                                                      , len([symbol].[market_cap]) - 1) as money) * 1000000000 as bigint)--N'B' 1,200,000,000.00
           when right([symbol].[market_cap]
                      , 1) = N'M' then cast(cast(left([symbol].[market_cap]
                                                      , len([symbol].[market_cap]) - 1) as money) * 1000000 as bigint) --then N'M' 50,320,000.00
         end                                 as [market_cap]
       , nullif([symbol].[ipo_year]
                , N'n/a')                    as [ipo_year]
       , [exchange].[id]                     as [exchange]
       , [sector].[id]                       as [sector]
       , [industry].[id]                     as [industry]
       , [symbol].[summary_quote]            as [summary_quote]
from   [equity_staging].[symbol] as [symbol]
       join [equity].[industry] as [industry]
         on [industry].[name] = [symbol].[industry]
       join [equity].[sector] as [sector]
         on [sector].[name] = [symbol].[sector]
       join [equity].[exchange] as [exchange]
         on [exchange].[name] = [symbol].[exchange]; 
