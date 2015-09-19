use [chamomile];

go

if schema_id(N'repository_secure') is null
  execute (N'create schema repository_secure');

go

if object_id(N'[repository_secure].[data]'
             , N'V') is not null
  drop view [repository_secure].[data];

go

set ansi_nulls on;

go

set ansi_padding on;

go

set ansi_warnings on;

go

set concat_null_yields_null on;

go

set numeric_roundabort off;

go

set quoted_identifier on;

go

/*
	select * from [repository_secure].[data];
*/
create view [repository_secure].[data]
with schemabinding
as
  select [id]
         , [source]
         , [category]
         , [class]
         , [type]
         , [entry]
         , [description]
         , [active]
         , [expire]
         , 0 as [immutable]
         , [created]
  from   [repository_secure].[mutable]
  union all
  select [id]
         , [source]
         , [category]
         , [class]
         , [type]
         , [entry]
         , [description]
         , [active]
         , [expire]
         , 1 as [immutable]
         , [created]
  from   [repository_secure].[immutable];

go 
