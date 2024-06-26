USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_Schedule_Type_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_Schedule_Type_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@NewScheduleType int
	,@IsPickup bit

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

Declare @OldScheduleType int = 0
Declare @OldScheduleTypeText nvarchar(250) = ''
Declare @NewScheduleTypeText nvarchar(250) = ''

if (@OrderNo <> '')
begin

	select @OldScheduleType = (case when @IsPickup = 1 then [Pickup Schedule Type] else [Delivery Schedule Type] end)
	from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] with (nolock) where [Document No] = @OrderNo

	Select @NewScheduleTypeText = [Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] with (nolock) where [Master Type ID] = 10520 and [ID] = @NewScheduleType
	Select @OldScheduleTypeText = [Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] with (nolock) where [Master Type ID] = 10520 and [ID] = @OldScheduleType

	if (@NewScheduleType <> @OldScheduleType)
	begin
		if @IsPickup = 1
		begin
			update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [Pickup Schedule Type] = @NewScheduleType, [Modified On] = GETUTCDATE(), [Modified By] = @UserName where [Document No] = @OrderNo
			set @pReturnCode = 1
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@NewScheduleTypeText,@OldScheduleTypeText,'','Pickup Schedule Type','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
		end
		else
		begin
			update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [Delivery Schedule Type] = @NewScheduleType, [Modified On] = GETUTCDATE(), [Modified By] = @UserName where [Document No] = @OrderNo
			execute [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog]@NewScheduleTypeText,@OldScheduleTypeText,'','Delivery Schedule Type','Metropolitan$Sales Linkup',@OrderNo,@UserName,40000,@OrderNo
			set @pReturnCode = 1
		end
	end

	SELECT  
		Return_Code = @pReturnCode
		,Return_Text = @pReturnText
		,NewScheduleTypeText = @NewScheduleTypeText
end
else
begin
	set @pReturnCode = 0
	set @pReturnText = 'Invalid Order'
end

END
GO
