USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_TaskAttachments]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC [P_Remove_TaskAttachments] 1,'Ihtisham.Ulhaq'
CREATE PROC [dbo].[P_Remove_TaskAttachments]
@TA_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TA_ID > 0 
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_TMS_TaskAttachments] WITH (NOLOCK) WHERE TA_ID = @TA_ID)
	BEGIN	    
	    UPDATE [POMS_DB].[dbo].[T_TMS_TaskAttachments] SET IsActive = 0 WHERE TA_ID = @TA_ID
		SET @Return_Text = 'Task Attachmen Remove Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Attachment does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Task Attachment ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END

GO
