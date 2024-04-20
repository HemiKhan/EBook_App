--	SELECT * FROM [dbo].[F_Get_T_TMS_Tasks_JsonTable]()
CREATE FUNCTION [dbo].[F_Get_T_TMS_Tasks_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(		 
 T_ID int
,Application_MTV_ID int
,TaskName nvarchar(Max)
,Note nvarchar(Max)
,TaskActive bit
,TaskItemsJson nvarchar(max)		 
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

	insert into @ReturnTable (
		 
		 T_ID
		,Application_MTV_ID 
		,TaskName 
		,Note
		,TaskActive
		,TaskItemsJson
		 
		) 
		select 
		 
		 T_ID
		,Application_MTV_ID 
		,TaskName 
		,Note 
		,TaskActive
		,TaskItemsJson
		 FROM OPENJSON(@Json)
    WITH (
		 
		 T_ID int '$.T_ID'
		,Application_MTV_ID int '$.Application_ID'
		,TaskName nvarchar(500) '$.TaskName'
		,Note nvarchar(Max) '$.Note'
		,TaskActive bit '$.Active'
		,TaskItemsJson Nvarchar(max) '$.TaskItems'  as Json 
		);
	 RETURN  ;
END;

 
GO
