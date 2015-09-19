/*
	KELightsey@gmail.com
	20150727
	
	Run each test and evaluate the results.
*/
go

--
-- [test_for_get_by_category_class_type]
-------------------------------------------------
begin transaction [test_for_get];

begin
    declare @identity    [uniqueidentifier],
            @category    [sysname]=N'category',
            @class       [sysname]=N'class',
            @type        [sysname]=N'type',
            @value       [nvarchar](max)=N'value',
            @entry       [xml]=N'<entry />',
            @timestamp   [datetime],
            @description [nvarchar](max)=N'[test_for_get_by_category_class_type]';

    truncate table [log_secure].[data];

    execute [log].[set]
      @category=@category,
      @class=@class,
      @type=@type,
      @value=@value,
      @entry=@entry,
      @description=@description,
      @identity=@identity output;

    set @timestamp = (select [created]
                      from   [log_secure].[data]
                      where  [id] = @identity);

    if (select [log].[get_value] (null
                                  , @category
                                  , @class
                                  , @type
                                  , @timestamp)) = @value
      print N'[test_for_get_by_category_class_type] - pass'
    else
      print N'[test_for_get_by_category_class_type] - fail';
end;

rollback transaction [test_for_get];

go

--
-- [test_for_get_by_id]
-------------------------------------------------
begin transaction [test_for_get];

begin
    declare @identity    [uniqueidentifier],
            @category    [sysname]=N'category',
            @class       [sysname]=N'class',
            @type        [sysname]=N'type',
            @value       [nvarchar](max)=N'value',
            @entry       [xml]=N'<entry />',
            @timestamp   [datetime],
            @description [nvarchar](max)=N'[test_for_get_by_id]';

    truncate table [log_secure].[data];

    execute [log].[set]
      @category=@category,
      @class=@class,
      @type=@type,
      @value=@value,
      @entry=@entry,
      @description=@description,
      @identity=@identity output;

    set @timestamp = (select [created]
                      from   [log_secure].[data]
                      where  [id] = @identity);

    if (select [log].[get_value] (@identity
                                  , null
                                  , null
                                  , null
                                  , null)) = @value
      print N'[test_for_get_by_id] - pass'
    else
      print N'[test_for_get_by_id] - fail';
end;

rollback transaction [test_for_get];

go 
