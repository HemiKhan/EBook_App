USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_OrderDetail_By_GUID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_Get_OrderDetail_By_GUID] '7ECADB58-AC2A-4535-BECE-40B1441999F5',0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147103,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode ,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Get_OrderDetail_By_GUID]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@ReturnCode bit output
	,@ReturnText nvarchar(250) output
)

AS

BEGIN

set @ORDER_CODE_GUID = upper(@ORDER_CODE_GUID)
set @UserName = upper(@UserName)
set @ReturnCode = 0
set @ReturnText = ''

set @ORDER_ID = isnull(@ORDER_ID,0)

if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

if @ORDER_ID = 0
begin
	set @ReturnText = 'Invalid OrderID'
end

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

Declare @ReturnTable table
([OrderID] int
, [ParentOrderID] int
, [TrackingNo] nvarchar(40)
--, [Pickup_OG_ID] int
, [PickupOGName] nvarchar(150)
--, [Delivery_OG_ID] int
, [DeliveryOGName] nvarchar(150)
--, [OrderStatus_MTV_ID] int
, [OrderStatusName] nvarchar(50)
--, [OrderSource_MTV_ID] int
, [OrderSourceName] nvarchar(50)
--, [OrderPriority_MTV_ID] int
, [OrderPriorityName] nvarchar(50)
--, [ShippingStatus_EVENT_ID] int
, [ShippingStatusEventName] nvarchar(150)
, [QuoteID] nvarchar(50)
, [QuoteAmount] decimal(18, 2)
, [SellerCode] nvarchar(20)
, [SellerName] nvarchar(150)
, [SubSellerCode] nvarchar(20)
, [SubSellerName] nvarchar(150)
, [SellerPartnerCode] nvarchar(20)
, [SellerPartnerName] nvarchar(150)
, [TariffNO] nvarchar(36)
, [TariffName] nvarchar(150)
, [EstimateRevenue] decimal(18,6)
, [ActualRevenue] decimal(18,6)
--, [InvoiceType_MTV_ID] int
, [InvoiceTypeName] nvarchar(50)
--, [OrderType_MTV_ID] int
, [OrderTypeName] nvarchar(50)
--, [SubOrderType_ID] int
, [SubOrderTypeName] nvarchar(150)

, [OrderCreatedOn] datetime
, [OrderCreatedBy] nvarchar(150)
, [LastLocation] nvarchar(50)
, [DocsCount] int
, [PublicComments] int
, [PrivateComments] int
, [ActivitiesEvent] int
, [ScansCount] int

--, [CurrentAssignToDept_MTV_CODE] nvarchar(20)
, [CurrentAssignToDeptName] nvarchar(50)

, [ShipFromAddressCode] nvarchar(50)
, [ShipFromFirstName] nvarchar(50)
, [ShipFromMiddleName] nvarchar(50)
, [ShipFromLastName] nvarchar(50)
, [ShipFromCompany] nvarchar(250)
, [ShipFromContactPerson] nvarchar(150)
, [ShipFromAddress] nvarchar(250)
, [ShipFromAddress2] nvarchar(250)
, [ShipFromCity] nvarchar(50)
, [ShipFromState] nvarchar(5)
, [ShipFromZipCode] nvarchar(10)
, [ShipFromCounty] nvarchar(50)
, [ShipFromCountryRegionCode] nvarchar(10)
, [ShipFromEmail] nvarchar(250)
, [ShipFromMobile] nvarchar(30)
, [ShipFromPhone] nvarchar(20)
, [ShipFromPhoneExt] nvarchar(10)
, [ShipFromLat] nvarchar(30)
, [ShipFromLng] nvarchar(30)
, [ShipFromPlaceID] nvarchar(500)
--, [ShipFrom_AreaType_MTV_ID] int
, [ShipFromAreaTypeName] nvarchar(150)
, [ShipFromHubCode] nvarchar(20)
, [ShipFromHubName] nvarchar(150)
, [LiveShipFromHubCode] nvarchar(20)	
, [LiveShipFromHubName] nvarchar(150)	
, [ShipFromZoneCode] nvarchar(20)
, [ShipFromZoneName] nvarchar(150)
, [ShipFromChangeCount] int
, [ShipToAddressCode] nvarchar(50)
, [ShipToFirstName] nvarchar(50)
, [ShipToMiddleName] nvarchar(50)
, [ShipToLastName] nvarchar(50)
, [ShipToCompany] nvarchar(250)
, [ShipToContactPerson] nvarchar(50)
, [ShipToAddress] nvarchar(250)
, [ShipToAddress2] nvarchar(250)
, [ShipToCity] nvarchar(50)
, [ShipToState] nvarchar(5)
, [ShipToZipCode] nvarchar(10)
, [ShipToCounty] nvarchar(50)
, [ShipToCountryRegionCode] nvarchar(10)
, [ShipToEmail] nvarchar(250)
, [ShipToMobile] nvarchar(30)
, [ShipToPhone] nvarchar(20)
, [ShipToPhoneExt] nvarchar(10)
, [ShipToLat] nvarchar(30)
, [ShipToLng] nvarchar(30)
, [ShipToPlaceID] nvarchar(500)
--, [ShipTo_AreaType_MTV_ID] int
, [ShipToAreaType_Name] nvarchar(150)
, [ShipToHubCode] nvarchar(20)
, [ShipToHubName] nvarchar(150)
, [LiveShipToHubCode] nvarchar(20)
, [LiveShipToHubName] nvarchar(150)
, [ShipToZoneCode] nvarchar(20)
, [ShipToZoneName] nvarchar(150)
, [IsBlindShipTo] bit

, [ShipTo_ChangeCount] int
, [InsuranceRequired] bit

--, [BillingType_MTV_CODE] nvarchar(20)
, [BillingTypeName] nvarchar(50)
, [BillToCustomerNO] nvarchar(20)
, [BillToCustomerName] nvarchar(250)
, [BillToSubCcustomerNO] nvarchar(20)
, [BillToSubCustomerName] nvarchar(250)
, [BillToAddressCode] nvarchar(50)
, [BillToFirstName] nvarchar(50)
, [BillToMiddleName] nvarchar(50)
, [BillToLastName] nvarchar(50)
, [BillToCompany] nvarchar(250)
, [BillToContactPerson] nvarchar(150)
, [BillToAddress] nvarchar(250)
, [BillToAddress2] nvarchar(250)
, [BillToCity] nvarchar(50)
, [BillToState] nvarchar(5)
, [BillToZipCode] nvarchar(10)
, [BillToCounty] nvarchar(50)
, [BillToCountryRegionCode] nvarchar(10)
, [BillToEmail] nvarchar(250)
, [BillToMobile] nvarchar(30)
, [BillToPhone] nvarchar(20)
, [BillToPhoneExt] nvarchar(10)
--, [PaymentStatusID] int
, [PaymentStatusName] nvarchar(50)
, [CreditLimit] decimal(18,2)
, [AvailableLimit] decimal(18,2)
, [Balance] decimal(18,2)
, [PaymentTermsCode] nvarchar(20)
, [PaymentTermsName] nvarchar(150)
, [DepartmentCode] nvarchar(20)
, [DepartmentName] nvarchar(50)

, [ReqPickupDate] date
, [ReqPickupFromTime] time(7)
, [ReqPickupToTime] time(7)
, [ReqPickupTimeName] nvarchar(50)
, [FirstOfferedPickupDate] date
--, [PickupScheduleType_MTV_ID] int
, [PickupScheduleTypeName] nvarchar(50)
, [PromisedPickupDate] date
, [PkpSchByUserName] nvarchar(150)
--, [ReqPickupTimeFrame_TFL_ID] int
, [ReqPickupTimeFrameTFLName] nvarchar(50)
--, [ConfirmedPickupTimeFrame_TFL_ID] int
, [ConfirmedPickupTimeFrameTFLName] nvarchar(50)
, [ActualPickupDate] nvarchar(50)
, [PickupManifest] int
, [PickupSTCode] nvarchar(20)
, [PickupSTName] nvarchar(50)
, [PickupSSTCode] nvarchar(20)
, [PickupSSTName] nvarchar(50)
, [PickupInstruction] nvarchar(1000)
, [ReqDeliveryDate] date
, [ReqDeliveryFromTime] time(7)
, [ReqDeliveryToTime] time(7)
, [ReqDeliveryTimeName] nvarchar(50)
, [FirstOfferedDeliveryDate] date
--, [DeliveryScheduleType_MTV_ID] int
, [DeliveryScheduleTypeName] nvarchar(50)
, [PromisedDeliveryDate] date
, [DlvSchByUserName] nvarchar(150)
--, [ReqDeliveryTimeFrame_TFL_ID] int
, [ReqDeliveryTimeFrameTFLName] nvarchar(50)
--, [ConfirmedDeliveryTimeFrame_TFL_ID] int
, [ConfirmedDeliveryTimeFrameTFLName] nvarchar(50)
, [ActualDeliveryDate] nvarchar(50)
, [DeliveryManifest] int
, [DeliverySTCode] nvarchar(20)
, [DeliverySTName] nvarchar(50)
, [DeliverySSTCode] nvarchar(20)
, [DeliverySSTName] nvarchar(50)
, [DeliveryInstruction] nvarchar(1000)

, [EstimateMiles] int
, [IsMWG] bit

, [Revenue] decimal(18,6)
, [RevenueWithCM] decimal(18,6)
, [LastViewedDate] datetime
, [LastViewedByUserName] nvarchar(150)
, [LastViewedByFullName] nvarchar(250)
, [LastViewedByDept] nvarchar(150)
)

if @GetRecordType_MTV_ID in (147100)
begin
	insert into @ReturnTable
	select ORDER_ID
	,PARENT_ORDER_ID
	,TRACKING_NO
	--,Pickup_OG_ID
	,Pickup_OG_Name
	--,Delivery_OG_ID
	,Delivery_OG_Name
	--,OrderStatus_MTV_ID
	,OrderStatus_Name
	--,OrderSource_MTV_ID
	,OrderSource_Name
	--,OrderPriority_MTV_ID
	,OrderPriority_Name
	--,ShippingStatus_EVENT_ID
	,ShippingStatus_EVENT_Name
	,QuoteID
	,QuoteAmount
	,SELLER_CODE
	,SELLER_NAME
	,SUB_SELLER_CODE
	,SUB_SELLER_NAME
	,SELLER_PARTNER_CODE
	,SELLER_PARTNER_NAME
	,TARIFF_NO
	,TARIFF_NAME
	,EstimateRevenue
	,ActualRevenue
	--,InvoiceType_MTV_ID
	,InvoiceType_Name
	--,OrderType_MTV_ID
	,OrderType_Name
	--,SubOrderType_ID
	,SubOrderType_Name
	,OrderCreatedOn
	,OrderCreatedBy
	,LastLocation
	,DocsCount
	,PublicComments
	,PrivateComments
	,ActivitiesEvent
	,ScansCount
	--,CurrentAssignToDept_MTV_CODE
	,CurrentAssignToDept_Name
	,ShipFrom_ADDRESS_CODE
	,ShipFrom_FirstName
	,ShipFrom_MiddleName
	,ShipFrom_LastName
	,ShipFrom_Company
	,ShipFrom_ContactPerson
	,ShipFrom_Address
	,ShipFrom_Address2
	,ShipFrom_City
	,ShipFrom_State
	,ShipFrom_ZipCode
	,ShipFrom_County
	,ShipFrom_CountryRegionCode
	,ShipFrom_Email
	,ShipFrom_Mobile
	,ShipFrom_Phone
	,ShipFrom_PhoneExt
	,ShipFrom_Lat
	,ShipFrom_Lng
	,ShipFrom_PlaceID
	--,ShipFrom_AreaType_MTV_ID
	,ShipFrom_AreaType_Name
	,ShipFrom_HUB_CODE
	,ShipFrom_HUB_Name
	,LiveShipFrom_HUB_CODE
	,LiveShipFrom_HUB_Name
	,ShipFrom_ZONE_CODE
	,ShipFrom_ZONE_Name
	,ShipFrom_ChangeCount
	,ShipTo_ADDRESS_CODE
	,ShipTo_FirstName
	,ShipTo_MiddleName
	,ShipTo_LastName
	,ShipTo_Company
	,ShipTo_ContactPerson
	,ShipTo_Address
	,ShipTo_Address2
	,ShipTo_City
	,ShipTo_State
	,ShipTo_ZipCode
	,ShipTo_County
	,ShipTo_CountryRegionCode
	,ShipTo_Email
	,ShipTo_Mobile
	,ShipTo_Phone
	,ShipTo_PhoneExt
	,ShipTo_Lat
	,ShipTo_Lng
	,ShipTo_PlaceID
	--,ShipTo_AreaType_MTV_ID
	,ShipTo_AreaType_Name
	,ShipTo_HUB_CODE
	,ShipTo_HUB_Name
	,LiveShipTo_HUB_CODE
	,LiveShipTo_HUB_Name
	,ShipTo_ZONE_CODE
	,ShipTo_ZONE_Name
	,IsBlindShipTo
	,ShipTo_ChangeCount
	,InsuranceRequired
	--,BillingType_MTV_CODE
	,BillingType_Name
	,BillTo_CUSTOMER_NO
	,BillTo_CUSTOMER_NAME
	,BillToSub_CUSTOMER_NO
	,BillToSub_CUSTOMER_NAME
	,BillTo_ADDRESS_CODE
	,BillTo_FirstName
	,BillTo_MiddleName
	,BillTo_LastName
	,BillTo_Company
	,BillTo_ContactPerson
	,BillTo_Address
	,BillTo_Address2
	,BillTo_City
	,BillTo_State
	,BillTo_ZipCode
	,BillTo_County
	,BillTo_CountryRegionCode
	,BillTo_Email
	,BillTo_Mobile
	,BillTo_Phone
	,BillTo_PhoneExt
	--,PaymentStatusID
	,PaymentStatusName
	,CreditLimit
	,AvailableLimit
	,Balance
	,PaymentTermsCode
	,PaymentTermsName
	,DepartmentCode
	,DepartmentName
	,ReqPickup_Date
	,ReqPickup_FromTime
	,ReqPickup_ToTime
	,ReqPickup_TimeName
	,FirstOffered_PickupDate
	--,PickupScheduleType_MTV_ID
	,PickupScheduleType_Name
	,PromisedPickupDate
	,PkpSchByUserName
	--,ReqPickupTimeFrame_TFL_ID
	,ReqPickupTimeFrame_TFL_Name
	--,ConfirmedPickupTimeFrame_TFL_ID
	,ConfirmedPickupTimeFrame_TFL_Name
	,ActualPickupDate
	,PickupManifest
	,PICKUP_ST_CODE
	,PICKUP_ST_NAME
	,PICKUP_SST_CODE
	,PICKUP_SST_NAME
	,Pickup_Instruction
	,ReqDelivery_Date
	,ReqDelivery_FromTime
	,ReqDelivery_ToTime
	,ReqDelivery_TimeName
	,FirstOffered_DeliveryDate
	--,DeliveryScheduleType_MTV_ID
	,DeliveryScheduleType_Name
	,PromisedDeliveryDate
	,DlvSchByUserName
	--,ReqDeliveryTimeFrame_TFL_ID
	,ReqDeliveryTimeFrame_TFL_Name
	--,ConfirmedDeliveryTimeFrame_TFL_ID
	,ConfirmedDeliveryTimeFrame_TFL_Name
	,ActualDeliveryDate
	,DeliveryManifest
	,DELIVERY_ST_CODE
	,DELIVERY_ST_NAME
	,DELIVERY_SST_CODE
	,DELIVERY_SST_NAME
	,Delivery_Instruction
	,EstimateMiles
	,IsMWG
	,Revenue
	,RevenueWithCM
	,LastViewedDate
	,LastViewedByUserName
	,LastViewedByFullName
	,LastViewedByDept
	from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147101)
begin
	insert into @ReturnTable
	select ORDER_ID
	,PARENT_ORDER_ID
	,TRACKING_NO
	--,Pickup_OG_ID
	,Pickup_OG_Name
	--,Delivery_OG_ID
	,Delivery_OG_Name
	--,OrderStatus_MTV_ID
	,OrderStatus_Name
	--,OrderSource_MTV_ID
	,OrderSource_Name
	--,OrderPriority_MTV_ID
	,OrderPriority_Name
	--,ShippingStatus_EVENT_ID
	,ShippingStatus_EVENT_Name
	,QuoteID
	,QuoteAmount
	,SELLER_CODE
	,SELLER_NAME
	,SUB_SELLER_CODE
	,SUB_SELLER_NAME
	,SELLER_PARTNER_CODE
	,SELLER_PARTNER_NAME
	,TARIFF_NO
	,TARIFF_NAME
	,EstimateRevenue
	,ActualRevenue
	--,InvoiceType_MTV_ID
	,InvoiceType_Name
	--,OrderType_MTV_ID
	,OrderType_Name
	--,SubOrderType_ID
	,SubOrderType_Name
	,OrderCreatedOn
	,OrderCreatedBy
	,LastLocation
	,DocsCount
	,PublicComments
	,PrivateComments
	,ActivitiesEvent
	,ScansCount
	--,CurrentAssignToDept_MTV_CODE
	,CurrentAssignToDept_Name
	,ShipFrom_ADDRESS_CODE
	,ShipFrom_FirstName
	,ShipFrom_MiddleName
	,ShipFrom_LastName
	,ShipFrom_Company
	,ShipFrom_ContactPerson
	,ShipFrom_Address
	,ShipFrom_Address2
	,ShipFrom_City
	,ShipFrom_State
	,ShipFrom_ZipCode
	,ShipFrom_County
	,ShipFrom_CountryRegionCode
	,ShipFrom_Email
	,ShipFrom_Mobile
	,ShipFrom_Phone
	,ShipFrom_PhoneExt
	,ShipFrom_Lat
	,ShipFrom_Lng
	,ShipFrom_PlaceID
	--,ShipFrom_AreaType_MTV_ID
	,ShipFrom_AreaType_Name
	,ShipFrom_HUB_CODE
	,ShipFrom_HUB_Name
	,LiveShipFrom_HUB_CODE
	,LiveShipFrom_HUB_Name
	,ShipFrom_ZONE_CODE
	,ShipFrom_ZONE_Name
	,ShipFrom_ChangeCount
	,ShipTo_ADDRESS_CODE
	,ShipTo_FirstName
	,ShipTo_MiddleName
	,ShipTo_LastName
	,ShipTo_Company
	,ShipTo_ContactPerson
	,ShipTo_Address
	,ShipTo_Address2
	,ShipTo_City
	,ShipTo_State
	,ShipTo_ZipCode
	,ShipTo_County
	,ShipTo_CountryRegionCode
	,ShipTo_Email
	,ShipTo_Mobile
	,ShipTo_Phone
	,ShipTo_PhoneExt
	,ShipTo_Lat
	,ShipTo_Lng
	,ShipTo_PlaceID
	--,ShipTo_AreaType_MTV_ID
	,ShipTo_AreaType_Name
	,ShipTo_HUB_CODE
	,ShipTo_HUB_Name
	,LiveShipTo_HUB_CODE
	,LiveShipTo_HUB_Name
	,ShipTo_ZONE_CODE
	,ShipTo_ZONE_Name
	,IsBlindShipTo
	,ShipTo_ChangeCount
	,InsuranceRequired
	--,BillingType_MTV_CODE
	,BillingType_Name
	,BillTo_CUSTOMER_NO
	,BillTo_CUSTOMER_NAME
	,BillToSub_CUSTOMER_NO
	,BillToSub_CUSTOMER_NAME
	,BillTo_ADDRESS_CODE
	,BillTo_FirstName
	,BillTo_MiddleName
	,BillTo_LastName
	,BillTo_Company
	,BillTo_ContactPerson
	,BillTo_Address
	,BillTo_Address2
	,BillTo_City
	,BillTo_State
	,BillTo_ZipCode
	,BillTo_County
	,BillTo_CountryRegionCode
	,BillTo_Email
	,BillTo_Mobile
	,BillTo_Phone
	,BillTo_PhoneExt
	--,PaymentStatusID
	,PaymentStatusName
	,CreditLimit
	,AvailableLimit
	,Balance
	,PaymentTermsCode
	,PaymentTermsName
	,DepartmentCode
	,DepartmentName
	,ReqPickup_Date
	,ReqPickup_FromTime
	,ReqPickup_ToTime
	,ReqPickup_TimeName
	,FirstOffered_PickupDate
	--,PickupScheduleType_MTV_ID
	,PickupScheduleType_Name
	,PromisedPickupDate
	,PkpSchByUserName
	--,ReqPickupTimeFrame_TFL_ID
	,ReqPickupTimeFrame_TFL_Name
	--,ConfirmedPickupTimeFrame_TFL_ID
	,ConfirmedPickupTimeFrame_TFL_Name
	,ActualPickupDate
	,PickupManifest
	,PICKUP_ST_CODE
	,PICKUP_ST_NAME
	,PICKUP_SST_CODE
	,PICKUP_SST_NAME
	,Pickup_Instruction
	,ReqDelivery_Date
	,ReqDelivery_FromTime
	,ReqDelivery_ToTime
	,ReqDelivery_TimeName
	,FirstOffered_DeliveryDate
	--,DeliveryScheduleType_MTV_ID
	,DeliveryScheduleType_Name
	,PromisedDeliveryDate
	,DlvSchByUserName
	--,ReqDeliveryTimeFrame_TFL_ID
	,ReqDeliveryTimeFrame_TFL_Name
	--,ConfirmedDeliveryTimeFrame_TFL_ID
	,ConfirmedDeliveryTimeFrame_TFL_Name
	,ActualDeliveryDate
	,DeliveryManifest
	,DELIVERY_ST_CODE
	,DELIVERY_ST_NAME
	,DELIVERY_SST_CODE
	,DELIVERY_SST_NAME
	,Delivery_Instruction
	,EstimateMiles
	,IsMWG
	,Revenue
	,RevenueWithCM
	,LastViewedDate
	,LastViewedByUserName
	,LastViewedByFullName
	,LastViewedByDept
	from [POMS_DB].[dbo].[F_Get_POMSArchive_OrderDetail_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID = 147103
begin
	insert into @ReturnTable
	select ORDER_ID
	,PARENT_ORDER_ID
	,TRACKING_NO
	--,Pickup_OG_ID
	,Pickup_OG_Name
	--,Delivery_OG_ID
	,Delivery_OG_Name
	--,OrderStatus_MTV_ID
	,OrderStatus_Name
	--,OrderSource_MTV_ID
	,OrderSource_Name
	--,OrderPriority_MTV_ID
	,OrderPriority_Name
	--,ShippingStatus_EVENT_ID
	,ShippingStatus_EVENT_Name
	,QuoteID
	,QuoteAmount
	,SELLER_CODE
	,SELLER_NAME
	,SUB_SELLER_CODE
	,SUB_SELLER_NAME
	,SELLER_PARTNER_CODE
	,SELLER_PARTNER_NAME
	,TARIFF_NO
	,TARIFF_NAME
	,EstimateRevenue
	,ActualRevenue
	--,InvoiceType_MTV_ID
	,InvoiceType_Name
	--,OrderType_MTV_ID
	,OrderType_Name
	--,SubOrderType_ID
	,SubOrderType_Name
	,OrderCreatedOn
	,OrderCreatedBy
	,LastLocation
	,DocsCount
	,PublicComments
	,PrivateComments
	,ActivitiesEvent
	,ScansCount
	--,CurrentAssignToDept_MTV_CODE
	,CurrentAssignToDept_Name
	,ShipFrom_ADDRESS_CODE
	,ShipFrom_FirstName
	,ShipFrom_MiddleName
	,ShipFrom_LastName
	,ShipFrom_Company
	,ShipFrom_ContactPerson
	,ShipFrom_Address
	,ShipFrom_Address2
	,ShipFrom_City
	,ShipFrom_State
	,ShipFrom_ZipCode
	,ShipFrom_County
	,ShipFrom_CountryRegionCode
	,ShipFrom_Email
	,ShipFrom_Mobile
	,ShipFrom_Phone
	,ShipFrom_PhoneExt
	,ShipFrom_Lat
	,ShipFrom_Lng
	,ShipFrom_PlaceID
	--,ShipFrom_AreaType_MTV_ID
	,ShipFrom_AreaType_Name
	,ShipFrom_HUB_CODE
	,ShipFrom_HUB_Name
	,LiveShipFrom_HUB_CODE
	,LiveShipFrom_HUB_Name
	,ShipFrom_ZONE_CODE
	,ShipFrom_ZONE_Name
	,ShipFrom_ChangeCount
	,ShipTo_ADDRESS_CODE
	,ShipTo_FirstName
	,ShipTo_MiddleName
	,ShipTo_LastName
	,ShipTo_Company
	,ShipTo_ContactPerson
	,ShipTo_Address
	,ShipTo_Address2
	,ShipTo_City
	,ShipTo_State
	,ShipTo_ZipCode
	,ShipTo_County
	,ShipTo_CountryRegionCode
	,ShipTo_Email
	,ShipTo_Mobile
	,ShipTo_Phone
	,ShipTo_PhoneExt
	,ShipTo_Lat
	,ShipTo_Lng
	,ShipTo_PlaceID
	--,ShipTo_AreaType_MTV_ID
	,ShipTo_AreaType_Name
	,ShipTo_HUB_CODE
	,ShipTo_HUB_Name
	,LiveShipTo_HUB_CODE
	,LiveShipTo_HUB_Name
	,ShipTo_ZONE_CODE
	,ShipTo_ZONE_Name
	,IsBlindShipTo
	,ShipTo_ChangeCount
	,InsuranceRequired
	--,BillingType_MTV_CODE
	,BillingType_Name
	,BillTo_CUSTOMER_NO
	,BillTo_CUSTOMER_NAME
	,BillToSub_CUSTOMER_NO
	,BillToSub_CUSTOMER_NAME
	,BillTo_ADDRESS_CODE
	,BillTo_FirstName
	,BillTo_MiddleName
	,BillTo_LastName
	,BillTo_Company
	,BillTo_ContactPerson
	,BillTo_Address
	,BillTo_Address2
	,BillTo_City
	,BillTo_State
	,BillTo_ZipCode
	,BillTo_County
	,BillTo_CountryRegionCode
	,BillTo_Email
	,BillTo_Mobile
	,BillTo_Phone
	,BillTo_PhoneExt
	--,PaymentStatusID
	,PaymentStatusName
	,CreditLimit
	,AvailableLimit
	,Balance
	,PaymentTermsCode
	,PaymentTermsName
	,DepartmentCode
	,DepartmentName
	,ReqPickup_Date
	,ReqPickup_FromTime
	,ReqPickup_ToTime
	,ReqPickup_TimeName
	,FirstOffered_PickupDate
	--,PickupScheduleType_MTV_ID
	,PickupScheduleType_Name
	,PromisedPickupDate
	,PkpSchByUserName
	--,ReqPickupTimeFrame_TFL_ID
	,ReqPickupTimeFrame_TFL_Name
	--,ConfirmedPickupTimeFrame_TFL_ID
	,ConfirmedPickupTimeFrame_TFL_Name
	,ActualPickupDate
	,PickupManifest
	,PICKUP_ST_CODE
	,PICKUP_ST_NAME
	,PICKUP_SST_CODE
	,PICKUP_SST_NAME
	,Pickup_Instruction
	,ReqDelivery_Date
	,ReqDelivery_FromTime
	,ReqDelivery_ToTime
	,ReqDelivery_TimeName
	,FirstOffered_DeliveryDate
	--,DeliveryScheduleType_MTV_ID
	,DeliveryScheduleType_Name
	,PromisedDeliveryDate
	,DlvSchByUserName
	--,ReqDeliveryTimeFrame_TFL_ID
	,ReqDeliveryTimeFrame_TFL_Name
	--,ConfirmedDeliveryTimeFrame_TFL_ID
	,ConfirmedDeliveryTimeFrame_TFL_Name
	,ActualDeliveryDate
	,DeliveryManifest
	,DELIVERY_ST_CODE
	,DELIVERY_ST_NAME
	,DELIVERY_SST_CODE
	,DELIVERY_SST_NAME
	,Delivery_Instruction
	,EstimateMiles
	,IsMWG
	,Revenue
	,RevenueWithCM
	,LastViewedDate
	,LastViewedByUserName
	,LastViewedByFullName
	,LastViewedByDept
	from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID = 147104
begin
	insert into @ReturnTable
	select ORDER_ID
	,PARENT_ORDER_ID
	,TRACKING_NO
	--,Pickup_OG_ID
	,Pickup_OG_Name
	--,Delivery_OG_ID
	,Delivery_OG_Name
	--,OrderStatus_MTV_ID
	,OrderStatus_Name
	--,OrderSource_MTV_ID
	,OrderSource_Name
	--,OrderPriority_MTV_ID
	,OrderPriority_Name
	--,ShippingStatus_EVENT_ID
	,ShippingStatus_EVENT_Name
	,QuoteID
	,QuoteAmount
	,SELLER_CODE
	,SELLER_NAME
	,SUB_SELLER_CODE
	,SUB_SELLER_NAME
	,SELLER_PARTNER_CODE
	,SELLER_PARTNER_NAME
	,TARIFF_NO
	,TARIFF_NAME
	,EstimateRevenue
	,ActualRevenue
	--,InvoiceType_MTV_ID
	,InvoiceType_Name
	--,OrderType_MTV_ID
	,OrderType_Name
	--,SubOrderType_ID
	,SubOrderType_Name
	,OrderCreatedOn
	,OrderCreatedBy
	,LastLocation
	,DocsCount
	,PublicComments
	,PrivateComments
	,ActivitiesEvent
	,ScansCount
	--,CurrentAssignToDept_MTV_CODE
	,CurrentAssignToDept_Name
	,ShipFrom_ADDRESS_CODE
	,ShipFrom_FirstName
	,ShipFrom_MiddleName
	,ShipFrom_LastName
	,ShipFrom_Company
	,ShipFrom_ContactPerson
	,ShipFrom_Address
	,ShipFrom_Address2
	,ShipFrom_City
	,ShipFrom_State
	,ShipFrom_ZipCode
	,ShipFrom_County
	,ShipFrom_CountryRegionCode
	,ShipFrom_Email
	,ShipFrom_Mobile
	,ShipFrom_Phone
	,ShipFrom_PhoneExt
	,ShipFrom_Lat
	,ShipFrom_Lng
	,ShipFrom_PlaceID
	--,ShipFrom_AreaType_MTV_ID
	,ShipFrom_AreaType_Name
	,ShipFrom_HUB_CODE
	,ShipFrom_HUB_Name
	,LiveShipFrom_HUB_CODE
	,LiveShipFrom_HUB_Name
	,ShipFrom_ZONE_CODE
	,ShipFrom_ZONE_Name
	,ShipFrom_ChangeCount
	,ShipTo_ADDRESS_CODE
	,ShipTo_FirstName
	,ShipTo_MiddleName
	,ShipTo_LastName
	,ShipTo_Company
	,ShipTo_ContactPerson
	,ShipTo_Address
	,ShipTo_Address2
	,ShipTo_City
	,ShipTo_State
	,ShipTo_ZipCode
	,ShipTo_County
	,ShipTo_CountryRegionCode
	,ShipTo_Email
	,ShipTo_Mobile
	,ShipTo_Phone
	,ShipTo_PhoneExt
	,ShipTo_Lat
	,ShipTo_Lng
	,ShipTo_PlaceID
	--,ShipTo_AreaType_MTV_ID
	,ShipTo_AreaType_Name
	,ShipTo_HUB_CODE
	,ShipTo_HUB_Name
	,LiveShipTo_HUB_CODE
	,LiveShipTo_HUB_Name
	,ShipTo_ZONE_CODE
	,ShipTo_ZONE_Name
	,IsBlindShipTo
	,ShipTo_ChangeCount
	,InsuranceRequired
	--,BillingType_MTV_CODE
	,BillingType_Name
	,BillTo_CUSTOMER_NO
	,BillTo_CUSTOMER_NAME
	,BillToSub_CUSTOMER_NO
	,BillToSub_CUSTOMER_NAME
	,BillTo_ADDRESS_CODE
	,BillTo_FirstName
	,BillTo_MiddleName
	,BillTo_LastName
	,BillTo_Company
	,BillTo_ContactPerson
	,BillTo_Address
	,BillTo_Address2
	,BillTo_City
	,BillTo_State
	,BillTo_ZipCode
	,BillTo_County
	,BillTo_CountryRegionCode
	,BillTo_Email
	,BillTo_Mobile
	,BillTo_Phone
	,BillTo_PhoneExt
	--,PaymentStatusID
	,PaymentStatusName
	,CreditLimit
	,AvailableLimit
	,Balance
	,PaymentTermsCode
	,PaymentTermsName
	,DepartmentCode
	,DepartmentName
	,ReqPickup_Date
	,ReqPickup_FromTime
	,ReqPickup_ToTime
	,ReqPickup_TimeName
	,FirstOffered_PickupDate
	--,PickupScheduleType_MTV_ID
	,PickupScheduleType_Name
	,PromisedPickupDate
	,PkpSchByUserName
	--,ReqPickupTimeFrame_TFL_ID
	,ReqPickupTimeFrame_TFL_Name
	--,ConfirmedPickupTimeFrame_TFL_ID
	,ConfirmedPickupTimeFrame_TFL_Name
	,ActualPickupDate
	,PickupManifest
	,PICKUP_ST_CODE
	,PICKUP_ST_NAME
	,PICKUP_SST_CODE
	,PICKUP_SST_NAME
	,Pickup_Instruction
	,ReqDelivery_Date
	,ReqDelivery_FromTime
	,ReqDelivery_ToTime
	,ReqDelivery_TimeName
	,FirstOffered_DeliveryDate
	--,DeliveryScheduleType_MTV_ID
	,DeliveryScheduleType_Name
	,PromisedDeliveryDate
	,DlvSchByUserName
	--,ReqDeliveryTimeFrame_TFL_ID
	,ReqDeliveryTimeFrame_TFL_Name
	--,ConfirmedDeliveryTimeFrame_TFL_ID
	,ConfirmedDeliveryTimeFrame_TFL_Name
	,ActualDeliveryDate
	,DeliveryManifest
	,DELIVERY_ST_CODE
	,DELIVERY_ST_NAME
	,DELIVERY_SST_CODE
	,DELIVERY_SST_NAME
	,Delivery_Instruction
	,EstimateMiles
	,IsMWG
	,Revenue
	,RevenueWithCM
	,LastViewedDate
	,LastViewedByUserName
	,LastViewedByFullName
	,LastViewedByDept
	from [POMS_DB].[dbo].[F_Get_PinnacleProdArchive_OrderDetail_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end

if not exists(select * from @ReturnTable) and @ReturnText = ''
begin
	set @ReturnText = 'No Record Found'
end
else
begin
	set @ReturnCode = 1
end

select * from @ReturnTable

END
GO
