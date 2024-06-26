USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_ArchiveDetail_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Pinnacle_ArchiveDetail_By_OrderID] (10100640,'ABDULLAH.ARSHAD',2,1,13,0)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_ArchiveDetail_By_OrderID]
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
, [Order_ArchiveDate] date
, [Order_Detail_ArchiveDate] date
, [Order_Additional_Info_ArchiveDate] date
, [Order_Items_ArchiveDate] date
, [Order_Items_Additional_Info_ArchiveDate] date
, [Order_Access_Log_ArchiveDate] date
, [Order_Audit_History_ArchiveDate] date
, [Order_Client_Identifier_ArchiveDate] date
, [Order_Comments_ArchiveDate] date
, [Order_Docs_ArchiveDate] date
, [Order_Events_ArchiveDate] date
, [Order_Events_List_ArchiveDate] date
, [Order_Item_Scans_ArchiveDate] date
, [Order_Related_Tickets_ArchiveDate] date
, [Order_Special_Instruction_ArchiveDate] date
, [Order_Special_Service_ArchiveDate] date
)
AS
begin
	
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	--MTV_ID	MT_ID	Name
	--147100	147		POMS Data
	--147101	147		POMS Archive Data
	--147102	147		POMS & Archive Data
	--147103	147		Pinnacle Data
	--147104	147		Pinnacle Archive Data
	--147105	147		Pinnacle & Archive Data

	insert into @ReturnTable ([ORDER_ID] , [Order_ArchiveDate] , [Order_Detail_ArchiveDate] 
	, [Order_Additional_Info_ArchiveDate] , [Order_Items_ArchiveDate] , [Order_Items_Additional_Info_ArchiveDate] , [Order_Access_Log_ArchiveDate] 
	, [Order_Audit_History_ArchiveDate] , [Order_Client_Identifier_ArchiveDate] , [Order_Comments_ArchiveDate] , [Order_Docs_ArchiveDate] 
	, [Order_Events_ArchiveDate] , [Order_Events_List_ArchiveDate] , [Order_Item_Scans_ArchiveDate] , [Order_Related_Tickets_ArchiveDate] 
	, [Order_Special_Instruction_ArchiveDate] , [Order_Special_Service_ArchiveDate])

	SELECT [ORDER_ID] = od.OrderId
	,[Order_ArchiveDate]= [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Detail_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Additional_Info_ArchiveDate] =[POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Items_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Items_Additional_Info_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Access_Log_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oas.AccessLog_ArchiveDt , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Audit_History_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oas.AuditHistory_ArchiveDt  , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Client_Identifier_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Comments_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oas.Comments_ArchiveDt  , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Docs_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Events_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oas.EventLog_ArchiveDt , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Events_List_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oas.EventLog_ArchiveDt, @TimeZone_ID , null , @TimeZoneName)
	,[Order_Item_Scans_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oas.ScanHistory_ArchiveDt , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Related_Tickets_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Special_Instruction_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)
	,[Order_Special_Service_ArchiveDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DateArchived] , @TimeZone_ID , null , @TimeZoneName)

	FROM [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) 
	left join [PinnacleProd].[dbo].[Metropolitan_OrderArchivalSummary] oas with (nolock) on od.OrderNo = oas.OrderNo
	where od.OrderId = @ORDER_ID

	return

end
GO
