--
-- change to an appropriate test database
-------------------------------------------------
use [test];

go

--
-- change to an appropriate test database
-------------------------------------------------
if schema_id(N'account_test') is null
  execute (N'create schema account_test');

go

--
-- create test for accessor object
-------------------------------------------------
-------------------------------------------------

if object_id(N'[account_test].[get_primary_age]', N'P') is not null
  drop procedure [account_test].[get_primary_age];

go

create procedure [account_test].[get_primary_age] @output [xml] output
as
  begin
      declare @test_stack_builder [xml] = N'<test_stack />'
              , @test_builder     [xml] = N'<test />'
              , @timestamp        [sysname] = convert(sysname, current_timestamp, 126);

      set @test_stack_builder.modify(N'insert attribute timestamp {sql:variable("@timestamp")} as last into (/*)[1]');

      --
      -- build test conditions
      -------------------------------------------
      declare @id    [int] = 2
              , @age [int] = null;

      execute [account].[get_primary_age]
        @id = @id
        , @age = @age output;

      select @id as [id],@age as [age];

      select @output = @test_stack_builder;
  end;

go

declare @output [xml] = null;

execute [account_test].[get_primary_age]
  @output = @output output;

select @output as [output];
/*
	declare @id [int] = 2, @age [int] = null;
	execute [account].[get_primary_age] @id = @id, @age = @age output;
	select @id as [id], @age as [age];
*/
/*
	declare @id [int] = 1, @date_of_birth [date] = N'2000-06-18';
	execute [account].[set_primary_date_of_birth] @id = @id, @date_of_birth = @date_of_birth;
*/
