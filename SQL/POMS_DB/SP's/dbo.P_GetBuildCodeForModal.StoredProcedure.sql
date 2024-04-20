USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetBuildCodeForModal]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC P_GetBuildCodeForModal
CREATE PROCEDURE [dbo].[P_GetBuildCodeForModal]
    
AS
BEGIN
    SET NOCOUNT ON;
    SELECT   code=BUILDCODE,[name]='<span class=''boldtext'' >BuildName:</span> '+BuildName+'<br> <span class=''boldtext'' >Build Status:</span> '+Status_MTV_CODE
    FROM [POMS_DB].[dbo].[T_Application_Builds] WITH (NOLOCK) 
     where IsActive=1
END


 
 
GO
