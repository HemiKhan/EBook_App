
/*
DECLARE @Room_Type_MTV_CODE nvarchar(150) = 'PRIVATE'
DECLARE @grp_Room_Memeber_Json nvarchar(max) = '[{"CRUM_ID" : 0,"ChatMemeberName":"BABAR.ALI","IsHistoryAllowed":true,"IsNotificationEnabled":true,"IsAdmin":false,"IsUserAddedAllowed":false,"IsReadOnly":true,"IsOnline":false},{"CRUM_ID" : 0,"ChatMemeberName":"TAIMOOR.ALI","IsHistoryAllowed":true,"IsNotificationEnabled":true,"IsAdmin":false,"IsUserAddedAllowed":false,"IsReadOnly":true,"IsOnline":false}]'
DECLARE @pvt_Room_Memeber_Json nvarchar(max) = '[{"CRUM_ID" : 0,"ChatMemeberName": "TAIMOOR.ALI", "IsHistoryAllowed": true, "IsNotificationEnabled": true, "IsAdmin": true, "IsUserAddedAllowed": false, "IsReadOnly": false, "IsOnline": false }]'
DECLARE @Room_Memeber_Json nvarchar(max)
IF @Room_Type_MTV_CODE = 'PRIVATE' BEGIN SET @Room_Memeber_Json = @pvt_Room_Memeber_Json END ELSE BEGIN SET @Room_Memeber_Json = @grp_Room_Memeber_Json END
EXEC [P_AddOrEdit_Chat_Group_Private] 0,'TMS_1',@Room_Type_MTV_CODE,@Room_Memeber_Json,'HAMMAS.KHAN'
*/
CREATE OR ALTER PROC [dbo].[P_AddOrEdit_Chat_Group_Private]
@CR_ID INT,
@Room_Name nvarchar(150),
@Room_Type_MTV_CODE nvarchar(20),
@Room_Memeber_Json nvarchar(max),
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 0
	Declare @Return_Text nvarchar(1000)  = ''

IF @CR_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [dbo].[T_Chat_Room] WITH (NOLOCK) WHERE CR_ID = @CR_ID)
	BEGIN			
		SET @Return_Text = 'UPDATE IS PENDING....!'
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
	IF @Room_Name <> '' AND @Room_Type_MTV_CODE <> '' AND @Room_Memeber_Json <> ''
	BEGIN 	
		
		SELECT @Room_Type_MTV_CODE = Room_Type_MTV_CODE FROM [dbo].[T_Chat_Room] WITH (NOLOCK) WHERE IsActive = 1 AND CR_ID = @CR_ID
		IF @Room_Type_MTV_CODE = 'PRIVATE' BEGIN 
			DECLARE @ChatMemeberName NVARCHAR(150)			
			SET @ChatMemeberName = (SELECT TOP 1 ChatMemeberName FROM F_Get_Chat_Memebers_JsonTable(@Room_Memeber_Json))
			
			SET @Room_Name = @Username + ' - ' + @ChatMemeberName

			INSERT INTO [dbo].[T_Chat_Room] (Room_Name,Room_Type_MTV_CODE,IsPublic,IsActive,AddedBy,AddedOn) 
			VALUES(@Room_Name,@Room_Type_MTV_CODE,0,1,@Username,GETUTCDATE())
			SET @CR_ID = SCOPE_IDENTITY()
			
			INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedBy,AddedOn) 
			SELECT CR_ID, ChatMemeberName, IsHistoryAllowed, IsNotificationEnabled, IsAdmin, IsUserAddedAllowed, IsReadOnly, IsOnline, IsActive, AddedBy, AddedOn FROM (
				SELECT @CR_ID AS CR_ID, ChatMemeberName, IsHistoryAllowed, IsNotificationEnabled, IsAdmin, IsUserAddedAllowed, IsReadOnly, IsOnline, 1 AS IsActive, @Username AS AddedBy, GETUTCDATE() AS AddedOn
				FROM F_Get_Chat_Memebers_JsonTable(@Room_Memeber_Json) WHERE ChatMemeberName <> @Username
				UNION ALL
				SELECT @CR_ID, @Username, 1, 1, 1, 1, 0, 0, 1, @Username, GETUTCDATE()
				FROM F_Get_Chat_Memebers_JsonTable(@Room_Memeber_Json)
			) pvt

			SET @Return_Text = 'Direct Chat With ' + @ChatMemeberName
			SET @Return_Code = 1

		END
		ELSE BEGIN 			
			INSERT INTO [dbo].[T_Chat_Room] (Room_Name,Room_Type_MTV_CODE,IsPublic,IsActive,AddedBy,AddedOn) 
			VALUES(@Room_Name,@Room_Type_MTV_CODE,0,1,@Username,GETUTCDATE())
			SET @CR_ID = SCOPE_IDENTITY()

			INSERT INTO [dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedBy,AddedOn) 
			SELECT DISTINCT CR_ID, ChatMemeberName, IsHistoryAllowed, IsNotificationEnabled, IsAdmin, IsUserAddedAllowed, IsReadOnly, IsOnline, IsActive, AddedBy, AddedOn FROM (
				SELECT @CR_ID AS CR_ID, ChatMemeberName, IsHistoryAllowed, IsNotificationEnabled, IsAdmin, IsUserAddedAllowed, IsReadOnly, IsOnline, 1 AS IsActive, @Username AS AddedBy, GETUTCDATE() AS AddedOn
				FROM F_Get_Chat_Memebers_JsonTable(@Room_Memeber_Json) WHERE @Username <> ChatMemeberName
				UNION ALL
				SELECT @CR_ID, @Username, 1, 1, 1, 1, 0, 0, 1, @Username, GETUTCDATE()
				FROM F_Get_Chat_Memebers_JsonTable(@Room_Memeber_Json)
			) grp
			SET @Return_Text = 'Group Memebers Added!'
			SET @Return_Code = 1
		END
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

-- EXEC [P_AddOrEdit_Chats] 0,2,1,'hIasdasd','HAMMAS.KHAN'
CREATE OR ALTER PROC [dbo].[P_AddOrEdit_Chats]
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
	IF EXISTS (SELECT 1 FROM [dbo].[T_Chats] WITH (NOLOCK) WHERE C_ID = @C_ID)
	BEGIN
	    
		DECLARE @OldMessage nvarchar(MAX)
		
		SELECT @OldMessage = [Message] FROM [dbo].[T_Chats] WITH (NOLOCK) WHERE C_ID = @C_ID
		
		UPDATE [dbo].[T_Chats] SET [Message] = @Message, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE C_ID = @C_ID
		
		IF @OldMessage <> @Message
		BEGIN	
			exec [dbo].P_Add_Audit_History 'Message' ,'T_Chats', @CRUM_ID, 166113, @C_ID, '', '', @OldMessage, @Message, @OldMessage, @Message, '', 0, 167100, @Username
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
		
		INSERT INTO [dbo].[T_Chats] (Parent_C_ID, CRUM_ID, Send_UserName, Parent_C_ID_Image, [Message], Attachment_Path, Attachment_Ext, Attachment_Name, Attachment_FileSize, IsActive, AddedBy, AddedOn) 
		VALUES (@Parent_C_ID, @CRUM_ID, @Username, @Parent_C_ID_Image, @Message, @Attachment_Path, @Attachment_Ext, @Attachment_Name, @Attachment_FileSize, 1, @Username, GETUTCDATE())
		SET @C_ID = SCOPE_IDENTITY()

		SELECT @Room_Type = Room_Type_MTV_CODE FROM [dbo].[T_Chat_Room] WITH (NOLOCK) WHERE IsActive = 1 AND CR_ID = @CR_ID
		IF @Room_Type = 'PRIVATE' BEGIN 
			SELECT @Recieve_UserName = UserName FROM [dbo].[T_Chat_Room_User_Mapping] WITH (NOLOCK) WHERE CR_ID = @CR_ID and UserName <> @Username
			--SELECT @Recieve_UserName = UserName FROM [dbo].[T_Chat_Room_User_Mapping] WITH (NOLOCK) WHERE CRUM_ID = @CRUM_ID
			INSERT INTO [dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) 
			VALUES (@C_ID, @Recieve_UserName, 0, 0, 0, NULL, 1, @Username, GETUTCDATE())
		END
		ELSE BEGIN 
			INSERT INTO [dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) 
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

--EXEC [P_Chats_Update_IsRead] 0,2,1,'hIasdasd','HAMMAS.KHAN'
CREATE OR ALTER PROC [dbo].[P_Chats_Update_IsRead]
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

--	[P_Get_Chat_Dropdown_Lists] 'HAMMAS.KHAN'
CREATE OR ALTER PROCEDURE [dbo].[P_Get_Chat_Dropdown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	SELECT code = MTV_CODE, [name] = [Name] FROM [dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = 181 AND IsActive = 1 AND Name <> 'Public' ORDER BY Sort_
	
	SELECT code = USERNAME, name = CONCAT(FirstName,' ',LastName) FROM [dbo].[T_Users] WITH (NOLOCK) 
	WHERE USERNAME IN ('ABDULLAH.ARSHAD','HAMMAS.KHAN','BABAR.ALI','TAIMOOR.ALI','SAAD.QADIR','TOUSEEF.AHMAD','IHTISHAM.ULHAQ','MUSA.RAZA')
	AND USERNAME NOT IN (SELECT DISTINCT UserName FROM [dbo].[T_Chat_Room] cr WITH (NOLOCK) 
	INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK) ON cr.CR_ID = crum.CR_ID
	WHERE cr.AddedBy = @Username AND UserName <> 'All')
	
	SELECT code = USERNAME, name = CONCAT(FirstName,' ',LastName) FROM [dbo].[T_Users] WITH (NOLOCK) WHERE USERNAME IN ('ABDULLAH.ARSHAD','HAMMAS.KHAN','BABAR.ALI','TAIMOOR.ALI','SAAD.QADIR','TOUSEEF.AHMAD','IHTISHAM.ULHAQ','MUSA.RAZA') AND USERNAME <> @Username
END
GO

--- exec P_Get_Chat_Messages 3, 'ABDULLAH.ARSHAD'
CREATE OR ALTER PROC [dbo].[P_Get_Chat_Messages]
	 @CR_ID INT 
	,@UserName NVARCHAR(150) 
	,@C_ID int = null
AS
BEGIN

	SELECT cr.CR_ID, crum.CRUM_ID, c.C_ID, c.Parent_C_ID, c.Parent_C_ID_Image
	,cr.Room_Name
	,c.Send_UserName
	,UserName = @UserName
	,Message = ISNULL(c.Message,'')
	,Attachment_Path = REPLACE(ISNULL(c.Attachment_Path,''), 'wwwroot\', '..\')
	,Attachment_Ext = ISNULL(c.Attachment_Ext,'')
	,Attachment_Name = ISNULL(c.Attachment_Name,'')
	,Attachment_FileSize = ISNULL(c.Attachment_FileSize,0)
	,MsgOn = FORMAT(c.AddedOn,'hh:mm tt')
	,IsRead = (SELECT CASE WHEN COUNT(*) > 0 AND SUM(CAST(IsRead AS INT)) = COUNT(*) THEN 1 ELSE 0 END FROM [dbo].[T_Chats_User_Mapping] WHERE IsActive = 1 AND C_ID = c.C_ID AND Recieve_UserName <> @UserName)
	,c.IsEdited
	,c.EditedOn 
	FROM [dbo].[T_Chat_Room] cr WITH (NOLOCK)
	INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK) ON cr.CR_ID = crum.CR_ID 
	INNER JOIN [dbo].[T_Chats] c WITH (NOLOCK) ON crum.CRUM_ID = c.CRUM_ID
	--INNER JOIN [dbo].[T_Chats_User_Mapping] cum on cum.C_ID = c.C_ID and cum.IsActive = 1
	WHERE cr.CR_ID = @CR_ID AND c.IsActive = 1 --and (c.C_ID = @C_ID or @C_ID is null) --and cum.Recieve_UserName = @UserName
	ORDER BY c.AddedOn

END
GO

--- exec P_Get_Chat_Room 'HAMMAS.KHAN'
CREATE OR ALTER PROC [dbo].[P_Get_Chat_Room]
	@UserName nvarchar(150) 
AS
BEGIN

	SELECT
	 cr.Room_Type_MTV_CODE
	 ,RoomType = rt.[Name]
	 ,ChatRoomDetails = (
		SELECT CR_ID, CRUM_ID, Room_Name, UserName, IsHistoryAllowed, IsNotificationEnabled, IsAdmin, IsUserAddedAllowed, IsReadOnly, IsOnline
		FROM (SELECT chatroom.Room_Type_MTV_CODE, chatroom.CR_ID,
			crum.CRUM_ID,
			--CRUM_ID = (CASE WHEN chatroom.Room_Type_MTV_CODE = 'PRIVATE' THEN crum2.CRUM_ID ELSE crum.CRUM_ID END),
			Room_Name = (CASE WHEN chatroom.Room_Type_MTV_CODE = 'PRIVATE' THEN chatroom.Room_Name ELSE crum.UserName END),
			UserName = (CASE WHEN chatroom.Room_Type_MTV_CODE = 'PRIVATE' THEN crum2.UserName ELSE chatroom.Room_Name END),
			crum.IsHistoryAllowed, crum.IsNotificationEnabled, crum.IsAdmin, crum.IsUserAddedAllowed, crum.IsReadOnly, crum.IsOnline, crum.AddedOn
		FROM [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK)
		INNER JOIN [dbo].[T_Chat_Room] chatroom WITH (NOLOCK) ON crum.CR_ID = chatroom.CR_ID
		LEFT JOIN [dbo].[T_Chat_Room_User_Mapping] crum2 WITH (NOLOCK) ON chatroom.Room_Type_MTV_CODE = 'PRIVATE' AND crum.CR_ID = crum2.CR_ID AND crum2.UserName <> @UserName
		WHERE (chatroom.Room_Type_MTV_CODE = 'PRIVATE' AND crum.UserName = @UserName) OR (chatroom.Room_Type_MTV_CODE = 'GROUP' AND crum.UserName = @UserName) OR (chatroom.Room_Type_MTV_CODE = 'PUBLIC')
		GROUP BY chatroom.CR_ID,crum.CRUM_ID,crum2.CRUM_ID,chatroom.Room_Name,crum.UserName,crum2.UserName,crum.IsHistoryAllowed,crum.IsNotificationEnabled,crum.IsAdmin,crum.IsUserAddedAllowed,crum.IsReadOnly,crum.IsOnline,crum.AddedOn, chatroom.Room_Type_MTV_CODE
		) a WHERE Room_Type_MTV_CODE = cr.Room_Type_MTV_CODE ORDER BY AddedOn DESC
		FOR JSON PATH) 
	FROM [dbo].[T_Chat_Room] cr WITH (NOLOCK)
	INNER JOIN [dbo].[T_Master_Type_Value] rt WITH (NOLOCK) ON cr.Room_Type_MTV_CODE = rt.MTV_CODE
	WHERE cr.IsActive = 1 
	GROUP BY cr.Room_Type_MTV_CODE,rt.[Name]
	ORDER BY cr.Room_Type_MTV_CODE ASC 
	FOR JSON PATH

END
GO

--- exec [P_Get_ChatRoom_UnreadMessages_Count] 2, 'HAMMAS.KHAN'
CREATE OR ALTER PROC [dbo].[P_Get_ChatRoom_UnreadMessages_Count]
	@CR_ID INT,
	@UserName nvarchar(150) 
AS
BEGIN

	SELECT UnreadMessages = COUNT(c.C_ID)  
	FROM [dbo].[T_Chat_Room] cr
	INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum ON cr.CR_ID = crum.CR_ID 
	INNER JOIN [dbo].[T_Chats] c ON crum.CRUM_ID = c.CRUM_ID
	INNER JOIN [dbo].[T_Chats_User_Mapping] cum ON c.C_ID = cum.C_ID
	WHERE cr.CR_ID = @CR_ID AND Recieve_UserName = @UserName AND IsRead = 0

END
GO