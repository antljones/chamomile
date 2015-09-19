use [equity];

go

if object_id(N'[equity].[sector]'
             , N'U') is not null
  drop table [equity].[sector];

go

create table [equity].[sector]
  (
     [id]     int not null identity(1, 1) constraint [equity.sector.id.primary_key_clustered] primary key clustered
     , [name] [sysname]
  );

go

--select max (len([sector])) from [equity_staging].[symbol]
insert into [equity].[sector]
            ([name])
select distinct [sector]
from   [equity_staging].[symbol]
order  by [sector]; 
