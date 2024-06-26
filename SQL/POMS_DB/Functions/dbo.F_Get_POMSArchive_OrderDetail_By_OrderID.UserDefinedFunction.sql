USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMSArchive_OrderDetail_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMSArchive_OrderDetail_By_OrderID] (10100640,'ABDULLAH.ARSHAD',2,1,13)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMSArchive_OrderDetail_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([ORDER_ID] int
, [PARENT_ORDER_ID] int
, [TRACKING_NO] nvarchar(40)
, [Pickup_OG_ID] int
, [Pickup_OG_Name] nvarchar(150)
, [Delivery_OG_ID] int
, [Delivery_OG_Name] nvarchar(150)
, [OrderStatus_MTV_ID] int
, [OrderStatus_Name] nvarchar(50)
, [OrderSource_MTV_ID] int
, [OrderSource_Name] nvarchar(50)
, [OrderPriority_MTV_ID] int
, [OrderPriority_Name] nvarchar(50)
, [ShippingStatus_EVENT_ID] int
, [ShippingStatus_EVENT_Name] nvarchar(150)
, [QuoteID] nvarchar(50)
, [QuoteAmount] decimal(18, 2)
, [SELLER_CODE] nvarchar(20)
, [SELLER_NAME] nvarchar(150)
, [SUB_SELLER_CODE] nvarchar(20)
, [SUB_SELLER_NAME] nvarchar(150)
, [SELLER_PARTNER_CODE] nvarchar(20)
, [SELLER_PARTNER_NAME] nvarchar(150)
, [TARIFF_NO] nvarchar(36)
, [TARIFF_NAME] nvarchar(150)
, [EstimateRevenue] decimal(18,6)
, [ActualRevenue] decimal(18,6)
, [InvoiceType_MTV_ID] int
, [InvoiceType_Name] nvarchar(50)
, [OrderType_MTV_ID] int
, [OrderType_Name] nvarchar(50)
, [SubOrderType_ID] int
, [SubOrderType_Name] nvarchar(150)

, [OrderCreatedOn] datetime
, [OrderCreatedBy] nvarchar(150)
, [LastLocation] nvarchar(50)
, [DocsCount] int
, [PublicComments] int
, [PrivateComments] int
, [ActivitiesEvent] int
, [ScansCount] int

, [CurrentAssignToDept_MTV_CODE] nvarchar(20)
, [CurrentAssignToDept_Name] nvarchar(50)

, [ShipFrom_ADDRESS_CODE] nvarchar(50)
, [ShipFrom_FirstName] nvarchar(50)
, [ShipFrom_MiddleName] nvarchar(50)
, [ShipFrom_LastName] nvarchar(50)
, [ShipFrom_Company] nvarchar(250)
, [ShipFrom_ContactPerson] nvarchar(150)
, [ShipFrom_Address] nvarchar(250)
, [ShipFrom_Address2] nvarchar(250)
, [ShipFrom_City] nvarchar(50)
, [ShipFrom_State] nvarchar(5)
, [ShipFrom_ZipCode] nvarchar(10)
, [ShipFrom_County] nvarchar(50)
, [ShipFrom_CountryRegionCode] nvarchar(10)
, [ShipFrom_Email] nvarchar(250)
, [ShipFrom_Mobile] nvarchar(30)
, [ShipFrom_Phone] nvarchar(20)
, [ShipFrom_PhoneExt] nvarchar(10)
, [ShipFrom_Lat] nvarchar(30)
, [ShipFrom_Lng] nvarchar(30)
, [ShipFrom_PlaceID] nvarchar(500)
, [ShipFrom_AreaType_MTV_ID] int
, [ShipFrom_AreaType_Name] nvarchar(150)
, [ShipFrom_HUB_CODE] nvarchar(20)
, [ShipFrom_HUB_Name] nvarchar(150)
, [LiveShipFrom_HUB_CODE] nvarchar(20)	
, [LiveShipFrom_HUB_Name] nvarchar(150)	
, [ShipFrom_ZONE_CODE] nvarchar(20)
, [ShipFrom_ZONE_Name] nvarchar(150)
, [ShipFrom_ChangeCount] int
, [ShipTo_ADDRESS_CODE] nvarchar(50)
, [ShipTo_FirstName] nvarchar(50)
, [ShipTo_MiddleName] nvarchar(50)
, [ShipTo_LastName] nvarchar(50)
, [ShipTo_Company] nvarchar(250)
, [ShipTo_ContactPerson] nvarchar(50)
, [ShipTo_Address] nvarchar(250)
, [ShipTo_Address2] nvarchar(250)
, [ShipTo_City] nvarchar(50)
, [ShipTo_State] nvarchar(5)
, [ShipTo_ZipCode] nvarchar(10)
, [ShipTo_County] nvarchar(50)
, [ShipTo_CountryRegionCode] nvarchar(10)
, [ShipTo_Email] nvarchar(250)
, [ShipTo_Mobile] nvarchar(30)
, [ShipTo_Phone] nvarchar(20)
, [ShipTo_PhoneExt] nvarchar(10)
, [ShipTo_Lat] nvarchar(30)
, [ShipTo_Lng] nvarchar(30)
, [ShipTo_PlaceID] nvarchar(500)
, [ShipTo_AreaType_MTV_ID] int
, [ShipTo_AreaType_Name] nvarchar(150)
, [ShipTo_HUB_CODE] nvarchar(20)
, [ShipTo_HUB_Name] nvarchar(150)
, [LiveShipTo_HUB_CODE] nvarchar(20)
, [LiveShipTo_HUB_Name] nvarchar(150)
, [ShipTo_ZONE_CODE] nvarchar(20)
, [ShipTo_ZONE_Name] nvarchar(150)
, [IsBlindShipTo] bit

, [ShipTo_ChangeCount] int
, [InsuranceRequired] bit

, [BillingType_MTV_CODE] nvarchar(20)
, [BillingType_Name] nvarchar(50)
, [BillTo_CUSTOMER_NO] nvarchar(20)
, [BillTo_CUSTOMER_NAME] nvarchar(250)
, [BillToSub_CUSTOMER_NO] nvarchar(20)
, [BillToSub_CUSTOMER_NAME] nvarchar(250)
, [BillTo_ADDRESS_CODE] nvarchar(50)
, [BillTo_FirstName] nvarchar(50)
, [BillTo_MiddleName] nvarchar(50)
, [BillTo_LastName] nvarchar(50)
, [BillTo_Company] nvarchar(250)
, [BillTo_ContactPerson] nvarchar(150)
, [BillTo_Address] nvarchar(250)
, [BillTo_Address2] nvarchar(250)
, [BillTo_City] nvarchar(50)
, [BillTo_State] nvarchar(20)
, [BillTo_ZipCode] nvarchar(20)
, [BillTo_County] nvarchar(50)
, [BillTo_CountryRegionCode] nvarchar(10)
, [BillTo_Email] nvarchar(250)
, [BillTo_Mobile] nvarchar(30)
, [BillTo_Phone] nvarchar(20)
, [BillTo_PhoneExt] nvarchar(10)
, [PaymentStatusID] int
, [PaymentStatusName] nvarchar(50)
, [CreditLimit] decimal(18,2)
, [AvailableLimit] decimal(18,2)
, [Balance] decimal(18,2)
, [PaymentTermsCode] nvarchar(20)
, [PaymentTermsName] nvarchar(50)
, [DepartmentCode] nvarchar(20)
, [DepartmentName] nvarchar(50)

, [ReqPickup_Date] date
, [ReqPickup_FromTime] time(7)
, [ReqPickup_ToTime] time(7)
, [ReqPickup_TimeName] nvarchar(50)
, [FirstOffered_PickupDate] date
, [PickupScheduleType_MTV_ID] int
, [PickupScheduleType_Name] nvarchar(50)
, [PromisedPickupDate] date
, [PkpSchByUserName] nvarchar(150)
, [ReqPickupTimeFrame_TFL_ID] int
, [ReqPickupTimeFrame_TFL_Name] nvarchar(50)
, [ConfirmedPickupTimeFrame_TFL_ID] int
, [ConfirmedPickupTimeFrame_TFL_Name] nvarchar(50)
, [ActualPickupDate] nvarchar(50)
, [PickupManifest] int
, [PICKUP_ST_CODE] nvarchar(20)
, [PICKUP_ST_NAME] nvarchar(50)
, [PICKUP_SST_CODE] nvarchar(20)
, [PICKUP_SST_NAME] nvarchar(50)
, [Pickup_Instruction] nvarchar(1000)
, [ReqDelivery_Date] date
, [ReqDelivery_FromTime] time(7)
, [ReqDelivery_ToTime] time(7)
, [ReqDelivery_TimeName] nvarchar(50)
, [FirstOffered_DeliveryDate] date
, [DeliveryScheduleType_MTV_ID] int
, [DeliveryScheduleType_Name] nvarchar(50)
, [PromisedDeliveryDate] date
, [DlvSchByUserName] nvarchar(150)
, [ReqDeliveryTimeFrame_TFL_ID] int
, [ReqDeliveryTimeFrame_TFL_Name] nvarchar(50)
, [ConfirmedDeliveryTimeFrame_TFL_ID] int
, [ConfirmedDeliveryTimeFrame_TFL_Name] nvarchar(50)
, [ActualDeliveryDate] nvarchar(50)
, [DeliveryManifest] int
, [DELIVERY_ST_CODE] nvarchar(20)
, [DELIVERY_ST_NAME] nvarchar(50)
, [DELIVERY_SST_CODE] nvarchar(20)
, [DELIVERY_SST_NAME] nvarchar(50)
, [Delivery_Instruction] nvarchar(1000)

, [EstimateMiles] int
, [IsMWG] bit
, [Revenue] decimal(18,6)
, [RevenueWithCM] decimal(18,6)
, [LastViewedDate] datetime
, [LastViewedByUserName] nvarchar(150)
, [LastViewedByFullName] nvarchar(250)
, [LastViewedByDept] nvarchar(150)
)
AS
begin
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @BillCustomerTable table
	([ORDER_ID] int
	, [BillTo_CUSTOMER_NO] nvarchar(20)
	, [BillTo_CUSTOMER_NAME] nvarchar(250)
	, [BillToSub_CUSTOMER_NO] nvarchar(20)
	, [BillToSub_CUSTOMER_NAME] nvarchar(250)
	, [BillTo_ADDRESS_CODE] nvarchar(50)
	, [BillTo_FirstName] nvarchar(50)
	, [BillTo_MiddleName] nvarchar(50)
	, [BillTo_LastName] nvarchar(50)
	, [BillTo_Company] nvarchar(250)
	, [BillTo_ContactPerson] nvarchar(150)
	, [BillTo_Address] nvarchar(250)
	, [BillTo_Address2] nvarchar(250)
	, [BillTo_City] nvarchar(50)
	, [BillTo_State] nvarchar(20)
	, [BillTo_ZipCode] nvarchar(20)
	, [BillTo_County] nvarchar(50)
	, [BillTo_CountryRegionCode] nvarchar(10)
	, [BillTo_Email] nvarchar(250)
	, [BillTo_Mobile] nvarchar(30)
	, [BillTo_Phone] nvarchar(20)
	, [BillTo_PhoneExt] nvarchar(10)
	, [CreditLimit] decimal(18,2)
	, [AvailableLimit] decimal(18,2)
	, [Balance] decimal(18,2)
	, [PaymentTermsCode] nvarchar(20)
	, [PaymentTermsName] nvarchar(50))

	insert into @BillCustomerTable
	SELECT o.[ORDER_ID] 
	,o.[BillTo_CUSTOMER_NO] ,[BillTo_CUSTOMER_NAME]=c.[Name]
	,o.[BillToSub_CUSTOMER_NO] ,[BillToSub_CUSTOMER_NAME]=(case when isnull(o.[BillToSub_CUSTOMER_NO],'') = '' then '' else 'Sub Customer Name Not Setup' end)
	,o.[BillTo_ADDRESS_CODE]
	,[BillTo_FirstName]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[Name] else o.[BillTo_FirstName] end)
	,[BillTo_MiddleName]=(case when o.[BillingType_MTV_CODE] in ('100','110') then '' else o.[BillTo_MiddleName] end)
	,[BillTo_LastName]=(case when o.[BillingType_MTV_CODE] in ('100','110') then '' else o.[BillTo_LastName] end)
	,[BillTo_Company]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[Name 2] else o.[BillTo_Company] end)
	,[BillTo_ContactPerson]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[Contact] else o.[BillTo_ContactPerson] end)
	,[BillTo_Address]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[Address] else o.[BillTo_Address] end)
	,[BillTo_Address2]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[Address 2] else o.[BillTo_Address2] end)
	,[BillTo_City]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[City] else o.[BillTo_City] end)
	,[BillTo_State]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[State] else o.[BillTo_State] end)
	,[BillTo_ZipCode]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[Post Code] else o.[BillTo_ZipCode] end)
	,[BillTo_County]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[County] else o.[BillTo_County] end)
	,[BillTo_CountryRegionCode]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[Country_Region Code] else o.[BillTo_CountryRegionCode] end)
	,[BillTo_Email]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[E-Mail] else o.[BillTo_Email] end)
	,[BillTo_Mobile]=(case when o.[BillingType_MTV_CODE] in ('100','110') then c.[Mobile] else o.[BillTo_Mobile] end)
	,[BillTo_Phone]=(case when o.[BillingType_MTV_CODE] in ('100','110') then bph.[PhoneNo] else o.[BillTo_Phone] end)
	,[BillTo_PhoneExt]=(case when o.[BillingType_MTV_CODE] in ('100','110') then bph.[Extension] else o.[BillTo_PhoneExt] end)
	,[CreditLimit] = c.[Credit Limit (LCY)]
	,[AvailableLimit] = isnull(gpd.[AvailableLimit],0)
	,[Balance] = isnull(gpd.[Balance],0)
	,[PaymentTermsCode] = c.[Payment Terms Code]
	,[PaymentTermsName] = isnull((select top 1 pt.[Description] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Payment Terms] pt with (nolock) where pt.[Code] = c.[Payment Terms Code]), '')

	FROM [POMSArchive_DB].[dbo].[T_Order] o with (nolock) 
	inner join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on o.[BillTo_CUSTOMER_NO] = c.No_ collate Latin1_General_100_CS_AS
	outer apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](c.[Phone No_]) bph
	outer apply [PinnacleProd].[dbo].[fn_ToGetPaymentDetail] (c.[No_]) gpd
	where o.ORDER_ID = @ORDER_ID

	insert into @ReturnTable ([ORDER_ID] , [PARENT_ORDER_ID] , [TRACKING_NO] , [Pickup_OG_ID] , [Pickup_OG_Name] , [Delivery_OG_ID] , [Delivery_OG_Name] 
	, [OrderStatus_MTV_ID] , [OrderStatus_Name] , [OrderSource_MTV_ID] , [OrderSource_Name] , [OrderPriority_MTV_ID] , [OrderPriority_Name] 
	, [ShippingStatus_EVENT_ID] , [ShippingStatus_EVENT_Name] , [QuoteID] , [QuoteAmount] , [SELLER_CODE] , [SELLER_NAME] , [SUB_SELLER_CODE] 
	, [SUB_SELLER_NAME] , [SELLER_PARTNER_CODE] , [SELLER_PARTNER_NAME] , [TARIFF_NO] , [TARIFF_NAME] , [EstimateRevenue] , [ActualRevenue] 
	, [InvoiceType_MTV_ID] , [InvoiceType_Name] , [OrderType_MTV_ID] , [OrderType_Name] , [SubOrderType_ID] , [SubOrderType_Name] , [OrderCreatedOn] 
	, [OrderCreatedBy] , [LastLocation] , [DocsCount] , [PublicComments] , [PrivateComments] , [ActivitiesEvent] , [ScansCount] , [CurrentAssignToDept_MTV_CODE] 
	, [CurrentAssignToDept_Name] , [ShipFrom_ADDRESS_CODE] , [ShipFrom_FirstName] 
	, [ShipFrom_MiddleName] , [ShipFrom_LastName] , [ShipFrom_Company] , [ShipFrom_ContactPerson] , [ShipFrom_Address] , [ShipFrom_Address2] , [ShipFrom_City] 
	, [ShipFrom_State] , [ShipFrom_ZipCode] , [ShipFrom_County] , [ShipFrom_CountryRegionCode] , [ShipFrom_Email] , [ShipFrom_Mobile] , [ShipFrom_Phone] 
	, [ShipFrom_PhoneExt] , [ShipFrom_Lat] , [ShipFrom_Lng] , [ShipFrom_PlaceID] , [ShipFrom_AreaType_MTV_ID] , [ShipFrom_AreaType_Name] , [ShipFrom_HUB_CODE] 
	, [ShipFrom_HUB_Name] , [LiveShipFrom_HUB_CODE] , [LiveShipFrom_HUB_Name] , [ShipFrom_ZONE_CODE] , [ShipFrom_ZONE_Name] , [ShipFrom_ChangeCount] 
	, [ShipTo_ADDRESS_CODE] , [ShipTo_FirstName] , [ShipTo_MiddleName] , [ShipTo_LastName] , [ShipTo_Company] , [ShipTo_ContactPerson] , [ShipTo_Address] 
	, [ShipTo_Address2] , [ShipTo_City] , [ShipTo_State] , [ShipTo_ZipCode] , [ShipTo_County] , [ShipTo_CountryRegionCode] , [ShipTo_Email] , [ShipTo_Mobile] 
	, [ShipTo_Phone] , [ShipTo_PhoneExt] , [ShipTo_Lat] , [ShipTo_Lng] , [ShipTo_PlaceID] , [ShipTo_AreaType_MTV_ID] , [ShipTo_AreaType_Name] , [ShipTo_HUB_CODE] 
	, [ShipTo_HUB_Name] , [LiveShipTo_HUB_CODE] , [LiveShipTo_HUB_Name] , [ShipTo_ZONE_CODE] , [ShipTo_ZONE_Name] , [IsBlindShipTo] , [ShipTo_ChangeCount] 
	, [InsuranceRequired] , [BillingType_MTV_CODE] , [BillingType_Name] , [BillTo_CUSTOMER_NO] , [BillTo_CUSTOMER_NAME] , [BillToSub_CUSTOMER_NO] 
	, [BillToSub_CUSTOMER_NAME] , [BillTo_ADDRESS_CODE] , [BillTo_FirstName] , [BillTo_MiddleName] , [BillTo_LastName] , [BillTo_Company] , [BillTo_ContactPerson] 
	, [BillTo_Address] , [BillTo_Address2] , [BillTo_City] , [BillTo_State] , [BillTo_ZipCode] , [BillTo_County] , [BillTo_CountryRegionCode] , [BillTo_Email] 
	, [BillTo_Mobile] , [BillTo_Phone] , [BillTo_PhoneExt] , [PaymentStatusID] , [PaymentStatusName] , [CreditLimit] , [AvailableLimit] , [Balance] 
	, [PaymentTermsCode] , [PaymentTermsName] , [DepartmentCode] , [DepartmentName] , [ReqPickup_Date] , [ReqPickup_FromTime] , [ReqPickup_ToTime] 
	, [ReqPickup_TimeName] , [FirstOffered_PickupDate] , [PickupScheduleType_MTV_ID] , [PickupScheduleType_Name] , [PromisedPickupDate] , [PkpSchByUserName] 
	, [ReqPickupTimeFrame_TFL_ID] , [ReqPickupTimeFrame_TFL_Name] , [ConfirmedPickupTimeFrame_TFL_ID] , [ConfirmedPickupTimeFrame_TFL_Name] , [ActualPickupDate] 
	, [PickupManifest] , [PICKUP_ST_CODE] , [PICKUP_ST_NAME] , [PICKUP_SST_CODE] , [PICKUP_SST_NAME] , [Pickup_Instruction] , [ReqDelivery_Date] 
	, [ReqDelivery_FromTime] , [ReqDelivery_ToTime] , [ReqDelivery_TimeName] , [FirstOffered_DeliveryDate] , [DeliveryScheduleType_MTV_ID] 
	, [DeliveryScheduleType_Name] , [PromisedDeliveryDate] , [DlvSchByUserName] , [ReqDeliveryTimeFrame_TFL_ID] , [ReqDeliveryTimeFrame_TFL_Name] 
	, [ConfirmedDeliveryTimeFrame_TFL_ID] , [ConfirmedDeliveryTimeFrame_TFL_Name] , [ActualDeliveryDate] , [DeliveryManifest] , [DELIVERY_ST_CODE] 
	, [DELIVERY_ST_NAME] , [DELIVERY_SST_CODE] , [DELIVERY_SST_NAME] , [Delivery_Instruction], [EstimateMiles] , [IsMWG] , [Revenue] , [RevenueWithCM] 
	, [LastViewedDate] 	, [LastViewedByUserName] , [LastViewedByFullName] , [LastViewedByDept])

	SELECT o.[ORDER_ID] ,o.[PARENT_ORDER_ID] ,o.[TRACKING_NO] 
	,o.[Pickup_OG_ID] ,[Pickup_OG_Name]=[POMS_DB].[dbo].[F_Get_OG_Name_From_OG_ID] (o.[Pickup_OG_ID])
	,o.[Delivery_OG_ID] ,[Delivery_OG_Name]=[POMS_DB].[dbo].[F_Get_OG_Name_From_OG_ID] (o.[Delivery_OG_ID])
	,o.[OrderStatus_MTV_ID] ,[OrderStatus_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.[OrderStatus_MTV_ID])
	,o.[OrderSource_MTV_ID] ,[OrderSource_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.[OrderSource_MTV_ID])
	,o.[OrderPriority_MTV_ID] ,[OrderPriority_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.[OrderPriority_MTV_ID])
	,o.[ShippingStatus_EVENT_ID] ,[ShippingStatus_EVENT_Name]=[POMS_DB].[dbo].[F_Get_EventName_From_EventID] (o.[ShippingStatus_EVENT_ID])
	,o.[QuoteID] ,o.[QuoteAmount]
	,o.[SELLER_CODE] ,[SELLER_NAME]=[POMS_DB].[dbo].[F_Get_Seller_Name_From_SellerCode] (o.[SELLER_CODE])
	,o.[SUB_SELLER_CODE] ,[SUB_SELLER_NAME]=[POMS_DB].[dbo].[F_Get_Sub_Seller_Name_From_SubSellerCode] (o.[SUB_SELLER_CODE])
	,o.[SELLER_PARTNER_CODE] ,[SELLER_PARTNER_NAME]=[POMS_DB].[dbo].[F_Get_Seller_Partner_Name_From_SellerPartnerCode] (o.[SELLER_PARTNER_CODE])
	,o.[TARIFF_NO] ,[TARIFF_NAME]=[POMS_DB].[dbo].[F_Get_TariffName_From_TariffNo] (o.[TARIFF_NO])
	,od.[EstimateRevenue]
	,od.[ActualRevenue]
	,od.[InvoiceType_MTV_ID] ,[InvoiceType_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (od.[InvoiceType_MTV_ID])
	,od.[OrderType_MTV_ID] ,[OrderType_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (od.[OrderType_MTV_ID])
	,od.[SubOrderType_ID] ,[SubOrderType_Name] = '' -- Not Available
	,[OrderCreatedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (o.[ShipmentRegDate], @TimeZone_ID, null ,@TimeZoneName) ,[OrderCreatedBy] = o.[CreatedBy]
	,[LastLocation] = isnull(odi.LastScanLocationID, '')
	,[DocsCount] = (select count(odoc.OD_ID) from [POMSArchive_DB].[dbo].[T_Order_Docs] odoc with (nolock) where odoc.ORDER_ID = o.ORDER_ID and ((odoc.[IsPublic] = 1 and @IsPublic = 1) or @IsPublic = 0))
	,[PublicComments] = (select count(oc.OC_ID) from [POMSArchive_DB].[dbo].[T_Order_Comments] oc with (nolock) where oc.ORDER_ID = o.ORDER_ID and oc.[IsPublic] = 1)
	,[PrivateComments] = (select count(oc.OC_ID) from [POMSArchive_DB].[dbo].[T_Order_Comments] oc with (nolock) where oc.ORDER_ID = o.ORDER_ID and oc.[IsPublic] = 0)
	,[ActivitiesEvent] = (select count(oe.OE_ID) from [POMSArchive_DB].[dbo].[T_Order_Events] oe with (nolock) where oe.ORDER_ID = o.ORDER_ID)
	,[ScansCount] = (select count(ois.OIS_ID) from [POMSArchive_DB].[dbo].[T_Order_Item_Scans] ois with (nolock) where ois.ORDER_ID = o.ORDER_ID)
	,od.[CurrentAssignToDept_MTV_CODE] ,[CurrentAssignToDept_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (od.[CurrentAssignToDept_MTV_CODE])
	,o.[ShipFrom_ADDRESS_CODE]
	,o.[ShipFrom_FirstName]
	,o.[ShipFrom_MiddleName]
	,o.[ShipFrom_LastName]
	,o.[ShipFrom_Company]
	,o.[ShipFrom_ContactPerson]
	,o.[ShipFrom_Address]
	,o.[ShipFrom_Address2]
	,o.[ShipFrom_City]
	,o.[ShipFrom_State]
	,o.[ShipFrom_ZipCode]
	,o.[ShipFrom_County]
	,o.[ShipFrom_CountryRegionCode]
	,o.[ShipFrom_Email]
	,o.[ShipFrom_Mobile]
	,o.[ShipFrom_Phone]
	,o.[ShipFrom_PhoneExt]
	,o.[ShipFrom_Lat]
	,o.[ShipFrom_Lng]
	,o.[ShipFrom_PlaceID]
	,o.[ShipFrom_AreaType_MTV_ID] ,[ShipFrom_AreaType_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.[ShipFrom_AreaType_MTV_ID])
	,o.[ShipFrom_HUB_CODE] ,[ShipFrom_HUB_Name]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.[ShipFrom_HUB_CODE])
	,o.[LiveShipFrom_HUB_CODE] ,[LiveShipFrom_HUB_Name]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.[LiveShipFrom_HUB_CODE])
	,o.[ShipFrom_ZONE_CODE] ,[ShipFrom_ZONE_Name]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.[ShipFrom_ZONE_CODE])
	,o.[ShipFrom_ChangeCount]
	,o.[ShipTo_ADDRESS_CODE]
	,o.[ShipTo_FirstName]
	,o.[ShipTo_MiddleName]
	,o.[ShipTo_LastName]
	,o.[ShipTo_Company]
	,o.[ShipTo_ContactPerson]
	,o.[ShipTo_Address]
	,o.[ShipTo_Address2]
	,o.[ShipTo_City]
	,o.[ShipTo_State]
	,o.[ShipTo_ZipCode]
	,o.[ShipTo_County]
	,o.[ShipTo_CountryRegionCode]
	,o.[ShipTo_Email]
	,o.[ShipTo_Mobile]
	,o.[ShipTo_Phone]
	,o.[ShipTo_PhoneExt]
	,o.[ShipTo_Lat]
	,o.[ShipTo_Lng]
	,o.[ShipTo_PlaceID]
	,o.[ShipTo_AreaType_MTV_ID] ,[ShipTo_AreaType_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.[ShipTo_AreaType_MTV_ID])
	,o.[ShipTo_HUB_CODE] ,[ShipTo_HUB_Name]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.[ShipTo_HUB_CODE])
	,o.[LiveShipTo_HUB_CODE] ,[LiveShipTo_HUB_Name]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.[LiveShipTo_HUB_CODE])
	,o.[ShipTo_ZONE_CODE] ,[ShipTo_ZONE_Name]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.[ShipTo_ZONE_CODE])
	,o.[IsBlindShipTo]
	,o.[ShipTo_ChangeCount]
	,o.[InsuranceRequired]
	,o.[BillingType_MTV_CODE] ,[BillingType_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (o.[BillingType_MTV_CODE])
	,bct.[BillTo_CUSTOMER_NO] ,bct.[BillTo_CUSTOMER_NAME]
	,bct.[BillToSub_CUSTOMER_NO] ,bct.[BillToSub_CUSTOMER_NAME]
	,bct.[BillTo_ADDRESS_CODE] ,bct.[BillTo_FirstName] ,bct.[BillTo_MiddleName] ,bct.[BillTo_LastName] ,bct.[BillTo_Company] ,bct.[BillTo_ContactPerson] 
	,bct.[BillTo_Address] ,bct.[BillTo_Address2] ,bct.[BillTo_City] ,bct.[BillTo_State] ,bct.[BillTo_ZipCode] ,bct.[BillTo_County] ,bct.[BillTo_CountryRegionCode] 
	,bct.[BillTo_Email] ,bct.[BillTo_Mobile] ,bct.[BillTo_Phone] ,bct.[BillTo_PhoneExt] 
	,o.[PaymentStatus_MTV_ID] ,[PaymentStatusName]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.[PaymentStatus_MTV_ID])
	,bct.[CreditLimit] ,bct.[AvailableLimit] ,bct.[Balance] ,bct.[PaymentTermsCode] ,bct.[PaymentTermsName] 
	,[DepartmentCode] = (case when gdbs.D_ID is not null then cast(gdbs.D_ID as nvarchar(20)) else '' end)
	,[DepartmentName] = gdbs.DepartmentName

	,o.[ReqPickup_Date]
	,o.[ReqPickup_FromTime]
	,o.[ReqPickup_ToTime]
	,[ReqPickup_TimeName] = [POMS_DB].[dbo].[F_Get_TimeName_From_And_To_Time] (o.[ReqPickup_FromTime],o.[ReqPickup_ToTime])
	,o.[FirstOffered_PickupDate]
	,o.[PickupScheduleType_MTV_ID] ,[PickupScheduleType_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.[PickupScheduleType_MTV_ID])
	,o.[PromisedPickupDate]
	,o.[PkpSchByUserName]
	,o.[ReqPickupTimeFrame_TFL_ID] ,[ReqPickupTimeFrame_TFL_Name]=[POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.[ReqPickupTimeFrame_TFL_ID])
	,o.[ConfirmedPickupTimeFrame_TFL_ID] ,[ConfirmedPickupTimeFrame_TFL_Name]=[POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.[ConfirmedPickupTimeFrame_TFL_ID])
	,[ActualPickupDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC_Abbr] (o.[ActualPickupDate], null, o.[ShipFrom_HUB_CODE] ,null ,null)
	,[PickupManifest] = od.Last_Pickup_PP_MIN_ID
	,o.[PICKUP_ST_CODE] ,[PICKUP_ST_NAME]=[POMS_DB].[dbo].[F_Get_ServiceLevelName_From_ST_CODE] (o.[PICKUP_ST_CODE])
	,o.[PICKUP_SST_CODE] ,[PICKUP_SST_NAME]=[POMS_DB].[dbo].[F_Get_SubServiceLevelName_From_ST_CODE_And_SST_CODE] (o.[PICKUP_ST_CODE],o.[PICKUP_SST_CODE])
	,[Pickup_Instruction] = isnull((SELECT osi.[Instruction] FROM [POMSArchive_DB].[dbo].[T_Order_Special_Instruction] osi with (nolock) where osi.[ORDER_ID] = o.[ORDER_ID] and osi.[InstructionType_MTV_ID] = 124100),'')
	,o.[ReqDelivery_Date]
	,o.[ReqDelivery_FromTime]
	,o.[ReqDelivery_ToTime]
	,[ReqDelivery_TimeName] = [POMS_DB].[dbo].[F_Get_TimeName_From_And_To_Time] (o.[ReqDelivery_FromTime],o.[ReqDelivery_ToTime])
	,o.[FirstOffered_DeliveryDate]
	,o.[DeliveryScheduleType_MTV_ID] ,[DeliveryScheduleType_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.[DeliveryScheduleType_MTV_ID])
	,o.[PromisedDeliveryDate]
	,o.[DlvSchByUserName]
	,o.[ReqDeliveryTimeFrame_TFL_ID] ,[ReqDeliveryTimeFrame_TFL_Name]=[POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.[ReqDeliveryTimeFrame_TFL_ID])
	,o.[ConfirmedDeliveryTimeFrame_TFL_ID] ,[ConfirmedDeliveryTimeFrame_TFL_Name]=[POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.[ConfirmedDeliveryTimeFrame_TFL_ID])
	,[ActualDeliveryDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC_Abbr] (o.[ActualDeliveryDate], null, o.[ShipTo_HUB_CODE] ,null ,null)
	,[DeliveryManifest] = od.Last_Delivery_PP_MIN_ID
	,o.[DELIVERY_ST_CODE] ,[DELIVERY_ST_NAME]=[POMS_DB].[dbo].[F_Get_ServiceLevelName_From_ST_CODE] (o.[DELIVERY_ST_CODE])
	,o.[DELIVERY_SST_CODE] ,[DELIVERY_SST_NAME]=[POMS_DB].[dbo].[F_Get_SubServiceLevelName_From_ST_CODE_And_SST_CODE] (o.[DELIVERY_ST_CODE],o.[DELIVERY_SST_CODE])
	,[Delivery_Instruction] = isnull((SELECT osi.[Instruction] FROM [POMSArchive_DB].[dbo].[T_Order_Special_Instruction] osi with (nolock) where osi.[ORDER_ID] = o.[ORDER_ID] and osi.[InstructionType_MTV_ID] = 124101),'')
	,od.[EstimateMiles] 
	,od.[IsMWG] 
	,odi.[Revenue] 
	,odi.[RevenueWithCM] 
	,[LastViewedDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odi.[LastViewedDate], @TimeZone_ID, null ,@TimeZoneName)
	,odi.[LastViewedByUserName]
	,[LastViewedByFullName] = gfadbu.FullName
	,[LastViewedByDept] = gfadbu.DeptName
	
	FROM [POMSArchive_DB].[dbo].[T_Order] o with (nolock) 
	left join @BillCustomerTable bct on o.ORDER_ID = bct.ORDER_ID
	left join [POMSArchive_DB].[dbo].[T_Order_Detail] od with (nolock) on o.ORDER_ID = od.ORDER_ID
	left join [POMSArchive_DB].[dbo].[T_Order_Additional_Info] odi with (nolock) on o.ORDER_ID = odi.ORDER_ID
	outer apply [POMS_DB].[dbo].[F_Get_Department_By_SellerCode] (o.SELLER_CODE) gdbs
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (odi.[LastViewedByUserName]) gfadbu
	where o.ORDER_ID = @ORDER_ID

	return
	

end
GO
