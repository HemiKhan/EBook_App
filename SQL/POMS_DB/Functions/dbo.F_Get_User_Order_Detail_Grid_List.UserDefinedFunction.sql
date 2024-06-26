USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_User_Order_Detail_Grid_List]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_User_Order_Detail_Grid_List] ('ABDULLAH.ARSHAD') 
-- =============================================
CREATE FUNCTION [dbo].[F_Get_User_Order_Detail_Grid_List]
(	
	@Username nvarchar(150)
)
returns @ReturnTable table
([ODGL_ID] [int] 
,[GridName] [nvarchar](50) 
,[IsExpand] [bit] 
,[NewSort_] [int] identity(1,1)
,[Sort_] [int] 
,[PR_ID] [int] 
,[IsActive] [bit] 
)
AS
Begin

	set @Username = isnull(upper(@Username),'')

	Declare @D_ID int = 0
	select @D_ID = D_ID from [POMS_DB].[dbo].[T_Users] u with (nolock) where u.USERNAME = @Username
	
	if (@D_ID is null)
	begin
		return
	end

	Declare @ROLE_ID int = 0
	Declare @IsGroupRoleID bit = 0
	select @ROLE_ID = ROLE_ID ,@IsGroupRoleID = IsGroupRoleID from [POMS_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username and urm.IsActive = 1
	set @ROLE_ID = isnull(@ROLE_ID,0)
	set @IsGroupRoleID = isnull(@IsGroupRoleID,0)
	
	Declare @RoleRightsTable table (PR_ID int , IsRightActive bit , PageRightName nvarchar(50) , PageRightType_MTV_CODE nvarchar(20))
	insert into @RoleRightsTable (PR_ID , IsRightActive , PageRightName , PageRightType_MTV_CODE )
	select PR_ID , IsRightActive , PageRightName , PageRightType_MTV_CODE  from [POMS_DB].[dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID,@IsGroupRoleID,401,0,'')

	insert into @ReturnTable ([ODGL_ID] ,[GridName] ,[IsExpand] ,[Sort_] ,[PR_ID] ,[IsActive])
	select * from (
		select 
		ilv2.[ODGL_ID]
		,ilv2.[GridName] 
		,[IsExpand] =isnull(uodgdm.[IsExpand],ilv2.[IsExpand])
		,[Sort_]=isnull(uodgdm.[Sort_],ilv2.[Sort_]) 
		,ilv2.[PR_ID]
		,[IsActive]=isnull(uodgdm.[IsActive],ilv2.[IsActive])
		from (
			select odgdm.ODGDM_ID
			,ilv.[ODGL_ID]
			,ilv.[GridName] 
			,[IsExpand] =isnull(odgdm.[IsExpand],ilv.[IsExpand])
			,[Sort_]=isnull(odgdm.[Sort_],ilv.[Sort_]) 
			,ilv.[PR_ID]
			,[IsActive]=isnull(odgdm.[IsActive],ilv.[IsActive])
			from (
				select odgl.[ODGL_ID] 
				,[GridName] = odgl.[Name]
				,odgl.[IsExpand] 
				,odgl.[Sort_] 
				,odgl.[PR_ID] 
				,odgl.[IsActive]
				from [POMS_DB].[dbo].[T_Order_Detail_Grid_List] odgl with (nolock) where odgl.IsActive = 1
				and odgl.PR_ID in (select rrt.PR_ID from @RoleRightsTable rrt)
			) ilv left join [POMS_DB].[dbo].[T_Order_Detail_Grid_Department_Mapping] odgdm with (nolock) on ilv.[ODGL_ID] = odgdm.[ODGL_ID] and odgdm.D_ID = @D_ID
		) ilv2 left join [POMS_DB].[dbo].[T_User_Order_Detail_Grid_Department_Mapping] uodgdm with (nolock) on ilv2.ODGDM_ID = uodgdm.ODGDM_ID and uodgdm.USERNAME = @Username
	) ilv3 order by ilv3.[Sort_], ilv3.ODGL_ID
	
	return

end
GO
