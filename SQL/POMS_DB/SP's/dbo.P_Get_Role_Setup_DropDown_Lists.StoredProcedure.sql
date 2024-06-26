USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Setup_DropDown_Lists]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[P_Get_Role_Setup_DropDown_Lists]
	@Username nvarchar(150)

AS
BEGIN
	
	SELECT [value] = R_ID, [text]= RoleName FROM [dbo].[T_Roles] WITH (NOLOCK) ORDER BY RoleName
	SELECT [value] = RG_ID, [text]= RoleGroupName FROM [dbo].[T_Role_Group] WITH (NOLOCK) ORDER BY RoleGroupName
	SELECT [value] = D_ID, [text]= DepartmentName FROM [dbo].[T_Department] WITH (NOLOCK) ORDER BY DepartmentName

END
GO
