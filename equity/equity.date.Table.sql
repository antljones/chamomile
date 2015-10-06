USE [equity_ods]
GO
/****** Object:  Table [equity].[date]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity].[date]') AND type in (N'U'))
DROP TABLE [equity].[date]
GO
/****** Object:  Table [equity].[date]    Script Date: 10/6/2015 9:39:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity].[date]') AND type in (N'U'))
BEGIN
CREATE TABLE [equity].[date](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[datetimeoffset] [datetimeoffset](7) NULL CONSTRAINT [date.dimension.datetimeoffset.default]  DEFAULT (getdate()),
 CONSTRAINT [date.dimension.id.primary_key_clustered] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
ALTER AUTHORIZATION ON [equity].[date] TO  SCHEMA OWNER 
GO
