use [equity_ods]

GO

/****** Object:  Schema [equity_ods]    Script Date: 10/6/2015 9:19:58 AM ******/
if not exists (select *
               from   sys.schemas
               where  name = N'equity_ods')
  exec sys.sp_executesql
    N'CREATE SCHEMA [equity_ods]'

GO 
