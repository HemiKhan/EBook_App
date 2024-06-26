USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_InvoiceType_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[P_PinnacleProd_InvoiceType_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int
	,@pInvoiceType_MTV_ID int
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

Declare @OldInvoiceType_MTV_ID int
Declare @OldInvoiceType_Name nvarchar(150)
Declare @InvoiceType_Name nvarchar(150)

Select @OldInvoiceType_MTV_ID = [InvoiceType] from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] with (nolock) where [Document No] = @OrderNo
set @OldInvoiceType_MTV_ID = isnull(@OldInvoiceType_MTV_ID,0)

set @OldInvoiceType_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10540 ,@OldInvoiceType_MTV_ID)
set @InvoiceType_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_MasterTypeValue_From_MTV_ID_And_MT_ID] (10540 ,@pInvoiceType_MTV_ID)

if(@OldInvoiceType_Name <> @InvoiceType_Name)
begin
	Declare @PinnacleSourceID int = 0
	set @PinnacleSourceID = [POMS_DB].[dbo].[F_Get_PinnacleProd_Source_From_Source_MTV_ID] (@Source_MTV_ID)
		
	update [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] set [InvoiceType] = @pInvoiceType_MTV_ID where [Document No] = @OrderNo
		
	Set @pReturnCode = 1
		
	exec [PinnacleProd].[dbo].[Metro_CheckAndAddAuditLog] @InvoiceType_Name ,@OldInvoiceType_Name ,'' ,'InvoiceType' ,'Metropolitan$Sales Linkup' ,@OrderNo ,@UserName ,40000 ,@OrderNo
end
else
begin
	set @pReturnText = 'No Change'
end

	select @OldInvoiceType_Name as OldInvoiceType_Name, @InvoiceType_Name as InvoiceType_Name

END
GO
