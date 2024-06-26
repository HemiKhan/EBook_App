USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_RoleName_From_RoleID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
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
		select @Ret = R.[RoleName] from [POMS_DB].[dbo].[T_Roles] R with (nolock) where R.[R_ID] = @RoleID
		set @Ret = isnull(@Ret,'')
	end
	else
	begin
		select @Ret = RG.[RoleGroupName] from [POMS_DB].[dbo].[T_Role_Group] RG with (nolock) where RG.[RG_ID] = @RoleID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
