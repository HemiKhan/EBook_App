USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_Order_Access_Log_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[P_PinnacleProd_Order_Access_Log_IU_Archive]  
	-- Add the parameters for the stored procedure here
	@ORDER_ID int
	,@OAL_ID int
	,@ViewSource_MTV_ID int
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
	set @pReturnText = ''

	if @OAL_ID = 0
	begin
		Declare @CurrentUTCDateTime datetime = getutcdate()
	
		Declare @OrderNo nvarchar(20) = cast(@ORDER_ID as nvarchar(20))
		Declare @EntityType int = 0
		Declare @Source int = 10000
		set @EntityType = [POMS_DB].[dbo].[F_Get_PinnacleProd_EntityType_From_UserType_MTV_CODE] (@UserType_MTV_CODE)
		set @Source = [POMS_DB].[dbo].[F_Get_PinnacleProd_Source_From_Source_MTV_ID] (@ViewSource_MTV_ID)

		insert [PinnacleProd].[dbo].[Metropolitan$Order Access Log] ([Client Type],[Viewed By],[Viewed On],[Sales Order],[Source],[Type])
		values (@EntityType,@UserName,@CurrentUTCDateTime,@OrderNo,@Source,0)

		select @OAL_ID=SCOPE_IDENTITY()
		
		update [PinnacleProd].[dbo].[Metro_OrderData] set [LastViewedDate] = @CurrentUTCDateTime ,[LastViewedByUser] = @UserName where [OrderNo] = @OrderNo
		set @pReturnCode = 1
	end
	else if @OAL_ID > 0 
	begin
		update [PinnacleProd].[dbo].[Metropolitan$Order Access Log] set [EndDate] = getutcdate() where [Entry No] = @OAL_ID
		set @pReturnCode = 1
	end

	select @OAL_ID as OAL_ID

END
GO
