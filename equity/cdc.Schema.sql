use [equity_ods]

GO

/****** Object:  Schema [cdc]    Script Date: 10/6/2015 9:19:58 AM ******/
if not exists (select *
               from   sys.schemas
               where  name = N'cdc')
  exec sys.sp_executesql
    N'CREATE SCHEMA [cdc]'

GO 
