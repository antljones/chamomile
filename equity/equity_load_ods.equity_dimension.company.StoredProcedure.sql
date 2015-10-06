use [equity_ods]

GO

/****** Object:  StoredProcedure [equity_load_ods].[equity_dimension.company]    Script Date: 10/6/2015 9:19:58 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity_load_ods].[equity_dimension.company]')
                      and type in ( N'P', N'PC' ))
  begin
      exec dbo.sp_executesql
        @statement = N'CREATE PROCEDURE [equity_load_ods].[equity_dimension.company] AS'
  end

GO

alter procedure [equity_load_ods].[equity_dimension.company]
as
  begin
      insert into [equity_dw].[equity_dimension].[company]
                  ([symbol],
                   [name],
                   [exchange],
                   [sector],
                   [industry],
                   [summary_quote],
                   [last_sale],
                   [market_cap],
                   [ipo_year])
      select [company].[symbol]
             , [company].[name]
             , [exchange].[name]
             , [sector].[name]
             , [industry].[name]
             , [company].[summary_quote]
             , [company].[last_sale]
             , [company].[market_cap]
             , [company].[ipo_year]
      from   [equity].[company] as [company]
             join [equity].[exchange] as [exchange]
               on [exchange].[id] = [company].[exchange.id]
             join [equity].[sector] as [sector]
               on [sector].[id] = [company].[sector.id]
             join [equity].[industry] as [industry]
               on [industry].[id] = [company].[industry.id];
  end;

GO 
