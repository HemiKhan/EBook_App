USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_UserSetup_Dropdown_Lists]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_Get_UserSetup_Dropdown_Lists] 'ABDULLAH.ARSHAD', 'METRO-USER'

CREATE PROCEDURE [dbo].[P_Get_UserSetup_Dropdown_Lists]
	@Username nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	
AS
BEGIN
	
	SELECT [value] = MTV_CODE, [text] = Name FROM [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock)
	where MT_ID = 106 AND IsActive = 1 ORDER BY Sort_

	SELECT [value] = D_ID, [text] = DepartmentName FROM [POMS_DB].[dbo].[T_Department] with (nolock)
	where IsActive = 1 ORDER BY DepartmentName 

	SELECT [value] = MTV_CODE, [text] = Name FROM [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock)
	where MT_ID = 150 AND IsActive = 1 ORDER BY Sort_

	SELECT [value] = MTV_CODE, [text] = Name FROM [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock)
	where MT_ID = 149 AND IsActive = 1 ORDER BY Sort_

	SELECT [value] = TIMEZONE_ID, [text] = TimeZoneDisplay FROM [POMS_DB].[dbo].[T_Time_Zone_List] with (nolock) WHERE IsActive = 1 and TIMEZONE_ID In (5,7,9,13) order by TimeZoneDisplay

	select [value], [text] from (
		Select [value]=CONCAT(r.R_ID,'|','0'),[text]=r.RoleName  from [POMS_DB].[dbo].[T_Roles] r  with (nolock) WHERE r.IsActive = 1
		union 
		select [value]=CONCAT(rg.RG_ID,'|','1'),[text]=rg.RoleGroupName from  [POMS_DB].[dbo].[T_Role_Group] rg  with (nolock) WHERE rg.IsActive = 1
	) ilv order by [text]
	 
	SELECT [value] = MTV_ID, [text] = Name FROM [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MT_ID=148 and IsActive = 1  ORDER BY Name

	SELECT [value] = SELLER_KEY, [text] = Company + '  -  ' + SELLER_CODE FROM [POMS_DB].[dbo].[T_Seller_list] with (nolock) WHERE IsActive = 1  ORDER BY Company

END

 
GO
