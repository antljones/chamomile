use [equity_ods]

GO

/****** Object:  Schema [equity]    Script Date: 10/6/2015 9:19:58 AM ******/
if not exists (select *
               from   sys.schemas
               where  name = N'equity')
  exec sys.sp_executesql
    N'CREATE SCHEMA [equity]'

GO 
