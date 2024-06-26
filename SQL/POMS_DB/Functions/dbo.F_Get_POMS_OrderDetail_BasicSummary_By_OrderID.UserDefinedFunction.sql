USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_BasicSummary_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_BasicSummary_By_OrderID] (10100640,'ABDULLAH.ARSHAD',2,1,13)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_BasicSummary_By_OrderID]
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

	insert into @ReturnTable ([ORDER_ID] , [FirstOfferTransitTime] , [ActualTransitTime] , [CallsAttempted] , [IsMWG] , [IsItemAdded] , [TotalQty] 
	, [TotalValue] , [TotalWeight] , [TotalCubes] , [TotalAssemblyMinutes] , [ShipFrom_MilesRadius] , [ShipFrom_DrivingMiles] , [ShipTo_MilesRadius] 
	, [ShipTo_DrivingMiles] , [LineHaul_DrivingMiles] , [FirstScanDate] , [FirstScanHub] , [FirstScanHubName] , [FirstFRBMDate] , [FirstFRBMHub] , [FirstFRBMHubName] 
	, [FirstFileMileFRBMDate] , [FirstFileMileFRBMHub] , [FirstFileMileFRBMHubName] , [LastScanDate] , [LastScanHub] , [LastScanHubName] , [LastScanLocationID] 
	, [ShipToHub_FirstScanDate] , [ShipToZone_FirstScanDate] , [OriginDepartureDate] , [DlvAttemptCount] , [ReSchCount])

	SELECT od.[ORDER_ID] ,[FirstOfferTransitTime] = 0 -- Need to Work On
	,[ActualTransitTime] = 0 -- Need to Work On
	,[CallsAttempted] = 0 -- Need to Work On
	,od.[IsMWG] 
	,od.[IsItemAdded] 
	,od.[TotalQty] 
	,od.[TotalValue] 
	,od.[TotalWeight] 
	,od.[TotalCubes] 
	,od.[TotalAssemblyMinutes] 
	,od.[ShipFrom_MilesRadius] 
	,od.[ShipFrom_DrivingMiles] 
	,od.[ShipTo_MilesRadius] 
	,od.[ShipTo_DrivingMiles] 
	,od.[LineHaul_DrivingMiles] 
	,[FirstScanDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odi.[FirstScanDate], @TimeZone_ID, null ,@TimeZoneName)
	,odi.[FirstScanHub] ,[FirstScanHubName]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (odi.[FirstScanHub])
	,[FirstFRBMDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odi.[FirstFRBMDate], @TimeZone_ID, null ,@TimeZoneName)
	,odi.[FirstFRBMHub] ,[FirstFRBMHubName]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (odi.[FirstFRBMHub]) 
	,[FirstFileMileFRBMDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odi.[FirstFileMileFRBMDate], @TimeZone_ID, null ,@TimeZoneName)
	,odi.[FirstFileMileFRBMHub] ,[FirstFileMileFRBMHubName]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (odi.[FirstFileMileFRBMHub])
	,[LastScanDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odi.[LastScanDate], @TimeZone_ID, null ,@TimeZoneName)
	,odi.[LastScanHub] ,[LastScanHubName]=[POMS_DB].[dbo].[F_Get_HubName_From_HubCode] (odi.[LastScanHub])
	,LastScanLocationID=odi.[LastScanLocationID]
	,[ShipToHub_FirstScanDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odi.[ShipToHub_FirstScanDate], @TimeZone_ID, null ,@TimeZoneName)
	,[ShipToZone_FirstScanDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odi.[ShipToZone_FirstScanDate], @TimeZone_ID, null ,@TimeZoneName)
	,[OriginDepartureDate] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (odi.[OriginDepartureDate], @TimeZone_ID, null ,@TimeZoneName)
	,odi.[DlvAttemptCount] 
	,odi.[ReSchCount] 

	FROM [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) 
	left join [POMS_DB].[dbo].[T_Order_Additional_Info] odi with (nolock) on od.ORDER_ID = odi.ORDER_ID
	where od.ORDER_ID = @ORDER_ID

	return
	

end
GO
