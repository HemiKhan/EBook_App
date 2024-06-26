USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetTaskDetailsModal]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[P_GetTaskDetailsModal]
@TD_ID int
As
Begin
SELECT TD_ID, T_ID, Task_Item, Task_Item_Detail, Application_URL, Task_Start_Date, Task_End_Date, Priority_MTV_ID, Status_MTV_ID, BUILDCODE, TaskCategory_MTV_ID, Review_Date, ETA_Date ,LeadAssignTo, IsPrivate, Active = IsActive
FROM [POMS_DB].[dbo].[T_TMS_TaskDetail] WITH (NOLOCK) WHERE TD_ID = @TD_ID
End
GO
