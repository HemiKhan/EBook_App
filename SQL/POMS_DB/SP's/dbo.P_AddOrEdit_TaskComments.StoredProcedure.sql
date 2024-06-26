USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TaskComments]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_TaskComments 'Test','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_TaskComments]
@TC_ID INT = NULL,
@TD_ID INT,
@CommentText NVARCHAR(MAX),
@Application_URL int,
@Task_Start_Date DATE,
@Task_End_Date DATE,
@Priority_MTV_ID INT,
@Status_MTV_ID INT,
@BUILDCODE NVARCHAR(50),
@TaskCategory_MTV_ID INT,
@Review_Date DATE,
@ETA_Date DATE,
@IsPrivate BIT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
       
    Declare @Priority_MTV_Name nvarchar(150)
	Declare @Status_MTV_Name nvarchar(150)
	Declare @BUILDName NVARCHAR(250)
	Declare @TaskCategory_MTV_Name nvarchar(150)
  
	DECLARE @OldTD_ID INT
	DECLARE @OldCommentText NVARCHAR(MAX)
	DECLARE @OldApplication_URL int
	DECLARE @OldTask_Start_Date DATE
	DECLARE @OldTask_End_Date DATE
	DECLARE @OldPriority_MTV_ID INT
	DECLARE @OldPriority_MTV_Name nvarchar(150)
	DECLARE @OldStatus_MTV_ID INT
	DECLARE @OldStatus_MTV_Name nvarchar(150)
	DECLARE @OldBUILDCODE nvarchar(50)
	DECLARE @OldBUILDName nvarchar(250)
	DECLARE @OldTaskCategory_MTV_ID int
	DECLARE @OldTaskCategory_MTV_Name nvarchar(150)
	DECLARE @OldReview_Date DATE
	DECLARE @OldETA_Date DATE
	DECLARE @OldIsPrivate BIT
	DECLARE @OldActive BIT
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TC_ID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_TaskComments] WHERE TC_ID = @TC_ID)
	BEGIN
	    
		SELECT @OldTD_ID = TD_ID, @OldCommentText = CommentText, @Application_URL = Application_URL, @OldTask_Start_Date = Task_Start_Date, @OldTask_End_Date = Task_End_Date, @OldPriority_MTV_ID = Priority_MTV_ID, @OldStatus_MTV_ID = Status_MTV_ID, @OldBUILDCODE = BUILDCODE, @OldTaskCategory_MTV_ID = TaskCategory_MTV_ID
		, @OldReview_Date = Review_Date, @OldETA_Date = ETA_Date, @OldIsPrivate = IsPrivate, @OldActive = IsActive FROM [POMS_DB].[dbo].[T_TMS_TaskComments] WHERE TC_ID = @TC_ID
		
		UPDATE [POMS_DB].[dbo].[T_TMS_TaskComments] 
		SET TD_ID = @TD_ID, CommentText = @CommentText, Application_URL = @Application_URL, Task_Start_Date = @Task_Start_Date, Task_End_Date = @Task_End_Date, Priority_MTV_ID = @Priority_MTV_ID, Status_MTV_ID = @Status_MTV_ID, BUILDCODE = @BUILDCODE
		,TaskCategory_MTV_ID = @TaskCategory_MTV_ID ,Review_Date = @Review_Date ,ETA_Date = @ETA_Date , IsPrivate = @IsPrivate, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE()
		WHERE TC_ID = @TC_ID
		
		IF @OldTD_ID <> @TD_ID
		BEGIN	
			exec P_Add_Audit_History 'TD_ID' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldTD_ID, @TD_ID, @OldTD_ID, @TD_ID, '', 0, 167100, @UserName
		END

		IF @OldCommentText <> @CommentText
		BEGIN	
			exec P_Add_Audit_History 'CommentText' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldCommentText, @CommentText, @OldCommentText, @CommentText, '', 0, 167100, @UserName
		END
		
		IF @OldApplication_URL <> @Application_URL
		BEGIN	
			exec P_Add_Audit_History 'Application_URL' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldApplication_URL, @Application_URL, @Application_URL, @Application_URL, '', 0, 167100, @UserName
		END

		IF @OldTask_Start_Date <> @Task_Start_Date
		BEGIN	
			exec P_Add_Audit_History 'Task_Start_Date' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldTask_Start_Date, @Task_Start_Date, @OldTask_Start_Date, @Task_Start_Date, '', 0, 167100, @UserName
		END

		IF @OldTask_End_Date <> @Task_End_Date
		BEGIN	
			exec P_Add_Audit_History 'Task_End_Date' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldTask_End_Date, @Task_End_Date, @OldTask_End_Date, @Task_End_Date, '', 0, 167100, @UserName
		END

		IF @OldTaskCategory_MTV_ID <> @TaskCategory_MTV_ID
		BEGIN
			Select @OldTaskCategory_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldTaskCategory_MTV_ID), @TaskCategory_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@TaskCategory_MTV_ID)
			exec P_Add_Audit_History 'TaskCategory_MTV_ID' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldTaskCategory_MTV_ID, @TaskCategory_MTV_ID, @OldTaskCategory_MTV_Name, @TaskCategory_MTV_Name, '', 0, 167100, @UserName
		END

		IF @OldPriority_MTV_ID <> @Priority_MTV_ID
		BEGIN
			Select @OldPriority_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldPriority_MTV_ID), @Priority_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@Priority_MTV_ID)
			exec P_Add_Audit_History 'Priority_MTV_ID' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldPriority_MTV_ID, @Priority_MTV_ID, @OldPriority_MTV_Name, @Priority_MTV_Name, '', 0, 167100, @UserName
		END

		IF @OldStatus_MTV_ID <> @Status_MTV_ID
		BEGIN	
			Select @OldStatus_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldStatus_MTV_ID), @Status_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@Status_MTV_ID)
			exec P_Add_Audit_History 'Status_MTV_ID' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldStatus_MTV_ID, @Status_MTV_ID, @OldStatus_MTV_ID, @Status_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldBUILDCODE <> @BUILDCODE
		BEGIN	
			Select @OldBUILDName = @OldBUILDCODE, @BUILDName = @BUILDCODE  -- Need to Workin On
			exec P_Add_Audit_History 'BUILDCODE' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldBUILDCODE, @BUILDCODE, @OldBUILDName, @BUILDName, '', 0, 167100, @UserName
		END

		IF @OldReview_Date <> @Review_Date
		BEGIN	
			exec P_Add_Audit_History 'Review_Date' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldReview_Date, @Review_Date, @OldReview_Date, @Review_Date, '', 0, 167100, @UserName
		END

		IF @OldETA_Date <> @ETA_Date
		BEGIN	
			exec P_Add_Audit_History 'ETA_Date' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldETA_Date, @ETA_Date, @OldETA_Date, @ETA_Date, '', 0, 167100, @UserName
		END

		IF @OldIsPrivate <> @IsPrivate
		BEGIN
			Declare @OldIsPrivateText nvarchar(10) = (case when @OldIsPrivate = 1 then 'Yes' else 'No' end)
			Declare @IsPrivateText nvarchar(10) = (case when @IsPrivate = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsPrivate' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldIsPrivate, @IsPrivate, @OldIsPrivateText, @IsPrivateText, '', 0, 167100, @UserName
		END	



		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Task Assigned Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Assigned does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @TD_ID > 0 AND @CommentText <> '' BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_TMS_TaskComments] (TD_ID, CommentText,Application_URL, Task_Start_Date, Task_End_Date, Priority_MTV_ID, Status_MTV_ID, BUILDCODE, TaskCategory_MTV_ID, Review_Date, ETA_Date, IsPrivate, IsActive, AddedBy, AddedOn) 
		VALUES (@TD_ID, @CommentText,@Application_URL, @Task_Start_Date, @Task_End_Date, @Priority_MTV_ID, @Status_MTV_ID, @BUILDCODE, @TaskCategory_MTV_ID, @Review_Date, @ETA_Date, @IsPrivate, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Task Comment Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Task Comment Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
