use [master]

GO

/****** Object:  Database [equity_ods]    Script Date: 10/6/2015 9:19:56 AM ******/
if not exists (select name
               from   sys.databases
               where  name = N'equity_ods')
  begin
      create database [equity_ods] CONTAINMENT = NONE on primary ( name = N'equity', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL_2014_A\MSSQL\DATA\equity.mdf', SIZE = 1480704KB, MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB ) LOG on ( name = N'equity_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL_2014_A\MSSQL\DATA\equity_log.ldf', SIZE = 3828544KB, MAXSIZE = 2048GB, FILEGROWTH = 10%)
  end

GO

alter database [equity_ods]

set COMPATIBILITY_LEVEL = 120

GO

if ( 1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') )
  begin
      exec [equity_ods].[dbo].[sp_fulltext_database]
        @action = 'enable'
  end

GO

alter database [equity_ods]

set ANSI_NULL_DEFAULT off

GO

alter database [equity_ods]

set ANSI_NULLS off

GO

alter database [equity_ods]

set ANSI_PADDING off

GO

alter database [equity_ods]

set ANSI_WARNINGS off

GO

alter database [equity_ods]

set ARITHABORT off

GO

alter database [equity_ods]

set AUTO_CLOSE off

GO

alter database [equity_ods]

set AUTO_SHRINK off

GO

alter database [equity_ods]

set AUTO_UPDATE_STATISTICS on

GO

alter database [equity_ods]

set CURSOR_CLOSE_ON_COMMIT off

GO

alter database [equity_ods]

set CURSOR_DEFAULT GLOBAL

GO

alter database [equity_ods]

set CONCAT_NULL_YIELDS_NULL off

GO

alter database [equity_ods]

set NUMERIC_ROUNDABORT off

GO

alter database [equity_ods]

set QUOTED_IDENTIFIER off

GO

alter database [equity_ods]

set RECURSIVE_TRIGGERS off

GO

alter database [equity_ods]

set DISABLE_BROKER

GO

alter database [equity_ods]

set AUTO_UPDATE_STATISTICS_ASYNC off

GO

alter database [equity_ods]

set DATE_CORRELATION_OPTIMIZATION off

GO

alter database [equity_ods]

set TRUSTWORTHY off

GO

alter database [equity_ods]

set ALLOW_SNAPSHOT_ISOLATION off

GO

alter database [equity_ods]

set PARAMETERIZATION SIMPLE

GO

alter database [equity_ods]

set READ_COMMITTED_SNAPSHOT off

GO

alter database [equity_ods]

set HONOR_BROKER_PRIORITY off

GO

alter database [equity_ods]

set RECOVERY full

GO

alter database [equity_ods]

set MULTI_USER

GO

alter database [equity_ods]

set PAGE_VERIFY CHECKSUM

GO

alter database [equity_ods]

set DB_CHAINING off

GO

alter database [equity_ods]

set FILESTREAM( NON_TRANSACTED_ACCESS = off )

GO

alter database [equity_ods]

set TARGET_RECOVERY_TIME = 0 SECONDS

GO

alter database [equity_ods]

set DELAYED_DURABILITY = DISABLED

GO

exec sys.sp_db_vardecimal_storage_format
  N'equity_ods',
  N'ON'

GO

alter database [equity_ods]

set READ_WRITE

GO 
