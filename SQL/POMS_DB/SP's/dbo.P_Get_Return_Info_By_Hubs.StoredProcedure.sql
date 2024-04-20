USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Return_Info_By_Hubs]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Declare @TotalCount int = 0 exec [dbo].[P_Get_Return_Info_By_Hubs] 'ABDULLAH', 0, 30, '', ' And cast([Created_On_Date] as date) between cast(''05/29/2023'' as date) and cast(''06/28/2023'' as date)  And cast([UTC_Created_On_Date] as date) between dateadd(day,-1,cast(''05/29/2023'' as date)) and dateadd(day,1,cast(''06/28/2023'' as date)) ', @TotalCount out, 1, '[{"fieldname":"Created_On_Date","fieldvalue":"","isfilterapply":true}]'
-- Declare @TotalCount int = 0 exec [dbo].[P_Get_Return_Info_By_Hubs] 'ABDULLAH', 0, 30, '', '   AND ( ClientID  like  ''%C100052%''  OR  ClientID like  ''%C100008%'' )  ' , @TotalCount out, 1, '[{"fieldname":"ClientID","fieldvalue":"","isfilterapply":true}]' select @TotalCount
-- Declare @TotalCount int = 0 exec [dbo].[P_Get_Return_Info_By_Hubs] 'ABDULLAH', 0, 30, '', '   ' , @TotalCount out, 1, '[{"fieldname":"Created_On_Date","fieldvalue":"","isfilterapply":true}]' select @TotalCount
-- ============================================='  
CREATE PROCEDURE [dbo].[P_Get_Return_Info_By_Hubs]   
 @Username nvarchar(150),
 @pageIndex int,  
 @pageSize int,  
 @sortExpression nvarchar(1000),  
 @filterClause nvarchar(max),  
 @totalRowCount int OUTPUT,
 @TimeZone int = 1,
 @filterobject nvarchar(max) = '',
 @columnobject nvarchar(max) = ''
  
AS  

BEGIN  
--IF(@filterClause = '' OR @filterClause = null)  
--  BEGIN SET @filterClause = ' AND 1=1' END  
  
 IF(@pageIndex = null)  
  BEGIN SET @pageIndex = 0 END  
  
 IF(@pageSize = null)  
  BEGIN SET @pageSize = 0 END  
   
Declare @SetTop int = 500
 set @SetTop = (@pageindex + 1) * @pagesize 
 if (@SetTop < 500)
	begin set @SetTop = 500 end

 if len(@sortExpression) = 0  
  set @sortExpression = ' UTC_Created_On_Date desc,ReturnOrderNo desc,Barcode asc '  
else
  set @sortExpression = @sortExpression --+ ' ,Barcode asc '  
 ---------------------------------------------------------     
 -- Your select sql goes here      
 ---------------------------------------------------------   
  
  drop table if exists #UserHubs
  select ID,Code,[Name] into #UserHubs from [PinnacleProd].[dbo].[F_Get_Hub_List_By_Username] (@Username,0)

  drop table if exists #Table_Hidden_Fields_Filter
  Create table #Table_Hidden_Fields_Filter (Code nvarchar(150) ,IsFilterApplied bit ,IsList bit ,[Value] nvarchar(1000) ,ListType int ,Logic nvarchar(50) ,[Type] nvarchar(50))
  insert into #Table_Hidden_Fields_Filter
  select Code,IsFilterApplied,IsList,[Value],ListType,Logic,[Type] from [POMS_DB].[dbo].[F_Get_Table_Hidden_Fields_Filter_2] (@filterobject)
  
  --hidefield=0, add this in column start this means ignore this fields while getting totalrowcount

  drop table if exists #TimeZone
  select tz.TZ_ID,SQL_TZ=tz.SQL_TZ collate Latin1_General_100_CS_AS,Hub_Code=h.Hub_Code collate Latin1_General_100_CS_AS  
  ,CurrentDateTime=cast(getutcdate() AT TIME ZONE 'UTC' AT TIME ZONE tz.SQL_TZ as datetime)
  into #TimeZone
  from [PPlus_DB].[dbo].[T_Time_Zone] tz with (nolock)
  inner join [PPlus_DB].[dbo].[T_Hub] h with (nolock) on tz.TZ_ID = h.TZ_ID

 Declare @selectSql nvarchar(max);  
    
 set @selectSql = N'select CountID
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'Created_On_Date') then '' else ',hidefield=0' end) + ',Created_On_Date
 ,UTC_Created_On_Date
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReturnOrderNo') then '' else ',hidefield=0' end) + ',ReturnOrderNo
 ,hidefield=0,OriginalOrderNo
 ,Barcode
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ClientID') then '' else ',hidefield=0' end) + ',ClientName
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ClientID') then '' else ',hidefield=0' end) + ',ClientID
 ,hidefield=0,SKU
 ,hidefield=0,ItemDescription
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code in ('OrigHub','PendingDays')) then '' else ',hidefield=0' end) + ',OrigHub
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'DestHub') then '' else ',hidefield=0' end) + ',DestHub
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'CurrentHub') then '' else ',hidefield=0' end) + ',CurrentHub
 ,hidefield=0,CurrentLocationID
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReasonForReturnID') then '' else ',hidefield=0' end) + ',ReasonForReturn
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code in ('OrderTypeID','ReasonForReturnID')) then '' else ',hidefield=0' end) + ',OrderTypeID
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'DispositionStatusID') then '' else ',hidefield=0' end) + ',DispositionStatus
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReasonForReturnID') then '' else ',hidefield=0' end) + ',ReasonForReturnID
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'DispositionStatusID') then '' else ',hidefield=0' end) + ',DispositionStatusID
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'PendingDays') then '' else ',hidefield=0' end) + ',PendingDays=(case when Created_On_Date = '''' then 0 else datediff(day,cast(Created_On_Date as date),cast(CurrentDateTime as date)) end)
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReturnStatusID') then '' else ',hidefield=0' end) + ',ReturnStatus
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReturnStatusID') then '' else ',hidefield=0' end) + ',ReturnStatusID
 from (
 Select CountID=1
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code in ('Created_On_Date','PendingDays')) then '' else ',hidefield=0' end) + ',Created_On_Date=isnull(CASE WHEN (Year(sh.[Create Time]) < 1950) THEN ''''  ELSE  format(cast(sh.[Create Time] AT TIME ZONE ''UTC'' AT TIME ZONE tz.SQL_TZ as datetime) ,''MM/dd/yyyy'')  END,'''')
 ,UTC_Created_On_Date=sh.[Create Time]
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReturnOrderNo') then '' else ',hidefield=0' end) + ',ReturnOrderNo=sh.No_
 ,hidefield=0,OriginalOrderNo=isnull(replace((select distinct [RelatedTicketID] + '','' + [TicketID] + '','' AS [text()] from [PinnacleProd].[dbo].[Metropolitan$RelatedTicketMap]    with(nolock) where ([TicketID] = sh.No_ or RelatedTicketID = sh.No_) For XML PATH ('''')),sh.No_ + '','',''''),'''')
 ,Barcode=sll.[Item Tracking No]
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ClientID') then '' else ',hidefield=0' end) + ',ClientName=isnull((Select top 1 [Name] from [PinnacleProd].[dbo].[Metropolitan$Customer] c with (nolock) where c.No_ = sh.[Bill-to Customer No_]),'''')
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ClientID') then '' else ',hidefield=0' end) + ',ClientID=sh.[Bill-to Customer No_]
 ,hidefield=0,SKU=sll.[Merchant SKU No]
 ,hidefield=0,ItemDescription=sll.[Item Description]
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code in ('OrigHub','PendingDays')) then '' else ',hidefield=0' end) + ',OrigHub=od.OrigHub
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'DestHub') then '' else ',hidefield=0' end) + ',DestHub=od.DestHub
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'CurrentHub') then '' else ',hidefield=0' end) + ',CurrentHub=(case when od.[FirstScanDate] is null then '''' else isnull((select top 1 moi.LastScanHub from [PinnacleProd].[dbo].[Metro_OrderItem_Data] moi with (nolock) where moi.[OrderNo] = sh.No_ and moi.BarcodeNo = sll.[Item Tracking No]),'''') end)
 ,hidefield=0,CurrentLocationID=(case when od.[FirstScanDate] is null then '''' else isnull((select top 1 moi.[LastScanLocationID] from [dbo].[Metro_OrderItem_Data] moi with (nolock) where moi.[OrderNo] = sh.No_ and moi.BarcodeNo = sll.[Item Tracking No]),'''') end)
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReasonForReturnID') then '' else ',hidefield=0' end) + ',ReasonForReturn=isnull((select sotv.[Name] from [PinnacleProd].[dbo].[T_Sub_Order_Type_Value] sotv with (nolock) where sotv.[Order_Type_ID] = sl.[OrderType] and sotv.[Sub_Order_Type_ID] = sl.[SubOrderType]), '''')
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'DispositionStatusID') then '' else ',hidefield=0' end) + ',DispositionStatus=isnull((select top 1 wul.[FullName] from [PinnacleProd].[dbo].[vw_Metro_WebUsers] wul with (nolock) where wul.[Username] = sl.[CSR Assign To]), '''')
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReasonForReturnID') then '' else ',hidefield=0' end) + ',ReasonForReturnID=isnull(sl.[SubOrderType],0)
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code in ('OrderTypeID','ReasonForReturnID')) then '' else ',hidefield=0' end) + ',OrderTypeID=isnull(sl.[OrderType],0)
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'DispositionStatusID') then '' else ',hidefield=0' end) + ',DispositionStatusID=isnull(sl.[CSR Assign To], '''')
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'PendingDays') then '' else ',hidefield=0' end) + ',PendingDays=0
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReturnStatusID') then '' else ',hidefield=0' end) + ',ReturnStatus=(case when upper(sl.[CSR Assign To]) in (''DISPOSITION'',''PENDINGCLAIMS'') then ''In Process'' else ''Processed'' end)
 ' + (case when exists(select Code from #Table_Hidden_Fields_Filter where IsFilterApplied = 1 and Code = 'ReturnStatusID') then '' else ',hidefield=0' end) + ',ReturnStatusID=(case when upper(sl.[CSR Assign To]) in (''DISPOSITION'',''PENDINGCLAIMS'') then 0 else 1 end)
 ,tz.CurrentDateTime
 From [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock)
 inner join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) on sh.No_ = sl.[Document No]
 inner join [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) on sh.No_ = od.OrderNo
 Inner Join [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock) on sh.No_ = sll.[Sales Order No]
 left join #TimeZone tz on tz.Hub_Code = od.OrigHub
 where 1 = 1 and sl.OrderType in (20000,30000) 
 and (od.OrigHub in (select Code from #UserHubs) or od.DestHub in (select Code from #UserHubs))
 and sh.[Order Status] = 10000 
 ) ilv where 1 = 1 
 '
 --isnull((select top 1 co.[ParentOrderNo] from [dbo].[Metropolitan_Clone_OrderRelation] co with(nolock) where co.[OrderNo] = sh.[No_]),'''')
 
 --select @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause

 exec [PinnacleProd].[dbo].[P_Metro_SP_CommonGetList] @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT   
  
END   

GO
