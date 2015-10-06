USE [equity_dw]
GO
/****** Object:  Table [equity_dimension].[date]    Script Date: 10/6/2015 9:35:18 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_dimension].[date]') AND type in (N'U'))
DROP TABLE [equity_dimension].[date]
GO
/****** Object:  Table [equity_dimension].[date]    Script Date: 10/6/2015 9:35:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity_dimension].[date]') AND type in (N'U'))
BEGIN
CREATE TABLE [equity_dimension].[date](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[datetimeoffset] [datetimeoffset](7) NULL CONSTRAINT [date.dimension.datetimeoffset.default]  DEFAULT (getdate()),
	[date]  AS (CONVERT([date],[datetimeoffset])),
	[day]  AS (datepart(day,[datetimeoffset])),
	[week]  AS (datepart(week,[datetimeoffset])),
	[quarter]  AS (datepart(quarter,[datetimeoffset])),
	[year]  AS (datepart(year,[datetimeoffset])),
	[day_of_year]  AS (datepart(dayofyear,[datetimeoffset])),
 CONSTRAINT [date.dimension.id.primary_key_clustered] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
ALTER AUTHORIZATION ON [equity_dimension].[date] TO  SCHEMA OWNER 
GO
