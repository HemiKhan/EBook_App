USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Event_Setup_DropDown_Lists]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			exec [P_Get_Event_Setup_DropDown_Lists] 'HAMMAS.KHAN'
CREATE PROCEDURE [dbo].[P_Get_Event_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	select [value] = EL_ID, [text]= EVENT_CODE from [POMS_DB].[dbo].[T_Events_List] with (nolock) order by EVENT_CODE

	select [value] = EL_ID, [text]= Name from [POMS_DB].[dbo].[T_Events_List] with (nolock) order by Name
END
GO
