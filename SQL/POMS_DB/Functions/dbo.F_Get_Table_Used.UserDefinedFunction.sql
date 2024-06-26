USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Used]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Table_Used] 
(	
	@FilterObject nvarchar(max) = '',
	@ColumnObject nvarchar(max) = ''
)
RETURNS @ReturnTable TABLE 
(IsUsed bit, TableName nvarchar(100))
AS
begin
	
	Declare @Table_Fields_Filter table (Code nvarchar(150) ,Name_ nvarchar(150) ,IsFilterApplied bit)
	insert into @Table_Fields_Filter (Code ,Name_ ,IsFilterApplied )
	select [Code],[Name],[IsFilterApplied] from [POMS_DB].[dbo].[F_Get_Table_Fields_Filter] (@FilterObject)
  
	Declare @Table_Fields_Column table (Code nvarchar(150) ,Name_ nvarchar(150) ,IsColumnRequired bit)
	insert into @Table_Fields_Column (Code ,Name_ ,IsColumnRequired )
	select [Code],[Name],[IsColumnRequired] from [POMS_DB].[dbo].[F_Get_Table_Fields_Column] (@ColumnObject)
	
	Declare @T_Order_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('ActualDeliveryDate,ActualPickupDate,BillingType_MTV_CODE,BillTo_Address,BillTo_ADDRESS_CODE,BillTo_Address2,BillTo_City,BillTo_Company,BillTo_ContactPerson,BillTo_CountryRegionCode,BillTo_County,BillTo_CUSTOMER_NO,BillTo_Email,BillTo_FirstName,BillTo_LastName,BillTo_MiddleName,BillTo_Mobile,BillTo_Phone,BillTo_PhoneExt,BillTo_State,BillTo_ZipCode,BillToSub_CUSTOMER_NO,Carrier_MTV_CODE,ConfirmedDeliveryTimeFrame_TFL_ID,ConfirmedPickupTimeFrame_TFL_ID,Delivery_OG_ID,DELIVERY_SST_CODE,DELIVERY_ST_CODE,DeliveryScheduleType_MTV_ID,DlvSchByUserName,FirstOffered_DeliveryDate,FirstOffered_PickupDate,InsuranceRequired,IsBlindShipTo,LiveShipFrom_HUB_CODE,LiveShipTo_HUB_CODE,ORDER_CODE,ORDER_CODE_GUID,ORDER_ID,OrderPriority_MTV_ID,OrderSource_MTV_ID,OrderStatus_MTV_ID,OrderSubSource_MTV_CODE,OrderSubSourceFileName,PARENT_ORDER_ID,PaymentStatus_MTV_ID,Pickup_OG_ID,PICKUP_SST_CODE,PICKUP_ST_CODE,PickupScheduleType_MTV_ID,PkpSchByUserName,PromisedDeliveryDate,PromisedPickupDate,QuoteAmount,QuoteID,ReqDelivery_Date,ReqDelivery_FromTime,ReqDelivery_ToTime,ReqDeliveryTimeFrame_TFL_ID,ReqPickup_Date,ReqPickup_FromTime,ReqPickup_ToTime,ReqPickupTimeFrame_TFL_ID,SELLER_CODE,SELLER_PARTNER_CODE,ShipFrom_Address,ShipFrom_ADDRESS_CODE,ShipFrom_Address2,ShipFrom_AreaType_MTV_ID,ShipFrom_ChangeCount,ShipFrom_City,ShipFrom_Company,ShipFrom_ContactPerson,ShipFrom_CountryRegionCode,ShipFrom_County,ShipFrom_Email,ShipFrom_FirstName,ShipFrom_HUB_CODE,ShipFrom_LastName,ShipFrom_Lat,ShipFrom_Lng,ShipFrom_MiddleName,ShipFrom_Mobile,ShipFrom_Phone,ShipFrom_PhoneExt,ShipFrom_PlaceID,ShipFrom_State,ShipFrom_ZipCode,ShipFrom_ZONE_CODE,ShipmentRegDate,ShippingStatus_EVENT_ID,ShipTo_Address,ShipTo_ADDRESS_CODE,ShipTo_Address2,ShipTo_AreaType_MTV_ID,ShipTo_ChangeCount,ShipTo_City,ShipTo_Company,ShipTo_ContactPerson,ShipTo_CountryRegionCode,ShipTo_County,ShipTo_Email,ShipTo_FirstName,ShipTo_HUB_CODE,ShipTo_LastName,ShipTo_Lat,ShipTo_Lng,ShipTo_MiddleName,ShipTo_Mobile,ShipTo_Phone,ShipTo_PhoneExt,ShipTo_PlaceID,ShipTo_State,ShipTo_ZipCode,ShipTo_ZONE_CODE,SUB_SELLER_CODE,TARIFF_NO,TRACKING_NO')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order')
	end

	Declare @T_Order_Additional_Info_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Additional_Info_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('DlvAttemptCount,FirstFileMileFRBMDate,FirstFileMileFRBMHub,FirstFRBMDate,FirstFRBMHub,FirstScanDate,FirstScanHub,IsIndexUpdated,IsInvoiceProcessed,IsPhoneUpdated,IsPPJobDone,LastScanDate,LastScanHub,LastScanLocationID,LastViewedByUserName,LastViewedDate,OriginDepartureDate,ReSchCount,Revenue,RevenueWithCM,ShipToHub_FirstScanDate,ShipToZone_FirstScanDate')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Additional_Info_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Additional_Info_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Additional_Info')
	end

	Declare @T_Order_Archive_Detail_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Archive_Detail_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('Order_Access_Log_ArchiveDate,Order_Additional_Info_ArchiveDate,Order_ArchiveDate,Order_Audit_History_ArchiveDate,Order_Client_Identifier_ArchiveDate,Order_Comments_ArchiveDate,Order_Detail_ArchiveDate,Order_Docs_ArchiveDate,Order_Events_ArchiveDate,Order_Events_List_ArchiveDate,Order_Item_Scans_ArchiveDate,Order_Items_Additional_Info_ArchiveDate,Order_Items_ArchiveDate,Order_Related_Tickets_ArchiveDate,Order_Special_Instruction_ArchiveDate,Order_Special_Service_ArchiveDate')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Archive_Detail_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Archive_Detail_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Archive_Detail')
	end

	Declare @T_Order_Comments_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Comments_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('Comment,ImportanceLevel_MTV_ID,IsActive,IsCall,IsPublic,OC_ID,ORDER_ID,OrderStatus_MTV_ID,ShippingStatus_EVENT_ID')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Comments_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Comments_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Comments')
	end

	Declare @V_Order_Client_Identifier_Tlb_Fields table (id nvarchar(50))
	insert into  @V_Order_Client_Identifier_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('CARRIER,PONUMBER,PRO,REF2,TAG,COSTCO')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @V_Order_Client_Identifier_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @V_Order_Client_Identifier_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'V_Order_Client_Identifier')
	end

	Declare @T_Order_Client_Identifier_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Client_Identifier_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('OIF_CODE,Value_')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Client_Identifier_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Client_Identifier_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Client_Identifier')
	end

	Declare @T_Order_Events_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Events_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('EVENT_ID,HUB_CODE,IsAuto,Source_MTV_ID,TriggerDate_')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Events_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Events_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Events')
	end

	Declare @T_Order_Invoice_Header_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Invoice_Header_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('Amount,ApprovalValue_MTV_ID,BLDimension_MTV_CODE,CMAmount,DimensionID,DocumentDate,DocumentType_MTV_ID,DueDate,EDIStatus_MTV_ID,EstimateID,EstimateNo,InvoiceStatus_MTV_ID,LastPaymentDate,NeedEDI_MTV_ID,PaidAmount,PaymentTermsCode,POCustRefNo,PostedInvoiceNo,PostedOnDatetime,PostingDate,QBInvoiceNo,RECTXT,SLDimension_SL_CODE,UnpostedInvoiceNo,UnpostedOnDatetime,UpdateWRDimensionType_MTV_ID,WRDimension_HUB_CODE')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Invoice_Header_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Invoice_Header_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Invoice_Header')
	end

	Declare @T_Order_Invoice_Line_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Invoice_Line_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('BLDimension_MTV_CODE_Line,Description,DimensionID_Line,GL_NO,GoodsType,InvoiceLineType,ItemsCuFt,ItemsQty,ItemsValue,ItemsWeight,LineAmount,LineNo_,OIL_ID,Quantity,SalesLineType,SLDimension_SL_CODE_Line,UnitPrice,UpdateWRDimensionType_MTV_ID_Line,WRDimension_HUB_CODE_Line')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Invoice_Line_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Invoice_Line_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Invoice_Line')
	end

	Declare @T_Order_Items_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Items_Tlb_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('ItemValue,AssemblyTime,BARCODE,Cu_Ft_,Dimensions,DimensionUnit_MTV_CODE,ItemClientRef1,ItemClientRef2,ItemClientRef3,ItemCode_MTV_CODE,ItemDeliveryStatus_MTV_ID,ItemDescription,ItemHeight,ItemLength,ItemPickupStatus_MTV_ID,ItemToShip_MTV_CODE,ItemWeight,ItemWidth,ItemLineNo_,OI_ID,PackageDetailsNote,PackingCode_MTV_CODE,PARENT_OI_ID,ItemQuantity,RelabelCount,SKU_NO,Weight,WeightUnit_MTV_CODE')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Items_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Items_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Items')
	end

	Declare @T_Order_Items_Additional_Info_Fields table (id nvarchar(50))
	insert into  @T_Order_Items_Additional_Info_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('OIAI_BARCODE,OIAI_FirstScanDate,OIAI_FirstScanHub,OIAI_FirstScanType_MTV_ID,OIAI_IsActive,OIAI_IsDamaged,OIAI_LastScanDate,OIAI_LastScanHub,OIAI_LastScanLocationID,OIAI_LastScanType_MTV_ID,OIAI_ShipToHub_FirstScanDate,OIAI_ShipToZone_FirstScanDate,OIAI_WarehouseStatus_MTV_ID')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Items_Additional_Info_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Items_Additional_Info_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Items_Additional_Info')
	end

	Declare @T_Order_Item_Scans_Info_Fields table (id nvarchar(50))
	insert into  @T_Order_Item_Scans_Info_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('AutoScan,OIS_BARCODE,DamageNote,DeviceCode_MTV_CODE,ErrorMsg,OIS_HUB_CODE,ImageCount,OIS_IsActive,IsDamage,IsError,IsRelabelRequired,Lat,Lng,LOCATION_ID,MANIFEST_ID,ManifestType_MTV_ID,OI_GUID,OIS_ID,ScanAnytime,ScanBy,ScanTime,ScanType_MTV_ID')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Item_Scans_Info_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Item_Scans_Info_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Item_Scans')
	end

	Declare @T_Order_Item_Scans_Damage_Info_Fields table (id nvarchar(50))
	insert into  @T_Order_Item_Scans_Damage_Info_Fields (id)
	select id from [POMS_DB].[dbo].[SplitIntoTable] ('Damage_MTV_ID')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Item_Scans_Damage_Info_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Item_Scans_Damage_Info_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Item_Scans_Damage')
	end

	return

end
GO
