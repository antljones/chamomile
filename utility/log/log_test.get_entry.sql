/*
	KELightsey@gmail.com
	20150727
	
	Run each test and evaluate the results.
*/
go

--
-- [test_for_get_entry]
-------------------------------------------------
begin transaction [test_for_get_entry];

begin
    declare @identity    [uniqueidentifier],
            @category    [sysname]=N'category',
            @class       [sysname]=N'class',
            @type        [sysname]=N'type',
            @value       [nvarchar](max)=N'value',
            @entry       [xml]=N'<entry />',
            @timestamp   [datetime],
            @description [nvarchar](max)=N'[test_for_get_entry]';

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

    if (select @entry.value('count (//*[local-name()="entry"])[1]'
                            , N'[int]')) = 1
      print N'[test_for_get_entry] - pass'
    else
      print N'[test_for_get_entry] - fail';
end;

rollback transaction [test_for_get_entry];

go 
