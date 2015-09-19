use [equity_ods];

set nocount on;

go

if object_id(N'[equity].[company]'
             , N'P') is not null
  drop procedure [equity].[company];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'equity', @object [sysname] = N'company';
	--
	-------------------------------------------------
	select N'[' + object_schema_name([extended_properties].[major_id]) +N'].['+
       case when Object_name([objects].[parent_object_id]) is not null 
			then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
			else Object_name([objects].[object_id]) +N']' + 
				case when [parameters].[parameter_id] > 0
					then coalesce(N'.['+[parameters].[name] + N']', N'') 
					else N'' 
				end +
				case when columnproperty ([objects].[object_id], [parameters].[name], N'IsOutParam') = 1  then N' output'
					else N''
				end
		end                                                                     as [object]
       ,case when [extended_properties].[minor_id]=0 then [objects].[type_desc]
			else N'PARAMETER'
        end                                                                     as [type]
		   ,[extended_properties].[name]                                        as [property]
		   ,[extended_properties].[value]                                       as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id]=[objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id]=[parameters].[object_id] and
					 [parameters].[parameter_id]=[extended_properties].[minor_id]
	where  [schemas].[name]=@schema and [objects].[name]=@object
	order  by [parameters].[parameter_id],[object],[type],[property]; 
*/
create procedure [equity].[company] @batch_size [int] = 1000000
as
  begin
      -- 
      declare @from_lsn     [binary](10) = [sys].fn_cdc_get_min_lsn('equity.company'),
              @to_lsn       [binary](10) = [sys].fn_cdc_get_max_lsn(),
              @sql          [nvarchar](max),
              @operation_01 [int],
              @operation_02 [int],
              @parameters   [nvarchar](max) = N'@from_lsn binary(10), @to_lsn binary(10), @operation_01 [int], @operation_02 [int], @batch_size [int]';

      -- 
      -- delete operation 
      ------------------------------------------------- 
      create table #cdc
        (
           [__$start_lsn]              [binary](10)
           , [__$seqval]               [binary](10)
           , [__$operation]            [int]
           , [__$update_mask]          [varbinary](128)
           , [equityid]                [int]
           , [adjustcopayamt]          [money]
           , [admitdate]               [datetime]
           , [admitdiagid]             [int]
           , [admitsourceid]           [int]
           , [admittypeid]             [int]
           , [approvedamt]             [money]
           , [approveddays]            [int]
           , [billeddrgmsid]           [int]
           , [billingareaid]           [int]
           , [billingtypeid]           [int]
           , [capitationindicator]     [varchar](10)
           , [equity]                  [varchar](20)
           , [equitystatusid]          [int]
           , [equitytype]              [varchar](255)
           , [cmsequityform]           [varchar](1)
           , [coinsuranceamt]          [money]
           , [copayamt]                [money]
           , [deductibleamt]           [money]
           , [dischargedate]           [datetime]
           , [dischargedispositionid]  [int]
           , [dischargetime]           [varchar](10)
           , [drgcalcid]               [int]
           , [drgmsid]                 [int]
           , [drgoutlier]              [char]
           , [drgoutlieramount]        [money]
           , [drgoutlierthreshold]     [money]
           , [orderphysicianid]        [int]
           , [otheramt]                [money]
           , [paiddate]                [datetime]
           , [patientid]               [int]
           , [placeofserviceid]        [int]
           , [referralid]              [numeric]
           , [refundamt]               [money]
           , [rejectamt]               [money]
           , [renderingproviderid]     [int]
           , [servicedate]             [datetime]
           , [servicefacilityaddress1] [varchar](100)
           , [servicefacilityaddress2] [varchar](100)
           , [servicefacilitycity]     [varchar](50)
           , [servicefacilityein]      [varchar](80)
           , [servicefacilityname]     [varchar](60)
           , [servicefacilitystate]    [varchar](20)
           , [servicefacilityzip]      [varchar](15)
           , [sumoflinebillamt]        [money]
           , [totalbilledamt]          [money]
           , [totaliabilityamt]        [money]
           , [totalpaidamt]            [money]
           , [vendorid]                [int]
           , [withholdamt]             [money]
        );

      -- 
      set @sql = N'insert into #cdc
						  ([__$start_lsn],
						   [__$seqval],
						   [__$operation],
						   [__$update_mask],
						   [adjustcopayamt],
						   [admitdate],
						   [admitdiagid],
						   [admitsourceid],
						   [admittypeid],
						   [approvedamt],
						   [approveddays],
						   [billeddrgmsid],
						   [billingareaid],
						   [billingtypeid],
						   [capitationindicator],
						   [equity],
						   [equityid],
						   [equitystatusid],
						   [equitytype],
						   [cmsequityform],
						   [coinsuranceamt],
						   [copayamt],
						   [deductibleamt],
						   [dischargedate],
						   [dischargedispositionid],
						   [dischargetime],
						   [drgcalcid],
						   [drgmsid],
						   [drgoutlier],
						   [drgoutlieramount],
						   [drgoutlierthreshold],
						   [orderphysicianid],
						   [otheramt],
						   [paiddate],
						   [patientid],
						   [placeofserviceid],
						   [referralid],
						   [refundamt],
						   [rejectamt],
						   [renderingproviderid],
						   [servicedate],
						   [servicefacilityaddress1],
						   [servicefacilityaddress2],
						   [servicefacilitycity],
						   [servicefacilityein],
						   [servicefacilityname],
						   [servicefacilitystate],
						   [servicefacilityzip],
						   [sumoflinebillamt],
						   [totalbilledamt],
						   [totaliabilityamt],
						   [totalpaidamt],
						   [vendorid],
						   [withholdamt])
			  select top(@batch_size) [__$start_lsn]
									  , [__$seqval]
									  , [__$operation]
									  , [__$update_mask]
									  , [adjustcopayamt]
									  , [admitdate]
									  , [admitdiagid]
									  , [admitsourceid]
									  , [admittypeid]
									  , [approvedamt]
									  , [approveddays]
									  , [billeddrgmsid]
									  , [billingareaid]
									  , [billingtypeid]
									  , [capitationindicator]
									  , [equity]
									  , [equityid]
									  , [equitystatusid]
									  , [equitytype]
									  , [cmsequityform]
									  , [coinsuranceamt]
									  , [copayamt]
									  , [deductibleamt]
									  , [dischargedate]
									  , [dischargedispositionid]
									  , [dischargetime]
									  , [drgcalcid]
									  , [drgmsid]
									  , [drgoutlier]
									  , [drgoutlieramount]
									  , [drgoutlierthreshold]
									  , [orderphysicianid]
									  , [otheramt]
									  , [paiddate]
									  , [patientid]
									  , [placeofserviceid]
									  , [referralid]
									  , [refundamt]
									  , [rejectamt]
									  , [renderingproviderid]
									  , [servicedate]
									  , [servicefacilityaddress1]
									  , [servicefacilityaddress2]
									  , [servicefacilitycity]
									  , [servicefacilityein]
									  , [servicefacilityname]
									  , [servicefacilitystate]
									  , [servicefacilityzip]
									  , [sumoflinebillamt]
									  , [totalbilledamt]
									  , [totaliabilityamt]
									  , [totalpaidamt]
									  , [vendorid]
									  , [withholdamt]
			  from   [cdc].[equity.company_ct]
			  where  [__$operation] = @operation_01
					  or [__$operation] = @operation_02
			  order  by [__$start_lsn]; 
			  '

      -- 
      -- delete operation 
      ------------------------------------------------- 
      truncate table #cdc;

      -- 
      select @operation_01 = 1
             , @operation_02 = 1
             , @from_lsn = [sys].fn_cdc_get_min_lsn('equity.company')
             , @to_lsn = [sys].fn_cdc_get_max_lsn();

      --     
      while (select count(*) as [delete_operations_remaining_in_change_table_after]
             from   [cdc].[equity.company_ct]
             where  [__$operation] = 1) > 0
        begin
            --  
            -- get next batch of records  
            -------------------------------------------   
            execute [sys].[sp_executesql]
              @sql = @sql,
              @parameters = @parameters,
              @batch_size = @batch_size,
              @from_lsn = @from_lsn,
              @to_lsn = @to_lsn,
              @operation_01 = @operation_01,
              @operation_02 = @operation_02;

            --  
            -- merge records from change table into target  
            -------------------------------------------   
            merge into [equity_ods].[equity].[company] as target
            using (select [equityid]
                   from   #cdc
                   where  [__$operation] = 1) as source
            on source.[equityid] = target.[equityid]
            when matched then
              delete;

            --  
            -- delete merged records from change table  
            -------------------------------------------   
            merge into [cdc].[equity.company_ct] as target
            using (select [__$start_lsn]
                          , [__$seqval]
                          , [__$operation]
                          , [__$update_mask]
                          , [equityid]
                   from   #cdc) as source
            on source.[__$start_lsn] = target.[__$start_lsn]
               and source.[__$seqval] = target.[__$seqval]
               and source.[__$operation] = target.[__$operation]
               and source.[__$update_mask] = target.[__$update_mask]
               and source.[equityid] = target.[equityid]
            when matched then
              delete;
        end;

      -- 
      -- insert operation 
      ------------------------------------------------- 
      truncate table #cdc;

      -- 
      select @operation_01 = 2
             , @operation_02 = 2
             , @from_lsn = [sys].fn_cdc_get_min_lsn('equity.company')
             , @to_lsn = [sys].fn_cdc_get_max_lsn();

      -- 
      while (select count(*)
             from   [cdc].[equity.company_ct]
             where  [__$operation] = 2) > 0
        begin
            execute [sys].[sp_executesql]
              @sql = @sql,
              @parameters = @parameters,
              @batch_size = @batch_size,
              @from_lsn = @from_lsn,
              @to_lsn = @to_lsn,
              @operation_01 = @operation_01,
              @operation_02 = @operation_02;

            --  
            merge into [equity_ods].[equity].[company] as target
            using (select [__$start_lsn]
                          , [__$seqval]
                          , [__$operation]
                          , [__$update_mask]
                          , [adjustcopayamt]
                          , [admitdate]
                          , [admitdiagid]
                          , [admitsourceid]
                          , [admittypeid]
                          , [approvedamt]
                          , [approveddays]
                          , [billeddrgmsid]
                          , [billingareaid]
                          , [billingtypeid]
                          , [capitationindicator]
                          , [equity]
                          , [equityid]
                          , [equitystatusid]
                          , [equitytype]
                          , [cmsequityform]
                          , [coinsuranceamt]
                          , [copayamt]
                          , [deductibleamt]
                          , [dischargedate]
                          , [dischargedispositionid]
                          , [dischargetime]
                          , [drgcalcid]
                          , [drgmsid]
                          , [drgoutlier]
                          , [drgoutlieramount]
                          , [drgoutlierthreshold]
                          , [orderphysicianid]
                          , [otheramt]
                          , [paiddate]
                          , [patientid]
                          , [placeofserviceid]
                          , [referralid]
                          , [refundamt]
                          , [rejectamt]
                          , [renderingproviderid]
                          , [servicedate]
                          , [servicefacilityaddress1]
                          , [servicefacilityaddress2]
                          , [servicefacilitycity]
                          , [servicefacilityein]
                          , [servicefacilityname]
                          , [servicefacilitystate]
                          , [servicefacilityzip]
                          , [sumoflinebillamt]
                          , [totalbilledamt]
                          , [totaliabilityamt]
                          , [totalpaidamt]
                          , [vendorid]
                          , [withholdamt]
                   from   #cdc
                   where  [__$operation] = 2) as source
            on source.[equityid] = target.[equityid]
            when not matched then
              insert ( [adjustcopayamt],
                       [admitdate],
                       [admitdiagid],
                       [admitsourceid],
                       [admittypeid],
                       [approvedamt],
                       [approveddays],
                       [billeddrgmsid],
                       [billingareaid],
                       [billingtypeid],
                       [capitationindicator],
                       [equity],
                       [equityid],
                       [equitystatusid],
                       [equitytype],
                       [cmsequityform],
                       [coinsuranceamt],
                       [copayamt],
                       [deductibleamt],
                       [dischargedate],
                       [dischargedispositionid],
                       [dischargetime],
                       [drgcalcid],
                       [drgmsid],
                       [drgoutlier],
                       [drgoutlieramount],
                       [drgoutlierthreshold],
                       [orderphysicianid],
                       [otheramt],
                       [paiddate],
                       [patientid],
                       [placeofserviceid],
                       [referralid],
                       [refundamt],
                       [rejectamt],
                       [renderingproviderid],
                       [servicedate],
                       [servicefacilityaddress1],
                       [servicefacilityaddress2],
                       [servicefacilitycity],
                       [servicefacilityein],
                       [servicefacilityname],
                       [servicefacilitystate],
                       [servicefacilityzip],
                       [sumoflinebillamt],
                       [totalbilledamt],
                       [totaliabilityamt],
                       [totalpaidamt],
                       [vendorid],
                       [withholdamt] )
              values ( [adjustcopayamt],
                       [admitdate],
                       [admitdiagid],
                       [admitsourceid],
                       [admittypeid],
                       [approvedamt],
                       [approveddays],
                       [billeddrgmsid],
                       [billingareaid],
                       [billingtypeid],
                       [capitationindicator],
                       [equity],
                       [equityid],
                       [equitystatusid],
                       [equitytype],
                       [cmsequityform],
                       [coinsuranceamt],
                       [copayamt],
                       [deductibleamt],
                       [dischargedate],
                       [dischargedispositionid],
                       [dischargetime],
                       [drgcalcid],
                       [drgmsid],
                       [drgoutlier],
                       [drgoutlieramount],
                       [drgoutlierthreshold],
                       [orderphysicianid],
                       [otheramt],
                       [paiddate],
                       [patientid],
                       [placeofserviceid],
                       [referralid],
                       [refundamt],
                       [rejectamt],
                       [renderingproviderid],
                       [servicedate],
                       [servicefacilityaddress1],
                       [servicefacilityaddress2],
                       [servicefacilitycity],
                       [servicefacilityein],
                       [servicefacilityname],
                       [servicefacilitystate],
                       [servicefacilityzip],
                       [sumoflinebillamt],
                       [totalbilledamt],
                       [totaliabilityamt],
                       [totalpaidamt],
                       [vendorid],
                       [withholdamt] );

            --  
            merge into [cdc].[equity.company_ct] as target
            using (select [__$start_lsn]
                          , [__$seqval]
                          , [__$operation]
                          , [__$update_mask]
                          , [equityid]
                   from   #cdc) as source
            on source.[__$start_lsn] = target.[__$start_lsn]
               and source.[__$seqval] = target.[__$seqval]
               and source.[__$operation] = target.[__$operation]
               and source.[__$update_mask] = target.[__$update_mask]
               and source.[equityid] = target.[equityid]
            when matched then
              delete;
        end;

      -- 
      -- update operation 
      ------------------------------------------------- 
      truncate table #cdc;

      -- 
      select @operation_01 = 3
             , @operation_02 = 4
             , @from_lsn = [sys].fn_cdc_get_min_lsn('equity.company')
             , @to_lsn = [sys].fn_cdc_get_max_lsn();

      -- 
      while (select count(*)
             from   [cdc].[equity.company_ct]
             where  [__$operation] = 3
                     or [__$operation] = 4) > 0
        begin
            execute [sys].[sp_executesql]
              @sql = @sql,
              @parameters = @parameters,
              @batch_size = @batch_size,
              @from_lsn = @from_lsn,
              @to_lsn = @to_lsn,
              @operation_01 = @operation_01,
              @operation_02 = @operation_02;

            --  
            merge into [equity_ods].[equity].[company] as target
            using (select [__$start_lsn]
                          , [__$seqval]
                          , [__$operation]
                          , [__$update_mask]
                          , [adjustcopayamt]
                          , [admitdate]
                          , [admitdiagid]
                          , [admitsourceid]
                          , [admittypeid]
                          , [approvedamt]
                          , [approveddays]
                          , [billeddrgmsid]
                          , [billingareaid]
                          , [billingtypeid]
                          , [capitationindicator]
                          , [equity]
                          , [equityid]
                          , [equitystatusid]
                          , [equitytype]
                          , [cmsequityform]
                          , [coinsuranceamt]
                          , [copayamt]
                          , [deductibleamt]
                          , [dischargedate]
                          , [dischargedispositionid]
                          , [dischargetime]
                          , [drgcalcid]
                          , [drgmsid]
                          , [drgoutlier]
                          , [drgoutlieramount]
                          , [drgoutlierthreshold]
                          , [orderphysicianid]
                          , [otheramt]
                          , [paiddate]
                          , [patientid]
                          , [placeofserviceid]
                          , [referralid]
                          , [refundamt]
                          , [rejectamt]
                          , [renderingproviderid]
                          , [servicedate]
                          , [servicefacilityaddress1]
                          , [servicefacilityaddress2]
                          , [servicefacilitycity]
                          , [servicefacilityein]
                          , [servicefacilityname]
                          , [servicefacilitystate]
                          , [servicefacilityzip]
                          , [sumoflinebillamt]
                          , [totalbilledamt]
                          , [totaliabilityamt]
                          , [totalpaidamt]
                          , [vendorid]
                          , [withholdamt]
                   from   #cdc
                   where  [__$operation] = 3
                           or [__$operation] = 4) as source
            on source.[equityid] = target.[equityid]
            when matched then
              update set target.[adjustcopayamt] = source.[adjustcopayamt],
                         target.[admitdate] = source.[admitdate],
                         target.[admitdiagid] = source.[admitdiagid],
                         target.[admitsourceid] = source.[admitsourceid],
                         target.[admittypeid] = source.[admittypeid],
                         target.[approvedamt] = source.[approvedamt],
                         target.[approveddays] = source.[approveddays],
                         target.[billeddrgmsid] = source.[billeddrgmsid],
                         target.[billingareaid] = source.[billingareaid],
                         target.[billingtypeid] = source.[billingtypeid],
                         target.[capitationindicator] = source.[capitationindicator],
                         target.[equity] = source.[equity],
                         target.[equityid] = source.[equityid],
                         target.[equitystatusid] = source.[equitystatusid],
                         target.[equitytype] = source.[equitytype],
                         target.[cmsequityform] = source.[cmsequityform],
                         target.[coinsuranceamt] = source.[coinsuranceamt],
                         target.[copayamt] = source.[copayamt],
                         target.[deductibleamt] = source.[deductibleamt],
                         target.[dischargedate] = source.[dischargedate],
                         target.[dischargedispositionid] = source.[dischargedispositionid],
                         target.[dischargetime] = source.[dischargetime],
                         target.[drgcalcid] = source.[drgcalcid],
                         target.[drgmsid] = source.[drgmsid],
                         target.[drgoutlier] = source.[drgoutlier],
                         target.[drgoutlieramount] = source.[drgoutlieramount],
                         target.[drgoutlierthreshold] = source.[drgoutlierthreshold],
                         target.[orderphysicianid] = source.[orderphysicianid],
                         target.[otheramt] = source.[otheramt],
                         target.[paiddate] = source.[paiddate],
                         target.[patientid] = source.[patientid],
                         target.[placeofserviceid] = source.[placeofserviceid],
                         target.[referralid] = source.[referralid],
                         target.[refundamt] = source.[refundamt],
                         target.[rejectamt] = source.[rejectamt],
                         target.[renderingproviderid] = source.[renderingproviderid],
                         target.[servicedate] = source.[servicedate],
                         target.[servicefacilityaddress1] = source.[servicefacilityaddress1],
                         target.[servicefacilityaddress2] = source.[servicefacilityaddress2],
                         target.[servicefacilitycity] = source.[servicefacilitycity],
                         target.[servicefacilityein] = source.[servicefacilityein],
                         target.[servicefacilityname] = source.[servicefacilityname],
                         target.[servicefacilitystate] = source.[servicefacilitystate],
                         target.[servicefacilityzip] = source.[servicefacilityzip],
                         target.[sumoflinebillamt] = source.[sumoflinebillamt],
                         target.[totalbilledamt] = source.[totalbilledamt],
                         target.[totaliabilityamt] = source.[totaliabilityamt],
                         target.[totalpaidamt] = source.[totalpaidamt],
                         target.[vendorid] = source.[vendorid],
                         target.[withholdamt] = source.[withholdamt];

            --  
            merge into [cdc].[equity.company_ct] as target
            using (select [__$start_lsn]
                          , [__$seqval]
                          , [__$operation]
                          , [__$update_mask]
                          , [equityid]
                   from   #cdc) as source
            on source.[__$start_lsn] = target.[__$start_lsn]
               and source.[__$seqval] = target.[__$seqval]
               and source.[__$operation] = target.[__$operation]
               and source.[__$update_mask] = target.[__$update_mask]
               and source.[equityid] = target.[equityid]
            when matched then
              delete;
        end;
  end;

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'equity'
                                          , N'procedure'
                                          , N'company'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'equity',
    @level1type = N'procedure',
    @level1name = N'company';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Incremental refresh procedure for [equity_dw].[equity].[company] (as target). Mines the change table for [equity_ods].[equity].[company] (as source) incrementally based on the value of @batch_size. Changes are applied to target then deleted from the change table. 1) Delete records are pulled and matching records are deleted in target. 2) Insert records are pulled then inserted into target. 3) Update records are pulled then updated in target.',
  @level0type = N'schema',
  @level0name = N'equity',
  @level1type = N'procedure',
  @level1name = N'company';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150826'
                                          , N'schema'
                                          , N'equity'
                                          , N'procedure'
                                          , N'company'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20150826',
    @level0type = N'schema',
    @level0name = N'equity',
    @level1type = N'procedure',
    @level1name = N'company';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20150826',
  @value = N'KLightsey@hcpnv.com – created.',
  @level0type = N'schema',
  @level0name = N'equity',
  @level1type = N'procedure',
  @level1name = N'company';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_cdc'
                                          , N'schema'
                                          , N'equity'
                                          , N'procedure'
                                          , N'company'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_cdc',
    @level0type = N'schema',
    @level0name = N'equity',
    @level1type = N'procedure',
    @level1name = N'company';

go

exec sys.sp_addextendedproperty
  @name = N'package_cdc',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'equity',
  @level1type = N'procedure',
  @level1name = N'company';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'equity'
                                          , N'procedure'
                                          , N'company'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'equity',
    @level1type = N'procedure',
    @level1name = N'company';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'  
	-- accept default for @batch_size
	execute [equity].[company];
	-- set @batch_size to 10,000 records
	execute [equity].[company] @batch_size = 10000;',
  @level0type = N'schema',
  @level0name = N'equity',
  @level1type = N'procedure',
  @level1name = N'company';

go 
