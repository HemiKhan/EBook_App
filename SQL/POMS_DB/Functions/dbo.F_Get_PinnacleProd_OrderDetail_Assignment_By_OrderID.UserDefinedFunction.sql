USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_Assignment_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_Assignment_By_OrderID] (3251652,'ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_Assignment_By_OrderID]
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
	
	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	insert into @ReturnTable ([ORDER_ID] , [CurrentAssignToDept_MTV_CODE] , [CurrentAssignToDept_Name] , [OEDAssignTo] , [OEDAssignToDateTime] , [OEDStatus_MTV_ID] , [OEDStatus_Name] 
	, [OEDStatusDateTime] , [OEDCompletedDateTime] , [OEDFollowUpDateTime] , [OEDFollowUPCount] , [CSRAssignTo] , [CSRAssignToDateTime] , [CSRStatus_MTV_ID] 
	, [CSRStatus_Name] , [CSRStatusDateTime] , [CSRCompletedDateTime] , [CSRFollowUpDateTime] , [CSRFollowUpCount] , [DispatchAssignTo] 
	, [DispatchAssignToDateTime] , [DispatchStatus_MTV_ID] , [DispatchStatus_Name] , [DispatchStatusDateTime] , [DispatchCompletedDateTime] 
	, [DispatchFollowUpDateTime] , [DispatchFollowUpCount] , [AccountAssignTo] , [AccountAssignToDateTime] , [AccountStatus_MTV_ID] , [AccountStatus_Name] 
	, [AccountStatusDateTime] , [AccountCompletedDateTime] , [AccountFollowUpDateTime] , [AccountFollowUpCount])

	SELECT [ORDER_ID] = @ORDER_ID 
	,[CurrentAssignToDept_MTV_CODE] = (case sl.[Current Assigned Dept_]
		when 10000 then 'OED'
		when 20000 then 'CSR'
		when 30000 then 'DISPATCH'
		when 40000 then 'ACCOUNT'
		else '' end)
	,[CurrentAssignToDept_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10020 and mtv.[ID] = sl.[Current Assigned Dept_]), '')
	,[OEDAssignTo] = oat.FullName
	,[OEDAssignToDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[OED Assign Date], @TimeZone_ID, null ,@TimeZoneName)
	,[OEDStatus_MTV_ID] = sl.[OED Status] 
	,[OEDStatus_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10030 and mtv.[ID] = sl.[OED Status]), '')
	,[OEDStatusDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[OED Status Time], @TimeZone_ID, null ,@TimeZoneName)
	,[OEDCompletedDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[OED Completed On], @TimeZone_ID, null ,@TimeZoneName)
	,[OEDFollowUpDateTime] = null -- Not Available
	,[OEDFollowUPCount] = 0 -- Not Available
	,[CSRAssignTo] = cat.FullName
	,[CSRAssignToDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[CSR Assign Date], @TimeZone_ID, null ,@TimeZoneName)
	,[CSRStatus_MTV_ID] = sl.[CSR Status] 
	,[CSRStatus_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10050 and mtv.[ID] = sl.[CSR Status]), '')
	,[CSRStatusDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[CSR Status Time], @TimeZone_ID, null ,@TimeZoneName)
	,[CSRCompletedDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[CSR Completed On], @TimeZone_ID, null ,@TimeZoneName)
	,[CSRFollowUpDateTime] = null -- Not Available
	,[CSRFollowUpCount] = sl.[CSR Follow Up Call] 
	,[DispatchAssignTo] = dat.FullName
	,[DispatchAssignToDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[Dispatch Assign Date], @TimeZone_ID, null ,@TimeZoneName)
	,[DispatchStatus_MTV_ID] = sl.[Dispatch Status] 
	,[DispatchStatus_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10040 and mtv.[ID] = sl.[Dispatch Status]), '')
	,[DispatchStatusDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[Dispatch Status Time], @TimeZone_ID, null ,@TimeZoneName)
	,[DispatchCompletedDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[Dispatch Completed On], @TimeZone_ID, null ,@TimeZoneName)
	,[DispatchFollowUpDateTime] = null -- Not Available
	,[DispatchFollowUpCount] = 0 -- Not Available
	,[AccountAssignTo] = aat.FullName
	,[AccountAssignToDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[Accounting Assign Date], @TimeZone_ID, null ,@TimeZoneName)
	,[AccountStatus_MTV_ID] = sl.[Accounting Status] 
	,[AccountStatus_Name]=isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10060 and mtv.[ID] = sl.[Accounting Status]), '')
	,[AccountStatusDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[Accounting Status Time], @TimeZone_ID, null ,@TimeZoneName)
	,[AccountCompletedDateTime] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (sl.[Accounting Completed On], @TimeZone_ID, null ,@TimeZoneName)
	,[AccountFollowUpDateTime] = null -- Not Available
	,[AccountFollowUpCount] = 0 -- Not Available
	
	FROM [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) 
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (sl.[OED Assign To]) oat
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (sl.[CSR Assign To]) cat
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (sl.[Disptach Assign To]) dat
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (sl.[Accounting Assign To]) aat
	where sl.[Document No] = @ORDER_NO

	return
	

end
GO
