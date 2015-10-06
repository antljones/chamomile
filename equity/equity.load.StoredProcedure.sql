USE [equity_ods]
GO
/****** Object:  StoredProcedure [equity].[load]    Script Date: 10/6/2015 9:39:57 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity].[load]') AND type in (N'P', N'PC'))
DROP PROCEDURE [equity].[load]
GO
/****** Object:  StoredProcedure [equity].[load]    Script Date: 10/6/2015 9:39:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[equity].[load]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [equity].[load] AS' 
END
GO

/*
	-- 7,598,799
	select count(*) from [equity_staging].[data];
	-- 
	select count(*) from [equity].[data];

    truncate table [equity].[data];

	execute [equity].[load];

	rollback
*/
ALTER procedure [equity].[load]
as
  begin
      set nocount on;
      set transaction isolation level read uncommitted;

      declare @symbol             [sysname],
              @transaction_prefix [sysname] = N'equity_load_',
              @transaction        [nvarchar](32);

      --
      -- delete header rows
      -- Symbol	Date	Open	High	Low	Close	Volume
      ----------------------------------------------
      delete from [equity_staging].[data]
      where  isnumeric([close]) = 0
              or isdate([date]) = 0;

      --
	  -- delete duplicate records in staging data
      ----------------------------------------------
      with [duplicate_finder]
           as (select [symbol]                                                 as [symbol],
                      cast([date] as [date])                                   as [date],
                      row_number()
                        over (
                          partition by [symbol], cast([date] as [date])
                          order by [symbol] desc, cast([date] as [date]) desc) as [sequence]
               from   [equity_staging].[data])
      delete from [duplicate_finder]
      where  [sequence] > 1;

      --
      declare [load_by_symbol] cursor for
        select distinct [symbol]
        from   [equity_staging].[data]
        order  by [symbol];

      open [load_by_symbol];

      fetch next from [load_by_symbol] into @symbol;
	  
      while @@fetch_status = 0
        begin
            set @transaction = @transaction_prefix + @symbol;

            if @@trancount = 0
              begin transaction @transaction;

            begin try
                merge into [equity].[data] as target
                using (select [symbol],
                              [close],
                              [volume],
                              [open],
                              [high],
                              [low],
                              cast([date] as [date]) as [date]
                       from   [equity_staging].[data]
                       where  [symbol] = @symbol) as source([symbol], [close], [volume], [open], [high], [low], [date])
                on target.[symbol] = source.[symbol]
                   and target.[date] = source.[date]
                when not matched then
                  insert ([symbol],
                          [close],
                          [volume],
                          [open],
                          [high],
                          [low],
                          [date])
                  values ([symbol],
                          [close],
                          [volume],
                          [open],
                          [high],
                          [low],
                          [date]);

                if (select count(*)
                    from   [sys].[dm_tran_active_transactions]
                    where  [name] = @transaction) = 1
                   and xact_state() = 1
                  commit transaction @transaction;
                else
                  rollback transaction @transaction;
            --select N'successfully loaded symbol: ' + @symbol;
            end try

            begin catch
                select N'failed loading symbol: ' + @symbol,
                       error_message() as N'error_message';

                rollback transaction @transaction;
            end catch;

            fetch next from [load_by_symbol] into @symbol;
        end;

      close [load_by_symbol];

      deallocate [load_by_symbol];
  end;


GO
ALTER AUTHORIZATION ON [equity].[load] TO  SCHEMA OWNER 
GO
ALTER AUTHORIZATION ON [equity].[load] TO  SCHEMA OWNER 
GO
