use [equity_ods]

GO

/****** Object:  Schema [date]    Script Date: 10/6/2015 9:19:58 AM ******/
if not exists (select *
               from   sys.schemas
               where  name = N'date')
  exec sys.sp_executesql
    N'CREATE SCHEMA [date]'

GO 
