USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Inbound_NotInManifestItems_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================
-- Declare @RetTotalCount int Declare @RetReturnCode bit Declare @RetReturnText nvarchar(250) exec [dbo].[P_Get_Inbound_NotInManifestItems_List] 0,'["1234567812345678"]','ABDULLAH.ARSHAD',13,1,100,@TotalCount=@RetTotalCount out, @ReturnCode=@RetReturnCode out, @ReturnText = @RetReturnText out select @RetTotalCount as RetTotalCount ,@RetReturnCode as RetReturnCode ,@RetReturnText as RetReturnText
-- ===========================================================================

CREATE PROCEDURE [dbo].[P_Get_Inbound_NotInManifestItems_List]
(
	@ManifestSource int,
	@Barcodes nvarchar(max),
	@UserName nvarchar(150),
	@TimeZoneID int = 13,
	@PageNo int = 1,
    @PageSize int = 30,
	@TotalCount int output,
	@ReturnCode bit output,
	@ReturnText nvarchar(250) output
)

AS

BEGIN
	
	set @TotalCount = 0
	set @ReturnCode = 0
	set @ReturnText = ''

	set @Barcodes = isnull(@Barcodes,'')

	if @Barcodes = ''
	begin
		set @ReturnText = 'Barcode is Required'
	end
	else
	begin
		if ISJSON(@Barcodes) = 0
		begin
			set @ReturnText = 'Invalid Barcodes List'
		end
	end
	
	Declare @BarcodesList table(Barcode nvarchar(20) collate Latin1_General_100_CS_AS)
	insert into @BarcodesList (Barcode)
	select bc.Barcode from OpenJson(@Barcodes) WITH (Barcode nvarchar(20) '$') bc

	Declare @ManifestSubType int = 10000
	select @ManifestSource = PinnacleManifestType, @ManifestSubType = PinnacleManifestSubType 
	from [POMS_DB].[dbo].[F_Get_PinnacleManifestType_From_NewManifestType] (@ManifestSource)
	
	Declare @Skip int = 0
	set @Skip = (@PageNo - 1) * @PageSize
	
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

	if @PageNo <= 0 and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid PageNo'
	end

	if @PageSize <= 0 and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid PageSize'
	end

	insert into @ReturnTable ([ManifestDate] , [ManifestID] , [ItemType] , [ItemDescription] , [SKU] , [Weight] , [CubicFeet] , [OrderNo] , [TrackingNo] 
	, [ScannedGUID] , [ScanTime] , [Client] , [DestinationState] , [ScanType] , [BSH_PK] , [ImageCount] , [ScannedType], IsDamageMarked)
	select distinct
		[ManifestDate] = null
		, [ManifestNo] = 0
		, [ItemType] = isnull((select top 1 [Description] from [PinnacleProd].[dbo].[Metropolitan$Goods Type] where [Good Type Code] = MSLL.[Item Code]),'')
		, [ItemDescription] = MSLL.[Item Description] 
		, [SKU] = MSLL.[Merchant SKU No] 
		, [Weight] = MSLL.[Weight]
		, [CubicFeet] = MSLL.[Cu_Ft_]
		, [OrderNo] = MSH.[No_]
		, [TrackingNo] = MSLL.[Item Tracking No]
		, [ScannedGUID] = ''
		, [ScanTime] = isnull((select top 1 BSH1.[Scan Time] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH1 with (nolock) 
			where BSH1.ManifestID = 0 and BSH1.ManifestSource = @ManifestSource and BSH1.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)
		, [Client] = isnull(MSH.[Bill-to Name], '')
		, [DestinationState]= 'From ' + [Ship-from State] + ' To ' + [Ship-to State]
		, [ScanType] = isnull((select top 1 BSH1.[Scan Type] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH1 with (nolock) 
			where BSH1.ManifestID = 0 and BSH1.ManifestSource = @ManifestSource and BSH1.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)
		, [BSH_PK] = isnull((select	top 1 BSH1.[Entry No] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH1 with (nolock)
			where BSH1.ManifestID = 0 and BSH1.ManifestSource = @ManifestSource and BSH1.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)
		, [ImageCount] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock) 
			where img.[Ref No_] = isnull(cast((select top 1 BSH1.[Entry No] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH1 with (nolock) 
				where BSH1.ManifestID = 0 and BSH1.ManifestSource = @ManifestSource and BSH1.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc) as varchar), '')
			and	img.[Order No] = MSH.[No_])
		, [ScannedType] = 2
		, IsDamageMarked = 0
		from [PinnacleProd].[dbo].[Metropolitan$Sales Header] MSH
		inner join [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
		where MSLL.[Item Tracking No] in (select bl.Barcode from @BarcodesList bl)

	if @ReturnText = ''
	begin
		set @ReturnCode = 1
	end

	if exists(select * from @ReturnTable)
	begin
		drop table if exists #tmpFinal
		select * into #tmpFinal from @ReturnTable r
		order by r.[ScanTime],r.[TrackingNo]
		offset @Skip rows fetch next @PageSize rows only
	
		if exists(select * from #tmpFinal)
		begin
			select @TotalCount = count(*)
			from @ReturnTable r
		end
		select * from #tmpFinal r
		order by r.[ScanTime],r.[OrderNo], r.[TrackingNo]
	end
	else
	begin
		select * from @ReturnTable r
		order by r.[ScanTime],r.[OrderNo], r.[TrackingNo]
	end

END


GO
