USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_OrderPriority_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[P_PinnacleProd_OrderPriority_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int
	,@pOrderPriority_MTV_ID int
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

Declare @OldOrderPriority_MTV_ID int
Declare @OldOrderPriority_Name nvarchar(150)
Declare @OrderPriority_Name nvarchar(150)

Select @OldOrderPriority_MTV_ID = [Priority] from [PinnacleProd].[dbo].[Metropolitan$Sales Header] with (nolock) where [No_] = @OrderNo
set @OldOrderPriority_MTV_ID = isnull(@OldOrderPriority_MTV_ID,0)

set @OldOrderPriority_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10250 ,@OldOrderPriority_MTV_ID)
set @OrderPriority_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10250 ,@pOrderPriority_MTV_ID)

if(@OldOrderPriority_Name <> @OrderPriority_Name)
begin
	Declare @PinnacleSourceID int = 0
	set @PinnacleSourceID = [POMS_DB].[dbo].[F_Get_PinnacleProd_Source_From_Source_MTV_ID] (@Source_MTV_ID)
		
	update [PinnacleProd].[dbo].[Metropolitan$Sales Header] set [Priority] = @pOrderPriority_MTV_ID where [No_] = @OrderNo
		
	Set @pReturnCode = 1
		
	exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @OrderPriority_Name ,@OldOrderPriority_Name ,'' ,'Priority' ,'Metropolitan$Sales Header' ,@OrderNo ,@UserName ,40000 ,@OrderNo
end
else
begin
	set @pReturnText = 'No Change'
end

	select @OldOrderPriority_Name as OldOrderPriority_Name, @OrderPriority_Name as OrderPriority_Name

END
GO
