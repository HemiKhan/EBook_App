-- SELECT * FROM [dbo].[F_Is_Admin_Right_From_Username]('hammas.khan')
CREATE FUNCTION [dbo].[F_Is_Admin_Right_From_Username]
(
	@Username nvarchar(150)	
)
RETURNS bit
AS
BEGIN
	
	DECLARE @Ret bit = 0
	set @Username = isnull(upper(@Username),'')
	
	if (@Username = '')
	begin
		return @Ret
	end

	Declare @ROLE_ID int = 0
	Declare @IsGroupRoleID bit = 0

	select @ROLE_ID = urm.ROLE_ID , @IsGroupRoleID = urm.IsGroupRoleID from [dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username

	select @Ret = [dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)

	set @Ret = isnull(@Ret,0)

	return @Ret

end

GO