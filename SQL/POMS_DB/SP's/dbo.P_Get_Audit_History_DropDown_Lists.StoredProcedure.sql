USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Audit_History_DropDown_Lists]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			exec [P_Get_Audit_History_DropDown_Lists] 'HAMMAS.KHAN'
create PROCEDURE [dbo].[P_Get_Audit_History_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	select [value] = MT_ID, [text]= [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 166 and IsActive = 1 order by [Name]

	select [value] = MT_ID, [text]= [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 167 and IsActive = 1 order by [Name]

END
GO
