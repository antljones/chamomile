use [equity_ods]

GO

/****** Object:  Schema [date_dw]    Script Date: 10/6/2015 9:19:58 AM ******/
if not exists (select *
               from   sys.schemas
               where  name = N'date_dw')
  exec sys.sp_executesql
    N'CREATE SCHEMA [date_dw]'

GO 
