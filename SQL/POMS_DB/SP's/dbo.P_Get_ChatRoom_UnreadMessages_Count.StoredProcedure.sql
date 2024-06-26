USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ChatRoom_UnreadMessages_Count]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--- exec [P_Get_ChatRoom_UnreadMessages_Count] 2, 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Get_ChatRoom_UnreadMessages_Count]
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
