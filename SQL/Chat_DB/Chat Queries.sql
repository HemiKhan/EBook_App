DECLARE @UserName nvarchar(150)  = 'IHTISHAM.ULHAQ'
DECLARE @CR_ID INT

SET @CR_ID = 3
SET @CR_ID = 2


SELECT UnreadMessages = COUNT(c.C_ID)  
FROM [dbo].[T_Chat_Room] cr
INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum ON cr.CR_ID = crum.CR_ID 
INNER JOIN [dbo].[T_Chats] c ON crum.CRUM_ID = c.CRUM_ID
INNER JOIN [dbo].[T_Chats_User_Mapping] cum ON c.C_ID = cum.C_ID
WHERE cr.CR_ID = @CR_ID AND Recieve_UserName = @UserName AND IsRead = 0

SELECT crum.CRUM_ID
FROM [dbo].[T_Chat_Room] cr
INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum ON cr.CR_ID = crum.CR_ID 
WHERE cr.CR_ID = @CR_ID AND crum.UserName <> @UserName

SELECT * FROM [T_Chat_Room] WHERE CR_ID = @CR_ID

SELECT * FROM [T_Chat_Room_User_Mapping] WHERE CR_ID = @CR_ID

SELECT c.* 
FROM [dbo].[T_Chat_Room] cr
INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum ON cr.CR_ID = crum.CR_ID 
INNER JOIN [dbo].[T_Chats] c ON crum.CRUM_ID = c.CRUM_ID
WHERE cr.CR_ID = @CR_ID

SELECT * FROM [dbo].[T_Chats_User_Mapping] 
WHERE C_ID IN (SELECT c.C_ID 
FROM [dbo].[T_Chat_Room] cr
INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum ON cr.CR_ID = crum.CR_ID 
INNER JOIN [dbo].[T_Chats] c ON crum.CRUM_ID = c.CRUM_ID
INNER JOIN [dbo].[T_Chats_User_Mapping] cum ON c.C_ID = cum.C_ID
WHERE cr.CR_ID = @CR_ID)







