use [equity];

go

if object_id(N'[equity].[exchange]'
             , N'U') is not null
  drop table [equity].[exchange];

go

create table [equity].[exchange]
  (
     [id]     int not null identity(1, 1) constraint [equity.exchange.id.primary_key_clustered] primary key clustered
     , [name] [sysname]
  );

go

insert into [equity].[exchange]
            ([name])
values      (N'nyse'),
            (N'nasdaq'),
            (N'amex'); 
