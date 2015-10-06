USE [equity_ods]
GO
/****** Object:  User [cdc]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'cdc')
DROP USER [cdc]
GO
/****** Object:  User [cdc]    Script Date: 10/6/2015 9:39:57 AM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'cdc')
CREATE USER [cdc] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[cdc]
GO
ALTER ROLE [db_owner] ADD MEMBER [cdc]
GO
