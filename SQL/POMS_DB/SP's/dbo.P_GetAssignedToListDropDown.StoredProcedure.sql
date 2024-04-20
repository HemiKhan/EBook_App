USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetAssignedToListDropDown]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 


 --exec P_GetAssignedToListDropDown 'FULL-STACK-DEVELOPER'
Create PROCEDURE [dbo].[P_GetAssignedToListDropDown]
   @AssignToType_MTV_CODE Nvarchar(40)
AS
BEGIN
Select code=AssignedTo, [name]=AssignedTo From  [POMS_DB].[dbo].[T_TMS_AssignedTo_List] with (nolock) where AssignToType_MTV_CODE=@AssignToType_MTV_CODE
End

 
GO
