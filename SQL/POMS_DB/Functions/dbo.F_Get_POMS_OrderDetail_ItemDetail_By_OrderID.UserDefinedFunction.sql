USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_ItemDetail_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_ItemDetail_By_OrderID] (10100656,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_ItemDetail_By_OrderID]
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
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @OrderItemScanTable table 
	(ORDER_ID int
	,BARCODE nvarchar(20)
	,LastScanDate datetime
	,LastScanHub nvarchar(20)
	,LastScanHubName nvarchar(50)
	,[LastScanLocationID] nvarchar(20)
	,LastScanType nvarchar(50)
	,WarehouseStatus nvarchar(50)
	)
	if @GetRecordType_MTV_ID in (147100)
	begin
		select @TotalRecords = @TotalRecords + count(oi.[OI_ID]) from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.[ORDER_ID] = @ORDER_ID

		insert into @OrderItemScanTable (ORDER_ID ,BARCODE ,LastScanDate ,LastScanHub ,LastScanHubName ,[LastScanLocationID] ,LastScanType ,WarehouseStatus)
		SELECT ORDER_ID ,BARCODE 
		,LastScanDate = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odai.LastScanDate, @TimeZone_ID, null, @TimeZoneName)
		,LastScanHub 
		,LastScanHubName = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (odai.LastScanHub)
		,[LastScanLocationID] 
		,LastScanType = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odai.LastScanType_MTV_ID)
		,WarehouseStatus = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odai.WarehouseStatus_MTV_ID)
		FROM [POMS_DB].[dbo].[T_Order_Items_Additional_Info] odai with (nolock) where odai.ORDER_ID = @ORDER_ID

		insert into @ReturnTable ([OrderID] , [Barcode] , [ParentBarcode] , [ItemID] , [ParentItemID] , [ItemToShip] , [ItemCode] , [Qty] , [ItemDescription] , [ItemAssemblyTime] , [ClientRef1] , [ClientRef2] 
		, [ClientRef3] , [SKUNo] , [PackingDetail] , [PackingDetailNote] , [ItemWeight] , [WeightUnit] , [Dimension] , [DimensionUnit] , [ItemCubes] , [ItemValue] , [LocationID] , [DeliveryStatus] 
		, [LastScanTypeName] , [LastScanDate] , [LastScanHub] , [LastScanHubName] , [ItemPickupStatus] , [ItemDeliveryStatus] , [WarehouseLocationStatus] , [TotalRecords])
		select [ORDER_ID] = oi.ORDER_ID
			, [Barcode] = oi.BARCODE
			, [ParentBarcode] = gpbobi.Barcode
			, [ItemID] = oi.OI_ID
			, [ParentItemID] = oi.PARENT_OI_ID
			, [ItemToShip] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (oi.ItemToShip_MTV_CODE)
			, [ItemCode] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (oi.ItemCode_MTV_CODE)
			, [Qty] = oi.Quantity
			, [ItemDescription] = oi.ItemDescription
			, [ItemAssemblyTime] = oi.AssemblyTime
			, [ClientRef1] = oi.ItemClientRef1
			, [ClientRef2] = oi.ItemClientRef2
			, [ClientRef3] = oi.ItemClientRef3
			, [SKUNo] = oi.SKU_NO
			, [PackingDetail] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (oi.PackingCode_MTV_CODE)
			, [PackingDetailNote] = oi.PackageDetailsNote
			, [ItemWeight] = oi.ItemWeight
			, [WeightUnit] = oi.WeightUnit_MTV_CODE
			, [Dimension] = oi.Dimensions
			, [DimensionUnit] = oi.DimensionUnit_MTV_CODE
			, [ItemCubes] = oi.Cu_Ft_
			, [ItemValue] = oi.Amount
			, [LocationID] = oist.[LastScanLocationID]
			, [DeliveryStatus] = '' --Need to Work On
			, [LastScanTypeName] = oist.LastScanType
			, [LastScanDate] = oist.LastScanDate
			, [LastScanHub] = oist.LastScanHub
			, [LastScanHubName] = oist.LastScanHubName
			, [ItemPickupStatus] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oi.ItemPickupStatus_MTV_ID)
			, [ItemDeliveryStatus] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oi.ItemDeliveryStatus_MTV_ID)
			, [WarehouseLocationStatus] = oist.WarehouseStatus
			, [TotalRecords] = @TotalRecords
		from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock)
		left join @OrderItemScanTable oist on oi.BARCODE = oist.BARCODE 
		outer apply [POMS_DB].[dbo].[F_Get_Parent_Barcode_OrderID_By_ItemID] (oi.PARENT_OI_ID) gpbobi
		where oi.[ORDER_ID] = @ORDER_ID
	end
	else if @GetRecordType_MTV_ID in (147101,147102)
	begin
		if @GetRecordType_MTV_ID in (147101)
		begin
			select @TotalRecords = @TotalRecords + count(oi.[OI_ID]) from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.[ORDER_ID] = @ORDER_ID

			insert into @OrderItemScanTable (ORDER_ID ,BARCODE ,LastScanDate ,LastScanHub ,LastScanHubName ,[LastScanLocationID] ,LastScanType ,WarehouseStatus)
			SELECT ORDER_ID ,BARCODE 
			,LastScanDate = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odai.LastScanDate, @TimeZone_ID, null, @TimeZoneName)
			,LastScanHub 
			,LastScanHubName = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (odai.LastScanHub)
			,[LastScanLocationID] 
			,LastScanType = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odai.LastScanType_MTV_ID)
			,WarehouseStatus = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odai.WarehouseStatus_MTV_ID)
			FROM [POMS_DB].[dbo].[T_Order_Items_Additional_Info] odai with (nolock) where odai.ORDER_ID = @ORDER_ID

			insert into @ReturnTable ([OrderID] , [Barcode] , [ParentBarcode] , [ItemID] , [ParentItemID] , [ItemToShip] , [ItemCode] , [Qty] , [ItemDescription] , [ItemAssemblyTime] , [ClientRef1] , [ClientRef2] 
			, [ClientRef3] , [SKUNo] , [PackingDetail] , [PackingDetailNote] , [ItemWeight] , [WeightUnit] , [Dimension] , [DimensionUnit] , [ItemCubes] , [ItemValue] , [LocationID] , [DeliveryStatus] 
			, [LastScanTypeName] , [LastScanDate] , [LastScanHub] , [LastScanHubName] , [ItemPickupStatus] , [ItemDeliveryStatus] , [WarehouseLocationStatus] , [TotalRecords])
			select [ORDER_ID] = oi.ORDER_ID
				, [Barcode] = oi.BARCODE
				, [ParentBarcode] = gpbobi.Barcode
				, [ItemID] = oi.OI_ID
				, [ParentItemID] = oi.PARENT_OI_ID
				, [ItemToShip] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (oi.ItemToShip_MTV_CODE)
				, [ItemCode] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (oi.ItemCode_MTV_CODE)
				, [Qty] = oi.Quantity
				, [ItemDescription] = oi.ItemDescription
				, [ItemAssemblyTime] = oi.AssemblyTime
				, [ClientRef1] = oi.ItemClientRef1
				, [ClientRef2] = oi.ItemClientRef2
				, [ClientRef3] = oi.ItemClientRef3
				, [SKUNo] = oi.SKU_NO
				, [PackingDetail] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (oi.PackingCode_MTV_CODE)
				, [PackingDetailNote] = oi.PackageDetailsNote
				, [ItemWeight] = oi.ItemWeight
				, [WeightUnit] = oi.WeightUnit_MTV_CODE
				, [Dimension] = oi.Dimensions
				, [DimensionUnit] = oi.DimensionUnit_MTV_CODE
				, [ItemCubes] = oi.Cu_Ft_
				, [ItemValue] = oi.Amount
				, [LocationID] = oist.[LastScanLocationID]
				, [DeliveryStatus] = '' --Need to Work On
				, [LastScanTypeName] = oist.LastScanType
				, [LastScanDate] = oist.LastScanDate
				, [LastScanHub] = oist.LastScanHub
				, [LastScanHubName] = oist.LastScanHubName
				, [ItemPickupStatus] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oi.ItemPickupStatus_MTV_ID)
				, [ItemDeliveryStatus] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oi.ItemDeliveryStatus_MTV_ID)
				, [WarehouseLocationStatus] = oist.WarehouseStatus
				, [TotalRecords] = @TotalRecords
			from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock)
			left join @OrderItemScanTable oist on oi.BARCODE = oist.BARCODE 
			outer apply [POMS_DB].[dbo].[F_Get_Parent_Barcode_OrderID_By_ItemID] (oi.PARENT_OI_ID) gpbobi
			where oi.[ORDER_ID] = @ORDER_ID
		end

		select @TotalRecords = @TotalRecords + count(oi.[OI_ID]) from [POMSArchive_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.[ORDER_ID] = @ORDER_ID

		insert into @OrderItemScanTable (ORDER_ID ,BARCODE ,LastScanDate ,LastScanHub ,LastScanHubName ,[LastScanLocationID] ,LastScanType ,WarehouseStatus)
		SELECT ORDER_ID ,BARCODE 
		,LastScanDate = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odai.LastScanDate, @TimeZone_ID, null, @TimeZoneName)
		,LastScanHub 
		,LastScanHubName = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (odai.LastScanHub)
		,[LastScanLocationID] 
		,LastScanType = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odai.LastScanType_MTV_ID)
		,WarehouseStatus = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (odai.WarehouseStatus_MTV_ID)
		FROM [POMSArchive_DB].[dbo].[T_Order_Items_Additional_Info] odai with (nolock) where odai.ORDER_ID = @ORDER_ID

		insert into @ReturnTable ([OrderID] , [Barcode] , [ParentBarcode] , [ItemID] , [ParentItemID] , [ItemToShip] , [ItemCode] , [Qty] , [ItemDescription] , [ItemAssemblyTime] , [ClientRef1] , [ClientRef2] 
		, [ClientRef3] , [SKUNo] , [PackingDetail] , [PackingDetailNote] , [ItemWeight] , [WeightUnit] , [Dimension] , [DimensionUnit] , [ItemCubes] , [ItemValue] , [LocationID] , [DeliveryStatus] 
		, [LastScanTypeName] , [LastScanDate] , [LastScanHub] , [LastScanHubName] , [ItemPickupStatus] , [ItemDeliveryStatus] , [WarehouseLocationStatus] , [TotalRecords])
		select [ORDER_ID] = oi.ORDER_ID
			, [Barcode] = oi.BARCODE
			, [ParentBarcode] = gpbobi.Barcode
			, [ItemID] = oi.OI_ID
			, [ParentItemID] = oi.PARENT_OI_ID
			, [ItemToShip] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (oi.ItemToShip_MTV_CODE)
			, [ItemCode] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (oi.ItemCode_MTV_CODE)
			, [Qty] = oi.Quantity
			, [ItemDescription] = oi.ItemDescription
			, [ItemAssemblyTime] = oi.AssemblyTime
			, [ClientRef1] = oi.ItemClientRef1
			, [ClientRef2] = oi.ItemClientRef2
			, [ClientRef3] = oi.ItemClientRef3
			, [SKUNo] = oi.SKU_NO
			, [PackingDetail] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (oi.PackingCode_MTV_CODE)
			, [PackingDetailNote] = oi.PackageDetailsNote
			, [ItemWeight] = oi.ItemWeight
			, [WeightUnit] = oi.WeightUnit_MTV_CODE
			, [Dimension] = oi.Dimensions
			, [DimensionUnit] = oi.DimensionUnit_MTV_CODE
			, [ItemCubes] = oi.Cu_Ft_
			, [ItemValue] = oi.Amount
			, [LocationID] = oist.[LastScanLocationID]
			, [DeliveryStatus] = '' --Need to Work On
			, [LastScanTypeName] = oist.LastScanType
			, [LastScanDate] = oist.LastScanDate
			, [LastScanHub] = oist.LastScanHub
			, [LastScanHubName] = oist.LastScanHubName
			, [ItemPickupStatus] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oi.ItemPickupStatus_MTV_ID)
			, [ItemDeliveryStatus] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oi.ItemDeliveryStatus_MTV_ID)
			, [WarehouseLocationStatus] = oist.WarehouseStatus
			, [TotalRecords] = @TotalRecords
		from [POMSArchive_DB].[dbo].[T_Order_Items] oi with (nolock)
		left join @OrderItemScanTable oist on oi.BARCODE = oist.BARCODE 
		outer apply [POMS_DB].[dbo].[F_Get_Parent_Barcode_OrderID_By_ItemID] (oi.PARENT_OI_ID) gpbobi
		where oi.[ORDER_ID] = @ORDER_ID
	end

	return
	

end
GO
