USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_CompletePickuporDelivery_And_OrderStatus_By_GUID_IU]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ===============================================================
 Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' 
 exec [dbo].[P_CompletePickuporDelivery_And_OrderStatus_By_GUID_IU] '',10100168,0,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
=============================================================== */

CREATE PROCEDURE [dbo].[P_CompletePickuporDelivery_And_OrderStatus_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int

	,@IsPickup bit = 0
	,@IsCompleteOrderStatus bit = 0
	,@pReason nvarchar(1000)
	
	,@Source_MTV_ID int
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
set @pReason = isnull(@pReason,'')

set @ORDER_ID = isnull(@ORDER_ID,0)

if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

Declare @ReturnTable table
(Return_Code bit
,Return_Text nvarchar(250)
,[shippingstatus] nvarchar(250)
,[orderstatus] nvarchar(250)
,[actualpickupdate] nvarchar(250)
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

if @GetRecordType_MTV_ID in (147100,147101,147102)
begin
	Declare @OldOrderStatus_MTV_ID int = 0
	Declare @OldScheduleDate datetime = null
	Declare @OldActualDate datetime = null

	Declare @ActualDate datetime = null
	
	if (@IsPickup = 1)
	begin
		select @OldOrderStatus_MTV_ID = OrderStatus_MTV_ID, @OldScheduleDate = PromisedPickupDate, @OldActualDate = ActualPickupDate from [POMS_DB].[dbo].[T_Order] with (nolock) where ORDER_ID = @ORDER_ID
	end
	else
	begin
		select @OldOrderStatus_MTV_ID = OrderStatus_MTV_ID, @OldScheduleDate = PromisedDeliveryDate, @OldActualDate = ActualDeliveryDate from [POMS_DB].[dbo].[T_Order] with (nolock) where ORDER_ID = @ORDER_ID
	end
	
	if (@OldOrderStatus_MTV_ID <> 100100)
	begin
		set @ReturnText = 'Order Status is not Active'
	end
	
	if @ReturnText = '' and @OldScheduleDate is null
	begin
		set @ReturnText = 'Order is Not Schedule for ' + (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end)
	end

	if @ReturnText = '' and @OldActualDate is not null
	begin
		set @ReturnText = 'Actual ' + (case when @IsPickup = 1 then 'Pickup' else 'Delivery' end) + ' Date Already Exists'
	end
	
	if @ReturnText = ''
	begin
		
		set @ActualDate = @OldScheduleDate + CAST('11:00:00.000' as datetime)
		--Declare @CurrentDateTime datetime = getutcdate()
		--set @ActualDate = @OldScheduleDate + CAST(format(getutcdate(),'HH:mm:ss.fff') as datetime)

		if isnull(@ActualDate,'') <> isnull(@OldActualDate,'') and isnull(@ActualDate,'') <> ''
		begin
			drop table if exists #JsonOldEditItemsTable 
			select item.ORDER_ID, item.BARCODE 
			,ItemPickupStatus_MTV_ID = item.ItemPickupStatus_MTV_ID
			,ItemPickupStatusName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (item.ItemPickupStatus_MTV_ID)
			,ItemDeliveryStatus_MTV_ID = item.ItemDeliveryStatus_MTV_ID
			,ItemDeliveryStatusName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (item.ItemDeliveryStatus_MTV_ID)
			into #JsonOldEditItemsTable 
			from [POMS_DB].[dbo].[T_Order_Items] item with (nolock) where item.ORDER_ID = @ORDER_ID
			
			UPDATE o 
			set o.ActualPickupDate = (case when @IsPickup = 1 then @ActualDate else o.ActualPickupDate end)
			,o.ActualDeliveryDate = (case when @IsPickup = 0 then @ActualDate else o.ActualDeliveryDate end)
			from [POMS_DB].[dbo].[T_Order] o where o.ORDER_ID = @ORDER_ID

			UPDATE oi
			set oi.ItemPickupStatus_MTV_ID = (case when @IsPickup = 1 then 123101 else oi.ItemPickupStatus_MTV_ID end)
			, oi.ItemDeliveryStatus_MTV_ID = (case when @IsPickup = 0 then 122101 else oi.ItemDeliveryStatus_MTV_ID end)
			from [POMS_DB].[dbo].[T_Order_Items] oi WHERE ORDER_ID = @ORDER_ID

			drop table if exists #JsonNewEditItemsTable 
			select item.ORDER_ID, item.BARCODE 
			,ItemPickupStatus_MTV_ID = item.ItemPickupStatus_MTV_ID
			,ItemPickupStatusName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (item.ItemPickupStatus_MTV_ID)
			,ItemDeliveryStatus_MTV_ID = item.ItemDeliveryStatus_MTV_ID
			,ItemDeliveryStatusName = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (item.ItemDeliveryStatus_MTV_ID)
			into #JsonNewEditItemsTable 
			from [POMS_DB].[dbo].[T_Order_Items] item with (nolock) where item.ORDER_ID = @ORDER_ID

			Declare @ColumnName nvarchar(50) = (case when @IsPickup = 1 then 'ActualPickupDate' else 'ActualDeliveryDate' end)
			Declare @OldActualDateText nvarchar(50) = (case when @OldActualDate is null then '' else format(@OldActualDate,'yyyy-MM-dd HH:mm:ss.fff') end)
			Declare @ActualDateText nvarchar(50) = (case when @ActualDate is null then '' else format(@ActualDate,'yyyy-MM-dd HH:mm:ss.fff') end)

			exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = @OldActualDate
				, @pNewValueHidden = @ActualDate ,@pOldValue = @OldActualDateText, @pNewValue = @ActualDateText, @pColumn_Name = @ColumnName, @pTable_Name = 'T_Order', @pReason = @pReason
				, @pSource_MTV_ID = @Source_MTV_ID, @pChangedBy = @UserName, @pIsAuto = 0, @pTriggerDebugInfo = 'P_CompletePickuporDelivery_And_OrderStatus_By_GUID_IU'

			exec [POMS_DB].[dbo].[P_CompletePickuporDelivery_And_OrderStatus_By_GUID_IU_ItemTable_ChangeLog] @plogIsEdit = 1 ,@plogUserName = @UserName ,@plogSource_MTV_ID = @Source_MTV_ID

			set @ReturnCode = 1
			set @ReturnText = 'Updated'

			if (@IsCompleteOrderStatus = 1 and @IsPickup = 0)
			begin

				Declare @Ret_ReturnCode bit = 0
				Declare @Ret_ReturnText nvarchar(250) = ''

				exec [POMS_DB].[dbo].[P_Cancel_Closed_Status_By_GUID_IU] @ORDER_CODE_GUID = @ORDER_CODE_GUID ,@ORDER_ID = @ORDER_ID ,@pOrderStatus_MTV_ID = 100101 ,@pEVENTID = 0 ,@pReason = @pReason
					,@Source_MTV_ID = @Source_MTV_ID ,@UserName = @UserName ,@UserType_MTV_CODE = @UserType_MTV_CODE ,@IsPublic = @IsPublic ,@TimeZone_ID = @TimeZone_ID ,@GetRecordType_MTV_ID = @GetRecordType_MTV_ID 
					,@ReturnCode = @Ret_ReturnCode out ,@ReturnText = @Ret_ReturnText out

				if (@Ret_ReturnCode = 0)
				begin
					set @ReturnText = 'Updated but unable to trigger event'
				end
			end

		end
		else
		begin
			set @ReturnText = 'Unable to Update'
		end

	end
	
end

END
GO
