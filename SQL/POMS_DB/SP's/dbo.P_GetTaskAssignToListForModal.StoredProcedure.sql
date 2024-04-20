USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetTaskAssignToListForModal]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[P_GetTaskAssignToListForModal]
@TAL_ID int
AS
BEGIN
    SET NOCOUNT ON;
 SELECT TAL_ID, AssignToType_MTV_CODE, AssignedTo,Active = IsActive FROM [POMS_DB].[dbo].[T_TMS_AssignedTo_List] WITH (NOLOCK) 
	WHERE TAL_ID = @TAL_ID
END
GO
