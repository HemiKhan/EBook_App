USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Inbound_ManifestItems_List_2]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================
-- Declare @RetTotalCount int Declare @RetTotalItems int Declare @RetScannedCount int Declare @RetUnScannedCount int Declare @RetOSNDCount int Declare @RetOverageItemCount int Declare @RetReturnCode bit Declare @RetReturnText nvarchar(250) exec [dbo].[P_Get_Inbound_ManifestItems_List_2] 10000,1,112084,'ABDULLAH.ARSHAD',13,1,100,@TotalCount=@RetTotalCount out,@TotalItems=@RetTotalItems out, @ScannedCount=@RetScannedCount out, @UnScannedCount=@RetUnScannedCount out, @OSNDCount=@RetOSNDCount out, @OverageItemCount=@RetOverageItemCount out, @ReturnCode=@RetReturnCode out, @ReturnText = @RetReturnText out ,@OrderNo = '' ,@TrackingNo = '' select @RetTotalCount as RetTotalCount ,@RetTotalItems as RetTotalItems ,@RetScannedCount as RetScannedCount ,@RetUnScannedCount as RetUnScannedCount ,@RetOSNDCount as RetOSNDCount ,@RetOverageItemCount as RetOverageItemCount ,@RetReturnCode as RetReturnCode ,@RetReturnText as RetReturnText
-- ===========================================================================

CREATE PROCEDURE [dbo].[P_Get_Inbound_ManifestItems_List_2]
(
	@ManifestSource int,
	@ScanRecordType int,
	@ManifestID int,
	@UserName nvarchar(150),
	@TimeZoneID int = 13,
	@PageNo int = 1,
    @PageSize int = 30,
	@TotalCount int output,
	@TotalItems int output,
	@ScannedCount int output,
	@UnScannedCount int output,
	@OSNDCount int output,
	@OverageItemCount int output,
	@ReturnCode bit output,
	@ReturnText nvarchar(250) output,
	@OrderNo nvarchar(20),
	@TrackingNo nvarchar(20)
)

AS

BEGIN
	
	--select @ManifestSource=ManifestType_MTV_ID from [POMS_DB].[dbo].[F_Get_New_ScanType_And_ManifestType_By_ScanType_And_ManifestType] (@ManifestSource)
	
	Declare @ManifestSubType int = 10000
	select @ManifestSource = PinnacleManifestType, @ManifestSubType = PinnacleManifestSubType 
	from [POMS_DB].[dbo].[F_Get_PinnacleManifestType_From_NewManifestType] (@ManifestSource)
	
	Declare @Skip int = 0
	set @Skip = (@PageNo - 1) * @PageSize
	
	set @TotalCount = 0
	set @TotalItems = 0
	set @ScannedCount = 0
	set @UnScannedCount = 0
	set @OSNDCount = 0
	set @OverageItemCount = 0
	set @ReturnCode = 0
	set @ReturnText = ''

	Declare @ReturnTable table
	([ManifestDate] date
	, [ManifestID] int
	, [ItemType] nvarchar(50)
	, [ItemDescription] nvarchar(250)
	, [SKU] nvarchar(100)
	, [Weight] decimal(18,2)
	, [CubicFeet] decimal(18,2)
	, [OrderNo] nvarchar(20)
	, [TrackingNo] nvarchar(20)
	, [ScannedGUID] nvarchar(36)
	, [ScanTime] datetime
	, [Client] nvarchar(250)
	, [DestinationState] nvarchar(20)
	, [ScanType] int
	, [BSH_PK] int
	, [ImageCount] int
	, [ScannedType] int
	, ExceptionNote nvarchar(1000) null	, IsException bit null
	, IsPickup bit null
	, IsDamageMarked bit)

	Declare @OverageItemsTable table
	( [TrackingNo] nvarchar(20) collate Latin1_General_100_CS_AS)

	if @PageNo <= 0 and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid PageNo'
	end

	if @PageSize <= 0 and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid PageSize'
	end

	if @ManifestSource not in (10000,30000,40000) and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid ManifestSource'
	end

	--	ScanRecordType	Name
	--	1				All
	--	2				Scanned
	--	3				Not Scanned
	--	4				Scanned & Overage

	if @ManifestSource in (10000/*,20000,30000*/) and @ReturnText = ''
	begin
		if (@ScanRecordType = 2) --Inbound
		begin
			insert into @OverageItemsTable ([TrackingNo])
			select distinct BSH.[Barcode] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
				where BSH.ManifestID = @ManifestId and BSH.ManifestSource = 10000 and BSH.[Barcode] not in 
					(select	sll.[Item Tracking No] from	[PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi
						inner join [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll on sll.ID = mgi.[Item ID]  
						inner join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg on mgi.[Manifest Group ID] = mg.[ManifestGroupId] and mg.[Active Status] = 1 
						where mg.[ManifestId] = @ManifestId and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1 group by sll.[Item Tracking No])
		end

		insert into @ReturnTable ([ManifestDate] , [ManifestID] , [ItemType] , [ItemDescription] , [SKU] , [Weight] , [CubicFeet] , [OrderNo] , [TrackingNo] 
		, [ScannedGUID] , [ScanTime] , [Client] , [DestinationState] , [ScanType] , [BSH_PK] , [ImageCount] , [ScannedType], IsDamageMarked)
		select distinct
			[ManifestDate] = M.[Manifest Date]
			, [ManifestNo] = M.[Entry No]
			, [ItemType] = isnull((select top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Goods Type] where [Good Type Code] = MSLL.[Item Code]),'')
			, [ItemDescription] = MSLL.[Item Description] 
			, [SKU] = MSLL.[Merchant SKU No] 
			, [Weight] = [Weight]
			, [CubicFeet] = [Cu_Ft_]
			, [OrderNo] = MSH.[No_]
			, [TrackingNo] = MSLL.[Item Tracking No]
			, [ScannedGUID] = ''
			, [ScanTime] = MGIWS.[Inbound_staging_area_scan]
			, [Client] = isnull(MSH.[Bill-to Name], '')
			, [DestinationState]= case when MGI.[Pickup OR Delivery] = 1 then [Ship-from State] else isnull(MSH.[Ship-to State], '') end
			, [ScanType] = isnull((select top 1 BSH.[Scan Type] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH with (nolock) 
				where BSH.ManifestID = MG.[ManifestId] and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)
			, [BSH_PK] = isnull((select	top 1 BSH.[Entry No] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH with (nolock)
				where BSH.ManifestID = MG.[ManifestId] and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)
			, [ImageCount] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock) 
				where img.[Ref No_] = isnull(cast((select top 1 BSH.[Entry No] from	[PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
					where BSH.ManifestID = MG.[ManifestId] and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc) as varchar), '')
				and	img.[Order No] = MSH.[No_])
			, [ScannedType] = (case when oit.[TrackingNo] is not null then 4
				when MGIWS.[Inbound_staging_area_scan] is not null then 2 else 3 end)
			, IsDamageMarked = 0
			from [PinnacleProd].[dbo].[Metropolitan$Sales Header] MSH
			inner join [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
			inner join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] MGI on MGI.[Item ID] = MSLL.[ID] and	MGI.[Is Stop Defined] = 1 and MGI.[Active Status] = 1
			left join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] MG on MGI.[Manifest Group ID]= MG.[ManifestGroupId]
			left join [PinnacleProd].[dbo].[Metropolitan$Manifest] M on M.[Entry No] = MG.[ManifestId]
			left join [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@ManifestSource 
			left join [PinnacleProd].[dbo].[MetroVw_ManifestGroupItemsWithScans] MGIWS on MGI.ID = MGIWS.ID
			left join @OverageItemsTable oit on MSLL.[Item Tracking No] = oit.[TrackingNo]
			where M.[Entry No] = @ManifestID and BSH.[ManifestSource]=@ManifestSource
			--order by MSLL.[Item Tracking No]
			--offset @Skip rows fetch next @PageSize rows only
			
		if (@ScanRecordType = 2) --Inbound
		begin
			select @OverageItemCount = count(*) from @OverageItemsTable
		end
	end
	else if @ManifestSource in (30000) and @ReturnText = ''
	begin
		drop table if exists #PPlusFMManifestItems
		select m.[MIN_ID],
			ms.MS_ID,
			mso.MSO_ID,
			msoe.MSOEx_ID,
			m.[StartDate_Local],
			[Hub]=m.[Hub] collate Latin1_General_100_CS_AS,
			mso.[Is_Pickup],
			mso.[Order_ID],
			[OrderNo]=cast(mso.[Order_ID] as nvarchar(20)) collate Latin1_General_100_CS_AS,
			mso.[Ex] Order_Level_Ex,			[BarCode]=msod.[BarCode] collate Latin1_General_100_CS_AS,			[Exception_Text]=msoe.[Exception_Text] collate Latin1_General_100_CS_AS,			msoe.[Exception_Type],			msod.[ExceptionCode] Item_ex,			msod.[ConfirmedQuantity]			into #PPlusFMManifestItems		from [PPlus_DB].[dbo].[T_Manifest] m with (nolock)		inner join [PPlus_DB].[dbo].[T_Manifest_Stop] ms with (nolock) on m.MIN_ID = ms.MIN_ID		inner join [PPlus_DB].[dbo].[T_Manifest_Stop_Order] mso with (nolock) on ms.MS_ID = mso.MS_ID		inner join [PPlus_DB].[dbo].[T_Manifest_Stop_Order_Detail] msod with (nolock) on mso.MSO_ID = msod.MSO_ID		left join [PPlus_DB].[dbo].[T_Manifest_Stop_Order_Exception] msoe with (nolock) on msoe.MSO_ID = mso.MSO_ID		where ((mso.Is_Pickup = 0 and ((isnull(mso.[Ex],0) = 1 and isnull(msoe.Exception_Type,0) in (101,102,103,104,105,201,202,203,204,205))				or (isnull(mso.[Ex],0) = 0 and isnull(msod.ConfirmedQuantity,0) = 0)))			or (mso.Is_Pickup = 1 and ((isnull(mso.[Ex],0) = 0 and isnull(msod.ConfirmedQuantity,0) = 1))))			and m.MIN_ID = @ManifestId
		if (@ScanRecordType = 2) --Inbound
		begin
			insert into @OverageItemsTable ([TrackingNo])
			select distinct BSH.[Barcode] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
				where BSH.ManifestID = @ManifestId and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] not in (select [BarCode] from #PPlusFMManifestItems)
		end

		insert into @ReturnTable ([ManifestDate] , [ManifestID] , [ItemType] , [ItemDescription] , [SKU] , [Weight] , [CubicFeet] , [OrderNo] , [TrackingNo] 
		, [ScannedGUID] , [ScanTime] , [Client] , [DestinationState] , [ScanType] , [BSH_PK] , [ImageCount] , [ScannedType] , ExceptionNote , IsException , IsPickup , IsDamageMarked)
		select distinct 
			[ManifestDate] = ppfmmi.[StartDate_Local]
			, [ManifestNo] = ppfmmi.[MIN_ID]
			, ItemType = isnull((select gt.[Description] from [PinnacleProd].[dbo].[Metropolitan$Goods Type] gt where gt.[Good Type Code] = MSLL.[Item Code]),'')
			, ItemDescription = MSLL.[Item Description]
			, SKU = MSLL.[Merchant SKU No]
			, [Weight] = MSLL.[Weight]
			, [CubicFeet] = MSLL.[Cu_Ft_]
			, [OrderNo] = MSH.[No_]
			, [TrackingNo]= MSLL.[Item Tracking No]
			, [ScannedGUID] = ''	
			, [ScanTime] = BSH.[Scan Time]
			, [Client] = isnull(MSH.[Bill-to Name], '')
			, [DestinationState]= isnull(MSH.[Ship-to State], '') 
			, [ScanType] = isnull((select top 1 BSH.[Scan Type] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
				where BSH.ManifestID = ppfmmi.[MIN_ID] and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)
			, [BSH_PK] = isnull((select	top 1 BSH.[Entry No] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
				where BSH.ManifestID = ppfmmi.[MIN_ID] and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)	
			, [ImageCount] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock) 
				where img.[Ref No_] = isnull(cast((select top 1 BSH.[Entry No] from	[PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
					where	BSH.ManifestID = ppfmmi.[MIN_ID] and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc) as varchar), '')
				and	 img.[Order No] = MSH.[No_])
			, [ScannedType] = (case when oit.[TrackingNo] is not null then 4
				when BSH.[Scan Time] is not null then 2 else 3 end)
			, ExceptionNote = ppfmmi.Exception_Text
			, IsException = (case when isnull(ppfmmi.Order_Level_Ex,0) = 1 or ISNULL(ppfmmi.ConfirmedQuantity,0) = 0 then 1 else 0 end)
			, IsPickup = ppfmmi.Is_Pickup
			, IsDamageMarked = 0
			from [PinnacleProd].[dbo].[Metropolitan$Sales Header] MSH
			inner join [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
			inner join #PPlusFMManifestItems ppfmmi on MSLL.[Item Tracking No] = ppfmmi.BarCode
			left join [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@ManifestSource 
			left join @OverageItemsTable oit on MSLL.[Item Tracking No] = oit.[TrackingNo]
			where ppfmmi.[MIN_ID] = @ManifestId  --
			
			if (@ScanRecordType = 2) --Inbound 
			begin
				select @OverageItemCount = count(*) from @OverageItemsTable
			end
	end
	else if @ManifestSource in (40000) and @ReturnText = ''
	begin
		drop table if exists #PPlusPUManifestItems
		select m.[MIN_ID],
		m.[ManDate],
		Barcode=MSO.Barcode collate Latin1_General_100_CS_AS
		into #PPlusPUManifestItems		from [PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] MSO with (nolock) 
		left join [PPlus_DB].[dbo].[T_ManifestPU_Stop] MS on MS.[MpS_ID]=MSO.[MpS_ID]
		left join [PPlus_DB].[dbo].[T_ManifestPU] M on M.[MIN_ID] = MS.[MIN_ID]
		where M.[MIN_ID] = @ManifestId

		if (@ScanRecordType = 2) --Inbound
		begin
			insert into @OverageItemsTable ([TrackingNo])
			select distinct BSH.[Barcode] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
				where BSH.ManifestID = @ManifestId and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] not in (select [BarCode] from #PPlusPUManifestItems)
		end

		insert into @ReturnTable ([ManifestDate] , [ManifestID] , [ItemType] , [ItemDescription] , [SKU] , [Weight] , [CubicFeet] , [OrderNo] , [TrackingNo] 
		, [ScannedGUID] , [ScanTime] , [Client] , [DestinationState] , [ScanType] , [BSH_PK] , [ImageCount] , [ScannedType] , IsDamageMarked)
		select distinct 
			[ManifestDate] =pppumi.[ManDate]
			, [ManifestNo] = pppumi.[MIN_ID]
			, ItemType = isnull((select gt.[Description] from [PinnacleProd].[dbo].[Metropolitan$Goods Type] gt where gt.[Good Type Code] = MSLL.[Item Code]),'')
			, ItemDescription = MSLL.[Item Description]
			, SKU = MSLL.[Merchant SKU No]
			, [Weight] = MSLL.[Weight]
			, [CubicFeet] = MSLL.[Cu_Ft_]
			, [OrderNo] = MSH.[No_]
			, [TrackingNo]= MSLL.[Item Tracking No]
			, [ScannedGUID] = ''	
			, [ScanTime] = BSH.[Scan Time]
			, [Client] = isnull(MSH.[Bill-to Name], '')
			, [DestinationState]= isnull(MSH.[Ship-to State], '') 
			, [ScanType] = isnull((select top 1 BSH.[Scan Type] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
				where BSH.ManifestID = pppumi.[MIN_ID] and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)
			, [BSH_PK] = isnull((select	top 1 BSH.[Entry No] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
				where BSH.ManifestID = pppumi.[MIN_ID] and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)	
			, [ImageCount] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock) 
				where img.[Ref No_] = isnull(cast((select top 1 BSH.[Entry No] from	[PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
					where	BSH.ManifestID = pppumi.[MIN_ID] and BSH.ManifestSource = @ManifestSource and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc) as varchar), '')
				and	 img.[Order No] = MSH.[No_])
			, [ScannedType] = (case when oit.[TrackingNo] is not null then 4
				when BSH.[Scan Time] is not null then 2 else 3 end)
			, IsDamageMarked = 0
			from [PinnacleProd].[dbo].[Metropolitan$Sales Header] MSH
			inner join [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
			inner join #PPlusPUManifestItems pppumi with (nolock) on pppumi.Barcode = MSLL.[Item Tracking No]
			left join [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@ManifestSource 
			left join @OverageItemsTable oit on MSLL.[Item Tracking No] = oit.[TrackingNo]
			where pppumi.[MIN_ID] = @ManifestId  --
			
			if (@ScanRecordType = 2) --Inbound 
			begin
				select @OverageItemCount = count(*) from @OverageItemsTable
			end
	end

	if @ReturnText = ''
	begin
		set @ReturnCode = 1
	end

	if exists(select * from @ReturnTable)
	begin
		drop table if exists #tmpFinal
		select * into #tmpFinal from @ReturnTable r
		where ((r.[OrderNo] = @OrderNo and @OrderNo <> '') or @OrderNo = '')
		and ((r.[TrackingNo] = @TrackingNo and @TrackingNo <> '') or @TrackingNo = '')
		and (@ScanRecordType = 1 or (ScannedType = @ScanRecordType))
		order by r.[ScanTime],r.[TrackingNo]
		offset @Skip rows fetch next @PageSize rows only
	
		if exists(select * from #tmpFinal)
		begin
			select @TotalCount = count(*)
			,@TotalItems = count(*)
			,@ScannedCount = sum(case when r.ScannedType in (2,4) then 1 else 0 end)
			,@UnScannedCount = sum(case when r.ScannedType in (3) then 1 else 0 end)
			,@OSNDCount = 0
			,@OverageItemCount = sum(case when r.ScannedType in (4) then 1 else 0 end)
			from @ReturnTable r
			where ((r.[OrderNo] = @OrderNo and @OrderNo <> '') or @OrderNo = '')
			and ((r.[TrackingNo] = @TrackingNo and @TrackingNo <> '') or @TrackingNo = '')
			and (@ScanRecordType = 1 or (r.ScannedType = @ScanRecordType))
		end
		select * from #tmpFinal r
		order by r.[OrderNo], r.[TrackingNo]
	end
	else
	begin
		select * from @ReturnTable r
		where ((r.[OrderNo] = @OrderNo and @OrderNo <> '') or @OrderNo = '')
		and ((r.[TrackingNo] = @TrackingNo and @TrackingNo <> '') or @TrackingNo = '')
		and (@ScanRecordType = 1 or (ScannedType = @ScanRecordType))
		order by r.[OrderNo], r.[TrackingNo]
	end

END


GO
