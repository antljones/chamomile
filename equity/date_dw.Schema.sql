USE [equity_ods]
GO
/****** Object:  Schema [date_dw]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'date_dw')
DROP SCHEMA [date_dw]
GO
/****** Object:  Schema [date_dw]    Script Date: 10/6/2015 9:39:59 AM ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'date_dw')
EXEC sys.sp_executesql N'CREATE SCHEMA [date_dw] AUTHORIZATION [dbo]'

GO
