USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Chat_Room]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--- exec P_Get_Chat_Room 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Get_Chat_Room]
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
