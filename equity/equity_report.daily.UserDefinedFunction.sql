USE [equity_dw]
GO
/****** Object:  UserDefinedFunction [equity_report].[daily]    Script Date: 10/6/2015 9:35:18 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_report].[daily]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [equity_report].[daily]
GO
/****** Object:  UserDefinedFunction [equity_report].[daily]    Script Date: 10/6/2015 9:35:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_report].[daily]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
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
END

GO
ALTER AUTHORIZATION ON [equity_report].[daily] TO  SCHEMA OWNER 
GO
