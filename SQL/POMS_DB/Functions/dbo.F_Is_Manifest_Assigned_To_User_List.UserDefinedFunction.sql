USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Manifest_Assigned_To_User_List]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- select * from [dbo].[F_Is_Manifest_Assigned_To_User_List](112084, 934)
-- ======================================================================================

CREATE FUNCTION [dbo].[F_Is_Manifest_Assigned_To_User_List]
(
	@ManifestID int,
	@UserID int
)
RETURNS @ReturnTable TABLE 
(ReturnCode bit, ReturnText nvarchar(250))
AS

BEGIN
	
	Declare @ReturnCode int = 0
	Declare @ReturnText nvarchar(250) = ''

	set @ManifestID = isnull(@ManifestID,0)
	set @UserID = isnull(@UserID,0)

	if (@ManifestID = 0)
	begin
		set @ReturnText = 'Manifest No is Required'
	end

	if (@UserID = 0)
	begin
		set @ReturnText = 'UserName is Required'
	end

	if (select [Partner] from [PinnacleProd].[dbo].[Metropolitan$Web User Login] with (nolock) where [Web UserID] = @UserID) = 0 and @ReturnText = ''
	begin
		set @ReturnCode = 1
	end
	else if exists(select 1 from [PinnacleProd].[dbo].[Metropolitan_UserGroup_Assignment] uga with (nolock) 
		where uga.[EntityTypeID] = 30000 -- 30000 = Manifest
		and	uga.[EntityID] = @ManifestID
		and	((uga.[IsGroup] = 0 and uga.[UserGroupID] = @UserID)
			or (uga.[IsGroup] = 1 and exists(select	1 from [PinnacleProd].[dbo].[Metropolitan_UserGroup_Members] ugm with (nolock) where ugm.[UserID] = @UserID and ugm.[GroupID] = uga.[UserGroupID]))
			)
		) and @ReturnText = ''
	begin
		set @ReturnCode = 1
	end
	else if @ReturnText = ''
	begin
		set @ReturnText = 'Manifest Not Assigned To User'
	end

	insert into @ReturnTable (ReturnCode, ReturnText)
	values (@ReturnCode,@ReturnText)

	return

END
GO
