use [equity_ods]

GO

/****** Object:  Table [equity].[daily]    Script Date: 10/6/2015 9:19:58 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity].[daily]')
                      and type in ( N'U' ))
  begin
      create table [equity].[daily]
        (
           [id]           [int] identity(1, 1) not null
           , [company.id] [int] not null
           , [date.id]    [int] not null
           , [close]      [float] null
           , [volume]     [float] null
           , [open]       [float] null
           , [high]       [float] null
           , [low]        [float] null,
           constraint [equity_ods.data.id.primary_key_clustered] primary key clustered ( [id] asc )with (PAD_INDEX = off, STATISTICS_NORECOMPUTE = off, IGNORE_DUP_KEY = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY],
           constraint [equity_ods.data.symbol.date.unique] unique nonclustered ( [company.id] asc, [date.id] asc )with (PAD_INDEX = off, STATISTICS_NORECOMPUTE = off, IGNORE_DUP_KEY = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY]
        )
      on [PRIMARY]
  end

GO

if not exists (select *
               from   sys.foreign_keys
               where  object_id = OBJECT_ID(N'[equity].[equity_ods.data.company.references]')
                      and parent_object_id = OBJECT_ID(N'[equity].[daily]'))
  alter table [equity].[daily]
    with check add constraint [equity_ods.data.company.references] foreign key([company.id]) references [equity].[company] ([id])

GO

if exists (select *
           from   sys.foreign_keys
           where  object_id = OBJECT_ID(N'[equity].[equity_ods.data.company.references]')
                  and parent_object_id = OBJECT_ID(N'[equity].[daily]'))
  alter table [equity].[daily]
    check constraint [equity_ods.data.company.references]

GO

if not exists (select *
               from   sys.foreign_keys
               where  object_id = OBJECT_ID(N'[equity].[equity_ods.data.date.references]')
                      and parent_object_id = OBJECT_ID(N'[equity].[daily]'))
  alter table [equity].[daily]
    with check add constraint [equity_ods.data.date.references] foreign key([date.id]) references [equity].[date] ([id])

GO

if exists (select *
           from   sys.foreign_keys
           where  object_id = OBJECT_ID(N'[equity].[equity_ods.data.date.references]')
                  and parent_object_id = OBJECT_ID(N'[equity].[daily]'))
  alter table [equity].[daily]
    check constraint [equity_ods.data.date.references]

GO 
