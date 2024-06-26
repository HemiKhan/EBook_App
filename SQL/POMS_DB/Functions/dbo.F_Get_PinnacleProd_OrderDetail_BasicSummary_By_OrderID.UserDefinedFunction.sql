USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_BasicSummary_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_BasicSummary_By_OrderID] (10100640,'ABDULLAH.ARSHAD',2,1,13,147105)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_BasicSummary_By_OrderID]
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
, [FirstOfferTransitTime] int
, [ActualTransitTime] int
, [CallsAttempted] int
, [IsMWG] bit
, [IsItemAdded] bit
, [TotalQty] int
, [TotalValue] decimal(18,6)
, [TotalWeight] decimal(18,6)
, [TotalCubes] decimal(18,6)
, [TotalAssemblyMinutes] int
, [ShipFrom_MilesRadius] decimal(18,6)
, [ShipFrom_DrivingMiles] decimal(18,6)
, [ShipTo_MilesRadius] decimal(18,6)
, [ShipTo_DrivingMiles] decimal(18,6)
, [LineHaul_DrivingMiles] decimal(18,6)

, [FirstScanDate] datetime
, [FirstScanHub] nvarchar(20)
, [FirstScanHubName] nvarchar(50)
, [FirstFRBMDate] datetime
, [FirstFRBMHub] nvarchar(20)
, [FirstFRBMHubName] nvarchar(50)
, [FirstFileMileFRBMDate] datetime
, [FirstFileMileFRBMHub] nvarchar(20)
, [FirstFileMileFRBMHubName] nvarchar(50)
, [LastScanDate] datetime
, [LastScanHub] nvarchar(20)
, [LastScanHubName] nvarchar(50)
, [LastScanLocationID] nvarchar(20)
, [ShipToHub_FirstScanDate] datetime
, [ShipToZone_FirstScanDate] datetime
, [OriginDepartureDate] datetime
, [DlvAttemptCount] int
, [ReSchCount] int
)
AS
begin
	
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @FirstFileMileTable table
	(OrderNo nvarchar(20) collate Latin1_General_100_CS_AS
	,[FirstFileMileFRBMDate] datetime
	,[FirstFileMileFRBMHub] nvarchar(20)
	)
	insert into @FirstFileMileTable ([OrderNo] ,[FirstFileMileFRBMDate] ,[FirstFileMileFRBMHub])
	select od.OrderNo
	,[FirstFileMileFRBMDate] = (case when not exists(select top 1 oid.OrderNo from [PinnacleProd].[dbo].[Metro_OrderItem_Data] oid with (nolock) where oid.OrderNo = od.OrderNo and oid.DestHub_FirstScanDate is null)
		then (select min(oid.DestHub_FirstScanDate) from [PinnacleProd].[dbo].[Metro_OrderItem_Data] oid with (nolock) where oid.OrderNo = od.OrderNo)
		else null end)		
	,[FirstFileMileFRBMHub] = od.DestHub
	from [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) where od.OrderId = @ORDER_ID
	and od.[FirstFRBMDate] is not null and od.[DestHub_FirstScanDate] is not null

	insert into @ReturnTable ([ORDER_ID] , [FirstOfferTransitTime] , [ActualTransitTime] , [CallsAttempted] , [IsMWG] , [IsItemAdded] , [TotalQty] 
	, [TotalValue] , [TotalWeight] , [TotalCubes] , [TotalAssemblyMinutes] , [ShipFrom_MilesRadius] , [ShipFrom_DrivingMiles] , [ShipTo_MilesRadius] 
	, [ShipTo_DrivingMiles] , [LineHaul_DrivingMiles] , [FirstScanDate] , [FirstScanHub] , [FirstScanHubName] , [FirstFRBMDate] , [FirstFRBMHub] , [FirstFRBMHubName] 
	, [FirstFileMileFRBMDate] , [FirstFileMileFRBMHub] , [FirstFileMileFRBMHubName] , [LastScanDate] , [LastScanHub] , [LastScanHubName] , [LastScanLocationID] 
	, [ShipToHub_FirstScanDate] , [ShipToZone_FirstScanDate] , [OriginDepartureDate] , [DlvAttemptCount] , [ReSchCount])

	SELECT [ORDER_ID] = od.OrderId
	,[FirstOfferTransitTime] = 0 -- Need to Work On
	,[ActualTransitTime] = 0 -- Need to Work On
	,[CallsAttempted] = 0 -- Need to Work On
	,od.[IsMWG] 
	,od.[IsItemAdded] 
	,od.[TotalQty] 
	,od.[TotalValue] 
	,od.[TotalWeight] 
	,od.[TotalCubes] 
	,[TotalAssemblyMinutes] = od.TotalAssemblyTime
	,[ShipFrom_MilesRadius] = od.OrigMilesRadius
	,[ShipFrom_DrivingMiles] = od.OrigDrivingMiles
	,[ShipTo_MilesRadius] = od.DestMilesRadius
	,[ShipTo_DrivingMiles] = od.DestDrivingMiles
	,[LineHaul_DrivingMiles] = od.LHDrivingMiles
	,[FirstScanDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[FirstScanDate], @TimeZone_ID, null ,@TimeZoneName)
	,od.[FirstScanHub] ,[FirstScanHubName]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (od.[FirstScanHub])
	,[FirstFRBMDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[FirstFRBMDate], @TimeZone_ID, null ,@TimeZoneName)
	,od.[FirstFRBMHub] ,[FirstFRBMHubName]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (od.[FirstFRBMHub]) 
	,[FirstFileMileFRBMDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ffmt.[FirstFileMileFRBMDate], @TimeZone_ID, null ,@TimeZoneName)
	,[FirstFileMileFRBMHub] = ffmt.[FirstFileMileFRBMHub]
	,[FirstFileMileFRBMHubName] = [POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (ffmt.[FirstFileMileFRBMHub]) 
	,[LastScanDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[LastScanDate], @TimeZone_ID, null ,@TimeZoneName)
	,od.[LastScanHub] ,[LastScanHubName]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (od.[LastScanHub])
	,LastScanLocationID=od.[LastScanLocationID]
	,[ShipToHub_FirstScanDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DestHub_FirstScanDate], @TimeZone_ID, null ,@TimeZoneName)
	,[ShipToZone_FirstScanDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[DestZone_FirstScanDate], @TimeZone_ID, null ,@TimeZoneName)
	,[OriginDepartureDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (od.[OriginDepartureDate], @TimeZone_ID, null ,@TimeZoneName)
	,od.[DlvAttemptCount] 
	,od.[ReSchCount] 

	FROM [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) 
	left join @FirstFileMileTable ffmt on od.OrderNo = ffmt.OrderNo
	where od.OrderId = @ORDER_ID

	return
	

end
GO
