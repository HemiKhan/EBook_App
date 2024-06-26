USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Page_Setup_DropDown_Lists]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[P_Get_Page_Setup_DropDown_Lists]
	@Username nvarchar(150)

AS
BEGIN
	
	select [value] = PG_ID, [text]= PageGroupName from [POMS_DB].[dbo].[T_Page_Group] with (nolock) order by PageGroupName

	select [value] = P_ID, [text]= PageName from [POMS_DB].[dbo].[T_Page] with (nolock) order by PageName

	SELECT [value] = [MTV_ID] ,[text]= [Name] FROM [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 148 order by [Name]
END
GO
