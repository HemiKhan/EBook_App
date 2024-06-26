USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_Cancel_Closed_Status_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_Cancel_Closed_Status_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@pStatus int
	,@pEventCode int
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

Declare @CustomerNo nvarchar(20)
Declare @OdlOrderStatus int
Declare @OldOrderStatusText nvarchar(50)
Declare @NewOrderStatusText nvarchar(50)
Declare @Result nvarchar(250) = ''
Declare @CurrentDateTime datetime = getutcdate()

set @pStatus = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@pStatus)

Select 
@CustomerNo=SH.[Bill-to Customer No_]
,@OdlOrderStatus=SH.[Order Status]
,@OldOrderStatusText=isnull(( Select Top 1 [Description] from PinnacleProd.[dbo].[Metropolitan$Master Type Value] mtv with(nolock) where mtv.[Master Type ID]=10080 And mtv.ID=SH.[Order Status]),'')
,@NewOrderStatusText=isnull(( Select Top 1 [Description] from PinnacleProd.[dbo].[Metropolitan$Master Type Value] mtv with(nolock) where mtv.[Master Type ID]=10080 And mtv.ID=@pStatus),'')
from [PinnacleProd].[dbo].[Metropolitan$Sales Header] SH with(nolock) where SH.No_ = @OrderNo

Select @Result = (case when (@OdlOrderStatus <> (SELECT [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderStatus_MTV_ID] (100100)) and @pStatus <> (SELECT [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderStatus_MTV_ID] (100100))) then 'Order Status is Not Active'
when @OldOrderStatusText = @NewOrderStatusText then 'Order Status is Already Changed to ' + @NewOrderStatusText
when @pStatus = (SELECT [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderStatus_MTV_ID] (100102)) and @pEventCode = 0 then 'Please Select Shipping Status'
else '' end)

if @Result = ''
begin
	Declare @Comment nvarchar (1000)
	if @pStatus = (SELECT [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderStatus_MTV_ID] (100103))
	begin
		set @pEventCode = 52
	end
	else if @pStatus = (SELECT [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderStatus_MTV_ID] (100104))
	begin
		set @pEventCode = 0
	end
	else if @pStatus = (SELECT [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderStatus_MTV_ID] (100100))
	begin
		set @pEventCode = 104
	end
	else if @pStatus = (SELECT [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderStatus_MTV_ID] (100102))
	begin
		set @Comment = @pReason
		set @pReason = ''
		exec [PinnacleProd].[dbo].[Metro_AddOrderGeneralComment] @OrderNo,@Comment,1,@UserName,40000,1,0
	end

	if (@OdlOrderStatus <> @pStatus)
	begin
		Declare @PinnacleSourceID int = 0
		set @PinnacleSourceID = [POMS_DB].[dbo].[F_Get_PinnacleProd_Source_From_Source_MTV_ID] (@Source_MTV_ID)

		UPDATE [PinnacleProd].[dbo].[Metropolitan$Sales Header] set [Order Status]=@pStatus, [Modified On] = @CurrentDateTime where [No_] = @OrderNo and [Document Type] = 1
		EXECUTE PinnacleProd.[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] @pEventCode,0,0,0,@Source_MTV_ID,1,'10000','ShippingStatus/OrderDetail/UpdateShippingStatus',@UserName,@OrderNo,@CustomerNo,'','',''

		if @NewOrderStatusText <> @OldOrderStatusText
		begin
			exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @NewOrderStatusText,@OldOrderStatusText,'','Order Status','Metropolitan$Sales Header',@OrderNo,@UserName,@PinnacleSourceID,@OrderNo
		end

		set @pReturnCode = 1		
		Set @pReturnText = 'UPDATED'
	end
	else 
	begin
		Set @pReturnCode = 0
		Set @pReturnText = 'No Change'
	end
end
else
begin
	Set @pReturnCode = 0
	Set @pReturnText = 'Invalid Order'
end

if (@pReturnCode = 1)
begin		
	Select 
	 ShippingStatus = isnull((select top 1 evm.[Events] from [PinnacleProd].[dbo].[Metropolitan$Event Master] evm with (nolock) where evm.[Entry No] = sh.[Shipping Status]), '')
	,OrderStatus = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.[ID] = sh.[Order Status]), '')
	,PaymentStatus = case [PaymentStatus] when 0 then 'Current' when 1 then 'Past Due' when 2 then 'Order Hold' else '' end		
	,OldStatus = @OldOrderStatusText
	,NewStatus = @NewOrderStatusText
	From PinnacleProd.[dbo].[Metropolitan$Sales Linkup] sl with (nolock) inner join PinnacleProd.[dbo].[Metropolitan$Sales Header] sh with (nolock) on sl.[Document No] = sh.No_
	where sl.[Document No] = @OrderNo
end
else
begin
	Select Return_Code = @pReturnCode, Return_Text = @pReturnText 
end

END
GO
