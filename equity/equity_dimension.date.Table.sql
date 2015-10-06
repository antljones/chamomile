use [equity_dw]

GO

/****** Object:  Table [equity_dimension].[date]    Script Date: 10/6/2015 9:04:34 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity_dimension].[date]')
                      and type in ( N'U' ))
  begin
      create table [equity_dimension].[date]
        (
           [id]               [int] identity(1, 1) not null
           , [datetimeoffset] [datetimeoffset](7) null constraint [date.dimension.datetimeoffset.default] default (getdate())
           , [date] as ( convert([date], [datetimeoffset]) )
           , [day] as ( datepart(day
                           , [datetimeoffset]) )
           , [week] as ( datepart(week
                           , [datetimeoffset]) )
           , [quarter] as ( datepart(quarter
                           , [datetimeoffset]) )
           , [year] as ( datepart(year
                           , [datetimeoffset]) )
           , [day_of_year] as ( datepart(dayofyear
                           , [datetimeoffset]) ),
           constraint [date.dimension.id.primary_key_clustered] primary key clustered ( [id] asc )with (PAD_INDEX = off, STATISTICS_NORECOMPUTE = off, IGNORE_DUP_KEY = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY]
        )
      on [PRIMARY]
  end

GO 
