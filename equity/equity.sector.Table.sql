use [equity_ods]

GO

/****** Object:  Table [equity].[sector]    Script Date: 10/6/2015 9:19:58 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity].[sector]')
                      and type in ( N'U' ))
  begin
      create table [equity].[sector]
        (
           [id]     [int] identity(1, 1) not null
           , [name] [sysname] not null,
           constraint [equity.sector.id.primary_key_clustered] primary key clustered ( [id] asc )with (PAD_INDEX = off, STATISTICS_NORECOMPUTE = off, IGNORE_DUP_KEY = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY]
        )
      on [PRIMARY]
  end

GO 
