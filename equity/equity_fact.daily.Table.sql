USE [equity_dw]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.date.references]') AND parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
ALTER TABLE [equity_fact].[daily] DROP CONSTRAINT [equity_fact.daily.date.references]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.company.references]') AND parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
ALTER TABLE [equity_fact].[daily] DROP CONSTRAINT [equity_fact.daily.company.references]
GO
/****** Object:  Table [equity_fact].[daily]    Script Date: 10/6/2015 9:35:18 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_fact].[daily]') AND type in (N'U'))
DROP TABLE [equity_fact].[daily]
GO
/****** Object:  Table [equity_fact].[daily]    Script Date: 10/6/2015 9:35:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_fact].[daily]') AND type in (N'U'))
BEGIN
CREATE TABLE [equity_fact].[daily](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company.id] [int] NOT NULL,
	[date.id] [int] NOT NULL,
	[close] [float] NULL,
	[volume] [float] NULL,
	[open] [float] NULL,
	[high] [float] NULL,
	[low] [float] NULL,
 CONSTRAINT [equity_fact.daily.id.primary_key_clustered] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
ALTER AUTHORIZATION ON [equity_fact].[daily] TO  SCHEMA OWNER 
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.company.references]') AND parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
ALTER TABLE [equity_fact].[daily]  WITH CHECK ADD  CONSTRAINT [equity_fact.daily.company.references] FOREIGN KEY([company.id])
REFERENCES [equity_dimension].[company] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.company.references]') AND parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
ALTER TABLE [equity_fact].[daily] CHECK CONSTRAINT [equity_fact.daily.company.references]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.date.references]') AND parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
ALTER TABLE [equity_fact].[daily]  WITH CHECK ADD  CONSTRAINT [equity_fact.daily.date.references] FOREIGN KEY([date.id])
REFERENCES [equity_dimension].[date] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity_fact].[equity_fact.daily.date.references]') AND parent_object_id = OBJECT_ID(N'[equity_fact].[daily]'))
ALTER TABLE [equity_fact].[daily] CHECK CONSTRAINT [equity_fact.daily.date.references]
GO
