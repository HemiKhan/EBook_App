USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_OrderDetail_BasicSummary_By_GUID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_Get_OrderDetail_BasicSummary_By_GUID] '81476343-24DE-48B6-B53F-FDFDB66BC616',0,'ABDULLAH.ARSHAD',2,null,13,0,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode ,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Get_OrderDetail_BasicSummary_By_GUID]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@ReturnCode bit output
	,@ReturnText nvarchar(250) output
)

AS

BEGIN

set @ORDER_CODE_GUID = upper(@ORDER_CODE_GUID)
set @UserName = upper(@UserName)
set @ReturnCode = 0
set @ReturnText = ''

set @ORDER_ID = isnull(@ORDER_ID,0)

if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

if @ORDER_ID = 0
begin
	set @ReturnText = 'Invalid OrderID'
end
else
begin
	set @ReturnCode = 1
end

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

Declare @ReturnTable table
([OrderID] int

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
, [ShipFromMilesRadius] decimal(18,6)
, [ShipFromDrivingMiles] decimal(18,6)
, [ShipToMilesRadius] decimal(18,6)
, [ShipToDrivingMiles] decimal(18,6)
, [LineHaulDrivingMiles] decimal(18,6)

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
, [ShipToHubFirstScanDate] datetime
, [ShipToZoneFirstScanDate] datetime
, [OriginDepartureDate] datetime
, [DlvAttemptCount] int
, [ReSchCount] int
)

if @GetRecordType_MTV_ID = 147100
begin
	insert into @ReturnTable
	select ORDER_ID
	,FirstOfferTransitTime
	,ActualTransitTime
	,CallsAttempted
	,IsMWG
	,IsItemAdded
	,TotalQty
	,TotalValue
	,TotalWeight
	,TotalCubes
	,TotalAssemblyMinutes
	,ShipFrom_MilesRadius
	,ShipFrom_DrivingMiles
	,ShipTo_MilesRadius
	,ShipTo_DrivingMiles
	,LineHaul_DrivingMiles
	,FirstScanDate
	,FirstScanHub
	,FirstScanHubName
	,FirstFRBMDate
	,FirstFRBMHub
	,FirstFRBMHubName
	,FirstFileMileFRBMDate
	,FirstFileMileFRBMHub
	,FirstFileMileFRBMHubName
	,LastScanDate
	,LastScanHub
	,LastScanHubName
	,LastScanLocationID
	,ShipToHub_FirstScanDate
	,ShipToZone_FirstScanDate
	,OriginDepartureDate
	,DlvAttemptCount
	,ReSchCount
	from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_BasicSummary_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147101,147102)
begin
	insert into @ReturnTable
	select ORDER_ID
	,FirstOfferTransitTime
	,ActualTransitTime
	,CallsAttempted
	,IsMWG
	,IsItemAdded
	,TotalQty
	,TotalValue
	,TotalWeight
	,TotalCubes
	,TotalAssemblyMinutes
	,ShipFrom_MilesRadius
	,ShipFrom_DrivingMiles
	,ShipTo_MilesRadius
	,ShipTo_DrivingMiles
	,LineHaul_DrivingMiles
	,FirstScanDate
	,FirstScanHub
	,FirstScanHubName
	,FirstFRBMDate
	,FirstFRBMHub
	,FirstFRBMHubName
	,FirstFileMileFRBMDate
	,FirstFileMileFRBMHub
	,FirstFileMileFRBMHubName
	,LastScanDate
	,LastScanHub
	,LastScanHubName
	,LastScanLocationID
	,ShipToHub_FirstScanDate
	,ShipToZone_FirstScanDate
	,OriginDepartureDate
	,DlvAttemptCount
	,ReSchCount
	from [POMS_DB].[dbo].[F_Get_POMSArchive_OrderDetail_BasicSummary_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147103)
begin
	insert into @ReturnTable
	select ORDER_ID
	,FirstOfferTransitTime
	,ActualTransitTime
	,CallsAttempted
	,IsMWG
	,IsItemAdded
	,TotalQty
	,TotalValue
	,TotalWeight
	,TotalCubes
	,TotalAssemblyMinutes
	,ShipFrom_MilesRadius
	,ShipFrom_DrivingMiles
	,ShipTo_MilesRadius
	,ShipTo_DrivingMiles
	,LineHaul_DrivingMiles
	,FirstScanDate
	,FirstScanHub
	,FirstScanHubName
	,FirstFRBMDate
	,FirstFRBMHub
	,FirstFRBMHubName
	,FirstFileMileFRBMDate
	,FirstFileMileFRBMHub
	,FirstFileMileFRBMHubName
	,LastScanDate
	,LastScanHub
	,LastScanHubName
	,LastScanLocationID
	,ShipToHub_FirstScanDate
	,ShipToZone_FirstScanDate
	,OriginDepartureDate
	,DlvAttemptCount
	,ReSchCount
	from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_BasicSummary_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147104,147105)
begin
	insert into @ReturnTable
	select ORDER_ID
	,FirstOfferTransitTime
	,ActualTransitTime
	,CallsAttempted
	,IsMWG
	,IsItemAdded
	,TotalQty
	,TotalValue
	,TotalWeight
	,TotalCubes
	,TotalAssemblyMinutes
	,ShipFrom_MilesRadius
	,ShipFrom_DrivingMiles
	,ShipTo_MilesRadius
	,ShipTo_DrivingMiles
	,LineHaul_DrivingMiles
	,FirstScanDate
	,FirstScanHub
	,FirstScanHubName
	,FirstFRBMDate
	,FirstFRBMHub
	,FirstFRBMHubName
	,FirstFileMileFRBMDate
	,FirstFileMileFRBMHub
	,FirstFileMileFRBMHubName
	,LastScanDate
	,LastScanHub
	,LastScanHubName
	,LastScanLocationID
	,ShipToHub_FirstScanDate
	,ShipToZone_FirstScanDate
	,OriginDepartureDate
	,DlvAttemptCount
	,ReSchCount
	from [POMS_DB].[dbo].[F_Get_PinnacleProdArchive_OrderDetail_BasicSummary_By_OrderID] (@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end

if not exists(select * from @ReturnTable) and @ReturnText = ''
begin
	set @ReturnText = 'No Record Found'
end
else
begin
	set @ReturnCode = 1
end

select * from @ReturnTable

END
GO
