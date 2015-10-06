USE [equity_ods]
GO
/****** Object:  Schema [equity_fact]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_fact')
DROP SCHEMA [equity_fact]
GO
/****** Object:  Schema [equity_fact]    Script Date: 10/6/2015 9:39:59 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'equity_fact')
EXEC sys.sp_executesql N'CREATE SCHEMA [equity_fact] AUTHORIZATION [dbo]'

GO
