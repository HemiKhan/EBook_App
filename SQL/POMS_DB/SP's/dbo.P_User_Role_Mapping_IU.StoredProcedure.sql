USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_User_Role_Mapping_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_User_Role_Mapping_IU]
	@pUsername nvarchar(150)
	,@pIP nvarchar(20)
	,@pROLE_ID int
	,@pIsGroupRoleID bit
	,@pAddedBy nvarchar(150)
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(1000) output
	,@pError_Text nvarchar(max) output
	,@pIsBeginTransaction bit = 1
	,@pSource_MTV_ID int = 167100
AS
BEGIN
	
	set @pUserName = upper(@pUserName)
	set @pAddedBy = upper(@pAddedBy)

	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	Begin Try

		if @pIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if exists(select URM_ID from [POMS_DB].[dbo].[T_User_Role_Mapping] with (nolock) where USERNAME = @pUsername)
		begin
			
			update urm
			set urm.ROLE_ID = @pROLE_ID
			,urm.IsGroupRoleID = @pIsGroupRoleID
			,urm.ModifiedBy = @pAddedBy
			,urm.ModifiedOn = getutcdate()
			from [POMS_DB].[dbo].[T_User_Role_Mapping] urm where urm.USERNAME = @pUsername

			set @pReturn_Code = 1
			set @pReturn_Text = 'Updated'
		end
		else
		begin
			insert into [POMS_DB].[dbo].[T_User_Role_Mapping] (USERNAME, ROLE_ID, IsGroupRoleID, AddedBy)
			values (@pUsername, @pROLE_ID, @pIsGroupRoleID, @pAddedBy)
			set @pReturn_Code = 1
			set @pReturn_Text = 'Inserted'
		end

		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 1
		begin
			COMMIT; 
		end
		else if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 0
		begin
			ROLLBACK; 
		end

	End Try
	Begin catch
		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @pError_Text = 'P_User_Role_Mapping_IU: ' + ERROR_MESSAGE()
	End catch


END
GO
