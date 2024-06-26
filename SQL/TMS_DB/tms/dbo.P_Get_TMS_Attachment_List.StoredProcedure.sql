USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TMS_Attachment_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--		EXEC [P_Get_TMS_Attachment_List] 9

CREATE PROCEDURE [dbo].[P_Get_TMS_Attachment_List]
    @TD_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  
	 
	  
	 ta.TA_ID
	,ta.OriginalFileName
	,ta.[FileName]
	,ta.FileExt
	,ta.[Path]
	,ta.REFID2
	From [POMS_DB].[dbo].[T_TMS_TaskAttachments] ta  WITH (NOLOCK) 
	WHERE 	 
	ta.IsActive = 1 
	AND ta.REFID2 = @TD_ID
	
END;
GO
