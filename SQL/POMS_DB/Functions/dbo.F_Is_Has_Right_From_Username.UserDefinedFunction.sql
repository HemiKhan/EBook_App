USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Has_Right_From_Username]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[F_Is_Has_Right_From_Username]
(
	@Username nvarchar(150)
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
)
RETURNS bit
AS
BEGIN
	
	DECLARE @Ret bit = 0
	set @Username = isnull(upper(@Username),'')
	set @PR_ID = isnull(@PR_ID,0)
	set @PageRightType_MTV_CODE = isnull(@PageRightType_MTV_CODE,'')
	
	if (@Username = '')
	begin
		return @Ret
	end

	if (@PR_ID = 0 and @PageRightType_MTV_CODE = '')
	begin
		return @Ret
	end

	Declare @ROLE_ID int = 0
	Declare @IsGroupRoleID bit = 0

	select @ROLE_ID = urm.ROLE_ID , @IsGroupRoleID = urm.IsGroupRoleID from [POMS_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username

	select @Ret = [POMS_DB].[dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)

	set @Ret = isnull(@Ret,0)

	if (@Ret = 0)
	begin
		select @Ret = IsRightActive from [POMS_DB].[dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID , @IsGroupRoleID ,0 ,@PR_ID ,@PageRightType_MTV_CODE)
		set @Ret = isnull(@Ret,0)
	end

	return @Ret

end

GO
