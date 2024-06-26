USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Role_Rights_From_Username]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Role_Rights_From_Username] ('ABDULLAH.ARSHAD',0,0,'')
-- =============================================
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
	
	select @ROLE_ID = urm.ROLE_ID ,@IsGroupRoleID = urm.IsGroupRoleID from [POMS_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username and urm.IsActive = 1
	
	insert into @ReturnTable
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [POMS_DB].[dbo].[F_Get_Role_Rights_From_RoleID] (	@ROLE_ID ,@IsGroupRoleID ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

	return

end
GO
