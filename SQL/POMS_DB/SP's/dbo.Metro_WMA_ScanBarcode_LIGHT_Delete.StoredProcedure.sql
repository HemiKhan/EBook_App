USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[Metro_WMA_ScanBarcode_LIGHT_Delete]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================
-- Author		: Mohd Tasleem
-- Create date	: 2020.11.12
-- Description	: To scan the barcode and return result
--				.. added a new column [ScanOption] in [Barcode Scan History]
--				.. to mark scans via new LIGHT (20000) option
--				.. defaulted to 10000 (LEGACY)
-- [Asim: 2023.02.01] #9025: Centralized SP for Barcode
-- [Asim: 2023.05.04] #9512: WH app capture images
-- exec [dbo].[Metro_WMA_ScanBarcode_LIGHT] 40000, '2179653649590002', 'out-nc', 0, 1374,1,'',0
-- ============================================================================================

create PROCEDURE [dbo].[Metro_WMA_ScanBarcode_LIGHT_Delete]
(
	@pScanType int,
	@pBarcode varchar(20),
	@pLocationID varchar(12),
	@pManifestID int,
	@pScanBy int,
	@pScanAny bit,
	@pDeviceID varchar(10) = 'Device',	-- varchar(10)
	@pManifestSource int = 10000,
	@pIsPickupNotInManifest bit = 0
)

AS

BEGIN

set transaction isolation level read uncommitted
--select * from [Metropolitan$Time Zone]
declare @orderNo varchar(40), @customerNo varchar(20), @pkpScheduled int, @destWHCode varchar(10), @itemID int, @whLocation varchar(20), @whCode varchar(20), @mftSchType int
	, @msg varchar(200) = '', @scanText varchar(100) = '', @status int = 0, @deviceID varchar(20) = 'Device', @scanTime datetime = getutcdate()
	, @totOrderItems int, @totInbound int, @totScannedInWH int, @totItemScanned int
	, @totItemsMF int = 0, @totScannedMF int = 0, @orderStatus int, @eventCode int = 0, @lastScannedLocation varchar(20), @locID varchar(20), @inboundLoc int
	, @whName nvarchar(150), @pickupTriggers bit = 0, @errorID int = 0, @overageItem int = 0,@barcodeScanEntryNo int=0, @role varchar(25) = ''

set @pickupTriggers = 1
				--case
				----when @pScanAny = 1 then 1
				--when @pScanAny = 0 and @pScanType = 40000 then 0
				--else 1 end


	--, @tzOffset int = isnull(
	--	(
	--		select	top 1 tz.[Offset]
	--		from	[dbo].[Metropolitan$Time Zone] tz
	--		join	[dbo].[Metropolitan$Web User Login] wul on wul.[Time Zone ID] = tz.[Time Zone ID] and wul.[Web UserID] = @pScanBy
	--	), -18000000)


-- Get item info ..
select	@orderNo = sh.[No_], @customerNo = sh.[Bill-to Customer No_], @pkpScheduled = sl.[Pickup DateScheduled], @itemID = sll.[ID]
		, @destWHCode = (select top 1 zz.[HubCode] from [dbo].[vw_Metro_ZipZoneHub] zz where zz.[ZipCode] = sh.[Ship-to Post Code])
		, @orderStatus = sh.[Order Status]
from	[dbo].[Metropolitan$Sales Line Link] sll
join	[dbo].[Metropolitan$Sales Header] sh on sh.[No_] = sll.[Sales Order No] and sh.[Document Type] = 1 and sh.[Register Type] = 0
join	[dbo].[Metropolitan$Sales Linkup] sl on sl.[Document No] = sh.[No_] and sl.[Document Type] = 1
where	sll.[Item Tracking No] = @pBarcode
and		sll.[Item Type] = 1
-- @pBarcode, @orderNo, @pScanType, @whLocation, @whCode, @pScanBy, @pManifestID, @itemID
--			, @deviceID, @scanTime, 

if(@pManifestSource=40000)
begin
	if(isnull(@orderNo,'')='')
		begin
			set @orderNo = '00000'
			set @customerNo = ''
		end
	
		exec [dbo].[Metro_WMA_ScanBarcode_PickupManifest_LIGHT] @orderNo,@customerNo, @pkpScheduled, @pBarcode,@pLocationID,@pManifestID,@pScanBy, @pScanAny,@destWHCode, @pDeviceID
		return
	
end
else if(@pIsPickupNotInManifest = 1)
begin
	exec [dbo].[Metro_WMA_ScanBarcode_PickupNotInManifest_LIGHT] @pBarcode, @pLocationID, @pScanBy
	return
end
else
begin
select	top 1
		@lastScannedLocation = [Location]
from	[Metropolitan$Barcode Scan History]
where	[Order No] = @orderNo
and		[Scan Type] = 20000
order by	[Scan Time] desc
select  top 1 
		@locID = isnull(wle.[Warehouse ID],'')
from	[dbo].[Metropolitan$Warehouse Location Entry] wle
where	upper(wle.[Code]) = upper(@pLocationID)
or		upper(wle.[Barcode]) = upper(@pLocationID)
or		upper(wle.[Warehouse ID]) = upper(@pLocationID)
select 
		@inboundLoc = count (1)
from	[Metropolitan$Barcode Scan History]
where	[Barcode] = @pBarcode
and		[Scan Type] = 20000
and	(
	--	upper([Location]) = upper(@pLocationID)
	--or  upper([Location ID]) = upper(@pLocationID)
	upper([Location]) = upper(@locID)
) 
select  top 1
		@whName = isnull([Wharehouse Name],'')
from	[Metropolitan$TR Warehouse Hub]
where	[Code] = @locID
and		@locID != ''
print 'start'
if(@pScanType = 30000 and @pScanAny = 0)--@pScanType = 30000 --[2021.11.11 : Tasleem]
begin
print '@pScanType = 30000'		 
declare @mapManifestSalesOrderLH tinyint = 0,@itemLocation varchar(50),@mOrgHubCode varchar(30), @mDestHubCode varchar(30)
declare @tmp table
(
	[OrderNo] varchar(40)
	, [ScanText] varchar(100)
	, [ResultMsg] varchar(50)
	, [Status] int
	,[BarcodeScanEntryNo] int
)
declare @tmpAutoPickup table
(
	[PickupCompletedDate] varchar(100)
	, PickupScheduledDate  varchar(100)
	, PickupCompletedEvtDate datetime
	, PickupScheduledEvtDate datetime
	, IsSuccess bit
)
insert into @tmp([OrderNo],[ScanText],[ResultMsg],[Status],[BarcodeScanEntryNo])
exec [dbo].[Metro_WMA_AttachedManifest_LIGHT_UPDATED]@pScanType,@pBarcode,@pLocationID,	@pManifestID,@pScanBy,@itemID,@orderNo,@orderStatus

select	@scanText = [ScanText]
		, @msg = [ResultMsg]
		, @status = [Status]
		,@barcodeScanEntryNo = [BarcodeScanEntryNo]
from	@tmp

set		@totItemsMF = (
	select	count(1)
	from	[dbo].[Metropolitan$Sales Line Link]
	where	[Sales Order No] in (
					select	sll.[Sales Order No]
					from	[dbo].[Metropolitan$Manifest Group Items] mgi
					join	[dbo].[Metropolitan$Sales Line Link] sll on sll.ID = mgi.[Item ID]  
					join	[dbo].[Metropolitan$ManifestGroups] mg on mgi.[Manifest Group ID] = mg.[ManifestGroupId] and mg.[Active Status] = 1 
					where mg.[ManifestId] = @pManifestID
					and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
					group by sll.[Sales Order No]
				)
)
--(
--select	count(1)
--from	[Metropolitan$Sales Header] sh with(nolock) 
--join	[Metropolitan$Sales Linkup] sl with(nolock) on sh.[No_] = sl.[Document No] and sh.[Register Type] = 0 and sh.[Register Type] = 0 and sh.[Document Type] = 1 and sl.[Register Type] = 0  
--join	[Metropolitan$Sales Line Link] sll with(nolock)  on sh.[No_]= sll.[Sales Order No]
--join	[Metropolitan$Manifest Group Items] mgi with(nolock) on mgi.[Item ID]= sll.[ID]	and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
--join	[Metropolitan$ManifestGroups] mg with(nolock) on mgi.[Manifest Group ID] = mg.[ManifestGroupId] and mg.[Active Status] = 1
--where	mg.[ManifestId] = @pManifestID
--)

print '@totItemsMF: ' + cast(@totItemsMF as varchar)
set @totScannedMF = (select count(1)
	from	[dbo].[Metropolitan$Manifest Group Items] mgi
	join	[dbo].[Metropolitan$ManifestGroups] mg on mgi.[Manifest Group ID] = mg.[ManifestGroupId] and mg.[Active Status] = 1
	join	[dbo].[Metropolitan$Sales Line Link] sll on sll.[ID] = mgi.[Item ID]
	where mg.[ManifestId] = @pManifestID
	and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
)
print '@totScannedMF: ' + cast(@totScannedMF as varchar)
end
else
begin

print '@pScanAny : ' + cast(@pScanAny as varchar) + ', @pScanType : ' + cast(@pScanType as varchar) + ', @lastScannedLocation : ' + cast(@lastScannedLocation as varchar)
 + ', @locID ' + cast(@locID as varchar) + ', @inboundLoc : ' + cast(@inboundLoc as varchar)
	if (@pManifestID > 0)
	begin
		-- Total items in manifest ...
		set @totItemsMF = (
				select	count(1)
				from	[dbo].[Metropolitan$Sales Line Link] sll
				join	[dbo].[Metropolitan$Manifest Group Items] mgi on mgi.[Item ID] = sll.[ID] and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
				join	[dbo].[Metropolitan$ManifestGroups] mg on mg.[ManifestGroupId] = mgi.[Manifest Group ID] and mg.[ManifestId] = @pManifestID
				where	sll.[Item Type] = 1
				and		sll.[Document Type] = 1
			)
		print '@totItemsMF: ' + cast(@totItemsMF as varchar)
		-- Total items scanne in manifest ...
		set @totScannedMF = (
				select	count(distinct [Barcode])
				from	(
							select	bsh.[Barcode]
									, [ScanType] = (
											select	top 1 BSH.[Scan Type] 
											from	[dbo].[Metropolitan$Barcode Scan History] BSH 
											where	BSH.ManifestID = mg.[ManifestId] 
											and		BSH.[Barcode] = sll.[Item Tracking No]
											order by BSH.[Entry No] desc
										)
							from	[dbo].[Metropolitan$Barcode Scan History] bsh
							join	[dbo].[Metropolitan$Sales Line Link] sll on sll.[Item Tracking No] = bsh.[Barcode] and sll.[Item Type] = 1 and sll.[Document Type] = 1 and bsh.[ManifestSource]=@pManifestSource
							join	[dbo].[Metropolitan$Manifest Group Items] mgi on mgi.[Item ID] = sll.[ID] and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
							join	[dbo].[Metropolitan$ManifestGroups] mg on mg.[ManifestGroupId] = mgi.[Manifest Group ID] and mg.[ManifestId] = @pManifestID
						) t
				where	ScanType = @pScanType
			)
		print '@totScannedMF: ' + cast(@totScannedMF as varchar)
	end
	declare @isValidItem bit = 1, @tempItemID int = 0
	if(@pScanAny = 0 and @pScanType = 20000)
	begin
		
		if(isnull(@itemID,0) = 0)
		begin
			set @tempItemID = isnull(
			(	select		count(1)
				from	[dbo].[Metropolitan$Sales Line Link] sll
				join	[dbo].[Metropolitan$Sales Header] sh on sh.[No_] = sll.[Sales Order No] and sh.[Document Type] = 1 and sh.[Register Type] = 0
				join	[dbo].[Metropolitan$Sales Linkup] sl on sl.[Document No] = sh.[No_] and sl.[Document Type] = 1
				where	substring(sll.[Item Tracking No],1,12) = substring(@pBarcode,1,12)
				and		sll.[Item Type] = 1
			),0)
				if(@tempItemID != 0)
				begin
					set @OrderNo = isnull(@OrderNo,'00000')
					set @errorID = 60001
					set @msg = 'The item ' + @pBarcode + ' is not included in the manifest ' + cast(@pManifestID as varchar) + ' so will be added as Overage'
					set @status = 1
				end
		end
		else if (not exists(select top 1  1 from [dbo].[Metropolitan$Sales Line Link] sll 
							join	[dbo].[Metropolitan$Manifest Group Items] mgi on mgi.[Item ID] = sll.[ID] and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
							join	[dbo].[Metropolitan$ManifestGroups] mg on mg.[ManifestGroupId] = mgi.[Manifest Group ID] and mg.[ManifestId] = @pManifestID
							where sll.[Item Tracking No] = @pBarcode and sll.[Item Type] = 1 and sll.[Document Type] = 1) and @pManifestID > 0)
			begin
				print 'Check'
				set @errorID = 60001
				set @msg = 'The item ' + @pBarcode + ' is not included in the manifest ' + cast(@pManifestID as varchar) + ' so will be added as Overage'
				set @status = 1
				set @tempItemID = @itemID
				set @OrderNo = isnull(@OrderNo,'00000')
			end
	end
	
	set @isValidItem = case
		when @tempItemID != 0 then 1
		when isnull(@itemID,0) = 0 and @tempItemID = 0 and @pScanAny = 0 and @pScanType = 20000 then 0
		when isnull(@itemID,0) = 0 then 0 else 1 end
	print '@tempItemID : ' + cast(@tempItemID as varchar) + ', @isValidItem : '  + cast(@isValidItem as varchar) + ', @itemID : ' + cast(@itemID as varchar)
	
	if(@pScanType = 40000)
		begin
			select @role = [Description] from [Metropolitan$Web Role] wr join [Metropolitan$Web User Login] wul
			on wr.[Role Id] = wul.[Web Role] where wul.[Web UserID] = @pScanBy
		end
	
	if(len(@pBarcode) > 16)
	begin
	set @msg = 'Invalid barcode ' + @pBarcode
	set @scanText = ''
	set @status = 0
	end
	else if (isnull(@isValidItem,0) = 0)
	begin
	print 'validItem'
		set @msg = 'Invalid barcode ' + @pBarcode
		set @errorID = 0
	end
	else if(isnull(@locID,'') = '')
	begin
	print 'locID'
	set @msg = 'Invalid location code : ' + @pLocationID
	set @errorID = 0
	end
	else if (exists(select top 1 1 from [dbo].[Metropolitan$Barcode Scan History] where [Barcode] = @pBarcode and [Scan Type] = @pScanType and [ManifestID] = @pManifestID) and @pScanAny = 0 and @pScanType != 40000)
	begin		-- ALREADY SCANNED ...
		print 'ALREADY SCANNED'
		set @msg = @pBarcode + ' already scanned'
		set @errorID = 0
		set @status = 0
	end		
	else if(@role = 'Warehouse User' and (@pScanAny = 0 and @pScanType = 40000 and (upper(@lastScannedLocation) != upper(@locID) or @inboundLoc < 1)))
	begin
	print 'inbound'
	set @msg = 'Please do inbound of items at current location.'
	set @errorID = 0
	end
	--else if(@pScanAny = 0  and @pScanType = 40000 and not exists(select top 1 1
	--					from	[dbo].[Metropolitan$Barcode Scan History]
	--					where	[Barcode] = @pBarcode
	--					and		[Scan Type] = 40000
	--					and		(upper([Location]) = upper(@pLocationID) or upper([Location ID]) = upper(@pLocationID))
	--					order by [Scan Time] desc)
	--)
	--begin
	--set @msg = 'Item already scanned in this location!'
	--end
	else if (not exists(select top 1  1 from [dbo].[Metropolitan$Sales Line Link] sll 
							join	[dbo].[Metropolitan$Manifest Group Items] mgi on mgi.[Item ID] = sll.[ID] and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
							join	[dbo].[Metropolitan$ManifestGroups] mg on mg.[ManifestGroupId] = mgi.[Manifest Group ID] and mg.[ManifestId] = @pManifestID
							where sll.[Item Tracking No] = @pBarcode and sll.[Item Type] = 1 and sll.[Document Type] = 1) and @pScanAny = 0 and @pManifestID > 0 and @pScanType != 20000)--2021.11.03
		-- INVALID BARCODE FOR MANIFEST...
		begin
		print 'INVALID BARCODE FOR MANIFEST'
		set @msg ='Invalid barcode:'+ @pBarcode + ' for this Manifest.'
		set @errorID = 0
		end
	else
	begin
		-- VALID ITEM ...
		print 'VALID ITEM'
		-- Check if manifested fro pickup or delivery?
		set @mftSchType = (
				select	top 1 mgi.[Pickup OR Delivery]
				from	[dbo].[Metropolitan$Manifest Group Items] mgi
				join	[dbo].[Metropolitan$ManifestGroups] mg on mg.[ManifestGroupId] = mgi.[Manifest Group ID] and mg.[ManifestId] = @pManifestID
				where	mgi.[Item Status] = @itemID
			)

		-- Get warehouse location and warehouse code ...
		select	top 1 @whLocation = wle.[Code], @whCode = wle.[Warehouse ID]
		from	[dbo].[Metropolitan$Warehouse Location Entry] wle
		--join	[dbo].[Metropolitan$Truck Location] tl on wle.[Code] = tl.[Code] and wle.[Barcode] = tl.[Barcode] -- do we need this?
		where	upper(wle.[Code]) = upper(@pLocationID)
		or		upper(wle.[Barcode]) = upper(@pLocationID)

		-- Add scan entry ...
		print 'add entry'

		--new centralized sp
		declare  @scanItemID int
		set @scanItemID = isnull(@itemID,0)
		exec @barcodeScanEntryNo = [dbo].[Metro_InsertScans] @pBarcode, @orderNo,@pScanType,@whLocation,@whCode,@pScanBy,@pManifestID,@scanItemID,@scanTime,@pDeviceID,@pScanAny,20000
		
		-- Old insert code
		--insert into [dbo].[Metropolitan$Barcode Scan History]
		--(
		--	[Barcode], [Order No], [Scan Type], [Location ID], [Location], [Scan By], [ManifestID], [Scan Item ID]
		--	, [Device ID], [Scan Time], [Active Status], [ScanAnytime], [AutoScan], [ScanOption], [Lat], [Lang], [GoogleAddress]
		--)
		--values
		--(
		--	@pBarcode, @orderNo, @pScanType, @whLocation, @whCode, @pScanBy, @pManifestID, isnull(@itemID,0)
		--	, @deviceID, @scanTime, 1, @pScanAny, 0, 20000, '', '', ''
		--)
		
		print @msg
		set @scanText = 'Item # <strong>' + @pBarcode + '</strong><br /> POM - ' + @orderNo + ' // ' + ' Scan time - ' + format(dateadd(MS, -18000000, getutcdate()),'MM/dd/yyyy hh:mm tt')-- NEEDTOCHECK if timezone conversion is required
		set @msg = case when @errorID > 0 then @msg else  @pBarcode + ' scanned successfully' end
		set @status = 1

		declare @warehouseStatus int = 10010,@warehouseLocation int = 10000
		IF(@pScanAny = 1 AND @pScanType = 30000)
			BEGIN
				SET @warehouseStatus = 30000
				SET @warehouseLocation = 40000
			END

		-- Update item status ...
		if (@mftSchType in (1,2) OR (@pScanAny = 1 AND @pScanType = 30000))
		begin
			update [dbo].[Metropolitan$Sales Line Link] 
			set		[WarehouseStatus] = @warehouseStatus --10010 -- In-Warehouse
					, [WarehouseLocation] = @warehouseLocation --10000 -- Inbound Staging Area
					, [WarehouseLocationCode] = case when @pScanType not in (50000,100000) then @whLocation else [WarehouseLocationCode] end
					, [Item Pickup Status] = case when @mftSchType = 1 then 1 else [Item Pickup Status] end
					, [Item Delivery Status] = case when @mftSchType = 2 then 0 else [Item Delivery Status] end
					, [ModifiedBy] = @pScanBy
					, [ModifedOn] = @scanTime
			where	[Item Tracking No] = @pBarcode
			and		[Document Type] = 1
			and		[Register Type] = 0
			and		[Item Type] = 1
		end

		-- Update order status ...
		update	[dbo].[Metropolitan$Sales Header]
		set		[Warehouse Status] = @warehouseStatus --10010 -- In-Warehouse
				, [WarehouseLocation] = case when @pScanAny = 0 and @pScanType = 40000 then 30000
											 when @pScanAny = 1 and @pScanType = 30000 then 40000
											 else 10000  -- Inbound Staging Area
											 end
				, [WarehouseLocationCode] = case when @pScanType not in (50000, 100000) then @whLocation else [WarehouseLocationCode] end
		where	[No_] = @orderNo
		and		[Document Type] = 1

		if(@pScanAny = 0 and @pScanType = 40000)--warehouse Location  [2021.11.16]
		begin
			update [dbo].[Metropolitan$Sales Line Link] 
			set		[WarehouseLocation] = 30000
					, [WarehouseLocationCode] = @whLocation
					, [WarehouseStatus] = @warehouseStatus --10010
			where	[Item Tracking No] = @pBarcode
		end
		-- Update manifest status ...
		update	[dbo].[Metropolitan$Manifest] 
		set		[Warehouse Status] = @warehouseStatus --10010 -- In-Warehouse
		where	[Entry No] = @pManifestID

		-- Trigger event - Scan Barcode (Inbound Staging Area)--[21.11.15 : Tasleem :DO-5683,84,85]
		if(@pScanAny = 0 and @pScanType = 40000)
		exec Metro_InsertUpdateOrderInfoEventTriggered 94, 0, 0, 0, @pScanBy, 1, '30000', 'WarehouseLocation/SaveWarehouseBarcode', 'Warehouse App User', @orderNo, @customerNo, '', '', ''
		else if(@pScanAny = 0 and @tempItemID = 0)
		exec Metro_InsertUpdateOrderInfoEventTriggered 95, 0, 0, 0, @pScanBy, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @orderNo, @customerNo, '', '', ''

		else if(@pScanAny = 1 and @tempItemID = 0)
		begin
			set @eventCode = case
								when @pScanType = 20000 then 95
								when @pScanType = 30000 then 93
								else 94
						end
			exec Metro_InsertUpdateOrderInfoEventTriggered @eventCode, 0, 0, 0, @pScanBy, 1, '30000', 'LoadingtoTruck/ScanItem/ScanAnyTime', 'Warehouse App User', @orderNo, @customerNo, '', '', ''
		end

		-- Trigger event - Pickup completed, No exceptions
		set @totOrderItems = (select count(1) from [dbo].[Metropolitan$Sales Line Link] sll where sll.[Sales Order No] = @orderNo and sll.[Document Type] = 1 and sll.[Item Type] = 1)
		set @totInbound = (
				select	count(1) 
				from	[dbo].[Metropolitan$Sales Line Link] sll 
				where	sll.[Sales Order No] = @orderNo 
				and		sll.[Document Type] = 1 
				and		sll.[Item Type] = 1
				and		sll.[Item Pickup Status] = 1
			)
		set @totItemScanned = (
				select	count(distinct [Barcode]) 
				from	[dbo].[Metropolitan$Barcode Scan History] 
				where	[Order No] = @orderNo 
				and		[Location] = @whCode 
				and		[ManifestSource] = @pManifestSource
		--		and		[Scan Type] = @pScanType [2021.11.22 : Tasleem] as discussed with danish sir and wasim sir
			)

		
		print '@totOrderItems :' + cast(@totOrderItems as varchar)
		+ ', @totInbound : ' + cast(@totInbound as varchar)
		+ ', @pScanAny : ' + cast(@pScanAny as varchar) 
		+ ' , @overageItem : ' + cast(@overageItem as varchar)
		+ ', @totItemScanned : ' + cast(@totItemScanned as varchar)
	if(@pickupTriggers = 1 and @tempItemID = 0)
	begin
		if(@totOrderItems = @totItemScanned and not exists (select 1 from [dbo].[Metropolitan$Event Master Log] eml where eml.[EventID] = 18 and eml.[Order Number] = @orderNo))-- [2021.11.05]
		begin
			print 'auto pickup'
			insert into @tmpAutoPickup([PickupCompletedDate],PickupScheduledDate,PickupCompletedEvtDate,PickupScheduledEvtDate,IsSuccess)
			exec Metro_WMA_AutoScheduleAndCompletePickup @orderNo, @pScanBy
		end
		else if (@totOrderItems = @totInbound and @pkpScheduled != 0 and not exists (select 1 from [dbo].[Metropolitan$Event Master Log] eml where eml.[EventID] = 18 and eml.[Order Number] = @orderNo))
		begin
			print 'PCNE'
			exec Metro_InsertUpdateOrderInfoEventTriggered 18, 0, 0, 0, @pScanBy, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @orderNo, @customerNo, '', '', ''
		end
	end

		-- Trigger event - Furniture Received by Metro-<Warehouse>-Hub
		set @totScannedInWH = (
				select	count(distinct [Barcode]) --count( [Barcode])[2021.11.15 tasleem]
				from	[dbo].[Metropolitan$Barcode Scan History] 
				where	[Order No] = @orderNo 
				and		[Location] = @whCode 
				and		[ManifestSource]=@pManifestSource
--				and		[Scan Type] = @pScanType -- need to discuss [2021.11.22 tasleem]
			)

				-- Total items scanne in manifest ...
		set @totScannedMF = (
				select	count(distinct [Barcode])
				from	(
							select	bsh.[Barcode]
									, [ScanType] = (
											select	top 1 BSH.[Scan Type] 
											from	[dbo].[Metropolitan$Barcode Scan History] BSH 
											where	BSH.ManifestID = mg.[ManifestId] 
											and		BSH.[Barcode] = sll.[Item Tracking No]
											order by BSH.[Entry No] desc
										)
							from	[dbo].[Metropolitan$Barcode Scan History] bsh
							join	[dbo].[Metropolitan$Sales Line Link] sll on sll.[Item Tracking No] = bsh.[Barcode] and sll.[Item Type] = 1 and sll.[Document Type] = 1 and bsh.[ManifestSource]=@pManifestSource
							join	[dbo].[Metropolitan$Manifest Group Items] mgi on mgi.[Item ID] = sll.[ID] and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
							join	[dbo].[Metropolitan$ManifestGroups] mg on mg.[ManifestGroupId] = mgi.[Manifest Group ID] and mg.[ManifestId] = @pManifestID
						) t
				where	ScanType = @pScanType
			)

		

		if (@pickupTriggers = 1 and @totOrderItems = @totScannedInWH and not exists (select 1 from [dbo].[Metropolitan$Event Master Log] eml where eml.[EventID] = 23 and eml.[Order Number] = @orderNo and Warehouse = @whCode))
		begin
			exec Metro_InsertUpdateOrderInfoEventTriggered 23, 0, 0, 0, @pScanBy, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @orderNo, @customerNo, '', '', ''
	

		-- Trigger event - Reached Delivery Hub
		if (@destWHCode = @whCode and @tempItemID = 0)
		begin
			exec Metro_InsertUpdateOrderInfoEventTriggered 107, 0, 0, 0, @pScanBy, 1, '30000', 'InboundScanning/ScanItem/SaveBarcodeItem', 'Warehouse App User', @orderNo, @customerNo, '', '', ''
		end
		end
	-- Order Moved to Storage event not required as it was removed in original code on 2020.06.12
	end
end

set @overageItem = 
(
				select	count(distinct BSH.[Barcode])
				from	[dbo].[Metropolitan$Barcode Scan History] BSH 
				where	BSH.ManifestID = @pManifestID
				and		BSH.[Barcode] not in (
					select	sll.[Item Tracking No]
					from	[dbo].[Metropolitan$Manifest Group Items] mgi
					join	[dbo].[Metropolitan$Sales Line Link] sll on sll.ID = mgi.[Item ID]  
					join	[dbo].[Metropolitan$ManifestGroups] mg on mgi.[Manifest Group ID] = mg.[ManifestGroupId] and mg.[Active Status] = 1 
					where mg.[ManifestId] = @pManifestID
					and mgi.[Active Status] = 1 and mgi.[Is Stop Defined] = 1
					group by sll.[Item Tracking No]
					)
			)

select	* 
from	(
			select	[OrderNo] = isnull(@orderNo, '')
					, [ScanText] = isnull(@scanText,'')
					, [ResultMsg] = isnull(@msg,'')
					, [Status] = isnull(@status,0)
					, [TotalItems] = case when @pScanAny = 0 and @pScanType = 20000 then isnull(@totItemsMF,0) + isnull(@overageItem,0) else isnull(@totItemsMF,0) end
					, [Scanned] = isnull(@totScannedMF,0)
					, [Pending] = isnull((@totItemsMF - @totScannedMF),0)
					, [WarehouseName] = isnull(@whName,'')
					, [ErrorID] = isnull(@errorID,0)
					, [OverageItems] = isnull(@overageItem,0)
					, [BarcodeScanEntryNo] = @barcodeScanEntryNo
					, [ImageCount] = (
											select	count(1)
											from	[dbo].[Metropolitan$Image] img with (nolock)
											where	img.[Ref No_] = cast(@barcodeScanEntryNo as varchar)
											and		img.[Order No] = @orderNo
										)
		) t
end
END
GO
