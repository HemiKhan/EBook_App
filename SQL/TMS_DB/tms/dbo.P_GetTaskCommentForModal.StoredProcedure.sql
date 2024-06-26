USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetTaskCommentForModal]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[P_GetTaskCommentForModal]
@TC_ID int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TC_ID, TD_ID, CommentText, Application_URL=Application_URL
,Task_Start_Date=Task_Start_Date
,Task_End_Date=Task_End_Date
,Priority_MTV_ID=Priority_MTV_ID
,Status_MTV_ID=Status_MTV_ID
,BUILDCODE=BUILDCODE
,TaskCategory_MTV_ID=TaskCategory_MTV_ID
,Review_Date=Review_Date
,ETA_Date=ETA_Date
,IsPrivate=IsPrivate
,Active = IsActive FROM [POMS_DB].[dbo].[T_TMS_TaskComments] WITH (NOLOCK) 
	WHERE TC_ID = @TC_ID
END
GO
