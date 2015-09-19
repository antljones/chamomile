/*
	KELightsey@gmail.com
	20150727
	
	Run each test and evaluate the results.
*/
go

--
-- [test_for_get_list]
-------------------------------------------------
begin transaction [test_for_get_list];

begin
    declare @identity    [uniqueidentifier],
            @category    [sysname]=N'category',
            @class       [sysname]=N'class',
            @type        [sysname]=N'type',
            @value       [nvarchar](max)=N'value',
            @entry       [xml]=N'<entry />',
            @timestamp   [datetime],
            @description [nvarchar](max)=N'[test_for_get_list]';

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

    if (select count(*)
        from   [log].[get_list] (@category
                                 , @class
                                 , @type
                                 , @timestamp)) = 1
      print N'[test_for_get_list] - pass'
    else
      print N'[test_for_get_list] - fail';
end;

rollback transaction [test_for_get_list];

go

--
-- [test_for_get_list_partial_match]
-------------------------------------------------
begin transaction [test_for_get_list_partial_match];

begin
    declare @identity    [uniqueidentifier],
            @category    [sysname]=N'category',
            @class       [sysname]=N'class',
            @type        [sysname]=N'type',
            @value       [nvarchar](max)=N'value',
            @entry       [xml]=N'<entry />',
            @description [nvarchar](max)=N'[test_for_get_list_partial_match]';

    truncate table [log_secure].[data];

    execute [log].[set]
      @category=@category,
      @class=@class,
      @type=@type,
      @value=@value,
      @entry=@entry,
      @description=@description,
      @identity=@identity output;

    set @type = N'type2';

    execute [log].[set]
      @category=@category,
      @class=@class,
      @type=@type,
      @value=@value,
      @entry=@entry,
      @description=@description,
      @identity=@identity output;

    if (select count(*)
        from   [log].[get_list] (@category
                                 , @class
                                 , null
                                 , null)) = 2
      print N'[test_for_get_list_partial_match] - pass'
    else
      print N'[test_for_get_list_partial_match] - fail';
end;

rollback transaction [test_for_get_list_partial_match];

go 
