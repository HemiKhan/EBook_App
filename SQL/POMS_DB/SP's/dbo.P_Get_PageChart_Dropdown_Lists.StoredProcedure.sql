USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_PageChart_Dropdown_Lists]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_Get_PageChart_Dropdown_Lists]
	
AS
BEGIN
	
	SELECT code = MTV_CODE, [name] = SubName FROM [POMS_DB].[dbo].[F_Get_List_By_ID_2] (148, null) ORDER BY Sort_
	SELECT code = R_ID, [name] = RoleName FROM [POMS_DB].[dbo].[T_Roles] WITH (NOLOCK) WHERE IsActive = 1
	SELECT code = USERNAME, [name] = LOWER(USERNAME) FROM [POMS_DB].[dbo].[T_Users] WITH (NOLOCK) WHERE IsActive = 1 

END

 
GO
