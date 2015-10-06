use [equity_dw]

GO

/****** Object:  Table [equity_dimension].[company]    Script Date: 10/6/2015 9:04:34 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity_dimension].[company]')
                      and type in ( N'U' ))
  begin
      create table [equity_dimension].[company]
        (
           [id]              [int] identity(1, 1) not null
           , [symbol]        [sysname] not null
           , [name]          [sysname] not null
           , [exchange]      [sysname] not null
           , [sector]        [sysname] not null
           , [industry]      [sysname] not null
           , [summary_quote] [sysname] not null
           , [last_sale]     [float] null
           , [market_cap]    [bigint] null
           , [ipo_year]      [int] null,
           constraint [equity_dimension.symbol.id.primary_key_clustered] primary key clustered ( [id] asc )with (PAD_INDEX = off, STATISTICS_NORECOMPUTE = off, IGNORE_DUP_KEY = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY]
        )
      on [PRIMARY]
  end

GO 
