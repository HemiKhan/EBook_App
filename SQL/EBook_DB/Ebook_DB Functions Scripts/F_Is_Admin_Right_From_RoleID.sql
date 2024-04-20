
-- select * from [dbo].[F_Is_Admin_Right_From_RoleID] (1,true)
CREATE FUNCTION [dbo].[F_Is_Admin_Right_From_RoleID]
(
	@ROLE_ID int
	,@IsGroupRoleID bit
)
RETURNS bit
AS
BEGIN
	
	Declare @PR_ID int = 100100
	set @ROLE_ID = isnull(@ROLE_ID,0)
	set @IsGroupRoleID = isnull(@IsGroupRoleID,0)

	DECLARE @Ret bit = 0
	
	if (@ROLE_ID = 0)
	begin
		return @Ret
	end

	Declare @RolesTable table (ROLE_ID int)
	if @IsGroupRoleID = 1
	begin
		insert into @RolesTable (ROLE_ID)
		select R_ID from [dbo].[T_Role_Group_Mapping] rgm with (nolock) where rgm.RG_ID = @ROLE_ID and rgm.IsActive = 1
	end
	else
	begin
		insert into @RolesTable (ROLE_ID)
		select @ROLE_ID
	end

	if exists(Select rprm.PR_ID from [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable) and rprm.PR_ID = 100100)
	begin
		set @Ret = 1
	end

	set @Ret = isnull(@Ret,0)

	return @Ret

end

GO
