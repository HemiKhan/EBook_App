USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_ItemDetail_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_ItemDetail_By_OrderID] (3251652,'ABDULLAH.ARSHAD',2,1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_ItemDetail_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([OrderID] int
, [Barcode] nvarchar(20)
, [ParentBarcode] nvarchar(20)
, [ItemID] int
, [ParentItemID] int
, [ItemToShip] nvarchar(50)
, [ItemCode] nvarchar(50)
, [Qty] int
, [ItemDescription] nvarchar(250)
, [ItemAssemblyTime] int
, [ClientRef1] nvarchar(50)
, [ClientRef2] nvarchar(50)
, [ClientRef3] nvarchar(50)
, [SKUNo] nvarchar(50)
, [PackingDetail] nvarchar(50)
, [PackingDetailNote] nvarchar(250)
, [ItemWeight] decimal(18,2)
, [WeightUnit] nvarchar(20)
, [Dimension] nvarchar(50)
, [DimensionUnit] nvarchar(20)
, [ItemCubes] decimal(18,2)
, [ItemValue] decimal(18,2)
, [LocationID] nvarchar(50)
, [DeliveryStatus] nvarchar(50)
, [LastScanTypeName] nvarchar(50)
, [LastScanDate] datetime
, [LastScanHub] nvarchar(20)
, [LastScanHubName] nvarchar(50)
, [ItemPickupStatus] nvarchar(50)
, [ItemDeliveryStatus] nvarchar(50)
, [WarehouseLocationStatus] nvarchar(50)
, [TotalRecords] int
)
AS
begin
	
	Declare @TotalRecords int = 0
	Declare @OrderJobcancelled bit = 0
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	Declare @OrderItemRelationTable table 
	([OrderNo] nvarchar(20) collate Latin1_General_100_CS_AS
	,[ItemID] int
	,[ItemTrackingNo] nvarchar(20) collate Latin1_General_100_CS_AS
	,[ParentItemID] int
	,[ParentItemTrackingNo] nvarchar(20) collate Latin1_General_100_CS_AS
	)
	insert into @OrderItemRelationTable ([OrderNo] ,[ItemID] ,[ItemTrackingNo] ,[ParentItemID] ,[ParentItemTrackingNo])
	SELECT [OrderNo] ,[ItemID] ,[ItemTrackingNo] ,[ParentItemID] ,[ParentItemTrackingNo] FROM [PinnacleProd].[dbo].[Metropolitan_Clone_OrderItemRelation] mcoir with (nolock)
	where mcoir.OrderNo = @ORDER_NO

	Declare @OrderItemScanTable table 
	([OrderNo] nvarchar(20) collate Latin1_General_100_CS_AS
	,BarcodeNo nvarchar(20) collate Latin1_General_100_CS_AS
	,[LastScanLocationID] nvarchar(20) collate Latin1_General_100_CS_AS
	,[LastScanType] int
	,[LastScanTypeName] nvarchar(50) collate Latin1_General_100_CS_AS
	,[LastScanDate] datetime
	,[LastScanHub] nvarchar(20) collate Latin1_General_100_CS_AS
	)
	insert into @OrderItemScanTable ([OrderNo] , BarcodeNo, [LastScanLocationID] ,[LastScanType] ,[LastScanTypeName] ,[LastScanDate] ,[LastScanHub])
	SELECT oid.[OrderNo] , oid.BarcodeNo, oid.[LastScanLocationID] ,oid.[LastScanType] 
	,[LastScanTypeName] = (select top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10150 and mtv.ID = oid.[LastScanType])
	,[LastScanDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oid.[LastScanDate], @TimeZone_ID, null, @TimeZoneName)
	,oid.[LastScanHub] 
	FROM [PinnacleProd].[dbo].[Metro_OrderItem_Data] oid with (nolock) where oid.OrderNo = @ORDER_NO

	if @GetRecordType_MTV_ID in (147103)
	begin
		select @TotalRecords = @TotalRecords + count(sll.[Sales Order No]) from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock)
		where sll.[Item Type] = 1 and sll.[Document Type] = 1 and sll.[Sales Order No] = @ORDER_NO

		insert into @ReturnTable ([OrderID] , [Barcode] , [ParentBarcode] , [ItemID] , [ParentItemID] , [ItemToShip] , [ItemCode] , [Qty] , [ItemDescription] , [ItemAssemblyTime] , [ClientRef1] , [ClientRef2] 
		, [ClientRef3] , [SKUNo] , [PackingDetail] , [PackingDetailNote] , [ItemWeight] , [WeightUnit] , [Dimension] , [DimensionUnit] , [ItemCubes] , [ItemValue] , [LocationID] , [DeliveryStatus] 
		, [LastScanTypeName] , [LastScanDate] , [LastScanHub] , [LastScanHubName] , [ItemPickupStatus] , [ItemDeliveryStatus] , [WarehouseLocationStatus] , [TotalRecords])
		select [ORDER_ID] = @ORDER_ID
			, [Barcode] = sll.[Item Tracking No]
			, [ParentBarcode] = oirt.[ParentItemTrackingNo]
			, [ItemID] =  sll.[ID]
			, [ParentItemID] = oirt.[ParentItemID]
			, [ItemToShip] = ''
			, [ItemCode] = (select top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Goods Type] gt with (nolock) where gt.[Good Type Code] = sll.[Item Code])
			, [Qty] = sll.[Item Quantity]
			, [ItemDescription] = sll.[Item Description]
			, [ItemAssemblyTime] = sll.[AssemblyTime]
			, [ClientRef1] = sll.[CustomField1]
			, [ClientRef2] = sll.[CustomField2]
			, [ClientRef3] = sll.[CustomField3]
			, [SKUNo] = sll.[Merchant SKU No]
			, [PackingDetail] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] ([POMS_DB].[dbo].[F_Get_Pinnacle_PackingCode] (sll.[Packed by Shipper],sll.[BlanketService],sll.[PackingRequired],sll.[Crate Required]))
			, [PackingDetailNote] = sll.PackageDetails
			, [ItemWeight] = sll.[Weight]
			, [WeightUnit] = 'LB'
			, [Dimension] = sll.[Dimensions] + ' ' + replace(sll.[Dimension Unit],'.','')
			, [DimensionUnit] = replace(sll.[Dimension Unit],'.','')
			, [ItemCubes] = sll.[Cu_Ft_]
			, [ItemValue] = sll.[Amount]
			, [LocationID] = oist.[LastScanLocationID]
			, [DeliveryStatus] = (case when @OrderJobcancelled = 1 then 'Manifest Cancelled' else [PinnacleProd].[dbo].[GetOrderItemDeliveryStatusByItemTrackingNumber](sll.[Sales Order No], sll.[Item Tracking No]) end)
			, [LastScanTypeName] = oist.[LastScanTypeName]
			, [LastScanDate] = oist.[LastScanDate]
			, [LastScanHub] = oist.[LastScanHub]
			, [LastScanHubName] = [POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (oist.[LastScanLocationID])
			, [ItemPickupStatus] = case sll.[Item Pickup Status] 
				when 0 then 'Pending'
				when 1 then 'Picked Up'
				when 2 then 'In-Transit'
				when 3 then 'In-Manifest'
				when 4 then 'Exception'
				else '' end
			, [ItemDeliveryStatus] = case sll.[Item Delivery Status]
				when 0 then 'Pending'
				when 1 then 'Delivered'
				when 2 then 'In-Transit'
				when 3 then 'In-Manifest'
				when 4 then 'Exception'
				else '' end
			, [WarehouseLocationStatus] = (select top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10370 and mtv.ID = sll.[WarehouseStatus])
			, [TotalRecords] = @TotalRecords
		from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock)
		left join @OrderItemRelationTable oirt on sll.[Item Tracking No] = oirt.[ItemTrackingNo] and sll.ID = oirt.[ItemID]
		left join @OrderItemScanTable oist on sll.[Item Tracking No] = oist.BarcodeNo 
		where sll.[Item Type] = 1 and sll.[Document Type] = 1 and sll.[Sales Order No] = @ORDER_NO
	end
	else if @GetRecordType_MTV_ID in (147104,147105)
	begin
		if @GetRecordType_MTV_ID in (147104)
		begin
			select @TotalRecords = @TotalRecords + count(sll.[Sales Order No]) from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock)
			where sll.[Item Type] = 1 and sll.[Document Type] = 1 and sll.[Sales Order No] = @ORDER_NO

			insert into @ReturnTable ([OrderID] , [Barcode] , [ParentBarcode] , [ItemID] , [ParentItemID] , [ItemToShip] , [ItemCode] , [Qty] , [ItemDescription] , [ItemAssemblyTime] , [ClientRef1] , [ClientRef2] 
			, [ClientRef3] , [SKUNo] , [PackingDetail] , [PackingDetailNote] , [ItemWeight] , [WeightUnit] , [Dimension] , [DimensionUnit] , [ItemCubes] , [ItemValue] , [LocationID] , [DeliveryStatus] 
			, [LastScanTypeName] , [LastScanDate] , [LastScanHub] , [LastScanHubName] , [ItemPickupStatus] , [ItemDeliveryStatus] , [WarehouseLocationStatus] , [TotalRecords])
			select [ORDER_ID] = @ORDER_ID
				, [Barcode] = sll.[Item Tracking No]
				, [ParentBarcode] = oirt.[ParentItemTrackingNo]
				, [ItemID] =  sll.[ID]
				, [ParentItemID] = oirt.[ParentItemID]
				, [ItemToShip] = ''
				, [ItemCode] = (select top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Goods Type] gt with (nolock) where gt.[Good Type Code] = sll.[Item Code])
				, [Qty] = sll.[Item Quantity]
				, [ItemDescription] = sll.[Item Description]
				, [ItemAssemblyTime] = sll.[AssemblyTime]
				, [ClientRef1] = sll.[CustomField1]
				, [ClientRef2] = sll.[CustomField2]
				, [ClientRef3] = sll.[CustomField3]
				, [SKUNo] = sll.[Merchant SKU No]
				, [PackingDetail] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] ([POMS_DB].[dbo].[F_Get_Pinnacle_PackingCode] (sll.[Packed by Shipper],sll.[BlanketService],sll.[PackingRequired],sll.[Crate Required]))
				, [PackingDetailNote] = sll.PackageDetails
				, [ItemWeight] = sll.[Weight]
				, [WeightUnit] = 'LB'
				, [Dimension] = sll.[Dimensions] + ' ' + replace(sll.[Dimension Unit],'.','')
				, [DimensionUnit] = replace(sll.[Dimension Unit],'.','')
				, [ItemCubes] = sll.[Cu_Ft_]
				, [ItemValue] = sll.[Amount]
				, [LocationID] = oist.[LastScanLocationID]
				, [DeliveryStatus] = (case when @OrderJobcancelled = 1 then 'Manifest Cancelled' else [PinnacleProd].[dbo].[GetOrderItemDeliveryStatusByItemTrackingNumber](sll.[Sales Order No], sll.[Item Tracking No]) end)
				, [LastScanTypeName] = oist.[LastScanTypeName]
				, [LastScanDate] = oist.[LastScanDate]
				, [LastScanHub] = oist.[LastScanHub]
				, [LastScanHubName] = [POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (oist.[LastScanLocationID])
				, [ItemPickupStatus] = case sll.[Item Pickup Status] 
					when 0 then 'Pending'
					when 1 then 'Picked Up'
					when 2 then 'In-Transit'
					when 3 then 'In-Manifest'
					when 4 then 'Exception'
					else '' end
				, [ItemDeliveryStatus] = case sll.[Item Delivery Status]
					when 0 then 'Pending'
					when 1 then 'Delivered'
					when 2 then 'In-Transit'
					when 3 then 'In-Manifest'
					when 4 then 'Exception'
					else '' end
				, [WarehouseLocationStatus] = (select top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10370 and mtv.ID = sll.[WarehouseStatus])
				, [TotalRecords] = @TotalRecords
			from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock)
			left join @OrderItemRelationTable oirt on sll.[Item Tracking No] = oirt.[ItemTrackingNo] and sll.ID = oirt.[ItemID]
			left join @OrderItemScanTable oist on sll.[Item Tracking No] = oist.BarcodeNo 
			where sll.[Item Type] = 1 and sll.[Document Type] = 1 and sll.[Sales Order No] = @ORDER_NO
		end

		select @TotalRecords = @TotalRecords + count(sll.[Sales Order No]) from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Line Link] sll with (nolock)
		where sll.[Item Type] = 1 and sll.[Document Type] = 1 and sll.[Sales Order No] = @ORDER_NO

		insert into @ReturnTable ([OrderID] , [Barcode] , [ParentBarcode] , [ItemID] , [ParentItemID] , [ItemToShip] , [ItemCode] , [Qty] , [ItemDescription] , [ItemAssemblyTime] , [ClientRef1] , [ClientRef2] 
		, [ClientRef3] , [SKUNo] , [PackingDetail] , [PackingDetailNote] , [ItemWeight] , [WeightUnit] , [Dimension] , [DimensionUnit] , [ItemCubes] , [ItemValue] , [LocationID] , [DeliveryStatus] 
		, [LastScanTypeName] , [LastScanDate] , [LastScanHub] , [LastScanHubName] , [ItemPickupStatus] , [ItemDeliveryStatus] , [WarehouseLocationStatus] , [TotalRecords])
		select [ORDER_ID] = @ORDER_ID
			, [Barcode] = sll.[Item Tracking No]
			, [ParentBarcode] = oirt.[ParentItemTrackingNo]
			, [ItemID] =  sll.[ID]
			, [ParentItemID] = oirt.[ParentItemID]
			, [ItemToShip] = ''
			, [ItemCode] = (select top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Goods Type] gt with (nolock) where gt.[Good Type Code] = sll.[Item Code])
			, [Qty] = sll.[Item Quantity]
			, [ItemDescription] = sll.[Item Description]
			, [ItemAssemblyTime] = sll.[AssemblyTime]
			, [ClientRef1] = sll.[CustomField1]
			, [ClientRef2] = sll.[CustomField2]
			, [ClientRef3] = sll.[CustomField3]
			, [SKUNo] = sll.[Merchant SKU No]
			, [PackingDetail] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] ([POMS_DB].[dbo].[F_Get_Pinnacle_PackingCode] (sll.[Packed by Shipper],sll.[BlanketService],sll.[PackingRequired],sll.[Crate Required]))
			, [PackingDetailNote] = sll.PackageDetails
			, [ItemWeight] = sll.[Weight]
			, [WeightUnit] = 'LB'
			, [Dimension] = sll.[Dimensions] + ' ' + replace(sll.[Dimension Unit],'.','')
			, [DimensionUnit] = replace(sll.[Dimension Unit],'.','')
			, [ItemCubes] = sll.[Cu_Ft_]
			, [ItemValue] = sll.[Amount]
			, [LocationID] = oist.[LastScanLocationID]
			, [DeliveryStatus] = (case when @OrderJobcancelled = 1 then 'Manifest Cancelled' else [PinnacleProd].[dbo].[GetOrderItemDeliveryStatusByItemTrackingNumber](sll.[Sales Order No], sll.[Item Tracking No]) end)
			, [LastScanTypeName] = oist.[LastScanTypeName]
			, [LastScanDate] = oist.[LastScanDate]
			, [LastScanHub] = oist.[LastScanHub]
			, [LastScanHubName] = [POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (oist.[LastScanLocationID])
			, [ItemPickupStatus] = case sll.[Item Pickup Status] 
				when 0 then 'Pending'
				when 1 then 'Picked Up'
				when 2 then 'In-Transit'
				when 3 then 'In-Manifest'
				when 4 then 'Exception'
				else '' end
			, [ItemDeliveryStatus] = case sll.[Item Delivery Status]
				when 0 then 'Pending'
				when 1 then 'Delivered'
				when 2 then 'In-Transit'
				when 3 then 'In-Manifest'
				when 4 then 'Exception'
				else '' end
			, [WarehouseLocationStatus] = (select top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10370 and mtv.ID = sll.[WarehouseStatus])
			, [TotalRecords] = @TotalRecords
		from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Line Link] sll with (nolock)
		left join @OrderItemRelationTable oirt on sll.[Item Tracking No] = oirt.[ItemTrackingNo] and sll.ID = oirt.[ItemID]
		left join @OrderItemScanTable oist on sll.[Item Tracking No] = oist.BarcodeNo 
		where sll.[Item Type] = 1 and sll.[Document Type] = 1 and sll.[Sales Order No] = @ORDER_NO
	end

	return
	

end
GO
