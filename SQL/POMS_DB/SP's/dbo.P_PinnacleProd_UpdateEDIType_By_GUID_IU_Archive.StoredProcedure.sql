USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_UpdateEDIType_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_UpdateEDIType_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@EstInvoiceNo nvarchar(50)
	,@NewNeedEDIType int

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
	Declare @OldNeedEDIType int = 0
	Declare @OldNeedEDI nvarchar(250) = ''
	Declare @NewNeedEDI nvarchar(250) = ''
	Declare @EDIStatusCode int = 0
	Declare @EDIStatus nvarchar(250) = ''
	Declare @NewValue nvarchar(250) = ''
	Declare @OldValue nvarchar(250) = ''

	select @OldNeedEDIType = [NeedEDICode], @OldNeedEDI = [NeedEDI], @EDIStatusCode = [EDIStatusCode], @EDIStatus = [EDIStatus] 
	from [PinnacleProd].[dbo].[V_Order_Invoice_Detail] with (nolock) where [Estimated InvoiceNo] = @EstInvoiceNo and [Order No] = @OrderNo

	set @NewNeedEDI = (case when @NewNeedEDIType = 0 then 'Setup Default' when @NewNeedEDIType = 1 then 'Yes' else 'No' end)
	select @NewValue = @NewNeedEDI + ' (' + @EstInvoiceNo + ')' ,@OldValue = @OldNeedEDI + ' (' + @EstInvoiceNo + ')'

	if(@NewValue <> @OldValue)
	begin		
		update [MetroPolitanNavProduction].[dbo].[Metropolitan$Sales Estimate Header] set [Need EDI] = @NewNeedEDIType where [No_] = @EstInvoiceNo and [Project ID] = @OrderNo
		exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @NewValue ,@OldValue ,'' ,'Need EDI' ,'Metropolitan$Sales Estimate Header' ,@OrderNo ,@UserName ,'40000' ,@OrderNo
		Set @pReturnCode = 1
	end

	SELECT Return_Code = @pReturnCode
		  ,Return_Text = @pReturnText
		  ,EstInvoiceNo = @EstInvoiceNo  
		  ,OldNeedEDIType = @OldNeedEDIType
		  ,OldNeedEDI = @OldNeedEDI 
		  ,NewNeedEDI = @NewNeedEDI 
		  ,OldEDIStatusCode = @EDIStatusCode 
		  ,OldEDIStatus = @EDIStatus 
end
else
begin
	set @pReturnCode = 0
	set @pReturnText = 'Invalid Order'
end

END
GO
