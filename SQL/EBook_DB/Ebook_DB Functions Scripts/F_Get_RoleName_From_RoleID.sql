
--	SELECT * FROM [dbo].[F_Get_RoleName_From_RoleID] (1,true) 
CREATE FUNCTION [dbo].[F_Get_RoleName_From_RoleID]  
(
	@RoleID int
	,@IsGroupRoleID bit
)
RETURNS nvarchar(50)
AS
BEGIN
	
	set @RoleID = isnull(@RoleID,0)
	set @IsGroupRoleID = isnull(@IsGroupRoleID,0)

	Declare @Ret nvarchar(50) = ''
	
	if @IsGroupRoleID = 0
	begin
		select @Ret = R.[RoleName] from [dbo].[T_Roles] R with (nolock) where R.[R_ID] = @RoleID
		set @Ret = isnull(@Ret,'')
	end
	else
	begin
		select @Ret = RG.[RoleGroupName] from [dbo].[T_Role_Group] RG with (nolock) where RG.[RG_ID] = @RoleID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
