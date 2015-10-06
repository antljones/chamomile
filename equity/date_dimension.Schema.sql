USE [equity_dw]
GO
/****** Object:  Schema [date_dimension]    Script Date: 10/6/2015 9:35:18 AM ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'date_dimension')
DROP SCHEMA [date_dimension]
GO
/****** Object:  Schema [date_dimension]    Script Date: 10/6/2015 9:35:20 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'date_dimension')
EXEC sys.sp_executesql N'CREATE SCHEMA [date_dimension] AUTHORIZATION [dbo]'

GO
