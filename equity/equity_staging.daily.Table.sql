use [equity_ods]

GO

/****** Object:  Table [equity_staging].[daily]    Script Date: 10/6/2015 9:19:58 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity_staging].[daily]')
                      and type in ( N'U' ))
  begin
      create table [equity_staging].[daily]
        (
           [symbol]   [nvarchar](256) null
           , [date]   [nvarchar](256) null
           , [open]   [nvarchar](256) null
           , [high]   [nvarchar](256) null
           , [low]    [nvarchar](256) null
           , [close]  [nvarchar](256) null
           , [volume] [nvarchar](256) null
        )
      on [PRIMARY]
  end

GO 
