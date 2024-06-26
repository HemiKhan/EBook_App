USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Inbound_Scanning_Validation]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Inbound_Scanning_Validation]
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
	,@ppLat nvarchar(30)
	,@ppLng nvarchar(30)
	,@ppScanAnytime bit
	,@ppAutoScan bit
	,@ppIsRelabelRequired bit
	,@ppRoleID int
	,@ppIsGroupRoleID bit
	,@ppGetRecordType_MTV_ID int
	,@ppTRACKING_NO nvarchar(20)
	,@ppOrderStatus int
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
	
	Declare @OrigHubCode nvarchar(20) = '' 
	Declare @DestHubCode nvarchar(20) = ''
	Declare @LastLocationHub nvarchar(20) = ''
	Declare @IsAttached bit = 0
	Declare @AttachedToOther bit = 0
	Declare @ScanSpecialPermission bit = 0
	Declare @CanScanNonActiveOrder bit = 0

	if (@ppRoleID = 0)
	begin
		select @ppRoleID = urm.ROLE_ID, @ppIsGroupRoleID = IsGroupRoleID from [POMS_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @ppScanBy and urm.IsActive = 1
	end
	select @ScanSpecialPermission = [POMS_DB].[dbo].[F_Is_Has_Right_From_RoleID] (@ppRoleID ,@ppIsGroupRoleID ,100101 ,null)
	select @CanScanNonActiveOrder = [POMS_DB].[dbo].[F_Is_Has_Right_From_RoleID] (@ppRoleID ,@ppIsGroupRoleID ,100102 ,null)

	select @OrigHubCode = [OrgHubCode], @DestHubCode = [DestHubCode] from [PinnacleProd].[dbo].[Metropolitan$Manifest] m with (nolock) where [Entry No] = @ppMANIFEST_ID

	select @LastLocationHub = [Location] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) where [Barcode] = @ppBARCODE order by [Entry No] desc
		
	drop table if exists #ManifestList
	select sll.[Item Tracking No], sll.[ID], m.[OrgHubCode], m.[DestHubCode] into #ManifestList from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock)
	inner join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi with (nolock) on sll.[ID] = mgi.[Item ID] and mgi.[Is Stop Defined] = 1 and mgi.[Active Status] = 1
	inner join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg with (nolock) on mgi.[Manifest Group ID] = mg.ManifestGroupId and mg.[Active Status] = 1
	inner join [PinnacleProd].[dbo].[Metropolitan$Manifest] m with (nolock) on mg.[ManifestId] = m.[Entry No] and m.[Status] != 50000 and m.[Type] = 10000 and m.[Active Status] = 1 and m.[Entry No] = @ppMANIFEST_ID 

	set @IsAttached = (case when exists(select 1 from #ManifestList t where t.[Item Tracking No] = @ppBARCODE) then 1 else 0 end)

	set @AttachedToOther = (case when exists(select 1 from #ManifestList t where t.[OrgHubCode] = @OrigHubCode and t.[DestHubCode] = @DestHubCode and t.[Item Tracking No] = @ppBarcode) then 1 else 0 end)

	if (@ppHUB_CODE != @LastLocationHub and @ScanSpecialPermission = 1)
	begin
		set @ppWarningMsg = (case when @ppWarningMsg = '' then 'Scanned but Item Location is Not in Current Warehouse, Barcode: ' + @ppBARCODE else @ppErrorMsg + '; Scanned but Item Location is Not in Current Warehouse, Barcode: ' + @ppBARCODE end)
	end

	if (@ppHUB_CODE != @LastLocationHub and @ScanSpecialPermission = 0)
	begin
		set @ppErrorMsg = (case when @ppErrorMsg = '' then 'Item Location is Not in Current Warehouse, Barcode: ' + @ppBARCODE else @ppErrorMsg + '; Item Location is Not in Current Warehouse, Barcode: ' + @ppBARCODE end)
		set @ppIsError = 1
		set @ppIsActive = 0
	end
	else if (@AttachedToOther = 1 and @CanScanNonActiveOrder = 0 and @ppOrderStatus = 10000)
	begin
		set @ppErrorMsg = (case when @ppErrorMsg = '' then 'Attached to Another Manifest, Barcode: ' + @ppBARCODE else @ppErrorMsg + '; Attached to Another Manifest, Barcode: ' + @ppBARCODE end)
		set @ppIsError = 1
		set @ppIsActive = 0
	end
	else if (@IsAttached = 1)
	begin
		set @ppErrorMsg = (case when @ppErrorMsg = '' then 'Already Attached, Barcode: ' + @ppBARCODE else @ppErrorMsg + '; Already Attached, Barcode: ' + @ppBARCODE end)
		set @ppIsError = 1
		set @ppIsActive = 0
	end
	else if (@CanScanNonActiveOrder = 0 and @ppOrderStatus != 10000)
	begin
		set @ppErrorMsg = (case when @ppErrorMsg = '' then 'This Order has Already been Cancelled, Barcode: ' + @ppBARCODE else @ppErrorMsg + '; This Order has Already been Cancelled, Barcode: ' + @ppBARCODE end)
		set @ppIsError = 1
		set @ppIsActive = 0
	end

	if @ppErrorMsg = ''
	begin
		
		Declare @GroupItemID int = 0
		Declare @GroupID int = 0
		Declare @DTEmpty datetime = '1753-01-01 00:00:00.000'
		Declare @BarcodeScanEntryNo int = 0

		if (@ppIsActive = 1)
		begin

			select top 1 @GroupID = [ManifestGroupId] from [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg with (nolock) where [ManifestId] = @ppMANIFEST_ID and [GroupNo] = 'G1'
			set @GroupID = isnull(@GroupID,0)

			if (@GroupID = 0)
			begin
				insert into [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] ([ManifestId], [ProjectId], [StopNo], [GroupNo], [PickupOrDelivery], [ApproxStopArrivalTime]
					, [ApproxStopDepartureTime], [ActualStopArrivalTime], [ActualStopDepartureTime], [City], [State], [Zip Code], [Address], [RunDay], [TimeFrame]
					, [Estimated Miles], [Active Status], [Added By], [Added On], [Modified By], [Modified On], [Stop Modified On])
				values (@ppMANIFEST_ID, '', 1, 'G1', 2, @DTEmpty, @DTEmpty, @DTEmpty, @DTEmpty, '', '', '', '', 0, '', '', 1, @ppScanByID, getutcdate(), 0, @DTEmpty, '')
				set @GroupID = scope_identity()
			end

			insert into [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] ([Item ID], [Manifest Group ID], [Item Status], [Item Acceptance], [Last Scanned]
			, [Last Scanned Item ID], [Is Stop Defined], [Added By], [Added On], [Modified By], [Modified On], [Pickup OR Delivery], [Active Status])
			values (@ppOI_ID, @GroupID, 0, 0, @DTEmpty, 0, 1, @ppScanByID, getutcdate(), 0, @DTEmpty, 2, 1)
			set @GroupItemID = scope_identity()

			insert into [PinnacleProd].[dbo].[Metropolitan$ManifestSalesOrderActivity] ([ManifestGroupId], [ManifestSalesOrderId], [StopNo], [IsStopDefined]
			, [ManifestSalesOrderStatus], [Date Added], [Added By], [ItemID], [ManifestGroupItemId], [Active Status], [ItemAction])
			values (@GroupID, @ppORDER_ID, 0, 0, 0, getutcdate(), @ppScanByID, @ppOI_ID, @GroupItemID, 0, 3)

			Declare @OtherManifestsList table (ManifestID int, [ManifestGroupId] int)
		
			insert into @OtherManifestsList (ManifestID, [ManifestGroupId])
			select m.[Entry No],mg.[ManifestGroupId] from [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi with (nolock)
			inner join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg with (nolock) on mg.[ManifestGroupId] = mgi.[Manifest Group ID]
			inner join [PinnacleProd].[dbo].[Metropolitan$Manifest] m with (nolock) on m.[Entry No] = mg.[ManifestId] and m.[Status] in (20000,30000) 
			and	m.[OrgHubCode] = @OrigHubCode and m.[DestHubCode] = @DestHubCode and m.[Entry No] != @ppMANIFEST_ID
			where mgi.[Active Status] = 1 and mgi.[Item ID] = @ppOI_ID
		
			if exists(select * from @OtherManifestsList)
			begin
				update mgi
				set mgi.[Active Status] = 0
				, mgi.[Modified By] = @ppScanByID
				, mgi.[Is Stop Defined] = 0
				, mgi.[Modified On] = getutcdate()
				from [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi
				inner join @OtherManifestsList oml on oml.[ManifestGroupId] = mgi.[Manifest Group ID]
			end

			--if exists(select [IsGoogleXMLRequired] from [PinnacleProd].[dbo].[DispatchRoute] dr with (nolock) where dr.[ManifestId] = @ppMANIFEST_ID)
			--begin
			--	update dr
			--	set	dr.[IsGoogleXMLRequired] = 1
			--	from [PinnacleProd].[dbo].[DispatchRoute] dr
			--	where [ManifestId] = @ppMANIFEST_ID
			--end

			exec @BarcodeScanEntryNo = [PinnacleProd].[dbo].[Metro_InsertScans] @ppBARCODE, @ppORDER_ID, @ppScanType_MTV_ID, @ppLOCATION_ID, @ppHUB_CODE, @ppScanByID, @ppMANIFEST_ID, @ppOI_ID, @ppScanAnytime, @ppDeviceCode_MTV_CODE

			if (@BarcodeScanEntryNo > 0)
			begin
				set @ppReturn_Code = 1
				update [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] set [WarehouseStatus] = 30000 where [ID] = @ppOI_ID
			end

		end

	end

END
GO
