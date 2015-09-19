use [equity_dw]

go

if object_id(N'[equity_report].[daily]'
             , N'U') is not null
  drop table [equity_report].[daily];

go

set ansi_nulls on;

go

set quoted_identifier on;

go

create table [equity_report].[daily]
  (
     [id]         [int] null
     , [symbol]   [sysname] not null constraint [equity_report.daily.id.primary_key_clustered] primary key clustered
     , [company]  [sysname] not null
     , [exchange] [sysname] not null
     , [industry] [sysname] not null
     , [sector]   [sysname] not null
     , [date]     [date] null
     , [day]      [sysname] not null
     , [week]     [int] null
     , [quarter]  [int] null
     , [year]     [int] null
     , [close]    [float] null
     , [volume]   [float] null
     , [open]     [float] null
     , [high]     [float] null
     , [low]      [float] null
  );

go 
