use [equity];

go

if object_id(N'[equity].[industry]'
             , N'U') is not null
  drop table [equity].[industry];

go

create table [equity].[industry]
  (
     [id]       int not null identity(1, 1) constraint [equity.industry.id.primary_key_clustered] primary key clustered
     , [sector] [int] not null constraint [equity.industry.sector.references] references [equity].[sector]([id])
     , [name]   [sysname]
  );

go

--select max (len([industry])) from [equity_staging].[symbol]
insert into [equity].[industry]
            ([name])
select distinct [industry]
from   [equity_staging].[symbol]
order  by [industry]; 
