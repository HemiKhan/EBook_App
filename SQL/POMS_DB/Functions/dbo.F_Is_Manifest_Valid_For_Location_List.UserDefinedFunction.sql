USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Manifest_Valid_For_Location_List]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- select * from [POMS_DB].[dbo].[F_Is_Manifest_Valid_For_Location_List] ('IN-NC', 32571, 0, '50000,30000', 10000, null)
-- ======================================================================================

CREATE FUNCTION [dbo].[F_Is_Manifest_Valid_For_Location_List]
(
	@LocationID nvarchar(20)
	,@ManifestID int
	,@Type int --(0. Origin, 1. Destination)
	,@Status nvarchar(50) --'50000,30000' comma-delimited list of manifest status IDs
	,@ManifestSource int --10000 - LH, 30000 - FM, 40000 - PU
	,@HubCode nvarchar(20) = null

)
RETURNS @ReturnTable TABLE 
(ReturnCode bit, ReturnText nvarchar(250))
AS

BEGIN

	Declare @ReturnCode bit = 0
	Declare @ReturnText nvarchar(250) = ''
	set @ManifestID = isnull(@ManifestID,0)
	set @LocationID = upper(@LocationID)

	set @ManifestSource = isnull(@ManifestSource,0)

	if @HubCode is null
	begin
		set @HubCode = isnull((select top 1 [Warehouse ID] from [PinnacleProd].[dbo].[Metropolitan$Warehouse Location Entry] with (nolock) where upper([Code]) = @LocationID) ,'')
	end

	if @HubCode = ''
	begin
		set @ReturnText = 'Invalid Location ID'
	end

	if @ManifestSource = 10000 and @ReturnText = ''
	begin
		Set @ReturnCode = (case when exists(select 1 from [PinnacleProd].[dbo].[Metropolitan$Manifest] with (nolock)
							where [Entry No] = @ManifestID and ((@Type = 0 and [OrgHubCode] = @HubCode) or (@Type = 1 and [DestHubCode] = @hubCode))
							and	[Status] in (select id from dbo.SplitIntoTable(@Status))) then 1 else 0 end)
		set @ReturnText = (case when @ReturnCode = 0 then 'Line Haul Manifest Not Found' else @ReturnText end)
	end
	else if @ManifestSource = 30000 and @ReturnText = ''
	begin
		Set @ReturnCode = (case when exists(select 1 from [PPlus_DB].[dbo].[T_Manifest] with (nolock)
							where [MIN_ID] = @ManifestID and [Hub] = @HubCode and [ExportednuVizz] = 1 and isnull(OB_Scan_Complete ,0)=0) then 1 else 0 end)
		set @ReturnText = (case when @ReturnCode = 0 then 'Final Mile Manifest Not Found' else @ReturnText end)
	end
	else if @ManifestSource = 40000 and @ReturnText = ''
	begin
		Set @ReturnCode = (case when exists(select 1 from [PPlus_DB].[dbo].[T_ManifestPU] with (nolock)
							where [MIN_ID] = @ManifestID and [Hub] = @HubCode and [Status]=1000200) then 1 else 0 end)
		set @ReturnText = (case when @ReturnCode = 0 then 'Pickup Manifest Not Found' else @ReturnText end)
	end

	insert into @ReturnTable (ReturnCode, ReturnText)
	values (@ReturnCode,@ReturnText)

	return
	
END
GO
