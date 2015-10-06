USE [equity_dw]
GO
/****** Object:  Schema [equity_report]    Script Date: 10/6/2015 9:35:18 AM ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_report')
DROP SCHEMA [equity_report]
GO
/****** Object:  Schema [equity_report]    Script Date: 10/6/2015 9:35:20 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_report')
EXEC sys.sp_executesql N'CREATE SCHEMA [equity_report] AUTHORIZATION [dbo]'

GO
