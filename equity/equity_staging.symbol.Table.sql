use [equity_ods]

GO

/****** Object:  Table [equity_staging].[symbol]    Script Date: 10/6/2015 9:19:58 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity_staging].[symbol]')
                      and type in ( N'U' ))
  begin
      create table [equity_staging].[symbol]
        (
           [exchange]        [nvarchar](256) null
           , [symbol]        [nvarchar](256) null
           , [name]          [nvarchar](256) null
           , [last_sale]     [nvarchar](256) null
           , [market_cap]    [nvarchar](256) null
           , [ipo_year]      [nvarchar](256) null
           , [sector]        [nvarchar](256) null
           , [industry]      [nvarchar](256) null
           , [summary_quote] [nvarchar](256) null
        )
      on [PRIMARY]
  end

GO 
