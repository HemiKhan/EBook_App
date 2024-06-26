USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Master_Setup_DropDown_Lists]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			exec [P_Get_Master_Setup_DropDown_Lists] 'HAMMAS.KHAN'
CREATE PROCEDURE [dbo].[P_Get_Master_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	select [value] = MT_ID, [text]= [Name] from [POMS_DB].[dbo].[T_Master_Type] with (nolock) order by [Name]

	select [value] = MTV_ID , [text]= Name from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE IsActive = 1 order by [Name]
END
GO
