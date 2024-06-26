USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Valid_Manifest]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Is_Valid_Manifest]  
(
	@ManifestType int
	,@HubCode nvarchar(20)
	,@ScanType int
	,@ManifestID int
	,@Barcode nvarchar(20)

)
RETURNS int
AS
BEGIN
	
	--	ID		Name
	--	1		Manifest Exists
	--	2		Barcode Exists
	--	3		Manifest Not Exists
	--	4		Barcode Not Exists

	Declare @ReturnCode int = 0

	Declare @ReturnTable table
	([ManifestID] int
	, [OrderNo] nvarchar(20)
	, [TrackingNo] nvarchar(20)
	, [ScanType] int)

	if @ManifestType in (10000)
	begin
		insert into @ReturnTable ([ManifestID] , [OrderNo] , [TrackingNo] , [ScanType] )
		select distinct
			[ManifestNo] = M.[Entry No]
			, [OrderNo] = MSH.[No_]
			, [TrackingNo] = MSLL.[Item Tracking No]
			, [ScanType] = isnull((select top 1 BSH.[Scan Type] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH with (nolock) 
				where BSH.ManifestID = M.[Entry No] and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)
			from [PinnacleProd].[dbo].[Metropolitan$Sales Header] MSH
			inner join [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
			inner join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] MGI on MGI.[Item ID] = MSLL.[ID] and	MGI.[Is Stop Defined] = 1 and MGI.[Active Status] = 1
			left join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] MG on MGI.[Manifest Group ID]= MG.[ManifestGroupId]
			left join [PinnacleProd].[dbo].[Metropolitan$Manifest] M on M.[Entry No] = MG.[ManifestId]
			left join [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@ManifestType 
			where M.[Entry No] = @ManifestID and BSH.[ManifestSource]=@ManifestType
	end
	else if @ManifestType in (30000)
	begin
		insert into @ReturnTable ([ManifestID] , [OrderNo] , [TrackingNo] , [ScanType] )
		select distinct 
			[ManifestNo] = M.[MIN_ID]
			, [OrderNo] = MSH.[No_]
			, [TrackingNo]= MSLL.[Item Tracking No]
			, [ScanType] = isnull((select top 1 BSH.[Scan Type] from [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH 
				where BSH.ManifestID = M.[MIN_ID] and BSH.[Barcode] = MSLL.[Item Tracking No] order by [Entry No] desc), 0)
			from [PinnacleProd].[dbo].[Metropolitan$Sales Header] MSH
			inner join [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] MSLL on MSLL.[Sales Order No] = MSH.[No_]
			inner join [PPlus_DB].[dbo].[T_ManifestPU_Stop_Item] MSO with (nolock) on cast(MSO.[Order_No] as varchar) = MSLL.[Sales Order No]
			left join [PPlus_DB].[dbo].[T_ManifestPU_Stop] MS on MS.[MpS_ID]=MSO.[MpS_ID]
			left join [PPlus_DB].[dbo].[T_ManifestPU] M on M.[MIN_ID] = MS.[MIN_ID]
			left join [PinnacleProd].[dbo].[Metropolitan$Barcode Scan History] BSH on BSH.Barcode = MSLL.[Item Tracking No] and BSH.[ManifestSource]=@ManifestType 
			where M.[MIN_ID] = @ManifestID  --
	end

	if exists(select * from @ReturnTable)
	begin
		set @ReturnCode = 1
		if exists(select * from @ReturnTable where [TrackingNo] = @Barcode)
		begin
			set @ReturnCode = 2
		end
		else
		begin
			set @ReturnCode = 4
		end
	end
	else
	begin
		set @ReturnCode = 3
	end

	return @ReturnCode
END
GO
