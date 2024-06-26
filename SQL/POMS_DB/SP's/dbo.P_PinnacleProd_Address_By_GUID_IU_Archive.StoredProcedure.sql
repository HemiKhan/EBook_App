USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_Address_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_Address_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@IsOrigin bit
	,@IsBlindShipment bit
	,@Name nvarchar(50)
	,@Company nvarchar(50)
	,@Address1 nvarchar(50)
	,@Address2 nvarchar(50)
	,@City nvarchar(30)
	,@State nvarchar(10)
	,@ZipCode nvarchar(10)
	,@ContactPerson nvarchar(50)
	,@Email nvarchar(120)
	,@Phone nvarchar(20)
	,@Mobile nvarchar(20)
	,@LatLong nvarchar(100)
	,@PlaceId nvarchar(max)
	,@County nvarchar(30)
	,@Country nvarchar(10)

	,@Source_MTV_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@pReturnCode bit output
	,@pReturnText nvarchar(250) output
AS
BEGIN
	
set @pReturnCode = 0
Declare @OrderNo nvarchar(20) = cast(@ORDER_ID as nvarchar(20))
set @UserName = upper(@UserName)

Declare @IsBlindShipmentText nvarchar(50) = ''
Declare @OldIsBlindShipmentText nvarchar(50) = ''
Declare @OldName nvarchar(250) = ''
Declare @OldCompany nvarchar(250) = ''
Declare @OldAddress1 nvarchar(250) = ''
Declare @OldAddress2 nvarchar(250) = ''
Declare @OldCity nvarchar(250) = ''
Declare @OldState nvarchar(20) = ''
Declare @OldZipCode nvarchar(20) = ''
Declare @OldContactPerson nvarchar(250) = ''
Declare @OldEmail nvarchar(250) = ''
Declare @OldPhone nvarchar(250) = ''
Declare @OldMobile nvarchar(250) = ''
Declare @Return_Code bit = 0
Declare @Return_Text nvarchar(250) = ''
Declare @IsZipChanged bit = 0
Declare @IsHubChanged bit = 0
Declare @IsFirstOfferDateChanged bit = 0
Declare @OldLatLong nvarchar(50) = ''
Declare @OldPlaceId nvarchar(max) = ''
Declare @OldCounty nvarchar(250) = ''
Declare @OldCountry nvarchar(250) = ''
Declare @SearchType nvarchar(max) = ''
Declare @ServiceType nvarchar(20) = ''
Declare @AreaType int = 10000
Declare @OldAreaType int = 0
Declare @AreaTypeName nvarchar(100) = ''
Declare @OldAreaTypeName nvarchar(100) = ''
Declare @Hub nvarchar(20) = ''
Declare @OldHub nvarchar(20) = ''
Declare @HubName nvarchar(100) = ''
Declare @OldHubName nvarchar(100) = ''
Declare @HubZone nvarchar(20) = ''
Declare @DestZoneFirstScanDate datetime = null
Declare @DestHubFirstScanDate datetime = null
Declare @ArchiveEventsCount int = 0
Declare @IsAddressFieldChange bit = 0
Declare @CustomerNo nvarchar(50) = ''
Declare @OrderStatus nvarchar(50) = ''
Declare @CompleteEventID int = 0
Declare @OldPP_Manfiest int = 0
Declare @EventID1 int = 0
Declare @EventID2 int = 0
Declare @FirstOfferDate date
Declare @ScheduleDate date
Declare @ScanDate date

set @State = LTRIM(rtrim(upper(@State)))
set @ZipCode = LTRIM(rtrim(@ZipCode))
set @CompleteEventID = (case when @IsOrigin = 1 then 18 else 54 end)

Select 
 @CustomerNo = SH.[Bill-to Customer No_] 
,@OrderStatus = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.[ID] = SH.[Order Status]), '')
,@OldPP_Manfiest = (case when @IsOrigin = 1 then [PP_Manifest_Pickup] else [PP_Manifest_Delivery] end)
,@OldAddress1 = (case when @IsOrigin = 1 then SH.[Ship-from Address] else SH.[Ship-to Address] end)
,@OldCity = (case when @IsOrigin = 1 then SH.[Ship-from City] else SH.[Ship-to City] end)
,@OldState = (case when @IsOrigin = 1 then LTRIM(rtrim(upper(SH.[Ship-from State]))) else LTRIM(rtrim(upper(SH.[Ship-to State]))) end)
,@OldZipCode = (case when @IsOrigin = 1 then LTRIM(rtrim(SH.[Ship-from Post Code])) else LTRIM(rtrim(SH.[Ship-to Post Code])) end)
,@FirstOfferDate = SL.[First Offered Delvery Date]
,@ScheduleDate = (case when @IsOrigin = 1 then SL.[Promised Pickup Date] else SH.[Promised Delivery Date] end)
,@ScanDate = OD.FirstScanDate
from [PinnacleProd].[dbo].[Metropolitan$Sales Header] SH with(nolock) 
inner join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] SL with(nolock) on SL.[Document No] = SH.No_ 
inner join [PinnacleProd].[dbo].[Metro_OrderData] OD with(nolock) on OD.[OrderNo] = SH.No_
where SH.[No_] = @OrderNo

if (upper(@OldAddress1) <> upper(@Address1) or @OldZipCode <> @ZipCode or @OldState <> @State or upper(@OldCity) <> upper(@City))
begin
	set @IsAddressFieldChange = 1
end

if @OrderStatus <> 'Active' and @IsAddressFieldChange = 1
begin
	set @pReturnText = 'Cannot change ' + (case when @IsOrigin = 1 then 'Origin' else 'Destination' end) + ' Address. Order is ' + @OrderStatus
end

if exists(select [EventID] from [PinnacleProd].[dbo].[Metropolitan$Event Master Log] with (nolock) where [Order Number] = @OrderNo and [EventID] = @CompleteEventID) and @pReturnText = '' and @IsAddressFieldChange = 1
begin
	set @pReturnText = (case when @IsOrigin = 1 then 'Pickup' else 'Delivery' end) + ' Complete No Exception Event is Already Triggered'
end

if @ScanDate is null and @pReturnText = '' and @IsAddressFieldChange = 1 and @IsOrigin = 1
begin
	set @pReturnText = 'Cannot Change Origin Address. Order is Already Scanned.'
end

if @OldPP_Manfiest > 0 and @Return_Text = '' and @IsAddressFieldChange = 1
begin
	set @pReturnText = 'Cannot Change ' + (case when @IsOrigin = 1 then 'Origin' else 'Destination' end) + ' Address. Order is Already Attached with the Pinnacle Plus Manifest# ' + cast(@OldPP_Manfiest as nvarchar(50))
end

if year(@ScheduleDate) > 2000 and @IsAddressFieldChange = 1 and @pReturnText = ''
begin
	set @pReturnText = 'Cannot change ' + (case when @IsOrigin = 1 then 'Origin' else 'Destination' end) + ' Address. Order is Already Schedule for ' + (case when @IsOrigin = 1 then 'Pickup' else 'Delivery' end)
end

if @OldZipCode <> @ZipCode and @pReturnText = '' and @IsAddressFieldChange = 1
begin
	Declare @ZoneID nvarchar(50) = ''
	select top 1 @ZoneID = PC.Code From [PinnacleProd].[dbo].[Metropolitan$Post Code] PC with (nolock) where PC.Code = @ZipCode
	set @ZoneID = isnull(@ZoneID,'Zip Code Not Found')
	if @ZoneID = 'ZONE999'
	begin
		set @pReturnText = 'No Service Area'
	end
	else if @ZoneID = 'Zip Code Not Found'
	begin
		set @pReturnText = 'Zip Code Not Found'
	end
end

if @pReturnText = '' and @IsAddressFieldChange = 1
begin
	drop table if exists #PinManfiestDetail
	select mg.[ManifestId] , [Type] = (CASE WHEN mgi.[Pickup OR Delivery] = 1 THEN 1 WHEN mgi.[Pickup OR Delivery] = 2 THEN 0 ELSE 0 END)
	, OrderNo = msll.[Sales Order No] , ManifestType = m.[Type] , [ManifestTypeCode] = (case m.[Type] when 30000 then 'FM' else 'LH' end)
	, AttachedLinked = (case when mgi.[Is Stop Defined] = 1 then 'Attached' when mgi.[Is Stop Defined]=0 then 'Linked' else '' end)
	, m.[Status] into #PinManfiestDetail From [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] msll with(nolock)
	Inner Join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi with(nolock) on mgi.[Item ID]= msll.ID
	Inner Join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg with(nolock) on mgi.[Manifest Group ID]= mg.[ManifestGroupId]
	Inner Join [PinnacleProd].[dbo].[Metropolitan$Manifest] m with(nolock) on m.[Entry No]=mg.[ManifestId]
	where mg.[Active Status] = 1 and mgi.[Active Status] = 1 and m.[Status] in (30000,20000) and mgi.[Is Stop Defined] = 1 and mgi.[Pickup OR Delivery] = (case when @IsOrigin = 1 then 1 else 2 end)
	group by mg.[ManifestId],mgi.[Pickup OR Delivery],msll.[Sales Order No],m.[Type],mgi.[Is Stop Defined],m.[Status]

	if exists(select * from #PinManfiestDetail where [Status] in (30000,20000) and [Type] = 30000)
		begin
			set @pReturnText = 'Cannot Change ' + (case when @IsOrigin = 1 then 'Origin' else 'Destination' end) + ' Address. Order is Already Linked/Attached with Pinnacle Manifest No ' + cast((select [ManifestId] from #PinManfiestDetail where [Status] in (30000,20000) and [Type] = 30000) as nvarchar(50)) + ' of type ' + (select [ManifestTypeCode] from #PinManfiestDetail where [Status] in (30000,20000) and [Type] = 30000) + '.'
		end
end
	
if @IsOrigin = 1 and @pReturnText = ''
begin
	select 
	@OldCompany = sh.[Ship-from Name]
	,@OldAddress1 = sh.[Ship-from Address]
	,@OldAddress2 = sh.[Ship-from Address 2]
	,@OldCity = sh.[Ship-from City]
	,@OldState = LTRIM(rtrim(upper(sh.[Ship-from State])))
	,@OldZipCode = LTRIM(rtrim(sh.[Ship-from Post Code]))
	,@OldContactPerson = sh.[Ship-from Contact]
	,@OldPhone = sh.[Ship-from Phone]
	,@OldMobile = sh.[Ship-from Mobile]
	,@OldEmail = sl.[Ship from Email]
	,@OldLatLong = sl.[Ship-from Latlong]
	,@OldPlaceId = isnull(od.[OriginPlaceID],'')
	,@OldCounty = sh.[Ship-from County]
	,@Country = sh.[Ship-from Country_Region Code]
	,@OldHub = od.OrigHub
	,@OldHubName = isnull((select top 1 [Wharehouse Name] from [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] with (nolock) where Code = od.OrigHub),'')
	,@OldAreaType = od.OrigAreaType
	,@OldAreaTypeName = isnull((select [Name] from [PPlus_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 150 and MTV_ID = od.OrigAreaType),'')
	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock)
	join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) on sl.[Document No] = sh.[No_]
	join [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) on od.[OrderNo] = sh.[No_]
	where sh.[No_] = @OrderNo

	if(@OldZipCode <> @ZipCode)
	begin	
		select top 1 
		@AreaType = (case when PC.[Is Outsource] = 1 and PC.[Is_Ferry] = 1 then 35000
						  when PC.[Is Outsource] = 1 and PC.[Is_Ferry] = 0 then 30000
						  when PC.[Is Remote] = 1 and PC.[Is_Ferry] = 1 then 25000
						  when PC.[Is Remote] = 1 and PC.[Is_Ferry] = 0 then 20000
						  when PC.[Is_Ferry] = 1 then 15000 
				    else 10000 end)
		,@Hub = isnull(TWH.[Code],'')
		,@HubName = isnull(TWH.[Wharehouse Name],'')
		,@HubZone = TWH.[DestZone]			
		From [PinnacleProd].[dbo].[Metropolitan$Post Code] PC with (nolock) 
		join [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] TWH with(nolock) on PC.[Zone ID] = TWH.[Zone ID]
		where PC.[Code] = @ZipCode
		
		select @AreaTypeName = [Name] from [PPlus_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 150 and MTV_ID = @AreaType
		set @AreaTypeName = isnull(@AreaTypeName,'')
	end
	else
	begin
		select @AreaType = @OldAreaType, @Hub = @OldHub, @HubName = @OldHubName, @AreaTypeName = @OldAreaTypeName
	end

	if (@pReturnText = '')
	begin
		update [PinnacleProd].[dbo].[Metropolitan$Sales Header] set  [Ship-from Name] = @Company ,[Ship-from Address] = @Address1 ,[Ship-from Address 2] = @Address2 
			,[Ship-from City] = @City ,[Ship-from State] = @State ,[Ship-from Contact] = @ContactPerson ,[Ship-from Post Code] = @ZipCode 
			,[Ship-from County] = @County ,[Ship-from Country_Region Code] = @Country
			,[Ship-from Mobile] = @Mobile ,[Ship-from Phone] = @Phone ,[Modified On] = getutcdate() ,[ModifiedBy] = @UserName where [No_] = @OrderNo

		update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [Ship from Email] = @Email ,[Ship-from Latlong] = @LatLong ,[Modified On] = getutcdate() 
			,[Modified By] = @UserName where [Document No] = @OrderNo
	
		Update [PinnacleProd].[dbo].[Metro_OrderData] set [OrigHub] = @Hub, [OrigAreaType] = @AreaType 
		, [OrigMilesRadius] = null , [OrigDrivingMiles] = null , [LHDrivingMiles] = null  , [DateModified] = GETUTCDATE()
		, [OriginPlaceID] = @PlaceId , [LiveOrigHub] = @Hub where [OrderNo] = @OrderNo

		set @SearchType = (case when upper(@OldCompany) = upper(@Company) then @SearchType else
							(case when @SearchType = '' then 'SHIPFROMNAME' else @SearchType + ',SHIPFROMNAME' end) end) 
		set @SearchType = (case when upper(@OldAddress1) = upper(@Address1) then @SearchType else
							(case when @SearchType = '' then 'SHIPFROMADDRESS' else @SearchType + ',SHIPFROMADDRESS' end) end) 
		set @SearchType = (case when upper(@OldContactPerson) = upper(@ContactPerson) then @SearchType else
							(case when @SearchType = '' then 'SHIPFROMCONTACT' else @SearchType + ',SHIPFROMCONTACT' end) end) 

		if (@SearchType <> '')
		begin
			exec [PinnacleProd].[dbo].[P_Orders_Search_Value_Character_IU] @OrderNo, @SearchType
		end

		if (@OldMobile <> @Mobile or @OldPhone <> @Phone)
		begin
			exec [PinnacleProd].[dbo].[P_Update_Phones] @OrderNo
		end

		exec [PinnacleProd].[dbo].[P_Update_OrderData_Miles] @OrderNo ,1

		set @Return_Code = 1
		set @EventID1 = (case when @IsAddressFieldChange = 1 then 6 else 0 end)

		if (@OldCompany <> @Company)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Company,@OldCompany,'','Ship-from Name','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldAddress1 <> @Address1)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Address1,@OldAddress1,'','Ship-from Address','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldAddress2 <> @Address2)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Address2,@OldAddress2,'','Ship-from Address 2','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldCity <> @City)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @City,@OldCity,'','Ship-from City','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldCounty <> @County)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @County,@OldCounty,'','Ship-from County','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldCountry <> @Country)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Country,@OldCountry,'','Ship-from Country_Region Code','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldState <> @State)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @State,@OldState,'','Ship-from State','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldZipCode <> @ZipCode)
		begin 
			set @IsZipChanged = 1
			exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @ZipCode,@OldZipCode,'','Ship-from Post Code','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo 
			exec [PinnacleProd].[dbo].[Metro_UpdateScheduleType] @OrderNo, 1, @UserName, 0
		end
		if (@OldHubName <> @HubName)
		begin 
			set @IsHubChanged = 1
			exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @HubName,@OldHubName,'','Origin Hub','Metropolitan$TR Warehouse Hub',@OrderNo,@Username,40000,@OrderNo 
		end
		if (@OldContactPerson <> @ContactPerson)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @ContactPerson,@OldContactPerson,'','Ship-from Contact','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldMobile <> @Mobile)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Mobile,@OldMobile,'','Ship-from Mobile','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldPhone <> @Phone)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Phone,@OldPhone,'','Ship-from Phone','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldEmail <> @Email)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Email,@OldEmail,'','Ship from Email','Metropolitan$Sales Linkup',@OrderNo,@Username,40000,@OrderNo end
		if (@OldLatLong <> @LatLong)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @LatLong,@OldLatLong,'','Ship-from Latlong','Metropolitan$Sales Linkup',@OrderNo,@Username,40000,@OrderNo end
		if (@OldPlaceId <> @PlaceId)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] 'Updated','','','OriginPlaceID','Metro_OrderData',@OrderNo,@Username,40000,@OrderNo end
		if (@OldAreaTypeName <> @AreaTypeName)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @AreaTypeName,@OldAreaTypeName,'','OrigAreaType','Metro_OrderData',@OrderNo,@Username,40000,@OrderNo end
	end
end
else if @pReturnText = ''
begin
	set @IsBlindShipmentText = (case when @IsBlindShipment = 1 then 'Yes' else 'No' end)
	select @OldIsBlindShipmentText = (case when sh.[Blind Shippment] = 1 then 'Yes' else 'No' end)
	,@OldName = sh.[Destination Name]
	,@OldCompany = sh.[Ship-to Name]
	,@OldAddress1 = sh.[Ship-to Address]
	,@OldAddress2 = sh.[Ship-to Address 2]
	,@OldCity = sh.[Ship-to City]
	,@OldState = LTRIM(rtrim(upper(sh.[Ship-to State])))
	,@OldZipCode = LTRIM(rtrim(sh.[Ship-to Post Code]))
	,@OldContactPerson = sh.[Ship-to Contact]
	,@OldPhone = sh.[Ship-to Phone]
	,@OldMobile = sh.[Ship-to Mobile]
	,@OldEmail = sl.[Ship to Email]
	,@OldLatLong = sl.[Ship-to Latlong]
	,@OldPlaceId = isnull(od.[DestinationPlaceID],'')
	,@OldCounty = sh.[Ship-to County]
	,@Country = sh.[Ship-to Country_Region Code]
	,@ServiceType = sl.[Service type]
	,@OldHub = isnull(od.DestHub,'')
	,@OldHubName = isnull((select top 1 [Wharehouse Name] from [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] with (nolock) where Code = od.DestHub),'')
	,@OldAreaType = od.DestAreaType
	,@OldAreaTypeName = isnull((select [Name] from [PPlus_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 150 and MTV_ID = od.DestAreaType),'')
	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock)
	join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) on sl.[Document No] = sh.[No_]
	join [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) on od.[OrderNo] = sh.[No_]
	where sh.[No_] = @OrderNo

	if(@OldZipCode <> @ZipCode)
	begin
		select top 1 
			@AreaType = (case when PC.[Is Outsource] = 1 and PC.[Is_Ferry] = 1 then 35000
			when PC.[Is Outsource] = 1 and PC.[Is_Ferry] = 0 then 30000
			when PC.[Is Remote] = 1 and PC.[Is_Ferry] = 1 then 25000
			when PC.[Is Remote] = 1 and PC.[Is_Ferry] = 0 then 20000
			when PC.[Is_Ferry] = 1 then 15000 else 10000 end)
			,@Hub = isnull(TWH.[Code],'')
			,@HubName = isnull(TWH.[Wharehouse Name],'')
			,@HubZone = TWH.[DestZone]

		From [PinnacleProd].[dbo].[Metropolitan$Post Code] PC with (nolock) 
		join [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] TWH with(nolock) on PC.[Zone ID] = TWH.[Zone ID]
		where PC.[Code] = @ZipCode
		
		select @AreaTypeName = [Name] from [PPlus_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 150 and MTV_ID = @AreaType
		set @AreaTypeName = isnull(@AreaTypeName,'')
	end
	else
	begin
		select @AreaType = @OldAreaType, @Hub = @OldHub, @HubName = @OldHubName, @AreaTypeName = @OldAreaTypeName
	end

	if @pReturnText = ''
	begin

		update [PinnacleProd].[dbo].[Metropolitan$Sales Header] set [Destination Name] = @Name ,[Ship-to Name] = @Company ,[Ship-to Address] = @Address1 ,[Ship-to Address 2] = @Address2 
			,[Ship-to City] = @City ,[Ship-to State] = @State ,[Ship-to Contact] = @ContactPerson ,[Ship-to Post Code] = @ZipCode ,[Ship-to Mobile] = @Mobile 
			,[Ship-to County] = @County ,[Ship-to Country_Region Code] = @Country, [Blind Shippment] = @IsBlindShipment
			,[Ship-to Phone] = @Phone ,[Shortcut Dimension 1 Code] = @Hub ,[Modified On] = getutcdate() ,[ModifiedBy] = @UserName where [No_] = @OrderNo

		update [PinnacleProd].[dbo].[Metropolitan$Sales Line] set [Shortcut Dimension 1 Code] = @Hub ,[Modified By] = @UserName ,[Modified On] = getutcdate() where [Document No_]=@OrderNo

		update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [Ship to Email] = @Email ,[Ship-to Latlong] = @LatLong ,[Modified On] = getutcdate() 
			,[Modified By] = @UserName where [Document No] = @OrderNo
		
		Declare @BarcodeDB Table ( [Order No] nvarchar(20) ,[Scan Time] nvarchar(20) ,[Location] nvarchar(20) );

		insert into @BarcodeDB ([Order No], [Scan Time], [Location]) 
		select [Order No] , [Scan Time] , [Location] from [PinnacleArchiveDB].[dbo].[Metropolitan$Barcode Scan History] with(nolock) where [Order No]=@OrderNo
		insert into @BarcodeDB ([Order No], [Scan Time], [Location]) 
		select [Order No] , [Scan Time] , [Location] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] with(nolock) where [Order No]=@OrderNo

		Declare @MainHub nvarchar(20) = ''
		select top 1 @MainHub = DestZone from [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] with(nolock) where Code = @Hub

		--select @DestZoneFirstScanDate = min(BS.[Scan Time]) from @BarcodeDB BS where BS.[Order No]=@OrderNo 
		--and [Location] in (select [Code] from [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] with(nolock) where DestZone = @Hub)
		select @DestHubFirstScanDate = min([Scan Time]) from @BarcodeDB bsh where bsh.[Location] = @Hub and bsh.[Order No] = @OrderNo

		Update [PinnacleProd].[dbo].[Metro_OrderData] set [DestHub] = @Hub, [DestAreaType] = @AreaType , [DestMilesRadius] = null 
		, [DestDrivingMiles] = null , [LHDrivingMiles] = null  , [DateModified] = GETUTCDATE(), [DestinationPlaceID] = @PlaceId , [LiveDestHub] = @Hub 
		, [DestHub_ChangeCount] = (case when isnull([DestHub],'') <>  isnull(@Hub,'') then [DestHub_ChangeCount] + 1 else [DestHub_ChangeCount] end)
		, [DestZone_FirstScanDate] = @DestZoneFirstScanDate , [DestHub_FirstScanDate] =  @DestHubFirstScanDate where [OrderNo] = @OrderNo

		exec [PinnacleProd].[dbo].[Metro_UpdateOrderItemData] @OrderNo ,@Hub ,@MainHub

		set @SearchType = (case when upper(@OldName) = upper(@Name) then @SearchType else
							(case when @SearchType = '' then 'DESTNAME' else @SearchType + ',DESTNAME' end) end) 
		set @SearchType = (case when upper(@OldCompany) = upper(@Company) then @SearchType else
							(case when @SearchType = '' then 'SHIPTONAME' else @SearchType + ',SHIPTONAME' end) end) 
		set @SearchType = (case when upper(@OldAddress1) = upper(@Address1) then @SearchType else
							(case when @SearchType = '' then 'SHIPTOADDRESS' else @SearchType + ',SHIPTOADDRESS' end) end) 
		set @SearchType = (case when upper(@OldContactPerson) = upper(@ContactPerson) then @SearchType else
							(case when @SearchType = '' then 'SHIPTOCONTACT' else @SearchType + ',SHIPTOCONTACT' end) end) 

		if (@SearchType <> '')
		begin
			exec [PinnacleProd].[dbo].[P_Orders_Search_Value_Character_IU] @OrderNo, @SearchType
		end

		if (@OldMobile <> @Mobile or @OldPhone <> @Phone)
		begin
			exec [PinnacleProd].[dbo].[P_Update_Phones] @OrderNo
		end

		exec [PinnacleProd].[dbo].[P_Update_OrderData_Miles] @OrderNo ,0

		exec [PinnacleProd].[dbo].[Metro_DimensionSet_SaveForOrder] @OrderNo

		set @Return_Code = 1
		set @EventID1 = (case when @IsBlindShipment = 1 and @OldIsBlindShipmentText = 'No' and @IsAddressFieldChange = 1 then 53 
			when @OldIsBlindShipmentText = 'Yes' and @IsBlindShipment = 0 and @IsAddressFieldChange = 1 then 91
			when @IsBlindShipment = 0 and @OldIsBlindShipmentText = 'No' and @IsAddressFieldChange = 1 then 39
			else 0 end)
		set @EventID2 = (case when @IsBlindShipment = 1 and @OldIsBlindShipmentText = 'No' and @IsAddressFieldChange = 1 then 90 
			when @IsBlindShipment = 0 and @OldIsBlindShipmentText = 'Yes' and @IsAddressFieldChange = 1 then 38
			else 0 end)

		if (@OldIsBlindShipmentText <> @IsBlindShipmentText)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @IsBlindShipmentText,@OldIsBlindShipmentText,'','Blind Shippment','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldName <> @Name)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Name,@OldName,'','Destination Name','Metropolitan$Sales Linkup',@OrderNo,@Username,40000,@OrderNo end
		if (@OldCompany <> @Company)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Company,@OldCompany,'','Ship-to Name','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldAddress1 <> @Address1)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Address1,@OldAddress1,'','Ship-to Address','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldAddress2 <> @Address2)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Address2,@OldAddress2,'','Ship-to Address 2','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldCity <> @City)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @City,@OldCity,'','Ship-to City','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldCounty <> @County)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @County,@OldCounty,'','Ship-to County','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldCountry <> @Country)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Country,@OldCountry,'','Ship-to Country_Region Code','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldState <> @State)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @State,@OldState,'','Ship-to State','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldZipCode <> @ZipCode)
		begin 
			set @IsZipChanged = 1
			exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @ZipCode,@OldZipCode,'','Ship-to Post Code','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo 
			exec [PinnacleProd].[dbo].[Metro_UpdateScheduleType] @OrderNo, 2, @UserName, 0
			if year(@FirstOfferDate) > 2000
			begin
				set @IsFirstOfferDateChanged = 1
				declare @FirstOfferDateText nvarchar(50) = (case when year(@FirstOfferDate) > 2000 then format(@FirstOfferDate,'MM/dd/yyyy') else '' end)
				update sl set sl.[First Offered Delvery Date] = '1753-01-01' from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl where [Document No] = @OrderNo and [Document Type] = 1
				exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] '', @FirstOfferDateText, '', 'First Offered Delvery Date', 'Metropolitan$Sales Linkup', @OrderNo, @UserName, 40000, @OrderNo
			end
		end
		if (@OldHubName <> @HubName)
		begin 
			set @IsHubChanged = 1
			exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @HubName,@OldHubName,'','Destination Hub','Metropolitan$TR Warehouse Hub',@OrderNo,@Username,40000,@OrderNo 
		end
		if (@OldContactPerson <> @ContactPerson)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @ContactPerson,@OldContactPerson,'','Ship-to Contact','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldMobile <> @Mobile)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Mobile,@OldMobile,'','Ship-to Mobile','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldPhone <> @Phone)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Phone,@OldPhone,'','Ship-to Phone','Metropolitan$Sales Header',@OrderNo,@Username,40000,@OrderNo end
		if (@OldEmail <> @Email)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Email,@OldEmail,'','Ship to Email','Metropolitan$Sales Linkup',@OrderNo,@Username,40000,@OrderNo end
		if (@OldLatLong <> @LatLong)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @LatLong,@OldLatLong,'','Ship-to Latlong','Metropolitan$Sales Linkup',@OrderNo,@Username,40000,@OrderNo end
		if (@OldPlaceId <> @PlaceId)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] 'Updated','','','DestinationPlaceID','Metro_OrderData',@OrderNo,@Username,40000,@OrderNo end
		if (@OldAreaTypeName <> @AreaTypeName)
			begin exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @AreaTypeName,@OldAreaTypeName,'','DestAreaType','Metro_OrderData',@OrderNo,@Username,40000,@OrderNo end
	end
end

if @IsAddressFieldChange = 1 and @pReturnCode = 1
begin
	if @EventID1 > 0
	begin
		exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] @EventID1 ,0 ,0 ,0 ,@UserName ,1 ,'10000' ,'ShippingStatus/OrderDetail/UpdateShippingStatus' ,@UserName ,@OrderNo ,@CustomerNo ,'' ,'' ,''
	end
	if @EventID2 > 0
	begin
		exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] @EventID2 ,0 ,0 ,0 ,@UserName ,1 ,'10000' ,'ShippingStatus/OrderDetail/UpdateShippingStatus' ,@UserName ,@OrderNo ,@CustomerNo ,'' ,'' ,''
	end
end

--if (@IsEventArchive = 1)
--begin
--	select @ArchiveEventsCount = count(1) from [PinnacleArchiveDB].[dbo].[Metropolitan$Event Master Log] with (nolock) where [Order Number] = @OrderNo
--end

if @pReturnCode = 1 
begin
	select	
	Return_Code = @pReturnCode
	,Return_Text = @pReturnText
	,IsZipChanged = @IsZipChanged 
	,IsHubChanged = @IsHubChanged 
	,IsAddressFieldChange = @IsAddressFieldChange
	,IsFirstOfferDateChanged = @IsFirstOfferDateChanged 
	,[orderid] = sh.[No_]
	,[shippingstatus] = (case when 1 = 1 then isnull((select top 1 evm.[Events] from [PinnacleProd].[dbo].[Metropolitan$Event Master] evm with (nolock) where evm.[Entry No] = sh.[Shipping Status]), '') else '' end)
	,[orderstatuscode] = sh.[Order Status]
	,[orderstatus] = (case when 1 = 0 then isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.[ID] = sh.[Order Status]), '') else '' end)
	,[activitiesevent] = (case when 1 = 1 then cast((select count(1) from [PinnacleProd].[dbo].[Metropolitan$Event Master Log] eml with (nolock) where eml.[Order Number] = sh.[No_]) + @ArchiveEventsCount as varchar(20)) else 0 end)

	,[company] = isnull((case when @IsOrigin = 1 then sh.[Ship-from Name] else sh.[Ship-to Name] end),'')
	,[address1] = isnull((case when @IsOrigin = 1 then sh.[Ship-from Address] else sh.[Ship-to Address] end),'')
	,[address2] = isnull((case when @IsOrigin = 1 then sh.[Ship-from Address 2] else sh.[Ship-to Address 2] end),'')
	,[city] = isnull((case when @IsOrigin = 1 then sh.[Ship-from City] else sh.[Ship-to City] end),'')
	,[state] = isnull((case when @IsOrigin = 1 then sh.[Ship-from State] else sh.[Ship-to State] end),'')
	,[zipcode] = isnull((case when @IsOrigin = 1 then sh.[Ship-from Post Code] else sh.[Ship-to Post Code] end),'')
	,[contactperson] = isnull((case when @IsOrigin = 1 then sh.[Ship-from Contact] else sh.[Ship-to Contact] end),'')
	,[email] = isnull((case when @IsOrigin = 1 then sl.[Ship from Email] else sl.[Ship to Email] end),'')
	,[phone] = isnull((case when @IsOrigin = 1 then sh.[Ship-from Phone] else sh.[Ship-to Phone] end),'')
	,[mobile] = isnull((case when @IsOrigin = 1 then sh.[Ship-from Mobile] else sh.[Ship-to Mobile] end),'')
	,[latlong] = isnull((case when @IsOrigin = 1 then sl.[Ship-from Latlong] else sl.[Ship-to Latlong] end),'')
	,[county] = isnull((case when @IsOrigin = 1 then sh.[Ship-from County] else sh.[Ship-to County] end),'')
	,[country] = isnull((case when @IsOrigin = 1 then sh.[Ship-from Country_Region Code] else sh.[Ship-to Country_Region Code] end),'')

	,[isblindshipment] = isnull((case when @IsOrigin = 1 then 0 else sh.[Blind Shippment] end),0)
	,[name] = isnull((case when @IsOrigin = 1 then '' else sh.[Destination Name] end),'')

	,[placeid] = isnull((case when @IsOrigin = 1 then od.[OriginPlaceID] else od.[DestinationPlaceID] end),'')
	,[hub] = isnull((case when @IsOrigin = 1 then od.OrigHub else od.DestHub end),'')
	,[hubname] = isnull((select top 1 [Wharehouse Name] from [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] with (nolock) where Code = (case when @IsOrigin = 1 then od.OrigHub else od.DestHub end)),'')

	,[phoneno] = (case when @IsOrigin = 1 then (oph.[FormattedPhoneNo] + oph.[FormattedExtension]) else (dph.[FormattedPhoneNo] + dph.[FormattedExtension]) end)
	,[mobileno] = (case when @IsOrigin = 1 then 
		(case when len(sh.[Ship-from Mobile]) > 0 then '(' + substring(sh.[Ship-from Mobile], 1, 3) + ') ' + substring(sh.[Ship-from Mobile], 4, 3) + '-' + substring(sh.[Ship-from Mobile], 7, 4) else '' end)
		else
		(case when len(sh.[Ship-to Mobile]) > 0 then '(' + substring(sh.[Ship-to Mobile], 1, 3) + ') ' + substring(sh.[Ship-to Mobile], 4, 3) + '-' + substring(sh.[Ship-to Mobile], 7, 4) else '' end)
		end)

	,[scheduletype] = isnull((case when @IsOrigin = 1 then
		(select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10520 and mtv.[ID] = sl.[Pickup Schedule Type])
		else
		(select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10520 and mtv.[ID] = sl.[Delivery Schedule Type])
		end), '')

	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock)
	join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) on sl.[Document No] = sh.[No_]
	join [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) on od.[OrderNo] = sh.[No_]
	cross apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](sh.[Ship-from Phone]) oph
	cross apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](sh.[Ship-to Phone]) dph
	where sh.[No_] = @OrderNo
end
else
begin
	select Return_Code = @pReturnCode , Return_Text = @pReturnText
end
END
GO
