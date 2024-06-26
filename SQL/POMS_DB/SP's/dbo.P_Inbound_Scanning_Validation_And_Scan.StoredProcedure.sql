USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Inbound_Scanning_Validation_And_Scan]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Inbound_Scanning_Validation_And_Scan]
	@ppOIS_ID int 
	,@ppOI_ID int
	,@ppORDER_ID int
	,@ppBARCODE nvarchar(20)
	,@ppOIS_GUID nvarchar(36)
	,@ppRelabelCount int
	,@ppScanType_MTV_ID int
	,@ppLOCATION_ID nvarchar(20)
	,@ppHUB_CODE nvarchar(20)
	,@ppDeviceCode_MTV_CODE nvarchar(20)
	,@ppScanTime datetime
	,@ppScanBy nvarchar(150)
	,@ppScanByID int
	,@ppMANIFEST_ID int
	,@ppManifestType_MTV_ID int
	,@ppManifestSubType_MTV_ID int
	,@ppLat nvarchar(30)
	,@ppLng nvarchar(30)
	,@ppScanAnytime bit
	,@ppAutoScan bit
	,@ppIsRelabelRequired bit
	,@ppRoleID int
	,@ppIsGroupRoleID bit
	,@ppGetRecordType_MTV_ID int
	,@ppTRACKING_NO nvarchar(20)
	,@ppIsValidate bit
	,@ppIsUpdate bit
	,@ppIsActive bit
	,@ppIsError bit output
	,@ppErrorMsg nvarchar(1000) output
	,@ppWarningMsg nvarchar(1000) output
	,@ppReturn_Code bit output
	,@ppReturn_Text nvarchar(1000) output
	,@ppExecution_Error nvarchar(max) output

AS
BEGIN
	
	set @ppIsError = isnull(@ppIsError,0)
	set @ppErrorMsg = isnull(@ppErrorMsg,'')
	set @ppWarningMsg = isnull(@ppWarningMsg,'')
	set @ppReturn_Code = isnull(@ppReturn_Code,0)
	set @ppReturn_Text = isnull(@ppReturn_Text,'')
	set @ppExecution_Error = isnull(@ppExecution_Error,'')

	Declare @ShipFromHub nvarchar(20) = ''
	Declare @ShipToHub nvarchar(20) = ''
	Declare @OrderStatus int = 0
	Declare @CustomerNo nvarchar(20) = ''

	Declare @ORDER_NO nvarchar(20) = '000000'
	Declare @PickupTriggers bit = 0
	Declare @LastScannedLocation nvarchar(20) = ''
	Declare @InboundLocationCount int = 0
	Declare @IsOverage bit = 0
	Declare @TempItemID int = 0
	Declare @AlreadyScannedLocation nvarchar(20) = ''
	Declare @BarcodeScanEntryNo int = 0 
	Declare @PickupScheduleDate datetime = null
	Declare @PickupCompleteDate datetime = null
	Declare @IsAuto bit = 0
	Declare @TempIsError bit = 0
	Declare @TempErrorMsg nvarchar(1000) = ''
	Declare @TempWarningMsg nvarchar(1000) = ''
	Declare @TempReturn_Code bit = 0
	Declare @TempReturn_Text nvarchar(1000) = ''
	Declare @TempExecution_Error nvarchar(max) = ''
	Declare @TotalOrderItems int = 0
	Declare @TotalInbound int = 0
	Declare @TotalItemScanned int = 0
	Declare @RequestedPkpTimeFrameID int = 0
	Declare @RecsUpdated int = 0

	Declare @BarcodeScanIDReturnTable table (ScanID int)

	if (@ppORDER_ID > 0)
	begin
		set @ORDER_NO = cast(@ppORDER_ID as nvarchar(20))
		
		select @OrderStatus = sh.[Order Status], @CustomerNo = sh.[Bill-to Customer No_] 
		from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) where sh.No_ = @ORDER_NO
		set @OrderStatus = isnull(@OrderStatus,0)
		set @CustomerNo = isnull(@CustomerNo ,'')

		if (@OrderStatus > 0)
		begin
			select @ShipFromHub = isnull(od.OrigHub,''), @ShipToHub = isnull(od.DestHub,'')
			from [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) where od.OrderNo = @ORDER_NO

			select @PickupCompleteDate = sl.[Pickup Completed Date], @PickupScheduleDate = sl.[Promised Pickup Date] 
			from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) where sl.[Document No] = @ORDER_NO
		end
	end
	
	set @PickupTriggers = case when @ppScanAnytime = 0 and @ppScanType_MTV_ID = 40000 then 0 else 1 end

	if(@ppManifestType_MTV_ID in (40000,30000))
	begin
		if (@ppManifestType_MTV_ID = 30000)
		begin
			set @IsOverage = (case when exists(select msod.[BarCode] from [PPlus_DB].[dbo].[T_Manifest] m with (nolock)			inner join [PPlus_DB].[dbo].[T_Manifest_Stop] ms with (nolock) on m.MIN_ID = ms.MIN_ID			inner join [PPlus_DB].[dbo].[T_Manifest_Stop_Order] mso with (nolock) on ms.MS_ID = mso.MS_ID			inner join [PPlus_DB].[dbo].[T_Manifest_Stop_Order_Detail] msod with (nolock) on mso.MSO_ID = msod.MSO_ID			where m.MIN_ID = @ppMANIFEST_ID and msod.[BarCode] = @ppBARCODE) then 0 else 1 end)
		end
		else if (@ppManifestType_MTV_ID = 40000)
		--if (@ppManifestType_MTV_ID = 40000)
		begin
			set @IsOverage = (case when exists(select msi.[MpS_ID] from [PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] msi with (nolock)
				inner join [PPlus_DB].[dbo].[T_ManifestPU_Stop] ms with (nolock) on ms.[MpS_ID] = msi.[MpS_ID] 
				where ms.[MIN_ID] = @ppMANIFEST_ID and msi.Barcode = @ppBARCODE) then 0 else 1 end)
		end

		if(@IsOverage = 1)
		begin
			set @TempErrorMsg = 'The Item ' + @ppBARCODE + ' is not Included in the Manifest ' + cast(@ppMANIFEST_ID as nvarchar(20)) + ', so will be added as Overage'
			set @ppWarningMsg = (case when @ppWarningMsg = '' then @TempErrorMsg else @ppWarningMsg + @TempErrorMsg end)
		end

		select @AlreadyScannedLocation = bsh.[Location ID] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) 
		where bsh.[Barcode] = @ppBARCODE and bsh.[Scan Type] = @ppScanType_MTV_ID and bsh.[ManifestID] = @ppMANIFEST_ID and bsh.ManifestSource = @ppManifestType_MTV_ID
		set @AlreadyScannedLocation = isnull(@AlreadyScannedLocation,'')

		if @AlreadyScannedLocation != '' and @AlreadyScannedLocation = @ppLOCATION_ID
		begin
			set @TempErrorMsg = 'Barcode ' + @ppBARCODE + ' Already Scanned'
			set @ppErrorMsg = (case when @ppErrorMsg = '' then @TempErrorMsg else @ppErrorMsg + @TempErrorMsg end)
			set @ppIsError = 1
			set @ppIsActive = 0
		end	
		else if @AlreadyScannedLocation != ''
		begin
			set @TempErrorMsg = 'Barcode ' + @ppBARCODE + ' Already Scanned on Location ' + @AlreadyScannedLocation + ' with this Manifest'
			set @ppErrorMsg = (case when @ppErrorMsg = '' then @TempErrorMsg else @ppErrorMsg + @TempErrorMsg end)
			set @ppIsError = 1
			set @ppIsActive = 0
		end	
		else
		begin
			insert into @BarcodeScanIDReturnTable (ScanID)
			exec [PinnacleProd].[dbo].[Metro_InsertScans] @ppBARCODE, @ORDER_NO,@ppScanType_MTV_ID,@ppLOCATION_ID,@ppHUB_CODE,@ppScanByID,@ppMANIFEST_ID,@ppOI_ID,@ppScanTime,@ppDeviceCode_MTV_CODE,@ppScanAnytime,20000,@ppIsActive,@ppAutoScan,@ppLat,@ppLng,'',@ppManifestType_MTV_ID,@ppOIS_GUID
			select @BarcodeScanEntryNo = ScanID from @BarcodeScanIDReturnTable
			set @BarcodeScanEntryNo = isnull(@BarcodeScanEntryNo,0)

			if (@BarcodeScanEntryNo > 0)
			begin
				set @ppReturn_Code = 1
			end
		end

		if(@ppReturn_Code = 1)
		begin
			update [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] 
				set	[WarehouseStatus] = 10010
				, [WarehouseLocation] = 10000
				, [WarehouseLocationCode] = @ppLOCATION_ID
				, [Item Pickup Status] = 1 
				, [ModifiedBy] = @ppScanByID
				, [ModifedOn] = @ppScanTime
			where [Item Tracking No] = @ppBARCODE

			update [PinnacleProd].[dbo].[Metropolitan$Sales Header]
				set	[Warehouse Status] = 10010
				, [WarehouseLocation] = 10000
				, [WarehouseLocationCode] = @ppLOCATION_ID
			where [No_] = @ORDER_NO
		end

		select @TempItemID = sum((case when @ppOI_ID = 0 then 1 else 0 end))
		,@TotalOrderItems = count(sll.ID)
		,@TotalInbound = sum((case when sll.[Item Pickup Status] = 1 then 1 else 0 end))
		from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock) 
		where sll.[Sales Order No] = @ORDER_NO and sll.[Document Type] = 1 and sll.[Item Type] = 1
		
		if(@ppScanAnytime = 0 and @TempItemID = 0)
		begin
			exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 95, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
		end
		
		if (year(@PickupCompleteDate) < 2000)
		begin
			select @TotalItemScanned = count(distinct bsh.[Barcode]) from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock)
			where bsh.[Order No] = @ORDER_NO and bsh.[Location] = @ppHUB_CODE and bsh.[ManifestSource] = @ppManifestType_MTV_ID
		end

		if(@TempItemID = 0)
		begin
			if(@TotalOrderItems = @TotalItemScanned and year(@PickupCompleteDate) < 2000)
			begin
				if year(@PickupScheduleDate) < 2000
				begin
					set @IsAuto = (case when [POMS_DB].[dbo].[F_CustomizedValue] (@CustomerNo, 'AUTO_COMPLETE_PICKUP_ON_FRBM') = 'YES' then 1 else 0 end)
				end

				if (@IsAuto = 1 or year(@PickupScheduleDate) > 2000)
				begin
					begin try
					
						set @RequestedPkpTimeFrameID = (case when year(@PickupScheduleDate) > 2000 or @IsAuto = 0 
							then (select [Requested Pkp Timeframe ID] from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) where sl.[Document No] = @ORDER_NO)
							else case
								when [PinnacleProd].[dbo].[fn_IsWeekOfEnabledDay](@ORDER_NO, @ppScanTime, 1) = 1 then 0
								when [PinnacleProd].[dbo].[fn_HasNoRoute](@ORDER_NO, 1) = 1 then 0
								else [PinnacleProd].[dbo].[fn_DefaultTimeframeWindowID](@ORDER_NO, 1)
							end
						end)

						set @RequestedPkpTimeFrameID = isnull(@RequestedPkpTimeFrameID,0)
		
						update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup]
							set	[Pickup Completed Date] = @ppScanAnytime
							, [Pickup Completed] = 1
							, [Pinnacle Pickup Completed] = 1
							, [Promised Pickup Date] = (case when year(@PickupScheduleDate) < 2000 then [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (@ppScanAnytime, null, @ppHUB_CODE, null) else [Promised Pickup Date] end)
							, [Requested Pkp Timeframe ID] = @RequestedPkpTimeFrameID
						where [Document No] = @ORDER_NO
						and	year([Pickup Completed Date]) < 2000
		
						set @RecsUpdated = @@rowcount
		
						if (@RecsUpdated > 0 and year(@PickupScheduleDate) < 2000 and @IsAuto = 1)
						begin
							exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 10, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
						end

						if (@RecsUpdated > 0)
						begin
							exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 18, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
						end

					end try
					begin catch
						
					end catch

				end

			end
			else if (@TotalOrderItems = @TotalInbound and year(@PickupScheduleDate) > 2000)
			begin
				exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 18, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
			end
		end

		if (@TotalItemScanned = 0)
		begin
			select @TotalItemScanned = count(distinct bsh.[Barcode]) from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock)
			where bsh.[Order No] = @ORDER_NO and bsh.[Location] = @ppHUB_CODE and bsh.[ManifestSource] = @ppManifestType_MTV_ID
		end

		if @TotalOrderItems = @TotalItemScanned
		begin
			if not exists(select eml.ID from [PinnacleProd].[dbo].[Metropolitan$Event Master Log] eml with (nolock) where eml.[EventID] = 23 and eml.[Order Number] = @ORDER_NO and Warehouse = @ppHUB_CODE)
			begin
				exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 23, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
	
				-- Trigger event - Reached Delivery Hub
				if (@ShipToHub = @ppHUB_CODE and @TempItemID = 0)
				begin
					exec [PinnacleProd].[dbo].Metro_InsertUpdateOrderInfoEventTriggered 107, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
				end
			end
		end

		return
	end
	else
	begin
		select top 1 @LastScannedLocation = [Location] from	[PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) 
		where [Order No] = @ORDER_NO and [Scan Type] = 20000 order by [Scan Time] desc
		
		select @InboundLocationCount = count(bsh.[Entry No]) from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) 
		where [Barcode] = @ppBARCODE and [Scan Type] = 20000 and upper([Location]) = @ppHUB_CODE

		if(@ppScanType_MTV_ID = 30000 and @ppScanAnytime = 0)
		begin
			set @TempIsError = 0
			set @TempErrorMsg = ''
			set @TempReturn_Code = 0
			set @TempReturn_Text = ''
			set @TempExecution_Error = ''

			exec [POMS_DB].[dbo].[P_Inbound_Scanning_Validation] @ppOIS_ID = @ppOIS_ID ,@ppOI_ID = @ppOI_ID ,@ppORDER_ID = @ppORDER_ID ,@ppBARCODE = @ppBARCODE ,@ppOIS_GUID = @ppOIS_GUID ,@ppRelabelCount = @ppRelabelCount
			,@ppScanType_MTV_ID = @ppScanType_MTV_ID ,@ppLOCATION_ID = @ppLOCATION_ID ,@ppHUB_CODE = @ppHUB_CODE ,@ppDeviceCode_MTV_CODE = @ppDeviceCode_MTV_CODE ,@ppScanTime = @ppScanTime ,@ppScanBy = @ppScanBy ,@ppScanByID = @ppScanByID
			,@ppMANIFEST_ID = @ppMANIFEST_ID ,@ppManifestType_MTV_ID = @ppManifestType_MTV_ID ,@ppLat = @ppLat ,@ppLng = @ppLng ,@ppScanAnytime = @ppScanAnytime ,@ppAutoScan = @ppAutoScan ,@ppIsRelabelRequired = @ppIsRelabelRequired 
			,@ppRoleID = @ppRoleID ,@ppIsGroupRoleID = @ppIsGroupRoleID ,@ppGetRecordType_MTV_ID = @ppGetRecordType_MTV_ID ,@ppTRACKING_NO = @ppTRACKING_NO ,@ppOrderStatus = @OrderStatus ,@ppIsActive = @ppIsActive 
			,@ppIsError = @TempIsError out ,@ppErrorMsg = @TempErrorMsg out ,@ppWarningMsg = @TempWarningMsg out ,@ppReturn_Code = @TempReturn_Code out ,@ppReturn_Text = @TempReturn_Text out ,@ppExecution_Error = @TempExecution_Error out

			set @ppIsError = @TempIsError
			set @ppErrorMsg = @TempErrorMsg
			set @ppWarningMsg = @TempWarningMsg
			set @ppReturn_Code = @TempReturn_Code
			set @ppReturn_Text = @TempReturn_Text
			set @ppExecution_Error = @TempExecution_Error

		end
		else
		begin
			Declare @IsValidItem bit = 1
			Declare @IsExists bit = 0
			set @TempItemID = 0
			
			set @IsExists = (case when exists(select top 1 sll.ID from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock)
				inner join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi with (nolock) on mgi.[Item ID] = sll.[ID] and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
				inner join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg with (nolock) on mg.[ManifestGroupId] = mgi.[Manifest Group ID] and mg.[ManifestId] = @ppMANIFEST_ID
				where sll.[Item Tracking No] = @ppBARCODE and sll.[Item Type] = 1 and sll.[Document Type] = 1) then 1 else 0 end)

			if(@ppScanAnytime = 0 and @ppScanType_MTV_ID = 20000)
			begin
				if (@ppOI_ID = 0)
				begin
					select @TempItemID = sum((case when @ppOI_ID = 0 then 1 else 0 end))
					from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock) 
					where sll.[Sales Order No] = @ORDER_NO and sll.[Document Type] = 1 and sll.[Item Type] = 1
					
					if(@TempItemID != 0)
					begin
						set @TempErrorMsg = 'The Item ' + @ppBARCODE + ' is not Included in the Manifest ' + cast(@ppMANIFEST_ID as nvarchar(20)) + ', so will be added as Overage'
						set @ppWarningMsg = (case when @ppWarningMsg = '' then @TempErrorMsg else @ppWarningMsg + @TempErrorMsg end)
					end
				end
				else if (@IsExists = 0 and @ppMANIFEST_ID > 0)
				begin
					set @TempErrorMsg = 'The Item ' + @ppBARCODE + ' is not Included in the Manifest ' + cast(@ppMANIFEST_ID as nvarchar(20)) + ', so will be added as Overage'
					set @ppWarningMsg = (case when @ppWarningMsg = '' then @TempErrorMsg else @ppWarningMsg + @TempErrorMsg end)
				end
			end
	
			set @IsValidItem = (case when @TempItemID != 0 then 1 
				when @ppOI_ID = 0 and @TempItemID = 0 and @ppScanAnytime = 0 and @ppScanType_MTV_ID = 20000 then 0
				when @ppOI_ID = 0 then 0 else 1 end)
			
			if (@IsValidItem = 0)
			begin
				set @TempErrorMsg = 'Invalid Barcode ' + @ppBARCODE
				set @ppErrorMsg = (case when @ppErrorMsg = '' then @TempErrorMsg else @ppErrorMsg + @TempErrorMsg end)
				set @ppIsError = 1
				set @ppIsActive = 0
			end
			else if (exists(select top 1 bsh.[Entry No] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) where bsh.[Barcode] = @ppBARCODE and bsh.[Scan Type] = @ppScanType_MTV_ID and bsh.[ManifestID] = @ppMANIFEST_ID and bsh.ManifestSource = @ppManifestType_MTV_ID) and @ppScanAnytime = 0 and @ppScanType_MTV_ID != 40000)
			begin
				set @TempErrorMsg = 'Already Scanned ' + @ppBARCODE
				set @ppErrorMsg = (case when @ppErrorMsg = '' then @TempErrorMsg else @ppErrorMsg + @TempErrorMsg end)
				set @ppIsError = 1
				set @ppIsActive = 0
			end		
			else if(@ppScanAnytime = 0 and @ppScanType_MTV_ID = 40000 and (upper(@LastScannedLocation) != @ppLOCATION_ID or @InboundLocationCount < 1))
			begin
				set @TempErrorMsg = 'Please do Inbound of Items at Current Location'
				set @ppErrorMsg = (case when @ppErrorMsg = '' then @TempErrorMsg else @ppErrorMsg + @TempErrorMsg end)
				set @ppIsError = 1
				set @ppIsActive = 0
			end
			else if (@IsExists = 0 and @ppScanAnytime = 0 and @ppMANIFEST_ID > 0 and @ppScanType_MTV_ID != 20000)
			begin
				set @TempErrorMsg = 'Invalid Barcode ' + @ppBARCODE + ' for this Manifest'
				set @ppErrorMsg = (case when @ppErrorMsg = '' then @TempErrorMsg else @ppErrorMsg + @TempErrorMsg end)
				set @ppIsError = 1
				set @ppIsActive = 0
			end
			else
			begin
				Declare @ManifestScheduleType int = 0
				select top 1 @ManifestScheduleType = mgi.[Pickup OR Delivery] from [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi with (nolock)
				inner join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg with (nolock) on mg.[ManifestGroupId] = mgi.[Manifest Group ID] and mg.[ManifestId] = @ppMANIFEST_ID
				where mgi.[Item Status] = @ppOI_ID

				insert into @BarcodeScanIDReturnTable (ScanID)
				exec [PinnacleProd].[dbo].[Metro_InsertScans] @ppBARCODE,@ORDER_NO,@ppScanType_MTV_ID,@ppLOCATION_ID,@ppHUB_CODE,@ppScanByID,@ppMANIFEST_ID,@ppOI_ID,@ppScanTime,@ppDeviceCode_MTV_CODE,@ppScanAnytime,20000,@ppIsActive,@ppAutoScan,@ppLat,@ppLng,'',@ppManifestType_MTV_ID,@ppOIS_GUID
				select @BarcodeScanEntryNo = ScanID from @BarcodeScanIDReturnTable
				set @BarcodeScanEntryNo = isnull(@BarcodeScanEntryNo,0)
				
				if @BarcodeScanEntryNo > 0
				begin
					set @ppReturn_Code = 1
				end

				Declare @WarehouseStatus int = 10010
				Declare @WarehouseLocation int = 10000

				IF(@ppScanAnytime = 1 and @ppScanType_MTV_ID = 30000)
				BEGIN
					set @WarehouseStatus = 30000
					set @WarehouseLocation = 40000
				END

				if (@ManifestScheduleType in (1,2) OR (@ppScanAnytime = 1 AND @ppScanType_MTV_ID = 30000))
				begin
					update [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] 
						set	[WarehouseStatus] = @WarehouseStatus --10010 -- In-Warehouse
						, [WarehouseLocation] = @WarehouseLocation --10000 -- Inbound Staging Area
						, [WarehouseLocationCode] = case when @ppScanType_MTV_ID not in (50000,100000) then @ppLOCATION_ID else [WarehouseLocationCode] end
						, [Item Pickup Status] = case when @ManifestScheduleType = 1 then 1 else [Item Pickup Status] end
						, [Item Delivery Status] = case when @ManifestScheduleType = 2 then 0 else [Item Delivery Status] end
						, [ModifiedBy] = @ppScanByID
						, [ModifedOn] = @ppScanTime
					where [Item Tracking No] = @ppBARCODE and [Document Type] = 1 and [Register Type] = 0 and [Item Type] = 1
				end

				if not ((@ManifestScheduleType in (1,2) OR (@ppScanAnytime = 1 AND @ppScanType_MTV_ID = 30000)) and @ppScanType_MTV_ID in (50000,100000)) and (@ppScanAnytime = 0 and @ppScanType_MTV_ID = 40000)
				begin
					update [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] 
						set	[WarehouseLocation] = 30000
						, [WarehouseLocationCode] = @ppLOCATION_ID
						, [WarehouseStatus] = @WarehouseStatus --10010
					where [Item Tracking No] = @ppBARCODE
				end
		
				update [PinnacleProd].[dbo].[Metropolitan$Sales Header] 
					set [Warehouse Status] = @WarehouseStatus --10010 -- In-Warehouse
					, [WarehouseLocation] = case when @ppScanAnytime = 0 and @ppScanType_MTV_ID = 40000 then 30000
						when @ppScanAnytime = 1 and @ppScanType_MTV_ID = 30000 then 40000
						else 10000  -- Inbound Staging Area
						end
					, [WarehouseLocationCode] = case when @ppScanType_MTV_ID not in (50000, 100000) then @ppLOCATION_ID else [WarehouseLocationCode] end
				where [No_] = @ORDER_NO and [Document Type] = 1

				update [PinnacleProd].[dbo].[Metropolitan$Manifest] 
					set	[Warehouse Status] = @WarehouseStatus --10010 -- In-Warehouse
				where [Entry No] = @ppMANIFEST_ID

				if (@ppScanAnytime = 0 and @ppScanType_MTV_ID = 40000)
				begin
					exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 94, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
				end
				else if(@ppScanAnytime = 0 and @TempItemID = 0)
				begin
					exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 95, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
				end
				else if(@ppScanAnytime = 1 and @TempItemID = 0)
				begin
					Declare @EventCode int = 94
					set @eventCode = case
						when @ppScanType_MTV_ID = 20000 then 95
						when @ppScanType_MTV_ID = 30000 then 93
						else 94 end
					exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] @EventCode, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
				end

				select @TempItemID = sum((case when @ppOI_ID = 0 then 1 else 0 end))
					,@TotalOrderItems = count(sll.ID)
					,@TotalInbound = sum((case when sll.[Item Pickup Status] = 1 then 1 else 0 end))
				from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock) 
				where sll.[Sales Order No] = @ORDER_NO and sll.[Document Type] = 1 and sll.[Item Type] = 1
				
				select @TotalItemScanned = count(distinct bsh.[Barcode]) from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock)
				where bsh.[Order No] = @ORDER_NO and bsh.[Location] = @ppHUB_CODE and bsh.ManifestSource = @ppManifestType_MTV_ID

				if (@PickupTriggers = 1 and @TempItemID = 0 and @TotalOrderItems = @TotalItemScanned and year(@PickupCompleteDate) < 2000)--(@TotalOrderItems = @TotalItemScanned and year(@PickupCompleteDate) < 2000)
				begin
					if year(@PickupScheduleDate) < 2000
					begin
						set @IsAuto = (case when [POMS_DB].[dbo].[F_CustomizedValue] (@CustomerNo, 'AUTO_COMPLETE_PICKUP_ON_FRBM') = 'YES' then 1 else 0 end)
					end

					if (@IsAuto = 1 or year(@PickupScheduleDate) > 2000)
					begin
						begin try
					
							set @RequestedPkpTimeFrameID = (case when year(@PickupScheduleDate) > 2000 or @IsAuto = 0 
								then (select [Requested Pkp Timeframe ID] from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) where sl.[Document No] = @ORDER_NO)
								else case
									when [PinnacleProd].[dbo].[fn_IsWeekOfEnabledDay](@ORDER_NO, @ppScanTime, 1) = 1 then 0
									when [PinnacleProd].[dbo].[fn_HasNoRoute](@ORDER_NO, 1) = 1 then 0
									else [PinnacleProd].[dbo].[fn_DefaultTimeframeWindowID](@ORDER_NO, 1)
								end
							end)

							set @RequestedPkpTimeFrameID = isnull(@RequestedPkpTimeFrameID,0)
		
							update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup]
								set	[Pickup Completed Date] = @ppScanAnytime
								, [Pickup Completed] = 1
								, [Pinnacle Pickup Completed] = 1
								, [Promised Pickup Date] = (case when year(@PickupScheduleDate) < 2000 then [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (@ppScanAnytime, null, @ppHUB_CODE, null) else [Promised Pickup Date] end)
								, [Requested Pkp Timeframe ID] = @RequestedPkpTimeFrameID
							where [Document No] = @ORDER_NO
							and	year([Pickup Completed Date]) < 2000
		
							set @RecsUpdated = @@rowcount
		
							if (@RecsUpdated > 0 and year(@PickupScheduleDate) < 2000 and @IsAuto = 1)
							begin
								exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 10, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
							end

							exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 18, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''

						end try
						begin catch
							
						end catch

					end

				end
				else if (@TotalOrderItems = @TotalInbound and year(@PickupScheduleDate) > 2000)
				begin
					exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 18, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
				end

				if (@PickupTriggers = 1 and @TotalOrderItems = @TotalItemScanned and not exists (select eml.ID from [PinnacleProd].[dbo].[Metropolitan$Event Master Log] eml with (nolock) where eml.[EventID] = 23 and eml.[Order Number] = @ORDER_NO and Warehouse = @ppHUB_CODE))
				begin
					exec [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 23, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
					
					if (@ShipToHub = @ppHUB_CODE and @TempItemID = 0)
					begin
						exec [PinnacleProd].[dbo].Metro_InsertUpdateOrderInfoEventTriggered 107, 0, 0, 0, @ppScanByID, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @ORDER_NO, @CustomerNo, '', '', ''
					end
				end
			end
		end
		
	end

END
GO
