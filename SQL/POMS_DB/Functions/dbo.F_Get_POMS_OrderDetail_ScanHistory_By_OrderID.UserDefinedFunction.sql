USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_ScanHistory_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_ScanHistory_By_OrderID] (3652511,'ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_ScanHistory_By_OrderID]
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

	if @GetRecordType_MTV_ID in (147100)
	begin
		select @TotalRecords = (@TotalRecords + count(ois.OIS_ID)) from [POMS_DB].[dbo].[T_Order_Item_Scans] ois with (nolock) where ois.[ORDER_ID] = @ORDER_ID

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [EntryNo] , [ScanTime] , [ScanBy] , [Barcode] , [Location] , [ScanType] , [Device] , [WarehouseName] , [ManifestID] , [ImageCount] , [Section] , TotalRecords)
			select [OrderID] = ois.ORDER_ID
				, [EntryNo] = ois.OIS_ID
				, [ScanTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ois.ScanTime,@TimeZone_ID,null,@TimeZoneName)
				, [ScanBy] = afn.FullName
				, [Barcode] = ois.BARCODE
				, [Location] = case 
						when (isnull(ois.LOCATION_ID, '') = '' and ois.ScanType_MTV_ID = 50000 and ois.MANIFEST_ID <> 0) then ''--isnull(mtl.[Name], '')
						when isnull(ois.LOCATION_ID, '') = '' then ''--isnull(bsh.[GoogleAddress], '')
						else isnull(ois.LOCATION_ID, '')
					end
				, [ScanType] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ois.ScanType_MTV_ID)
					+ (case when ois.ScanAnytime = 1 then ' (Any)' else '' end)
					+ (case when (ois.ScanType_MTV_ID = 50000 and ois.AutoScan = 1) then ' (Auto)' else '' end)
				, [DeviceID] = ois.DeviceCode_MTV_CODE
				, [WarehouseName] = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (ois.HUB_CODE)
				, [ManifestID] = case when ois.MANIFEST_ID = 0 then '' else cast(ois.MANIFEST_ID as nvarchar(20)) + [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ois.ManifestType_MTV_ID)  end 
				, [ImageCount] = (select count(od.OD_ID) from [POMS_DB].[dbo].[T_Order_Docs] od with (nolock) where od.RefID = ois.OIS_ID and od.[ORDER_ID] = ois.[ORDER_ID])
				, [Section] = (select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv where mtv.[Master Type ID] = 10730 and mtv.[ID] = loc.WHSection)
				, TotalRecords = @TotalRecords
			from [POMS_DB].[dbo].[T_Order_Item_Scans] ois with (nolock)
			left join [PinnacleProd].[dbo].[Metropolitan$Manifest] msh with (nolock) on msh.[Entry No] = ois.MANIFEST_ID
			left join [PinnacleProd].[dbo].[Metropolitan$Truck Location] mtl with (nolock) on mtl.[Entry No] = msh.[Truck Id]
			left join [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] loc with(nolock) on loc.[Code] = ois.LOCATION_ID collate database_default
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (ois.ScanBy) afn
			where ois.[ORDER_ID] = @ORDER_ID
		end

		if @GetRecordType_MTV_ID in (147102)
		begin
			Declare @TempTotalRecords int = 0
			select @TempTotalRecords = (@TempTotalRecords + count(ois.OIS_ID)) from [POMSArchive_DB].[dbo].[T_Order_Item_Scans] ois with (nolock) where ois.[ORDER_ID] = @ORDER_ID

			if @TempTotalRecords > 0
			begin
				set @TotalRecords = @TotalRecords + @TempTotalRecords
				insert into @ReturnTable ([OrderID] , [EntryNo] , [ScanTime] , [ScanBy] , [Barcode] , [Location] , [ScanType] , [Device] , [WarehouseName] , [ManifestID] , [ImageCount] , [Section] , TotalRecords)
				select [OrderID] = ois.ORDER_ID
					, [EntryNo] = ois.OIS_ID
					, [ScanTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ois.ScanTime,@TimeZone_ID,null,@TimeZoneName)
					, [ScanBy] = afn.FullName
					, [Barcode] = ois.BARCODE
					, [Location] = case 
							when (isnull(ois.LOCATION_ID, '') = '' and ois.ScanType_MTV_ID = 50000 and ois.MANIFEST_ID <> 0) then ''--isnull(mtl.[Name], '')
							when isnull(ois.LOCATION_ID, '') = '' then ''--isnull(bsh.[GoogleAddress], '')
							else isnull(ois.LOCATION_ID, '')
						end
					, [ScanType] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ois.ScanType_MTV_ID)
						+ (case when ois.ScanAnytime = 1 then ' (Any)' else '' end)
						+ (case when (ois.ScanType_MTV_ID = 50000 and ois.AutoScan = 1) then ' (Auto)' else '' end)
					, [DeviceID] = ois.DeviceCode_MTV_CODE
					, [WarehouseName] = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (ois.HUB_CODE)
					, [ManifestID] = case when ois.MANIFEST_ID = 0 then '' else cast(ois.MANIFEST_ID as nvarchar(20)) + [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ois.ManifestType_MTV_ID)  end 
					, [ImageCount] = (select count(od.OD_ID) from [POMS_DB].[dbo].[T_Order_Docs] od with (nolock) where od.RefID = ois.OIS_ID and od.[ORDER_ID] = ois.[ORDER_ID])
					, [Section] = (select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv where mtv.[Master Type ID] = 10730 and mtv.[ID] = loc.WHSection)
					, TotalRecords = @TotalRecords
				from [POMSArchive_DB].[dbo].[T_Order_Item_Scans] ois with (nolock)
				left join [PinnacleProd].[dbo].[Metropolitan$Manifest] msh with (nolock) on msh.[Entry No] = ois.MANIFEST_ID
				left join [PinnacleProd].[dbo].[Metropolitan$Truck Location] mtl with (nolock) on mtl.[Entry No] = msh.[Truck Id]
				left join [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] loc with(nolock) on loc.[Code] = ois.LOCATION_ID collate database_default
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (ois.ScanBy) afn
				where ois.[ORDER_ID] = @ORDER_ID
			end
		end
	end
	else if @GetRecordType_MTV_ID in (147101)
	begin
		select @TotalRecords = (@TempTotalRecords + count(ois.OIS_ID)) from [POMSArchive_DB].[dbo].[T_Order_Item_Scans] ois with (nolock) where ois.[ORDER_ID] = @ORDER_ID

		if @TotalRecords > 0
		begin
			set @TotalRecords = @TotalRecords + @TempTotalRecords
			insert into @ReturnTable ([OrderID] , [EntryNo] , [ScanTime] , [ScanBy] , [Barcode] , [Location] , [ScanType] , [Device] , [WarehouseName] , [ManifestID] , [ImageCount] , [Section] , TotalRecords)
			select [OrderID] = ois.ORDER_ID
				, [EntryNo] = ois.OIS_ID
				, [ScanTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ois.ScanTime,@TimeZone_ID,null,@TimeZoneName)
				, [ScanBy] = afn.FullName
				, [Barcode] = ois.BARCODE
				, [Location] = case 
						when (isnull(ois.LOCATION_ID, '') = '' and ois.ScanType_MTV_ID = 50000 and ois.MANIFEST_ID <> 0) then ''--isnull(mtl.[Name], '')
						when isnull(ois.LOCATION_ID, '') = '' then ''--isnull(bsh.[GoogleAddress], '')
						else isnull(ois.LOCATION_ID, '')
					end
				, [ScanType] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ois.ScanType_MTV_ID)
					+ (case when ois.ScanAnytime = 1 then ' (Any)' else '' end)
					+ (case when (ois.ScanType_MTV_ID = 50000 and ois.AutoScan = 1) then ' (Auto)' else '' end)
				, [DeviceID] = ois.DeviceCode_MTV_CODE
				, [WarehouseName] = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (ois.HUB_CODE)
				, [ManifestID] = case when ois.MANIFEST_ID = 0 then '' else cast(ois.MANIFEST_ID as nvarchar(20)) + [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (ois.ManifestType_MTV_ID)  end 
				, [ImageCount] = (select count(od.OD_ID) from [POMS_DB].[dbo].[T_Order_Docs] od with (nolock) where od.RefID = ois.OIS_ID and od.[ORDER_ID] = ois.[ORDER_ID])
				, [Section] = (select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv where mtv.[Master Type ID] = 10730 and mtv.[ID] = loc.WHSection)
				, TotalRecords = @TotalRecords
			from [POMSArchive_DB].[dbo].[T_Order_Item_Scans] ois with (nolock)
			left join [PinnacleProd].[dbo].[Metropolitan$Manifest] msh with (nolock) on msh.[Entry No] = ois.MANIFEST_ID
			left join [PinnacleProd].[dbo].[Metropolitan$Truck Location] mtl with (nolock) on mtl.[Entry No] = msh.[Truck Id]
			left join [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] loc with(nolock) on loc.[Code] = ois.LOCATION_ID collate database_default
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (ois.ScanBy) afn
			where ois.[ORDER_ID] = @ORDER_ID
		end
	end

	return
	

end
GO
