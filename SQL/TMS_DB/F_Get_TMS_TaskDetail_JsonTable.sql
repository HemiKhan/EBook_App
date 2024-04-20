-- SELECT * FROM [dbo].[F_Get_TMS_TaskDetail_JsonTable]('')
  CREATE FUNCTION [dbo].[F_Get_TMS_TaskDetail_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(   TD_ID int,
    Task_Item nvarchar(1000),
    Task_Item_Detail nvarchar(Max),
    Application_URL int,
    Task_Start_Date Date,
    Task_End_Date Date,
	Priority_MTV_Code int,
	Status_MTV_Code int,
	BUILDCODE nvarchar(50),
    TaskCategory_MTV_ID int,
	Review_Date Date,
	ETA_Date Date,
	LeadAssignTo nvarchar(150),
    IsPrivate bit,
	TaskDetailActive bit,
    AttachmentsJson nvarchar(max)
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

    INSERT INTO @ReturnTable (
		TD_ID,
        Task_Item,
        Task_Item_Detail,
        Application_URL,
        Task_Start_Date,
        Task_End_Date,
		Priority_MTV_Code,
		Status_MTV_Code ,
        BUILDCODE,  
		TaskCategory_MTV_ID , 
		Review_Date, 
		ETA_Date , 
		LeadAssignTo ,
		IsPrivate , 
		TaskDetailActive,
        AttachmentsJson
    ) 
    SELECT 
		TD_ID,
        Task_Item,
        Task_Item_Detail,
        Application_URL,
        Task_Start_Date,
        Task_End_Date,
		Priority_MTV_Code,
		Status_MTV_Code ,
		BUILDCODE,  
        TaskCategory_MTV_ID , 
		Review_Date, 
		ETA_Date , 
		LeadAssignTo ,
		IsPrivate , 
		TaskDetailActive,
        AttachmentsJson
    FROM OPENJSON(@Json)
    WITH (
	    TD_ID int '$.TD_ID',
        Task_Item nvarchar(1000) '$.TaskItemName',
        Task_Item_Detail nvarchar(Max) '$.TaskDetail',
		Application_URL int '$.Application_URL',
        Task_Start_Date Date '$.StartDate',
        Task_End_Date Date '$.EndDate',
		Priority_MTV_Code int '$.Priority_MTV_Code',
		Status_MTV_Code int '$.Status_MTV_Code',
		BUILDCODE nvarchar(100) '$.BUILDCODE',
        TaskCategory_MTV_ID int '$.TaskCategory_MTV_ID',
        Review_Date Date '$.Review_Date',
		ETA_Date Date '$.ETA_Date',
		LeadAssignTo nvarchar(150) '$.LeadAssignTo',
		IsPrivate bit '$.IsPrivate',
		TaskDetailActive bit '$.Active',
        AttachmentsJson nvarchar(max) '$.Attachments' AS JSON
    )

    RETURN;
END;


 
GO
