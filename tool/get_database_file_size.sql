
if object_id(N'tempdb..##builder', N'U') is not null
  drop table ##builder;

go

create table ##builder
  (
     [database]        sysname
     , [name]          sysname
     , [physical_name] nvarchar(max)
     , [size]          bigint
  );

insert into ##builder
            ([database]
             , [name]
             , [physical_name]
             , [size])
select [databases].[name]
       , [master_files].[name]
       , [physical_name]
       , [size]
from   sys.[master_files] as [master_files]
       join [sys].[databases] as [databases]
         on [databases].[database_id] = [master_files].[database_id];

select [database]                                                          as [database]
       , [name]                                                            as [file_name]
       , [physical_name]                                                   as [physical_name]
       , cast(cast([size] as decimal(10, 2)) * 8 / 1024 as decimal(10, 3)) as [size_mb]
from   ##builder
order  by [database]
          , [name]
          , [physical_name]
          , [size];
