USE [equity_ods]
GO
/****** Object:  Schema [cdc]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'cdc')
DROP SCHEMA [cdc]
GO
/****** Object:  Schema [cdc]    Script Date: 10/6/2015 9:39:59 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'cdc')
EXEC sys.sp_executesql N'CREATE SCHEMA [cdc] AUTHORIZATION [cdc]'

GO
