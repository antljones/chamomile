USE [equity_dw]
GO
/****** Object:  Table [equity_dimension].[company]    Script Date: 10/6/2015 9:35:18 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_dimension].[company]') AND type in (N'U'))
DROP TABLE [equity_dimension].[company]
GO
/****** Object:  Table [equity_dimension].[company]    Script Date: 10/6/2015 9:35:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_dimension].[company]') AND type in (N'U'))
BEGIN
CREATE TABLE [equity_dimension].[company](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[symbol] [sysname] NOT NULL,
	[name] [sysname] NOT NULL,
	[exchange] [sysname] NOT NULL,
	[sector] [sysname] NOT NULL,
	[industry] [sysname] NOT NULL,
	[summary_quote] [sysname] NOT NULL,
	[last_sale] [float] NULL,
	[market_cap] [bigint] NULL,
	[ipo_year] [int] NULL,
 CONSTRAINT [equity_dimension.symbol.id.primary_key_clustered] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
ALTER AUTHORIZATION ON [equity_dimension].[company] TO  SCHEMA OWNER 
GO
