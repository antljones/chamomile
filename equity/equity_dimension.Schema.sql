USE [equity_dw]
GO
/****** Object:  Schema [equity_dimension]    Script Date: 10/6/2015 9:35:18 AM ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_dimension')
DROP SCHEMA [equity_dimension]
GO
/****** Object:  Schema [equity_dimension]    Script Date: 10/6/2015 9:35:20 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_dimension')
EXEC sys.sp_executesql N'CREATE SCHEMA [equity_dimension] AUTHORIZATION [dbo]'

GO
