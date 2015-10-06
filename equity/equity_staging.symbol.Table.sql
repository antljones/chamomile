USE [equity_ods]
GO
/****** Object:  Table [equity_staging].[symbol]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_staging].[symbol]') AND type in (N'U'))
DROP TABLE [equity_staging].[symbol]
GO
/****** Object:  Table [equity_staging].[symbol]    Script Date: 10/6/2015 9:39:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_staging].[symbol]') AND type in (N'U'))
BEGIN
CREATE TABLE [equity_staging].[symbol](
	[exchange] [nvarchar](256) NULL,
	[symbol] [nvarchar](256) NULL,
	[name] [nvarchar](256) NULL,
	[last_sale] [nvarchar](256) NULL,
	[market_cap] [nvarchar](256) NULL,
	[ipo_year] [nvarchar](256) NULL,
	[sector] [nvarchar](256) NULL,
	[industry] [nvarchar](256) NULL,
	[summary_quote] [nvarchar](256) NULL
) ON [PRIMARY]
END
GO
ALTER AUTHORIZATION ON [equity_staging].[symbol] TO  SCHEMA OWNER 
GO
