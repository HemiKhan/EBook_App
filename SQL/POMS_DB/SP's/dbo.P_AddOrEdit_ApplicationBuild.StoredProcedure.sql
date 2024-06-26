USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ApplicationBuild]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 
CREATE PROC [dbo].[P_AddOrEdit_ApplicationBuild]
@AB_ID int,
@BuildName nvarchar(250),
@Application_MTV_ID int,
@Description nvarchar(1000),
@ScheduleDate Nvarchar(50),
@Status_MTV_CODE Nvarchar(20),
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	 
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @AB_ID >0
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Application_Builds] WITH (NOLOCK) WHERE AB_ID = @AB_ID)
	BEGIN
	    
     Declare	@OldBuildName nvarchar(250)
     Declare	@OldApplication_MTV_ID int
     Declare	@OldDescription nvarchar(1000)
     Declare	@OldScheduleDate Nvarchar(50)
     Declare	@OldStatus_MTV_CODE Nvarchar(20)
     Declare	@OldIsActive BIT = 1
		
		SELECT @OldBuildName=BuildName,@OldApplication_MTV_ID=Application_MTV_ID, @OldDescription=[Description], @OldScheduleDate=ScheduleDate,@OldStatus_MTV_CODE=Status_MTV_CODE,@OldIsActive=IsActive   FROM [POMS_DB].[dbo].[T_Application_Builds] WITH (NOLOCK) WHERE AB_ID = @AB_ID
		
		UPDATE [POMS_DB].[dbo].[T_Application_Builds] SET BuildName=@BuildName, Application_MTV_ID = @Application_MTV_ID,[Description]=@Description, ScheduleDate = @ScheduleDate, Status_MTV_CODE = @Status_MTV_CODE, IsActive = @IsActive ,ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE AB_ID = @AB_ID

		IF @OldBuildName <> @BuildName
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'BuildName' ,'T_Application_Builds', @AB_ID, 166152, @AB_ID, '', '', @OldBuildName, @BuildName, @OldBuildName, @BuildName, '', 0, 167100, @UserName
		END

		IF @OldApplication_MTV_ID <> @Application_MTV_ID
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Application_MTV_ID' ,'T_Application_Builds', @AB_ID, 166152,  '', '', '', @OldApplication_MTV_ID, @Application_MTV_ID, @OldApplication_MTV_ID, @Application_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldScheduleDate <> @ScheduleDate
		BEGIN
			exec [POMS_DB].[dbo].P_Add_Audit_History 'ScheduleDate' ,'T_Application_Builds', @AB_ID, 166152, '', '', '', @OldScheduleDate, @ScheduleDate, @OldScheduleDate, @ScheduleDate, '', 0, 167100, @UserName
		
		END

		IF @OldStatus_MTV_CODE <> @Status_MTV_CODE
		BEGIN
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Status_MTV_CODE' ,'T_Application_Builds', @AB_ID, 166152, '', '', '', @OldStatus_MTV_CODE, @Status_MTV_CODE, @OldStatus_MTV_CODE, @Status_MTV_CODE, '', 0, 167100, @UserName
		
		END
		IF @OldDescription <> @Description
		BEGIN
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Description' ,'T_Application_Builds', @AB_ID, 166152, '', '', '', @OldDescription, @Description, @Description, @OldDescription, '', 0, 167100, @UserName
		
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Application_Builds', @AB_ID, 166152, '', '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Application Build Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Application Build does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @BuildName <> '' 
	BEGIN
		
		DECLARE @BUILD_CODE nvarchar(50) = ''
		DECLARE @Build_Hash nvarchar(20) = ''

		exec [POMS_DB].[dbo].[P_Generate_BuildID] @Ret_BUILD_ID = @AB_ID out
		select @Build_Hash=[POMS_DB].[dbo].[F_Get_Build_ID] (0)
		select @BUILD_CODE=CONVERT(varchar(12), right(newid(),12))
		select @BUILD_CODE=right(@BUILD_CODE + @Build_Hash,12)
		set @BUILD_CODE = isnull(@BUILD_CODE,'')

		if @BUILD_CODE = '' or @AB_ID = 0
		begin
			SET @Return_Text = 'Unable to Generate Build Code'
			SET @Return_Code = 0
		end
		else
		begin
			INSERT INTO [POMS_DB].[dbo].T_Application_Builds (AB_ID, [BUILDCODE], BuildName, Application_MTV_ID, [Description] ,ScheduleDate, Status_MTV_CODE, IsActive, AddedBy, AddedOn) 
			VALUES (@AB_ID, @BUILD_CODE, @BuildName, @Application_MTV_ID, @Description, @ScheduleDate ,@Status_MTV_CODE, @IsActive, @Username, GETUTCDATE())
			SET @Return_Text = 'Application Builds Added Successfully!'
			SET @Return_Code = 1
		end
	END
	ELSE BEGIN
		SET @Return_Text = 'Application Builds Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
