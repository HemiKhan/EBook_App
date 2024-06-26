USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_Assignment_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_Assignment_By_OrderID] (10100640,'ABDULLAH.ARSHAD',2,1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_Assignment_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([ORDER_ID] int
, [CurrentAssignToDept_MTV_CODE] nvarchar(20)
, [CurrentAssignToDept_Name] nvarchar(50)
, [OEDAssignTo] nvarchar(150)
, [OEDAssignToDateTime] datetime
, [OEDStatus_MTV_ID] int
, [OEDStatus_Name] nvarchar(50)
, [OEDStatusDateTime] datetime
, [OEDCompletedDateTime] datetime
, [OEDFollowUpDateTime] datetime
, [OEDFollowUPCount] int
, [CSRAssignTo] nvarchar(150)
, [CSRAssignToDateTime] datetime
, [CSRStatus_MTV_ID] int
, [CSRStatus_Name] nvarchar(50)
, [CSRStatusDateTime] datetime
, [CSRCompletedDateTime] datetime
, [CSRFollowUpDateTime] datetime
, [CSRFollowUpCount] int
, [DispatchAssignTo] nvarchar(150)
, [DispatchAssignToDateTime] datetime
, [DispatchStatus_MTV_ID] int
, [DispatchStatus_Name] nvarchar(50)
, [DispatchStatusDateTime] datetime
, [DispatchCompletedDateTime] datetime
, [DispatchFollowUpDateTime] datetime
, [DispatchFollowUpCount] int
, [AccountAssignTo] nvarchar(150)
, [AccountAssignToDateTime] datetime
, [AccountStatus_MTV_ID] int
, [AccountStatus_Name] nvarchar(50)
, [AccountStatusDateTime] datetime
, [AccountCompletedDateTime] datetime
, [AccountFollowUpDateTime] datetime
, [AccountFollowUpCount] int
)
AS
begin
	
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	insert into @ReturnTable ([ORDER_ID] , [CurrentAssignToDept_MTV_CODE] , [CurrentAssignToDept_Name] , [OEDAssignTo] , [OEDAssignToDateTime] , [OEDStatus_MTV_ID] , [OEDStatus_Name] 
	, [OEDStatusDateTime] , [OEDCompletedDateTime] , [OEDFollowUpDateTime] , [OEDFollowUPCount] , [CSRAssignTo] , [CSRAssignToDateTime] , [CSRStatus_MTV_ID] 
	, [CSRStatus_Name] , [CSRStatusDateTime] , [CSRCompletedDateTime] , [CSRFollowUpDateTime] , [CSRFollowUpCount] , [DispatchAssignTo] 
	, [DispatchAssignToDateTime] , [DispatchStatus_MTV_ID] , [DispatchStatus_Name] , [DispatchStatusDateTime] , [DispatchCompletedDateTime] 
	, [DispatchFollowUpDateTime] , [DispatchFollowUpCount] , [AccountAssignTo] , [AccountAssignToDateTime] , [AccountStatus_MTV_ID] , [AccountStatus_Name] 
	, [AccountStatusDateTime] , [AccountCompletedDateTime] , [AccountFollowUpDateTime] , [AccountFollowUpCount])

	SELECT od.[ORDER_ID] 
	,od.[CurrentAssignToDept_MTV_CODE] ,[CurrentAssignToDept_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (od.[CurrentAssignToDept_MTV_CODE])
	,[OEDAssignTo] = oat.FullName
	,[OEDAssignToDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[OEDAssignToDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,od.[OEDStatus_MTV_ID] ,[OEDStatus_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (od.[OEDStatus_MTV_ID])
	,[OEDStatusDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[OEDStatusDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,[OEDCompletedDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[OEDCompletedDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,[OEDFollowUpDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[OEDFollowUpDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,od.[OEDFollowUPCount] 
	,[CSRAssignTo] = cat.FullName
	,[CSRAssignToDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[CSRAssignToDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,od.[CSRStatus_MTV_ID] ,[CSRStatus_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (od.[CSRStatus_MTV_ID])
	,[CSRStatusDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[CSRStatusDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,[CSRCompletedDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[CSRCompletedDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,[CSRFollowUpDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[CSRFollowUpDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,od.[CSRFollowUpCount] 
	,[DispatchAssignTo] = dat.FullName
	,[DispatchAssignToDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DispatchAssignToDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,od.[DispatchStatus_MTV_ID] ,[DispatchStatus_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (od.[DispatchStatus_MTV_ID])
	,[DispatchStatusDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DispatchStatusDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,[DispatchCompletedDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DispatchCompletedDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,[DispatchFollowUpDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DispatchFollowUpDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,od.[DispatchFollowUpCount] 
	,[AccountAssignTo] = aat.FullName
	,[AccountAssignToDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[AccountAssignToDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,od.[AccountStatus_MTV_ID] 
	,[AccountStatus_Name]=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (od.[AccountStatus_MTV_ID])
	,[AccountStatusDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[AccountStatusDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,[AccountCompletedDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[AccountCompletedDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,[AccountFollowUpDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[AccountFollowUpDateTime], @TimeZone_ID, null ,@TimeZoneName)
	,od.[AccountFollowUpCount] 
	
	FROM [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) 
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (od.[OEDAssignTo]) oat
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (od.[CSRAssignTo]) cat
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (od.[DispatchAssignTo]) dat
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (od.[AccountAssignTo]) aat
	where od.ORDER_ID = @ORDER_ID

	return
	

end
GO
