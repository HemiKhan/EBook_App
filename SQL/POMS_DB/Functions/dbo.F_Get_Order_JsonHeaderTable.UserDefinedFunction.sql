USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_JsonHeaderTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_JsonHeaderTable] ('')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_JsonHeaderTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(OrderSource_MTV_ID int
,OrderSubSource_MTV_CODE nvarchar(20)
,OrderSubSourceFileName nvarchar(50)
,OrderType_MTV_ID int
,SubOrderType_ID int
,Carrier_MTV_CODE nvarchar(20)
,ShipmentRegDate datetime
,CreatedBy nvarchar(150)
,PARENT_ORDER_ID int
,QuoteID nvarchar(50)
,QuoteAmount decimal(18,6)
,PreAssignedTrackingNo nvarchar(20)
,SELLER_KEY nvarchar(50)
,SELLER_CODE nvarchar(20)
,SUB_SELLER_KEY nvarchar(50)
,SUB_SELLER_CODE nvarchar(20)
,SELLER_PARTNER_KEY nvarchar(36)
,SELLER_PARTNER_CODE nvarchar(20)
,TARIFF_NO nvarchar(36)
,BillingType_MTV_CODE nvarchar(20)
,BillTo_CUSTOMER_KEY nvarchar(50)
,BillTo_CUSTOMER_NO nvarchar(20)
,BillToSub_CUSTOMER_NO nvarchar(20)
,billtoaddresscode nvarchar(50)
,billtoinformation nvarchar(max)
,shipfromaddresscode nvarchar(50)
,shipfrominformation nvarchar(max)
,shiptoaddresscode nvarchar(50)
,shiptoinformation nvarchar(max)
,isblindshipto bit
,clientidentifiers nvarchar(max)
,pickupotherinfo nvarchar(max)
,pickupspecialservices nvarchar(max)
,deliveryotherinfo nvarchar(max)
,deliveryspecialservices nvarchar(max)
,initialcomment nvarchar(1000)
,initialcommentispublic bit
,initialcomment2 nvarchar(1000)
,initialcommentispublic2 bit
,orderdocs nvarchar(max)
,itemsdetails nvarchar(max)
)
AS
begin

	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end
	
	insert into @ReturnTable
	select ReqHeader.*
	from OpenJson(@Json)
	WITH (
		OrderSource_MTV_ID int '$.ordersource'
		,OrderSubSource_MTV_CODE nvarchar(20) '$.ordersubsource'
		,OrderSubSourceFileName nvarchar(50) '$.ordersubsourcefilename'
		,OrderType_MTV_ID int '$.ordertype'
		,SubOrderType_ID int '$.subordertype'
		,Carrier_MTV_CODE nvarchar(20) '$.carriercode'
		,ShipmentRegDate datetime '$.shipmentregdatetime'
		,CreatedBy nvarchar(150) '$.username'
		,PARENT_ORDER_ID int '$.parentorderid'
		,QuoteID nvarchar(50) '$.quoteid'
		,QuoteAmount decimal(18,6) '$.quoteamount'
		,PreAssignedTrackingNo nvarchar(20) '$.preassignedtrackingno'
		,SELLER_KEY nvarchar(50) '$.selltocustomerkey'
		,SELLER_CODE nvarchar(20) '$.selltocustomerno'
		,SUB_SELLER_KEY nvarchar(50) '$.subselltocustomerkey'
		,SUB_SELLER_CODE nvarchar(20) '$.subselltocustomerno'
		,SELLER_PARTNER_KEY nvarchar(50) '$.selltopartnerkey'
		,SELLER_PARTNER_CODE nvarchar(20) '$.selltopartnercode'
		,TARIFF_NO nvarchar(36) '$.tariffno'
		,BillingType_MTV_CODE nvarchar(20) '$.billingtype'
		,BillTo_CUSTOMER_KEY nvarchar(50) '$.billtocustomerkey'
		,BillTo_CUSTOMER_NO nvarchar(20) '$.billtocustomerno'
		,BillToSub_CUSTOMER_NO nvarchar(20) '$.billtosubcustomerno'
		,billtoaddresscode nvarchar(50) '$.billtoaddresscode'
		,billtoinformation nvarchar(max) '$.billtoinformation' as json
		,shipfromaddresscode nvarchar(50) '$.shipfromaddresscode'
		,shipfrominformation nvarchar(max) '$.shipfrominformation' as json
		,shiptoaddresscode nvarchar(50) '$.shiptoaddresscode'
		,shiptoinformation nvarchar(max) '$.shiptoinformation' as json
		,isblindshipto bit '$.isblindshipto'
		,clientidentifiers nvarchar(max) '$.clientidentifiers' as json
		,pickupotherinfo nvarchar(max) '$.pickupotherinfo' as json
		,pickupspecialservices nvarchar(max) '$.pickupspecialservices' as json
		,deliveryotherinfo nvarchar(max) '$.deliveryotherinfo' as json
		,deliveryspecialservices nvarchar(max) '$.deliveryspecialservices' as json
		,initialcomment nvarchar(1000) '$.initialcomment'
		,initialcommentispublic bit '$.initialcommentispublic'
		,initialcomment2 nvarchar(1000) '$.initialcomment2'
		,initialcommentispublic2 bit '$.initialcommentispublic2'
		,orderdocs nvarchar(max) '$.orderdocs' as json
		,itemsdetails nvarchar(max) '$.itemsdetails' as json
	) ReqHeader

	return
	

end
GO
