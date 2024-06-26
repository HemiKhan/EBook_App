USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Chats_Update_IsRead]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--							EXEC [P_Chats_Update_IsRead] 0,2,1,'hIasdasd','HAMMAS.KHAN'
CREATE PROC [dbo].[P_Chats_Update_IsRead]
@CR_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @CR_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [dbo].[T_Chat_Room] WITH (NOLOCK) WHERE CR_ID = @CR_ID)
	BEGIN
		UPDATE [dbo].[T_Chats_User_Mapping]
		SET IsRead = 1, Read_At = GETUTCDATE(), ModifiedBy = @Username, ModifiedOn = GETUTCDATE() 
		WHERE C_ID IN (
			SELECT c.C_ID
			FROM [dbo].[T_Chat_Room] cr
			INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum ON cr.CR_ID = crum.CR_ID 
			INNER JOIN [dbo].[T_Chats] c ON crum.CRUM_ID = c.CRUM_ID
			INNER JOIN [dbo].[T_Chats_User_Mapping] cum ON c.C_ID = cum.C_ID
			WHERE cr.CR_ID = @CR_ID AND ISNULL(cum.IsRead,0) = 0 AND cum.Recieve_UserName = @Username);
		
		SET @Return_Text = @Username + ' Read Message Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Chat Room does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	SET @Return_Text = 'Chat Room Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
