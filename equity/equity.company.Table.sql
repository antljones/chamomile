use [equity_ods]

GO

/****** Object:  Table [equity].[company]    Script Date: 10/6/2015 9:19:58 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity].[company]')
                      and type in ( N'U' ))
  begin
      create table [equity].[company]
        (
           [id]              [int] identity(1, 1) not null
           , [symbol]        [sysname] not null
           , [name]          [sysname] not null
           , [last_sale]     [float] null
           , [market_cap]    [bigint] null
           , [ipo_year]      [int] null
           , [exchange.id]   [int] not null
           , [sector.id]     [int] not null
           , [industry.id]   [int] not null
           , [summary_quote] [sysname] not null,
           constraint [equity.symbol.id.primary_key_clustered] primary key clustered ( [id] asc )with (PAD_INDEX = off, STATISTICS_NORECOMPUTE = off, IGNORE_DUP_KEY = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY],
           constraint [equity.symbol.symbol.unique] unique nonclustered ( [symbol] asc )with (PAD_INDEX = off, STATISTICS_NORECOMPUTE = off, IGNORE_DUP_KEY = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY]
        )
      on [PRIMARY]
  end

GO

if not exists (select *
               from   sys.foreign_keys
               where  object_id = OBJECT_ID(N'[equity].[equity.symbol.exchange.refernces]')
                      and parent_object_id = OBJECT_ID(N'[equity].[company]'))
  alter table [equity].[company]
    with check add constraint [equity.symbol.exchange.refernces] foreign key([exchange.id]) references [equity].[exchange] ([id])

GO

if exists (select *
           from   sys.foreign_keys
           where  object_id = OBJECT_ID(N'[equity].[equity.symbol.exchange.refernces]')
                  and parent_object_id = OBJECT_ID(N'[equity].[company]'))
  alter table [equity].[company]
    check constraint [equity.symbol.exchange.refernces]

GO

if not exists (select *
               from   sys.foreign_keys
               where  object_id = OBJECT_ID(N'[equity].[equity.symbol.industry.references]')
                      and parent_object_id = OBJECT_ID(N'[equity].[company]'))
  alter table [equity].[company]
    with check add constraint [equity.symbol.industry.references] foreign key([industry.id]) references [equity].[industry] ([id])

GO

if exists (select *
           from   sys.foreign_keys
           where  object_id = OBJECT_ID(N'[equity].[equity.symbol.industry.references]')
                  and parent_object_id = OBJECT_ID(N'[equity].[company]'))
  alter table [equity].[company]
    check constraint [equity.symbol.industry.references]

GO

if not exists (select *
               from   sys.foreign_keys
               where  object_id = OBJECT_ID(N'[equity].[equity.symbol.sector.references]')
                      and parent_object_id = OBJECT_ID(N'[equity].[company]'))
  alter table [equity].[company]
    with check add constraint [equity.symbol.sector.references] foreign key([sector.id]) references [equity].[sector] ([id])

GO

if exists (select *
           from   sys.foreign_keys
           where  object_id = OBJECT_ID(N'[equity].[equity.symbol.sector.references]')
                  and parent_object_id = OBJECT_ID(N'[equity].[company]'))
  alter table [equity].[company]
    check constraint [equity.symbol.sector.references]

GO 
