USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_UpdateEDIType_By_GUID_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ===============================================================
 Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' 
 exec [dbo].[P_UpdateEDIType_By_GUID_IU] '',10100168,0,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
=============================================================== */

CREATE PROCEDURE [dbo].[P_UpdateEDIType_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int

	,@EstInvoiceNo nvarchar(50)
	,@NewNeedEDIType int
	
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

set @ORDER_ID = isnull(@ORDER_ID,0)
if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

Declare @ReturnTable table
(Return_Code bit
,Return_Text nvarchar(250)
,OldNeedEDIType int
,OldNeedEDI nvarchar(250)
,NewNeedEDI nvarchar(250)
,OldEDIStatusCode int
,OldEDIStatus nvarchar(250)
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

	Declare @OldNeedEDI_MTV_ID int = 0
	Declare @OldNeedEDI nvarchar(250) = ''
	Declare @NewNeedEDI nvarchar(250) = ''

	Declare @OldEDIStatus_MTV_ID int = 0
	Declare @OldEDIStatus nvarchar(250) = ''

	SELECT 
		 @OldNeedEDI_MTV_ID = NeedEDI_MTV_ID
		,@OldEDIStatus_MTV_ID = EDIStatus_MTV_ID
	from [POMS_DB].[dbo].[T_Order_Invoice_Header] with (nolock) WHERE EstimateNo = @EstInvoiceNo and ORDER_ID = @ORDER_ID

	set @OldNeedEDI = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@OldNeedEDI_MTV_ID)
	set @NewNeedEDI = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@NewNeedEDIType)
	set @OldEDIStatus = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@OldEDIStatus_MTV_ID)

	if (@OldNeedEDI <> @NewNeedEDI)
	begin
		UPDATE [POMS_DB].[dbo].[T_Order_Invoice_Header] SET NeedEDI_MTV_ID = @NewNeedEDIType WHERE EstimateNo = @EstInvoiceNo and ORDER_ID = @ORDER_ID
		exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108108, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = @OldNeedEDI_MTV_ID
		,@pNewValueHidden = @NewNeedEDIType ,@pOldValue = @OldNeedEDI, @pNewValue = @NewNeedEDI, @pColumn_Name = 'NeedEDI_MTV_ID', @pTable_Name = 'T_Order_Invoice_Header', @pReason = ''
		,@pSource_MTV_ID = 0, @pChangedBy = @UserName, @pIsAuto = 0, @pTriggerDebugInfo = 'P_UpdateEDIType_By_GUID_IU'
		SET @ReturnCode = 1
	end

	SELECT Return_Code = @ReturnCode
		  ,Return_Text = @ReturnText
		  ,EstInvoiceNo = @EstInvoiceNo  
		  ,OldNeedEDIType = @OldNeedEDI_MTV_ID
		  ,OldNeedEDI = @OldNeedEDI 
		  ,NewNeedEDI = @NewNeedEDI 
		  ,OldEDIStatusCode = @OldEDIStatus_MTV_ID 
		  ,OldEDIStatus = @OldEDIStatus 

end
else if @GetRecordType_MTV_ID in (147103,147104,147105)
begin
	insert into @ReturnTable
	exec [POMS_DB].[dbo].[P_PinnacleProd_UpdateEDIType_By_GUID_IU] @ORDER_ID 
	,@EstInvoiceNo 
	,@NewNeedEDIType 
	,@Source_MTV_ID ,@UserName ,@UserType_MTV_CODE ,@IsPublic ,@TimeZone_ID ,@GetRecordType_MTV_ID ,@pReturnCode = @ReturnCode out ,@pReturnText = @ReturnText out
end

END
GO
