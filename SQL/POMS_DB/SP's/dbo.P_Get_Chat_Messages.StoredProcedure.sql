USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Chat_Messages]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--- exec P_Get_Chat_Messages 3, 'ABDULLAH.ARSHAD'
CREATE PROC [dbo].[P_Get_Chat_Messages]
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
