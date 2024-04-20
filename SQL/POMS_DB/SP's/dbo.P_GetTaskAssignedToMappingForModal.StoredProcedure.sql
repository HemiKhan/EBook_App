USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetTaskAssignedToMappingForModal]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC P_GetTaskAssignedToMappingForModal 2
CREATE PROCEDURE [dbo].[P_GetTaskAssignedToMappingForModal]
    @TD_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TATM_ID, TD_ID, AssignedTo, AssignToType_MTV_CODE, Active = IsActive 
    FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] WITH (NOLOCK) 
    WHERE TD_ID = @TD_ID And IsActive=1
END


 
 
GO
