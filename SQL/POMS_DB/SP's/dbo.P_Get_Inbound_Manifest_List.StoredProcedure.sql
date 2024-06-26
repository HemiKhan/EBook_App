USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Inbound_Manifest_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- Declare @RetTotalCount int = 0 Declare @RetReturnCode bit = 0 Declare @RetReturnText nvarchar(250) = '' Declare @RetIsNotInManifest bit = 0 exec [POMS_DB].[dbo].[P_Get_Inbound_Manifest_List] 115101, 113101, 'IN-NC', 'NC-AD', 'ABDULLAH.ARSHAD', -14400000, 13, 1, 10, @TotalCount = @RetTotalCount out, @ReturnCode = @RetReturnCode out, @ReturnText = @RetReturnText out ,@IsNotInManifest = @RetIsNotInManifest out select @RetTotalCount ,@RetReturnCode ,@RetReturnText ,@RetIsNotInManifest
-- Declare @RetTotalCount int = 0 Declare @RetReturnCode bit = 0 Declare @RetReturnText nvarchar(250) = '' Declare @RetIsNotInManifest bit = 0 exec [POMS_DB].[dbo].[P_Get_Inbound_Manifest_List] 115101, 113101, 'IN-NC', 'NC-AD', 'ABDULLAH.ARSHAD', -14400000, 13, 1, 1000, @TotalCount = @RetTotalCount out, @ReturnCode = @RetReturnCode out, @ReturnText = @RetReturnText out ,@IsNotInManifest = @RetIsNotInManifest out select @RetTotalCount ,@RetReturnCode ,@RetReturnText ,@RetIsNotInManifest
-- ======================================================================================

CREATE PROCEDURE [dbo].[P_Get_Inbound_Manifest_List]
(
	@ManifestSource int,
	@ScanType int,
	@LocationID nvarchar(20),
	@HubCode nvarchar(20),
	@UserName nvarchar(150),
	@Offset int = -14400000,
	@TimeZoneID int = 13,
	@PageNo int = 0,
    @PageSize int = 20,
	@TotalCount int output,
	@ReturnCode bit output,
	@ReturnText nvarchar(250) output,
	@IsNotInManifest bit output,
	@ManifestIDFilter int = 0,
	@ManifestDateFrom date = '1900-01-01',
	@ManifestDateTo date = '1900-01-01',
	@StartDateFrom date = '1900-01-01',
	@StartDateTo date = '1900-01-01',
	@EndDateFrom date = '1900-01-01',
	@EndDateTo date = '1900-01-01'
)

AS

BEGIN
	
	set @TotalCount = 0
	set @ReturnCode = 0
	set @ReturnText = ''

	select @ScanType=ScanType_MTV_ID,@ManifestSource=ManifestType_MTV_ID,@IsNotInManifest=ScanAnyTime
	from [POMS_DB].[dbo].[F_Get_New_ScanType_And_ManifestType_By_ScanType_And_ManifestType] (@ScanType,@ManifestSource)
	
	set @ScanType = [POMS_DB].[dbo].[F_Get_PinnacleScanType_From_NewScanType] (@ScanType)
	
	Declare @ManifestSubType int = 10000
	select @ManifestSource = PinnacleManifestType, @ManifestSubType = PinnacleManifestSubType 
	from [POMS_DB].[dbo].[F_Get_PinnacleManifestType_From_NewManifestType] (@ManifestSource)
	print @ManifestSource
	print @ManifestSubType


	Declare @Skip int = 0
	set @Skip = (@PageNo - 1) * @PageSize

	Declare @ReturnTable table
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

	if (@IsNotInManifest = 1)
	begin
		set @ReturnCode = 1
		select * from @ReturnTable
		return
	end

	set @HubCode = upper(isnull(@HubCode,''))
	set @ManifestIDFilter = (case when @ManifestIDFilter < 0 then 0 else @ManifestIDFilter end)
	set @TotalCount = 0
	set @ReturnCode = 0
	set @ReturnText = ''

	if @ManifestSource not in (10000,30000,40000) and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid ManifestSource'
	end

	if @PageNo <= 0 and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid PageNo Value'
	end

	if @PageSize <= 0 and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid PageSize Value'
	end

	Declare @WarehouseName nvarchar(50) = ''
	if @ReturnText = ''
	begin
		select @WarehouseName = [Wharehouse Name] from [PinnacleProd].[dbo].[Metropolitan$TR Warehouse Hub] with (nolock) where Code = @HubCode
		set @WarehouseName = isnull(@WarehouseName,'')
	end

	if @WarehouseName = '' and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid HubCode'
	end

	if @ManifestSource in (10000/*,20000,30000*/) and @ReturnText = ''
	begin
		Declare @UserID int = 0
		Declare @Partner bit = 0
		select @UserID = [Web UserID] , @Partner = [Partner] from [PinnacleProd].[dbo].[Metropolitan$Web User Login] with (nolock) where Username = @UserName
		select @UserID = isnull(@UserID,0) ,@Partner = isnull(@Partner,0)
		
		drop table if exists #LineHaulOrderCount
		select OrderCount, ItemCount, [Entry No] into #LineHaulOrderCount from (
			select OrderCount=count(distinct sll.[Sales Order No])
			,ItemCount=count(distinct sll.[ID])
			,M.[Entry No]
			, ManifestAssignToUser = [POMS_DB].[dbo].[F_Is_Manifest_Assigned_To_User] (M.[Entry No], @UserID) 
			from [PinnacleProd].[dbo].[Metropolitan$Manifest] M with (nolock) 
			left join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] MG with (nolock) on M.[Entry No] = MG.ManifestId and MG.[Active Status] = 1 
			left join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] MGI with (nolock) on MG.[ManifestGroupId] = MGI.[Manifest Group ID] 
			left join [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock) on MGI.[Item ID] = sll.[ID] and MGI.[Is Stop Defined] = 1 and MGI.[Active Status] = 1
			where M.[Active Status] = 1 and	M.[Status] in (30000/*, 50000, 60000, 70000*/)
			and	M.[Type] = @ManifestSource and (M.[Type] = 10000 and M.[DestHubCode] = @HubCode)
			and M.Subtype = @ManifestSubType
			----and	M.[Type] = @ManifestSource and ((M.[Type] = 30000 and M.[OrgHubCode] = @HubCode) or (M.[Type] = 10000 and M.[DestHubCode] = @HubCode))
			--and	[POMS_DB].[dbo].[F_Is_Manifest_Assigned_To_User] (M.[Entry No], @UserID) = 1
			----and	(([POMS_DB].[dbo].[F_Is_Manifest_Assigned_To_User] (M.[Entry No], @UserID) = 1 and @Partner = 1) or @Partner = 0)
			and ((M.[Entry No] = @ManifestIDFilter and @ManifestIDFilter <> 0) or @ManifestIDFilter = 0)
			and ((year(@ManifestDateFrom) >= 2000 and M.[Manifest Date] >= @ManifestDateFrom) or year(@ManifestDateFrom) < 2000)
			and ((year(@ManifestDateTo) >= 2000 and M.[Manifest Date] <= @ManifestDateTo) or year(@ManifestDateTo) < 2000)
			and ((year(@StartDateFrom) >= 2000 and M.[Start Date] >= @StartDateFrom) or year(@StartDateFrom) < 2000)
			and ((year(@StartDateTo) >= 2000 and M.[Start Date] <= @StartDateTo) or year(@StartDateTo) < 2000)
			and ((year(@EndDateFrom) >= 2000 and M.[End Date] >= @EndDateFrom) or year(@EndDateFrom) < 2000)
			and ((year(@EndDateTo) >= 2000 and M.[End Date] <= @EndDateTo) or year(@EndDateTo) < 2000)
			group by M.[Entry No]
		) ilv where ManifestAssignToUser = 1
		
		set @TotalCount = (select count([Entry No]) from #LineHaulOrderCount)
		
		insert into @ReturnTable ([ManifestID] ,[ManifestDate] ,[StartDate] ,[EndDate] ,[Status] ,[StatusID] ,[OrderCount] , [ItemCount] ,[Driver] ,[DriverID] ,[Truck] ,[TruckID] ,[WarehouseName] ,[HubCode])
		select	M.[Entry No] , M.[Manifest Date] , M.[Start Date] , M.[End Date] 
			, [Status] = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[ID] = M.[Status] and mtv.[Master Type ID] = 10120), '')
			, [StatusID] = M.[Status] 
			, [OrderCount] = (select OrderCount from #LineHaulOrderCount lhoc1 where lhoc1.[Entry No] = M.[Entry No])
			, [ItemCount] = (select ItemCount from #LineHaulOrderCount lhoc1 where lhoc1.[Entry No] = M.[Entry No])
			, [Driver] = isnull((select top 1 drv.[Name] from [PinnacleProd].[dbo].[Metropolitan$Driver] drv with (nolock) where drv.[Driver Id] = M.[Driver Id]), '')
			, [DriverID] = M.[Driver Id] 
			, [Truck] = isnull((select top 1 trk.[Code] from [PinnacleProd].[dbo].[Metropolitan$Truck Location] trk with (nolock) where trk.[Entry No] = M.[Truck Id]), '')
			, [TruckID] = M.[Truck Id] 
			, [WarehouseName] = @WarehouseName
			, [HubCode] = @HubCode
		from [PinnacleProd].[dbo].[Metropolitan$Manifest] M with (nolock)
		where M.[Entry No] in (select lhoc.[Entry No] from #LineHaulOrderCount lhoc)
		order by M.[Entry No] desc
		offset @Skip rows fetch next @PageSize rows only
	end
	else if @ManifestSource in (30000) and @ReturnText = ''
	begin
		set @TotalCount = (select count(m.[MIN_ID]) from [PPlus_DB].[dbo].[T_Manifest] m with (nolock) where m.[ExportednuVizz] = 1 and isnull(m.OB_Scan_Complete ,0)=0 and m.[Hub] = @HubCode)

		insert into @ReturnTable ([ManifestID] ,[ManifestDate] ,[StartDate] ,[EndDate] ,[Status] ,[StatusID] ,[OrderCount] , [ItemCount] ,[Driver] ,[DriverID] ,[Truck] ,[TruckID] ,[WarehouseName] ,[HubCode])
		select * from (			select [Entry No] = m.[MIN_ID]				, [Manifest Date] = m.[StartDate_Local]				, [Start Date] = m.[WorkStart_Local]				, [End Date] = (select max(ETA_Local) from [PPlus_DB].[dbo].[T_Manifest_Stop] tms with (nolock) where MIN_ID=m.MIN_ID)				, [Status] = 'Published'				, [StatusID] = 1				, [OrderCount] = (select count(1) from [PPlus_DB].[dbo].[T_Manifest_Stop_Order] mso with (nolock)					inner join [PPlus_DB].[dbo].[T_Manifest_Stop] ms with (nolock) on ms.[MS_ID] = mso.[MS_ID] and ms.[MIN_ID] = m.[MIN_ID])				, [ItemCount] = isnull((select sum(isnull(od.TotalQty,0)) from [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock)					inner join [PPlus_DB].[dbo].[T_Manifest_Stop_Order] mso with (nolock) on od.OrderId = mso.Order_ID					inner join [PPlus_DB].[dbo].[T_Manifest_Stop] ms with (nolock) on ms.[MS_ID] = mso.[MS_ID] and ms.[MIN_ID] = m.[MIN_ID]					group by ms.[MIN_ID]),0)				, [Driver] = isnull((SELECT [Name]  FROM PinnacleProd.dbo.Metropolitan$Driver WITH (nolock) WHERE [Driver Id] = m.DRIVER_ID), '')				, [DriverID] = m.[DRIVER_ID] 				, [Truck] = isnull((SELECT Code FROM PinnacleProd.dbo.[Metropolitan$Truck Location]  WITH (nolock) WHERE [Entry No] = m.TRUCK_ID),'')				, [TruckID] = m.[TRUCK_ID]				, [WarehouseName] = @WarehouseName				, [HubCode] = @HubCode			from [PPlus_DB].[dbo].[T_Manifest] m with (nolock) where m.[ExportednuVizz] = 1			and isnull(m.OB_Scan_Complete ,0)=0 and m.[Hub] = @HubCode
			and ((m.[MIN_ID] = @ManifestIDFilter and @ManifestIDFilter <> 0) or @ManifestIDFilter = 0)
			and ((year(@ManifestDateFrom) >= 2000 and m.[StartDate_Local] >= @ManifestDateFrom) or year(@ManifestDateFrom) < 2000)
			and ((year(@ManifestDateTo) >= 2000 and m.[StartDate_Local] <= @ManifestDateTo) or year(@ManifestDateTo) < 2000)
			and ((year(@StartDateFrom) >= 2000 and m.[WorkStart_Local] >= @StartDateFrom) or year(@StartDateFrom) < 2000)
			and ((year(@StartDateTo) >= 2000 and m.[WorkStart_Local] <= @StartDateTo) or year(@StartDateTo) < 2000)
		) ilv where ((year(@EndDateFrom) >= 2000 and ilv.[End Date] >= @EndDateFrom) or year(@EndDateFrom) < 2000)
		and ((year(@EndDateTo) >= 2000 and ilv.[End Date] <= @EndDateTo) or year(@EndDateTo) < 2000)
		order by ilv.[Entry No] desc											   
		offset @Skip rows fetch next @PageSize rows only
	end
	else if @ManifestSource in (40000) and @ReturnText = ''
	begin
		set @TotalCount = (select count(m.[MIN_ID]) from [PPlus_DB].[dbo].[T_ManifestPU] m with (nolock) where m.[Status] = 1000200 and	m.[Hub] = @HubCode) 

		insert into @ReturnTable ([ManifestID] ,[ManifestDate] ,[StartDate] ,[EndDate] ,[Status] ,[StatusID] ,[OrderCount] , [ItemCount] ,[Driver] ,[DriverID] ,[Truck] ,[TruckID] ,[WarehouseName] ,[HubCode])
		select [Entry No] = m.[MIN_ID]
			, [Manifest Date] = m.[ManDate]
			, [Start Date] = m.[ManDate]
			, [End Date] = m.[ManDate]
			, [Status] = 'Published'
			, [StatusID] = 1
			, [OrderCount] = (select count(distinct mso.[Order_No]) from [PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] mso with (nolock)
				inner join [PPlus_DB].[dbo].[T_ManifestPU_Stop] ms with (nolock) on ms.[MpS_ID] = mso.[MpS_ID] and ms.[MIN_ID] = m.[MIN_ID])
			, [ItemCount] = (select count(mso.[Pin_Item_ID]) from [PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] mso with (nolock)
				inner join [PPlus_DB].[dbo].[T_ManifestPU_Stop] ms with (nolock) on ms.[MpS_ID] = mso.[MpS_ID] and ms.[MIN_ID] = m.[MIN_ID])
			, [Driver] = isnull((select	drv.[Name] from	[PinnacleProd].[dbo].[Metropolitan$Driver] drv with (nolock) where drv.[Driver Id] = m.[DRIVER_ID]), '')
			, [DriverID] = m.[DRIVER_ID] 
			, [Truck] = isnull((select tl.[Code] from [PinnacleProd].[dbo].[Metropolitan$Truck Location] tl with (nolock) where	tl.[Entry No] = m.[TRUCK_ID]), '')
			, [TruckID] = m.[TRUCK_ID]
			, [WarehouseName] = @WarehouseName
			, [HubCode] = @HubCode
		from [PPlus_DB].[dbo].[T_ManifestPU] m with (nolock) where m.[Status]= 1000200 and	m.[Hub] = @HubCode
		and ((m.[MIN_ID] = @ManifestIDFilter and @ManifestIDFilter <> 0) or @ManifestIDFilter = 0)
		and ((year(@ManifestDateFrom) >= 2000 and m.[ManDate] >= @ManifestDateFrom) or year(@ManifestDateFrom) < 2000)
		and ((year(@ManifestDateTo) >= 2000 and m.[ManDate] <= @ManifestDateTo) or year(@ManifestDateTo) < 2000)
		and ((year(@StartDateFrom) >= 2000 and m.[ManDate] >= @StartDateFrom) or year(@StartDateFrom) < 2000)
		and ((year(@StartDateTo) >= 2000 and m.[ManDate] <= @StartDateTo) or year(@StartDateTo) < 2000)
		and ((year(@EndDateFrom) >= 2000 and m.[ManDate] >= @EndDateFrom) or year(@EndDateFrom) < 2000)
		and ((year(@EndDateTo) >= 2000 and m.[ManDate] <= @EndDateTo) or year(@EndDateTo) < 2000)
		order by m.[MIN_ID] desc
		offset @Skip rows fetch next @PageSize rows only
	end

	if @ReturnText = ''
	begin
		set @ReturnCode = 1
	end

	select * from @ReturnTable order by [ManifestID] desc
	
END
GO
