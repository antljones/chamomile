use [equity_ods]

GO

/****** Object:  StoredProcedure [equity_load_ods].[equity_fact.daily_company]    Script Date: 10/6/2015 9:19:58 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity_load_ods].[equity_fact.daily_company]')
                      and type in ( N'P', N'PC' ))
  begin
      exec dbo.sp_executesql
        @statement = N'CREATE PROCEDURE [equity_load_ods].[equity_fact.daily_company] AS'
  end

GO

/*
	truncate table [equity_dw].[equity_fact].[daily_company];
	execute [equity_load_ods].[equity_fact.daily_company];
*/
alter procedure [equity_load_ods].[equity_fact.daily_company]
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
