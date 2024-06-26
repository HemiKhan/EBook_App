USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_CompleteDelivery_And_OrderStatus_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_CompleteDelivery_And_OrderStatus_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@pIsCompleteStatus Bit
	,@pReason nvarchar(1000)

	,@Source_MTV_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@pReturnCode bit output
	,@pReturnText nvarchar(250) output
AS
BEGIN
	
set @pReturnCode = 0
Declare @OrderNo nvarchar(20) = cast(@ORDER_ID as nvarchar(20))
set @UserName = upper(@UserName)

Declare @EventCode int = 54
Declare @Sch_Date date
Declare @UpdateActualDate datetime
Declare @ActualDeliveryDate datetime
Declare @CustomerNo nvarchar(20)
Declare @OrderStatus int = 0
Declare @OldOrderStatusText nvarchar(50)
Declare @NewOrderStatusText nvarchar(50) = 'Complete'
Declare @CurrentDateTime datetime = getutcdate()
Declare @IsEventTriggered bit = 0

if (@OrderNo <> '')
begin
	select @IsEventTriggered = (case when year([Actual Delivery Date]) > 2000 then 1 else 0 end) from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] with (nolock) where [Document No] = @OrderNo
	if @IsEventTriggered = 0
	begin			
		select 
		 @CustomerNo=SH.[Bill-to Customer No_]
		,@OrderStatus=SH.[Order Status]
		,@OldOrderStatusText=isnull(( Select Top 1 [Description] from PinnacleProd.[dbo].[Metropolitan$Master Type Value] mtv with(nolock) where mtv.[Master Type ID]=10080 And mtv.ID=SH.[Order Status]),'')
		,@Sch_Date=Case When Year(SH.[Promised Delivery Date]) < 1950 Then null ELSE SH.[Promised Delivery Date] END
		--,@ActualDeliveryDate=Case When Year(SL.[Actual Delivery Date]) < 1950 Then null ELSE cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), SL.[Actual Delivery Date]  ) as datetime) END
		from [PinnacleProd].[dbo].[Metropolitan$Sales Header] SH with(nolock) where SH.No_ = @OrderNo

		Select @pReturnText = (case when @OrderStatus <> 10000 then 'Order Status is Not Active'
		when cast(@Sch_Date as date) > cast(getutcdate() as date) then 'Cannot Complete Delivery In Future Date'
		when @Sch_Date is null then 'Order is Not Schedule for Delivery'
		else '' end)

		if @pReturnText = ''
		begin
			select @UpdateActualDate = DATEADD(hour,12,cast(@Sch_Date as datetime)) 
					
			update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [Actual Delivery Date]=@UpdateActualDate,[Delivery Completed]=1 where [Document No]=@OrderNo
			update [PinnacleProd].[dbo].[Metropolitan$Sales Line Link]	set [Item Delivery Status]=1 where [Sales Order No]=@OrderNo and [Document Type]=1
		
			EXECUTE [PinnacleProd].[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] 
				@EventCode
				,0
				,0
				,0
				,@UserName
				,1
				,'10000'
				,'ShippingStatus/OrderDetail/UpdateShippingStatus'
				,@UserName
				,@OrderNo
				,@CustomerNo
				,''
				,''
				,''
			
			if (@pIsCompleteStatus = 1 and @OrderStatus = 10000)
			begin
				update [PinnacleProd].[dbo].[Metropolitan$Sales Header] set [Order Status]=20000, [Modified On] = @CurrentDateTime where [No_] =@OrderNo and [Document Type] = 1
				execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@NewOrderStatusText,@OldOrderStatusText,@pReason,'Order Status','Metropolitan$Sales Header',@OrderNo,@UserName,40000,@OrderNo
				set @pReturnCode = 1
				set @pReturnText = ''
			end
			else
			begin
				set @pReturnCode = 1
			end

		end

	end
	else
	begin
		select 
			 @CustomerNo=SH.[Bill-to Customer No_]
			,@OrderStatus=SH.[Order Status]
			,@OldOrderStatusText=isnull(( Select Top 1 [Description] from PinnacleProd.[dbo].[Metropolitan$Master Type Value] mtv with(nolock) where mtv.[Master Type ID]=10080 And mtv.ID=SH.[Order Status]),'')
			,@Sch_Date=Case When Year(SH.[Promised Delivery Date]) < 1950 Then null ELSE SH.[Promised Delivery Date] END
			--,@ActualDeliveryDate=Case When Year(SL.[Actual Delivery Date]) < 1950 Then null ELSE cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), SL.[Actual Delivery Date]  ) as datetime) END
		from [PinnacleProd].[dbo].[Metropolitan$Sales Header] SH with(nolock) where SH.No_ = @OrderNo

		Select @pReturnText = (case when @OrderStatus <> 10000 then 'Order Status is Not Active'
		when cast(@Sch_Date as date) > cast(getutcdate() as date) then 'Cannot Complete Delivery In Future Date'
		when @Sch_Date is null then 'Order is Not Schedule for Delivery'
		else '' end)

		if (@pIsCompleteStatus = 1 and @OrderStatus = 10000)
		begin
			update [PinnacleProd].[dbo].[Metropolitan$Sales Header] set [Order Status]=20000, [Modified On] = @CurrentDateTime where [No_] =@OrderNo and [Document Type] = 1
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@NewOrderStatusText,@OldOrderStatusText,@pReason,'Order Status','Metropolitan$Sales Header',@OrderNo,@UserName,40000,@OrderNo
			set @pReturnCode = 1
			set @pReturnText = ''
		end
		else
		begin
			set @pReturnCode = 0
		end
	end

	if (@pReturnCode = 1)
	begin
		Select Return_Code = @pReturnCode, Return_Text = @pReturnText
		,[shippingstatus] = isnull((select top 1 evm.[Events] from [PinnacleProd].[dbo].[Metropolitan$Event Master] evm with (nolock) where evm.[Entry No] = sh.[Shipping Status]), '')
		,[orderstatus] = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.[ID] = sh.[Order Status]), '')
		,[actualdeliverydate] = case when year(sl.[Actual Delivery Date]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[Actual Delivery Date],@TimeZone_ID,14400000) end
		,[paymentstatus] = (case when sl.PaymentStatus = 0 then ' (Current)'
			when sl.PaymentStatus = 1 then ' (Past Due)'
			when sl.PaymentStatus = 2 then ' (Order Hold)'
			else '' end)
		From PinnacleProd.[dbo].[Metropolitan$Sales Linkup] sl with (nolock)
		inner join PinnacleProd.[dbo].[Metropolitan$Sales Header] sh with (nolock) on sl.[Document No] = sh.No_
		where sl.[Document No]=@OrderNo
	end
	else
	begin
		select Return_Code = @pReturnCode, Return_Text = @pReturnText
	end
end
else
begin
	set @pReturnCode = 0
	set @pReturnText = 'Invalid Order'
end

END
GO
