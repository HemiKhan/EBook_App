USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PaymentStatus_By_GUID_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ===============================================================
 Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' 
 exec [dbo].[P_PaymentStatus_By_GUID_IU] '',10100168,0,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
=============================================================== */

CREATE PROCEDURE [dbo].[P_PaymentStatus_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int

	,@NewPaymentStatus int
	
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
set @NewPaymentStatus = isnull(@NewPaymentStatus,0)

set @ORDER_ID = isnull(@ORDER_ID,0)
if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

Declare @ReturnTable table
(Return_Code bit
,Return_Text nvarchar(250)
,[paymentstatus] nvarchar(250)
,[orderstatus] nvarchar(250)
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

	Declare @OldPaymentStatus int
	Declare @OldPaymentStatusText nvarchar(150)
	Declare @NewPaymentStatusText nvarchar(150)

	SELECT @OldPaymentStatus = PaymentStatus_MTV_ID FROM [POMS_DB].[dbo].[T_Order] o WITH (NOLOCK) WHERE o.ORDER_ID = @ORDER_ID
	
	if (@OldPaymentStatus <> @NewPaymentStatus)
	begin
		SET @OldPaymentStatusText = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@OldPaymentStatus)
		SET @NewPaymentStatusText = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@NewPaymentStatus)
		
		UPDATE [POMS_DB].[dbo].[T_Order] SET PaymentStatus_MTV_ID = @NewPaymentStatus WHERE ORDER_ID = @ORDER_ID
		
		SET @ReturnCode = 1
		
		exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = @OldPaymentStatus
			,@pNewValueHidden = @NewPaymentStatus ,@pOldValue = @OldPaymentStatusText, @pNewValue = @NewPaymentStatusText, @pColumn_Name = 'PaymentStatus_MTV_ID', @pTable_Name = 'T_Order', @pReason = ''
			,@pSource_MTV_ID = @Source_MTV_ID, @pChangedBy = @UserName, @pIsAuto = 0, @pTriggerDebugInfo = 'P_PaymentStatus_By_GUID_IU'
	end

end

END
GO
