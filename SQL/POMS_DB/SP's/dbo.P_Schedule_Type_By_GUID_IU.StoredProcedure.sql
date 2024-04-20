USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Schedule_Type_By_GUID_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ===============================================================
 Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' 
 exec [dbo].[P_Schedule_Type_By_GUID_IU] '',10100168,0,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
=============================================================== */

CREATE PROCEDURE [dbo].[P_Schedule_Type_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int

	,@pNewScheduleType int
	,@pIsPickup bit
	
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
set @pNewScheduleType = isnull(@pNewScheduleType,0)

set @ORDER_ID = isnull(@ORDER_ID,0)
if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

Declare @ReturnTable table
(Return_Code bit
,Return_Text nvarchar(250)
,NewScheduleTypeText nvarchar(250)
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

	Declare @OldScheduleType int = 0
	Declare @OldScheduleTypeText nvarchar(250) = ''
	Declare @NewScheduleTypeText nvarchar(250) = ''

	SELECT @OldScheduleType = (case when @pIsPickup = 1 then PickupScheduleType_MTV_ID else DeliveryScheduleType_MTV_ID end)
	FROM [POMS_DB].[dbo].[T_Order] o WITH (NOLOCK) 
	WHERE o.ORDER_ID = @ORDER_ID

	if (@pNewScheduleType <> @OldScheduleType)
	begin
		set @OldScheduleTypeText = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@OldScheduleType)
		set @NewScheduleTypeText = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@pNewScheduleType)

		UPDATE o 
		SET o.PickupScheduleType_MTV_ID = (case when @IsPublic = 1 then @pNewScheduleType else o.PickupScheduleType_MTV_ID end)
		,o.DeliveryScheduleType_MTV_ID = (case when @IsPublic = 0 then @pNewScheduleType else o.DeliveryScheduleType_MTV_ID end)
		, ModifiedOn = GETUTCDATE()
		, ModifiedBy = @UserName 
		from [POMS_DB].[dbo].[T_Order] o WHERE o.ORDER_ID = @ORDER_ID
		
		SET @ReturnCode = 1
		Declare @ColumnName nvarchar(50) = (case when @IsPublic = 1 then 'PickupScheduleType_MTV_ID' else 'DeliveryScheduleType_MTV_ID' end)

		exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = @OldScheduleType
		,@pNewValueHidden = @OldScheduleType ,@pOldValue = @OldScheduleTypeText, @pNewValue = @NewScheduleTypeText, @pColumn_Name = @ColumnName, @pTable_Name = 'T_Order', @pReason = ''
		,@pSource_MTV_ID = @Source_MTV_ID, @pChangedBy = @UserName, @pIsAuto = 0, @pTriggerDebugInfo = 'P_Schedule_Type_By_GUID_IU'

	end	

end

END
GO
