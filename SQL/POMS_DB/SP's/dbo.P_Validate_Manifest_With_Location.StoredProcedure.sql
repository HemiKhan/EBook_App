USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Validate_Manifest_With_Location]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Created by	: Abdullah
-- Date Created	: 09-22-2023
--
-- exec dbo.[P_Validate_Manifest_With_Location] 'in-caev', 113101, 115037, 0, '30000', 'ABDULLAH.ARSHAD', 115101
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[P_Validate_Manifest_With_Location]
(
	@LocationID nvarchar(20)
	,@ScanType int
	,@ManifestID int
	,@Type int --(0. Origin, 1. Destination)
	,@Status nvarchar(50) --'50000,30000' comma-delimited list of manifest status IDs
	,@UserName nvarchar(150)
	,@ManifestSource int --10000 - LH, 30000 - FM, 40000 - PU
)

AS

BEGIN
	
	Declare @ScanType_MTV_ID int = @ScanType
	Declare @ManifestType_MTV_ID int = @ManifestSource

	--set @ScanType = [POMS_DB].[dbo].[F_Get_PinnacleScanType_From_NewScanType] (@ScanType_MTV_ID)
	--select @ManifestSource = PinnacleManifestType from [POMS_DB].[dbo].[F_Get_PinnacleManifestType_From_NewManifestType] (@ManifestType_MTV_ID)

	set @LocationID = upper(@LocationID)
	set @UserName = upper(@UserName)
	Declare @HubCode nvarchar(20) = ''
	Declare @HubName nvarchar(50) = ''
	Declare @Ret_ReturnCode int = 0
	Declare @Ret_ReturnText nvarchar(250) = ''
	Declare @Ret_TotalCount int = 0 
	Declare @Ret_IsNotInManifest bit = 0

	--Declare @UserID int = 0
	--Declare @Partner bit = 0
	--select @UserID = [Web UserID] , @Partner = [Partner] from [PinnacleProd].[dbo].[Metropolitan$Web User Login] with (nolock) where Username = @UserName

	--select @UserID = isnull(@UserID,0) ,@Partner = isnull(@Partner,0)

	--if @UserID = 0
	--begin
	--	set @Ret_ReturnText = 'Invalid Username'
	--end

	if @Ret_ReturnText = ''
	begin
		select top 1 @HubCode = twh.Code, @HubName = twh.[Wharehouse Name] from [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] wle with (nolock)
		inner join [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] twh with (nolock) on wle.[Warehouse ID] = twh.Code where upper(wle.[Code]) = @LocationID
		
		if (isnull(@HubCode,'') = '')
		begin
			select top 1 @HubCode = twh.Code, @HubName = twh.[Wharehouse Name], @LocationID = upper(wle.[Code]) from [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] wle with (nolock)
			inner join [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] twh with (nolock) on wle.[Warehouse ID] = twh.Code where upper(wle.[Barcode]) = @LocationID
		end
	end

	if isnull(@HubCode,'') = ''
	begin
		set @Ret_ReturnText = 'Invalid Location ID'
	end

	set @ManifestSource = (case when isnull(@ManifestSource,0) = 0 then 10000 else @ManifestSource end)

	Declare @TempReturnTable table
	([ManifestID] int
	,[ManifestDate] date
	,[StartDate] date
	,[EndDate] date
	,[Status] nvarchar(50)
	,[StatusID] int
	,[OrderCount] int
	,[ItemCount] int
	,[Driver] nvarchar(50)
	,[DriverID] int
	,[Truck] nvarchar(50)
	,[TruckID] int
	,[WarehouseName] nvarchar(50)
	,[HubCode] nvarchar(20))

	insert into @TempReturnTable
	exec [POMS_DB].[dbo].[P_Get_Inbound_Manifest_List] @ManifestType_MTV_ID, @ScanType_MTV_ID, @LocationID, @HubCode, @UserName, -14400000, 13, 1, 1, @TotalCount = @Ret_TotalCount out, @ReturnCode = @Ret_ReturnCode out, @ReturnText = @Ret_ReturnText out, @IsNotInManifest = @Ret_IsNotInManifest out, @ManifestIDFilter = @ManifestID

	--drop table if exists #ManifestAssignToUserTable
	--Create table #ManifestAssignToUserTable (ReturnCode int ,ReturnText nvarchar(250))
	--insert into #ManifestAssignToUserTable
	--select ReturnCode, ReturnText from [POMS_DB].[dbo].[F_Is_Manifest_Assigned_To_User_List] (@ManifestID, @UserID)

	--if exists(select * from #ManifestAssignToUserTable where ReturnCode = 0) and @Ret_ReturnText = ''
	--begin
	--	select @Ret_ReturnCode = ReturnCode ,@Ret_ReturnText = ReturnText from #ManifestAssignToUserTable
	--end

	--drop table if exists #ManifestValidLocationTable
	--Create table #ManifestValidLocationTable (ReturnCode int ,ReturnText nvarchar(250))
	--if @Ret_ReturnText = '' and not exists(select * from #ManifestAssignToUserTable where ReturnCode = 1)
	--begin
	--	insert into #ManifestValidLocationTable
	--	select ReturnCode, ReturnText from [POMS_DB].[dbo].[F_Is_Manifest_Valid_For_Location_List] (@LocationID,@ManifestID,@Type,@Status,@ManifestSource,@HubCode)
	--end

	--if exists(select ReturnCode from #ManifestValidLocationTable where ReturnCode = 0) and @Ret_ReturnText = ''
	--begin
	--	select @Ret_ReturnCode = ReturnCode ,@Ret_ReturnText = ReturnText from #ManifestValidLocationTable
	--end

	--if (exists(select ReturnCode from #ManifestAssignToUserTable where ReturnCode = 1) or exists(select * from #ManifestValidLocationTable where ReturnCode = 1)) and @Ret_ReturnText = ''
	--begin
	--	set @Ret_ReturnCode = 1
	--end
	
	if not exists(select * from @TempReturnTable) and @Ret_ReturnText = ''
	begin
		select @Ret_ReturnCode = 0 ,@Ret_ReturnText = 'Invalid Manifest No'
	end

	select ReturnCode = @Ret_ReturnCode ,ReturnText = @Ret_ReturnText ,LocationID = @LocationID ,HubCode = @HubCode ,HubName = @HubName

END
GO
