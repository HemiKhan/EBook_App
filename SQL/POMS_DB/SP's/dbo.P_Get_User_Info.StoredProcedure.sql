USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_User_Info]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abdullah>
-- Create date: <07-31-2021>
-- Description:	<Get User Information>
-- [dbo].[P_Get_User_Info] 'PPLUSAPI.USER',148115
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_User_Info]
	-- Add the parameters for the stored procedure here
	@UserName nvarchar(100)
	,@ApplicationID int
	
AS
BEGIN
	
	Set @UserName = upper(isnull(@UserName,''))

	Declare @Usertable table
	(
		[User_ID] int
		,[UserName] nvarchar(150)
		,[FullName] nvarchar(250)
		,[Designation] nvarchar(150)
		,[DepartmentID] int
		,[DepartmentName] nvarchar(150)
		,[IsAdmin] bit
		,[IsBlocked] bit
		,[TempBlockTillDateTime] datetime
		,[PasswordExpiryDateTime] datetime
		,[TimeRegion] nvarchar(50)
		,[TimeRegionShortName] nvarchar(10)
		,[TimeZoneID] int
		,[TimeOffset] int
		,[NavUserName] nvarchar(150)
		,[NavApproverUserName] nvarchar(150)
		,[UserTypeMTVCode] nvarchar(20)
		,[RoleID] int
		,[IsGroupRoleID] int
		,[IsApplicationAccessAllowed] bit
		,[IsAPIAccessAllowed] bit
		,[PasswordHash] nvarchar(250)
		,[PasswordSalt] nvarchar(250)
	)

	if (@ApplicationID = 148104)
	begin
		insert into @Usertable ([User_ID] ,[UserName] ,[FullName] ,[Designation] ,[DepartmentID] ,[DepartmentName] ,[IsAdmin] ,[IsBlocked] ,[TempBlockTillDateTime] ,[PasswordExpiryDateTime] ,[TimeRegion] 
		,[TimeRegionShortName] ,[TimeZoneID] ,[TimeOffset] ,[NavUserName] ,[NavApproverUserName] ,[UserTypeMTVCode] ,[RoleID] ,[IsGroupRoleID] ,[IsApplicationAccessAllowed] ,[IsAPIAccessAllowed] ,[PasswordHash] ,[PasswordSalt])
		Select [USER_ID] ,u.[USERNAME]
		,FullName = (case when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.MiddleName + ' ' + u.LastName
		when isnull(u.FirstName,'') = '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.MiddleName + ' ' + u.LastName
		when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') = '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.LastName
		when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') = '' then u.FirstName + ' ' + u.MiddleName
		else u.USERNAME end)
		,[Designation]
		,[DepartmentID] = u.D_ID
		,[DepartmentName] = (select top 1 d.DepartmentName from [POMS_DB].[dbo].[T_Department] d with (nolock) where d.D_ID = u.D_ID) 
		,[IsAdmin] = cast((case when isnull(urm.ROLE_ID,0) in (12,16) then 1 else 0 end) as bit)
		,[IsBlocked] = cast((case when u.BlockType_MTV_ID <> 149100 then 1 else 0 end) as bit)
		,u.[TempBlockTillDateTime]
		,u.[PasswordExpiryDateTime]
		,[TimeRegion] = isnull(tzl.TimeZoneDisplay,'Eastern Time (US & Canada)')
		,[TimeRegionShortName] = isnull(tzl.TimeZoneAbbreviation,'EST')
		,[TimeZoneID] = (case when tzl.TimeZoneDisplay is null then 13 else u.TIMEZONE_ID end)
		,[TimeOffset] = isnull(tzl.Offset,-18000000)
		,[NavUserName] = ''
		,[NavApproverUserName] = ''
		,[UserTypeMTVCode] = u.UserType_MTV_CODE
		,[RoleID] = isnull(urm.ROLE_ID,0)
		,[IsGroupRoleID] = isnull(urm.IsGroupRoleID,0)
		,[IsApplicationAccessAllowed] = isnull(uaa.IsActive,0)
		,[IsAPIAccessAllowed] = u.IsAPIUser
		,[PasswordHash] = u.PasswordHash
		,[PasswordSalt] = u.PasswordSalt
		from [POMS_DB].[dbo].[T_Users] u with (nolock)
		left join [POMS_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) on u.USERNAME = urm.USERNAME
		left join [POMS_DB].[dbo].[T_User_Application_Access] uaa with (nolock) on u.USERNAME = uaa.USERNAME and uaa.Application_MTV_ID = @ApplicationID and uaa.IsActive = 1 -- Pinnacle
		left join [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) on u.TIMEZONE_ID = tzl.TIMEZONE_ID
		where u.USERNAME = @UserName
	end
	else --if (@ApplicationID = 148107)
	begin
		insert into @Usertable ([User_ID] ,[UserName] ,[FullName] ,[Designation] ,[DepartmentID] ,[DepartmentName] ,[IsAdmin] ,[IsBlocked] ,[TempBlockTillDateTime] ,[PasswordExpiryDateTime] ,[TimeRegion] 
		,[TimeRegionShortName] ,[TimeZoneID] ,[TimeOffset] ,[NavUserName] ,[NavApproverUserName] ,[UserTypeMTVCode] ,[RoleID] ,[IsGroupRoleID] ,[IsApplicationAccessAllowed] ,[IsAPIAccessAllowed] ,[PasswordHash] ,[PasswordSalt])
		Select [USER_ID] ,u.[USERNAME]
		,FullName = (case when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.MiddleName + ' ' + u.LastName
		when isnull(u.FirstName,'') = '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.MiddleName + ' ' + u.LastName
		when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') = '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.LastName
		when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') = '' then u.FirstName + ' ' + u.MiddleName
		else u.USERNAME end)
		,[Designation]
		,[DepartmentID] = u.D_ID
		,[DepartmentName] = (select top 1 d.DepartmentName from [POMS_DB].[dbo].[T_Department] d with (nolock) where d.D_ID = u.D_ID) 
		,[IsAdmin] = cast((case when isnull(urm.ROLE_ID,0) in (12,16) then 1 else 0 end) as bit)
		,[IsBlocked] = cast((case when u.BlockType_MTV_ID <> 149100 then 1 else 0 end) as bit)
		,u.[TempBlockTillDateTime]
		,u.[PasswordExpiryDateTime]
		,[TimeRegion] = isnull(tzl.TimeZoneDisplay,'Eastern Time (US & Canada)')
		,[TimeRegionShortName] = isnull(tzl.TimeZoneAbbreviation,'EST')
		,[TimeZoneID] = (case when tzl.TimeZoneDisplay is null then 13 else u.TIMEZONE_ID end)
		,[TimeOffset] = isnull(tzl.Offset,-18000000)
		,[NavUserName] = ''
		,[NavApproverUserName] = ''
		,[UserTypeMTVCode] = u.UserType_MTV_CODE
		,[RoleID] = isnull(urm.ROLE_ID,0)
		,[IsGroupRoleID] = isnull(urm.IsGroupRoleID,0)
		,[IsApplicationAccessAllowed] = isnull(uaa.IsActive,0)
		,[IsAPIAccessAllowed] = u.IsAPIUser
		,[PasswordHash] = u.PasswordHash
		,[PasswordSalt] = u.PasswordSalt
		from [POMS_DB].[dbo].[T_Users] u with (nolock)
		left join [POMS_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) on u.USERNAME = urm.USERNAME
		left join [POMS_DB].[dbo].[T_User_Application_Access] uaa with (nolock) on u.USERNAME = uaa.USERNAME and uaa.Application_MTV_ID = @ApplicationID and uaa.IsActive = 1 -- All
		left join [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) on u.TIMEZONE_ID = tzl.TIMEZONE_ID
		where u.USERNAME = @UserName
	end

	select * from @Usertable

END
GO
