-- select * from [[dbo].[F_Get_Role_Rights_From_Username] ('ABDULLAH.ARSHAD',0,0,'')
CREATE FUNCTION [dbo].[F_Get_Role_Rights_From_Username]
(	
	@Username nvarchar(150)
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

	Declare @ROLE_ID int = 0
	Declare @IsGroupRoleID bit = 0
	
	select @ROLE_ID = urm.ROLE_ID ,@IsGroupRoleID = urm.IsGroupRoleID from [[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username and urm.IsActive = 1
	
	insert into @ReturnTable
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [[dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID ,@IsGroupRoleID ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

	return

end
GO
