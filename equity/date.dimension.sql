use [equity];

go

if schema_id(N'date') is null
  execute (N'create schema date');

go

if object_id(N'[date].[dimension]'
             , N'U') is not null
  drop table [date].[dimension];

go

create table [date].[dimension]
  (
     [id]               int not null identity(1, 1) constraint [date.dimension.id.primary_key_clustered] primary key clustered
     , [datetimeoffset] [datetimeoffset] constraint [date.dimension.datetimeoffset.default] default (current_timestamp)
  );

go

insert into [date].[dimension]
            ([datetimeoffset])
select [datetimeoffset]
from   [chamomile].[date].[dimension]
order  by [datetimeoffset] asc; 
