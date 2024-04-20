
--select [dbo].[F_Get_Users_Json] ('hammaass.khan')
CREATE FUNCTION [dbo].[F_Get_Users_Json]
(	
	@UserName nvarchar(300)	 
)
RETURNS nvarchar(max) 
AS
begin
	
	Declare @Return_Json nvarchar(max) = ''
	
	SELECT @Return_Json =  (SELECT
    u.[User_ID],
    u.UserName,
    u.Email,
    u.FirstName,
    u.LastName,
    u.PasswordHash,
    u.PasswordSalt,
    u.UserType_MTV_CODE,
    u.Department_MTV_CODE,
    u.Designation_MTV_CODE,
    u.BlockType_MTV_CODE,
	R_ID = CONCAT(rm.ROLE_ID, '_', CASE WHEN rm.IsGroupRoleID = 1 THEN 'true' ELSE 'false' END),
    u.IsApproved,
    u.IsActive    
	FROM [dbo].[T_Users] u WITH (NOLOCK)
	LEFT JOIN [dbo].[T_User_Role_Mapping] rm  WITH (NOLOCK) ON u.UserName = rm.USERNAME
    where u.UserName=@UserName    
	FOR JSON PATH)

	if @Return_Json is null	begin set @Return_Json = '' end

	return @Return_Json

end
GO
