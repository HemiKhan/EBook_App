-- select * from [dbo].[F_Get_RoleName_RoleID] (1)
CREATE FUNCTION [dbo].[F_Get_RoleName_RoleID]
(
	@R_ID int
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @RoleName nvarchar(max)
	SELECT @RoleName = ISNULL(RoleName,'') FROM [dbo].[T_Roles] WHERE R_ID = @R_ID AND IsActive = 1
	return @RoleName
end

