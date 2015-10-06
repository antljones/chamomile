use [equity_dw]

GO

/****** Object:  UserDefinedFunction [equity_report].[daily]    Script Date: 10/6/2015 9:04:34 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity_report].[daily]')
                      and type in ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  begin
      execute dbo.sp_executesql
        @statement = N'
/*
	select * from [equity_report].[daily](N''19941201'');
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

'
  end

GO 
