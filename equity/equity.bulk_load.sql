use [equity]

go

insert into [equity].[data]
            ([symbol],
             [date],
             [close],
             [volume],
             [open],
             [high],
             [low])
select [symbol]
       , [date]
       , [close]
       , [volume]
       , [open]
       , [high]
       , [low]
from   [equity_staging].[data];

go 
