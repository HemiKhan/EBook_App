USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_GetBuildCodeName]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[F_GetBuildCodeName] (@BUILDCODE NVARCHAR(50))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @BuildCodeName NVARCHAR(MAX)

    SELECT @BuildCodeName = '<span class=''boldtext''>Build Name:</span> ' + BuildName + '<br> <span class=''boldtext''>Build Status:</span> ' + Status_MTV_CODE
    FROM [POMS_DB].[dbo].[T_Application_Builds] WITH (NOLOCK) 
    WHERE IsActive = 1 AND BUILDCODE = @BUILDCODE

    RETURN @BuildCodeName
END
  

 
GO
