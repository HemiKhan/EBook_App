USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Event_List_By_EventActivityID_And_SubID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Event_List_By_EventActivityID_And_SubID] (null,null,null,1)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Event_List_By_EventActivityID_And_SubID]
(	
	@EventActivity_MTV_ID int
	,@SubEventActivity_MTV_ID int = null
	,@Username nvarchar(150) = null
	,@IsManualTriggerOnly bit = 1
)
returns @ReturnTable table
(EVENT_ID int
,EVENT_CODE nvarchar(20)
,[Name] nvarchar(250)
,Activity_MTV_ID int
,SubActivity_MTV_ID int
,IsAutoTrigger bit
,IsManualTrigger bit
)
AS
Begin
	
	insert into @ReturnTable
	select 
	EVENT_ID = el.EVENT_ID
	,EVENT_CODE = el.EVENT_CODE
	,[Name] = el.[Name]
	,Activity_MTV_ID = el.Activity_MTV_ID
	,SubActivity_MTV_ID = el.SubActivity_MTV_ID
	,IsAutoTrigger = el.IsAutoTrigger
	,IsManualTrigger = el.IsManualTrigger
	from [POMS_DB].[dbo].[T_Events_List] el with (nolock)
	inner join [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on el.Activity_MTV_ID = mtv.MTV_ID and mtv.MT_ID = 129 
	where el.IsActive = 1 and mtv.IsActive = 1 and (mtv.MTV_ID = @EventActivity_MTV_ID or @EventActivity_MTV_ID is null)
	and (el.SubActivity_MTV_ID = @SubEventActivity_MTV_ID or @SubEventActivity_MTV_ID is null)
	and (el.IsManualTrigger = @IsManualTriggerOnly or @IsManualTriggerOnly = 0)
	order by [Activity_MTV_ID],[Name]

	return

end
GO
