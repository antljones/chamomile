/*
	KELightsey@gmail.com
	20150727
	
	Run each test and evaluate the results.
	The tests for update and delete should raise an error if pass.
*/
go

--
-- [test_for_insert]
-------------------------------------------------
begin transaction [test_for_insert];

begin
    declare @identity    [uniqueidentifier],
            @category    [sysname]=N'category',
            @class       [sysname]=N'class',
            @type        [sysname]=N'type',
            @value       [nvarchar](max)=N'value',
            @entry       [xml]=N'<entry />',
            @description [nvarchar](max)=N'[test_for_insert]';

    truncate table [log_secure].[data];

    execute [log].[set]
      @category=@category,
      @class=@class,
      @type=@type,
      @value=@value,
      @entry=@entry,
      @description=@description,
      @identity=@identity output;

    if (select [value]
        from   [log_secure].[data]
        where  [id] = @identity) = @value
      print N'[test_for_insert] - pass'
    else
      print N'[test_for_insert] - fail';
end;

rollback transaction [test_for_insert];

go

--
-- [test_for_multiple_inserts]
-------------------------------------------------
begin transaction [test_for_multiple_inserts];

begin
    declare @identity    [uniqueidentifier],
            @category    [sysname]=N'category',
            @class       [sysname]=N'class',
            @type        [sysname]=N'type',
            @value       [nvarchar](max)=N'value',
            @entry       [xml]=N'<entry />',
            @description [nvarchar](max)=N'[test_for_multiple_inserts]';

    truncate table [log_secure].[data];

    execute [log].[set]
      @category=@category,
      @class=@class,
      @type=@type,
      @value=@value,
      @entry=@entry,
      @description=@description,
      @identity=@identity output;

    execute [log].[set]
      @category=@category,
      @class=@class,
      @type=@type,
      @value=@value,
      @entry=@entry,
      @description=@description,
      @identity=@identity output;

    if (select count(*)
        from   [log_secure].[data]
        where  [category] = @category
               and [class] = @class
               and [type] = @type) = 2
      print N'[test_for_multiple_inserts] - pass'
    else
      print N'[test_for_multiple_inserts] - fail';
end;

rollback transaction [test_for_multiple_inserts];

go

--
-- [test_for_delete]
-- pass if an error is raised
-- fail if no error is raised
-------------------------------------------------
begin transaction [test_for_delete];

begin
    declare @identity    [uniqueidentifier],
            @category    [sysname]=N'category',
            @class       [sysname]=N'class',
            @type        [sysname]=N'type',
            @value       [nvarchar](max)=N'value',
            @entry       [xml]=N'<entry />',
            @description [nvarchar](max)=N'[test_for_delete]';

    truncate table [log_secure].[data];

    execute [log].[set]
      @category=@category,
      @class=@class,
      @type=@type,
      @value=@value,
      @entry=@entry,
      @description=@description,
      @identity=@identity output;

    --
    ------------------------------------------------
    delete from [log_secure].[data]
    where  [id] = @identity;
end;

rollback transaction [test_for_delete];

go

--
-- [test_for_update]
-- pass if an error is raised
-- fail if no error is raised
-------------------------------------------------
begin transaction [test_for_update];

begin
    declare @identity    [uniqueidentifier],
            @category    [sysname]=N'category',
            @class       [sysname]=N'class',
            @type        [sysname]=N'type',
            @value       [nvarchar](max)=N'value',
            @entry       [xml]=N'<entry />',
            @description [nvarchar](max)=N'[test_for_update]';

    truncate table [log_secure].[data];

    execute [log].[set]
      @category=@category,
      @class=@class,
      @type=@type,
      @value=@value,
      @entry=@entry,
      @description=@description,
      @identity=@identity output;

    --
    ------------------------------------------------
    update [log_secure].[data]
    set    [value] = N'new value'
    where  [id] = @identity;
end;

rollback transaction [test_for_update];

go 
