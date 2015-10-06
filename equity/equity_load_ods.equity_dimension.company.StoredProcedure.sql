USE [equity_ods]
GO
/****** Object:  StoredProcedure [equity_load_ods].[equity_dimension.company]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_load_ods].[equity_dimension.company]') AND type in (N'P', N'PC'))
DROP PROCEDURE [equity_load_ods].[equity_dimension.company]
GO
/****** Object:  StoredProcedure [equity_load_ods].[equity_dimension.company]    Script Date: 10/6/2015 9:39:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_load_ods].[equity_dimension.company]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [equity_load_ods].[equity_dimension.company] AS' 
END
GO

ALTER procedure [equity_load_ods].[equity_dimension.company]
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
ALTER AUTHORIZATION ON [equity_load_ods].[equity_dimension.company] TO  SCHEMA OWNER 
GO
ALTER AUTHORIZATION ON [equity_load_ods].[equity_dimension.company] TO  SCHEMA OWNER 
GO
