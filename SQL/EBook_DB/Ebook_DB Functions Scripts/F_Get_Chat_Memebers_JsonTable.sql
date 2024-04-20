
--	SELECT * FROM [dbo].[F_Get_Chat_Memebers_JsonTable]('')
CREATE FUNCTION [dbo].[F_Get_Chat_Memebers_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
	 CRUM_ID int 
	,ChatMemeberName nvarchar(150) 
	,IsHistoryAllowed bit 
	,IsNotificationEnabled bit 
	,IsAdmin bit 
	,IsUserAddedAllowed bit 
	,IsReadOnly bit 
	,IsOnline bit  
)
BEGIN
    SET @Json = ISNULL(@Json, '')

    IF @Json = ''
    BEGIN
        RETURN
    END
    ELSE
    BEGIN
        IF ISJSON(@Json) = 0
        BEGIN
            RETURN
        END
    END

	INSERT INTO @ReturnTable (CRUM_ID
							 ,ChatMemeberName
							 ,IsHistoryAllowed
							 ,IsNotificationEnabled
							 ,IsAdmin  
							 ,IsUserAddedAllowed  
							 ,IsReadOnly  
							 ,IsOnline) 
	SELECT
		CRUM_ID
		,ChatMemeberName
		,IsHistoryAllowed
		,IsNotificationEnabled
		,IsAdmin  
		,IsUserAddedAllowed  
		,IsReadOnly  
		,IsOnline
		 FROM OPENJSON(@Json)
    WITH (CRUM_ID int '$.CRUM_ID'
		,ChatMemeberName nvarchar(150) '$.ChatMemeberName'
		,IsHistoryAllowed bit '$.IsHistoryAllowed'
		,IsNotificationEnabled bit '$.IsNotificationEnabled'
		,IsAdmin bit '$.IsAdmin'
		,IsUserAddedAllowed bit '$.IsUserAddedAllowed'
		,IsReadOnly bit '$.IsReadOnly'
		,IsOnline bit '$.IsOnline')

	 RETURN 
END;

 
GO