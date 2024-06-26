USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_GetAssignedTo]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[F_GetAssignedTo] (@TD_ID INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @AssignedTo NVARCHAR(MAX)
    
    SELECT @AssignedTo = COALESCE(@AssignedTo + ', ', '') + AssignedTo
    FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] with (nolock)
    WHERE TD_ID = @TD_ID and IsActive=1
    
    RETURN ISNULL(@AssignedTo, '')
END
GO
