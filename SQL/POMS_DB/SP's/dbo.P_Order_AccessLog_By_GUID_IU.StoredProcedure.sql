USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_AccessLog_By_GUID_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_Order_AccessLog_By_GUID_IU] '',10100168,0,107100,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Order_AccessLog_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	,@OAL_ID int
	,@ViewSource_MTV_ID int
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

if @ORDER_ID = 0
begin
	set @ReturnText = 'Invalid OrderID'
	select @OAL_ID as OAL_ID
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
	if (@OAL_ID = 0)
	begin
		Declare @CurrentUTCDateTime datetime = getutcdate()
		insert into [POMS_DB].[dbo].[T_Order_Access_Log] (ORDER_ID,UserType_MTV_CODE,ViewedBy,ViewedOn,ViewSource_MTV_ID)
		values (@ORDER_ID,@UserType_MTV_CODE,@UserName,@CurrentUTCDateTime,@ViewSource_MTV_ID)
		set @OAL_ID = SCOPE_IDENTITY()
		
		update oai
			set oai.LastViewedByUserName = @UserName
			,oai.LastViewedDate = @CurrentUTCDateTime
		from [POMS_DB].[dbo].[T_Order_Additional_Info] oai where oai.ORDER_ID = @ORDER_ID

		set @ReturnCode = 1
	end
	else if @OAL_ID > 0
	begin
		update oal
		set oal.EndDate = getutcdate()
		from [POMS_DB].[dbo].[T_Order_Access_Log] oal where oal.OAL_ID = @OAL_ID
		
		set @ReturnCode = 1
	end
end
else if @GetRecordType_MTV_ID in (147103,147104,147105)
begin
	Declare @Ret_OAL_ID int = @OAL_ID
	exec @Ret_OAL_ID = [POMS_DB].[dbo].[P_PinnacleProd_Order_Access_Log_IU] @ORDER_ID ,@OAL_ID ,@ViewSource_MTV_ID ,@UserName ,@UserType_MTV_CODE ,@IsPublic ,@TimeZone_ID ,@GetRecordType_MTV_ID ,@pReturnCode = @ReturnCode out ,@pReturnText = @ReturnText out
	set @OAL_ID = @Ret_OAL_ID
end

select @OAL_ID as OAL_ID

END
GO
