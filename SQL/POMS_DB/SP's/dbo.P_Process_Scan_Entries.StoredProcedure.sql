USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Process_Scan_Entries]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @Ret_pReturn_Code bit = 0 Declare @Ret_pReturn_Text nvarchar(1000) = '' Declare @Ret_pExecution_Error nvarchar(max) = '' exec [dbo].[P_Process_Scan_Entries] @pReturn_Code = @Ret_pReturn_Code out, @pReturn_Text = @Ret_pReturn_Text out, @pExecution_Error  = @Ret_pExecution_Error out select @Ret_pReturn_Code ,@Ret_pReturn_Text ,@Ret_pExecution_Error
-- =============================================
CREATE PROCEDURE [dbo].[P_Process_Scan_Entries]
(	
	@pJson nvarchar(max) = null--'[{"RequestID":"10f39552-eb95-4d67-8c28-e938445f2a5b","OIS_ID":0,"BARCODE":"8134019701150006","OIS_GUID":"5f08b2ec-71aa-432 e-9114-4ef9de132193","RelabelCount":2,"ScanType_MTV_ID":113101,"LOCATION_ID":"IN-NC","HUB_CODE":"NC-AD","DeviceCode_MTV_CODE":"DEVICE","ScanTime":"2023-11-25 12:45:38 AM","ScanBy":"ABDULLAH.ARSHAD","ScanByID":934,"MANIFEST_ID":112084,"ManifestType_MTV_ID":115101,"Lat":"","Lng":"","ScanAnytime":false,"AutoScan":false,"IsRelabelRequired":false,"IsActive":true,"IsError":false,"ErrorMsg":"","IsJsonBasicValidation":false,"WarningMsg":""}]'
	--'[{"RequestID":"49b97bac-2187-4734-89a3-0ae180a7ad4e","OIS_ID":0,"BARCODE":"8134019101150003","OIS_GUID":"5f08b2ec-71aa-432e-9114-4ef9de132193","RelabelCount":0,"ScanType_MTV_ID":113101,"LOCATION_ID":"IN-NC","HUB_CODE":"NC-AD","DeviceCode_MTV_CODE":"DEVICE","ScanTime":"2023-11-24 06:28:19 PM","ScanBy":"TOUSEEF.AHMAD","ScanByID":0,"MANIFEST_ID":112084,"ManifestType_MTV_ID":115101,"Lat":"","Lng":"","ScanAnytime":false,"AutoScan":false,"IsRelabelRequired":false,"IsActive":true,"IsError":false,"ErrorMsg":"","IsJsonBasicValidation":false}]' -- if null then below fields are required

	,@pOIS_ID int = null -- can be 0
	,@pBARCODE nvarchar(20) = null
	,@pOIS_GUID nvarchar(36) = null -- only required for images
	,@pRelabelCount int = null
	,@pScanType_MTV_ID int = null
	,@pLOCATION_ID nvarchar(20) = null
	,@pHUB_CODE nvarchar(20) = null
	,@pDeviceCode_MTV_CODE nvarchar(20) = null
	,@pScanTime datetime = null
	,@pScanBy nvarchar(150) = null
	,@pScanByID int = null
	,@pMANIFEST_ID int = null
	,@pManifestType_MTV_ID int = null
	,@pLat nvarchar(30) = null
	,@pLng nvarchar(30) = null
	,@pScanAnytime bit = null
	,@pAutoScan bit = null
	,@pIsRelabelRequired bit = null
	,@pIsActive bit = 1
	,@pIsError bit = 0
	,@pErrorMsg nvarchar(1000) = ''
	,@pWarningMsg nvarchar(1000) = ''
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(max) output
)
AS
BEGIN
	
	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''

	Declare @pRequestID nvarchar(36) = ''
	
	drop table if exists #ReturnTable
	Create table #ReturnTable
	(RequestID nvarchar(36)
	,BARCODE nvarchar(20)
	,ORDER_ID int
	,OIS_GUID nvarchar(36)
	,IsError bit
	,ErrorMsg nvarchar(max)
	,Warning_Text nvarchar(max)
	)

	drop table if exists #ProcessScanEntriesJsonTable
	Create table #ProcessScanEntriesJsonTable
	(ID int
	,RequestID nvarchar(36)
	,OIS_ID int
	,BARCODE nvarchar(20)
	,OIS_GUID nvarchar(36)
	,RelabelCount int
	,ScanType_MTV_ID int
	,LOCATION_ID nvarchar(20)
	,HUB_CODE nvarchar(20)
	,DeviceCode_MTV_CODE nvarchar(20)
	,ScanTime datetime
	,ScanBy nvarchar(150)
	,ScanByID Int
	,MANIFEST_ID int
	,ManifestType_MTV_ID int
	,Lat nvarchar(30)
	,Lng nvarchar(30)
	,ScanAnytime bit
	,AutoScan bit
	,IsRelabelRequired bit
	,IsActive bit
	,IsError bit
	,ErrorMsg nvarchar(max)
	,IsJsonBasicValidation bit
	,WarningMsg nvarchar(max))

	Declare @ID int = 0
	Declare @RequestID nvarchar(36) = ''
	Declare @OIS_ID int = 0
	Declare @BARCODE nvarchar(20) = ''
	Declare @OI_ID int = 0
	Declare @ORDER_ID int = 0
	Declare @RelabelCount int = 0
	Declare @OIS_GUID nvarchar(36) = ''
	Declare @ScanType_MTV_ID int = 0
	Declare @LOCATION_ID nvarchar(20) = ''
	Declare @HUB_CODE nvarchar(20) = ''
	Declare @DeviceCode_MTV_CODE nvarchar(20) = ''
	Declare @ScanTime datetime = getutcdate()
	Declare @ScanBy nvarchar(150) = ''
	Declare @ScanByID Int = 0
	Declare @MANIFEST_ID int = 0
	Declare @ManifestType_MTV_ID int = 0
	Declare @Lat nvarchar(30) = ''
	Declare @Lng nvarchar(30) = ''
	Declare @ScanAnytime bit = 0
	Declare @AutoScan bit = 0
	Declare @IsRelabelRequired bit = 0
	Declare @IsActive bit = 1
	Declare @IsError bit = 0
	Declare @ErrorMsg nvarchar(max) = ''
	Declare @WarningMsg nvarchar(max) = ''
	Declare @IsJsonBasicValidation bit = 0
	Declare @NewRelabelCount int = 0
	Declare @ManifestValidType int = 0
	
	begin try

		if isnull(@pJson,'') <> ''
		begin
			insert into #ProcessScanEntriesJsonTable (ID ,RequestID ,OIS_ID ,BARCODE ,OIS_GUID ,RelabelCount ,ScanType_MTV_ID ,LOCATION_ID ,HUB_CODE ,DeviceCode_MTV_CODE ,ScanTime ,ScanBy ,ScanByID ,MANIFEST_ID ,ManifestType_MTV_ID ,Lat ,Lng ,ScanAnytime 
			,AutoScan ,IsRelabelRequired ,IsActive ,IsError ,ErrorMsg ,IsJsonBasicValidation ,WarningMsg)
			select ID ,RequestID ,OIS_ID ,BARCODE ,OIS_GUID ,RelabelCount ,ScanType_MTV_ID ,LOCATION_ID ,HUB_CODE ,DeviceCode_MTV_CODE ,ScanTime ,ScanBy ,ScanByID ,MANIFEST_ID ,ManifestType_MTV_ID ,Lat ,Lng ,ScanAnytime ,AutoScan ,IsRelabelRequired 
			,IsActive ,IsError ,ErrorMsg ,IsJsonBasicValidation ,WarningMsg from [POMS_DB].[dbo].[F_Get_ProcessScanEntries_JsonTable] (@pJson) order by ID
		end
		else 
		begin
			select @pRequestID = lower(newid())
			,@pOIS_ID = isnull(@pOIS_ID,0) 
			,@pBARCODE = isnull(@pBARCODE,'') 
			,@pOIS_GUID = isnull(@pOIS_GUID,lower(newid()))
			,@pRelabelCount = @pRelabelCount
			,@pScanType_MTV_ID = isnull(@pScanType_MTV_ID,0) 
			,@pLOCATION_ID = isnull(@pLOCATION_ID,'') 
			,@pHUB_CODE = isnull(@pHUB_CODE,'') 
			,@pDeviceCode_MTV_CODE = isnull(@pDeviceCode_MTV_CODE,'') 
			,@pScanTime = isnull(@pScanTime,getutcdate()) 
			,@pScanBy = isnull(@pScanBy,'') 
			,@pScanByID = isnull(@pScanByID,0) 
			,@pMANIFEST_ID = isnull(@pMANIFEST_ID,0) 
			,@pManifestType_MTV_ID = isnull(@pManifestType_MTV_ID,0) 
			,@pLat = isnull(@pLat,'') 
			,@pLng = isnull(@pLng,'') 
			,@pScanAnytime = isnull(@pScanAnytime,0) 
			,@pAutoScan = isnull(@pAutoScan,0) 
			,@pIsRelabelRequired = isnull(@pIsRelabelRequired,0) 
			,@pIsActive = isnull(@pIsActive,1) 
			,@pIsError = isnull(@pIsError,0) 
			,@pErrorMsg = isnull(@pErrorMsg,'')
			,@IsJsonBasicValidation = 0

			insert into #ProcessScanEntriesJsonTable (ID ,RequestID ,OIS_ID ,BARCODE ,OIS_GUID ,RelabelCount ,ScanType_MTV_ID ,LOCATION_ID ,HUB_CODE ,DeviceCode_MTV_CODE ,ScanTime ,ScanBy ,ScanByID ,MANIFEST_ID ,ManifestType_MTV_ID ,Lat ,Lng ,ScanAnytime 
			,AutoScan ,IsRelabelRequired ,IsActive ,IsError ,ErrorMsg ,IsJsonBasicValidation, WarningMsg)
			select ID = 1 ,@pRequestID ,@pOIS_ID ,@pBARCODE ,@pOIS_GUID ,@pRelabelCount ,@pScanType_MTV_ID ,@pLOCATION_ID ,@pHUB_CODE ,@pDeviceCode_MTV_CODE ,@pScanTime ,@pScanBy ,@pScanByID ,@pMANIFEST_ID ,@pManifestType_MTV_ID ,@pLat ,@pLng 
			,@pScanAnytime ,@pAutoScan ,@pIsRelabelRequired ,@pIsActive ,@pIsError ,@pErrorMsg ,@IsJsonBasicValidation ,WarningMsg = ''

		end

	end try
	begin catch
		Set @pExecution_Error = 'P_Process_Scan_Entries: ' + ERROR_MESSAGE()
		set @pReturn_Text = 'Internal Server Error'
	end catch
	
	if not exists(select ID from #ProcessScanEntriesJsonTable) and @pReturn_Text = ''
	begin
		set @pReturn_Text = 'No Record Found'
	end

	if @pReturn_Text = '' and @pExecution_Error = ''
	begin
		
		Declare @RoleID int = 0
		Declare @IsGroupRoleID bit = 0
		Declare @LastLOCATION_ID nvarchar(20) = ''
		Declare @GetRecordType_MTV_ID int = 0
		Declare @TRACKING_NO nvarchar(20) = ''
		Declare @TempIsError bit = 0
		Declare @TempErrorMsg nvarchar(1000) = ''
		Declare @TempWarningMsg nvarchar(1000) = ''
		Declare @TempReturn_Code bit = 0
		Declare @TempReturn_Text nvarchar(1000) = ''
		Declare @TempExecution_Error nvarchar(max) = ''
		Declare @PinnacleScanType int = 0
		Declare @PinnacleManifestType int = 0
		Declare @PinnacleManifestSubType int = 0
						
		Declare @TryCount int = 0
		Declare @MaxCount int = 0
		select @MaxCount = max(ID) from #ProcessScanEntriesJsonTable
		while @TryCount < @MaxCount
		begin
			set @pReturn_Code = 0
			set @TryCount = @TryCount + 1
			
			begin try
				
				set @ErrorMsg = ''
				set @WarningMsg = ''
				set @GetRecordType_MTV_ID = 0
				set @OI_ID = 0
				set @TRACKING_NO = ''

				select @ID = ID ,@RequestID = RequestID ,@OIS_ID = OIS_ID ,@BARCODE = BARCODE ,@OIS_GUID = OIS_GUID , @RelabelCount = RelabelCount ,@ScanType_MTV_ID = ScanType_MTV_ID ,@LOCATION_ID = upper(LOCATION_ID)
				,@HUB_CODE = HUB_CODE ,@DeviceCode_MTV_CODE = DeviceCode_MTV_CODE ,@ScanTime = ScanTime ,@ScanBy = ScanBy ,@ScanByID = ScanByID ,@MANIFEST_ID = MANIFEST_ID ,@ManifestType_MTV_ID = ManifestType_MTV_ID 
				,@Lat = Lat ,@Lng = Lng ,@ScanAnytime = ScanAnytime ,@AutoScan = AutoScan ,@IsRelabelRequired = IsRelabelRequired ,@IsActive = IsActive ,@IsError = IsError ,@ErrorMsg = ErrorMsg
				, @IsJsonBasicValidation = IsJsonBasicValidation ,@WarningMsg = WarningMsg from #ProcessScanEntriesJsonTable where ID = @TryCount

				set @RequestID = (case when @RequestID = '' then lower(newid()) else @RequestID end)
				set @OIS_GUID = (case when @OIS_GUID = '' then lower(newid()) else @OIS_GUID end)

				if @BARCODE = ''
				begin
					set @ErrorMsg = (case when @ErrorMsg = '' then 'Barcode is Required, RequiredID: ' + @RequestID else @ErrorMsg + '; Barcode is Required, RequiredID: ' + @RequestID end)
					set @IsError = 1
					set @IsActive = 0
				end
				else if len(@BARCODE) <> 16
				begin
					set @ErrorMsg = (case when @ErrorMsg = '' then 'Invalid Barcode: ' + @BARCODE else @ErrorMsg + '; Invalid Barcode: ' + @BARCODE end)
					set @IsError = 1
					set @IsActive = 0
				end
				else if isnumeric(@BARCODE) = 0
				begin
					set @ErrorMsg = (case when @ErrorMsg = '' then 'Invalid Barcode: ' + @BARCODE else @ErrorMsg + '; Invalid Barcode: ' + @BARCODE end)
					set @IsError = 1
					set @IsActive = 0
				end
				if (@ErrorMsg = '')
				begin
					if (@ManifestType_MTV_ID in (115100,115101,115102,115106,115107))
					begin
						set @ManifestValidType = 0
						select @ManifestValidType = [POMS_DB].[dbo].[F_Is_Valid_Manifest] (@ManifestType_MTV_ID,@HUB_CODE,@ScanType_MTV_ID,@MANIFEST_ID,@BARCODE)
						if @ManifestValidType = 0
						begin
							set @ErrorMsg = (case when @ErrorMsg = '' then 'Invalid Manifest: ' + cast(@MANIFEST_ID as nvarchar(20)) + ' - ' + isnull([POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@ManifestType_MTV_ID),'or Wrong Type')
								else @ErrorMsg + '; Invalid Manifest: ' + cast(@MANIFEST_ID as nvarchar(20)) + ' - ' + isnull([POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@ManifestType_MTV_ID),'or Wrong Type') end)
							set @IsError = 1
							set @IsActive = 0
						end
					end
				end

				if (@ErrorMsg = '')
				begin
					select @ORDER_ID = oib.ORDER_ID ,@TRACKING_NO = oib.TRACKING_NO ,@OI_ID = oib.OI_ID ,@GetRecordType_MTV_ID = oib.GetRecordType_MTV_ID ,@NewRelabelCount = oib.RelabelCount 
					from [POMS_DB].[dbo].[F_Get_OrderInfo_By_Barcode] (@BARCODE ,@ScanBy) oib
					
					if @ORDER_ID = 0
					begin
						set @ErrorMsg = (case when @ErrorMsg = '' then 'Invalid Barcode: ' + @BARCODE else @ErrorMsg + '; Invalid Barcode: ' + @BARCODE end)
						set @IsError = 1
						set @IsActive = 0
					end

					if @OI_ID = 0 and @ORDER_ID > 0
					begin
						set @ErrorMsg = (case when @ErrorMsg = '' then 'Barcode Doesnot Exists or Deleted: ' + @BARCODE else @ErrorMsg + '; Barcode Doesnot Exists or Deleted: ' + @BARCODE end)
						set @IsError = 1
						set @IsActive = 0
					end

					if (@RelabelCount is not null)
					begin
						if (isnull(@NewRelabelCount,0) <> @RelabelCount)
						begin
							set @IsRelabelRequired = 1
							set @WarningMsg = (case when @WarningMsg = '' then 'Relabel Required Barcode: ' + @BARCODE else @WarningMsg + '; Relabel Required Barcode: ' + @BARCODE end)
						end
					end

				end

				if (@ErrorMsg = '')
				begin
					
					set @TempErrorMsg = ''
					set @TempReturn_Code = 0
					set @TempReturn_Text = ''
					set @TempExecution_Error = ''

					set @PinnacleScanType = [POMS_DB].[dbo].[F_Get_PinnacleScanType_From_NewScanType] (@ScanType_MTV_ID)
					select @PinnacleManifestType = PinnacleManifestType, @PinnacleManifestSubType = PinnacleManifestSubType 
					from [POMS_DB].[dbo].[F_Get_PinnacleManifestType_From_NewManifestType] (@ManifestType_MTV_ID)
	
					--select @RoleID = urm.ROLE_ID, @IsGroupRoleID = IsGroupRoleID from [POMS_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @ScanBy and urm.IsActive = 1

					if @LastLOCATION_ID <> @LOCATION_ID
					begin
						select top 1 @LOCATION_ID = wle.[Code], @HUB_CODE = wle.[Warehouse ID] from [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] wle with (nolock)
						where upper(wle.[Code]) = @LOCATION_ID

						if @LOCATION_ID is null
						begin
							select top 1 @LOCATION_ID = wle.[Code], @HUB_CODE = wle.[Warehouse ID] from [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] wle with (nolock)
							where upper(wle.[Barcode]) = @LOCATION_ID
						end

						set @LOCATION_ID = isnull(@LOCATION_ID,'')
						set @HUB_CODE = isnull(@HUB_CODE,'')

						set @LastLOCATION_ID = @LOCATION_ID
					end

					if (@IsJsonBasicValidation = 0)
					begin
						if not exists(select mtv.MTV_ID from [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MT_ID = 113 and mtv.MTV_ID = @ScanType_MTV_ID)
						begin
							set @WarningMsg = (case when @WarningMsg = '' then 'Invalid ScanType: ' + cast(@ScanType_MTV_ID as nvarchar(20)) else @WarningMsg + '; Invalid ScanType: ' + cast(@ScanType_MTV_ID as nvarchar(20)) end)
						end
						--if not exists(select loc.[Entry No] from [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] loc with(nolock) where loc.[Code] = @LOCATION_ID) 
						--begin
						--	set @WarningMsg = (case when @WarningMsg = '' then 'Invalid LocationID: ' + @LOCATION_ID else @WarningMsg + '; Invalid LocationID: ' + @LOCATION_ID end)
						--end
						if not exists(select HUB_CODE from [POMS_DB].[dbo].[T_Hub_List] hl with(nolock) where hl.[HUB_CODE] = @HUB_CODE) 
						begin
							set @WarningMsg = (case when @WarningMsg = '' then 'Invalid HubCode: ' + @HUB_CODE else @WarningMsg + '; Invalid HubCode: ' + @HUB_CODE end)
						end
						if not exists(select mtv.MTV_ID from [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MT_ID = 114 and mtv.MTV_CODE = @DeviceCode_MTV_CODE) 
						begin
							set @WarningMsg = (case when @WarningMsg = '' then 'Invalid DeviceCode: ' + @DeviceCode_MTV_CODE else @WarningMsg + '; Invalid DeviceCode: ' + @DeviceCode_MTV_CODE end)
						end
						if not exists(select u.[USER_ID] from [POMS_DB].[dbo].[T_Users] u with (nolock) where u.USERNAME = @ScanBy) 
						begin
							set @WarningMsg = (case when @WarningMsg = '' then 'Invalid Username: ' + @ScanBy else @WarningMsg + '; Invalid Username: ' + @ScanBy end)
						end
						if not exists(select * from [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MT_ID = 115 and mtv.MTV_ID = @ManifestType_MTV_ID) 
						begin
							set @WarningMsg = (case when @WarningMsg = '' then 'Invalid ManifestType: ' + cast(@ManifestType_MTV_ID as nvarchar(20)) else @WarningMsg + '; Invalid ManifestType: ' + cast(@ManifestType_MTV_ID as nvarchar(20)) end)
						end
					end

					begin try
					
						Begin Transaction
						
						if (@ScanType_MTV_ID = 113101 and @ManifestType_MTV_ID in (115100,115101,115102,115106,115107))
						begin
							
							exec [POMS_DB].[dbo].[P_Inbound_Scanning_Validation_And_Scan] @ppOIS_ID = @OIS_ID ,@ppOI_ID = @OI_ID ,@ppORDER_ID = @ORDER_ID ,@ppBARCODE = @BARCODE ,@ppOIS_GUID = @OIS_GUID ,@ppRelabelCount = @RelabelCount 
							,@ppScanType_MTV_ID = @PinnacleScanType ,@ppLOCATION_ID = @LOCATION_ID ,@ppHUB_CODE = @HUB_CODE ,@ppDeviceCode_MTV_CODE = @DeviceCode_MTV_CODE ,@ppScanTime = @ScanTime ,@ppScanBy = @ScanBy ,@ppScanByID = @ScanByID 
							,@ppMANIFEST_ID = @MANIFEST_ID ,@ppManifestType_MTV_ID = @PinnacleManifestType ,@ppManifestSubType_MTV_ID = @PinnacleManifestSubType ,@ppLat = @Lat ,@ppLng = @Lng ,@ppScanAnytime = @ScanAnytime ,@ppAutoScan = @AutoScan 
							,@ppIsRelabelRequired = @IsRelabelRequired ,@ppRoleID = @RoleID ,@ppIsGroupRoleID = @IsGroupRoleID ,@ppGetRecordType_MTV_ID = @GetRecordType_MTV_ID ,@ppTRACKING_NO = @TRACKING_NO ,@ppIsValidate = 1 ,@ppIsUpdate = 1 
							,@ppIsActive = @IsActive ,@ppIsError = @TempIsError out ,@ppErrorMsg = @TempErrorMsg out ,@ppWarningMsg = @TempWarningMsg out ,@ppReturn_Code = @TempReturn_Code out ,@ppReturn_Text = @TempReturn_Text out
							,@ppExecution_Error = @TempExecution_Error out

							set @ErrorMsg = (case when @ErrorMsg = '' then @TempErrorMsg else @ErrorMsg + '; ' + @TempErrorMsg end)
							set @WarningMsg = (case when @WarningMsg = '' then @TempWarningMsg else @WarningMsg + '; ' + @TempWarningMsg end)

							if @TempIsError = 1
							begin
								set @IsError = @TempIsError
								set @IsActive = 0
							end

						end
						else if (@ScanType_MTV_ID = 113101 and @ManifestType_MTV_ID in (115103,115104,115105,115108,115109))
						begin
							
							exec [POMS_DB].[dbo].[P_Inbound_NotInManifest_Scanning_Validation_And_Scan] @ppOIS_ID = @OIS_ID ,@ppOI_ID = @OI_ID ,@ppORDER_ID = @ORDER_ID ,@ppBARCODE = @BARCODE ,@ppOIS_GUID = @OIS_GUID ,@ppRelabelCount = @RelabelCount 
							,@ppScanType_MTV_ID = @PinnacleScanType ,@ppLOCATION_ID = @LOCATION_ID ,@ppHUB_CODE = @HUB_CODE ,@ppDeviceCode_MTV_CODE = @DeviceCode_MTV_CODE ,@ppScanTime = @ScanTime ,@ppScanBy = @ScanBy ,@ppScanByID = @ScanByID 
							,@ppMANIFEST_ID = @MANIFEST_ID ,@ppManifestType_MTV_ID = @PinnacleManifestType ,@ppManifestSubType_MTV_ID = @PinnacleManifestSubType ,@ppLat = @Lat ,@ppLng = @Lng ,@ppScanAnytime = @ScanAnytime ,@ppAutoScan = @AutoScan 
							,@ppIsRelabelRequired = @IsRelabelRequired ,@ppRoleID = @RoleID ,@ppIsGroupRoleID = @IsGroupRoleID ,@ppGetRecordType_MTV_ID = @GetRecordType_MTV_ID ,@ppTRACKING_NO = @TRACKING_NO ,@ppIsValidate = 1 ,@ppIsUpdate = 1 
							,@ppIsActive = @IsActive ,@ppIsError = @TempIsError out ,@ppErrorMsg = @TempErrorMsg out ,@ppWarningMsg = @TempWarningMsg out ,@ppReturn_Code = @TempReturn_Code out ,@ppReturn_Text = @TempReturn_Text out
							,@ppExecution_Error = @TempExecution_Error out

							set @ErrorMsg = (case when @ErrorMsg = '' then @TempErrorMsg else @ErrorMsg + '; ' + @TempErrorMsg end)
							set @WarningMsg = (case when @WarningMsg = '' then @TempWarningMsg else @WarningMsg + '; ' + @TempWarningMsg end)

							if @TempIsError = 1
							begin
								set @IsError = @TempIsError
								set @IsActive = 0
							end

						end
						
						--insert into [POMS_DB].[dbo].[T_Order_Item_Scans] (BARCODE ,OI_ID ,ORDER_ID ,OIS_GUID ,ScanType_MTV_ID ,LOCATION_ID ,HUB_CODE ,DeviceCode_MTV_CODE ,ScanBy ,ScanTime ,MANIFEST_ID ,ManifestType_MTV_ID ,Lat
						--	,Lng ,ScanAnytime ,AutoScan ,IsRelabelRequired ,IsActive ,IsError ,ErrorMsg)
						--values (@BARCODE, @OI_ID, @ORDER_ID, @OIS_GUID, @ScanType_MTV_ID, @LOCATION_ID, @HUB_CODE, @DeviceCode_MTV_CODE, @ScanBy, @ScanTime, @MANIFEST_ID, @ManifestType_MTV_ID, @Lat,
						--	@Lng, @ScanAnytime, @AutoScan, @IsRelabelRequired, @IsActive, @IsError, @ErrorMsg)

						if @@TRANCOUNT > 0
						begin
							print 'commit'
							COMMIT; 
						end

					end try 
					begin catch
						set @pExecution_Error = (case when @pExecution_Error = '' then 'P_Process_Scan_Entries Loop 2; Barcode: ' +  @BARCODE + '; ErrorMsg: ' + ERROR_MESSAGE() else @pExecution_Error + '; P_Process_Scan_Entries Loop; Barcode: ' +  @BARCODE + '; ErrorMsg: ' + ERROR_MESSAGE() end)
						set @ErrorMsg = 'Internal Server Error Not Scanned Barcode: ' + @BARCODE
						set @IsError = 1
						set @IsActive = 0
						if @@TRANCOUNT > 0
						begin
							print 'rollback'
							ROLLBACK; 
						end
					end catch

				end

			end try
			begin catch
				set @pExecution_Error = (case when @pExecution_Error = '' then 'P_Process_Scan_Entries Loop; Barcode: ' +  @BARCODE + '; ErrorMsg: ' + ERROR_MESSAGE() else @pExecution_Error + '; P_Process_Scan_Entries Loop; Barcode: ' +  @BARCODE + '; ErrorMsg: ' + ERROR_MESSAGE() end)
				set @ErrorMsg = 'Internal Server Error Not Scanned Barcode: ' + @BARCODE
				set @IsError = 1
				set @IsActive = 0
			end catch

			insert into #ReturnTable (RequestID ,BARCODE ,ORDER_ID ,OIS_GUID ,IsError ,ErrorMsg ,Warning_Text)
			values (@RequestID, @BARCODE, @ORDER_ID, @OIS_GUID, @IsError, @ErrorMsg ,(case when @ErrorMsg = '' then @WarningMsg else '' end))

		end

	end

	select * from #ReturnTable

END
GO
