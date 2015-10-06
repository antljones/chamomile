USE [equity_ods]
GO
/****** Object:  Schema [equity_load_ods]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_load_ods')
DROP SCHEMA [equity_load_ods]
GO
/****** Object:  Schema [equity_load_ods]    Script Date: 10/6/2015 9:39:59 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_load_ods')
EXEC sys.sp_executesql N'CREATE SCHEMA [equity_load_ods] AUTHORIZATION [dbo]'

GO
