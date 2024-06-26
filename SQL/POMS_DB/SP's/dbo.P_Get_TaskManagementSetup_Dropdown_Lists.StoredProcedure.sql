USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskManagementSetup_Dropdown_Lists]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_Get_TaskManagementSetup_Dropdown_Lists]
	
AS
BEGIN
	-- Application
	SELECT code = MTV_CODE, [name] = SubName FROM [POMS_DB].[dbo].[F_Get_List_By_ID_2] (148,NULL) ORDER BY Sort_
	-- Category
	SELECT code = MTV_CODE, [name] = SubName FROM [POMS_DB].[dbo].[F_Get_List_By_ID_2] (177,NULL) ORDER BY Sort_
	-- Status
	SELECT code = MTV_CODE, [name] = SubName FROM [POMS_DB].[dbo].[F_Get_List_By_ID_2] (175,NULL) ORDER BY Sort_
	-- Priority
	SELECT code = MTV_CODE, [name] = SubName FROM [POMS_DB].[dbo].[F_Get_List_By_ID_2] (176,NULL) ORDER BY Sort_
	-- Memebers
	SELECT code = USERNAME, [name] = lower(USERNAME) FROM [POMS_DB].[dbo].[T_Users] WITH (NOLOCK) WHERE IsActive = 1 AND [USER_ID] IN (9114,9119,9124,9127,8550,8019,8551)

	--Application Url
	 SELECT code = P_ID, [name] = PageName FROM [POMS_DB].[dbo].[T_Page] WITH (NOLOCK) WHERE IsActive = 1

	 --Task Category
	 SELECT code = MTV_CODE, [name] = SubName FROM [POMS_DB].[dbo].[F_Get_List_By_ID_2] (177,NULL) ORDER BY Sort_
END

 
GO
