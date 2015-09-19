use [equity];

go

if object_id(N'[equity_staging].[symbol]'
             , N'U') is not null
  drop table [equity_staging].[symbol];

go

create table [equity_staging].[symbol]
  (
     [exchange]        [nvarchar](256)
     , [symbol]        [nvarchar](256)
     , [name]          [nvarchar](256)
     , [last_sale]     [nvarchar](256)
     , [market_cap]    [nvarchar](256)
     , [ipo_year]      [nvarchar](256)
     , [sector]        [nvarchar](256)
     , [industry]      [nvarchar](256)
     , [summary_quote] [nvarchar](256)
  ); 
