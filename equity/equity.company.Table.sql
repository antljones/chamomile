USE [equity_ods]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity.symbol.sector.references]') AND parent_object_id = OBJECT_ID(N'[equity].[company]'))
ALTER TABLE [equity].[company] DROP CONSTRAINT [equity.symbol.sector.references]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity.symbol.industry.references]') AND parent_object_id = OBJECT_ID(N'[equity].[company]'))
ALTER TABLE [equity].[company] DROP CONSTRAINT [equity.symbol.industry.references]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity.symbol.exchange.refernces]') AND parent_object_id = OBJECT_ID(N'[equity].[company]'))
ALTER TABLE [equity].[company] DROP CONSTRAINT [equity.symbol.exchange.refernces]
GO
/****** Object:  Table [equity].[company]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity].[company]') AND type in (N'U'))
DROP TABLE [equity].[company]
GO
/****** Object:  Table [equity].[company]    Script Date: 10/6/2015 9:39:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity].[company]') AND type in (N'U'))
BEGIN
CREATE TABLE [equity].[company](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[symbol] [sysname] NOT NULL,
	[name] [sysname] NOT NULL,
	[last_sale] [float] NULL,
	[market_cap] [bigint] NULL,
	[ipo_year] [int] NULL,
	[exchange.id] [int] NOT NULL,
	[sector.id] [int] NOT NULL,
	[industry.id] [int] NOT NULL,
	[summary_quote] [sysname] NOT NULL,
 CONSTRAINT [equity.symbol.id.primary_key_clustered] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [equity.symbol.symbol.unique] UNIQUE NONCLUSTERED 
(
	[symbol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
ALTER AUTHORIZATION ON [equity].[company] TO  SCHEMA OWNER 
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity.symbol.exchange.refernces]') AND parent_object_id = OBJECT_ID(N'[equity].[company]'))
ALTER TABLE [equity].[company]  WITH CHECK ADD  CONSTRAINT [equity.symbol.exchange.refernces] FOREIGN KEY([exchange.id])
REFERENCES [equity].[exchange] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity.symbol.exchange.refernces]') AND parent_object_id = OBJECT_ID(N'[equity].[company]'))
ALTER TABLE [equity].[company] CHECK CONSTRAINT [equity.symbol.exchange.refernces]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity.symbol.industry.references]') AND parent_object_id = OBJECT_ID(N'[equity].[company]'))
ALTER TABLE [equity].[company]  WITH CHECK ADD  CONSTRAINT [equity.symbol.industry.references] FOREIGN KEY([industry.id])
REFERENCES [equity].[industry] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity.symbol.industry.references]') AND parent_object_id = OBJECT_ID(N'[equity].[company]'))
ALTER TABLE [equity].[company] CHECK CONSTRAINT [equity.symbol.industry.references]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity.symbol.sector.references]') AND parent_object_id = OBJECT_ID(N'[equity].[company]'))
ALTER TABLE [equity].[company]  WITH CHECK ADD  CONSTRAINT [equity.symbol.sector.references] FOREIGN KEY([sector.id])
REFERENCES [equity].[sector] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity.symbol.sector.references]') AND parent_object_id = OBJECT_ID(N'[equity].[company]'))
ALTER TABLE [equity].[company] CHECK CONSTRAINT [equity.symbol.sector.references]
GO
