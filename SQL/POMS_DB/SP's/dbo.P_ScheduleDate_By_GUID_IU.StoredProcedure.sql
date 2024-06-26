USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_ScheduleDate_By_GUID_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_ScheduleDate_By_GUID_IU] '',10100168,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_ScheduleDate_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int

	,@ScheduleDate date
	,@ScheduleReq_TFL_ID int
	,@UserIntention_MTV_ID int --184100 = Exact Date, 184101 = Week-of
	,@IsDeleteDate bit
	,@IsPublicComment bit
	,@Comments nvarchar(1000)
	,@DriverInstructions nvarchar(1000)
	,@EventID int
	,@IsPickup bit
	,@CurrentDate date
	
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
set @ScheduleDate = (case when @ScheduleDate is null then null when year(@ScheduleDate) < 2000 then null else @ScheduleDate end)
set @ScheduleReq_TFL_ID = isnull(@ScheduleReq_TFL_ID,0)
set @IsDeleteDate = isnull(@IsDeleteDate,0)
set @IsPublicComment = isnull(@IsPublicComment,0)
set @Comments = isnull(@Comments,'')
set @DriverInstructions = isnull(@DriverInstructions,'')
set @EventID = isnull(@EventID,0)
set @IsPickup = isnull(@IsPickup,0)
set @CurrentDate = isnull(@CurrentDate,[POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (getutcdate(),@TimeZone_ID,null,null))

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
,ScheduleDate date default null
,OldScheduleDate date default null
)

Declare @RoutesTable table
(ROUTE_ID int
,Route_Name nvarchar(250)
,OriginWarehouse nvarchar(50)
,DestinationWarehouse nvarchar(50)
,RouteScheduleType nvarchar(50)
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
	Declare @OldScheduleDate date = null
	Declare @ScheduleDateText nvarchar(50) = ''
	Declare @OldScheduleDateText nvarchar(50) = ''
	Declare @CompleteEventID int = (case when @IsPickup = 1 then 18 else 54 end)
	Declare @IsActualDateExists bit = 0
	Declare @SELLER_CODE nvarchar(20) = ''
	Declare @OrderStatus_MTV_ID int = 0
	Declare @OrderStatusName nvarchar(50) = 0
	Declare @NewRequested_TFL_Name nvarchar(50) = ''
	Declare @Capacity int = 0
	Declare @RouteID int = 0

	Declare @OldFMManfiest int = 0
	Declare @OldConfirmedDate date
	Declare @OldConfirmed_TFL_ID int = 0
	Declare @OldRequested_TFL_ID int = 0
	Declare @OldConfirmed_TFL_Name nvarchar(50) = ''
	Declare @OldRequested_TFL_Name nvarchar(50) = ''
	Declare @OldSchType_MTV_ID int = 0
	Declare @NewSchType_MTV_ID int = 0
	Declare @FirstOfferedDate date 
	Declare @OldPaymentStatus_MTV_ID int = 0
	Declare @OldCurrentAssignedDept_MTV_CDOE nvarchar(20) = ''
	Declare @NewCurrentAssignedDept_MTV_CDOE nvarchar(20) = ''
	Declare @OldCurrentAssignedUser nvarchar(150) = ''
	Declare @NewCurrentAssignedUser nvarchar(150) = ''
	Declare @LastEventID int = 0
	Declare @ZipCode nvarchar(10) = ''
	Declare @EventID2 int = 0

	if @ScheduleDate is null and @ReturnText = '' and @IsDeleteDate = 0
	begin
		set @ReturnText = 'Schedule Date is Required'
	end
	else if not exists(select tfl.TFL_ID from [POMS_DB].[dbo].[T_Time_Frame_List] tfl with (nolock) where tfl.TFL_ID = @ScheduleReq_TFL_ID and tfl.IsActive = 1) and @ReturnText = ''
	begin
		set @ReturnText = 'Invalid Time Window'
	end
	else if not exists(select mtv.MTV_ID from [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MTV_ID = @UserIntention_MTV_ID and mtv.MT_ID = 184 and mtv.IsActive = 1) and @ReturnText = '' and @UserIntention_MTV_ID is not null
	begin
		set @ReturnText = 'Invalid User Intention Schedule Date Type'
	end
		
	if @ReturnText = ''
	begin
		select @OldScheduleDate = (case when @IsPickup = 1 then PromisedPickupDate else PromisedDeliveryDate end) 
		,@IsActualDateExists = (case when @IsPickup = 1 and o.ActualPickupDate is null then 0 
			when @IsPickup = 0 and o.ActualDeliveryDate is null then 0 
			else 1 end)
		,@SELLER_CODE = o.SELLER_CODE
		,@OrderStatus_MTV_ID = o.OrderStatus_MTV_ID
		from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID
		set @OrderStatusName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@OrderStatus_MTV_ID)

			
	end

	if @ReturnText = ''
	begin
		if @IsPickup = 1
		begin
			Select @OldScheduleDate = o.PromisedPickupDate
			,@IsActualDateExists = (case when o.ActualPickupDate is null then 0 else 1 end)
			,@SELLER_CODE = o.SELLER_CODE
			,@OrderStatus_MTV_ID = o.OrderStatus_MTV_ID
			,@ZipCode = o.ShipFrom_ZipCode
			,@OldFMManfiest = o.PickupFMManifest
			,@OldConfirmedDate = o.ConfirmedPickupDate
			,@OldConfirmed_TFL_ID = o.ConfirmedPickupTimeFrame_TFL_ID
			,@OldSchType_MTV_ID = o.PickupScheduleType_MTV_ID
			,@OldRequested_TFL_ID = o.ReqPickupTimeFrame_TFL_ID 
			,@FirstOfferedDate = o.FirstOffered_PickupDate 
			,@OldPaymentStatus_MTV_ID = o.PaymentStatus_MTV_ID
			,@OldCurrentAssignedDept_MTV_CDOE = od.CurrentAssignToDept_MTV_CODE
			,@OldCurrentAssignedUser = [POMS_DB].[dbo].[F_Get_Current_AssignTo_From_DeptCode] (od.CurrentAssignToDept_MTV_CODE, od.OEDAssignTo, od.CSRAssignTo, od.DispatchAssignTo, od.AccountAssignTo)
			,@NewCurrentAssignedDept_MTV_CDOE = (case when @ScheduleDate is not null then 'DISPATCH' else 'CSR' end)
			,@NewCurrentAssignedUser = [POMS_DB].[dbo].[F_Get_Current_AssignTo_From_DeptCode] ((case when @ScheduleDate is not null then 'DISPATCH' else 'CSR' end), od.OEDAssignTo, od.CSRAssignTo, od.DispatchAssignTo, od.AccountAssignTo)
			,@LastEventID = (select top 1 oe.EVENT_ID from [POMS_DB].[dbo].[T_Order_Events] oe with (nolock) where oe.EVENT_ID in (7,8) and oe.[ORDER_ID] = @ORDER_ID order by CreatedOn desc)
			from [POMS_DB].[dbo].[T_Order] o with(nolock)
			inner join [POMS_DB].[dbo].[T_Order_Detail] od with(nolock) on o.ORDER_ID = od.ORDER_ID where o.ORDER_ID = @ORDER_ID
		end
		else
		begin
			Select @OldScheduleDate = o.PromisedDeliveryDate
			,@IsActualDateExists = (case when o.ActualDeliveryDate is null then 0 else 1 end)
			,@SELLER_CODE = o.SELLER_CODE
			,@OrderStatus_MTV_ID = o.OrderStatus_MTV_ID
			,@ZipCode = o.ShipTo_ZipCode
			,@OldFMManfiest = o.DeliveryFMManifest
			,@OldConfirmedDate = o.ConfirmedDeliveryDate
			,@OldConfirmed_TFL_ID = o.ConfirmedDeliveryTimeFrame_TFL_ID
			,@OldSchType_MTV_ID = o.DeliveryScheduleType_MTV_ID
			,@OldRequested_TFL_ID = o.ReqDeliveryTimeFrame_TFL_ID 
			,@FirstOfferedDate = o.FirstOffered_DeliveryDate 
			,@OldPaymentStatus_MTV_ID = o.PaymentStatus_MTV_ID
			,@OldCurrentAssignedDept_MTV_CDOE = od.CurrentAssignToDept_MTV_CODE
			,@OldCurrentAssignedUser = [POMS_DB].[dbo].[F_Get_Current_AssignTo_From_DeptCode] (od.CurrentAssignToDept_MTV_CODE, od.OEDAssignTo, od.CSRAssignTo, od.DispatchAssignTo, od.AccountAssignTo)
			,@NewCurrentAssignedDept_MTV_CDOE = (case when @ScheduleDate is not null then 'DISPATCH' else 'CSR' end)
			,@NewCurrentAssignedUser = [POMS_DB].[dbo].[F_Get_Current_AssignTo_From_DeptCode] ((case when @ScheduleDate is not null then 'DISPATCH' else 'CSR' end), od.OEDAssignTo, od.CSRAssignTo, od.DispatchAssignTo, od.AccountAssignTo)
			,@LastEventID = (select top 1 oe.EVENT_ID from [POMS_DB].[dbo].[T_Order_Events] oe with (nolock) where oe.EVENT_ID in (37,38,90) and oe.[ORDER_ID] = @ORDER_ID order by CreatedOn desc)
			from [POMS_DB].[dbo].[T_Order] o with(nolock)
			inner join [POMS_DB].[dbo].[T_Order_Detail] od with(nolock) on o.ORDER_ID = od.ORDER_ID where o.ORDER_ID = @ORDER_ID
		end
		select @OldConfirmed_TFL_Name = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (@OldConfirmed_TFL_ID)
		select @OldRequested_TFL_Name = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (@OldRequested_TFL_ID)
		select @NewRequested_TFL_Name = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (@ScheduleReq_TFL_ID)
			
		if @OrderStatus_MTV_ID <> 100100 and @ReturnText = ''
		begin
			set @ReturnText = 'Cannot ' + (case when @IsDeleteDate = 0 then 'Change ' else 'Delete ' end) + (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end) + ' Schedule Date. Order is ' + @OrderStatusName
		end
		else if (@ScheduleDate > @CurrentDate and @Capacity <> 0) and @IsDeleteDate = 0
		begin
			Declare @CapacityTable table ([CapacityDates] nvarchar(250) ,Cnt int,SchType nvarchar(10))
			insert into @CapacityTable ([CapacityDates] ,Cnt ,SchType)
			exec [PinnacleProd].[dbo].[P_GetAvailableRouteCapacity_By_GUID] @ORDER_CODE_GUID ,@ORDER_ID ,@ScheduleDate ,@IsPickup ,@Source_MTV_ID ,@UserName ,@UserType_MTV_CODE 
				,@IsPublic ,@TimeZone_ID ,@GetRecordType_MTV_ID ,@ReturnCode out ,@ReturnText out
			if exists(select * from @CapacityTable)
			begin
				set @ReturnText = 'Capacity Reached!! No More Orders Can Be Scheduled On The Selected Date, Please Contact Dipatch/Admin.'
			end
		end
		else if @OldPaymentStatus_MTV_ID = 144103 and @ReturnText = '' and @IsDeleteDate = 0
		begin
			set @ReturnText = 'Unable to Schedule ' + (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end) + '. Payment Status is On Hold'
		end
		else if (@LastEventID = 7) and @IsPickup = 1 and @ReturnText = '' 
		begin
			set @ReturnText = 'Unable to Schedule Pickup. Pickup has been put to Hold'
		end
		else if (@LastEventID = 37) and @IsPickup = 0 and @ReturnText = '' 
		begin
			set @ReturnText = 'Unable to Schedule Delivery. Customer Put Order On Hold'
		end
		else if (@LastEventID = 90) and @IsPickup = 0 and @ReturnText = '' 
		begin
			set @ReturnText = 'Unable to Schedule Delivery. Delivery put on hold'
		end
		else if @OldScheduleDate is not null and @IsDeleteDate = 1 and @ReturnText = ''
		begin
			set @ReturnText = 'Schedule ' + (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end) + ' Date is Already Removed.'
		end
		else if @IsActualDateExists = 1 and @ReturnText = ''
		begin
			set @ReturnText = 'Cannot ' + (case when @IsDeleteDate = 0 then 'Change ' else 'Delete ' end) + (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end) + ' Schedule Date. Order ' + (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end) + ' is Already Complete.'
		end
		else if @OldFMManfiest > 0 and @ReturnText = ''
		begin
			set @ReturnText = 'Cannot ' + (case when @IsDeleteDate = 0 then 'Change ' else 'Delete ' end) + (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end) + ' Schedule Date. Order is Already Attached with the Final Mile Manifest# ' + cast(@OldFMManfiest as nvarchar(50))
		end
		
	end

	if @ReturnText = ''
	begin
		drop table if exists #OtherThanFMManfiestDetail
		select mg.[ManifestId] , [Type] = (CASE WHEN mgi.[Pickup OR Delivery] = 1 THEN 1 WHEN mgi.[Pickup OR Delivery] = 2 THEN 0 ELSE 0 END)
		, OrderNo = msll.[Sales Order No] , ManifestType = m.[Type] , [ManifestTypeCode] = (case m.[Type] when 30000 then 'FM' else 'LH' end)
		, AttachedLinked = (case when mgi.[Is Stop Defined] = 1 then 'Attached' when mgi.[Is Stop Defined]=0 then 'Linked' else '' end)
		, m.[Status] into #OtherThanFMManfiestDetail From [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] msll with(nolock)
		Inner Join [PinnacleProd].[dbo].[Metropolitan$Manifest Group Items] mgi with(nolock) on mgi.[Item ID]= msll.ID
		Inner Join [PinnacleProd].[dbo].[Metropolitan$ManifestGroups] mg with(nolock) on mgi.[Manifest Group ID]= mg.[ManifestGroupId]
		Inner Join [PinnacleProd].[dbo].[Metropolitan$Manifest] m with(nolock) on m.[Entry No]=mg.[ManifestId]
		where mg.[Active Status] = 1 and mgi.[Active Status] = 1 and m.[Status] in (30000,20000) and mgi.[Is Stop Defined] = 1 and mgi.[Pickup OR Delivery] = (case when @IsPickup = 1 then 1 else 2 end)
		group by mg.[ManifestId],mgi.[Pickup OR Delivery],msll.[Sales Order No],m.[Type],mgi.[Is Stop Defined],m.[Status]

		if exists(select * from #OtherThanFMManfiestDetail where [Status] in (30000,20000) and [Type] = 30000)
		begin
			set @ReturnText = 'Cannot ' + (case when @IsDeleteDate = 0 then 'Change ' else 'Delete ' end) + (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end) + ' Schedule Date. Order is Already Linked/Attached with Pinnacle Manifest No ' + cast((select [ManifestId] from #OtherThanFMManfiestDetail where [Status] in (30000,20000) and [Type] = 30000) as nvarchar(50)) + ' of type ' + (select [ManifestTypeCode] from #OtherThanFMManfiestDetail where [Status] in (30000,20000) and [Type] = 30000) + '.'
		end
		--ATTACHED STATUS 30000 ONLY
		--FM TYPE 30000 ONLY
	end

	if @ReturnText = ''
	begin
		begin transaction

		begin try
					
			if @ScheduleDate < @CurrentDate or @IsDeleteDate = 1
			begin
				set @UserIntention_MTV_ID = null
			end

			if @IsDeleteDate = 1
			begin
				drop table if exists #RoutesList2
				select [Route ID] into #RoutesList2 from [PinnacleProd].[dbo].[Metropolitan$FM Routes] fm with (nolock) where fm.[Active Status] = 1 and fm.[Zip Code] = @ZipCode

				select top 1 @RouteID = tr.[Route ID] from [PinnacleProd].[dbo].[Metropolitan$TR Routes] tr with (nolock) 
				where tr.[Route ID] in (select * from #RoutesList2) and tr.[Active Status] = 1
				and (@OldScheduleDate is null or not exists(select 1 from [PinnacleProd].[dbo].[Metropolitan$TR Route Locks] trl with (nolock) where @OldScheduleDate between trl.[Lock From Date] and trl.[Lock Upto Date]
				and	tr.[Route ID] = [Route ID] and year([Lock Release Date]) = 1775))
			end

			if (@ScheduleReq_TFL_ID = 0 and @IsDeleteDate = 0)
			begin	
				set @ScheduleReq_TFL_ID = (case when [PinnacleProd].[dbo].[fn_IsWeekOfEnabledDay](@ORDER_ID, @ScheduleDate, 2) = 1 and @UserIntention_MTV_ID = 184101 then 0 
				when @RouteID > 0 and @UserIntention_MTV_ID = 184101 then 0 else 1 end)
			end

			set @EventID2 = (case when isnull(@OldScheduleDate,'') = isnull(@ScheduleDate,'') then 0 
				when @IsPickup = 1 and @OldScheduleDate is null and @ScheduleDate is not null then 10 --Pickup scheduled
				when @IsPickup = 1 and @OldScheduleDate is not null and @ScheduleDate is null then 11 --Pickup Reschedule Awaited
				when @IsPickup = 1 and @OldScheduleDate is not null and @ScheduleDate is not null then 12 --Pickup has been rescheduled 
				when @IsPickup = 0 and @OldScheduleDate is null and @ScheduleDate is not null then 43 --Delivery Scheduled
				when @IsPickup = 0 and @OldScheduleDate is not null and @ScheduleDate is null then 44 --Delivery Reschedule Awaited
				when @IsPickup = 0 and @OldScheduleDate is not null and @ScheduleDate is not null then 46 --Delivery Rescheduled
				else 0 end)

			if @EventID2 > 0
			begin
				exec [POMS_DB].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] @EventID2 ,0 ,0 ,0 ,@UserName ,1 ,'10000' ,'ShippingStatus/OrderDetail/UpdateShippingStatus' ,@UserName ,@ORDER_ID ,@SELLER_CODE ,'' ,'' ,''
			end

			if @EventID > 0
			begin
				exec [POMS_DB].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] @EventID ,0 ,0 ,0 ,@UserName ,1 ,'10000' ,'ShippingStatus/OrderDetail/UpdateShippingStatus' ,@UserName ,@ORDER_ID ,@SELLER_CODE ,'' ,'' ,''
			end

			--if (@IsDeleteDate = 1 and @IsPickup = 1 and @RouteID > 0)
			--	exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] '', @RouteID, '', 'Pickup Route ID', 'Metropolitan$Sales Linkup', @ORDER_ID, @UserName, '40000', @ORDER_ID
			--if (@IsDeleteDate = 1 and @IsPickup = 0 and @RouteID > 0)
			--	exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] '', @RouteID, '', 'Delivery Route ID', 'Metropolitan$Sales Linkup', @ORDER_ID, @UserName, '40000', @ORDER_ID
		
			if @IsDeleteDate  = 0
			begin
				drop table if exists #JsonOldEditOrderTable
				select o.ORDER_ID
				, o.FirstOffered_PickupDate 
				, FirstOffered_PickupDateText = (case when o.FirstOffered_PickupDate is null then '' else format(o.FirstOffered_PickupDate,'yyyy-MM-dd') end)
				, o.PromisedPickupDate 
				, PromisedPickupDateText = (case when o.PromisedPickupDate is null then '' else format(o.PromisedPickupDate,'yyyy-MM-dd') end)
				, o.PkpIntentionType_MTV_ID
				, PkpIntentionTypeName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.PkpIntentionType_MTV_ID)
				, o.ReqPickupTimeFrame_TFL_ID 
				, ReqPickupTimeFrameName = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.ReqPickupTimeFrame_TFL_ID)
				, o.PickupFMManifest 
				, o.ConfirmedPickupDate 
				, ConfirmedPickupDateText = (case when o.ConfirmedPickupDate is null then '' else format(o.ConfirmedPickupDate,'yyyy-MM-dd') end)
				, o.ConfirmedPickupTimeFrame_TFL_ID 
				, ConfirmedPickupTimeFrameName = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.ConfirmedPickupTimeFrame_TFL_ID)
				, o.FirstOffered_DeliveryDate 
				, FirstOffered_DeliveryDateText = (case when o.FirstOffered_DeliveryDate is null then '' else format(o.FirstOffered_DeliveryDate,'yyyy-MM-dd') end)
				, o.PromisedDeliveryDate 
				, PromisedDeliveryDateText = (case when o.PromisedDeliveryDate is null then '' else format(o.PromisedDeliveryDate,'yyyy-MM-dd') end)
				, o.DlvIntentionType_MTV_ID
				, DlvIntentionTypeName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.DlvIntentionType_MTV_ID)
				, o.ReqDeliveryTimeFrame_TFL_ID 
				, ReqDeliveryTimeFrameName = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.ReqDeliveryTimeFrame_TFL_ID)
				, o.DeliveryFMManifest 
				, o.ConfirmedDeliveryDate 
				, ConfirmedDeliveryDateText = (case when o.ConfirmedDeliveryDate is null then '' else format(o.ConfirmedDeliveryDate,'yyyy-MM-dd') end)
				, o.ConfirmedDeliveryTimeFrame_TFL_ID 
				, ConfirmedDeliveryTimeFrameName = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.ConfirmedDeliveryTimeFrame_TFL_ID)
				into #JsonOldEditOrderTable
				from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID

				update o
				set o.FirstOffered_PickupDate = (case when @IsPickup = 1 then
					(case when @FirstOfferedDate is null and @IsDeleteDate = 0 then @ScheduleDate else o.FirstOffered_PickupDate end) 
					else o.FirstOffered_PickupDate end)
				, o.PromisedPickupDate = (case when @IsPickup = 1 then @ScheduleDate else o.PromisedPickupDate end)
				, o.PkpIntentionType_MTV_ID = (case when @IsPickup = 1 then @UserIntention_MTV_ID else o.PkpIntentionType_MTV_ID end)
				, o.ReqPickupTimeFrame_TFL_ID = (case when @IsPickup = 1 then @ScheduleReq_TFL_ID else o.ReqPickupTimeFrame_TFL_ID end)
				, o.PickupFMManifest = (case when @IsPickup = 1 then
					(case when @IsDeleteDate = 0 then null else o.PickupFMManifest end)
					else o.PickupFMManifest end)
				, o.ConfirmedPickupDate = (case when @IsPickup = 1 then
					(case when @IsDeleteDate = 0 then null else o.ConfirmedPickupDate end)
					else o.ConfirmedPickupDate end)
				, o.ConfirmedPickupTimeFrame_TFL_ID = (case when @IsPickup = 1 then
					(case when @IsDeleteDate = 0 then null else o.ConfirmedPickupTimeFrame_TFL_ID end)
					else o.ConfirmedPickupTimeFrame_TFL_ID end)

				, o.FirstOffered_DeliveryDate = (case when @IsPickup = 0 then
					(case when @FirstOfferedDate is null and @IsDeleteDate = 0 then @ScheduleDate else o.FirstOffered_DeliveryDate end)
					else o.FirstOffered_DeliveryDate end)
				, o.PromisedDeliveryDate = (case when @IsPickup = 0 then @ScheduleDate else o.PromisedDeliveryDate end)
				, o.DlvIntentionType_MTV_ID = (case when @IsPickup = 1 then @UserIntention_MTV_ID else o.DlvIntentionType_MTV_ID end)
				, o.ReqDeliveryTimeFrame_TFL_ID = (case when @IsPickup = 0 then @ScheduleReq_TFL_ID else o.ReqDeliveryTimeFrame_TFL_ID end)
				, o.DeliveryFMManifest = (case when @IsPickup = 0 then
					(case when @IsDeleteDate = 0 then null else o.DeliveryFMManifest end)
					else o.DeliveryFMManifest end)
				, o.ConfirmedDeliveryDate = (case when @IsPickup = 0 then
					(case when @IsDeleteDate = 0 then null else o.ConfirmedDeliveryDate end)
					else o.ConfirmedDeliveryDate end)
				, o.ConfirmedDeliveryTimeFrame_TFL_ID = (case when @IsPickup = 0 then
					(case when @IsDeleteDate = 0 then null else o.ConfirmedDeliveryTimeFrame_TFL_ID end)
					else o.ConfirmedDeliveryTimeFrame_TFL_ID end)

				, o.ModifiedBy = @UserName
				, o.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_Order] o where o.ORDER_ID = @ORDER_ID

				drop table if exists #JsonNewEditOrderTable
				select o.ORDER_ID
				, o.FirstOffered_PickupDate 
				, FirstOffered_PickupDateText = (case when o.FirstOffered_PickupDate is null then '' else format(o.FirstOffered_PickupDate,'yyyy-MM-dd') end)
				, o.PromisedPickupDate 
				, PromisedPickupDateText = (case when o.PromisedPickupDate is null then '' else format(o.PromisedPickupDate,'yyyy-MM-dd') end)
				, o.PkpIntentionType_MTV_ID
				, PkpIntentionTypeName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.PkpIntentionType_MTV_ID)
				, o.ReqPickupTimeFrame_TFL_ID 
				, ReqPickupTimeFrameName = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.ReqPickupTimeFrame_TFL_ID)
				, o.PickupFMManifest 
				, o.ConfirmedPickupDate 
				, ConfirmedPickupDateText = (case when o.ConfirmedPickupDate is null then '' else format(o.ConfirmedPickupDate,'yyyy-MM-dd') end)
				, o.ConfirmedPickupTimeFrame_TFL_ID 
				, ConfirmedPickupTimeFrameName = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.ConfirmedPickupTimeFrame_TFL_ID)
				, o.FirstOffered_DeliveryDate 
				, FirstOffered_DeliveryDateText = (case when o.FirstOffered_DeliveryDate is null then '' else format(o.FirstOffered_DeliveryDate,'yyyy-MM-dd') end)
				, o.PromisedDeliveryDate 
				, PromisedDeliveryDateText = (case when o.PromisedDeliveryDate is null then '' else format(o.PromisedDeliveryDate,'yyyy-MM-dd') end)
				, o.DlvIntentionType_MTV_ID
				, DlvIntentionTypeName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (o.DlvIntentionType_MTV_ID)
				, o.ReqDeliveryTimeFrame_TFL_ID 
				, ReqDeliveryTimeFrameName = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.ReqDeliveryTimeFrame_TFL_ID)
				, o.DeliveryFMManifest 
				, o.ConfirmedDeliveryDate 
				, ConfirmedDeliveryDateText = (case when o.ConfirmedDeliveryDate is null then '' else format(o.ConfirmedDeliveryDate,'yyyy-MM-dd') end)
				, o.ConfirmedDeliveryTimeFrame_TFL_ID 
				, ConfirmedDeliveryTimeFrameName = [POMS_DB].[dbo].[F_Get_TimeFrameName_From_TFL_ID] (o.ConfirmedDeliveryTimeFrame_TFL_ID)
				into #JsonNewEditOrderTable
				from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID

				update od
				set od.CurrentAssignToDept_MTV_CODE = @NewCurrentAssignedDept_MTV_CDOE
				, od.ModifiedBy = @UserName
				, od.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_Order_Detail] od where od.ORDER_ID = @ORDER_ID

				Declare @OldCurrentAssignedDeptName nvarchar(50) = ''
				Declare @NewCurrentAssignedDeptName nvarchar(50) = ''

				set @OldCurrentAssignedDeptName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@OldCurrentAssignedDept_MTV_CDOE)
				set @NewCurrentAssignedDeptName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@NewCurrentAssignedDept_MTV_CDOE)

				exec [POMS_DB].[dbo].[P_ScheduleDate_By_GUID_IU_ChangeLog] @plogIsEdit = 1 ,@plogUserName = @UserName ,@plogSource_MTV_ID = @Source_MTV_ID 

				exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = @OldCurrentAssignedDept_MTV_CDOE
				, @pNewValueHidden = @NewCurrentAssignedDept_MTV_CDOE ,@pOldValue = @OldCurrentAssignedDeptName, @pNewValue = @NewCurrentAssignedDeptName, @pColumn_Name = 'CurrentAssignToDept_MTV_CODE', @pTable_Name = 'T_Order_Detail'
				, @pReason = '' , @pSource_MTV_ID = @Source_MTV_ID, @pChangedBy = @UserName, @pIsAuto = 1, @pTriggerDebugInfo = 'P_ScheduleDate_By_GUID_IU'

				if @FirstOfferedDate is null and @ScheduleDate is not null
				begin
					if not exists(select oel.OEL_ID from [POMS_DB].[dbo].[T_Order_Events_List] oel with (nolock) where oel.[ORDER_ID] = @ORDER_ID and oel.EVENT_ID = 143) --and 1 = 0
					begin
						EXECUTE [POMS_DB].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 143 ,0 ,0 ,0 ,@UserName ,1 ,'10000' ,'OrderDetail/UpdateFirstOfferDate' ,@UserName ,@ORDER_ID ,@SELLER_CODE ,'' ,'' ,''
					end
				end
				--if (@RouteID > 0)
				--	exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @RouteID, '', '', 'Delivery Route ID', 'Metropolitan$Sales Linkup', @OrderID, @UserName, '40000', @OrderID

			end
					
			Declare @RetAddRowCount int = 0
			Declare @RetEditRowCount int = 0
			Declare @RetDeleteRowCount int = 0
			Declare @RetReturn_Code bit = 1
			Declare @RetReturn_Text nvarchar(1000) = ''
			Declare @RetExecution_Error nvarchar(1000) = ''
			Declare @RetError_Text nvarchar(max) = ''
					
			if @DriverInstructions <> '' and @IsDeleteDate = 0 and @ReturnText = ''
			begin
				Declare @InstructionType_MTV_ID int = (case when @IsPickup = 1 then 124100 else 124101 end)

				exec [POMS_DB].[dbo].[P_Order_Special_Instruction_IU] @pJson = null ,@pOrder_ID = @ORDER_ID ,@pOSI_ID = 0 ,@pInstructionType_MTV_ID = @InstructionType_MTV_ID ,@pInstruction = @DriverInstructions 
				,@pUserName = @UserName ,@pAddRowCount = @RetAddRowCount out ,@pEditRowCount = @RetEditRowCount out ,@pDeleteRowCount = @RetDeleteRowCount out ,@pReturn_Code = @RetReturn_Code out 
				,@pReturn_Text = @RetReturn_Text out ,@pExecution_Error = @RetExecution_Error out ,@pError_Text = @RetError_Text out ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID

				if @RetReturn_Code = 0
				begin
					set @ReturnText = @RetReturn_Text
				end

			end

			if @Comments <> '' and @IsDeleteDate = 0 and @ReturnText = ''
			begin
				exec [POMS_DB].[dbo].[P_Order_Comments_IU] @pJson = null ,@pOrder_ID = @ORDER_ID ,@pOC_ID = 0 ,@pComment = @Comments ,@pIsPublic = @IsPublicComment ,@pUserName = @UserName ,@pIsCall = 1
				,@pIsActive = 1 ,@pImportanceLevel_MTV_ID = null ,@pAddRowCount = @RetAddRowCount out ,@pEditRowCount = @RetEditRowCount out ,@pDeleteRowCount = @RetDeleteRowCount out ,@pReturn_Code = @RetReturn_Code out 
				,@pReturn_Text = @RetReturn_Text out ,@pExecution_Error = @RetExecution_Error out ,@pError_Text = @RetError_Text out ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID

				if @RetReturn_Code = 0
				begin
					set @ReturnText = @RetReturn_Text
				end
			end

			---- Log schedule type based on USER INTENTION
			--if @UserIntention_MTV_ID is not null and @IsDeleteDate = 0 and @ReturnText = ''
			--begin
			--	--Calculate the new scheduled type based on following ...
			--	--Old Value								For Intention Exact Date			For Intention Week-of
			--	---------------------------------------------------------------------------------------
			--	--105100 Every Day						105100 Every Day					105103 Specific Week 
			--	--105101 Every Week						105101 Every Week					105103 Specific Week 
			--	--105102 Specific Week					105103 Specific Date				105103 Specific Week 
			--	--105103 Specific Date					105103 Specific Date				105103 Specific Week 
			--	--105104 Exception Specific Date		105104 Exception Specific Date		105103 Specific Week
			--	--105105 Exception Specific Week		105103 Specific Date				105105 Exception Specific Week
			--	--105106 Call Metro (Remote Area)		105103 Specific Date				105103 Specific Week  
			--	--105107 Call Metro (3PL/Outsource)		105103 Specific Date				105103 Specific Week

			--	if (@UserIntention_MTV_ID = 184100)
			--	begin
			--		set @NewSchType_MTV_ID = (case when @OldSchType_MTV_ID in (105102,105105,105106,105107) then 105105 else @OldSchType_MTV_ID end)
			--	end
			--	else
			--	begin
			--		set @NewSchType_MTV_ID = (case when @OldSchType_MTV_ID not in (105105) then 105102 else @OldSchType_MTV_ID end)
			--	end

			--	--if @NewSchType_MTV_ID <> @OldSchType_MTV_ID
			--	--begin
			--	--	select top 1 @OldSchTypeText  = mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10520 and mtv.[ID] = @OldSchType
			--	--	set @OldSchTypeText = isnull(@OldSchTypeText,'')
			--	--	select top 1 @NewSchTypeText  = mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10520 and mtv.[ID] = @NewSchType
			--	--	set @NewSchTypeText = isnull(@NewSchTypeText,'')

			--	--	set @ColumnName = (case when @IsPickup = 1 then 'Pickup Schedule Type' else 'Delivery Schedule Type' end)
			--	--	exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @NewSchTypeText, @OldSchTypeText, '', @ColumnName, 'Metropolitan$Sales Linkup', @OrderID, @UserName, '40000', @OrderID
			--	--end
			--end

			--if (@EventID2 in (44,46))
			--begin
			--	exec [POMS_DB].[dbo].[Update_Metro_OrderData] @EventCode,@OrderID,@WebUserID
			--end

			set @ReturnCode = 1
			set @ReturnText = 'Updated'

			if @@TRANCOUNT > 0 and @ReturnCode = 1
			begin
				COMMIT; 
			end
			else if @@TRANCOUNT > 0 and @ReturnCode = 0
			begin
				ROLLBACK; 
			end

		end try
		begin catch
					
			if @@TRANCOUNT > 0
			begin
				ROLLBACK; 
			end

			Set @ReturnCode = 0
			Set @ReturnText = 'Internal Server Error'
					
			Declare @ERRORMESSAGE nvarchar(max) = ERROR_MESSAGE()

			exec [POMS_DB].[dbo].[P_SP_Error_Log_Add] @SPName = 'P_ScheduleDate_By_GUID_IU', @ParameterString = null, @ErrorString = @ERRORMESSAGE

		end catch

	end

	insert into @ReturnTable (ORDER_ID, ReturnCode ,ReturnText ,UserName)
	Select @ORDER_ID, @ReturnCode, @ReturnText ,@UserName 

end

select * from @ReturnTable

END
GO
