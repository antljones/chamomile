use [equity_ods]

GO

/****** Object:  User [cdc]    Script Date: 10/6/2015 9:19:57 AM ******/
if not exists (select *
               from   sys.database_principals
               where  name = N'cdc')
  create user [cdc] WITHOUT LOGIN with DEFAULT_SCHEMA=[cdc]

GO

alter ROLE [db_owner] add MEMBER [cdc]

GO 
