USE [equity_ods]
GO
/****** Object:  Table [equity_staging].[daily]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_staging].[daily]') AND type in (N'U'))
DROP TABLE [equity_staging].[daily]
GO
/****** Object:  Table [equity_staging].[daily]    Script Date: 10/6/2015 9:39:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_staging].[daily]') AND type in (N'U'))
BEGIN
CREATE TABLE [equity_staging].[daily](
	[symbol] [nvarchar](256) NULL,
	[date] [nvarchar](256) NULL,
	[open] [nvarchar](256) NULL,
	[high] [nvarchar](256) NULL,
	[low] [nvarchar](256) NULL,
	[close] [nvarchar](256) NULL,
	[volume] [nvarchar](256) NULL
) ON [PRIMARY]
END
GO
ALTER AUTHORIZATION ON [equity_staging].[daily] TO  SCHEMA OWNER 
GO
