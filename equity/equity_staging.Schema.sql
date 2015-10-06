USE [equity_ods]
GO
/****** Object:  Schema [equity_staging]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_staging')
DROP SCHEMA [equity_staging]
GO
/****** Object:  Schema [equity_staging]    Script Date: 10/6/2015 9:39:59 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_staging')
EXEC sys.sp_executesql N'CREATE SCHEMA [equity_staging] AUTHORIZATION [dbo]'

GO
