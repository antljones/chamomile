USE [equity_ods]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity_ods.data.date.references]') AND parent_object_id = OBJECT_ID(N'[equity].[daily]'))
ALTER TABLE [equity].[daily] DROP CONSTRAINT [equity_ods.data.date.references]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity_ods.data.company.references]') AND parent_object_id = OBJECT_ID(N'[equity].[daily]'))
ALTER TABLE [equity].[daily] DROP CONSTRAINT [equity_ods.data.company.references]
GO
/****** Object:  Table [equity].[daily]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity].[daily]') AND type in (N'U'))
DROP TABLE [equity].[daily]
GO
/****** Object:  Table [equity].[daily]    Script Date: 10/6/2015 9:39:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity].[daily]') AND type in (N'U'))
BEGIN
CREATE TABLE [equity].[daily](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company.id] [int] NOT NULL,
	[date.id] [int] NOT NULL,
	[close] [float] NULL,
	[volume] [float] NULL,
	[open] [float] NULL,
	[high] [float] NULL,
	[low] [float] NULL,
 CONSTRAINT [equity_ods.data.id.primary_key_clustered] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [equity_ods.data.symbol.date.unique] UNIQUE NONCLUSTERED 
(
	[company.id] ASC,
	[date.id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
ALTER AUTHORIZATION ON [equity].[daily] TO  SCHEMA OWNER 
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity_ods.data.company.references]') AND parent_object_id = OBJECT_ID(N'[equity].[daily]'))
ALTER TABLE [equity].[daily]  WITH CHECK ADD  CONSTRAINT [equity_ods.data.company.references] FOREIGN KEY([company.id])
REFERENCES [equity].[company] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity_ods.data.company.references]') AND parent_object_id = OBJECT_ID(N'[equity].[daily]'))
ALTER TABLE [equity].[daily] CHECK CONSTRAINT [equity_ods.data.company.references]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity_ods.data.date.references]') AND parent_object_id = OBJECT_ID(N'[equity].[daily]'))
ALTER TABLE [equity].[daily]  WITH CHECK ADD  CONSTRAINT [equity_ods.data.date.references] FOREIGN KEY([date.id])
REFERENCES [equity].[date] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[equity].[equity_ods.data.date.references]') AND parent_object_id = OBJECT_ID(N'[equity].[daily]'))
ALTER TABLE [equity].[daily] CHECK CONSTRAINT [equity_ods.data.date.references]
GO
