use [equity_dw];

go

if schema_id(N'equity_report') is null
  execute (N'create schema equity_report');

go

if object_id(N'[equity_report].[daily]'
             , N'TF') is not null
  drop function [equity_report].[daily];

go

/*
	select * from [equity_report].[daily](N'19941201');
*/
create function [equity_report].[daily](@date [date])
returns @return table (
  [symbol] [sysname] not null,
  [date]   [date] not null,
  [close]  [float] null,
  [volume] [float] null,
  [open]   [float] null,
  [high]   [float] null,
  [low]    [float] null)
as
  begin
      insert into @return
                  ([company].[symbol],
                   [date].[date],
                   [daily].[close],
                   [daily].[volume],
                   [daily].[open],
                   [daily].[high],
                   [daily].[low])
      select [company].[symbol]
             , [date].[date]
             , [daily].[close]
             , [daily].[volume]
             , [daily].[open]
             , [daily].[high]
             , [daily].[low]
      from   [equity_fact].[daily] as [daily]
             join [equity_dimension].[company] as [company]
               on [company].[id] = [daily].[company.id]
             join [equity_dimension].[date] as [date]
               on [date].[id] = [daily].[date.id]
      where  [date] = @date;

      return;
  end;

go 
