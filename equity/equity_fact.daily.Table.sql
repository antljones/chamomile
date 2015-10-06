use [equity_dw]

GO

/****** Object:  Table [equity_fact].[daily]    Script Date: 10/6/2015 9:04:34 AM ******/
set ANSI_NULLS on

GO

set QUOTED_IDENTIFIER on

GO

if not exists (select *
               from   sys.objects
               where  object_id = OBJECT_ID(N'[equity_fact].[daily]')
                      and type in ( N'U' ))
  begin
      create table [equity_fact].[daily]
        (
           [id]           [int] identity(1, 1) not null
           , [company.id] [int] not null
           , [date.id]    [int] not null
           , [close]      [float] null
           , [volume]     [float] null
           , [open]       [float] null
           , [high]       [float] null
           , [low]        [float] null,
           constraint [equity_fact.daily.id.primary_key_clustered] primary key clustered ( [id] asc )with (PAD_INDEX = off, STATISTICS_NORECOMPUTE = off, IGNORE_DUP_KEY = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY]
        )
      on [PRIMARY]
  end

GO

if not exists (select *
               from   sys.foreign_keys
               where  object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.company.references]')
                      and parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
  alter table [equity_fact].[daily]
    with check add constraint [equity_fact.daily.company.references] foreign key([company.id]) references [equity_dimension].[company] ([id])

GO

if exists (select *
           from   sys.foreign_keys
           where  object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.company.references]')
                  and parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
  alter table [equity_fact].[daily]
    check constraint [equity_fact.daily.company.references]

GO

if not exists (select *
               from   sys.foreign_keys
               where  object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.date.references]')
                      and parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
  alter table [equity_fact].[daily]
    with check add constraint [equity_fact.daily.date.references] foreign key([date.id]) references [equity_dimension].[date] ([id])

GO

if exists (select *
           from   sys.foreign_keys
           where  object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.date.references]')
                  and parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
  alter table [equity_fact].[daily]
    check constraint [equity_fact.daily.date.references]

GO 
