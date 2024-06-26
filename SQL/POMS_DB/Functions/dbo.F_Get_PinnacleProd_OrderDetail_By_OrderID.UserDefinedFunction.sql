USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_By_OrderID] (3251652,'ABDULLAH.ARSHAD',2,1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_By_OrderID]
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

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	Declare @BillCustomerTable table
	([ORDER_NO] nvarchar(20)
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
	, [PaymentTermsName] nvarchar(50)
	, [DepartmentCode] nvarchar(20))

	insert into @BillCustomerTable
	SELECT [ORDER_NO] = sh.No_
	,[BillTo_CUSTOMER_NO]=sh.[Bill-to Customer No_] ,[BillTo_CUSTOMER_NAME]=c.[Name]
	,[BillToSub_CUSTOMER_NO]=sh.SubCustomerNo ,[BillToSub_CUSTOMER_NAME]=(case when isnull(sh.SubCustomerNo,'') = '' then '' else 'Sub Customer Name Not Setup' end)
	,[BillTo_ADDRESS_CODE]=''
	,[BillTo_FirstName] = (case when sh.[Payment Method Code] in ('','100','110') then c.[Name] else sh.[Bill-to Name] end)
	,[BillTo_MiddleName] = ''
	,[BillTo_LastName] = ''
	,[BillTo_Company] = (case when sh.[Payment Method Code] in ('','100','110') then c.[Name 2] else sh.[Bill-to Name 2] end)
	,[BillTo_ContactPerson] = (case when sh.[Payment Method Code] in ('','100','110') then c.[Contact] else sh.[Bill-to Contact] end)
	,[BillTo_Address] = (case when sh.[Payment Method Code] in ('','100','110') then c.[Address] else sh.[Bill-to Address] end)
	,[BillTo_Address2] = (case when sh.[Payment Method Code] in ('','100','110') then c.[Address 2] else sh.[Bill-to Address 2] end)
	,[BillTo_City] = (case when sh.[Payment Method Code] in ('','100','110') then c.[City] else sh.[Bill-to City] end)
	,[BillTo_State] = (case when sh.[Payment Method Code] in ('','100','110') then c.[State] else sh.[Bill-to State] end)
	,[BillTo_ZipCode] = (case when sh.[Payment Method Code] in ('','100','110') then c.[Post Code] else sh.[Bill-to Post Code] end)
	,[BillTo_County] = (case when sh.[Payment Method Code] in ('','100','110') then c.[County] else sh.[Bill-to County] end)
	,[BillTo_CountryRegionCode] = (case when sh.[Payment Method Code] in ('','100','110') then c.[Country_Region Code] else sh.[Bill-to Country_Region Code] end)
	,[BillTo_Email] = (case when sh.[Payment Method Code] in ('','100','110') then c.[E-Mail] else sh.[Bill-to Email] end)
	,[BillTo_Mobile] = (case when sh.[Payment Method Code] in ('','100','110') then c.[Mobile] else sh.[Bill-to Mobile] end)
	,[BillTo_Phone] = (case when sh.[Payment Method Code] in ('','100','110') then bph.[PhoneNo] else sph.[PhoneNo] end)
	,[BillTo_PhoneExt] = (case when sh.[Payment Method Code] in ('','100','110') then bph.[Extension] else sph.[Extension] end)
	,[CreditLimit] = c.[Credit Limit (LCY)]
	,[AvailableLimit] = isnull(gpd.[AvailableLimit],0)
	,[Balance] = isnull(gpd.[Balance],0)
	,[PaymentTermsCode] = c.[Payment Terms Code]
	,[PaymentTermsName] = isnull((select top 1 pt.[Description] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Payment Terms] pt with (nolock) where pt.[Code] = c.[Payment Terms Code]), '')
	,[DepartmentCode] = c.[Department Code]

	FROM [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
	inner join [PinnacleProd].[dbo].[Metropolitan$Customer] c with (nolock) on sh.[Bill-to Customer No_] = c.No_ 
	outer apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](sh.[Bill-to Phone]) sph
	outer apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](c.[Phone No_]) bph
	outer apply [PinnacleProd].[dbo].[fn_ToGetPaymentDetail] (sh.[Bill-to Customer No_]) gpd
	where sh.No_ = @ORDER_NO

	Declare @Comments_ArchiveDt datetime = null
	Declare @EventLog_ArchiveDt datetime = null
	Declare @ScanHistory_ArchiveDt datetime = null
	Declare @AuditHistory_ArchiveDt datetime = null
	Declare @EmailLog_ArchiveDt datetime = null
	Declare @AccessLog_ArchiveDt datetime = null
	Declare @EventCount int = 0
	Declare @ScanCount int = 0

	if @GetRecordType_MTV_ID = 147105
	begin
		Select @Comments_ArchiveDt = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (Comments_ArchiveDt, @TimeZone_ID, null ,@TimeZoneName)
		,@EventLog_ArchiveDt = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (EventLog_ArchiveDt, @TimeZone_ID, null ,@TimeZoneName)
		,@ScanHistory_ArchiveDt = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ScanHistory_ArchiveDt, @TimeZone_ID, null ,@TimeZoneName)
		,@AuditHistory_ArchiveDt = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (AuditHistory_ArchiveDt, @TimeZone_ID, null ,@TimeZoneName)
		,@EmailLog_ArchiveDt = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (EmailLog_ArchiveDt, @TimeZone_ID, null ,@TimeZoneName)
		,@AccessLog_ArchiveDt = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (AccessLog_ArchiveDt, @TimeZone_ID, null ,@TimeZoneName)
		,@EventCount = EventCount
		,@ScanCount = [ScanCount]
		from [PinnacleProd].[dbo].[Metropolitan_OrderArchivalSummary] with (nolock) where [OrderNo] = @ORDER_NO
	end

	Declare @Is_Archive bit = 0
	If (@Comments_ArchiveDt is not null or @EventLog_ArchiveDt is not null or @ScanHistory_ArchiveDt is not null)
	begin
		set @Is_Archive = 1
	end

	Declare @callsattempted int = 0
	Declare @publiccommentcount int = 0
	Declare @privatecommentcount int = 0

	Select @callsattempted = sum((case when C.[Is Call] = 1 then 1 else 0 end))
	,@publiccommentcount = sum((case when C.[IsPublic] = 1 then 1 else 0 end))
	,@privatecommentcount = sum((case when C.[IsPublic] = 0 then 1 else 0 end))
	from [PinnacleProd].[dbo].[Metropolitan$Comments] C with (nolock) 
	where C.[Order ID] = @ORDER_NO and C.[Active Status] = 1
	group by C.[Order ID]

	if @Comments_ArchiveDt is not null and @GetRecordType_MTV_ID = 147105
	begin
		Select @callsattempted = @callsattempted + (sum((case when C.[Is Call] = 1 then 1 else 0 end)))
		,@publiccommentcount = @publiccommentcount + (sum((case when C.[IsPublic] = 1 then 1 else 0 end)))
		,@privatecommentcount = @privatecommentcount + (sum((case when C.[IsPublic] = 0 then 1 else 0 end)))
		from [PinnacleArchiveDB].[dbo].[Metropolitan$Comments] C with (nolock) 
		where C.[Order ID] = @ORDER_NO and C.[Active Status] = 1
		group by C.[Order ID]
	end

	declare @lastViewUser nvarchar(250), @lastViewDept nvarchar(250), @lastViewDt datetime
	select top 1 
	@lastViewUser = isnull((Case when isnull(wul.[First Name],'') = '' and isnull(wul.[Last Name],'') = '' then wul.Username
		when isnull(wul.[First Name],'') <> '' and isnull(wul.[Last Name],'') = '' then wul.[First Name]
		when isnull(wul.[First Name],'') = '' and isnull(wul.[Last Name],'') <> '' then wul.[Last Name]
		when isnull(wul.[First Name],'') <> '' and isnull(wul.[Last Name],'') <> '' then ltrim(rtrim(wul.[First Name])) + ' ' + ltrim(rtrim(wul.[Last Name]))
		else wul.Username end),'')
	, @lastViewDt = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.LastViewedDate, @TimeZone_ID, null ,@TimeZoneName)
	, @lastViewDept = mtv.[Description]
	from [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock)
	left join [PinnacleProd].[dbo].[Metropolitan$Web User Login] wul with (nolock) on wul.[Username] = od.[LastViewedByUser]
	left join [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) on mtv.[Master Type ID] = 10020 and mtv.[ID] = wul.[Department]
	where	od.[OrderNo] = @ORDER_NO

	Declare @ActualRevenue decimal(18,6) = 0
	Declare @EstimatedRevenue decimal(18,6) = 0
	SELECT 
	@ActualRevenue = isnull((case when seh.[Invoice Status] = (30000) 
	then (Select sum([Amount]) from [MetroPolitanNavProduction].[dbo].[Metropolitan$G_L Entry] with(nolock) where [Entry No_] = (select sih.[Cust_ Ledger Entry No_] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Sales Invoice Header] sih with(nolock) where sih.[Estimate Invoice No] = seh.[No_]))
	when seh.[Approval Status] in (1,2) then 
	(Select sum([Amount]) from [MetroPolitanNavProduction].[dbo].[Metropolitan$Sales Line]  with(nolock) where [Project ID]=seh.[Project ID] 
	and [Document Type] = 2 and [Document No_] in (Select sh.No_ from [MetroPolitanNavProduction].[dbo].[Metropolitan$Sales Header] sh where sh.[Estimate Invoice No] = seh.[No_] and sh.[Project ID] = seh.[Project ID]))
	else 0 end),0)
	,@EstimatedRevenue = isnull(seh.[Invoice Amount],0)
	from [MetroPolitanNavProduction].[dbo].[Metropolitan$Sales Estimate Header] seh with(nolock) where seh.[Project ID] = @ORDER_NO

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
	, [PaymentTermsCode] , [PaymentTermsName] , [DepartmentCode] , [DepartmentName] 
	, [ReqPickup_Date] , [ReqPickup_FromTime] , [ReqPickup_ToTime] , [ReqPickup_TimeName] , [FirstOffered_PickupDate] , [PickupScheduleType_MTV_ID] , [PickupScheduleType_Name] , [PromisedPickupDate] , [PkpSchByUserName] 
	, [ReqPickupTimeFrame_TFL_ID] , [ReqPickupTimeFrame_TFL_Name] , [ConfirmedPickupTimeFrame_TFL_ID] , [ConfirmedPickupTimeFrame_TFL_Name] , [ActualPickupDate] 
	, [PickupManifest] , [PICKUP_ST_CODE] , [PICKUP_ST_NAME] , [PICKUP_SST_CODE] , [PICKUP_SST_NAME] , [Pickup_Instruction] , [ReqDelivery_Date] 
	, [ReqDelivery_FromTime] , [ReqDelivery_ToTime] , [ReqDelivery_TimeName] , [FirstOffered_DeliveryDate] , [DeliveryScheduleType_MTV_ID] 
	, [DeliveryScheduleType_Name] , [PromisedDeliveryDate] , [DlvSchByUserName] , [ReqDeliveryTimeFrame_TFL_ID] , [ReqDeliveryTimeFrame_TFL_Name] 
	, [ConfirmedDeliveryTimeFrame_TFL_ID] , [ConfirmedDeliveryTimeFrame_TFL_Name] , [ActualDeliveryDate] , [DeliveryManifest] , [DELIVERY_ST_CODE] 
	, [DELIVERY_ST_NAME] , [DELIVERY_SST_CODE] , [DELIVERY_SST_NAME] , [Delivery_Instruction], [EstimateMiles] , [IsMWG] , [Revenue] , [RevenueWithCM] 
	, [LastViewedDate] 	, [LastViewedByUserName] , [LastViewedByFullName] , [LastViewedByDept])

	SELECT [ORDER_ID] = @ORDER_ID 
	,[PARENT_ORDER_ID] = (select ParentOrderNo from [PinnacleProd].[dbo].[Metropolitan_Clone_OrderRelation] co with(nolock) where co.[OrderNo] = sl.[Document No])
	,[TRACKING_NO] = sl.[Tracking No]
	,[Pickup_OG_ID] = null ,[Pickup_OG_Name]=''
	,[Delivery_OG_ID] = null,[Delivery_OG_Name]=''
	,[OrderStatus_MTV_ID] = sh.[Order Status]
	,[OrderStatus_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.[ID] = sh.[Order Status]), '')
	,[OrderSource_MTV_ID] = sh.[Order Source]
	,[OrderSource_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10070 and mtv.[ID] = sh.[Order Source]), '')
	,[OrderPriority_MTV_ID] = sh.[Priority]
	,[OrderPriority_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10250 and mtv.[ID] = sh.[Priority]), '')
	,[ShippingStatus_EVENT_ID] = sh.[Shipping Status]
	,[ShippingStatus_EVENT_Name]=isnull((select top 1 evm.[Events] from [PinnacleProd].[dbo].[Metropolitan$Event Master] evm with (nolock) where evm.[Entry No] = sh.[Shipping Status]), '')
	,[QuoteID] = od.Quote_ID ,[QuoteAmount] = od.Quote_Amount
	,[SELLER_CODE] = replace(bct.[BillTo_CUSTOMER_NO],'C','S')
	,[SELLER_NAME]=bct.[BillTo_CUSTOMER_NAME]
	,[SUB_SELLER_CODE] = ''
	,[SUB_SELLER_NAME]=''
	,[SELLER_PARTNER_CODE] = ''
	,[SELLER_PARTNER_NAME]=''
	,[TARIFF_NO] = sh.TariffID
	,[TARIFF_NAME]=[POMS_DB].[dbo].[F_Get_PinnacleProd_TariffName_From_TariffID] (sh.TariffID)
	,[EstimateRevenue]=@EstimatedRevenue
	,[ActualRevenue]=@ActualRevenue
	,[InvoiceType_MTV_ID] = sl.[InvoiceType]
	,[InvoiceType_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10540 and mtv.[ID] = sl.[InvoiceType]), '')
	,[OrderType_MTV_ID] = sl.[OrderType]
	,[OrderType_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10550 and mtv.[ID] = sl.[OrderType]), '')
	,[SubOrderType_ID] = sl.[SubOrderType]
	,[SubOrderType_Name] = isnull((select sotv.[Name] from [PinnacleProd].[dbo].[T_Sub_Order_Type_Value] sotv with (nolock) where sotv.[Order_Type_ID] = sl.[OrderType] and sotv.[Sub_Order_Type_ID] = sl.[SubOrderType]), '')
	,[OrderCreatedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sh.[Create Time], @TimeZone_ID, null ,@TimeZoneName)
	,[OrderCreatedBy] = isnull((select top 1 wul.[FullName] from [PinnacleProd].[dbo].[vw_Metro_WebUsers] wul with (nolock) where wul.[Username]= sh.[Web User Name]), '')
	,[LastLocation] = isnull(od.LastScanLocationID, '')
	,[DocsCount] = (select count([Entry No]) from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock) where img.[Order No] = sh.No_ and img.[Path] <> '' and img.[Master Type ID] = 10110 and ((img.[Private] = 1 and @IsPublic = 0) or @IsPublic = 1))
	,[PublicComments] = @publiccommentcount
	,[PrivateComments] = @privatecommentcount
	,[ActivitiesEvent] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Event Master Log] eml with (nolock) where eml.[Order Number] = sh.[No_]) + @EventCount
	,[ScansCount] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) where bsh.[Order No] = sh.[No_]) + @ScanCount
	,[CurrentAssignToDept_MTV_CODE] = (case sl.[Current Assigned Dept_]
		when 10000 then 'OED'
		when 20000 then 'CSR'
		when 30000 then 'DISPATCH'
		when 40000 then 'ACCOUNT'
		else '' end)
	,[CurrentAssignToDept_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10020 and mtv.[ID] = sl.[Current Assigned Dept_]), '')
	,[ShipFrom_ADDRESS_CODE]=''
	,[ShipFrom_FirstName]=sh.[Ship-from Name]
	,[ShipFrom_MiddleName]=''
	,[ShipFrom_LastName]=''
	,[ShipFrom_Company]=sh.[Ship-from Name 2]
	,[ShipFrom_ContactPerson]=sh.[Ship-from Contact]
	,[ShipFrom_Address]=sh.[Ship-from Address]
	,[ShipFrom_Address2]=sh.[Ship-from Address 2]
	,[ShipFrom_City]=sh.[Ship-from City]
	,[ShipFrom_State]=left(sh.[Ship-from State],5)
	,[ShipFrom_ZipCode]=sh.[Ship-from Post Code]
	,[ShipFrom_County]=sh.[Ship-from County]
	,[ShipFrom_CountryRegionCode]=sh.[Ship-from Country_Region Code]
	,[ShipFrom_Email]=sl.[Ship from Email]
	,[ShipFrom_Mobile]=sh.[Ship-from Mobile]
	,[ShipFrom_Phone]=oph.[PhoneNo]
	,[ShipFrom_PhoneExt]=oph.[Extension]
	,[ShipFrom_Lat]=oll.Text1
	,[ShipFrom_Lng]=oll.Text2
	,[ShipFrom_PlaceID]=od.OriginPlaceID
	,[ShipFrom_AreaType_MTV_ID] = od.OrigAreaType
	,[ShipFrom_AreaType_Name]=isnull((Select [Name] From [PPlus_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 150 and MTV_ID = od.OrigAreaType),'')
	,[ShipFrom_HUB_CODE] = od.OrigHub
	,[ShipFrom_HUB_Name]=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (od.OrigHub)
	,[LiveShipFrom_HUB_CODE] = od.LiveOrigHub
	,[LiveShipFrom_HUB_Name]=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (od.LiveOrigHub)
	,[ShipFrom_ZONE_CODE] = od.OrigZone
	,[ShipFrom_ZONE_Name]=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (od.OrigZone)
	,[ShipFrom_ChangeCount]=0
	,[ShipTo_ADDRESS_CODE]=0
	,[ShipTo_FirstName]=sh.[Destination Name]
	,[ShipTo_MiddleName]=''
	,[ShipTo_LastName]=''
	,[ShipTo_Company]=sh.[Ship-to Name]
	,[ShipTo_ContactPerson]=sh.[Ship-to Contact]
	,[ShipTo_Address]=sh.[Ship-to Address]
	,[ShipTo_Address2]=sh.[Ship-to Address 2]
	,[ShipTo_City]=sh.[Ship-to City]
	,[ShipTo_State]=left(sh.[Ship-to State],5)
	,[ShipTo_ZipCode]=sh.[Ship-to Post Code]
	,[ShipTo_County]=sh.[Ship-to County]
	,[ShipTo_CountryRegionCode]=sh.[Ship-to Country_Region Code]
	,[ShipTo_Email]=sl.[Ship to Email]
	,[ShipTo_Mobile]=sh.[Ship-to Mobile]
	,[ShipTo_Phone]=dph.[PhoneNo]
	,[ShipTo_PhoneExt]=dph.[Extension]
	,[ShipTo_Lat]=dll.Text1
	,[ShipTo_Lng]=dll.Text2
	,[ShipTo_PlaceID]=od.DestinationPlaceID
	,[ShipTo_AreaType_MTV_ID] = od.DestAreaType
	,[ShipTo_AreaType_Name]=isnull((Select [Name] From [PPlus_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 150 and MTV_ID = od.DestAreaType),'')
	,[ShipTo_HUB_CODE] = od.DestHub
	,[ShipTo_HUB_Name]=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (od.DestHub)
	,[LiveShipTo_HUB_CODE] = od.LiveDestHub
	,[LiveShipTo_HUB_Name]=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (od.LiveDestHub)
	,[ShipTo_ZONE_CODE] = od.DestZone
	,[ShipTo_ZONE_Name]=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (od.DestZone)
	,[IsBlindShipTo]=cast(sh.[Blind Shippment] as bit)
	,[ShipTo_ChangeCount]=od.DestHub_ChangeCount
	,[InsuranceRequired]=null
	,[BillingType_MTV_CODE] = ''
	,[BillingType_Name]=isnull((select top 1 pm.[Description] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Payment Method] pm with (nolock) where pm.[Code] = sh.[Payment Method Code]), '')
	,bct.[BillTo_CUSTOMER_NO] ,bct.[BillTo_CUSTOMER_NAME]
	,bct.[BillToSub_CUSTOMER_NO] ,bct.[BillToSub_CUSTOMER_NAME]
	,bct.[BillTo_ADDRESS_CODE] ,bct.[BillTo_FirstName] ,bct.[BillTo_MiddleName] ,bct.[BillTo_LastName] ,bct.[BillTo_Company] ,bct.[BillTo_ContactPerson] 
	,bct.[BillTo_Address] ,bct.[BillTo_Address2] ,bct.[BillTo_City] ,bct.[BillTo_State] ,bct.[BillTo_ZipCode] ,bct.[BillTo_County] ,bct.[BillTo_CountryRegionCode] 
	,bct.[BillTo_Email] ,bct.[BillTo_Mobile] ,bct.[BillTo_Phone] ,bct.[BillTo_PhoneExt] 
	,[PaymentStatus_MTV_ID] = 0
	,[PaymentStatusName]=case sl.[PaymentStatus] when 0 then 'Current' when 1 then 'Past Due' when 2 then 'Order Hold' else '' end
	,bct.[CreditLimit] ,bct.[AvailableLimit] ,bct.[Balance] ,bct.[PaymentTermsCode] ,bct.[PaymentTermsName] 
	,[DepartmentCode] = bct.[DepartmentCode]
	,[DepartmentName] = isnull((select top 1 d.[Description] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Department] d with (nolock) where d.[Code] = bct.[DepartmentCode] collate Latin1_General_100_CS_AS), '')

	,[ReqPickup_Date]=sl.[Requested Pickup Date]
	,[ReqPickup_FromTime]=sl.[Requested Pickup  From Time]
	,[ReqPickup_ToTime]=sl.[Requested Pickup To Time]
	,[ReqPickup_TimeName] = (case when sl.[Requested Pickup  From Time] is not null and isnull(sl.[Requested Pickup  From Time],'') <> isnull(sl.[Requested Pickup To Time],'') then format(cast(sl.[Requested Pickup  From Time] as datetime),'hh:mm tt') else '' end)
	+ (case when sl.[Requested Pickup To Time] is not null and isnull(sl.[Requested Pickup  From Time],'') <> isnull(sl.[Requested Pickup To Time],'') then ' To ' + format(cast(sl.[Requested Pickup To Time] as datetime),'hh:mm tt') else '' end)
	,[FirstOffered_PickupDate]=null
	,[PickupScheduleType_MTV_ID] = 0
	,[PickupScheduleType_Name]=[POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10520,sl.[Pickup Schedule Type])
	,[PromisedPickupDate]=sl.[Promised Pickup Date]
	,[PkpSchByUserName]=od.PkpSchByUsername
	,[ReqPickupTimeFrame_TFL_ID] = 0
	,[ReqPickupTimeFrame_TFL_Name]=isnull((select top 1 tw.[TimeWindow] from [PinnacleProd].[dbo].[Metropolitan$Time Windows] tw with (nolock) where tw.[TimeWindowID] = sl.[Requested Pkp Timeframe ID]), '')
	,[ConfirmedPickupTimeFrame_TFL_ID] = 0
	,[ConfirmedPickupTimeFrame_TFL_Name]=isnull((select top 1 tw.[TimeWindow] from [PinnacleProd].[dbo].[Metropolitan$Time Windows] tw with (nolock) where tw.[TimeWindowID] = sl.[Confirmed Pkp Timeframe ID] ),'')
	,[ActualPickupDate]=[POMS_DB].[dbo].[F_Get_DateTime_From_UTC_Abbr] (sl.[Pickup Completed Date], null, od.OrigHub ,null ,null)
	,[PickupManifest] = od.Last_FM_PU_Manifest -- Need to Work On
	,[PICKUP_ST_CODE]=sl.[Pickup type] 
	,[PICKUP_ST_NAME]=isnull((select top 1 pu.[Description] from [PinnacleProd].[dbo].[Metropolitan$TR Pickup] pu with (nolock) where pu.[Pickup Code] = sl.[Pickup type]), '')
	,[PICKUP_SST_CODE]=sl.[Sub Pickup Type]
	,[PICKUP_SST_NAME]=isnull((select top 1 sst.[Description] from [PinnacleProd].[dbo].[Metropolitan$TR Sub Type] sst with (nolock) where sst.[Code]= sl.[Pickup type] and sst.[Type] = 2 and sst.[Code Value] = sl.[Sub Pickup Type]), '')
	,[Pickup_Instruction] = isnull((Select replace(replace(replace(replace(replace([Pickup Specific Instruction], CHAR(13),' '), CHAR(10),' '), CHAR(9),' '), CHAR(11),' '), CHAR(160),' ') + '' From [PinnacleProd].[dbo].[Metropolitan$Sales Comment Line]   with(nolock) where [No_] = sh.No_ and [Document Line No_] = 0 order by [Line No_]For XML Path(''), TYPE).value('.', 'nvarchar(MAX)'),'')
	,[ReqDelivery_Date]=sh.[Requested Delivery Date]
	,[ReqDelivery_FromTime]=sl.[Requested Delivery From Time]
	,[ReqDelivery_ToTime]=sl.[Requested Delivery To Time]
	,[ReqDelivery_TimeName] = (case when sl.[Requested Delivery From Time] is not null and isnull(sl.[Requested Delivery From Time],'') <> isnull(sl.[Requested Delivery To Time],'') then format(cast(sl.[Requested Delivery From Time] as datetime),'hh:mm tt') else '' end)
	+ (case when sl.[Requested Delivery To Time] is not null and isnull(sl.[Requested Delivery From Time],'') <> isnull(sl.[Requested Delivery To Time],'') then ' To ' + format(cast(sl.[Requested Delivery To Time] as datetime),'hh:mm tt') else '' end)
	,[FirstOffered_DeliveryDate]=sl.[First Offered Delvery Date]
	,[DeliveryScheduleType_MTV_ID] = 0
	,[DeliveryScheduleType_Name]=[POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10520,sl.[Delivery Schedule Type])
	,[PromisedDeliveryDate]=sh.[Promised Delivery Date]
	,[DlvSchByUserName]=od.DlvSchByUsername
	,[ReqDeliveryTimeFrame_TFL_ID] = 0
	,[ReqDeliveryTimeFrame_TFL_Name]=isnull((select top 1 tw.[TimeWindow] from [PinnacleProd].[dbo].[Metropolitan$Time Windows] tw with (nolock) where tw.[TimeWindowID] = sl.[Requested Delv Timeframe ID]), '')
	,[ConfirmedDeliveryTimeFrame_TFL_ID] = 0
	,[ConfirmedDeliveryTimeFrame_TFL_Name]=isnull((select top 1 tw.[TimeWindow] from [PinnacleProd].[dbo].[Metropolitan$Time Windows] tw with (nolock) where tw.[TimeWindowID] = sl.[Confirmed Delv Timeframe ID] ),'')
	,[ActualDeliveryDate]=[POMS_DB].[dbo].[F_Get_DateTime_From_UTC_Abbr] (sl.[Actual Delivery Date], null, od.DestHub ,null ,null)
	,[DeliveryManifest] = od.Last_FM_Del_Manifest -- Need to Work On
	,[DELIVERY_ST_CODE] = sl.[Service type]
	,[DELIVERY_ST_NAME]=isnull((select top 1 st.[Service Name] from [PinnacleProd].[dbo].[Metropolitan$TR Service Type] st with (nolock) where st.[Services Code] = sl.[Service type]), '')
	,[DELIVERY_SST_CODE] = sl.[Sub Service Type]
	,[DELIVERY_SST_NAME]=isnull((select	top 1 spu.[Description] from [PinnacleProd].[dbo].[Metropolitan$TR Sub Type] spu  with (nolock) where spu.[Code] = sl.[Service type] and spu.[Code Value] = sl.[Sub Service Type] and spu.[Type] = 1), '')
	,[Delivery_Instruction] = isnull((Select replace(replace(replace(replace(replace([Comment], CHAR(13),' '), CHAR(10),' '), CHAR(9),' '), CHAR(11),' '), CHAR(160),' ') + '' From [PinnacleProd].[dbo].[Metropolitan$Sales Comment Line]   with(nolock) where [No_] = sh.No_ and [Document Line No_] = 0 order by [Line No_]For XML Path(''), TYPE).value('.', 'nvarchar(MAX)'),'')
	,[EstimateMiles] = (case when IsNumeric(sl.[Estimated Miles]) = 1 then cast(sl.[Estimated Miles] as float) else 0 end)
	,[IsMWG] = od.IsMWG
	,[Revenue] = od.Revenue
	,[RevenueWithCM] = od.RevenueWithCM
	,[LastViewedDate] = @lastViewDt
	,[LastViewedByUserName] = od.LastViewedByUser
	,[LastViewedByFullName] = @lastViewUser
	,[LastViewedByDept] = @lastViewDept
	
	FROM [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
	inner join @BillCustomerTable bct on sh.No_ = bct.ORDER_NO collate Latin1_General_100_CS_AS
	inner join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) on sh.No_ = sl.[Document No]
	inner join [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) on od.[OrderNo] = sl.[Document No]
	outer apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](sh.[Ship-from Phone]) oph
	outer apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](sh.[Ship-to Phone]) dph
	outer apply [POMS_DB].[dbo].[SplitText] (sl.[Ship-from Latlong],',') oll
	outer apply [POMS_DB].[dbo].[SplitText] (sl.[Ship-to Latlong],',') dll
	where sh.No_ = @ORDER_NO

	return
	

end
GO
