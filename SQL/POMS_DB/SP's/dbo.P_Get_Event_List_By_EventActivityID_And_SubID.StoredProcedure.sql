USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Event_List_By_EventActivityID_And_SubID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* ===============================================================
 exec [dbo].[P_Get_Event_List_By_EventActivityID_And_SubID] null,null,null,1
=============================================================== */

CREATE PROCEDURE [dbo].[P_Get_Event_List_By_EventActivityID_And_SubID]
(
	@EventActivity_MTV_ID int
	,@SubEventActivity_MTV_ID int = null
	,@Username nvarchar(150) = null
	,@IsManualTriggerOnly bit = 1
)

AS

BEGIN

	select EVENT_ID ,EVENT_CODE ,[Name] ,[Activity_MTV_ID] ,[SubActivity_MTV_ID] ,[IsAutoTrigger] ,[IsManualTrigger] from [POMS_DB].[dbo].[F_Get_Event_List_By_EventActivityID_And_SubID] (@EventActivity_MTV_ID,@SubEventActivity_MTV_ID,@Username,@IsManualTriggerOnly) order by [Activity_MTV_ID],[Name]

END
GO
