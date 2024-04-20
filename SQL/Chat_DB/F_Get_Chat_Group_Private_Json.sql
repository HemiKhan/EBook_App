
-- SELECT [POMS_DB].[dbo].[F_Get_Chat_Group_Private_Json] (0,'HAMMAS.KHAN')
CREATE FUNCTION [dbo].[F_Get_Chat_Group_Private_Json]
(@CR_ID int, @Username nvarchar(150))
RETURNS nvarchar(max) 
AS
begin
	
	Declare @Return_Json nvarchar(max) = ''
	
	SELECT @Return_Json = (SELECT cr.CR_ID, cr.Room_Name,
    Room_Member_Json = (
        SELECT CRUM_ID,
               ChatMemeberName = UserName,
               IsHistoryAllowed,
               IsNotificationEnabled,
               IsAdmin,
               IsUserAddedAllowed,
               IsReadOnly,
			   IsOnline
        FROM [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK)
        WHERE crum.CR_ID = cr.CR_ID AND crum.UserName <> @Username AND crum.IsActive = 1
        FOR JSON PATH
    ) 
	FROM [dbo].[T_Chat_Room] cr WITH (NOLOCK)
	WHERE cr.CR_ID = @CR_ID AND cr.IsActive = 1
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	if @Return_Json is null
		begin set @Return_Json = '' end

	return @Return_Json

end
GO
