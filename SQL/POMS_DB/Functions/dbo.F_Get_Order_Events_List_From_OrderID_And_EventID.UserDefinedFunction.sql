USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_Events_List_From_OrderID_And_EventID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_Events_List_From_OrderID_And_EventID] (10100237,1) 
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_Events_List_From_OrderID_And_EventID]
(	
	@ORDER_ID int
	,@Event_ID int
)
returns @ReturnTable table
(SellerKey nvarchar(36)
,SellerCode nvarchar(20)
,SellerName nvarchar(250)
,Order_ID int
,[EVENT_ID] int
,[EVENT_CODE] nvarchar(20)
,[Name] nvarchar(250)
,[Description] nvarchar(1000)
,[Activity_MTV_ID] int
,[IsAutoTrigger] bit
,[IsManualTrigger] bit
,[IsOutboundRequired] bit
,[IsNotify_Metro_Email] bit
,[IsNotify_Metro_SMS] bit
,[IsNotify_Client_Email] bit
,[IsNotify_Client_SMS] bit
,[IsNotify_OED_Email] bit
,[IsNotify_OED_SMS] bit
,[IsNotify_CSR_Email] bit
,[IsNotify_CSR_SMS] bit
,[IsNotify_Dispatch_Email] bit
,[IsNotify_Dispatch_SMS] bit
,[IsNotify_Accounting_Email] bit
,[IsNotify_Accounting_SMS] bit
,[IsNotify_Warehouse_Email] bit
,[IsNotify_Warehouse_SMS] bit
,[IsNotify_ShipFrom_Email] bit
,[IsNotify_ShipFrom_SMS] bit
,[IsNotify_ShipTo_Email] bit
,[IsNotify_ShipTo_SMS] bit
,[IsNotify_SellTo_Email] bit
,[IsNotify_SellTo_SMS] bit
,[IsNotify_SellToPartner_Email] bit
,[IsNotify_SellToPartner_SMS] bit
,[IsNotify_BillTo_Email] bit
,[IsNotify_BillTo_SMS] bit
,[IsRecurring] bit
,[IsPublic] bit
,[IsTrackingAvailable] bit
,[IsUpdateShippingStatus] bit
,[IsActive] bit
)
AS
Begin

	Declare @SellerKey nvarchar(36) = ''
	Declare @SellerCode nvarchar(20) = ''
	Declare @SellerName nvarchar(250) = ''

	select @SellerKey = s.SELLER_KEY
	,@SellerCode = s.SELLER_CODE
	,@SellerName = s.Company
	from [POMS_DB].[dbo].[T_Order] o with (nolock) 
	inner join [POMS_DB].[dbo].[T_Seller_List] s with (nolock) on o.SELLER_CODE = s.SELLER_CODE
	where ORDER_ID = @ORDER_ID

	set @SellerKey = isnull(@SellerKey,'')
	set @SellerCode = isnull(@SellerCode,'')
	set @SellerName = isnull(@SellerName,'')

	if (@SellerCode = '')
	begin
		return
	end

	insert into @ReturnTable 
	select 
	ilv.SellerKey
	,ilv.SellerCode
	,ilv.SellerName
	,Order_ID=@ORDER_ID
	,ilv.[EVENT_ID]
	,ilv.[EVENT_CODE]
	,ilv.[Name]
	,[Description]=isnull(cel.[Description],ilv.[Description])
	,ilv.[Activity_MTV_ID]
	,ilv.[IsAutoTrigger]
	,ilv.[IsManualTrigger]
	,[IsOutboundRequired]=isnull(cel.[IsOutboundRequired],ilv.[IsOutboundRequired])
	,[IsNotify_Metro_Email]=isnull(cel.[IsNotify_Metro_Email],ilv.[IsNotify_Metro_Email])
	,[IsNotify_Metro_SMS]=isnull(cel.[IsNotify_Metro_SMS],ilv.[IsNotify_Metro_SMS])
	,[IsNotify_Client_Email]=isnull(cel.[IsNotify_Client_Email],ilv.[IsNotify_Client_Email])
	,[IsNotify_Client_SMS]=isnull(cel.[IsNotify_Client_SMS],ilv.[IsNotify_Client_SMS])
	,[IsNotify_OED_Email]=isnull(cel.[IsNotify_OED_Email],ilv.[IsNotify_OED_Email])
	,[IsNotify_OED_SMS]=isnull(cel.[IsNotify_OED_SMS],ilv.[IsNotify_OED_SMS])
	,[IsNotify_CSR_Email]=isnull(cel.[IsNotify_CSR_Email],ilv.[IsNotify_CSR_Email])
	,[IsNotify_CSR_SMS]=isnull(cel.[IsNotify_CSR_SMS],ilv.[IsNotify_CSR_SMS])
	,[IsNotify_Dispatch_Email]=isnull(cel.[IsNotify_Dispatch_Email],ilv.[IsNotify_Dispatch_Email])
	,[IsNotify_Dispatch_SMS]=isnull(cel.[IsNotify_Dispatch_SMS],ilv.[IsNotify_Dispatch_SMS])
	,[IsNotify_Accounting_Email]=isnull(cel.[IsNotify_Accounting_Email],ilv.[IsNotify_Accounting_Email])
	,[IsNotify_Accounting_SMS]=isnull(cel.[IsNotify_Accounting_SMS],ilv.[IsNotify_Accounting_SMS])
	,[IsNotify_Warehouse_Email]=isnull(cel.[IsNotify_Warehouse_Email],ilv.[IsNotify_Warehouse_Email])
	,[IsNotify_Warehouse_SMS]=isnull(cel.[IsNotify_Warehouse_SMS],ilv.[IsNotify_Warehouse_SMS])
	,[IsNotify_ShipFrom_Email]=isnull(cel.[IsNotify_ShipFrom_Email],ilv.[IsNotify_ShipFrom_Email])
	,[IsNotify_ShipFrom_SMS]=isnull(cel.[IsNotify_ShipFrom_SMS],ilv.[IsNotify_ShipFrom_SMS])
	,[IsNotify_ShipTo_Email]=isnull(cel.[IsNotify_ShipTo_Email],ilv.[IsNotify_ShipTo_Email])
	,[IsNotify_ShipTo_SMS]=isnull(cel.[IsNotify_ShipTo_SMS],ilv.[IsNotify_ShipTo_SMS])
	,[IsNotify_SellTo_Email]=isnull(cel.[IsNotify_SellTo_Email],ilv.[IsNotify_SellTo_Email])
	,[IsNotify_SellTo_SMS]=isnull(cel.[IsNotify_SellTo_SMS],ilv.[IsNotify_SellTo_SMS])
	,[IsNotify_SellToPartner_Email]=isnull(cel.[IsNotify_SellToPartner_Email],ilv.[IsNotify_SellToPartner_Email])
	,[IsNotify_SellToPartner_SMS]=isnull(cel.[IsNotify_SellToPartner_SMS],ilv.[IsNotify_SellToPartner_SMS])
	,[IsNotify_BillTo_Email]=isnull(cel.[IsNotify_BillTo_Email],ilv.[IsNotify_BillTo_Email])
	,[IsNotify_BillTo_SMS]=isnull(cel.[IsNotify_BillTo_SMS],ilv.[IsNotify_BillTo_SMS])
	,ilv.[IsRecurring]
	,[IsPublic]=isnull(cel.[IsPublic],ilv.[IsPublic])
	,[IsTrackingAvailable]=isnull(cel.[IsTrackingAvailable],ilv.[IsTrackingAvailable])
	,ilv.[IsUpdateShippingStatus]
	,[IsActive]=isnull(cel.[IsActive],ilv.[IsActive])
	from (
		select SellerKey
			,SellerCode
			,SellerName
			,EVENT_ID
			,EVENT_CODE
			,[Name]
			,[Description]
			,Activity_MTV_ID
			,IsAutoTrigger
			,IsManualTrigger
			,IsOutboundRequired
			,IsNotify_Metro_Email
			,IsNotify_Metro_SMS
			,IsNotify_Client_Email
			,IsNotify_Client_SMS
			,IsNotify_OED_Email
			,IsNotify_OED_SMS
			,IsNotify_CSR_Email
			,IsNotify_CSR_SMS
			,IsNotify_Dispatch_Email
			,IsNotify_Dispatch_SMS
			,IsNotify_Accounting_Email
			,IsNotify_Accounting_SMS
			,IsNotify_Warehouse_Email
			,IsNotify_Warehouse_SMS
			,IsNotify_ShipFrom_Email
			,IsNotify_ShipFrom_SMS
			,IsNotify_ShipTo_Email
			,IsNotify_ShipTo_SMS
			,IsNotify_SellTo_Email
			,IsNotify_SellTo_SMS
			,IsNotify_SellToPartner_Email
			,IsNotify_SellToPartner_SMS
			,IsNotify_BillTo_Email
			,IsNotify_BillTo_SMS
			,IsRecurring
			,IsPublic
			,IsTrackingAvailable
			,IsUpdateShippingStatus
			,IsActive
		from [POMS_DB].[dbo].[F_Get_Client_Events_List_From_EventID] (@SellerKey, @Event_ID ,@SellerCode ,@SellerName)
	)ilv left join [POMS_DB].[dbo].[T_Order_Events_List] cel with (nolock) on ilv.EVENT_ID = cel.EVENT_ID and cel.ORDER_ID = @ORDER_ID
	
	return

end
GO
