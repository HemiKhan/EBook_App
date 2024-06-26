USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[Metro_WMA_GetInboundStagingAreaScanItems_Delete]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================
-- Author		: Farheen
-- Create date	: 2018.11.25
-- Description	: Changes for paging
--
-- [Asim: 2023.05.02] #9512: WH app capture images
-- [Asim: 2023.08.07] #10842: Pickup Manifest
-- [Asim: 2023.12.04] #11661: Mark as damaged
-- [Asim: 2023.08.07] #12079: New Tab for overage
-- exec [dbo].[Metro_DMA_GetInboundStagingAreaScanItems] '92991', 0, 0, 10, 0
-- [dbo].[Metro_WMA_GetInboundStagingAreaScanItems] '26042',18000000,0,10,20000,0
-- [dbo].[Metro_WMA_GetInboundStagingAreaScanItems] '1952',-18000000,0,10000,,0
-- [dbo].[Metro_WMA_GetInboundStagingAreaScanItems] '32781',-18000000,0,10000,1,0
-- [dbo].[Metro_WMA_GetInboundStagingAreaScanItems] '56315',0,0,100,20000,10000,0,0
-- [dbo].[Metro_WMA_GetInboundStagingAreaScanItems] '315922',0,0,100,0,20000,0,0
-- ===========================================================================

create PROCEDURE [dbo].[Metro_WMA_GetInboundStagingAreaScanItems_Delete]
(
	@ManifestId nvarchar(max),
	@Offset int = -14400000,
    @PageIndex int = 0, 
    @PageSize int = 10,
	@ScanType int, -- 0 for All, 1 for Not Scanned, 2 for Overage, 20000 for Scanned
	@pManifestSource int = 10000,
    @TotalRowCount int OUTPUT,
	@ScannedItemCount int OUTPUT,
	@PendingItemCount int OUTPUT,
	@OverageItemCount int = 0 OUTPUT
)

AS

BEGIN
set nocount on
set transaction isolation level read uncommitted

			
if(@pManifestSource=10000) --for Pinnacle manifests without overage
	begin
		select distinct
			[ManifestDate] = dateadd(MS, @Offset, M.[Manifest Date])
			, [Manifest Date1] = format(dateadd(MS, @Offset, M.[Manifest Date]), 'MM/dd/yyyy hh:mm tt')
			, [ManifestNo] = M.[Entry No]
			, [ItemType] = (select top 1 [Description] from [dbo].[Metropolitan$Goods Type] where [Good Type Code] = MSLL.[Item Code])
			, [ItemDescription] = MSLL.[Item Description] 
			, [SKU] = MSLL.[Merchant SKU No] 
			, [Weight] = concat(cast([Weight] as int), ' lbs')
			, [CubicFeet] = concat(cast([Cu_Ft_] as decimal(10,2)), ' cu.ft.')
			, [OrderNo] = MSH.[No_]
			, [TrackingNo] = MSLL.[Item Tracking No]
			, [ScanTime] = isnull(format(dateadd(MS, @Offset , MGIWS.[Inbound_staging_area_scan]), 'MM/dd/yyyy hh:mm:ss tt'), '')
			, [Client] = isnull(MSH.[Bill-to Name], '')
			, [DestinationState]= case when MGI.[Pickup OR Delivery] = 1 then [Ship-from State] else isnull(MSH.[Ship-to State], '') end
			, [ScanType] = isnull((
					select	top 1 BSH.[Scan Type] 
					from	[dbo].[Metropolitan$Barcode Scan History] BSH 
					where	BSH.ManifestID = MG.[ManifestId] 
					and		BSH.[Barcode] = MSLL.[Item Tracking No] 
					order by [Entry No] desc
				), 0)
			, [BSH_PK] = isnull((
					select	top 1 BSH.[Entry No] 
					from	[dbo].[Metropolitan$Barcode Scan History] BSH 
					where	BSH.ManifestID = MG.[ManifestId] 
					and		BSH.[Barcode] = MSLL.[Item Tracking No] 
					order by [Entry No] desc
				), 0)
				into #tempTablePinnacleTemp
				from	[dbo].[Metropolitan$Sales Header] MSH
			join	[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
			join	[dbo].[Metropolitan$Manifest Group Items] MGI on MGI.[Item ID] = MSLL.[ID]
					and	MGI.[Is Stop Defined] = 1 and MGI.[Active Status] = 1
			left join [Metropolitan$ManifestGroups] MG on MGI.[Manifest Group ID]= MG.[ManifestGroupId]
			left join [dbo].[Metropolitan$Manifest] M on M.[Entry No] = MG.[ManifestId]
			left join [dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@pManifestSource 
			left join [dbo].[MetroVw_ManifestGroupItemsWithScans] MGIWS on MGI.ID = MGIWS.ID			
			where	M.[Entry No] =  @ManifestId   and BSH.[ManifestSource]=@pManifestSource

			select #tempTablePinnacleTemp.* 
			, [ImageCount] = (
					select	count(1)
					from	[dbo].[Metropolitan$Image] img with (nolock)
					where	img.[Ref No_] = isnull(
													cast((#tempTablePinnacleTemp.BSH_PK) as varchar), '')
					and		img.[Order No] = #tempTablePinnacleTemp.OrderNo
				)
				,[ScanItemCondition] = case when exists (select 1 from [Metropolitan_ScanItemCondition] where [ScanID]=#tempTablePinnacleTemp.BSH_PK)
												then (select isnull([ItemCondition],10000) from [Metropolitan_ScanItemCondition] where [ScanID]=#tempTablePinnacleTemp.BSH_PK)
											else 10000 end
			into #tempTablePinnacle
			from #tempTablePinnacleTemp
			--select	top 1 BSH.[Entry No] from	[dbo].[Metropolitan$Barcode Scan History] BSH 
			--										where	BSH.ManifestID = MG.[ManifestId] and BSH.[Barcode] = MSLL.[Item Tracking No] 
			--										order by [Entry No] desc
			
			--------------------------overage dataset below for union--------------------------------------

			select distinct
				[ManifestDate] = dateadd(MS, @Offset, M.[Manifest Date])
				, [Manifest Date1] = format(dateadd(MS, @Offset, M.[Manifest Date]), 'MM/dd/yyyy hh:mm tt')
				, [ManifestNo] = M.[Entry No]
				, [ItemType] = (select top 1 [Description] from [dbo].[Metropolitan$Goods Type] where [Good Type Code] = MSLL.[Item Code])
				, [ItemDescription] = MSLL.[Item Description] 
				, [SKU] = MSLL.[Merchant SKU No] 
				, [Weight] = concat(cast([Weight] as int), ' lbs')
				, [CubicFeet] = concat(cast([Cu_Ft_] as decimal(10,2)), ' cu.ft.')
				, [OrderNo] = MSH.[No_]
				, [TrackingNo] = MSLL.[Item Tracking No]
				, [ScanTime] = isnull(format(dateadd(MS, @Offset , BSH.[Scan Time]), 'MM/dd/yyyy hh:mm:ss tt'), '')
				, [Client] = isnull(MSH.[Bill-to Name], '')
				, [DestinationState]= isnull(MSH.[Ship-to State], '') 
				, [ScanType] = isnull((
						select	top 1 BSH.[Scan Type] 
						from	[dbo].[Metropolitan$Barcode Scan History] BSH 
						where	BSH.ManifestID = @ManifestId 
						and		BSH.[Barcode] = MSLL.[Item Tracking No] 
						order by [Entry No] desc
					), 0)
				, [BSH_PK] = isnull((
						select	top 1 BSH.[Entry No] 
						from	[dbo].[Metropolitan$Barcode Scan History] BSH 
						where	BSH.ManifestID = @ManifestId
						and		BSH.[Barcode] = MSLL.[Item Tracking No] 
						order by [Entry No] desc
					), 0)
					,[ScanItemCondition]=isnull(SIC.[ItemCondition],10000)
					into #tempTablePinnacleOverageTemp
					from	[dbo].[Metropolitan$Sales Header] MSH
				join	[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
				left join [dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@pManifestSource 
				left join [dbo].[Metropolitan$Manifest] M on M.[Entry No] = BSH.[ManifestID]
				left join	[Metropolitan_ScanItemCondition] SIC with(nolock) on SIC.[ScanID] = BSH.[Entry No]
				where		BSH.ManifestID = @ManifestId
							and		BSH.[Barcode] not in (
								select	sll.[Item Tracking No]
								from	[dbo].[Metropolitan$Manifest Group Items] mgi
								join	[dbo].[Metropolitan$Sales Line Link] sll on sll.ID = mgi.[Item ID]  
								join	[dbo].[Metropolitan$ManifestGroups] mg on mgi.[Manifest Group ID] = mg.[ManifestGroupId] and mg.[Active Status] = 1 
								where mg.[ManifestId] = @ManifestId
								and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
								group by sll.[Item Tracking No]
								)
				select #tempTablePinnacleOverageTemp.* 
				, [ImageCount] = (
						select	count(1)
						from	[dbo].[Metropolitan$Image] img with (nolock)
						where	img.[Ref No_] = isnull(
														cast((#tempTablePinnacleOverageTemp.BSH_PK) as varchar), '')
						and		img.[Order No] = #tempTablePinnacleOverageTemp.OrderNo
					)				
				into #tempTablePinnacleOverage
				from #tempTablePinnacleOverageTemp

				--------------------------------------overage dataset end-----------------------------------------------------------------




			select @TotalRowCount = count(*) from #tempTablePinnacle
			select @ScannedItemCount = count(*) from #tempTablePinnacle where [ScanType] = 20000
			select @PendingItemCount = count(*) from #tempTablePinnacle where [ScanType] <> 20000
			set @OverageItemCount = (
						select	count(distinct BSH.[Barcode])
						from	[dbo].[Metropolitan$Barcode Scan History] BSH 
						where	BSH.ManifestID = @ManifestId
						and		BSH.[Barcode] not in (
							select	sll.[Item Tracking No]
							from	[dbo].[Metropolitan$Manifest Group Items] mgi
							join	[dbo].[Metropolitan$Sales Line Link] sll on sll.ID = mgi.[Item ID]  
							join	[dbo].[Metropolitan$ManifestGroups] mg on mgi.[Manifest Group ID] = mg.[ManifestGroupId] and mg.[Active Status] = 1 
							where mg.[ManifestId] = @ManifestId
							and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
							group by sll.[Item Tracking No]
							)
					)

		if (@ScanType = 20000)
			begin
				select * from #tempTablePinnacle where [ScanType] = 20000 order by [ManifestNo],[ScanTime] desc
				offset @PageIndex * @PageSize rows fetch next @PageSize rows only
			end
		else if (@ScanType = 1) 
			begin
				select * from #tempTablePinnacle where [ScanType] <> 20000 order by [ManifestNo],[ScanTime]desc
				offset @PageIndex * @PageSize rows fetch next @PageSize rows only
				--select @TotalRowCount = count(*) from #tempTablePinnacle where [ScanType] <> 20000
			end
		else if (@ScanType = 0)
			begin
				select * from #tempTablePinnacle 
				union
				select * from #tempTablePinnacleOverage 
				order by [ManifestNo],[ScanTime]desc
				offset @PageIndex * @PageSize rows fetch next @PageSize rows only
				--select @TotalRowCount = count(*) from #tempTablePinnacle
				--set @OverageItemCount = (
				--select	count(distinct BSH.[Barcode])
				--from	[dbo].[Metropolitan$Barcode Scan History] BSH 
				--where	BSH.ManifestID = @ManifestId
				--and		BSH.[Barcode] not in (
				--	select	sll.[Item Tracking No]
				--	from	[dbo].[Metropolitan$Manifest Group Items] mgi
				--	join	[dbo].[Metropolitan$Sales Line Link] sll on sll.ID = mgi.[Item ID]  
				--	join	[dbo].[Metropolitan$ManifestGroups] mg on mgi.[Manifest Group ID] = mg.[ManifestGroupId] and mg.[Active Status] = 1 
				--	where mg.[ManifestId] = @ManifestId
				--	and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
				--	group by sll.[Item Tracking No]
				--	)
				--)
			end
		else
			begin
				--select distinct
				--[ManifestDate] = dateadd(MS, @Offset, M.[Manifest Date])
				--, [Manifest Date1] = format(dateadd(MS, @Offset, M.[Manifest Date]), 'MM/dd/yyyy hh:mm tt')
				--, [ManifestNo] = M.[Entry No]
				--, [ItemType] = (select top 1 [Description] from [dbo].[Metropolitan$Goods Type] where [Good Type Code] = MSLL.[Item Code])
				--, [ItemDescription] = MSLL.[Item Description] 
				--, [SKU] = MSLL.[Merchant SKU No] 
				--, [Weight] = concat(cast([Weight] as int), ' lbs')
				--, [CubicFeet] = concat(cast([Cu_Ft_] as decimal(10,2)), ' cu.ft.')
				--, [OrderNo] = MSH.[No_]
				--, [TrackingNo] = MSLL.[Item Tracking No]
				--, [ScanTime] = isnull(format(dateadd(MS, @Offset , BSH.[Scan Time]), 'MM/dd/yyyy hh:mm:ss tt'), '')
				--, [Client] = isnull(MSH.[Bill-to Name], '')
				--, [DestinationState]= isnull(MSH.[Ship-to State], '') 
				--, [ScanType] = isnull((
				--		select	top 1 BSH.[Scan Type] 
				--		from	[dbo].[Metropolitan$Barcode Scan History] BSH 
				--		where	BSH.ManifestID = @ManifestId 
				--		and		BSH.[Barcode] = MSLL.[Item Tracking No] 
				--		order by [Entry No] desc
				--	), 0)
				--, [BSH_PK] = isnull((
				--		select	top 1 BSH.[Entry No] 
				--		from	[dbo].[Metropolitan$Barcode Scan History] BSH 
				--		where	BSH.ManifestID = @ManifestId
				--		and		BSH.[Barcode] = MSLL.[Item Tracking No] 
				--		order by [Entry No] desc
				--	), 0)
				--	,[ScanItemCondition]=isnull(SIC.[ItemCondition],10000)
				--	into #tempTablePinnacleOverageTemp
				--	from	[dbo].[Metropolitan$Sales Header] MSH
				--join	[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
				--left join [dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@pManifestSource 
				--left join [dbo].[Metropolitan$Manifest] M on M.[Entry No] = BSH.[ManifestID]
				--left join	[Metropolitan_ScanItemCondition] SIC with(nolock) on SIC.[ScanID] = BSH.[Entry No]
				--where		BSH.ManifestID = @ManifestId
				--			and		BSH.[Barcode] not in (
				--				select	sll.[Item Tracking No]
				--				from	[dbo].[Metropolitan$Manifest Group Items] mgi
				--				join	[dbo].[Metropolitan$Sales Line Link] sll on sll.ID = mgi.[Item ID]  
				--				join	[dbo].[Metropolitan$ManifestGroups] mg on mgi.[Manifest Group ID] = mg.[ManifestGroupId] and mg.[Active Status] = 1 
				--				where mg.[ManifestId] = @ManifestId
				--				and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
				--				group by sll.[Item Tracking No]
				--				)
				--select #tempTablePinnacleOverageTemp.* 
				--, [ImageCount] = (
				--		select	count(1)
				--		from	[dbo].[Metropolitan$Image] img with (nolock)
				--		where	img.[Ref No_] = isnull(
				--										cast((#tempTablePinnacleOverageTemp.BSH_PK) as varchar), '')
				--		and		img.[Order No] = #tempTablePinnacleOverageTemp.OrderNo
				--	)				
				--into #tempTablePinnacleOverage
				--from #tempTablePinnacleOverageTemp

				select * from #tempTablePinnacleOverage order by [ManifestNo],[ScanTime]desc			
				offset @PageIndex * @PageSize rows fetch next @PageSize rows only
				--select @TotalRowCount = count(*) from #tempTablePinnacleOverage
			end
	end
else -- for Pickup Manifest
	begin
		select	distinct 
					[ManifestDate] =dateadd(MS, @Offset, M.[ManDate])
					, [Manifest Date1] = case when year(M.[ManDate]) < 1950 then '' else format(dateadd(MS, @Offset, M.[ManDate]), 'MM/dd/yyyy hh:mm tt') end
					, [ManifestNo] = M.[MIN_ID]
					, ItemType = (select gt.[Description] from [dbo].[Metropolitan$Goods Type] gt where gt.[Good Type Code] = MSLL.[Item Code])
					, ItemDescription = MSLL.[Item Description]
					, SKU = MSLL.[Merchant SKU No]
					, [Weight] = concat(cast(MSLL.[Weight] as int), 'lbs')
					, [CubicFeet] = concat(cast(MSLL.[Cu_Ft_] as int), 'cu.ft.')
					, [OrderNo] = MSH.[No_]
					, [TrackingNo]= MSLL.[Item Tracking No]
					--, [ScanTime] = isnull(format(dateadd(MS, @Offset , MGIWS.[Inbound_staging_area_scan]), 'MM/dd/yyyy hh:mm:ss tt'), '')
					, [ScanTime] = isnull(format(dateadd(MS, @Offset, BSH.[Scan Time]), 'MM/dd/yyyy hh:mm:ss tt'), '')
					, [Client] = isnull(MSH.[Bill-to Name], '')
					, [DestinationState]= isnull(MSH.[Ship-to State], '') 
					, [ScanType] = isnull((
					select	top 1 BSH.[Scan Type] 
					from	[dbo].[Metropolitan$Barcode Scan History] BSH 
					where	BSH.ManifestID = M.[MIN_ID]
					and		BSH.[Barcode] = MSLL.[Item Tracking No] 
					order by [Entry No] desc
				), 0)
			, [BSH_PK] = isnull((
					select	top 1 BSH.[Entry No] 
					from	[dbo].[Metropolitan$Barcode Scan History] BSH 
					where	BSH.ManifestID = M.[MIN_ID]
					and		BSH.[Barcode] = MSLL.[Item Tracking No] 
					order by [Entry No] desc
				), 0)	
				into #tempTablePPlusTemp

			from	[dbo].[Metropolitan$Sales Header] MSH
			join	[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
			join	[PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] MSO with (nolock) on cast(MSO.[Order_No] as varchar) = MSLL.[Sales Order No]
					--and	MGI.[Is Stop Defined] = 1 and MGI.[Active Status] = 1
			left join [PPlus_DB].[dbo].[T_ManifestPU_Stop] MS on MS.[MpS_ID]=MSO.[MpS_ID]
			left join [PPlus_DB].[dbo].[T_ManifestPU] M on M.[MIN_ID] = MS.[MIN_ID]
			left join [dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@pManifestSource 
			--left join [dbo].[MetroVw_ManifestGroupItemsWithScans] MGIWS on MGI.ID = MGIWS.ID
			where	M.[MIN_ID] =  @ManifestId

			select #tempTablePPlusTemp.* 
			, [ImageCount] = (
					select	count(1)
					from	[dbo].[Metropolitan$Image] img with (nolock)
					where	img.[Ref No_] = isnull(cast((#tempTablePPlusTemp.BSH_PK) as varchar), '')
					and		img.[Order No] = #tempTablePPlusTemp.OrderNo)
			,[ScanItemCondition] = case when exists (select 1 from [Metropolitan_ScanItemCondition] where [ScanID]=#tempTablePPlusTemp.BSH_PK)
												then (select isnull([ItemCondition],10000) from [Metropolitan_ScanItemCondition] where [ScanID]=#tempTablePPlusTemp.BSH_PK)
											else 10000 end
			into #tempTablePPlus
			from #tempTablePPlusTemp

			select @TotalRowCount = count(*) from #tempTablePPlus
			select @ScannedItemCount = count(*) from #tempTablePPlus where [ScanType] = 20000
			select @PendingItemCount = count(*) from #tempTablePPlus where [ScanType] <> 20000
			set @OverageItemCount = (
				select	count(distinct bsh.[Barcode])
				from	[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock)
				where not exists(
										select 1 from [PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] msi with (nolock) join
										[PPlus_DB].[dbo].[T_ManifestPU_Stop] ms with (nolock) on msi.[MpS_ID] = ms.[MpS_ID]
										where msi.Barcode collate database_default = bsh.[Barcode] collate database_default
										and ms.[MIN_ID]=@ManifestId
								)	
				and		bsh.[ManifestID] = @ManifestId
				and		bsh.[ManifestSource] = @pManifestSource
				and		bsh.[Scan Type] = 20000
			)
			

				--isnull(
				--									cast((select	top 1 BSH.[Entry No] from	[dbo].[Metropolitan$Barcode Scan History] BSH 
				--									where	BSH.ManifestID = M.[MIN_ID] and BSH.[Barcode] = MSLL.[Item Tracking No] 
				--									order by [Entry No] desc
				--									) as varchar), '')
				--	and		img.[Order No] = MSH.[No_]
				--)

			if (@ScanType = 20000)
			begin
				select * from #tempTablePPlus where [ScanType] = 20000 order by [ManifestNo],[ScanTime] desc
				offset @PageIndex * @PageSize rows fetch next @PageSize rows only
				--select @TotalRowCount = count(*) from #tempTablePPlus where [ScanType] = 20000
				--set @OverageItemCount = 0
				--(
				--	select	count(distinct bsh.[Barcode])
				--	from	[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock)
				--	where not exists(
				--							select 1 from [PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] msi with (nolock) join
				--							[PPlus_DB].[dbo].[T_ManifestPU_Stop] ms with (nolock) on msi.[MpS_ID] = ms.[MpS_ID]
				--							where msi.Barcode collate database_default = bsh.[Barcode] collate database_default
				--							and ms.[MIN_ID]=@ManifestId
				--					)	
				--	and		bsh.[ManifestID] = @ManifestId
				--	and		bsh.[ManifestSource] = @pManifestSource
				--	and		bsh.[Scan Type] = 20000
				--)
			end
		else if (@ScanType = 1) 
			begin
				select * from #tempTablePPlus where [ScanType] <> 20000 order by [ManifestNo],[ScanTime]desc
				offset @PageIndex * @PageSize rows fetch next @PageSize rows only
				--select @TotalRowCount = count(*) from #tempTablePPlus where [ScanType] <> 20000
			end
		else if (@ScanType = 0) 
			begin
				select * from #tempTablePPlus order by [ManifestNo],[ScanTime]desc 
				offset @PageIndex * @PageSize rows fetch next @PageSize rows only
				--select @TotalRowCount = count(*) from #tempTablePPlus
				--set @OverageItemCount = (
				--	select	count(distinct bsh.[Barcode])
				--	from	[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock)
				--	where not exists(
				--							select 1 from [PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] msi with (nolock) join
				--							[PPlus_DB].[dbo].[T_ManifestPU_Stop] ms with (nolock) on msi.[MpS_ID] = ms.[MpS_ID]
				--							where msi.Barcode collate database_default = bsh.[Barcode] collate database_default
				--							and ms.[MIN_ID]=@ManifestId
				--					)	
				--	and		bsh.[ManifestID] = @ManifestId
				--	and		bsh.[ManifestSource] = @pManifestSource
				--	and		bsh.[Scan Type] = 20000
				--)
			end
		else
			begin
				select distinct
				[ManifestDate] =dateadd(MS, @Offset, M.[ManDate])
				, [Manifest Date1] = case when year(M.[ManDate]) < 1950 then '' else format(dateadd(MS, @Offset, M.[ManDate]), 'MM/dd/yyyy hh:mm tt') end
				, [ManifestNo] = M.[MIN_ID]
				, ItemType = (select gt.[Description] from [dbo].[Metropolitan$Goods Type] gt where gt.[Good Type Code] = MSLL.[Item Code])
				, ItemDescription = MSLL.[Item Description]
				, SKU = MSLL.[Merchant SKU No]
				, [Weight] = concat(cast(MSLL.[Weight] as int), 'lbs')
				, [CubicFeet] = concat(cast(MSLL.[Cu_Ft_] as int), 'cu.ft.')
				, [OrderNo] = MSH.[No_]
				, [TrackingNo]= MSLL.[Item Tracking No]
				, [ScanTime] = isnull(format(dateadd(MS, @Offset, BSH.[Scan Time]), 'MM/dd/yyyy hh:mm:ss tt'), '')
				, [Client] = isnull(MSH.[Bill-to Name], '')
				, [DestinationState]= isnull(MSH.[Ship-to State], '')
				, [ScanType] = isnull((
						select	top 1 BSH.[Scan Type] 
						from	[dbo].[Metropolitan$Barcode Scan History] BSH 
						where	BSH.ManifestID = @ManifestId 
						and		BSH.[Barcode] = MSLL.[Item Tracking No] 
						order by [Entry No] desc
					), 0)
				, [BSH_PK] = isnull((
						select	top 1 BSH.[Entry No] 
						from	[dbo].[Metropolitan$Barcode Scan History] BSH 
						where	BSH.ManifestID = @ManifestId
						and		BSH.[Barcode] = MSLL.[Item Tracking No] 
						order by [Entry No] desc
					), 0)
					,[ScanItemCondition]=isnull(SIC.[ItemCondition],10000)
						into #tempTablePPlusOverageTemp
					from	[dbo].[Metropolitan$Sales Header] MSH
					join	[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
					join	[PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] MSO with (nolock) on cast(MSO.[Order_No] as varchar) = MSLL.[Sales Order No]
					left join [PPlus_DB].[dbo].[T_ManifestPU_Stop] MS on MS.[MpS_ID]=MSO.[MpS_ID]
					left join [PPlus_DB].[dbo].[T_ManifestPU] M on M.[MIN_ID] = MS.[MIN_ID]
					left join [dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@pManifestSource 
					left join	[Metropolitan_ScanItemCondition] SIC with(nolock) on SIC.[ScanID] = BSH.[Entry No]
						where not exists(
												select 1 from [PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] msi with (nolock) join
												[PPlus_DB].[dbo].[T_ManifestPU_Stop] ms with (nolock) on msi.[MpS_ID] = ms.[MpS_ID]
												where msi.Barcode collate database_default = BSH.[Barcode] collate database_default
												and ms.[MIN_ID]=@ManifestId
										)	
						and		M.[MIN_ID] = @ManifestId
						and		BSH.[ManifestSource] = @pManifestSource
						and		BSH.[Scan Type] = 20000

					select #tempTablePPlusOverageTemp.* 
					, [ImageCount] = (
							select	count(1)
							from	[dbo].[Metropolitan$Image] img with (nolock)
							where	img.[Ref No_] = isnull(
															cast((#tempTablePPlusOverageTemp.BSH_PK) as varchar), '')
							and		img.[Order No] = #tempTablePPlusOverageTemp.OrderNo
						)				
					into #tempTablePPlusOverage
					from #tempTablePPlusOverageTemp

					select * from #tempTablePPlusOverage order by [ManifestNo],[ScanTime]desc			
					offset @PageIndex * @PageSize rows fetch next @PageSize rows only
					--select @TotalRowCount = count(*) from #tempTablePPlusOverage
			end
	end

print @TotalRowCount
print @OverageItemCount
END


GO
