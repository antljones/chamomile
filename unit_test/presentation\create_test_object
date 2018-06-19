--
-- change to an appropriate test database
-------------------------------------------------
use [test];

go

--
-- change to an appropriate test database
-------------------------------------------------
if schema_id(N'account') is null
  execute (N'create schema account');

go

--
-- create test object and data
-------------------------------------------------
-------------------------------------------------
if object_id(N'[account].[primary]', N'U') is not null
  drop table [account].[primary];

go

create table [account].[primary]
  (
     [id]               [int] identity(1, 1) not null,
          constraint [account__primary__id__pk] primary key clustered ([id])
     , [first_name]     [nvarchar](128) not null
     , [last_name]      [nvarchar](128) not null
     , [middle_initial] [nvarchar](1) null
     , [date_of_birth]  [date] not null
     , [age] as datediff(year, [date_of_birth], current_timestamp) - case
                                                                 when dateadd(year, datediff(year, [date_of_birth], current_timestamp), [date_of_birth]) > current_timestamp then 1
                                                                 else 0
                                                               end
  );

go

--
-- populate sample data
-------------------------------------------------
insert into [account].[primary]
            ([first_name],[last_name],[middle_initial],[date_of_birth])
values      (N'Bob',N'Smith',null,N'1999-01-25'),
            (N'Sally',N'Brown',N'T',N'1959-12-07'),
            (N'Janet',N'Brockman',N'B',N'1983-10-21');

go

--
-- create accessor/getter object
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------

--
-- change to an appropriate test database
-------------------------------------------------
if schema_id(N'account') is null
  execute (N'create schema account');

go

--
-------------------------------------------------
if object_id(N'[account].[get_primary_age]', N'P') is not null
  drop procedure [account].[get_primary_age];

go

create procedure [account].[get_primary_age] @id    [int]
                                             , @age [int] output
as
  begin
      select @age = [age]
      from   [account].[primary]
      where  [id] = @id;
  end;

go

--
-- create mutator/setter object
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------

--
-- change to an appropriate test database
-------------------------------------------------
if schema_id(N'account') is null
  execute (N'create schema account');

go

--
-------------------------------------------------
if object_id(N'[account].[set_primary_date_of_birth]', N'P') is not null
  drop procedure [account].[set_primary_date_of_birth];

go

create procedure [account].[set_primary_date_of_birth] @id              [int]
                                                       , @date_of_birth [date]
as
  begin
      update [account].[primary]
      set    [date_of_birth] = @date_of_birth
      where  [id] = @id;
  end;

go 
