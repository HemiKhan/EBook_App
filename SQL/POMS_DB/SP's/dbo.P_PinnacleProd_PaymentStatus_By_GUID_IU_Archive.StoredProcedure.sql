USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_PaymentStatus_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_PaymentStatus_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@NewPaymentStatus int

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

if (@OrderNo <> '')
begin
	Declare @OldPaymentStatus int
	Declare @OldPaymentStatusText nvarchar(150)
	Declare @NewPaymentStatusText nvarchar(150)

	Select @OldPaymentStatus = isnull([PaymentStatus],0) from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] with (nolock) where [Document No] = @OrderNo
	set @OldPaymentStatusText = case @OldPaymentStatus when 0 then 'Current' when 1 then 'Past Due' when 2 then 'Order Hold' else '' end
	set @NewPaymentStatusText = case @NewPaymentStatus when 0 then 'Current' when 1 then 'Past Due' when 2 then 'Order Hold' else '' end
		
	if(@OldPaymentStatusText <> @NewPaymentStatusText)
	begin		
		update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [PaymentStatus] = @NewPaymentStatus where [Document No] = @OrderNo  and [Document Type] = 1 and [Register Type] = 0
		Set @pReturnCode = 1
		exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] 
			@NewPaymentStatusText
			,@OldPaymentStatusText
			,''
			,'PaymentStatus'
			,'Metropolitan$Sales Linkup'
			,@OrderNo
			,@UserName
			,40000
			,@OrderNo
	end

	if @pReturnCode = 1
	begin
		SELECT
			 Return_Code = @pReturnCode
			,Return_Text = @pReturnText
			,paymentstatus = case [PaymentStatus] when 0 then ' (Current)' when 1 then ' (Past Due)' when 2 then ' (Order Hold)' else '' end
			,paymentstatustext = case [PaymentStatus] when 0 then 'Current' when 1 then 'Past Due' when 2 then 'Order Hold' else '' end
			,[orderstatus] = isnull((select top 1 mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID] = 10080 and mtv.[ID] = sh.[Order Status]), '')
		from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock)
		inner join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) on sh.No_ = sl.[Document No]
		where sh.No_ = @OrderNo
	end
	else
	begin
		SELECT
			 Return_Code = @pReturnCode
			,Return_Text = @pReturnText
	end
end
else
begin
	set @pReturnCode = 0
	set @pReturnText = 'Invalid Order'
end

END
GO
