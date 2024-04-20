USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_GetLinkedTaskDetail]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_GetLinkedTaskDetail] (@TD_ID INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @LinkedTask NVARCHAR(MAX)
    
    SELECT @LinkedTask = COALESCE(@LinkedTask + ', ', '') +
        CASE WHEN Parent_TD = @TD_ID THEN CAST(LinkedTask_TD AS NVARCHAR(50))
             ELSE CAST(Parent_TD AS NVARCHAR(50))
        END
    FROM [POMS_DB].[dbo].[T_TMS_LinkedTasks] with (nolock)
    WHERE (Parent_TD = @TD_ID OR LinkedTask_TD = @TD_ID) AND IsActive = 1
    
    RETURN ISNULL(@LinkedTask, '')
END
GO
