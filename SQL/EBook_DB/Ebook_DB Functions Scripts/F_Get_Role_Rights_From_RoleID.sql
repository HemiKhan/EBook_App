-- select * from [dbo].[F_Get_Role_Rights_From_RoleID] (12,0,0,0,'')
CREATE FUNCTION [dbo].[F_Get_Role_Rights_From_RoleID]
(	
	@ROLE_ID int
	,@IsGroupRoleID bit
	,@P_ID int = 0
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
)
returns @ReturnTable table
(PR_ID int
, IsRightActive bit
, PageRightName nvarchar(50)
, PageRightType_MTV_CODE nvarchar(20))
AS
Begin

	set @PR_ID = isnull(@PR_ID,0)
	set @PageRightType_MTV_CODE = isnull(upper(@PageRightType_MTV_CODE),'')

	Declare @IsAdmin bit = 0
	select @IsAdmin = [dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)
	set @IsAdmin = isnull(@IsAdmin,0)

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

	if @IsAdmin = 1
	begin
		insert into @ReturnTable (PR_ID , IsRightActive , PageRightName , PageRightType_MTV_CODE )
		select pr.PR_ID , pr.IsActive , pr.PageRightName , pr.PageRightType_MTV_CODE from [dbo].[T_Page_Rights] pr with (nolock) where pr.IsActive = 1
		and ((@P_ID > 0 and pr.P_ID = @P_ID) or @P_ID = 0)
		and ((@PR_ID > 0 and pr.PR_ID = @PR_ID) or @PR_ID = 0)
		and ((@PageRightType_MTV_CODE <> '' and pr.PageRightType_MTV_CODE = @PageRightType_MTV_CODE) or @PageRightType_MTV_CODE = '')
	end
	else
	begin
		Declare @TempRoleRightsTable table (PR_ID int, IsRightActive bit)
		insert into @TempRoleRightsTable (PR_ID ,IsRightActive)
		select rprm.PR_ID,rprm.IsRightActive from [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable) and rprm.IsActive = 1 and rprm.IsRightActive = 1

		insert into @TempRoleRightsTable (PR_ID ,IsRightActive)
		select rprm.PR_ID,rprm.IsRightActive from [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable) and rprm.IsActive = 1 and rprm.IsRightActive = 0
		and rprm.PR_ID not in (select rrt.PR_ID from @TempRoleRightsTable rrt where rrt.IsRightActive = 1)

		insert into @ReturnTable (PR_ID , IsRightActive , PageRightName , PageRightType_MTV_CODE )
		select pr.PR_ID , pr.IsActive , pr.PageRightName , pr.PageRightType_MTV_CODE 
		from [dbo].[T_Page_Rights] pr with (nolock) 
		inner join @TempRoleRightsTable trrt on pr.PR_ID = trrt.PR_ID
		where pr.IsActive = 1
		and ((@P_ID > 0 and pr.P_ID = @P_ID) or @P_ID = 0)
		and ((@PR_ID > 0 and pr.PR_ID = @PR_ID) or @PR_ID = 0)
		and ((@PageRightType_MTV_CODE <> '' and pr.PageRightType_MTV_CODE = @PageRightType_MTV_CODE) or @PageRightType_MTV_CODE = '')
	end

	return

end
GO