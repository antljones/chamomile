use [equity_dw]

GO

/****** Object:  Schema [date_dimension]    Script Date: 10/6/2015 9:04:34 AM ******/
if not exists (select *
               from   sys.schemas
               where  name = N'date_dimension')
  exec sys.sp_executesql
    N'CREATE SCHEMA [date_dimension]'

GO 
