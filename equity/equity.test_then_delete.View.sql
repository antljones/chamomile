USE [equity_dw]
GO
/****** Object:  View [equity].[test_then_delete]    Script Date: 10/6/2015 9:35:18 AM ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[equity].[test_then_delete]'))
DROP VIEW [equity].[test_then_delete]
GO
/****** Object:  View [equity].[test_then_delete]    Script Date: 10/6/2015 9:35:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[equity].[test_then_delete]'))
EXEC dbo.sp_executesql @statement = N'create view [equity].[test_then_delete] as
select top 1000 [equity.data].[id]                                  as [equity.data.id]
                , [symbol].[symbol]                                 as [symbol]
                , [symbol].[name]                                   as [company]
                , [exchange].[name]                                 as [exchange]
                , [industry].[name]                                 as [industry]
                , [sector].[name]                                   as [sector]
                , cast([date.dimension].[datetimeoffset] as [date]) as [date]
                , [close]                                           as [close]
                , [volume]                                          as [volume]
                , [open]                                            as [open]
                , [high]                                            as [high]
                , [low]                                             as [low]
from   [equity_ods].[equity].[data] as [equity.data]
       join [equity_ods].[equity].[symbol] as [symbol]
         on [symbol].[id] = [equity.data].[symbol]
       join [date].[dimension] as [date.dimension]
         on [date.dimension].[id] = [equity.data].[date]
       join [equity_ods].[equity].[exchange] as [exchange]
         on [exchange].[id] = [symbol].[exchange]
       join [equity_ods].[equity].[industry] as [industry]
         on [industry].[id] = [symbol].[industry]
       join [equity_ods].[equity].[sector] as [sector]
         on [sector].[id] = [symbol].[sector]; 
' 
GO
ALTER AUTHORIZATION ON [equity].[test_then_delete] TO  SCHEMA OWNER 
GO
