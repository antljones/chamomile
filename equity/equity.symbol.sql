use [equity];

go

if object_id(N'[equity].[symbol]'
             , N'U') is not null
  drop table [equity].[symbol];

go

/*
	select top(100) * from [equity_staging].[symbol];
*/
create table [equity].[symbol]
  (
     [id]              int not null identity(1, 1) constraint [equity.symbol.id.primary_key_clustered] primary key clustered
     --
     , [symbol]        [sysname] not null
          constraint [equity.symbol.symbol.unique] unique([symbol])
     , [name]          [sysname]
     , [last_sale]     [float]
     , [market_cap]    [bigint]
     , [ipo_year]      [int]
     --
     , [exchange]      [int] not null constraint [equity.symbol.exchange.refernces] references [equity].[exchange]([id])
     , [sector]        [int] not null constraint [equity.symbol.sector.references] references [equity].[sector]([id])
     , [industry]      [int] not null constraint [equity.symbol.industry.references] references [equity].[industry]([id])
     , [summary_quote] [sysname]
  ); 
