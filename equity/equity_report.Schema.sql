use [equity_dw]

GO

/****** Object:  Schema [equity_report]    Script Date: 10/6/2015 9:04:34 AM ******/
if not exists (select *
               from   sys.schemas
               where  name = N'equity_report')
  exec sys.sp_executesql
    N'CREATE SCHEMA [equity_report]'

GO 
