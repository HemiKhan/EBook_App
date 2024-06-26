USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Chat_Memebers_JsonTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
