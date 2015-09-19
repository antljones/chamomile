use [equity_dw];

go

if schema_id(N'date') is null
  execute (N'create schema date');

go

if object_id(N'[date].[dimension]'
             , N'U') is not null
  drop table [date].[dimension]

go

set ansi_nulls on;

go

set quoted_identifier on;

go

create table [date].[dimension]
  (
     [id]               [int] identity(1, 1) not null
          constraint [date.dimension.id.primary_key_clustered] primary key clustered ( [id] asc )
     , [datetimeoffset] [datetimeoffset](7) null constraint [date.dimension.datetimeoffset.default] default (getdate())
     , [date] as cast([datetimeoffset] as [date])
     , [day] as datepart(day
                   , [datetimeoffset])
     , [week] as datepart (week
                    , [datetimeoffset])
     , [quarter] as datepart(quarter
                   , [datetimeoffset])
     , [year] as datepart(year
                   , [datetimeoffset])
  );

go 
