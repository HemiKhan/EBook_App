USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TaskDetail]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_TaskDetail 'Test','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_TaskDetail]
@TD_ID INT = NULL,
@T_ID INT,
@Task_Item NVARCHAR(500),
@Task_Item_Detail NVARCHAR(MAX),
@Application_URL int,
@Task_Start_Date DATE,
@Task_End_Date DATE,
@Priority_MTV_ID INT,
@Status_MTV_ID INT,
@BUILDCODE NVARCHAR(50),
@TaskCategory_MTV_ID INT,
@Review_Date DATE,
@ETA_Date DATE,
@LeadAssignTo nvarchar(150),
@IsPrivate BIT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN

	Declare @Priority_MTV_Name nvarchar(150)
	Declare @Status_MTV_Name nvarchar(150)
	Declare @BuildName NVARCHAR(250)
	Declare @TaskCategory_MTV_Name nvarchar(150)

	DECLARE @OldT_ID INT
	DECLARE @TD_IDReturn INT
	DECLARE @OldTask_Item NVARCHAR(500)
	DECLARE @OldTask_Item_Detail NVARCHAR(MAX)
	DECLARE @OldApplication_URL int
	DECLARE @OldTask_Start_Date DATE
	DECLARE @OldTask_End_Date DATE
	DECLARE @OldPriority_MTV_ID INT
	DECLARE @OldPriority_MTV_Name nvarchar(150)
	DECLARE @OldStatus_MTV_ID INT
	DECLARE @OldStatus_MTV_Name nvarchar(150)
	DECLARE @OldBUILDCODE nvarchar(50)
	DECLARE @OldBuildName nvarchar(250)
	DECLARE @OldTaskCategory_MTV_ID int
	DECLARE @OldTaskCategory_MTV_Name nvarchar(150)
	DECLARE @OldReview_Date DATE
	DECLARE @OldETA_Date DATE
	DECLARE @OldLeadAssignTo nvarchar(150)
	DECLARE @OldIsPrivate BIT
	DECLARE @OldActive BIT
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TD_ID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_TaskDetail] WHERE TD_ID = @TD_ID)
	BEGIN
	    
		SELECT @OldT_ID = T_ID, @OldTask_Item = Task_Item, @OldTask_Item_Detail = Task_Item_Detail, @OldApplication_URL = Application_URL, @OldTask_Start_Date = Task_Start_Date, @OldTask_End_Date = Task_End_Date, @OldPriority_MTV_ID = Priority_MTV_ID, @OldStatus_MTV_ID = Status_MTV_ID, @OldBUILDCODE = BUILDCODE, @OldTaskCategory_MTV_ID = TaskCategory_MTV_ID
		, @OldReview_Date = Review_Date, @OldETA_Date = ETA_Date, @OldLeadAssignTo = LeadAssignTo, @OldIsPrivate = IsPrivate, @OldActive = IsActive FROM [POMS_DB].[dbo].[T_TMS_TaskDetail] WHERE TD_ID = @TD_ID
		
		UPDATE [POMS_DB].[dbo].[T_TMS_TaskDetail] 
		SET Task_Item = @Task_Item, Task_Item_Detail = @Task_Item_Detail, Application_URL = @Application_URL, Task_Start_Date = @Task_Start_Date, Task_End_Date = @Task_End_Date, Priority_MTV_ID = @Priority_MTV_ID, Status_MTV_ID = @Status_MTV_ID, BUILDCODE = @BUILDCODE
		,TaskCategory_MTV_ID = @TaskCategory_MTV_ID ,Review_Date = @Review_Date ,ETA_Date = @ETA_Date ,LeadAssignTo = @LeadAssignTo, IsPrivate = @IsPrivate, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE TD_ID = @TD_ID
		
		IF @OldT_ID <> @T_ID
		BEGIN	
			exec P_Add_Audit_History 'T_ID' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldT_ID, @T_ID, @OldT_ID, @T_ID, '', 0, 167100, @UserName
		END

		IF @OldTask_Item <> @Task_Item
		BEGIN	
			exec P_Add_Audit_History 'Task_Item' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTask_Item, @Task_Item, @OldTask_Item, @Task_Item, '', 0, 167100, @UserName
		END

		IF @OldTask_Item_Detail <> @Task_Item_Detail
		BEGIN	
			exec P_Add_Audit_History 'Task_Item_Detail' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTask_Item_Detail, @Task_Item_Detail, @OldTask_Item_Detail, @Task_Item_Detail, '', 0, 167100, @UserName
		END

		IF @OldApplication_URL <> @Application_URL
		BEGIN	
			exec P_Add_Audit_History 'Application_URL' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldApplication_URL, @Application_URL, @OldApplication_URL, @Application_URL, '', 0, 167100, @UserName
		END

		IF @OldTask_Start_Date <> @Task_Start_Date
		BEGIN	
			exec P_Add_Audit_History 'Task_Start_Date' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTask_Start_Date, @Task_Start_Date, @OldTask_Start_Date, @Task_Start_Date, '', 0, 167100, @UserName
		END

		IF @OldTask_End_Date <> @Task_End_Date
		BEGIN	
			exec P_Add_Audit_History 'Task_End_Date' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTask_End_Date, @Task_End_Date, @OldTask_End_Date, @Task_End_Date, '', 0, 167100, @UserName
		END

		IF @OldTaskCategory_MTV_ID <> @TaskCategory_MTV_ID
		BEGIN
			Select @OldTaskCategory_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldTaskCategory_MTV_ID), @TaskCategory_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@TaskCategory_MTV_ID)
			exec P_Add_Audit_History 'TaskCategory_MTV_ID' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTaskCategory_MTV_ID, @TaskCategory_MTV_ID, @OldTaskCategory_MTV_Name, @TaskCategory_MTV_Name, '', 0, 167100, @UserName
		END

		IF @OldPriority_MTV_ID <> @Priority_MTV_ID
		BEGIN
			Select @OldPriority_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldPriority_MTV_ID), @Priority_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@Priority_MTV_ID)
			exec P_Add_Audit_History 'Priority_MTV_ID' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldPriority_MTV_ID, @Priority_MTV_ID, @OldPriority_MTV_Name, @Priority_MTV_Name, '', 0, 167100, @UserName
		END

		IF @OldStatus_MTV_ID <> @Status_MTV_ID
		BEGIN	
			Select @OldStatus_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldStatus_MTV_ID), @Status_MTV_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@Status_MTV_ID)
			exec P_Add_Audit_History 'Status_MTV_ID' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldStatus_MTV_ID, @Status_MTV_ID, @OldStatus_MTV_ID, @Status_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldBUILDCODE <> @BUILDCODE
		BEGIN	
			Select @OldBuildName = @OldBUILDCode, @BuildName = @BUILDCODE  -- Need to Workin On
			exec P_Add_Audit_History 'BUILDCODE' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldBUILDCODE, @BUILDCODE, @OldBuildName, @BuildName, '', 0, 167100, @UserName
		END

		IF @OldReview_Date <> @Review_Date
		BEGIN	
			exec P_Add_Audit_History 'Review_Date' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldReview_Date, @Review_Date, @OldReview_Date, @Review_Date, '', 0, 167100, @UserName
		END

		IF @OldETA_Date <> @ETA_Date
		BEGIN	
			exec P_Add_Audit_History 'ETA_Date' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldETA_Date, @ETA_Date, @OldETA_Date, @ETA_Date, '', 0, 167100, @UserName
		END

		IF @OldLeadAssignTo <> @LeadAssignTo
		BEGIN	
			exec P_Add_Audit_History 'LeadAssignTo' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldLeadAssignTo, @LeadAssignTo, @OldLeadAssignTo, @LeadAssignTo, '', 0, 167100, @UserName
		END

		IF @OldIsPrivate <> @IsPrivate
		BEGIN
			Declare @OldIsPrivateText nvarchar(10) = (case when @OldIsPrivate = 1 then 'Yes' else 'No' end)
			Declare @IsPrivateText nvarchar(10) = (case when @IsPrivate = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsPrivate' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldIsPrivate, @IsPrivate, @OldIsPrivateText, @IsPrivateText, '', 0, 167100, @UserName
		END	

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Task Detail Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Detail does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @T_ID > 0 AND @Task_Item <> '' BEGIN
		--IF ISNULL(@TaskCategory,'') = '' BEGIN set @TaskCategory = 'Public' END
		INSERT INTO [POMS_DB].[dbo].[T_TMS_TaskDetail] (T_ID, Task_Item, Task_Item_Detail, Application_URL, Task_Start_Date, Task_End_Date, Priority_MTV_ID, Status_MTV_ID, BUILDCODE, TaskCategory_MTV_ID, Review_Date, ETA_Date, LeadAssignTo, IsPrivate, IsActive, AddedBy, AddedOn) 
		VALUES (@T_ID, @Task_Item, @Task_Item_Detail, @Application_URL, @Task_Start_Date, @Task_End_Date, @Priority_MTV_ID, @Status_MTV_ID, @BUILDCODE, @TaskCategory_MTV_ID, @Review_Date, @ETA_Date, @LeadAssignTo, @IsPrivate, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Task Detail Added Successfully!'
		SET @Return_Code = 1
		set @TD_IDReturn=SCOPE_IDENTITY()
	END
	ELSE BEGIN
		SET @Return_Text = 'Task Detail Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code,@TD_IDReturn

END
GO
