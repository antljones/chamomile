/*
	todo, except current column
*/
set nocount on;

declare @include [nvarchar](max),
        @column  [sysname],
        @schema  [sysname]= N'dbo',
        @object  [sysname] = N'patientEligibilityDm';
declare @index_list as table
  (
     [column]    [sysname]
     , [include] [nvarchar](max)
  );

insert into @index_list
            ([column])
select name
from   sys.columns
where  object_schema_name(object_id) = @schema
       and object_name(object_id) = @object;

declare [index_cursor] cursor for
  select [column]
  from   @index_list
  order  by [column];

open [index_cursor];

fetch next from [index_cursor] into @column;

while @@fetch_status = 0
  begin
      set @include=null;

      select @include = coalesce(@include + N', ', N' ')
                        + quotename([column], N']')
      from   @index_list
      order  by [column];

      print '--
------------------------------------------------- 
if Indexproperty (Object_id(''[' + @schema
            + N'].[' + @object + N']''), ''IX.' + @schema + N'.'
            + @object + N'.' + @column + N''', ''IndexID'') is not null
  drop index [IX.'
            + @schema + N'.' + @object + N'.' + @column + N'] on ['
            + @schema + N'].[' + @object
            + N'];
go
create nonclustered index [IX.' + @schema
            + N'.' + @object + N'.' + @column + N'] on '
            + quotename(@schema, N']')
            + quotename(@object, N']') + N'([' + @column
            + N'])
  include (' + @include + N');
go';

      fetch next from [index_cursor] into @column;
  end;

close [index_cursor];

deallocate [index_cursor]; 
