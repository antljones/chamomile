use [equity_dw]

GO

/****** Object:  Schema [equity_dimension]    Script Date: 10/6/2015 9:04:34 AM ******/
if not exists (select *
               from   sys.schemas
               where  name = N'equity_dimension')
  exec sys.sp_executesql
    N'CREATE SCHEMA [equity_dimension]'

GO 
