USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Tasks]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_Tasks 0, 148100,'Test','test',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Tasks]
@T_ID INT = NULL,
@Application_MTV_ID INT,
@TaskName NVARCHAR(200),
@Note NVARCHAR(MAX),
--@OutTID int output,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''

AS
BEGIN
	DECLARE @OldApplication_MTV_ID INT
	DECLARE @OldTaskName NVARCHAR(200)
    DECLARE @OldNote NVARCHAR(max)
	DECLARE @OldActive BIT
	Declare @T_ID_Return int
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @T_ID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_Tasks] with (nolock) WHERE T_ID = @T_ID)
	BEGIN
	    
		SELECT @OldTaskName = TaskName, @OldApplication_MTV_ID = Application_MTV_ID,@OldNote=Note, @OldActive = IsActive FROM [POMS_DB].[dbo].[T_TMS_Tasks] with (nolock) WHERE T_ID = @T_ID
		
		UPDATE [POMS_DB].[dbo].[T_TMS_Tasks] SET TaskName = @TaskName, Application_MTV_ID = @Application_MTV_ID, Note = @Note, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE T_ID = @T_ID
		
		set @T_ID_Return=0;
		IF @OldTaskName <> @TaskName
		BEGIN	
			exec P_Add_Audit_History 'TaskName' ,'T_TMS_Tasks', @T_ID, 166144, '', '', '', @OldTaskName, @TaskName, @OldTaskName, @TaskName, '', 0, 167100, @UserName
		END

		IF @OldApplication_MTV_ID <> @Application_MTV_ID
		BEGIN	
			exec P_Add_Audit_History 'Application_MTV_ID' ,'T_TMS_Tasks', @T_ID, 166144, '', '', '', @OldApplication_MTV_ID, @Application_MTV_ID, @OldApplication_MTV_ID, @Application_MTV_ID, '', 0, 167100, @UserName
		END
		IF @OldNote <> @Note
		BEGIN	
			exec P_Add_Audit_History 'Note' ,'T_TMS_Tasks', @T_ID, 166144, '', '', '', @OldNote, @Note, @OldNote, @Note, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_TMS_Tasks', @T_ID, 166144, '', '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Task Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @TaskName <> '' BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_TMS_Tasks] (Application_MTV_ID, TaskName, Note, IsActive, AddedBy, AddedOn) 
		VALUES (@Application_MTV_ID, @TaskName, @Note, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Task Added Successfully!'
		SET @Return_Code = 1
		Set @T_ID_Return =SCOPE_IDENTITY();
	END
	ELSE BEGIN
		SET @Return_Text = 'Task Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code,@T_ID_Return As T_ID

END
GO
