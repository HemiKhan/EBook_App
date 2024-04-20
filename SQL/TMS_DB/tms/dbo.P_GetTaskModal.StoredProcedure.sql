USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetTaskModal]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[P_GetTaskModal]
@T_ID int 
As
Begin
SELECT T_ID, Application_MTV_ID, TaskName, Note, IsActive Active FROM [POMS_DB].[dbo].[T_TMS_Tasks] with (nolock) WHERE T_ID = @T_ID
End
GO
