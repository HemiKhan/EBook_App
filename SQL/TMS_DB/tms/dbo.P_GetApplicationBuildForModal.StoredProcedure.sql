USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetApplicationBuildForModal]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec P_GetApplicationBuildForModal 1002
CREATE PROCEDURE [dbo].[P_GetApplicationBuildForModal]
@AB_ID int
AS
BEGIN
    SET NOCOUNT ON;
 SELECT AB_ID, BUILDCODE, BuildName, Application_MTV_ID
,[Description] 
,ScheduleDate=FORMAT(ScheduleDate, 'yyyy-MM-dd')
,Status_MTV_CODE
,Active = IsActive FROM [POMS_DB].[dbo].[T_Application_Builds] WITH (NOLOCK) 
	WHERE AB_ID = @AB_ID
END
GO
