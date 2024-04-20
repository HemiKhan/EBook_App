USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Chat_Group_Private]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

DECLARE @Room_Type_MTV_CODE nvarchar(150) = 'PRIVATE'
DECLARE @grp_Room_Memeber_Json nvarchar(max) = '[{"CRUM_ID" : 0,"ChatMemeberName":"BABAR.ALI","IsHistoryAllowed":true,"IsNotificationEnabled":true,"IsAdmin":false,"IsUserAddedAllowed":false,"IsReadOnly":true,"IsOnline":false},{"CRUM_ID" : 0,"ChatMemeberName":"TAIMOOR.ALI","IsHistoryAllowed":true,"IsNotificationEnabled":true,"IsAdmin":false,"IsUserAddedAllowed":false,"IsReadOnly":true,"IsOnline":false}]'
DECLARE @pvt_Room_Memeber_Json nvarchar(max) = '[{"CRUM_ID" : 0,"ChatMemeberName": "TAIMOOR.ALI", "IsHistoryAllowed": true, "IsNotificationEnabled": true, "IsAdmin": true, "IsUserAddedAllowed": false, "IsReadOnly": false, "IsOnline": false }]'
DECLARE @Room_Memeber_Json nvarchar(max)
IF @Room_Type_MTV_CODE = 'PRIVATE' BEGIN SET @Room_Memeber_Json = @pvt_Room_Memeber_Json END ELSE BEGIN SET @Room_Memeber_Json = @grp_Room_Memeber_Json END
EXEC [P_AddOrEdit_Chat_Group_Private] 0,'TMS_1',@Room_Type_MTV_CODE,@Room_Memeber_Json,'HAMMAS.KHAN'

*/
CREATE PROC [dbo].[P_AddOrEdit_Chat_Group_Private]
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
			
			INSERT INTO [POMS_DB].[dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedBy,AddedOn) 
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

			INSERT INTO [POMS_DB].[dbo].[T_Chat_Room_User_Mapping] (CR_ID,UserName,IsHistoryAllowed,IsNotificationEnabled,IsAdmin,IsUserAddedAllowed,IsReadOnly,IsOnline,IsActive,AddedBy,AddedOn) 
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
