USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Process_Order_Event_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Process_Order_Event_IU]
	@pppEVENT_ID int
	,@pppORDER_ID int
	,@pppSELLER_CODE nvarchar(20)
	,@pppTriggerDate datetime
	,@pppIsActive bit
	,@pppIsAuto bit
	,@pppHUB_CODE nvarchar(20)
	,@pppSource_MTV_ID int
	,@pppTriggerDebugInfo nvarchar(4000)
	,@pppUserName nvarchar(150)
	,@pppReturn_Code bit output
	,@pppReturn_Text nvarchar(1000) output
	,@pppExecution_Error nvarchar(1000) output
	,@pppError_Text nvarchar(max) output
	,@pppIsBeginTransaction bit = 1
AS
BEGIN
	
	SET NOCOUNT ON;
	set @pppUserName = upper(@pppUserName)

	set @pppReturn_Code = 0
	set @pppReturn_Text = ''
	set @pppExecution_Error = ''
	set @pppError_Text = ''
	
	Begin Try
		
		Declare @SELLER_CODE nvarchar(20) = ''
		Declare @EVENT_CODE nvarchar(20) = ''
		Declare @Name nvarchar(250) = ''
		Declare @Activity_MTV_ID int = 0
		Declare @IsAutoTrigger bit = 0
		Declare @IsManualTrigger bit = 0
		Declare @IsOutboundRequired bit = 0
		Declare @IsNotify_Metro_Email bit = 0
		Declare @IsNotify_Metro_SMS bit = 0
		Declare @IsNotify_Client_Email bit = 0
		Declare @IsNotify_Client_SMS bit = 0
		Declare @IsNotify_OED_Email bit = 0
		Declare @IsNotify_OED_SMS bit = 0
		Declare @IsNotify_CSR_Email bit = 0
		Declare @IsNotify_CSR_SMS bit = 0
		Declare @IsNotify_Dispatch_Email bit = 0
		Declare @IsNotify_Dispatch_SMS bit = 0
		Declare @IsNotify_Accounting_Email bit = 0
		Declare @IsNotify_Accounting_SMS bit = 0
		Declare @IsNotify_Warehouse_Email bit = 0
		Declare @IsNotify_Warehouse_SMS bit = 0
		Declare @IsNotify_ShipFrom_Email bit = 0
		Declare @IsNotify_ShipFrom_SMS bit = 0
		Declare @IsNotify_ShipTo_Email bit = 0
		Declare @IsNotify_ShipTo_SMS bit = 0
		Declare @IsRecurring bit = 0
		Declare @IsPublic bit = 0
		Declare @IsTrackingAvailable bit = 0
		Declare @IsUpdateShippingStatus bit = 0
		Declare @IsActive bit = 0

		if (@pppEVENT_ID = 1)
		begin
			select @SELLER_CODE = SellerCode ,@EVENT_CODE = EVENT_CODE ,@Name = [Name] ,@Activity_MTV_ID = Activity_MTV_ID ,@IsAutoTrigger = IsAutoTrigger 
			,@IsManualTrigger = IsManualTrigger ,@IsOutboundRequired = IsOutboundRequired ,@IsNotify_Metro_Email = IsNotify_Metro_Email ,@IsNotify_Metro_SMS = IsNotify_Metro_SMS 
			,@IsNotify_Client_Email = IsNotify_Client_Email ,@IsNotify_Client_SMS = IsNotify_Client_SMS ,@IsNotify_OED_Email = IsNotify_OED_Email ,@IsNotify_OED_SMS = IsNotify_OED_SMS 
			,@IsNotify_CSR_Email = IsNotify_CSR_Email ,@IsNotify_CSR_SMS = IsNotify_CSR_SMS ,@IsNotify_Dispatch_Email = IsNotify_Dispatch_Email ,@IsNotify_Dispatch_SMS = IsNotify_Dispatch_SMS 
			,@IsNotify_Accounting_Email = IsNotify_Accounting_Email ,@IsNotify_Accounting_SMS = IsNotify_Accounting_SMS ,@IsNotify_Warehouse_Email = IsNotify_Warehouse_Email 
			,@IsNotify_Warehouse_SMS = IsNotify_Warehouse_SMS ,@IsNotify_ShipFrom_Email = IsNotify_ShipFrom_Email ,@IsNotify_ShipFrom_SMS = IsNotify_ShipFrom_SMS 
			,@IsNotify_ShipTo_Email = IsNotify_ShipTo_Email ,@IsNotify_ShipTo_SMS = IsNotify_ShipTo_SMS ,@IsRecurring = IsRecurring ,@IsPublic = IsPublic ,@IsTrackingAvailable = IsTrackingAvailable 
			,@IsUpdateShippingStatus = IsUpdateShippingStatus ,@IsActive = IsActive from [POMS_DB].[dbo].[F_Get_Client_Events_List_From_EventID] (@pppSELLER_CODE, @pppORDER_ID ,@pppSELLER_CODE ,'')
		end
		else
		begin
			select @SELLER_CODE = SellerCode ,@EVENT_CODE = EVENT_CODE ,@Name = [Name] ,@Activity_MTV_ID = Activity_MTV_ID ,@IsAutoTrigger = IsAutoTrigger 
			,@IsManualTrigger = IsManualTrigger ,@IsOutboundRequired = IsOutboundRequired ,@IsNotify_Metro_Email = IsNotify_Metro_Email ,@IsNotify_Metro_SMS = IsNotify_Metro_SMS 
			,@IsNotify_Client_Email = IsNotify_Client_Email ,@IsNotify_Client_SMS = IsNotify_Client_SMS ,@IsNotify_OED_Email = IsNotify_OED_Email ,@IsNotify_OED_SMS = IsNotify_OED_SMS 
			,@IsNotify_CSR_Email = IsNotify_CSR_Email ,@IsNotify_CSR_SMS = IsNotify_CSR_SMS ,@IsNotify_Dispatch_Email = IsNotify_Dispatch_Email ,@IsNotify_Dispatch_SMS = IsNotify_Dispatch_SMS 
			,@IsNotify_Accounting_Email = IsNotify_Accounting_Email ,@IsNotify_Accounting_SMS = IsNotify_Accounting_SMS ,@IsNotify_Warehouse_Email = IsNotify_Warehouse_Email 
			,@IsNotify_Warehouse_SMS = IsNotify_Warehouse_SMS ,@IsNotify_ShipFrom_Email = IsNotify_ShipFrom_Email ,@IsNotify_ShipFrom_SMS = IsNotify_ShipFrom_SMS 
			,@IsNotify_ShipTo_Email = IsNotify_ShipTo_Email ,@IsNotify_ShipTo_SMS = IsNotify_ShipTo_SMS ,@IsRecurring = IsRecurring ,@IsPublic = IsPublic ,@IsTrackingAvailable = IsTrackingAvailable 
			,@IsUpdateShippingStatus = IsUpdateShippingStatus ,@IsActive = IsActive from [POMS_DB].[dbo].[F_Get_Order_Events_List_From_OrderID_And_EventID] (@pppORDER_ID,@pppEVENT_ID) 
		end

		if @pppIsBeginTransaction = 1
		begin
			Begin Transaction
		end
		
		insert into [POMS_DB].[dbo].[T_Order_Events] ([EVENT_ID] ,[ORDER_ID] ,[SELLER_CODE] ,[TriggerDate] ,[Source_MTV_ID] ,[TriggerDebugInfo] ,[IsActive] ,[IsAuto] ,[HUB_CODE] ,[CreatedBy])
		values (@pppEVENT_ID, @pppORDER_ID, @SELLER_CODE, @pppTriggerDate, @pppSource_MTV_ID, @pppTriggerDebugInfo, @pppIsActive, @pppIsAuto, @pppHUB_CODE, @pppUserName)

		if (@IsUpdateShippingStatus = 1 and @pppEVENT_ID <> 1)
		begin
			Update [POMS_DB].[dbo].[T_Order] set ShippingStatus_EVENT_ID = @pppEVENT_ID where ORDER_ID = @pppORDER_ID
		end

		if @pppExecution_Error = '' and @pppReturn_Text = '' and @pppError_Text = ''
		begin
			set @pppReturn_Code = 1
		end

		if @pppIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pppReturn_Code = 1
		begin
			COMMIT; 
		end
		else if @pppIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pppReturn_Code = 0
		begin
			ROLLBACK; 
		end

	End Try
	Begin catch
		if @pppIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @pppError_Text = 'P_Process_Order_Event_IU: ' + ERROR_MESSAGE()
	End catch

END
GO
