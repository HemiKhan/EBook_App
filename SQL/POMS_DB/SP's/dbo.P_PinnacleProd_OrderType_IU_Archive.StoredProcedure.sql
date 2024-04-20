USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_OrderType_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[P_PinnacleProd_OrderType_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int
	,@pOrderType_ID int
	,@pSubOrderType_ID int
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

Declare @OldOrderType_ID int
Declare @OldOrderType_Name nvarchar(150)
Declare @NewOrderType_Name nvarchar(150)
Declare @OldSubOrderType_ID int
Declare @OldSubOrderType_Name nvarchar(150)
Declare @NewSubOrderType_Name nvarchar(150)

Select @OldOrderType_ID = OrderType ,@OldSubOrderType_ID = SubOrderType from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] with (nolock) where [Document No] = @OrderNo
select @OldOrderType_ID = isnull(@OldOrderType_ID,0) ,@OldSubOrderType_ID = isnull(@OldSubOrderType_ID,0)

set @OldOrderType_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10550 ,@OldOrderType_ID)
set @NewOrderType_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10550 ,@pOrderType_ID)

select @OldSubOrderType_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_SubOrderType_By_ID] (@OldOrderType_ID ,@OldSubOrderType_ID)
select @NewSubOrderType_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_SubOrderType_By_ID] (@pOrderType_ID ,@pSubOrderType_ID)

if (@OldOrderType_Name <> @NewOrderType_Name or @NewSubOrderType_Name <> @OldSubOrderType_Name)
begin
	Declare @PinnacleSourceID int = 0
	set @PinnacleSourceID = [POMS_DB].[dbo].[F_Get_PinnacleProd_Source_From_Source_MTV_ID] (@Source_MTV_ID)

	update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [OrderType] = @pOrderType_ID, [SubOrderType] = @pSubOrderType_ID where [Document No] = @OrderNo  and [Document Type] = 1 and [Register Type] = 0
		
	Set @pReturnCode = 1
		
	if @NewOrderType_Name <> @OldOrderType_Name
	begin
		exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @NewOrderType_Name ,@OldOrderType_Name ,'' ,'Order Type' ,'Metropolitan$Sales Linkup' ,@OrderNo ,@UserName ,@PinnacleSourceID,@OrderNo
	end
	if @NewSubOrderType_Name <> @OldSubOrderType_Name
	begin
		exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @NewSubOrderType_Name ,@OldSubOrderType_Name ,'' ,'Sub Order Type' ,'Metropolitan$Sales Linkup' ,@OrderNo ,@UserName ,@PinnacleSourceID,@OrderNo
	end

end
else 
begin
	set @pReturnText = 'No Change'
end

select @OldOrderType_Name as OldOrderType_Name, @NewOrderType_Name as OrderType_Name, @OldSubOrderType_Name as OldSubOrderType_Name, @NewSubOrderType_Name as SubOrderType_Name

END
GO
