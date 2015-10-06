USE [equity_ods]
GO
/****** Object:  Schema [equity]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity')
DROP SCHEMA [equity]
GO
/****** Object:  Schema [equity]    Script Date: 10/6/2015 9:39:59 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity')
EXEC sys.sp_executesql N'CREATE SCHEMA [equity] AUTHORIZATION [dbo]'

GO
