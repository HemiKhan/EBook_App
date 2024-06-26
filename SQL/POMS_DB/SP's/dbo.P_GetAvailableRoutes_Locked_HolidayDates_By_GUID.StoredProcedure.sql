USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetAvailableRoutes_Locked_HolidayDates_By_GUID]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--==============================================================================================
-- Declare @RetReturnCode bit = 0 Declare @RetReturnText nvarchar(1000) = '' exec [POMS_DB].[dbo].[P_GetAvailableRoutes_Locked_HolidayDates_By_GUID] '', 10100781, 1 , 0, 1, 1, 1, 166100, 'ABDULLAH.ARSHAD', 'METRO-USER', null, 13, 147100, @ReturnCode = @RetReturnCode out, @ReturnText = @RetReturnText out Select @RetReturnCode ,@RetReturnText 
--==============================================================================================

CREATE PROCEDURE [dbo].[P_GetAvailableRoutes_Locked_HolidayDates_By_GUID] 
(
	
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int

	,@IsGetExistingInfo bit
	,@IsPickup bit
	,@EnableBackDates bit
	,@EnableCurrentDate bit
	,@EnableAllDates bit

	,@Source_MTV_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@ReturnCode bit output
	,@ReturnText nvarchar(1000) output
)

AS

BEGIN 

set @ORDER_CODE_GUID = upper(@ORDER_CODE_GUID)
set @UserName = upper(@UserName)
set @ReturnCode = 0
set @ReturnText = ''
set @IsGetExistingInfo = isnull(@IsGetExistingInfo,0)
set @IsPickup = isnull(@IsPickup,0)
set @EnableBackDates = isnull(@EnableBackDates,0)
set @EnableCurrentDate = isnull(@EnableCurrentDate,0)
set @EnableAllDates = isnull(@EnableAllDates,0)

set @ORDER_ID = isnull(@ORDER_ID,0)

if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

Declare @ReturnTable table
(ORDER_ID int default 0
,ReturnCode bit default 0
,ReturnText nvarchar(250) default ''
,UserName nvarchar(150) default ''
)

if @ORDER_ID = 0
begin
	set @ReturnText = 'Invalid OrderID'
	select * from @ReturnTable
	return
end

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

if @GetRecordType_MTV_ID in (147100,147102)
begin

	Declare @StartDate date = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (getutcdate(),@TimeZone_ID,null,null)
	Declare @ZipCode nvarchar(10) = ''
	Declare @RouteType int = (case when @IsPickup = 1 then 185100 else 185101 end)
	Declare @ScheduleDate date = null
	Declare @DriverInstruction nvarchar(1000) = ''
	Declare @EstimatedDate date = null
	Declare @EstimatedStartTW time(7) = null
	Declare @EstimatedEndTW time(7) = null
	Declare @InstructionType_MTV_ID int = (case when @IsPickup = 1 then 124100 else 124101 end)

	select @ZipCode = (case when @IsPickup = 1 then o.ShipFrom_ZipCode else o.ShipTo_ZipCode end)
	,@ScheduleDate = (case when @IsPickup = 1 then o.PromisedPickupDate else o.PromisedDeliveryDate end)
	,@EstimatedDate = (case when @IsPickup = 1 then o.ReqPickup_Date else o.ReqDelivery_Date end)
	,@EstimatedStartTW = (case when @IsPickup = 1 then o.ReqPickup_FromTime else o.ReqDelivery_FromTime end)
	,@EstimatedEndTW = (case when @IsPickup = 1 then o.ReqPickup_ToTime else o.ReqDelivery_ToTime end)
	from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.[ORDER_ID] = @ORDER_ID

	select @DriverInstruction = Instruction from [POMS_DB].[dbo].[T_Order_Special_Instruction] osi with (nolock) where osi.ORDER_ID = @ORDER_ID and osi.InstructionType_MTV_ID = @InstructionType_MTV_ID

	Declare @DateFrom date = @StartDate
	Declare @Months int = 4
	Declare @DateTo date = dateadd(month, @Months - 1, @StartDate)
	set @DateTo = dateadd(dd, 0 - datepart(dd, @DateTo), dateadd(month, 1, @DateTo))

	drop table if exists #RoutesList
	select [RL_ID] = rz.[RL_ID] into #RoutesList from [POMS_DB].[dbo].[T_Route_Zips] rz with (nolock) where rz.[IsActive] = 1 and rz.[ZIP_CODE] = @ZipCode

	drop table if exists #tRoutes
	select [RL_ID] = rl.[RL_ID] 
	, [RouteName]=rl.[Name] 
	, [Start_HUB_CODE]=rl.Start_HUB_CODE
	, [End_HUB_CODE]=rl.End_HUB_CODE
	, [ScheduleType_MTV_ID]=[ScheduleType_MTV_ID]
	, [TransitDays]=[TransitDays]
	, IsRoundTrip
	, AllowAPIScheduling
	, DaysToAppointment
	into #tRoutes
	from [POMS_DB].[dbo].[T_Route_List] rl with (nolock) 
	inner join #RoutesList trl on rl.RL_ID = trl.RL_ID
	where rl.Route_MTV_ID = 185101 and rl.[IsActive] = 1
	drop table if exists #RoutesList

	select * from #tRoutes

	drop table if exists #tZipCode
	select [ZIP_CODE] = rz.[ZIP_CODE] into #tZipCode from [POMS_DB].[dbo].[T_Route_Zips] rz with (nolock) where rz.RL_ID in (select r.RL_ID from #tRoutes r) and rz.[IsActive] = 1

	drop table if exists #tRouteSchedule
	select rts.TypeofMonth_MTV_CODE , rts.SubTypeofMonth_MTV_CODE ,rz.RL_ID, rta.TL_ID, rta.TrailerCount, rts.SpecificDate into #tRouteSchedule 
	from #tRoutes rz with (nolock) 
	inner join [POMS_DB].[dbo].[T_Route_Trailer_Attached] rta with (nolock) on rz.RL_ID = rta.RL_ID and rta.IsActive = 1
	inner join [POMS_DB].[dbo].[T_Route_Trailer_Schedule] rts with (nolock) on rta.RTA_ID = rts.RTA_ID and rts.IsActive = 1

	drop table if exists #tRouteWeekDays
	select Distinct rs.SubTypeofMonth_MTV_CODE ,rs.RL_ID ,rs.TL_ID into #tRouteWeekDays 
	from #tRouteSchedule rs where rs.TypeofMonth_MTV_CODE= 'DAYS'

	drop table if exists #tRouteWeeks
	select Distinct rs.SubTypeofMonth_MTV_CODE ,rs.RL_ID ,rs.TL_ID into #tRouteWeeks 
	from #tRouteSchedule rs where rs.TypeofMonth_MTV_CODE= 'WEEKS'

	drop table if exists #tSpecificDays
	select Distinct rs.SpecificDate, rs.SubTypeofMonth_MTV_CODE ,rs.RL_ID ,rs.TL_ID into #tSpecificDays 
	from #tRouteSchedule rs where rs.TypeofMonth_MTV_CODE= 'SPECIFIC-DAY' and rs.SpecificDate is not null

	drop table if exists #tRouteScheduleUnique
	select distinct RL_ID, TL_ID, TrailerCount into #tRouteScheduleUnique from #tRouteSchedule

	Declare @tRouteTotCapacity table (ID int identity(1,1) ,[Date] date ,[LockedValue_] int ,[FullValue_] int ,[DensityType] nvarchar(20))
	insert into @tRouteTotCapacity ([Date] ,[LockedValue_] ,[FullValue_] ,[DensityType])
	select [Date], [LockedValue_] ,FullValue_ ,DensityType from (
		select d.[Date], [LockedValue_] = sum(tc.[LockedValue_]) * rs.TrailerCount ,FullValue_ = sum(tc.FullValue_) * rs.TrailerCount ,DensityType = tc.DensityType_MTV_CODE ,tc.Sort_
		from #tRouteScheduleUnique rs
		inner join [POMS_DB].[dbo].[T_Trailer_Capacity] tc with (nolock) on rs.TL_ID = tc.TL_ID and tc.IsActive = 1
		inner join #tRouteWeekDays dm on rs.RL_ID = dm.RL_ID
		inner join #tRouteWeeks wm on rs.RL_ID = wm.RL_ID
		inner join [POMS_DB].[dbo].[T_Dates] d on d.[Day] = dm.SubTypeofMonth_MTV_CODE and d.[Week] = wm.SubTypeofMonth_MTV_CODE and d.[Date] between @DateFrom and @DateTo
		group by d.[Date], tc.[DensityType_MTV_CODE], rs.TrailerCount, tc.Sort_
	) A
	order by A.Sort_

	if exists(select * from #tSpecificDays)
	begin
		insert into @tRouteTotCapacity ([Date] ,[LockedValue_] ,[FullValue_] ,[DensityType])
		select [Date], [LockedValue_] ,FullValue_ ,DensityType from (
			select d.[Date], [LockedValue_] = sum(tc.[LockedValue_]) * rs.TrailerCount ,FullValue_ = sum(tc.FullValue_) * rs.TrailerCount ,DensityType = tc.DensityType_MTV_CODE ,tc.Sort_
			from #tRouteScheduleUnique rs inner join #tSpecificDays sd on rs.RL_ID = sd.RL_ID
			inner join [POMS_DB].[dbo].[T_Trailer_Capacity] tc with (nolock) on sd.TL_ID = tc.TL_ID and tc.IsActive = 1 
			inner join [POMS_DB].[dbo].[T_Dates] d on d.[Date] = sd.SpecificDate and d.[Date] between @DateFrom and @DateTo
			group by d.[Date], tc.[DensityType_MTV_CODE], rs.TrailerCount, tc.Sort_
		) A
		order by A.Sort_
	end
	
	drop table if exists #tRouteTotCapacity
	create table #tRouteTotCapacity
	(ID int identity(1,1) 
	,[Date] date
	,[LockedValue_] int 
	,[FullValue_] int 
	,[DensityType] nvarchar(20))
	insert into #tRouteTotCapacity ([Date], [LockedValue_], [FullValue_], [DensityType])
	select [Date] = [Date], [LockedValue_] = sum([LockedValue_]) ,[FullValue_] = sum([FullValue_]) ,[DensityType] from @tRouteTotCapacity group by [Date],[DensityType]

	Declare @tRouteUsedCapacity table ([Date] date ,[OrdersCount] int ,[ItemsCount] int ,[Cubes] int ,[Weight] int ,[SchType] nvarchar(10))

	insert into @tRouteUsedCapacity ([Date] ,[OrdersCount] ,[ItemsCount] ,[Cubes] ,[Weight] ,[SchType])
	select [Date] = o.PromisedPickupDate, [OrdersCount] = count(o.ORDER_ID), [ItemsCount] = sum(od.TotalQty), [Cubes] = sum(od.TotalCubes), [Weight] = sum(od.TotalWeight), [SchType] = 'P'
	from [POMS_DB].[dbo].[T_Order] o with (nolock) 
	inner join [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) on o.ORDER_ID = od.ORDER_ID
	where ActualPickupDate is null and o.PromisedPickupDate is not null
	and o.ShipFrom_ZipCode in (select z.[ZIP_CODE] from #tZipCode z) 
	and	o.PromisedPickupDate between @DateFrom and @DateTo and o.OrderStatus_MTV_ID = 100100
	group by o.PromisedPickupDate order by o.PromisedPickupDate

	insert into @tRouteUsedCapacity ([Date] ,[OrdersCount] ,[ItemsCount] ,[Cubes] ,[Weight] ,[SchType])
	select [Date] = o.PromisedDeliveryDate, [OrdersCount] = count(o.ORDER_ID), [ItemsCount] = sum(od.TotalQty), [Cubes] = sum(od.TotalCubes), [Weight] = sum(od.TotalWeight), [SchType] = 'D'
	from [POMS_DB].[dbo].[T_Order] o with (nolock) 
	inner join [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) on o.ORDER_ID = od.ORDER_ID
	where ActualDeliveryDate is null and o.PromisedDeliveryDate is not null
	and o.ShipTo_ZipCode in (select z.[ZIP_CODE] from #tZipCode z) 
	and	o.PromisedDeliveryDate between @DateFrom and @DateTo and o.OrderStatus_MTV_ID = 100100
	group by o.PromisedDeliveryDate order by o.PromisedDeliveryDate

	--drop table if exists #tRouteUsedCapacity
	--select [Date] 
	--, [OrdersCount] = sum([OrdersCount]) 
	--, [ItemsCount] = sum([ItemsCount]) 
	--, [Cubes] = sum([Cubes]) 
	--, [Weight] = sum([Weight]) 
	--into #tRouteUsedCapacity 
	--from @tRouteUsedCapacity group by [Date]

	drop table if exists #tRouteUsedCapacity
	create table #tRouteUsedCapacity
	(ID int 
	,[Date] date
	,[LockedValue_] int 
	,[FullValue_] int 
	,[DensityType] nvarchar(20))
	insert into #tRouteUsedCapacity (ID, [Date], [LockedValue_], [FullValue_], [DensityType])
	select ID = rtc.ID, ilv.[Date], ilv.[LockedValue_], ilv.[FullValue_], ilv.[DensityType]
	from (
		select [Date], [LockedValue_] = sum([OrdersCount]) ,[FullValue_] = sum([OrdersCount]) ,[DensityType] = 'ORDER' from @tRouteUsedCapacity group by [Date]
		union
		select [Date], [LockedValue_] = sum([ItemsCount]) ,[FullValue_] = sum([ItemsCount]) ,[DensityType] = 'ITEMS' from @tRouteUsedCapacity group by [Date]
		union
		select [Date], [LockedValue_] = sum([Cubes]) ,[FullValue_] = sum([Cubes]) ,[DensityType] = 'CUBES' from @tRouteUsedCapacity group by [Date]
		union
		select [Date], [LockedValue_] = sum([Weight]) ,[FullValue_] = sum([Weight]) ,[DensityType] = 'WEIGHT' from @tRouteUsedCapacity group by [Date]
	) ilv inner join #tRouteTotCapacity rtc on rtc.[DensityType] = ilv.[DensityType]

	drop table if exists #tLockDates
	Create table #tLockDates 
	(RL_ID int
	,LockDateFrom date
	,LockDateTo date
	,LockReleaseDate date)
	insert into #tLockDates (RL_ID,LockDateFrom,LockDateTo,LockReleaseDate)
	select rld.RL_ID,rld.LockDateFrom,rld.LockDateTo,rld.LockReleaseDate from [POMS_DB].[dbo].[T_Route_Lock_Dates] rld with (nolock) 
	inner join #tRoutes rt on rld.RL_ID = rt.RL_ID

	drop table if exists #tConsolidated
	select [Day] = dm.SubTypeofMonth_MTV_CODE
	, d.[Date]
	, [Week] = wm.SubTypeofMonth_MTV_CODE
	, [ScheduleType] = rt.[ScheduleType_MTV_ID]
	, rt.RL_ID
	, [IsLocked] = (case when exists(select * from #tLockDates tl where tl.RL_ID = rt.RL_ID) then
			(case when exists(select rld.RLD_ID from [POMS_DB].[dbo].[T_Route_Lock_Dates] rld with (nolock) 
				where rld.RL_ID = rt.RL_ID and d.[Date] between rld.LockDateFrom and rld.LockDateTo and rld.LockReleaseDate is null) 
			then 1 else 0 end)
		else 0 end)
	, [HolidayName] = [POMS_DB].[dbo].[F_Get_HolidayName_From_HM_ID] (hd.[HM_ID])
	, [IsReached] = (case when exists(select top 1 rtc.ID from #tRoutetotCapacity rtc
			inner join #tRouteUsedCapacity ruc on rtc.[DensityType] = ruc.[DensityType] and rtc.[Date] = ruc.[Date] where ruc.[Date] = d.[Date] and ruc.[FullValue_] > rtc.[FullValue_] order by rtc.ID) 
		then 1 else 0 end)
	into #tConsolidated
	from #tRoutes rt
	left join #tRouteWeekDays dm on rt.RL_ID = dm.RL_ID
	left join #tRouteWeeks wm on rt.RL_ID = wm.RL_ID
	left join #tSpecificDays sd on rt.RL_ID = sd.RL_ID
	left join [POMS_DB].[dbo].[T_Dates] d with (nolock) on ((d.[Day] = dm.SubTypeofMonth_MTV_CODE and d.[Week] = wm.SubTypeofMonth_MTV_CODE) or (d.[Date] = sd.[SpecificDate])) and d.[Date] between @DateFrom and @DateTo
	left join [POMS_DB].[dbo].[T_Holiday_Dates] hd with (nolock) on hd.[Date] = d.[Date] and hd.[IsActive] = 1

	drop table if exists #FinalRecord1
	select * into #FinalRecord1 from (
		select [Day]
		, [Date]
		, [Week]
		, [ScheduleType]
		, RL_ID
		, [IsLocked] = (case when @EnableAllDates = 1 then 0 else [IsLocked] end)
		, [IsHoliday] = (case when [HolidayName] is null then 1 else 0 end)
		, [HolidayName]
		, [IsEnabled] = (case when [IsLocked] = 1 then 0 
			when [HolidayName] is not null then 0
			when [IsReached] = 1 then 0
			else 1 end)
		, [IsReached]
		from #tConsolidated
	
		union

		select d.[Day]
		, d.[Date] 
		, d.[Week]
		, [Schedule Type] = 105101
		, [RL_ID] = 0
		, [IsLocked] = (case when @EnableAllDates = 1 then 0 else 1 end)
		, [IsHoliday] = 1
		, [HolidayName] = hm.[Name]
		, [IsEnabled] = 0
		, [IsReached] = 0
		from [POMS_DB].[dbo].[T_Holiday_Dates] hd with (nolock)
		inner join [POMS_DB].[dbo].[T_Holiday_Master] hm on hm.HM_ID = hd.HM_ID and hd.IsActive = 1
		inner join [POMS_DB].[dbo].[T_Dates] d on d.[Date] = hd.[Date] and d.[Date] between @DateFrom and @DateTo and d.[Date] not in (select cn.[Date] from #tConsolidated cn)
	) A
	
	
	
	
	
	
	
	
	
	
	

	select @ScheduleDate as ScheduleDate 
	,@DriverInstruction as DriverInstruction 
	,@EstimatedDate as EstimatedDate 
	,@EstimatedStartTW as EstimatedStartTW 
	,@EstimatedEndTW as EstimatedEndTW 

	select fr1.* 
	--,[Class]=(case when Flag = 'Enabled' then 'DT-Green'
	--	when Flag = 'Locked' then 'DT-Blue'
	--	when Flag = 'Holiday' then 'DT-Red'
	--	when Flag = 'Capacity Reached' then 'DT-Orange'
	--	else '' end)
	from #FinalRecord1 fr1 order by fr1.[Date]

	--drop table if exists #tSPDay
	--select distinct [SpecificDay] into #tSPDay from #FinalRecord1 fr1 where [SpecificDay] is not null

	--select * from #tSPDay order by [SpecificDay]

	select distinct RL_ID =  tr.RL_ID
	, tr.[RouteName]
	, tr.[Start_HUB_CODE]
	, tr.[End_HUB_CODE]
	, [ScheduleTypeName] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (tr.[ScheduleType_MTV_ID])
	from #tRoutes tr

	select EnableAllDates = @EnableAllDates
	, EnableBackDates = @EnableBackDates
	, EnableCurrentDate = @EnableCurrentDate
	, CurrentDate = @StartDate
	, Months = @Months

	select [ORDER_ID] = o.ORDER_ID
	, [ORDER_GUID] = o.ORDER_CODE_GUID
	, [ScheduleDate] = (case when @IsPickup = 1 then o.PromisedPickupDate else o.PromisedDeliveryDate end)
	from [POMS_DB].[dbo].[T_Order_Related_Tickets] ort with (nolock) 
	inner join [POMS_DB].[dbo].[T_Order] o with (nolock) on o.ORDER_ID = ort.RELATED_ORDER_ID 
	where ort.ORDER_ID = @ORDER_ID and o.OrderStatus_MTV_ID = 100100
	and ((@IsPickup = 1 and o.PromisedPickupDate is null) or (@IsPickup = 0 and o.PromisedDeliveryDate is null))

end

END
GO
