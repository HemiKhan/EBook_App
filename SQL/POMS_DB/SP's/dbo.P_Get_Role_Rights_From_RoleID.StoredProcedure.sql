USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Rights_From_RoleID]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_Role_Rights_From_RoleID] 12,0,0.0,''
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Role_Rights_From_RoleID]
	@ROLE_ID int
	,@IsGroupRoleID bit
	,@P_ID int = 0
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
AS
BEGIN
	
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [POMS_DB].[dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID ,@IsGroupRoleID ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

END
GO
