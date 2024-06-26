USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_User_Application_Mapping_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_User_Application_Mapping_IU]
	@pJson nvarchar(max)
	,@pAddedBy nvarchar(150)
	,@pIP nvarchar(20)
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(1000) output
	,@pError_Text nvarchar(max) output
	,@pIsBeginTransaction bit = 1
	,@pSource_MTV_ID int = 167100
AS
BEGIN
	
	set @pAddedBy = upper(@pAddedBy)

	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	Declare @UserApplicationAccessTable table (ID int identity(1,1), UAA_ID int, USERNAME nvarchar(150), Application_MTV_ID int, NAV_USERNAME nvarchar(150), IsActive bit)

	insert into @UserApplicationAccessTable (UAA_ID , USERNAME , Application_MTV_ID , NAV_USERNAME , IsActive)
	select UAA_ID , USERNAME , Application_MTV_ID , NAV_USERNAME , IsActive from [POMS_DB].[dbo].[F_Get_UserApplicationAccess_JsonTable] (@pJson)

	Declare @UAA_ID int = 0
	Declare @USERNAME nvarchar(150) = ''
	Declare @Application_MTV_ID int = 0
	Declare @NAV_USERNAME nvarchar(150) = ''
	Declare @IsActive bit = 0

	Declare @TryCount int = 1
	Declare @MaxCount int = 0
	select @MaxCount = max(ID) from @UserApplicationAccessTable
	while @TryCount <= @MaxCount
	begin
		
		Begin Try
			
			set @pReturn_Code = 0
			set @pReturn_Text = ''

			Select @UAA_ID = UAA_ID 
			,@USERNAME = USERNAME
			,@Application_MTV_ID = Application_MTV_ID
			,@NAV_USERNAME = NAV_USERNAME
			,@IsActive = IsActive
			from @UserApplicationAccessTable where ID = @TryCount

			if @pIsBeginTransaction = 1
			begin
				Begin Transaction
			end

			if exists(select UAA_ID from [POMS_DB].[dbo].[T_User_Application_Access] uaa with (nolock) where uaa.UAA_ID = @UAA_ID and uaa.USERNAME = @USERNAME)
			begin
				drop table if exists #JsonOldEditUserApplicationAccessTable 
				select uaa.UAA_ID
				,uaa.USERNAME
				,uaa.Application_MTV_ID
				,Application_MTV_ID_Name=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (uaa.Application_MTV_ID)
				,NAV_USERNAME=isnull(uaa.NAV_USERNAME,'')
				,uaa.IsActive
				,IsActive_Name=(case uaa.IsActive when 1 then 'Yes' else 'No' end)
				into #JsonOldEditUserApplicationAccessTable    
				from [POMS_DB].[dbo].[T_User_Application_Access] uaa with (nolock)
				where uaa.UAA_ID = @UAA_ID and uaa.USERNAME = @USERNAME

				update uaa
				set uaa.Application_MTV_ID = @Application_MTV_ID
				,uaa.NAV_USERNAME = @NAV_USERNAME
				,uaa.ModifiedBy = @pAddedBy
				,uaa.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_User_Application_Access] uaa where uaa.UAA_ID = @UAA_ID and uaa.USERNAME = @USERNAME

				drop table if exists #JsonNewEditUserApplicationAccessTable 
				select UAA_ID=@UAA_ID
				,USERNAME=@USERNAME
				,Application_MTV_ID=@Application_MTV_ID
				,Application_MTV_ID_Name=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@Application_MTV_ID)
				,NAV_USERNAME=isnull(@NAV_USERNAME,'')
				,IsActive=@IsActive
				,IsActive_Name=(case @IsActive when 1 then 'Yes' else 'No' end)
				into #JsonNewEditUserApplicationAccessTable 

				exec [POMS_DB].[dbo].[P_User_Application_Mapping_IU_ChangeLog] @plogIsEdit = 1 ,@plogUserName = @pAddedBy ,@plogSource_MTV_ID = @pSource_MTV_ID

				set @pReturn_Code = 1
				set @pReturn_Text = 'Updated'
			end
			else if @UAA_ID = 0 and not exists(select UAA_ID from [POMS_DB].[dbo].[T_User_Application_Access] uaa with (nolock) where uaa.USERNAME = @USERNAME and uaa.Application_MTV_ID = @Application_MTV_ID)
			begin
				insert into [POMS_DB].[dbo].[T_User_Application_Access] (USERNAME ,Application_MTV_ID ,NAV_USERNAME ,AddedBy)
				values (@USERNAME, @Application_MTV_ID, @NAV_USERNAME, @pAddedBy)
				set @pReturn_Code = 1
				set @pReturn_Text = 'Inserted'
			end
			else if @UAA_ID = 0 and exists(select UAA_ID from [POMS_DB].[dbo].[T_User_Application_Access] uaa with (nolock) where uaa.USERNAME = @USERNAME and uaa.Application_MTV_ID = @Application_MTV_ID)
			begin
				set @pReturn_Code = 0
				set @pReturn_Text = 'Already Exists'
			end

			if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 1
			begin
				COMMIT; 
			end
			else if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 0
			begin
				ROLLBACK; 
			end

			if (@pReturn_Code = 1)
			begin
				set @TryCount = @TryCount + 1
			end
			else
			begin
				set @TryCount = @MaxCount
			end

		End Try
		Begin catch
			if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0
			begin
				ROLLBACK; 
			end
			Set @pError_Text = 'P_User_Application_Mapping_IU: ' + ERROR_MESSAGE()
		End catch
		
		set @TryCount = @TryCount + 1

	end

END
GO
