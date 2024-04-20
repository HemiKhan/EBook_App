USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_Address_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================
-- ===============================================================
CREATE PROCEDURE [dbo].[P_PinnacleProd_Address_IU_Archive] (
	@ORDER_ID INT
	,@IsOrigin BIT
	,@IsBlindShipment BIT
	,@FirstName NVARCHAR(50)
	,@MiddleName NVARCHAR(50)
	,@LastName NVARCHAR(50)
	,@Company NVARCHAR(250)
	,@Address1 NVARCHAR(250)
	,@Address2 NVARCHAR(250)
	,@City NVARCHAR(30)
	,@State NVARCHAR(10)
	,@ZipCode NVARCHAR(10)
	,@ContactPerson NVARCHAR(50)
	,@Email NVARCHAR(120)
	,@Phone NVARCHAR(30)
	,@PhoneExt NVARCHAR(20)
	,@Mobile NVARCHAR(20)
	,@Lat nvarchar(30)
	,@Long nvarchar(30)
	,@PlaceId NVARCHAR(max)
	,@County NVARCHAR(30)
	,@Country NVARCHAR(10)
	,@Source_MTV_ID INT
	,@UserName NVARCHAR(150)
	,@IsUpdate BIT = 0
	,@WebUserID INT
	,@UserType_MTV_CODE NVARCHAR(20)
	,@IsPublic BIT
	,@TimeZone_ID INT
	,@GetRecordType_MTV_ID INT
	,@pReturnCode BIT OUTPUT
	,@pReturnText NVARCHAR(250) OUTPUT
	)
AS
BEGIN
	
	set @pReturnCode = 0
	set @pReturnText = ''

	set @Phone = isnull(@Phone,'') + '-' + isnull(@PhoneExt,'')

	DECLARE @Name nvarchar(250) = ''
	set @Name = (case when @Name = '' then '' else ' ' end) + isnull(@FirstName,'')
	set @Name = (case when @Name = '' then '' else ' ' end) + isnull(@MiddleName,'')
	set @Name = (case when @Name = '' then '' else ' ' end) + isnull(@LastName,'')
	
	Declare @LatLong nvarchar(100) = ''
	set @LatLong = isnull(@Lat,'') + ',' + isnull(@Long,'')
	
	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	Declare @ReturnTable table ([ORDER_ID] int, [OrderStatus_MTV_ID] int , [OrderStatus_Name] nvarchar(50) , [ShippingStatus_EVENT_ID] int, [ShippingStatus_EVENT_Name] nvarchar(150)
	, [ActivitiesEvent] int, [IsOrigin] bit, [FirstName] nvarchar(50), [MiddleName] nvarchar(50), [LastName] nvarchar(50), [Company] nvarchar(250), [ContactPerson] nvarchar(150)
	, [Address] nvarchar(250), [Address2] nvarchar(250), [City] nvarchar(50), [State] nvarchar(5), [ZipCode] nvarchar(10), [County] nvarchar(50), [CountryRegionCode] nvarchar(10)
	, [Email] nvarchar(250), [Mobile] nvarchar(30), [Phone] nvarchar(20), [PhoneExt] nvarchar(10), [Lat] nvarchar(30), [Lng] nvarchar(30), [PlaceID] nvarchar(500), [AreaType_MTV_ID] int
	, [AreaType_Name] nvarchar(150), [HUB_CODE] nvarchar(20), [HUB_Name] nvarchar(150), [Live_HUB_CODE] nvarchar(20), [Live_HUB_Name] nvarchar(150), [ZONE_CODE] nvarchar(20)
	, [ZONE_Name] nvarchar(150), [ChangeCount] int, [IsBlindShipTo] bit, [PickupScheduleType_MTV_ID] int, [PickupScheduleType_Name] nvarchar(50))

	DECLARE @IsBlindShipmentText NVARCHAR(50) = ''
	DECLARE @OldIsBlindShipmentText NVARCHAR(50) = ''
	DECLARE @OldName NVARCHAR(250) = ''
	DECLARE @OldCompany NVARCHAR(250) = ''
	DECLARE @OldAddress1 NVARCHAR(250) = ''
	DECLARE @OldAddress2 NVARCHAR(250) = ''
	DECLARE @OldCity NVARCHAR(250) = ''
	DECLARE @OldState NVARCHAR(20) = ''
	DECLARE @OldZipCode NVARCHAR(20) = ''
	DECLARE @OldContactPerson NVARCHAR(250) = ''
	DECLARE @OldEmail NVARCHAR(250) = ''
	DECLARE @OldPhone NVARCHAR(250) = ''
	DECLARE @OldMobile NVARCHAR(250) = ''
	DECLARE @IsZipChanged BIT = 0
	DECLARE @IsHubChanged BIT = 0
	DECLARE @IsFirstOfferDateChanged BIT = 0
	DECLARE @OldLatLong NVARCHAR(50) = ''
	DECLARE @OldPlaceId NVARCHAR(max) = ''
	DECLARE @OldCounty NVARCHAR(250) = ''
	DECLARE @OldCountry NVARCHAR(250) = ''
	DECLARE @SearchType NVARCHAR(max) = ''
	DECLARE @ServiceType NVARCHAR(20) = ''
	DECLARE @AreaType INT = 10000
	DECLARE @OldAreaType INT = 0
	DECLARE @AreaTypeName NVARCHAR(100) = ''
	DECLARE @OldAreaTypeName NVARCHAR(100) = ''
	DECLARE @Hub NVARCHAR(20) = ''
	DECLARE @OldHub NVARCHAR(20) = ''
	DECLARE @HubName NVARCHAR(100) = ''
	DECLARE @OldHubName NVARCHAR(100) = ''
	DECLARE @HubZone NVARCHAR(20) = ''
	DECLARE @DestZoneFirstScanDate DATETIME = NULL
	DECLARE @DestHubFirstScanDate DATETIME = NULL
	DECLARE @ArchiveEventsCount INT = 0
	DECLARE @IsAddressFieldChange BIT = 0
	DECLARE @CustomerNo NVARCHAR(50) = ''
	DECLARE @OrderStatus NVARCHAR(50) = ''
	Declare @OrderStatusID int = 0
	DECLARE @CompleteEventID INT = 0
	DECLARE @OldPP_Manfiest INT = 0
	DECLARE @EventID1 INT = 0
	DECLARE @EventID2 INT = 0
	DECLARE @FirstOfferDate DATE
	DECLARE @ScheduleDate DATE
	DECLARE @ActualDate DATE
	DECLARE @ScanDate DATE

	IF @IsUpdate = 1
	BEGIN
		SET @State = LTRIM(rtrim(upper(@State)))
		SET @ZipCode = LTRIM(rtrim(@ZipCode))
		SET @CompleteEventID = (CASE WHEN @IsOrigin = 1 THEN 18 ELSE 54 END)

		SELECT @CustomerNo = SH.[Bill-to Customer No_]
			,@OrderStatus = [POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10080,SH.[Order Status])
			,@OrderStatusID = SH.[Order Status]
			,@OldPP_Manfiest = (CASE WHEN @IsOrigin = 1 THEN [PP_Manifest_Pickup] ELSE [PP_Manifest_Delivery] END)
			,@OldAddress1 = (CASE WHEN @IsOrigin = 1 THEN SH.[Ship-from Address] ELSE SH.[Ship-to Address] END)
			,@OldCity = (CASE WHEN @IsOrigin = 1 THEN SH.[Ship-from City] ELSE SH.[Ship-to City] END)
			,@OldState = (CASE WHEN @IsOrigin = 1 THEN LTRIM(rtrim(upper(SH.[Ship-from State]))) ELSE LTRIM(rtrim(upper(SH.[Ship-to State]))) END)
			,@OldZipCode = (CASE WHEN @IsOrigin = 1 THEN LTRIM(rtrim(SH.[Ship-from Post Code])) ELSE LTRIM(rtrim(SH.[Ship-to Post Code])) END)
			,@FirstOfferDate = SL.[First Offered Delvery Date]
			,@ScheduleDate = (CASE WHEN @IsOrigin = 1 THEN SL.[Promised Pickup Date] ELSE SH.[Promised Delivery Date] END)
			,@ScanDate = OD.FirstScanDate
			,@ActualDate = (CASE WHEN @IsOrigin = 1 THEN SL.[Pickup Completed Date] ELSE SL.[Actual Delivery Date] END)
		FROM [PinnacleProd].[dbo].[Metropolitan$Sales Header] SH WITH (NOLOCK)
		INNER JOIN [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] SL WITH (NOLOCK) ON SL.[Document No] = SH.No_
		INNER JOIN [PinnacleProd].[dbo].[Metro_OrderData] OD WITH (NOLOCK) ON OD.[OrderNo] = SH.No_
		WHERE SH.[No_] = @ORDER_NO

		IF (upper(@OldAddress1) <> upper(@Address1) OR @OldZipCode <> @ZipCode OR @OldState <> @State OR upper(@OldCity) <> upper(@City))
		BEGIN
			SET @IsAddressFieldChange = 1
		END

		IF @OrderStatus <> 10000
			AND @IsAddressFieldChange = 1
		BEGIN
			SET @pReturnText = 'Cannot change ' + (CASE WHEN @IsOrigin = 1 THEN 'Origin' ELSE 'Destination' END) + ' Address. Order is ' + @OrderStatus
		END

		IF year(@ActualDate) > 2000 AND @pReturnText = '' AND @IsAddressFieldChange = 1
		BEGIN
			SET @pReturnText = (CASE WHEN @IsOrigin = 1 THEN 'Pickup' ELSE 'Delivery' END) + ' is Complete'
		END

		IF @ScanDate IS NOT NULL AND @pReturnText = '' AND @IsAddressFieldChange = 1 AND @IsOrigin = 1
		BEGIN
			SET @pReturnText = 'Cannot Change Origin Address. Order is Already Scanned.'
		END

		IF @OldPP_Manfiest > 0 AND @pReturnText = '' AND @IsAddressFieldChange = 1
		BEGIN
			SET @pReturnText = 'Cannot Change ' + (CASE WHEN @IsOrigin = 1 THEN 'Origin' ELSE 'Destination' END) + ' Address. Order is Already Attached with the Pinnacle Plus Manifest# ' + cast(@OldPP_Manfiest AS NVARCHAR(50))
		END

		IF year(@ScheduleDate) > 2000 AND @IsAddressFieldChange = 1 AND @pReturnText = ''
		BEGIN
			SET @pReturnText = 'Cannot change ' + (CASE WHEN @IsOrigin = 1 THEN 'Origin' ELSE 'Destination' END) + ' Address. Order is Already Schedule for ' 
				+ (CASE WHEN @IsOrigin = 1 THEN 'Pickup' ELSE 'Delivery' END)
		END

		IF @OldZipCode <> @ZipCode AND @pReturnText = '' AND @IsAddressFieldChange = 1
		BEGIN
			DECLARE @AreaType_MTV_ID int = 0

			SELECT [AreaType_MTV_ID] FROM [POMS_DB].[dbo].[T_Zip_Code_List] zcl with (nolock) where zcl.ZIP_CODE = @ZipCode and zcl.IsActive = 1
			set @AreaType_MTV_ID = isnull(@AreaType_MTV_ID,0)

			IF @AreaType_MTV_ID = 104106
			BEGIN
				SET @pReturnText = 'No Service Area'
			END
			ELSE IF @AreaType_MTV_ID = 0
			BEGIN
				SET @pReturnText = 'Zip Code Not Found'
			END
		END

		IF @pReturnText = '' AND @IsAddressFieldChange = 1
		BEGIN
			DROP TABLE IF EXISTS #PinManfiestDetail
				
			SELECT mg.[ManifestId] 
				,[Type] = (CASE mgi.[Pickup OR Delivery] WHEN 1 THEN 1 ELSE 0 END)
				,OrderNo = msll.[Sales Order No]
				,ManifestType = m.[Type]
				,[ManifestTypeCode] = (CASE m.[Type] WHEN 30000 THEN 'FM' ELSE 'LH' END)
				,AttachedLinked = (CASE mgi.[Is Stop Defined] WHEN 1 THEN 'Attached' WHEN 0 THEN 'Linked' ELSE '' END)
				,m.[Status]
				INTO #PinManfiestDetail
			FROM [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] msll WITH (NOLOCK)
			INNER JOIN [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi WITH (NOLOCK) ON mgi.[Item ID] = msll.ID
			INNER JOIN [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg WITH (NOLOCK) ON mgi.[Manifest Group ID] = mg.[ManifestGroupId]
			INNER JOIN [PinnacleProd].[dbo].[Metropolitan$Manifest] m WITH (NOLOCK) ON m.[Entry No] = mg.[ManifestId]
			WHERE mg.[Active Status] = 1 AND mgi.[Active Status] = 1 AND m.[Status] IN (30000,20000)
			AND mgi.[Is Stop Defined] = 1 AND mgi.[Pickup OR Delivery] = (CASE WHEN @IsOrigin = 1 THEN 1 ELSE 2 END)
			--AND msll.[Sales Order No] = @ORDER_NO
			GROUP BY mg.[ManifestId] ,mgi.[Pickup OR Delivery] ,msll.[Sales Order No] ,m.[Type] ,mgi.[Is Stop Defined] ,m.[Status]

			IF EXISTS (SELECT * FROM #PinManfiestDetail WHERE [Status] IN (30000,20000) AND [Type] = 30000)
			BEGIN
				SET @pReturnText = 'Cannot Change ' + (CASE WHEN @IsOrigin = 1 THEN 'Origin' ELSE 'Destination' END) + ' Address. Order is Already Linked/Attached with Pinnacle Manifest No ' 
					+ cast((SELECT [ManifestId] FROM #PinManfiestDetail WHERE [Status] IN (30000,20000) AND [Type] = 30000) AS NVARCHAR(50)) + ' of type ' 
					+ (SELECT [ManifestTypeCode] FROM #PinManfiestDetail WHERE [Status] IN (30000,20000) AND [Type] = 30000) + '.'
			END
		END

		IF @IsOrigin = 1 AND @pReturnText = ''
		BEGIN
			SELECT @OldCompany = sh.[Ship-from Name]
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
				,@OldPlaceId = isnull(od.[OriginPlaceID], '')
				,@OldCounty = sh.[Ship-from County]
				,@Country = sh.[Ship-from Country_Region Code]
				,@OldHub = od.OrigHub
				,@OldHubName = [POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (od.OrigHub)
				,@OldAreaType = od.OrigAreaType
				,@OldAreaTypeName = isnull((SELECT [Name] FROM [PPlus_DB].[dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = 150 AND MTV_ID = od.OrigAreaType), '')
			FROM [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh WITH (NOLOCK)
			JOIN [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl WITH (NOLOCK) ON sl.[Document No] = sh.[No_]
			JOIN [PinnacleProd].[dbo].[Metro_OrderData] od WITH (NOLOCK) ON od.[OrderNo] = sh.[No_]
			WHERE sh.[No_] = @ORDER_NO

			IF (@OldZipCode <> @ZipCode)
			BEGIN
				SELECT @AreaType=[POMS_DB].[dbo].[F_Get_PinnacleAreaType_From_NewAreaType] (zcl.[AreaType_MTV_ID])
					,@AreaTypeName=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (zcl.[AreaType_MTV_ID])
					,@Hub=zcl.[HUB_CODE]
					,@HubName=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (zcl.[HUB_CODE])
					,@HubZone=[POMS_DB].[dbo].[F_Get_HubZone_From_HubCode] (zcl.[HUB_CODE])
				FROM [POMS_DB].[dbo].[T_Zip_Code_List] zcl with (nolock) where zcl.[IsActive] = 1 and zcl.[ZIP_CODE] = @ZipCode
			END
			ELSE
			BEGIN
				SELECT @AreaType = @OldAreaType
					,@Hub = @OldHub
					,@HubName = @OldHubName
					,@AreaTypeName = @OldAreaTypeName
			END

			IF (@pReturnText = '')
			BEGIN
				UPDATE [PinnacleProd].[dbo].[Metropolitan$Sales Header]
				SET [Ship-from Name] = @Company
					,[Ship-from Address] = @Address1
					,[Ship-from Address 2] = @Address2
					,[Ship-from City] = @City
					,[Ship-from State] = @State
					,[Ship-from Contact] = @ContactPerson
					,[Ship-from Post Code] = @ZipCode
					,[Ship-from County] = @County
					,[Ship-from Country_Region Code] = @Country
					,[Ship-from Mobile] = @Mobile
					,[Ship-from Phone] = @Phone
					,[Modified On] = getutcdate()
					,[ModifiedBy] = @WebUserID
				WHERE [No_] = @ORDER_NO

				UPDATE [PinnacleProd].[dbo].[Metropolitan$Sales Linkup]
				SET [Ship from Email] = @Email
					,[Ship-from Latlong] = @LatLong
					,[Modified On] = getutcdate()
					,[Modified By] = @WebUserID
				WHERE [Document No] = @ORDER_NO

				UPDATE [PinnacleProd].[dbo].[Metro_OrderData]
				SET [OrigHub] = @Hub
					,[OrigAreaType] = @AreaType
					,[OrigMilesRadius] = NULL
					,[OrigDrivingMiles] = NULL
					,[LHDrivingMiles] = NULL
					,[DateModified] = GETUTCDATE()
					,[OriginPlaceID] = @PlaceId
					,[LiveOrigHub] = @Hub
				WHERE [OrderNo] = @ORDER_NO

				SET @SearchType = [POMS_DB].[dbo].[F_Set_Order_SearchType] (@OldCompany,@Company,'SHIPFROMNAME',@SearchType)
				SET @SearchType = [POMS_DB].[dbo].[F_Set_Order_SearchType] (@OldAddress1,@Address1,'SHIPFROMADDRESS',@SearchType)
				SET @SearchType = [POMS_DB].[dbo].[F_Set_Order_SearchType] (@OldContactPerson,@ContactPerson,'SHIPFROMCONTACT',@SearchType)

				EXEC [PinnacleProd].[dbo].[P_Orders_Search_Value_Character_IU] @ORDER_NO ,@SearchType

				IF (@OldMobile <> @Mobile OR @OldPhone <> @Phone)
				BEGIN
					EXEC [PinnacleProd].[dbo].[P_Update_Phones] @ORDER_NO
				END

				EXEC [PinnacleProd].[dbo].[P_Update_OrderData_Miles] @ORDER_NO ,1

				SET @pReturnCode = 1
				SET @EventID1 = (CASE WHEN @IsAddressFieldChange = 1 THEN 6 ELSE 0 END)

				IF (@OldCompany <> @Company)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Company ,@OldCompany ,'' ,'Ship-from Name' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldAddress1 <> @Address1)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Address1 ,@OldAddress1 ,'' ,'Ship-from Address' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldAddress2 <> @Address2)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Address2 ,@OldAddress2 ,'' ,'Ship-from Address 2' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldCity <> @City)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @City ,@OldCity ,'' ,'Ship-from City' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldCounty <> @County)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @County ,@OldCounty ,'' ,'Ship-from County' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldCountry <> @Country)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Country ,@OldCountry ,'' ,'Ship-from Country_Region Code' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldState <> @State)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @State ,@OldState ,'' ,'Ship-from State' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldZipCode <> @ZipCode)
				BEGIN
					SET @IsZipChanged = 1

					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @ZipCode ,@OldZipCode ,'' ,'Ship-from Post Code' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO

					EXEC [PinnacleProd].[dbo].[Metro_UpdateScheduleType] @ORDER_NO ,1 ,@WebUserID ,0
				END

				IF (@OldHubName <> @HubName)
				BEGIN
					SET @IsHubChanged = 1

					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @HubName ,@OldHubName ,'' ,'Origin Hub' ,'Metropolitan$TR Warehouse Hub' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldContactPerson <> @ContactPerson)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @ContactPerson ,@OldContactPerson ,'' ,'Ship-from Contact' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldMobile <> @Mobile)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Mobile ,@OldMobile ,'' ,'Ship-from Mobile' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldPhone <> @Phone)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Phone ,@OldPhone ,'' ,'Ship-from Phone' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldEmail <> @Email)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Email ,@OldEmail ,'' ,'Ship from Email' ,'Metropolitan$Sales Linkup' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldLatLong <> @LatLong)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @LatLong ,@OldLatLong ,'' ,'Ship-from Latlong' ,'Metropolitan$Sales Linkup' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldPlaceId <> @PlaceId)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] 'Updated' ,'' ,'' ,'OriginPlaceID' ,'Metro_OrderData' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldAreaTypeName <> @AreaTypeName)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @AreaTypeName ,@OldAreaTypeName ,'' ,'OrigAreaType' ,'Metro_OrderData' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END
			END
		END
		ELSE IF @pReturnText = ''
		BEGIN
			SET @IsBlindShipmentText = (CASE WHEN @IsBlindShipment = 1 THEN 'Yes' ELSE 'No' END)

			SELECT @OldIsBlindShipmentText = (CASE WHEN sh.[Blind Shippment] = 1 THEN 'Yes' ELSE 'No' END)
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
				,@OldPlaceId = isnull(od.[DestinationPlaceID], '')
				,@OldCounty = sh.[Ship-to County]
				,@Country = sh.[Ship-to Country_Region Code]
				,@ServiceType = sl.[Service type]
				,@OldHub = isnull(od.DestHub, '')
				,@OldHubName = [POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (od.DestHub)
				,@OldAreaType = od.DestAreaType
				,@OldAreaTypeName = isnull((SELECT [Name] FROM [PPlus_DB].[dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = 150 AND MTV_ID = od.DestAreaType), '')
			FROM [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh WITH (NOLOCK)
			JOIN [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl WITH (NOLOCK) ON sl.[Document No] = sh.[No_]
			JOIN [PinnacleProd].[dbo].[Metro_OrderData] od WITH (NOLOCK) ON od.[OrderNo] = sh.[No_]
			WHERE sh.[No_] = @ORDER_NO

			IF (@OldZipCode <> @ZipCode)
			BEGIN
				SELECT @AreaType=[POMS_DB].[dbo].[F_Get_PinnacleAreaType_From_NewAreaType] (zcl.[AreaType_MTV_ID])
					,@AreaTypeName=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (zcl.[AreaType_MTV_ID])
					,@Hub=zcl.[HUB_CODE]
					,@HubName=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (zcl.[HUB_CODE])
					,@HubZone=[POMS_DB].[dbo].[F_Get_HubZone_From_HubCode] (zcl.[HUB_CODE])
				FROM [POMS_DB].[dbo].[T_Zip_Code_List] zcl with (nolock) where zcl.[IsActive] = 1 and zcl.[ZIP_CODE] = @ZipCode
			END
			ELSE
			BEGIN
				SELECT @AreaType = @OldAreaType
					,@Hub = @OldHub
					,@HubName = @OldHubName
					,@AreaTypeName = @OldAreaTypeName
			END

			IF @pReturnText = ''
			BEGIN
				UPDATE [PinnacleProd].[dbo].[Metropolitan$Sales Header]
				SET [Destination Name] = @Name
					,[Ship-to Name] = @Company
					,[Ship-to Address] = @Address1
					,[Ship-to Address 2] = @Address2
					,[Ship-to City] = @City
					,[Ship-to State] = @State
					,[Ship-to Contact] = @ContactPerson
					,[Ship-to Post Code] = @ZipCode
					,[Ship-to Mobile] = @Mobile
					,[Ship-to County] = @County
					,[Ship-to Country_Region Code] = @Country
					,[Blind Shippment] = @IsBlindShipment
					,[Ship-to Phone] = @Phone
					,[Shortcut Dimension 1 Code] = @Hub
					,[Modified On] = getutcdate()
					,[ModifiedBy] = @WebUserID
				WHERE [No_] = @ORDER_NO

				UPDATE [PinnacleProd].[dbo].[Metropolitan$Sales Line]
				SET [Shortcut Dimension 1 Code] = @Hub
					,[Modified By] = @WebUserID
					,[Modified On] = getutcdate()
				WHERE [Document No_] = @ORDER_NO

				UPDATE [PinnacleProd].[dbo].[Metropolitan$Sales Linkup]
				SET [Ship to Email] = @Email
					,[Ship-to Latlong] = @LatLong
					,[Modified On] = getutcdate()
					,[Modified By] = @WebUserID
				WHERE [Document No] = @ORDER_NO

				DECLARE @BarcodeDB TABLE (
					[Order No] NVARCHAR(20)
					,[Scan Time] NVARCHAR(20)
					,[Location] NVARCHAR(20)
					);

				INSERT INTO @BarcodeDB ([Order No] ,[Scan Time] ,[Location])
				SELECT [Order No] ,[Scan Time] ,[Location] FROM [PinnacleArchiveDB].[dbo].[Metropolitan$Barcode Scan History] WITH (NOLOCK) WHERE [Order No] = @ORDER_NO

				INSERT INTO @BarcodeDB ([Order No] ,[Scan Time] ,[Location])
				SELECT [Order No] ,[Scan Time] ,[Location] FROM [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] WITH (NOLOCK) WHERE [Order No] = @ORDER_NO

				DECLARE @MainZone NVARCHAR(20) = ''

				SELECT TOP 1 @MainZone = hl.HUB_ZONE FROM [POMS_DB].[dbo].[T_Hub_List] hl WITH (NOLOCK) WHERE hl.HUB_CODE = @Hub

				SELECT @DestZoneFirstScanDate = min(BS.[Scan Time]) FROM @BarcodeDB BS WHERE BS.[Order No] = @ORDER_NO 
					AND [Location] IN (SELECT [HUB_CODE] FROM [POMS_DB].[dbo].[T_Hub_List] hl WITH (NOLOCK) WHERE hl.HUB_ZONE = @MainZone)

				SELECT @DestHubFirstScanDate = min([Scan Time]) FROM @BarcodeDB bsh WHERE bsh.[Location] = @Hub AND bsh.[Order No] = @ORDER_NO 

				UPDATE [PinnacleProd].[dbo].[Metro_OrderData]
				SET [DestHub] = @Hub
					,[DestAreaType] = @AreaType
					,[DestMilesRadius] = NULL
					,[DestDrivingMiles] = NULL
					,[LHDrivingMiles] = NULL
					,[DateModified] = GETUTCDATE()
					,[DestinationPlaceID] = @PlaceId
					,[LiveDestHub] = @Hub
					,[DestHub_ChangeCount] = (CASE WHEN isnull([DestHub], '') <> isnull(@Hub, '') THEN [DestHub_ChangeCount] + 1 ELSE [DestHub_ChangeCount] END)
					,[DestZone_FirstScanDate] = @DestZoneFirstScanDate
					,[DestHub_FirstScanDate] = @DestHubFirstScanDate
				WHERE [OrderNo] = @ORDER_NO

				EXEC [PinnacleProd].[dbo].[Metro_UpdateOrderItemData] @ORDER_NO ,@Hub ,@MainZone

				SET @SearchType = [POMS_DB].[dbo].[F_Set_Order_SearchType] (@OldName,@Name,'DESTNAME',@SearchType)
				SET @SearchType = [POMS_DB].[dbo].[F_Set_Order_SearchType] (@OldCompany,@Company,'SHIPTONAME',@SearchType)
				SET @SearchType = [POMS_DB].[dbo].[F_Set_Order_SearchType] (@OldAddress1,@Address1,'SHIPTOADDRESS',@SearchType)
				SET @SearchType = [POMS_DB].[dbo].[F_Set_Order_SearchType] (@OldContactPerson,@ContactPerson,'SHIPTOCONTACT',@SearchType)
				
				EXEC [PinnacleProd].[dbo].[P_Orders_Search_Value_Character_IU] @ORDER_NO ,@SearchType

				IF (@OldMobile <> @Mobile OR @OldPhone <> @Phone)
				BEGIN
					EXEC [PinnacleProd].[dbo].[P_Update_Phones] @ORDER_NO
				END

				EXEC [PinnacleProd].[dbo].[P_Update_OrderData_Miles] @ORDER_NO ,0

				EXEC [PinnacleProd].[dbo].[Metro_DimensionSet_SaveForOrder] @ORDER_NO

				SET @pReturnCode = 1
				SET @EventID1 = (CASE WHEN @IsBlindShipment = 1 AND @OldIsBlindShipmentText = 'No' AND @IsAddressFieldChange = 1 THEN 53
					WHEN @OldIsBlindShipmentText = 'Yes' AND @IsBlindShipment = 0 AND @IsAddressFieldChange = 1 THEN 91
					WHEN @IsBlindShipment = 0 AND @OldIsBlindShipmentText = 'No' AND @IsAddressFieldChange = 1 THEN 39
					ELSE 0 END)
				SET @EventID2 = (CASE WHEN @IsBlindShipment = 1 AND @OldIsBlindShipmentText = 'No' AND @IsAddressFieldChange = 1 THEN 90
					WHEN @IsBlindShipment = 0 AND @OldIsBlindShipmentText = 'Yes' AND @IsAddressFieldChange = 1 THEN 38
					ELSE 0 END)

				IF (@OldIsBlindShipmentText <> @IsBlindShipmentText)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @IsBlindShipmentText ,@OldIsBlindShipmentText ,'' ,'Blind Shippment' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldName <> @Name)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Name ,@OldName ,'' ,'Destination Name' ,'Metropolitan$Sales Linkup' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldCompany <> @Company)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Company ,@OldCompany ,'' ,'Ship-to Name' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldAddress1 <> @Address1)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Address1 ,@OldAddress1 ,'' ,'Ship-to Address' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldAddress2 <> @Address2)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Address2 ,@OldAddress2 ,'' ,'Ship-to Address 2' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldCity <> @City)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @City ,@OldCity ,'' ,'Ship-to City' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldCounty <> @County)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @County ,@OldCounty ,'' ,'Ship-to County' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldCountry <> @Country)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Country ,@OldCountry ,'' ,'Ship-to Country_Region Code' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldState <> @State)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @State ,@OldState ,'' ,'Ship-to State' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldZipCode <> @ZipCode)
				BEGIN
					SET @IsZipChanged = 1

					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @ZipCode ,@OldZipCode ,'' ,'Ship-to Post Code' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO

					EXEC [PinnacleProd].[dbo].[Metro_UpdateScheduleType] @ORDER_NO ,2 ,@WebUserID ,0

					IF year(@FirstOfferDate) > 2000
					BEGIN
						SET @IsFirstOfferDateChanged = 1

						DECLARE @FirstOfferDateText NVARCHAR(50) = (CASE WHEN year(@FirstOfferDate) > 2000 THEN format(@FirstOfferDate, 'MM/dd/yyyy') ELSE '' END)

						UPDATE sl
						SET sl.[First Offered Delvery Date] = '1753-01-01'
						FROM [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl
						WHERE [Document No] = @ORDER_NO AND [Document Type] = 1

						EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] '' ,@FirstOfferDateText ,'' ,'First Offered Delvery Date' ,'Metropolitan$Sales Linkup' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
					END
				END

				IF (@OldHubName <> @HubName)
				BEGIN
					SET @IsHubChanged = 1

					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @HubName ,@OldHubName ,'' ,'Destination Hub' ,'Metropolitan$TR Warehouse Hub' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldContactPerson <> @ContactPerson)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @ContactPerson ,@OldContactPerson ,'' ,'Ship-to Contact' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldMobile <> @Mobile)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Mobile ,@OldMobile ,'' ,'Ship-to Mobile' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldPhone <> @Phone)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Phone ,@OldPhone ,'' ,'Ship-to Phone' ,'Metropolitan$Sales Header' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldEmail <> @Email)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @Email ,@OldEmail ,'' ,'Ship to Email' ,'Metropolitan$Sales Linkup' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldLatLong <> @LatLong)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @LatLong ,@OldLatLong ,'' ,'Ship-to Latlong' ,'Metropolitan$Sales Linkup' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldPlaceId <> @PlaceId)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] 'Updated' ,'' ,'' ,'DestinationPlaceID' ,'Metro_OrderData' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END

				IF (@OldAreaTypeName <> @AreaTypeName)
				BEGIN
					EXEC [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @AreaTypeName ,@OldAreaTypeName ,'' ,'DestAreaType' ,'Metro_OrderData' ,@ORDER_NO ,@UserName ,40000 ,@ORDER_NO
				END
			END
		END
	END

	IF @IsAddressFieldChange = 1 AND @IsUpdate = 1 AND @pReturnCode = 1
	BEGIN
		IF @EventID1 > 0
		BEGIN
			EXEC [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] @EventID1 ,0 ,0 ,0 ,@WebUserID ,1 ,'10000' ,'ShippingStatus/OrderDetail/UpdateShippingStatus' ,@WebUserID ,@ORDER_NO ,@CustomerNo ,'' ,'' ,''
		END

		IF @EventID2 > 0
		BEGIN
			EXEC [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] @EventID2 ,0 ,0 ,0 ,@WebUserID ,1 ,'10000' ,'ShippingStatus/OrderDetail/UpdateShippingStatus' ,@WebUserID ,@ORDER_NO ,@CustomerNo ,'' ,'' ,''
		END
	END

	IF (@GetRecordType_MTV_ID in (147104,147105) AND @IsUpdate = 1)
	BEGIN
		SELECT @ArchiveEventsCount = count(1) FROM [PinnacleArchiveDB].[dbo].[Metropolitan$Event Master Log] WITH (NOLOCK) WHERE [Order Number] = @ORDER_NO
	END

	IF @pReturnCode = 1 OR @IsUpdate = 0
	BEGIN
		insert into @ReturnTable ([ORDER_ID], [OrderStatus_MTV_ID], [OrderStatus_Name], [ShippingStatus_EVENT_ID], [ShippingStatus_EVENT_Name], [ActivitiesEvent], [IsOrigin]
			, [FirstName], [MiddleName], [LastName], [Company], [ContactPerson], [Address], [Address2], [City], [State], [ZipCode], [County], [CountryRegionCode], [Email], [Mobile]
			, [Phone], [PhoneExt], [Lat], [Lng], [PlaceID], [AreaType_MTV_ID], [AreaType_Name], [HUB_CODE], [HUB_Name], [Live_HUB_CODE], [Live_HUB_Name], [ZONE_CODE], [ZONE_Name]
			, [ChangeCount], [IsBlindShipTo], [PickupScheduleType_MTV_ID], [PickupScheduleType_Name])
		SELECT [ORDER_ID] = @ORDER_ID
			,[ShippingStatus_EVENT_ID] = sh.[Shipping Status]
			,[ShippingStatus_EVENT_Name]=isnull((select top 1 evm.[Events] from [PinnacleProd].[dbo].[Metropolitan$Event Master] evm with (nolock) where evm.[Entry No] = sh.[Shipping Status]), '')
			,[OrderStatus_MTV_ID] = sh.[Order Status]
			,[OrderStatus_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.[ID] = sh.[Order Status]), '')
			,[ActivitiesEvent] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Event Master Log] eml with (nolock) where eml.[Order Number] = sh.[No_]) + @ArchiveEventsCount
			,[IsOrigin] = @IsOrigin
			,[FirstName]=(case when @IsOrigin = 1 then sh.[Ship-from Name] else sh.[Destination Name] end)
			,[MiddleName]=''
			,[LastName]=''
			,[Company]=(case when @IsOrigin = 1 then sh.[Ship-from Name 2] else sh.[Ship-to Name] end)
			,[ContactPerson]=(case when @IsOrigin = 1 then sh.[Ship-from Contact] else sh.[Ship-to Contact] end)
			,[Address]=(case when @IsOrigin = 1 then sh.[Ship-from Address] else sh.[Ship-to Address] end)
			,[Address2]=(case when @IsOrigin = 1 then sh.[Ship-from Address 2] else sh.[Ship-to Address 2] end)
			,[City]=(case when @IsOrigin = 1 then sh.[Ship-from City] else sh.[Ship-to City] end)
			,[State]=(case when @IsOrigin = 1 then left(sh.[Ship-from State],5) else left(sh.[Ship-to State],5) end)
			,[ZipCode]=(case when @IsOrigin = 1 then sh.[Ship-from Post Code] else sh.[Ship-to Post Code] end)
			,[County]=(case when @IsOrigin = 1 then sh.[Ship-from County] else sh.[Ship-to County] end)
			,[CountryRegionCode]=(case when @IsOrigin = 1 then sh.[Ship-from Country_Region Code] else sh.[Ship-to Country_Region Code] end)
			,[Email]=(case when @IsOrigin = 1 then sl.[Ship from Email] else sl.[Ship to Email] end)
			,[Mobile]=(case when @IsOrigin = 1 then sh.[Ship-from Mobile] else sh.[Ship-to Mobile] end)
			,[Phone]=(case when @IsOrigin = 1 then oph.[PhoneNo] else dph.[PhoneNo] end)
			,[PhoneExt]=(case when @IsOrigin = 1 then oph.[Extension] else dph.[Extension] end)
			,[Lat]=(case when @IsOrigin = 1 then oll.Text1 else dll.Text1 end)
			,[Lng]=(case when @IsOrigin = 1 then oll.Text2 else dll.Text2 end)
			,[PlaceID]=(case when @IsOrigin = 1 then od.OriginPlaceID else od.DestinationPlaceID end)
			,[AreaType_MTV_ID] = (case when @IsOrigin = 1 then od.OrigAreaType else od.DestAreaType end)
			,[AreaType_Name]=isnull((Select [Name] From [PPlus_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 150 
				and MTV_ID = (case when @IsOrigin = 1 then od.OrigAreaType else od.DestAreaType end)),'')
			,[HUB_CODE] = (case when @IsOrigin = 1 then od.OrigHub else od.DestHub end)
			,[HUB_Name]=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] ((case when @IsOrigin = 1 then od.OrigHub else od.DestHub end))
			,[HUB_CODE] = (case when @IsOrigin = 1 then od.LiveOrigHub else od.LiveDestHub end)
			,[HUB_Name]=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] ((case when @IsOrigin = 1 then od.LiveOrigHub else od.LiveDestHub end))
			,[ZONE_CODE] = (case when @IsOrigin = 1 then od.OrigZone else od.DestZone end)
			,[ZONE_Name]=[POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] ((case when @IsOrigin = 1 then od.OrigZone else od.DestZone end))
			,[IsBlindShipTo]=cast(sh.[Blind Shippment] as bit)
			,[ChangeCount]=(case when @IsOrigin = 1 then 0 else od.DestHub_ChangeCount end)
			,[PickupScheduleType_MTV_ID] = 0--(case when @IsOrigin = 1 then sl.[Pickup Schedule Type] else sl.[Pickup Schedule Type] end)
			,[PickupScheduleType_Name]=[POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10520,(case when @IsOrigin = 1 then sl.[Pickup Schedule Type] else sl.[Pickup Schedule Type] end))
		FROM [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh WITH (NOLOCK)
		JOIN [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl WITH (NOLOCK) ON sl.[Document No] = sh.[No_]
		JOIN [PinnacleProd].[dbo].[Metro_OrderData] od WITH (NOLOCK) ON od.[OrderNo] = sh.[No_]
		outer apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](sh.[Ship-from Phone]) oph
		outer apply [PinnacleProd].[dbo].[fn_FormattedPhoneAndExt](sh.[Ship-to Phone]) dph
		outer apply [POMS_DB].[dbo].[SplitText] (sl.[Ship-from Latlong],',') oll
		outer apply [POMS_DB].[dbo].[SplitText] (sl.[Ship-to Latlong],',') dll
		WHERE sh.[No_] = @ORDER_NO
	END

	select * from @ReturnTable 

END
GO
