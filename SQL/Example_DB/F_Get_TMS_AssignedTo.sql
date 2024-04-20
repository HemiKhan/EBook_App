--	SELECT * FROM [dbo].[F_GetAssignedTo] (@TD_ID INT)(1)
CREATE FUNCTION [dbo].[F_GetAssignedTo] (@TD_ID INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @AssignedTo NVARCHAR(MAX)
    
    SELECT @AssignedTo = COALESCE(@AssignedTo + ', ', '') + AssignedTo
    FROM [dbo].[T_TMS_TaskAssignedTo_Mapping] with (nolock)
    WHERE TD_ID = @TD_ID and IsActive=1
    
    RETURN ISNULL(@AssignedTo, '')
END
GO
