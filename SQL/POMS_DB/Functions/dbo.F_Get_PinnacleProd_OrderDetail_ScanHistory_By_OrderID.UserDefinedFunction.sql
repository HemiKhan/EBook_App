USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_ScanHistory_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_ScanHistory_By_OrderID] (3652511,'ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_ScanHistory_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([OrderID] int
, [EntryNo] int
, [ScanTime] datetime
, [ScanBy] nvarchar(150)
, [Barcode] nvarchar(20)
, [Location] nvarchar(20)
, [ManifestID] nvarchar(50)
, [Device] nvarchar(20)
, [ScanType] nvarchar(50)
, [WarehouseName] nvarchar(50)
, [ImageCount] int
, [Section] nvarchar(20)
, TotalRecords int
)
AS
begin
	
	Declare @TotalRecords int = 0
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	if @GetRecordType_MTV_ID in (147103,147105)
	begin
		select @TotalRecords = (@TotalRecords + count(bsh.[Entry No])) from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) where bsh.[Order No] = @ORDER_NO

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [EntryNo] , [ScanTime] , [ScanBy] , [Barcode] , [Location] , [ScanType] , [Device] , [WarehouseName] , [ManifestID] , [ImageCount] , [Section] , TotalRecords)
			select [OrderID] = @ORDER_ID
				, [EntryNo] = bsh.[Entry No]
				, [ScanTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (bsh.[Scan Time],@TimeZone_ID,null,@TimeZoneName)
				, [ScanBy] = afn.FullName
				, [Barcode] = bsh.[Barcode]
				, [Location] = case 
						when (isnull(bsh.[Location ID], '') = '' and bsh.[Scan Type] = 50000 and bsh.[ManifestID] <> 0) then isnull(mtl.[Name], '')
						when isnull(bsh.[Location ID], '') = '' then isnull(bsh.[GoogleAddress], '')
						else isnull(bsh.[Location ID], '')
					end
				, [ScanType] = isnull((select top 1 mtv.[Description] from	[PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10150 and mtv.[ID] = bsh.[Scan Type]),'')
					+ (case when bsh.[ScanAnytime] = 1 then ' (Any)' else '' end)
					+ (case when (bsh.[Scan Type] = 50000 and bsh.[AutoScan] = 1) then ' (Auto)' else '' end)
				, [DeviceID] = bsh.[Device ID]
				, [WarehouseName] = [POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (bsh.[Location])
				, [ManifestID] = case
						when bsh.[ManifestID] = 0 then ''
						else cast(bsh.[ManifestID] as nvarchar(20)) + ' ' + case bsh.[ManifestSource] when 10000 then '(LH)' when 20000 then '(FM)' when 40000 then '(PU)' else '' end
					 end 
				, [ImageCount] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock) where img.[Ref No_] = cast(bsh.[Entry No] as nvarchar(20)) and img.[Order No] = bsh.[Order No])
				, [Section] = (select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv where mtv.[Master Type ID] = 10730 and mtv.[ID] = loc.WHSection)
				, TotalRecords = @TotalRecords
			from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock)
			left join [PinnacleProd].[dbo].[Metropolitan$Manifest] msh with (nolock) on msh.[Entry No] = bsh.[ManifestID]
			left join [PinnacleProd].[dbo].[Metropolitan$Truck Location] mtl with (nolock) on mtl.[Entry No] = msh.[Truck Id]
			left join [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] loc with(nolock) on loc.[Code] = bsh.[Location ID]
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (bsh.[Scan By]) afn
			where bsh.[Order No] = @ORDER_NO
		end

		if @GetRecordType_MTV_ID in (147105)
		begin
			Declare @TempTotalRecords int = 0
			select @TempTotalRecords = (@TempTotalRecords + count(bsh.[Entry No])) from [PinnacleArchiveDB].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) where bsh.[Order No] = @ORDER_NO

			if @TempTotalRecords > 0
			begin
				set @TotalRecords = @TotalRecords + @TempTotalRecords
				insert into @ReturnTable ([OrderID] , [EntryNo] , [ScanTime] , [ScanBy] , [Barcode] , [Location] , [ScanType] , [Device] , [WarehouseName] , [ManifestID] , [ImageCount] , [Section] , TotalRecords)
				select [OrderID] = @ORDER_ID
					, [EntryNo] = bsh.[Entry No]
					, [ScanTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (bsh.[Scan Time],@TimeZone_ID,null,@TimeZoneName)
					, [ScanBy] = afn.FullName
					, [Barcode] = bsh.[Barcode]
					, [Location] = case 
							when (isnull(bsh.[Location ID], '') = '' and bsh.[Scan Type] = 50000 and bsh.[ManifestID] <> 0) then isnull(mtl.[Name], '')
							when isnull(bsh.[Location ID], '') = '' then isnull(bsh.[GoogleAddress], '')
							else isnull(bsh.[Location ID], '')
						end
					, [ScanType] = isnull((select top 1 mtv.[Description] from	[PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10150 and mtv.[ID] = bsh.[Scan Type]),'')
						+ (case when bsh.[ScanAnytime] = 1 then ' (Any)' else '' end)
						+ (case when (bsh.[Scan Type] = 50000 and bsh.[AutoScan] = 1) then ' (Auto)' else '' end)
					, [DeviceID] = bsh.[Device ID]
					, [WarehouseName] = [POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (bsh.[Location])
					, [ManifestID] = case
							when bsh.[ManifestID] = 0 then ''
							else cast(bsh.[ManifestID] as nvarchar(20)) --+ ' ' + case bsh.[ManifestSource] when 10000 then '(LH)' when 20000 then '(FM)' when 40000 then '(PU)' else '' end
						 end 
					, [ImageCount] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock) where img.[Ref No_] = cast(bsh.[Entry No] as nvarchar(20)) and img.[Order No] = bsh.[Order No])
					, [Section] = (select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv where mtv.[Master Type ID] = 10730 and mtv.[ID] = loc.WHSection)
					, TotalRecords = @TotalRecords
				from [PinnacleArchiveDB].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock)
				left join [PinnacleProd].[dbo].[Metropolitan$Manifest] msh with (nolock) on msh.[Entry No] = bsh.[ManifestID]
				left join [PinnacleProd].[dbo].[Metropolitan$Truck Location] mtl with (nolock) on mtl.[Entry No] = msh.[Truck Id]
				left join [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] loc with(nolock) on loc.[Code] = bsh.[Location ID]
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (bsh.[Scan By]) afn
				where bsh.[Order No] = @ORDER_NO
			end
		end
	end
	else if @GetRecordType_MTV_ID in (147104)
	begin
		select @TotalRecords = (@TotalRecords + count(bsh.[Entry No])) from [PinnacleArchiveDB].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock) where bsh.[Order No] = @ORDER_NO

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [EntryNo] , [ScanTime] , [ScanBy] , [Barcode] , [Location] , [ScanType] , [Device] , [WarehouseName] , [ManifestID] , [ImageCount] , [Section] , TotalRecords)
			select [OrderID] = @ORDER_ID
				, [EntryNo] = bsh.[Entry No]
				, [ScanTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (bsh.[Scan Time],@TimeZone_ID,null,@TimeZoneName)
				, [ScanBy] = afn.FullName
				, [Barcode] = bsh.[Barcode]
				, [Location] = case 
						when (isnull(bsh.[Location ID], '') = '' and bsh.[Scan Type] = 50000 and bsh.[ManifestID] <> 0) then isnull(mtl.[Name], '')
						when isnull(bsh.[Location ID], '') = '' then isnull(bsh.[GoogleAddress], '')
						else isnull(bsh.[Location ID], '')
					end
				, [ScanType] = isnull((select top 1 mtv.[Description] from	[PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10150 and mtv.[ID] = bsh.[Scan Type]),'')
					+ (case when bsh.[ScanAnytime] = 1 then ' (Any)' else '' end)
					+ (case when (bsh.[Scan Type] = 50000 and bsh.[AutoScan] = 1) then ' (Auto)' else '' end)
				, [DeviceID] = bsh.[Device ID]
				, [WarehouseName] = [POMS_DB].[dbo].[F_Get_PinnacleHubName_From_HubCode] (bsh.[Location])
				, [ManifestID] = case
						when bsh.[ManifestID] = 0 then ''
						else cast(bsh.[ManifestID] as nvarchar(20)) --+ ' ' + case bsh.[ManifestSource] when 10000 then '(LH)' when 20000 then '(FM)' when 40000 then '(PU)' else '' end
						end 
				, [ImageCount] = (select count(1) from [PinnacleProd].[dbo].[Metropolitan$Image] img with (nolock) where img.[Ref No_] = cast(bsh.[Entry No] as nvarchar(20)) and img.[Order No] = bsh.[Order No])
				, [Section] = (select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv where mtv.[Master Type ID] = 10730 and mtv.[ID] = loc.WHSection)
				, TotalRecords = @TotalRecords
			from [PinnacleArchiveDB].[dbo].[Metropolitan$Barcode Scan History] bsh with (nolock)
			left join [PinnacleProd].[dbo].[Metropolitan$Manifest] msh with (nolock) on msh.[Entry No] = bsh.[ManifestID]
			left join [PinnacleProd].[dbo].[Metropolitan$Truck Location] mtl with (nolock) on mtl.[Entry No] = msh.[Truck Id]
			left join [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] loc with(nolock) on loc.[Code] = bsh.[Location ID]
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (bsh.[Scan By]) afn
			where bsh.[Order No] = @ORDER_NO
		end
	end

	return
	

end
GO
