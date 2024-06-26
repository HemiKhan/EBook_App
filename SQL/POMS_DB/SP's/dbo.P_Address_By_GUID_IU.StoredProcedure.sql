USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Address_By_GUID_IU]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ===============================================================
 Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' Declare @Ret_WarningText nvarchar(250) = '' 
 exec [dbo].[P_Address_By_GUID_IU] '',10100168,0,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out,@WarningText=@Ret_WarningText out select @Ret_ReturnCode,@Ret_ReturnText ,@Ret_WarningText 
=============================================================== */

CREATE PROCEDURE [dbo].[P_Address_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int

	,@pAddress_MTV_ID int --130100
	,@pIsBlindShipTo bit
	,@pADDRESS_CODE nvarchar(20)
	,@pFirstName nvarchar(50)
	,@pMiddleName nvarchar(50)
	,@pLastName nvarchar(50)
	,@pCompany nvarchar(250)
	,@pContactPerson nvarchar(150)
	,@pAddress nvarchar(250)
	,@pAddress2 nvarchar(250)
	,@pCity nvarchar(50)
	,@pState nvarchar(5)
	,@pZipCode nvarchar(10)
	,@pCounty nvarchar(50)
	,@pCountryRegionCode nvarchar(10)
	,@pEmail nvarchar(250)
	,@pMobile nvarchar(30)
	,@pPhone nvarchar(20)
	,@pPhoneExt nvarchar(10)
	,@pIsValidAddress bit
	,@pLat nvarchar(30)
	,@pLng nvarchar(30)
	,@pPlaceID nvarchar(500)
	
	,@Source_MTV_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@ReturnCode bit output
	,@ReturnText nvarchar(250) output
	,@WarningText nvarchar(250) output
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

Declare @ReturnTable table
(Return_Code bit
,Return_Text nvarchar(250)
,Warning_Text nvarchar(250)
,ShippingStatus int
,ShippingStatusEventName nvarchar(250)
,ActivitiesEvent int
,ADDRESS_CODE nvarchar(20)
,IsBlindShipTo bit
,FirstName nvarchar(50)
,MiddleName nvarchar(50)
,LastName nvarchar(50)
,Company nvarchar(250)
,ContactPerson nvarchar(150)
,[Address] nvarchar(250)
,Address2 nvarchar(250)
,City nvarchar(50)
,[State] nvarchar(5)
,ZipCode nvarchar(10)
,County nvarchar(50)
,CountryRegionCode nvarchar(10)
,Email nvarchar(250)
,Mobile nvarchar(30)
,Phone nvarchar(20)
,PhoneExt nvarchar(10)
,IsValidAddress bit
,Lat nvarchar(30)
,Lng nvarchar(30)
,PlaceID nvarchar(500)
,AreaType_MTV_ID int
,AreaTypeName nvarchar(50)
,HUB_CODE nvarchar(20)
,HubName nvarchar(50)
,LiveHUB_CODE nvarchar(20)
,LiveHubName nvarchar(50)
,ZONE_CODE nvarchar(20)
,ZoneName nvarchar(50)
,ChangeCount int
,ScheduleTypeName nvarchar(50)
)

if @ORDER_ID = 0
begin
	set @ReturnText = 'Invalid OrderID'
	select * from @ReturnTable
	return
end

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

set @pState = LTRIM(rtrim(upper(isnull(@pState,''))))
set @pZipCode = LTRIM(rtrim(isnull(@pZipCode,'')))
set @pADDRESS_CODE = (case when @pADDRESS_CODE = '' then null else upper(@pADDRESS_CODE) end)

if @GetRecordType_MTV_ID in (147100,147101,147102)
begin
	Declare @ShippingStatus_MTV_ID int
	Declare @ShippingStatusEventName nvarchar(250)
	Declare @ActivitiesEvent int
	Declare @AreaType_MTV_ID int
	Declare @AreaTypeName nvarchar(50)
	Declare @HUB_CODE nvarchar(20)
	Declare @HubName nvarchar(50)
	Declare @LiveHUB_CODE nvarchar(20)
	Declare @LiveHubName nvarchar(50)
	Declare @ZONE_CODE nvarchar(20)
	Declare @ZoneName nvarchar(50)
	Declare @ChangeCount int
	Declare @ScheduleType_MTV_ID int
	Declare @ScheduleTypeName nvarchar(50)

	Declare @OldIsBlindShipTo bit
	Declare @OldAddress nvarchar(250)
	Declare @OldCity nvarchar(50)
	Declare @OldState nvarchar(5)
	Declare @OldZipCode nvarchar(10)
	Declare @OldAreaType_MTV_ID int
	Declare @OldHUB_CODE nvarchar(20)
	Declare @OldLiveHUB_CODE nvarchar(20)
	Declare @OldZONE_CODE nvarchar(20)
	Declare @OldChangeCount int
	Declare @OldScheduleType_MTV_ID int
	Declare @OldScheduleTypeName nvarchar(50)

	Declare @SearchType nvarchar(max) = ''
	Declare @ServiceType nvarchar(20) = ''
	Declare @HubZone nvarchar(20) = ''
	Declare @DestZoneFirstScanDate datetime = null
	Declare @DestHubFirstScanDate datetime = null
	Declare @ArchiveEventsCount int = 0
	Declare @IsAddressFieldChange bit = 0
	Declare @SellerCode nvarchar(20) = ''
	Declare @BillToCustomerNo nvarchar(20) = ''
	Declare @OrderStatus_MTV_ID int = 0
	Declare @OrderStatus nvarchar(50) = ''
	Declare @CompleteEventID int = 0
	Declare @PP_Manfiest int = 0
	Declare @EventID1 int = 0
	Declare @EventID2 int = 0
	Declare @FirstOfferDate date
	Declare @ScheduleDate date
	Declare @ActualDate date
	Declare @ScanDate date
	Declare @IsHubChanged bit = 0
	Declare @IsFirstOfferDateChanged bit = 0

	set @CompleteEventID = (case when @pAddress_MTV_ID = 130100 then 18 else 54 end)

	SELECT @SellerCode = SELLER_CODE	
	,@BillToCustomerNo = BillTo_CUSTOMER_NO	
	--,@ShippingStatus_MTV_ID = o.ShippingStatus_EVENT_ID
	--,@ShippingStatusEventName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.ShippingStatus_EVENT_ID)
	,@OrderStatus_MTV_ID = o.OrderStatus_MTV_ID
	,@OrderStatus = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.OrderStatus_MTV_ID)
	,@PP_Manfiest = (CASE WHEN @pAddress_MTV_ID = 130100 THEN od.Last_Pickup_PP_MIN_ID ELSE od.Last_Delivery_PP_MIN_ID END)
	,@OldAddress = (CASE WHEN @pAddress_MTV_ID = 130100 THEN o.ShipFrom_Address ELSE o.ShipTo_Address END)
	,@OldCity = (CASE WHEN @pAddress_MTV_ID = 130100 THEN o.ShipFrom_City ELSE o.ShipTo_City END)
	,@OldState = (CASE WHEN @pAddress_MTV_ID = 130100 THEN o.ShipFrom_State ELSE o.ShipTo_State END)
	,@OldZipCode = (CASE WHEN @pAddress_MTV_ID = 130100 THEN o.ShipFrom_ZipCode ELSE o.ShipTo_ZipCode END)
	,@OldLiveHUB_CODE = (CASE WHEN @pAddress_MTV_ID = 130100 THEN o.LiveShipFrom_HUB_CODE ELSE o.LiveShipTo_HUB_CODE END)
	,@FirstOfferDate = (CASE WHEN @pAddress_MTV_ID = 130100 THEN o.FirstOffered_PickupDate ELSE o.FirstOffered_DeliveryDate END)
	,@ScheduleDate = (CASE WHEN @pAddress_MTV_ID = 130100 THEN o.PromisedPickupDate ELSE o.PromisedDeliveryDate END)
	,@ActualDate = (CASE WHEN @pAddress_MTV_ID = 130100 THEN o.ActualPickupDate ELSE o.ActualDeliveryDate END)
	,@ScanDate = oai.FirstScanDate 
	FROM [POMS_DB].[dbo].[T_Order] o WITH (NOLOCK) 
	INNER JOIN [POMS_DB].[dbo].[T_Order_Detail] od WITH (NOLOCK) ON o.ORDER_ID = od.ORDER_ID
	LEFT JOIN [POMS_DB].[dbo].[T_Order_Additional_Info] oai WITH (NOLOCK) ON o.ORDER_ID = oai.ORDER_ID
	WHERE o.ORDER_ID = @ORDER_ID
	
	SELECT @PP_Manfiest = isnull(@PP_Manfiest,0)
	,@OldAddress = isnull(@OldAddress,'')
	,@OldCity = isnull(@OldCity,'')
	,@OldState = isnull(@OldState,'')
	,@OldZipCode = isnull(@OldZipCode,'')
	,@OldLiveHUB_CODE = isnull(@OldLiveHUB_CODE,'')

	if (upper(@OldAddress) <> upper(@pAddress) or @OldZipCode <> @pZipCode or @OldState <> @pState or upper(@OldCity) <> upper(@pCity))
	begin
		set @IsAddressFieldChange = 1
	end

	if @OrderStatus_MTV_ID <> 100100 and @ReturnText = '' and @IsAddressFieldChange = 1
	begin
		set @ReturnText = 'Cannot change ' + (case when @pAddress_MTV_ID = 130100 then 'Origin' else 'Destination' end) + ' Address. Order is ' + @OrderStatus
	end

	if @ActualDate is not null and @ReturnText = '' and @IsAddressFieldChange = 1
	begin
		set @ReturnText = 'Actual ' + (case when @pAddress_MTV_ID = 130100 then 'Pickup' else 'Delivery' end) + ' Date Already Exists'
	end

	if @ScanDate is null and @ReturnText = '' and @IsAddressFieldChange = 1 and @pAddress_MTV_ID = 130100
	begin
		set @ReturnText = 'Cannot Change Origin Address. Order is Already Scanned.'
	end
		
	if @PP_Manfiest > 0 and @ReturnText = '' and @IsAddressFieldChange = 1
	begin
		set @ReturnText = 'Cannot Change ' + (case when @pAddress_MTV_ID = 130100 then 'Origin' else 'Destination' end) + ' Address. Order is Already Attached with the Pinnacle Plus Manifest# ' + cast(@PP_Manfiest as nvarchar(20))
	end

	if @ScheduleDate is not null and @IsAddressFieldChange = 1 and @ReturnText = ''
	begin
		set @ReturnText = 'Cannot change ' + (case when @pAddress_MTV_ID = 130100 then 'Origin' else 'Destination' end) + ' Address. Order is Already Schedule for ' + (case when @pAddress_MTV_ID = 130100 then 'Pickup' else 'Delivery' end)
	end

	if @OldZipCode <> @pZipCode and @ReturnText = '' and @IsAddressFieldChange = 1
	begin
		select @AreaType_MTV_ID = zc.AreaType_MTV_ID
		,@HUB_CODE = zc.[HUB_CODE]
		FROM [POMS_DB].[dbo].[T_Zip_Code_List] zc WITH (NOLOCK) WHERE ZIP_CODE = @pZipCode

		select @AreaType_MTV_ID = isnull(@AreaType_MTV_ID,0)
		,@HUB_CODE = isnull(@HUB_CODE,'')

		select @ScheduleType_MTV_ID = [POMS_DB].[dbo].[F_Get_ScheduleType_MTV_ID_From_ZipCode] (@pZipCode)
		select @ScheduleTypeName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@ScheduleType_MTV_ID)

		select @AreaTypeName = (case when @AreaType_MTV_ID = 0 then '' else [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@AreaType_MTV_ID) end)
		,@HubName = (case when @HUB_CODE = '' then '' else [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (@HUB_CODE) end)
		,@ZONE_CODE = (case when @HUB_CODE = '' then '' else [POMS_DB].[dbo].[F_Get_HubZone_From_HubCode] (@HUB_CODE) end)

		select @LiveHUB_CODE = @HUB_CODE
		, @LiveHubName = @HubName
		, @ZoneName = (case when @ZONE_CODE = @HUB_CODE then @HubName else [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (@ZONE_CODE) end)

		if (@OldLiveHUB_CODE <> @HUB_CODE)
		begin
			set @IsHubChanged = 1
		end

		if @AreaType_MTV_ID = 104106
		begin
			set @ReturnText = 'No Service Area'
		end
		else if @AreaType_MTV_ID = 0
		begin
			set @ReturnText = 'Invalid Zip Code'
		end
	end

	if @ReturnText = '' and @IsAddressFieldChange = 1
	begin
		drop table if exists #PinManfiestDetail
		select mg.[ManifestId]
		,[Type] = (CASE WHEN mgi.[Pickup OR Delivery] = 1 THEN 1 WHEN mgi.[Pickup OR Delivery] = 2 THEN 0 ELSE 0 END)
		,OrderNo = msll.[Sales Order No] 
		,OrderID = @ORDER_ID
		,ManifestType = m.[Type] 
		,[ManifestTypeCode] = (case m.[Type] when 30000 then 'FM' else 'LH' end)
		,AttachedLinked = (case when mgi.[Is Stop Defined] = 1 then 'Attached' when mgi.[Is Stop Defined]=0 then 'Linked' else '' end)
		,m.[Status] into #PinManfiestDetail
		From [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] msll with(nolock)
		Inner Join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi with(nolock) on mgi.[Item ID]= msll.ID
		Inner Join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg with(nolock) on mgi.[Manifest Group ID]= mg.[ManifestGroupId]
		Inner Join [PinnacleProd].[dbo].[Metropolitan$Manifest] m with(nolock) on m.[Entry No]=mg.[ManifestId]
		where mg.[Active Status] = 1 and mgi.[Active Status] = 1 and m.[Status] in (30000,20000) and mgi.[Is Stop Defined] = 1 and mgi.[Pickup OR Delivery] = (case when @pAddress_MTV_ID = 130100 then 1 else 2 end)
		group by mg.[ManifestId],mgi.[Pickup OR Delivery],msll.[Sales Order No],m.[Type],mgi.[Is Stop Defined],m.[Status]

		if exists(select * from #PinManfiestDetail where [Status] in (30000,20000) and [Type] = 30000)
		begin
			set @ReturnText = 'Cannot Change ' + (case when @pAddress_MTV_ID = 130100 then 'Origin' else 'Destination' end) + ' Address. Order is Already Linked/Attached with Pinnacle Manifest No ' + cast((select [ManifestId] from #PinManfiestDetail where [Status] in (30000,20000) and [Type] = 30000) as nvarchar(50)) + ' of type ' + (select [ManifestTypeCode] from #PinManfiestDetail where [Status] in (30000,20000) and [Type] = 30000) + '.'
		end
	end

	if @pAddress_MTV_ID = 130100 and @ReturnText = ''
	begin
		drop table if exists #JsonOldShipFromOrderTable 
		SELECT ORDER_ID = o.ORDER_ID
		,ShipFrom_ADDRESS_CODE = isnull(o.ShipFrom_ADDRESS_CODE,'')
		,ShipFrom_FirstName = o.ShipFrom_FirstName
		,ShipFrom_MiddleName = o.ShipFrom_MiddleName
		,ShipFrom_LastName = o.ShipFrom_LastName
		,ShipFrom_Company = o.ShipFrom_Company
		,ShipFrom_ContactPerson = o.ShipFrom_ContactPerson
		,ShipFrom_Address = o.ShipFrom_Address
		,ShipFrom_Address2 = o.ShipFrom_Address2
		,ShipFrom_City = o.ShipFrom_City
		,ShipFrom_State = o.ShipFrom_State
		,ShipFrom_ZipCode = o.ShipFrom_ZipCode
		,ShipFrom_County = o.ShipFrom_County
		,ShipFrom_CountryRegionCode = o.ShipFrom_CountryRegionCode
		,ShipFrom_Email = o.ShipFrom_Email
		,ShipFrom_Mobile = o.ShipFrom_Mobile
		,ShipFrom_Phone = o.ShipFrom_Phone
		,ShipFrom_PhoneExt = o.ShipFrom_PhoneExt
		,IsShipFrom_ValidAddress = o.IsShipFrom_ValidAddress
		,IsShipFrom_ValidAddressText = (case when o.IsShipFrom_ValidAddress = 1 then 'Yes' else 'No' end)
		,ShipFrom_Lat = o.ShipFrom_Lat
		,ShipFrom_Lng = o.ShipFrom_Lng
		,ShipFrom_PlaceID = o.ShipFrom_PlaceID
		,ShipFrom_AreaType_MTV_ID = o.ShipFrom_AreaType_MTV_ID
		,ShipFrom_AreaTypeName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.ShipFrom_AreaType_MTV_ID)
		,ShipFrom_HUB_CODE = o.ShipFrom_HUB_CODE
		,ShipFrom_HUB_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.ShipFrom_HUB_CODE)
		,LiveShipFrom_HUB_CODE = o.LiveShipFrom_HUB_CODE
		,LiveShipFrom_HUB_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.LiveShipFrom_HUB_CODE)
		,ShipFrom_ZONE_CODE = o.ShipFrom_ZONE_CODE
		,ShipFrom_ZONE_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.ShipFrom_ZONE_CODE)
		,ShipFrom_ChangeCount = o.ShipFrom_ChangeCount
		,PickupScheduleType_MTV_ID = o.PickupScheduleType_MTV_ID
		,PickupScheduleType_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.PickupScheduleType_MTV_ID)
		,FirstOfferDate = (case when @FirstOfferDate is not null then 
			(case when @ScanDate is null and @ScheduleDate is null and @OldZipCode <> @pZipCode then format(@FirstOfferDate,'yyyy-MM-dd') else '' end) else '' end)
		into #JsonOldShipFromOrderTable 
		FROM [POMS_DB].[dbo].[T_Order] o WITH (NOLOCK) 
		WHERE o.ORDER_ID = @ORDER_ID

		if (@OldZipCode = @pZipCode)
		begin
			select @AreaType_MTV_ID = @OldAreaType_MTV_ID
			,@HUB_CODE = @OldHUB_CODE
			,@ZONE_CODE = @OldZONE_CODE
			,@LiveHUB_CODE = @OldLiveHUB_CODE

		end

		if @FirstOfferDate is not null and  @ScanDate is null and @ScheduleDate is null and @OldZipCode <> @pZipCode 
		begin
			Set @IsFirstOfferDateChanged = 1
		end

		UPDATE o
		set o.ShipFrom_ADDRESS_CODE = @pADDRESS_CODE
		,o.ShipFrom_FirstName = @pFirstName
		,o.ShipFrom_MiddleName = @pMiddleName
		,o.ShipFrom_LastName = @pLastName
		,o.ShipFrom_Company = @pCompany
		,o.ShipFrom_ContactPerson = @pContactPerson
		,o.ShipFrom_Address = @pAddress
		,o.ShipFrom_Address2 = @pAddress2
		,o.ShipFrom_City = @pCity
		,o.ShipFrom_State = @pState
		,o.ShipFrom_ZipCode = @pZipCode
		,o.ShipFrom_County = @pCounty
		,o.ShipFrom_CountryRegionCode = @pCountryRegionCode
		,o.ShipFrom_Email = @pEmail
		,o.ShipFrom_Mobile = @pMobile
		,o.ShipFrom_Phone = @pPhone
		,o.ShipFrom_PhoneExt = @pPhoneExt
		,o.IsShipFrom_ValidAddress = @pIsValidAddress
		,o.ShipFrom_Lat = @pLat
		,o.ShipFrom_Lng = @pLng
		,o.ShipFrom_PlaceID = @pPlaceID
		,o.ShipFrom_AreaType_MTV_ID = @AreaType_MTV_ID
		,o.ShipFrom_HUB_CODE = @HUB_CODE
		,o.LiveShipFrom_HUB_CODE = @LiveHUB_CODE
		,o.ShipFrom_ZONE_CODE = @ZONE_CODE
		,o.PickupScheduleType_MTV_ID = @ScheduleType_MTV_ID
		,o.ShipFrom_ChangeCount = (case when @IsHubChanged = 1 then o.ShipFrom_ChangeCount + 1 else o.ShipFrom_ChangeCount end)
		,o.FirstOffered_PickupDate = (case when @FirstOfferDate is not null and  @ScanDate is null and @ScheduleDate is null and @OldZipCode <> @pZipCode then null else o.FirstOffered_PickupDate end)
		,o.ModifiedOn = getutcdate() 
		,o.ModifiedBy = @UserName 
		from [POMS_DB].[dbo].[T_Order] o
		WHERE ORDER_ID = @ORDER_ID

		drop table if exists #JsonNewShipFromOrderTable
		SELECT ORDER_ID = o.ORDER_ID
		,ShipFrom_ADDRESS_CODE = isnull(o.ShipFrom_ADDRESS_CODE,'')
		,ShipFrom_FirstName = o.ShipFrom_FirstName
		,ShipFrom_MiddleName = o.ShipFrom_MiddleName
		,ShipFrom_LastName = o.ShipFrom_LastName
		,ShipFrom_Company = o.ShipFrom_Company
		,ShipFrom_ContactPerson = o.ShipFrom_ContactPerson
		,ShipFrom_Address = o.ShipFrom_Address
		,ShipFrom_Address2 = o.ShipFrom_Address2
		,ShipFrom_City = o.ShipFrom_City
		,ShipFrom_State = o.ShipFrom_State
		,ShipFrom_ZipCode = o.ShipFrom_ZipCode
		,ShipFrom_County = o.ShipFrom_County
		,ShipFrom_CountryRegionCode = o.ShipFrom_CountryRegionCode
		,ShipFrom_Email = o.ShipFrom_Email
		,ShipFrom_Mobile = o.ShipFrom_Mobile
		,ShipFrom_Phone = o.ShipFrom_Phone
		,ShipFrom_PhoneExt = o.ShipFrom_PhoneExt
		,IsShipFrom_ValidAddress = o.IsShipFrom_ValidAddress
		,IsShipFrom_ValidAddressText = (case when o.IsShipFrom_ValidAddress = 1 then 'Yes' else 'No' end)
		,ShipFrom_Lat = o.ShipFrom_Lat
		,ShipFrom_Lng = o.ShipFrom_Lng
		,ShipFrom_PlaceID = o.ShipFrom_PlaceID
		,ShipFrom_AreaType_MTV_ID = o.ShipFrom_AreaType_MTV_ID
		,ShipFrom_AreaTypeName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.ShipFrom_AreaType_MTV_ID)
		,ShipFrom_HUB_CODE = o.ShipFrom_HUB_CODE
		,ShipFrom_HUB_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.ShipFrom_HUB_CODE)
		,LiveShipFrom_HUB_CODE = o.LiveShipFrom_HUB_CODE
		,LiveShipFrom_HUB_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.LiveShipFrom_HUB_CODE)
		,ShipFrom_ZONE_CODE = o.ShipFrom_ZONE_CODE
		,ShipFrom_ZONE_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.ShipFrom_ZONE_CODE)
		,ShipFrom_ChangeCount = o.ShipFrom_ChangeCount
		,PickupScheduleType_MTV_ID = o.PickupScheduleType_MTV_ID
		,PickupScheduleType_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.PickupScheduleType_MTV_ID)
		,FirstOfferDate = (case when @FirstOfferDate is not null then 
			(case when @ScanDate is null and @ScheduleDate is null and @OldZipCode = @pZipCode then 'Deleted' else '' end) else '' end)
		into #JsonNewShipFromOrderTable 
		FROM [POMS_DB].[dbo].[T_Order] o WITH (NOLOCK) 
		WHERE o.ORDER_ID = @ORDER_ID
		
		exec [POMS_DB].[dbo].[P_Address_By_GUID_IU_ShipFrom_ChangeLog] @plogIsEdit = 1 ,@plogUserName = @UserName ,@plogSource_MTV_ID = @Source_MTV_ID

		if not exists(select ORDER_ID from #JsonOldShipFromOrderTable where ShipFrom_FirstName = @pFirstName)
		begin
			SET @SearchType = (case when @SearchType = '' then 'SF_FIRSTNAME' else @SearchType + ',SF_FIRSTNAME' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipFromOrderTable where ShipFrom_MiddleName = @pMiddleName)
		begin
			SET @SearchType = (case when @SearchType = '' then 'SF_MIDDLENAME' else @SearchType + ',SF_MIDDLENAME' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipFromOrderTable where ShipFrom_LastName = @pLastName)
		begin
			SET @SearchType = (case when @SearchType = '' then 'SF_LASTNAME' else @SearchType + ',SF_LASTNAME' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipFromOrderTable where ShipFrom_Company = @pCompany)
		begin
			SET @SearchType = (case when @SearchType = '' then 'SF_COMPANY' else @SearchType + ',SF_COMPANY' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipFromOrderTable where ShipFrom_ContactPerson = @pContactPerson)
		begin
			SET @SearchType = (case when @SearchType = '' then 'SF_CONTACTPERSON' else @SearchType + ',SF_CONTACTPERSON' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipFromOrderTable where ShipFrom_Address = @pAddress)
		begin
			SET @SearchType = (case when @SearchType = '' then 'SF_ADDRESS' else @SearchType + ',SF_ADDRESS' end)
		end
			
		SET @ReturnCode = 1
		SET @EventID1 = (case when @IsAddressFieldChange = 1 then 6 else 0 end)

		if @OldZipCode <> @pZipCode
		begin
			Update od
			set od.ShipFrom_MilesRadius = null
			, od.ShipFrom_DrivingMiles = null
			, od.LineHaul_DrivingMiles = null
			, od.ModifiedBy = @UserName
			, od.ModifiedOn = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Detail] od where od.ORDER_ID = @ORDER_ID
		end

		if (@SearchType <> '')
		begin
			exec [POMS_DB].[dbo].[P_Orders_Search_Value_Character_IU] @ORDER_ID, @SearchType
		end

		exec [POMS_DB].[dbo].[P_Update_OrderData_Miles] @ORDER_ID ,1

	end
	else if @pAddress_MTV_ID = 130101 and @ReturnText = ''
	begin
		drop table if exists #JsonOldShipToOrderTable 
		SELECT ORDER_ID = o.ORDER_ID
		,ShipTo_ADDRESS_CODE = isnull(o.ShipTo_ADDRESS_CODE,'')
		,IsBlindShipTo = o.IsBlindShipTo
		,IsBlindShipToText = (case when o.IsBlindShipTo = 1 then 'Yes' else 'No' end)
		,ShipTo_FirstName = o.ShipTo_FirstName
		,ShipTo_MiddleName = o.ShipTo_MiddleName
		,ShipTo_LastName = o.ShipTo_LastName
		,ShipTo_Company = o.ShipTo_Company
		,ShipTo_ContactPerson = o.ShipTo_ContactPerson
		,ShipTo_Address = o.ShipTo_Address
		,ShipTo_Address2 = o.ShipTo_Address2
		,ShipTo_City = o.ShipTo_City
		,ShipTo_State = o.ShipTo_State
		,ShipTo_ZipCode = o.ShipTo_ZipCode
		,ShipTo_County = o.ShipTo_County
		,ShipTo_CountryRegionCode = o.ShipTo_CountryRegionCode
		,ShipTo_Email = o.ShipTo_Email
		,ShipTo_Mobile = o.ShipTo_Mobile
		,ShipTo_Phone = o.ShipTo_Phone
		,ShipTo_PhoneExt = o.ShipTo_PhoneExt
		,IsShipTo_ValidAddress = o.IsShipTo_ValidAddress
		,IsShipTo_ValidAddressText = (case when o.IsShipTo_ValidAddress = 1 then 'Yes' else 'No' end)
		,ShipTo_Lat = o.ShipTo_Lat
		,ShipTo_Lng = o.ShipTo_Lng
		,ShipTo_PlaceID = o.ShipTo_PlaceID
		,ShipTo_AreaType_MTV_ID = o.ShipTo_AreaType_MTV_ID
		,ShipTo_AreaTypeName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.ShipTo_AreaType_MTV_ID)
		,ShipTo_HUB_CODE = o.ShipTo_HUB_CODE
		,ShipTo_HUB_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.ShipTo_HUB_CODE)
		,LiveShipTo_HUB_CODE = o.LiveShipTo_HUB_CODE
		,LiveShipTo_HUB_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.LiveShipTo_HUB_CODE)
		,ShipTo_ZONE_CODE = o.ShipTo_ZONE_CODE
		,ShipTo_ZONE_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.ShipTo_ZONE_CODE)
		,ShipTo_ChangeCount = o.ShipTo_ChangeCount
		,DeliveryScheduleType_MTV_ID = o.DeliveryScheduleType_MTV_ID
		,DeliveryScheduleType_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.DeliveryScheduleType_MTV_ID)
		,FirstOfferDate = (case when @FirstOfferDate is not null then 
			(case when @ScanDate is null and @ScheduleDate is null and @OldZipCode <> @pZipCode then format(@FirstOfferDate,'yyyy-MM-dd') else '' end) else '' end)
		into #JsonOldShipToOrderTable 
		FROM [POMS_DB].[dbo].[T_Order] o WITH (NOLOCK) 
		WHERE o.ORDER_ID = @ORDER_ID

		if (@OldZipCode = @pZipCode)
		begin
			select @AreaType_MTV_ID = @OldAreaType_MTV_ID
			,@HUB_CODE = @OldHUB_CODE
			,@ZONE_CODE = @OldZONE_CODE
			,@LiveHUB_CODE = @OldLiveHUB_CODE

		end

		if @FirstOfferDate is not null and  @ScanDate is null and @ScheduleDate is null and @OldZipCode <> @pZipCode 
		begin
			Set @IsFirstOfferDateChanged = 1
		end

		UPDATE o
		set o.ShipTo_ADDRESS_CODE = @pADDRESS_CODE
		,o.IsBlindShipTo = @pIsBlindShipTo
		,o.ShipTo_FirstName = @pFirstName
		,o.ShipTo_MiddleName = @pMiddleName
		,o.ShipTo_LastName = @pLastName
		,o.ShipTo_Company = @pCompany
		,o.ShipTo_ContactPerson = @pContactPerson
		,o.ShipTo_Address = @pAddress
		,o.ShipTo_Address2 = @pAddress2
		,o.ShipTo_City = @pCity
		,o.ShipTo_State = @pState
		,o.ShipTo_ZipCode = @pZipCode
		,o.ShipTo_County = @pCounty
		,o.ShipTo_CountryRegionCode = @pCountryRegionCode
		,o.ShipTo_Email = @pEmail
		,o.ShipTo_Mobile = @pMobile
		,o.ShipTo_Phone = @pPhone
		,o.ShipTo_PhoneExt = @pPhoneExt
		,o.IsShipTo_ValidAddress = @pIsValidAddress
		,o.ShipTo_Lat = @pLat
		,o.ShipTo_Lng = @pLng
		,o.ShipTo_PlaceID = @pPlaceID
		,o.ShipTo_AreaType_MTV_ID = @AreaType_MTV_ID
		,o.ShipTo_HUB_CODE = @HUB_CODE
		,o.LiveShipTo_HUB_CODE = @LiveHUB_CODE
		,o.ShipTo_ZONE_CODE = @ZONE_CODE
		,o.DeliveryScheduleType_MTV_ID = @ScheduleType_MTV_ID
		,o.ShipTo_ChangeCount = (case when @IsHubChanged = 1 then o.ShipTo_ChangeCount + 1 else o.ShipTo_ChangeCount end)
		,o.FirstOffered_DeliveryDate = (case when @FirstOfferDate is not null and  @ScanDate is null and @ScheduleDate is null and @OldZipCode <> @pZipCode then null else o.FirstOffered_DeliveryDate end)
		,o.ModifiedOn = getutcdate() 
		,o.ModifiedBy = @UserName 
		from [POMS_DB].[dbo].[T_Order] o
		WHERE ORDER_ID = @ORDER_ID

		drop table if exists #JsonNewShipToOrderTable
		SELECT ORDER_ID = o.ORDER_ID
		,ShipTo_ADDRESS_CODE = isnull(o.ShipFrom_ADDRESS_CODE,'')
		,IsBlindShipTo = o.IsBlindShipTo
		,IsBlindShipToText = (case when o.IsBlindShipTo = 1 then 'Yes' else 'No' end)
		,ShipTo_FirstName = o.ShipFrom_FirstName
		,ShipTo_MiddleName = o.ShipFrom_MiddleName
		,ShipTo_LastName = o.ShipFrom_LastName
		,ShipTo_Company = o.ShipFrom_Company
		,ShipTo_ContactPerson = o.ShipFrom_ContactPerson
		,ShipTo_Address = o.ShipFrom_Address
		,ShipTo_Address2 = o.ShipFrom_Address2
		,ShipTo_City = o.ShipFrom_City
		,ShipTo_State = o.ShipFrom_State
		,ShipTo_ZipCode = o.ShipFrom_ZipCode
		,ShipTo_County = o.ShipFrom_County
		,ShipTo_CountryRegionCode = o.ShipFrom_CountryRegionCode
		,ShipTo_Email = o.ShipFrom_Email
		,ShipTo_Mobile = o.ShipFrom_Mobile
		,ShipTo_Phone = o.ShipFrom_Phone
		,ShipTo_PhoneExt = o.ShipFrom_PhoneExt
		,IsShipTo_ValidAddress = o.IsShipFrom_ValidAddress
		,IsShipTo_ValidAddressText = (case when o.IsShipTo_ValidAddress = 1 then 'Yes' else 'No' end)
		,ShipTo_Lat = o.ShipFrom_Lat
		,ShipTo_Lng = o.ShipFrom_Lng
		,ShipTo_PlaceID = o.ShipFrom_PlaceID
		,ShipTo_AreaType_MTV_ID = o.ShipFrom_AreaType_MTV_ID
		,ShipTo_AreaTypeName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.ShipFrom_AreaType_MTV_ID)
		,ShipTo_HUB_CODE = o.ShipFrom_HUB_CODE
		,ShipTo_HUB_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.ShipFrom_HUB_CODE)
		,LiveShipTo_HUB_CODE = o.LiveShipFrom_HUB_CODE
		,LiveShipTo_HUB_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.LiveShipFrom_HUB_CODE)
		,ShipTo_ZONE_CODE = o.ShipFrom_ZONE_CODE
		,ShipTo_ZONE_Name = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (o.ShipFrom_ZONE_CODE)
		,ShipTo_ChangeCount = o.ShipFrom_ChangeCount
		,DeliveryScheduleType_MTV_ID = o.DeliveryScheduleType_MTV_ID
		,DeliveryScheduleType_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.DeliveryScheduleType_MTV_ID)
		,FirstOfferDate = (case when @FirstOfferDate is not null then 
			(case when @ScanDate is null and @ScheduleDate is null and @OldZipCode = @pZipCode then 'Deleted' else '' end) else '' end)
		into #JsonNewShipToOrderTable 
		FROM [POMS_DB].[dbo].[T_Order] o WITH (NOLOCK) 
		WHERE o.ORDER_ID = @ORDER_ID
		
		exec [POMS_DB].[dbo].[P_Address_By_GUID_IU_ShipTo_ChangeLog] @plogIsEdit = 1 ,@plogUserName = @UserName ,@plogSource_MTV_ID = @Source_MTV_ID

		if not exists(select ORDER_ID from #JsonOldShipToOrderTable where ShipTo_FirstName = @pFirstName)
		begin
			SET @SearchType = (case when @SearchType = '' then 'ST_FIRSTNAME' else @SearchType + ',ST_FIRSTNAME' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipToOrderTable where ShipTo_MiddleName = @pMiddleName)
		begin
			SET @SearchType = (case when @SearchType = '' then 'ST_MIDDLENAME' else @SearchType + ',ST_MIDDLENAME' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipToOrderTable where ShipTo_LastName = @pLastName)
		begin
			SET @SearchType = (case when @SearchType = '' then 'ST_LASTNAME' else @SearchType + ',ST_LASTNAME' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipToOrderTable where ShipTo_Company = @pCompany)
		begin
			SET @SearchType = (case when @SearchType = '' then 'ST_COMPANY' else @SearchType + ',ST_COMPANY' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipToOrderTable where ShipTo_ContactPerson = @pContactPerson)
		begin
			SET @SearchType = (case when @SearchType = '' then 'ST_CONTACTPERSON' else @SearchType + ',ST_CONTACTPERSON' end)
		end
		if not exists(select ORDER_ID from #JsonOldShipToOrderTable where ShipTo_Address = @pAddress)
		begin
			SET @SearchType = (case when @SearchType = '' then 'ST_ADDRESS' else @SearchType + ',ST_ADDRESS' end)
		end
			
		select @OldIsBlindShipTo = IsBlindShipTo from #JsonOldShipToOrderTable

		SET @ReturnCode = 1
		set @EventID1 = (case when @pIsBlindShipTo = 1 and @OldIsBlindShipTo = 0 and @IsAddressFieldChange = 1 then 53 
			when @OldIsBlindShipTo = 1 and @pIsBlindShipTo = 0 and @IsAddressFieldChange = 1 then 91
			when @pIsBlindShipTo = 0 and @OldIsBlindShipTo = 0 and @IsAddressFieldChange = 1 then 39
			else 0 end)
		set @EventID2 = (case when @pIsBlindShipTo = 1 and @OldIsBlindShipTo = 0 and @IsAddressFieldChange = 1 then 90 
			when @pIsBlindShipTo = 0 and @OldIsBlindShipTo = 1 and @IsAddressFieldChange = 1 then 38
			else 0 end)
		
		if @OldZipCode <> @pZipCode
		begin
			Update od
			set od.ShipTo_MilesRadius = null
			, od.ShipTo_DrivingMiles = null
			, od.LineHaul_DrivingMiles = null
			, od.ModifiedBy = @UserName
			, od.ModifiedOn = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Detail] od where od.ORDER_ID = @ORDER_ID
		end

		if @ScanDate is not null and @OldZipCode <> @pZipCode
		begin
			Declare @ScanRecords Table (ORDER_ID int ,ScanTime datetime ,HUB_CODE nvarchar(20) );

			insert into @ScanRecords (ORDER_ID, ScanTime, HUB_CODE) 
			select ORDER_ID, ScanTime, HUB_CODE from [POMSArchive_DB].[dbo].[T_Order_Item_Scans] with(nolock) where ORDER_ID=@ORDER_ID
			insert into @ScanRecords (ORDER_ID, ScanTime, HUB_CODE) 
			select ORDER_ID, ScanTime, HUB_CODE from [POMS_DB].[dbo].[T_Order_Item_Scans] with(nolock) where ORDER_ID=@ORDER_ID

			Declare @ShipToHub_FirstScanDate datetime = null
			Declare @ShipToZone_FirstScanDate datetime = null
			select ShipToHub_FirstScanDate = min(sr.ScanTime) from @ScanRecords sr where HUB_CODE = @HUB_CODE
			select @ShipToZone_FirstScanDate = min(sr.ScanTime) from @ScanRecords sr where HUB_CODE in (select hl.HUB_CODE from [POMS_DB].[dbo].[T_Hub_List] hl with(nolock) where hl.HUB_ZONE = @ZONE_CODE)

			Update oai
			set oai.ShipToHub_FirstScanDate = @ShipToHub_FirstScanDate
			, oai.ShipToZone_FirstScanDate = @ShipToZone_FirstScanDate
			, oai.ModifiedBy = @UserName
			, oai.ModifiedOn = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Additional_Info] oai where oai.ORDER_ID = @ORDER_ID

			exec [POMS_DB].[dbo].[Metro_UpdateOrderItemData] @ORDER_ID ,@HUB_CODE ,@ZONE_CODE
		end

		if (@SearchType <> '')
		begin
			exec [POMS_DB].[dbo].[P_Orders_Search_Value_Character_IU] @ORDER_ID, @SearchType
		end

		exec [POMS_DB].[dbo].[P_Update_OrderData_Miles] @ORDER_ID ,0

	end

end

END
GO
