USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Manifest_Assigned_To_User]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- select [dbo].[F_Is_Manifest_Assigned_To_User](48328, 3272)
-- ======================================================================================

CREATE FUNCTION [dbo].[F_Is_Manifest_Assigned_To_User]
(
	@ManifestID int,
	@UserID int
)
RETURNS bit
AS

BEGIN
	
	Declare @ReturnCode bit = 0

	select @ReturnCode = ReturnCode from [POMS_DB].[dbo].[F_Is_Manifest_Assigned_To_User_List] (@ManifestID, @UserID)

	return @ReturnCode

END
GO
