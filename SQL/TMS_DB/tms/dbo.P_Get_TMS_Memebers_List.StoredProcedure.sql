USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TMS_Memebers_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--		EXEC [P_Get_TMS_Memebers_List] 1

create PROCEDURE [dbo].[P_Get_TMS_Memebers_List]
    @TD_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TATM_ID, TD_ID, r.R_ID, AssignedTo, u.Email, r.RoleName
	FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tatm WITH (NOLOCK) 
	INNER JOIN [POMS_DB].[dbo].[T_Users] u WITH (NOLOCK) on tatm.AssignedTo = u.USERNAME
	LEFT JOIN [POMS_DB].[dbo].[T_User_Role_Mapping] urm WITH (NOLOCK) on tatm.AssignedTo = urm.USERNAME
	LEFT JOIN [POMS_DB].[dbo].[T_Roles] r WITH (NOLOCK) on urm.ROLE_ID = r.R_ID
	WHERE tatm.IsActive = 1 AND tatm.TD_ID = @TD_ID
	
END;
GO
