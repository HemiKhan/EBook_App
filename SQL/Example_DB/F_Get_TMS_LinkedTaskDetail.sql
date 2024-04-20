
--	SELECT * FROM [dbo].[F_Get_TMS_LinkedTaskDetail] (@TD_ID INT)(1)
CREATE FUNCTION [dbo].[F_Get_TMS_LinkedTaskDetail] (@TD_ID INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @LinkedTask NVARCHAR(MAX)
    
    SELECT @LinkedTask = COALESCE(@LinkedTask + ', ', '') +
        CASE WHEN Parent_TD = @TD_ID THEN CAST(LinkedTask_TD AS NVARCHAR(50))
             ELSE CAST(Parent_TD AS NVARCHAR(50))
        END
    FROM [dbo].[T_TMS_LinkedTasks] with (nolock)
    WHERE (Parent_TD = @TD_ID OR LinkedTask_TD = @TD_ID) AND IsActive = 1
    
    RETURN ISNULL(@LinkedTask, '')
END
GO
