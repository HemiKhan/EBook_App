USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_TaskAssignedToList]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC [P_Remove_ApplicationBuilds] 0,'IHTISHAM.ULHAQ'
Create PROC [dbo].[P_Remove_TaskAssignedToList]
@TAL_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TAL_ID > 0 
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_AssignedTo_List] WITH (NOLOCK) WHERE TAL_ID = @TAL_ID)
	BEGIN	    
		SELECT @IsActive = IsActive FROM [POMS_DB].[dbo].[T_TMS_AssignedTo_List] WITH (NOLOCK) WHERE TAL_ID = @TAL_ID
		IF @IsActive = 0 BEGIN		
			UPDATE [POMS_DB].[dbo].[T_TMS_AssignedTo_List] SET IsActive = 1 WHERE TAL_ID = @TAL_ID
		SET @Return_Text = 'Task Assigned To List ACTIVE Successfully!'
		SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [POMS_DB].[dbo].[T_TMS_AssignedTo_List] SET IsActive = 0 WHERE TAL_ID = @TAL_ID
			SET @Return_Text = 'Task Assigned To List IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Assigned To List does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Task Assigned To List ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
