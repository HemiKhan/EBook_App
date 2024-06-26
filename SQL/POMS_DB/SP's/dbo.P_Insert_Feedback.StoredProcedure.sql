USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Insert_Feedback]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	EXEC P_Insert_Feedback '', 1, 'TOUSEEF.AHMAD', 'jhasgjfdsgajafghd' 

CREATE PROCEDURE [dbo].[P_Insert_Feedback]
	@MessageData NVARCHAR(MAX),
    @IsActive BIT,
    @UserName NVARCHAR(100),
	@ImageData NVARCHAR(4000)

AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

BEGIN
	IF @MessageData <> '' 
	BEGIN
	INSERT INTO  [POMS_DB].[dbo].[T_Feedback] (MessageData, IsActive, ImageData ,AddedBy, AddedOn)
    VALUES (@MessageData, @IsActive, @ImageData, @UserName, GETUTCDATE());		
	SET @Return_Text = 'FeedBack Inserted Successfully'
	SET @Return_Code = 1
	END
	ELSE 
	BEGIN
		SET @Return_Text = 'FeedBack does not Inserted!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
