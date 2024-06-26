USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskManagementSystem_JSON]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec P_Get_TaskManagementSystem_JSON 48,63

CREATE PROCEDURE [dbo].[P_Get_TaskManagementSystem_JSON]
(
    @T_ID INT,
    @TD_TD INT
)
AS
BEGIN
    DECLARE @Return_Json NVARCHAR(MAX)

    SELECT @Return_Json = (
        SELECT  
            t.T_ID,
            t.TaskName,
            t.Note,
            Application_ID=t.Application_MTV_ID,
            (
                SELECT 
                    td.TD_ID,
                    td.T_ID AS Task_ID,
                    td.Task_Item AS Item,
                    td.Task_Item_Detail AS Item_Detail,
                    td.Application_URL,
                    td.Task_Start_Date,
                    td.Task_End_Date,
                    Priority_MTV_Code = td.Priority_MTV_ID,
                    Status_MTV_Code = td.Status_MTV_ID,
                    BUILDCODE = td.BUILDCODE,
                    TaskCategory = td.TaskCategory_MTV_ID,
					Review_Date=td.Review_Date,
					ETA_Date=td.ETA_Date,
					LeadAssignTo=td.LeadAssignTo,
                    td.IsPrivate,
                    td.IsActive,
                    (
                        SELECT 
                            ta.TA_ID,
							[path] = ta.[Path],
                            REFID2 = ta.REFID2,
                            ta.[FileName],
                            ta.FileExt,
							DocumentType_MTV_ID=ta.DocumentType_MTV_ID,
							AttachmentType_MTV_ID=ta.AttachmentType_MTV_ID
                        FROM [POMS_DB].[dbo].[T_TMS_TaskAttachments] ta
                        WHERE ta.AttachmentType_MTV_ID = 179100 AND ta.REFID2 = @TD_TD AND ta.IsActive = 1
                        FOR JSON PATH
                    ) AS Attachments
                FROM [T_TMS_TaskDetail] td
                WHERE td.TD_ID = @TD_TD AND td.IsActive = 1
                FOR JSON PATH
            ) AS TaskItems
        FROM [POMS_DB].[dbo].[T_TMS_Tasks] t
        WHERE t.T_ID = @T_ID AND t.IsActive = 1
        FOR JSON PATH,WITHOUT_ARRAY_WRAPPER 
    );

    IF @Return_Json IS NULL
        SET @Return_Json = ''

    SELECT @Return_Json AS Return_Json -- Return the JSON as a result set instead of using RETURN statement
END;
GO
