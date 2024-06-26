USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_LinkedTasks]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [P_Remove_LinkedTasks] 102,99,'IHTISHAM.ULHAQ'
--select * from T_TMS_LinkedTasks
CREATE PROC [dbo].[P_Remove_LinkedTasks]
@ParentTask_ID INT,
@LinkedTask_TD Int,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @ParentTask_ID > 0  And  @LinkedTask_TD > 0
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_LinkedTasks] WITH (NOLOCK) WHERE (Parent_TD = @ParentTask_ID AND LinkedTask_TD = @LinkedTask_TD) OR (Parent_TD = @LinkedTask_TD AND LinkedTask_TD = @ParentTask_ID))
	BEGIN	    
		SELECT @IsActive = IsActive FROM [POMS_DB].[dbo].[T_TMS_LinkedTasks] WITH (NOLOCK) WHERE (Parent_TD = @ParentTask_ID AND LinkedTask_TD = @LinkedTask_TD) OR (Parent_TD = @LinkedTask_TD AND LinkedTask_TD = @ParentTask_ID)
		IF @IsActive = 0 BEGIN		
			UPDATE [POMS_DB].[dbo].[T_TMS_LinkedTasks] SET IsActive = 1 WHERE (Parent_TD = @ParentTask_ID AND LinkedTask_TD = @LinkedTask_TD) OR (Parent_TD = @LinkedTask_TD AND LinkedTask_TD = @ParentTask_ID)
		SET @Return_Text = 'Task Linked Successfully!'
		SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [POMS_DB].[dbo].[T_TMS_LinkedTasks] SET IsActive = 0 WHERE (Parent_TD = @ParentTask_ID AND LinkedTask_TD = @LinkedTask_TD) OR (Parent_TD = @LinkedTask_TD AND LinkedTask_TD = @ParentTask_ID)
			SET @Return_Text = 'Task Linked IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Linked does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Task ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END


  
GO
