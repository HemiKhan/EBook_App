USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Manifest_Valid_For_Location]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- select [POMS_DB].[dbo].[F_Is_Manifest_Valid_For_Location] ('IN-NC', 32571, 0, '50000,30000', 10000, null)
-- ======================================================================================

create FUNCTION [dbo].[F_Is_Manifest_Valid_For_Location]
(
	@LocationID nvarchar(20)
	,@ManifestID int
	,@Type int --(0. Origin, 1. Destination)
	,@Status nvarchar(50) --'50000,30000' comma-delimited list of manifest status IDs
	,@ManifestSource int --10000 - LH, 30000 - FM, 40000 - PU
	,@HubCode nvarchar(20) = null

)
RETURNS bit
AS

BEGIN

	Declare @ReturnCode bit = 0
	select @ReturnCode = ReturnCode from [POMS_DB].[dbo].[F_Is_Manifest_Valid_For_Location_List] (@LocationID,@ManifestID,@Type,@Status,@ManifestSource,@HubCode)

	return @ReturnCode
	
END
GO
