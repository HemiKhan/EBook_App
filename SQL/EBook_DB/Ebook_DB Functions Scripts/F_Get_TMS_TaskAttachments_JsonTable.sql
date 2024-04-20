
 -- SELECT * FROM [dbo].[F_Get_TMS_TaskAttachments_JsonTable]()
CREATE FUNCTION [dbo].[F_Get_TMS_TaskAttachments_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
    TA_ID int,
	OriginalFileName nvarchar(500),
	[FileName] nvarchar(100),
	FileExt nvarchar(20),
	[Path] nvarchar(1000),
	DocumentType_MTV_ID int,
	AttachmentType_MTV_ID int ,
    REFID1 int ,
	REFID2 int,
	REFID3 int,
	REFID4 int,
	AttachmentsIsActive bit
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
     TA_ID  
	,OriginalFileName  
	,[FileName]  
	,FileExt  
	,[Path]  
	,DocumentType_MTV_ID  
	,AttachmentType_MTV_ID  
    ,REFID1  
	,REFID2  
	,REFID3  
	,REFID4  
	,AttachmentsIsActive 
		
    ) 
    SELECT 
     TA_ID  
	,OriginalFileName  
	,[FileName]  
	,FileExt  
	,[Path]  
	,DocumentType_MTV_ID  
	,AttachmentType_MTV_ID  
    ,REFID1  
	,REFID2  
	,REFID3  
	,REFID4  
	,AttachmentsIsActive 
		
    FROM OPENJSON(@Json)
    WITH (
	TA_ID int '$.TA_ID',
	OriginalFileName nvarchar(500) '$.OriginalFileName',
	[FileName] nvarchar(100) '$.FileName',
	FileExt nvarchar(20) '$.FileExt',
	[Path] nvarchar(1000) '$.Path',
	DocumentType_MTV_ID int'$.DocumentType_MTV_ID',
	AttachmentType_MTV_ID int '$.AttachmentType_MTV_ID',
    REFID1 int '$.REFID1',
	REFID2 int '$.REFID2',
	REFID3 int '$.REFID3',
	REFID4 int '$.REFID4',
	AttachmentsIsActive bit '$.Active'
		 
    )

    RETURN;
END;

 
GO
