USE [equity_ods]
GO
/****** Object:  StoredProcedure [equity_load_ods].[equity_fact.daily_company]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_load_ods].[equity_fact.daily_company]') AND type in (N'P', N'PC'))
DROP PROCEDURE [equity_load_ods].[equity_fact.daily_company]
GO
/****** Object:  StoredProcedure [equity_load_ods].[equity_fact.daily_company]    Script Date: 10/6/2015 9:39:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_load_ods].[equity_fact.daily_company]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [equity_load_ods].[equity_fact.daily_company] AS' 
END
GO

/*
	truncate table [equity_dw].[equity_fact].[daily_company];
	execute [equity_load_ods].[equity_fact.daily_company];
*/
ALTER procedure [equity_load_ods].[equity_fact.daily_company]
as
  begin
      insert into [equity_dw].[equity_fact].[daily_company]
                  ([company.id],
                   [date.id],
                   [close],
                   [volume],
                   [open],
                   [high],
                   [low])
      select [company].[id]
             , [date].[id]
             , [daily].[close]
             , [daily].[volume]
             , [daily].[open]
             , [daily].[high]
             , [daily].[low]
      from   [equity].[daily] as [daily]
             join [equity].[company] as [company]
               on [company].[id] = [daily].[company.id]
             join [equity].[date] as [date]
               on [date].[id] = [daily].[date.id];
  end;


GO
ALTER AUTHORIZATION ON [equity_load_ods].[equity_fact.daily_company] TO  SCHEMA OWNER 
GO
ALTER AUTHORIZATION ON [equity_load_ods].[equity_fact.daily_company] TO  SCHEMA OWNER 
GO
