USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Chats]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--							EXEC [P_AddOrEdit_Chats] 0,2,1,'hIasdasd','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Chats]
@C_ID INT = NULL,
@CR_ID INT,
@CRUM_ID INT,
@Message nvarchar(MAX),
@Username nvarchar(150),
@Attachment_Path nvarchar(500) = null,
@Attachment_Ext nvarchar(500) = null,
@Attachment_Name nvarchar(500) = null,
@Attachment_FileSize BIGINT = null,
@Parent_C_ID INT = 0,
@Parent_C_ID_Image nvarchar(150) = null,
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @C_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Chats] WITH (NOLOCK) WHERE C_ID = @C_ID)
	BEGIN
	    
		DECLARE @OldMessage nvarchar(MAX)
		
		SELECT @OldMessage = [Message] FROM [POMS_DB].[dbo].[T_Chats] WITH (NOLOCK) WHERE C_ID = @C_ID
		
		UPDATE [POMS_DB].[dbo].[T_Chats] SET [Message] = @Message, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE C_ID = @C_ID
		
		IF @OldMessage <> @Message
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Message' ,'T_Chats', @CRUM_ID, 166113, @C_ID, '', '', @OldMessage, @Message, @OldMessage, @Message, '', 0, 167100, @Username
		END	

		SET @Return_Text = 'Message Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Message does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @CRUM_ID > 0 AND (@Message <> '' OR @Attachment_Path <> '') BEGIN
		DECLARE @Recieve_UserName NVARCHAR(150)
		DECLARE @Room_Type NVARCHAR(20)
		
		INSERT INTO [POMS_DB].[dbo].[T_Chats] (Parent_C_ID, CRUM_ID, Send_UserName, Parent_C_ID_Image, [Message], Attachment_Path, Attachment_Ext, Attachment_Name, Attachment_FileSize, IsActive, AddedBy, AddedOn) 
		VALUES (@Parent_C_ID, @CRUM_ID, @Username, @Parent_C_ID_Image, @Message, @Attachment_Path, @Attachment_Ext, @Attachment_Name, @Attachment_FileSize, 1, @Username, GETUTCDATE())
		SET @C_ID = SCOPE_IDENTITY()

		SELECT @Room_Type = Room_Type_MTV_CODE FROM [dbo].[T_Chat_Room] WITH (NOLOCK) WHERE IsActive = 1 AND CR_ID = @CR_ID
		IF @Room_Type = 'PRIVATE' BEGIN 
			SELECT @Recieve_UserName = UserName FROM [dbo].[T_Chat_Room_User_Mapping] WITH (NOLOCK) WHERE CR_ID = @CR_ID and UserName <> @Username
			--SELECT @Recieve_UserName = UserName FROM [dbo].[T_Chat_Room_User_Mapping] WITH (NOLOCK) WHERE CRUM_ID = @CRUM_ID
			INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) 
			VALUES (@C_ID, @Recieve_UserName, 0, 0, 0, NULL, 1, @Username, GETUTCDATE())
		END
		ELSE BEGIN 
			INSERT INTO [POMS_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) 
			SELECT C_ID = @C_ID, Recieve_UserName = UserName, IsRead = 0, IsBookmark = 0, IsFlag = 0, Read_At = NULL, IsActive = 1, AddedBy = @Username, AddedOn = GETUTCDATE()
			FROM [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK) INNER JOIN [dbo].[T_Chat_Room] cr WITH (NOLOCK) ON crum.CR_ID = cr.CR_ID 
			WHERE crum.CR_ID = @CR_ID AND UserName <> @Username
		END
		
		SET @Return_Text = 'Message Sent Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Message Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code, @C_ID as C_ID

END
GO
