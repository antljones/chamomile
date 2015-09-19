use [equity];

go

--
if schema_id(N'equity_ods') is null
  execute (N'create schema equity_ods');

go

if object_id(N'[equity_ods].[data]'
             , N'U') is not null
  drop table [equity_ods].[data];

go

-- "date","close","volume","open","high","low"
-- select top(100)* from [equity_ods].[data];
create table [equity_ods].[data]
  (
     [id]       [int] identity(1, 1) not null constraint [equity_ods.data.id.primary_key_clustered] primary key clustered
     , [symbol] [int] not null constraint [equity_ods.data.symbol.references] references [equity_ods].[symbol]([id])
     , [date]   [int] not null constraint [equity_ods.data.date.references] references [date].[dimension]([id])
     , [close]  [float]
     , [volume] [float]
     , [open]   [float]
     , [high]   [float]
     , [low]    [float]
  );

go

alter table [equity_ods].[data]
  add constraint [equity_ods.data.symbol.date.unique] unique ([symbol], [date]);

go
/*
-- add these as xml columns here? another table?
alter table[equity_ods].[data]
add 
   [0003_day_ave] [float]
  , [0005_day_ave] [float]
  , [0007_day_ave] [float]
  , [0014_day_ave] [float]
  , [0021_day_ave] [float]
  , [0030_day_ave] [float]
  , [0060_day_ave] [float]
  , [0090_day_ave] [float]
  , [0120_day_ave] [float]
  , [0180_day_ave] [float]
  , [0270_day_ave] [float]
  , [0365_day_ave] [float]
  , [0540_day_ave] [float]
  , [0730_day_ave] [float]
  , [1095_day_ave] [float]
  , [1460_day_ave] [float]
  , [1825_day_ave] [float]
  , [2190_day_ave] [float]
  , [2555_day_ave] [float]
  , [2920_day_ave] [float]
  , [3285_day_ave] [float]
  , [3650_day_ave] [float];

  
alter table[equity_ods].[data]
add 
   [0001_day_delta] [float]
  , [0003_day_delta] [float]
  , [0005_day_delta] [float]
  , [0007_day_delta] [float]
  , [0014_day_delta] [float]
  , [0021_day_delta] [float]
  , [0030_day_delta] [float]
  , [0060_day_delta] [float]
  , [0090_day_delta] [float]
  , [0120_day_delta] [float]
  , [0180_day_delta] [float]
  , [0270_day_delta] [float]
  , [0365_day_delta] [float]
  , [0540_day_delta] [float]
  , [0730_day_delta] [float]
  , [1095_day_delta] [float]
  , [1460_day_delta] [float]
  , [1825_day_delta] [float]
  , [2190_day_delta] [float]
  , [2555_day_delta] [float]
  , [2920_day_delta] [float]
  , [3285_day_delta] [float]
  , [3650_day_delta] [float];

alter table[equity_ods].[data]
add 
   [0003_day_m] [float]
  , [0005_day_m] [float]
  , [0007_day_m] [float]
  , [0014_day_m] [float]
  , [0021_day_m] [float]
  , [0030_day_m] [float]
  , [0060_day_m] [float]
  , [0090_day_m] [float]
  , [0120_day_m] [float]
  , [0180_day_m] [float]
  , [0270_day_m] [float]
  , [0365_day_m] [float]
  , [0540_day_m] [float]
  , [0730_day_m] [float]
  , [1095_day_m] [float]
  , [1460_day_m] [float]
  , [1825_day_m] [float]
  , [2190_day_m] [float]
  , [2555_day_m] [float]
  , [2920_day_m] [float]
  , [3285_day_m] [float]
  , [3650_day_m] [float];
alter table[equity_ods].[data]
add 
   [0003_day_sd] [float]
  , [0005_day_sd] [float]
  , [0007_day_sd] [float]
  , [0014_day_sd] [float]
  , [0021_day_sd] [float]
  , [0030_day_sd] [float]
  , [0060_day_sd] [float]
  , [0090_day_sd] [float]
  , [0120_day_sd] [float]
  , [0180_day_sd] [float]
  , [0270_day_sd] [float]
  , [0365_day_sd] [float]
  , [0540_day_sd] [float]
  , [0730_day_sd] [float]
  , [1095_day_sd] [float]
  , [1460_day_sd] [float]
  , [1825_day_sd] [float]
  , [2190_day_sd] [float]
  , [2555_day_sd] [float]
  , [2920_day_sd] [float]
  , [3285_day_sd] [float]
  , [3650_day_sd] [float];
  */
