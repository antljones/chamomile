use [equity_ods]

GO

/****** Object:  Schema [equity_staging]    Script Date: 10/6/2015 9:19:58 AM ******/
if not exists (select *
               from   sys.schemas
               where  name = N'equity_staging')
  exec sys.sp_executesql
    N'CREATE SCHEMA [equity_staging]'

GO 
