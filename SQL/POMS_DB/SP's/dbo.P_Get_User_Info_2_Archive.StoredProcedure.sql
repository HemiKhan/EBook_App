USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_User_Info_2_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abdullah>
-- Create date: <07-31-2021>
-- Description:	<Get User Information>
-- [dbo].[P_Get_User_Info_2] 'ABDULLAH.ARSHAD',10100
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_User_Info_2_Archive]
	-- Add the parameters for the stored procedure here
	@UserName nvarchar(100)
	,@ApplicationID int
	
AS
BEGIN
	
	Set @UserName = upper(@UserName)

	Declare @Usertable table
	(
		[USER_ID] nvarchar(50)
		,[S_Key] nvarchar(36)
		,[Full_Name] nvarchar(1000)
		,[Is_Admin] bit
		,[Is_Blocked] bit
		,[Is_Pinnacle_Blocked] bit
		,[Department] int
		,[EST_Offset] int
		,[Time_Region] nvarchar(50)
		,[Time_Region_Short_Name] nvarchar(10)
		,[Time_Region_TZ_ID] int
		,[Time_Offset] int
		,[User_Region] nvarchar(50)
		,[User_Region_Short_Name] nvarchar(10)
		,[User_Region_TZ_ID] int
		,[User_Offset] int
		,[Web_UserID] int
		,[Nav_User] nvarchar(50)
		,[Nav_Approver_User] nvarchar(100)
		,[Entity_Type] int
		,[Is_UseLocalTimeZone] bit
		,[Role_ID] int
		,[Theme_ID] int
		,[DOCThumnailsSize] nvarchar(20)
		,[POPThumnailsSize] nvarchar(20)
		,[PODThumnailsSize] nvarchar(20)
		,[Override_Feature] int
		,[Web_Role] nvarchar(250)
		,[EnableSchAllDates] bit
		,[EnableSchBackDate] bit
		,[EnableSchCurrentDate] bit
		,[IsApplicationAccessAllowed] bit
		--,[IsApplicationAccessAllowed] = cast((case when u.[USER_ID] is null then 0
		--	when cast(isnull(wul.[Blocked],0) as bit) = 1 then 0 
		--	else (case when u.Is_Blocked = 1 then 0 else 1 end) 
		--	end) as bit)
		,[IsAPIAccessAllowed] bit
		,[PasswordHash] nvarchar(250)
		,[PasswordSalt] nvarchar(250)
	)

	if (@ApplicationID = 10100)
	begin
		insert into @Usertable
		select 
		[USER_ID] = @UserName
		,[S_Key] = ''
		,[Full_Name] = (Case when isnull(wul.[First Name],'') = '' and isnull(wul.[Last Name],'') = ''then @UserName
		when isnull(wul.[First Name],'') <> '' and isnull(wul.[Last Name],'') = '' then wul.[First Name]
		when isnull(wul.[First Name],'') = '' and isnull(wul.[Last Name],'') <> '' then wul.[Last Name]
		when isnull(wul.[First Name],'') <> '' and isnull(wul.[Last Name],'') <> '' then ltrim(rtrim(wul.[First Name])) + ' ' + ltrim(rtrim(wul.[Last Name]))
		else @UserName end)
		,[Is_Admin] = cast((case when wul.[Web Role] in ('METRO','SUPER') then 1 else 0 end) as bit)
		,[Is_Blocked] = cast(isnull(wul.[Blocked],0) as bit)
		,[Is_Pinnacle_Blocked] = cast(isnull(wul.[Blocked],0) as bit)
		,[Department] = isnull(wul.[Department],'')
		,[EST_Offset] = isnull(DATEDIFF(Millisecond,GETDATE(),cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()),GETDATE()) as datetime)),0)
		,[Time_Region] = isnull(ntz.[Time Zone],'')
		,[Time_Region_Short_Name] = isnull(ntz.[Time Zone Abbreviation],'')
		,[Time_Region_TZ_ID] = isnull(wul.[Time Zone ID],0)
		,[Time_Offset] = cast(isnull(ntz.Offset,0) as int)
		,[User_Region] = isnull(ntz.[Time Zone],'')
		,[User_Region_Short_Name]=isnull(ntz.[Time Zone Abbreviation],'')
		,[User_Region_TZ_ID] = isnull(wul.[Time Zone ID],0)
		,[User_Offset] = cast(isnull(ntz.Offset,0) as int)
		,[Web_UserID] = cast(isnull(wul.[Web UserID],0) as int)
		,[Nav_User] = ''
		,[Nav_Approver_User] = ''
		,[Entity_Type] = isnull(wul.[Entity type],0)
		,[Is_UseLocalTimeZone] = 0
		,[Role_ID] = 0
		,[Theme_ID] = 0
		,[DOCThumnailsSize] = ''
		,[POPThumnailsSize] = ''
		,[PODThumnailsSize] = ''
		,[Override_Feature] = wul.[Override Feature]
		,[Web_Role] = wul.[Web Role]
		,[EnableSchAllDates] = 0
		,[EnableSchBackDate] = 0
		,[EnableSchCurrentDate] = 0
		,[IsApplicationAccessAllowed] = cast(1 as bit)
		--,[IsApplicationAccessAllowed] = cast((case when u.[USER_ID] is null then 0
		--	when cast(isnull(wul.[Blocked],0) as bit) = 1 then 0 
		--	else (case when u.Is_Blocked = 1 then 0 else 1 end) 
		--	end) as bit)
		,[IsAPIAccessAllowed] = cast(wul.[APIAccess] as bit)
		,[PasswordHash] = wul.[Password Hash]
		,[PasswordSalt] = wul.[Password Salt]
	
		from [PinnacleProd].[dbo].[Metropolitan$Web User Login] wul with (nolock) 
		left join [PPlus_DB].[dbo].[V_NAV_Time_Zone] ntz with (nolock) on wul.[Time Zone ID] = ntz.[Time Zone ID]
		where upper(rtrim(ltrim(wul.Username))) = @UserName
	end
	else
	begin
		insert into @Usertable
		select 
		[USER_ID] = u.[USER_ID]
		,[S_Key] = u.[S_Key]
		,[Full_Name] = (Case when isnull(wul.[First Name],'') = '' and isnull(wul.[Last Name],'') = ''then @UserName
		when isnull(wul.[First Name],'') <> '' and isnull(wul.[Last Name],'') = '' then wul.[First Name]
		when isnull(wul.[First Name],'') = '' and isnull(wul.[Last Name],'') <> '' then wul.[Last Name]
		when isnull(wul.[First Name],'') <> '' and isnull(wul.[Last Name],'') <> '' then ltrim(rtrim(wul.[First Name])) + ' ' + ltrim(rtrim(wul.[Last Name]))
		else @UserName end)
		,[Is_Admin] = cast((case when wul.[Web Role] in ('METRO','SUPER') and wul.[APIAccess] = 1 then 1 else isnull(u.[Is_Admin],0) end) as bit)
		,[Is_Blocked] = isnull(u.[Is_Blocked],1)
		,[Is_Pinnacle_Blocked] = cast(isnull(wul.[Blocked],0) as bit)
		,[Department] = isnull(wul.[Department],'')
		,[EST_Offset] = isnull(DATEDIFF(Millisecond,GETDATE(),cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()),GETDATE()) as datetime)),0)
		,[Time_Region] = isnull(ntz.[Time Zone],'')
		,[Time_Region_Short_Name] = isnull(ntz.[Time Zone Abbreviation],'')
		,[Time_Region_TZ_ID] = isnull(wul.[Time Zone ID],0)
		,[Time_Offset] = cast(isnull(ntz.Offset,0) as int)
		,[User_Region] = isnull(ntz.[Time Zone],'')
		,[User_Region_Short_Name]=isnull(ntz.[Time Zone Abbreviation],'')
		,[User_Region_TZ_ID] = isnull(wul.[Time Zone ID],0)
		,[User_Offset] = cast(isnull(ntz.Offset,0) as int)
		,[Web_UserID] = cast(isnull(wul.[Web UserID],0) as int)
		,[Nav_User] = isnull(wul.[Dynamics UserName],'')
		,[Nav_Approver_User] = (case when isnull(wul.[Dynamics UserName],'') = '' then '' else 
			isnull((Select top 1 [Approver ID] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Additional Approvers] with (nolock) where [Document Type] = 2 and [Approver ID] = upper(wul.[Dynamics UserName]) and [Approval Code] = 'S-INVOICE'),
			(SELECT (Case when us.[Approver ID] <> '' then us.[Approver ID] when us.[Substitute] <> '' then us.[Substitute] else (Select top 1 [Approver ID] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Additional Approvers] with (nolock) where [Document Type] = 2 and [Approval Code] = 'S-INVOICE' and [Approval Group No_] = us.[Approval Group No_]) end) FROM [MetroPolitanNavProduction].[dbo].[Metropolitan$User Setup] us with (nolock) where us.[User ID] = upper(wul.[Dynamics UserName])))
		end)
		,[Entity_Type] = isnull(wul.[Entity type],0)
		,[Is_UseLocalTimeZone] = isnull(u.[Is_UseLocalTimeZone],0)
		,[Role_ID] = cast(isnull(u.[Role_ID],0) as int)
		,[Theme_ID] = cast(isnull(u.[Theme_ID],1) as int)
		,[DOCThumnailsSize] = isnull(u.[DOCThumnailSize],'100')
		,[POPThumnailsSize] = isnull(u.[POPThumnailSize],'100')
		,[PODThumnailsSize] = isnull(u.[PODThumnailSize],'100')
		,[Override_Feature] = wul.[Override Feature]
		,[Web_Role] = wul.[Web Role]
		,[EnableSchAllDates] = (case when (wul.[Web UserID] = 2077 or wul.[Web Role] in ('SUPER','CAADMIN5')) then 1 else 0 end)
		,[EnableSchBackDate] = (case when (wul.[Override Feature] = 1 or wul.[Web Role] in ('ACC USER','ACC SUPERVISOR','ACCOUNTING','METRO','SUPER')) then 1 else 0 end)
		,[EnableSchCurrentDate] = (case when (wul.[Override Feature] = 1 or wul.[Web Role] in ('ACC USER','ACC SUPERVISOR','ACCOUNTING','METRO','SUPER')) then 1 else 0 end)
		,[IsApplicationAccessAllowed] = cast(1 as bit)
		--,[IsApplicationAccessAllowed] = cast((case when u.[USER_ID] is null then 0
		--	when cast(isnull(wul.[Blocked],0) as bit) = 1 then 0 
		--	else (case when u.Is_Blocked = 1 then 0 else 1 end) 
		--	end) as bit)
		,[IsAPIAccessAllowed] = cast(wul.[APIAccess] as bit)
		,[PasswordHash] = wul.[Password Hash]
		,[PasswordSalt] = wul.[Password Salt]
	
		from [PPlus_DB].[dbo].[T_Users] u with (nolock)
		left join [PinnacleProd].[dbo].[Metropolitan$Web User Login] wul with (nolock) on upper(u.[USER_ID]) = wul.[Username] collate Database_Default
		left join [PPlus_DB].[dbo].[V_NAV_Time_Zone] ntz with (nolock) on wul.[Time Zone ID] = ntz.[Time Zone ID]
		where upper(rtrim(ltrim(u.[USER_ID]))) = @UserName
	end

	select * from @Usertable

END
GO
