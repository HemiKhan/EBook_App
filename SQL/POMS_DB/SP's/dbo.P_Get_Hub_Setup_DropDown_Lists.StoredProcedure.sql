USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Hub_Setup_DropDown_Lists]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			exec [P_Get_Hub_Setup_DropDown_Lists] 'HAMMAS.KHAN'
CREATE PROCEDURE [dbo].[P_Get_Hub_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	select [value] = HL_ID, [text]= HUB_CODE +' - ' + HubName from [POMS_DB].[dbo].[T_Hub_List] with (nolock) order by HUB_CODE

	select [value] = MTV_ID, [text]= Name from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 104 order by Sort_
	select [value] = MTV_ID, [text]= Name from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 125 order by Sort_
	select [value] = MTV_ID, [text]= Name from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 130 order by Sort_
	select [value] = MTV_ID, [text]= Name from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 131 order by Sort_
 

END
GO
