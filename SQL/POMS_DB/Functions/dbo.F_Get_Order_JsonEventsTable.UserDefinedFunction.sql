USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_JsonEventsTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_JsonEventsTable] ('C100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_JsonEventsTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(ID int identity(1,1)
,EVENT_ID int
,ORDER_ID int
,SELLER_CODE nvarchar(20)
,TriggerDate datetime
,IsActive bit
,IsAuto bit
,HUB_CODE nvarchar(20))
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
	
	insert into @ReturnTable (EVENT_ID ,ORDER_ID ,SELLER_CODE ,TriggerDate ,IsActive ,IsAuto ,HUB_CODE)
	select EVENT_ID = isnull(ev.EVENT_ID,0)
		,ORDER_ID = isnull(ev.ORDER_ID,0)
		,SELLER_CODE = isnull(ev.SELLER_CODE,'')
		,TriggerDate = isnull(ev.TriggerDate,getutcdate())
		,IsActive = isnull(ev.IsActive,1)
		,IsAuto = isnull(ev.IsAuto,0)
		,HUB_CODE = isnull(ev.HUB_CODE,'')
	from OpenJson(@Json)
	WITH (
		EVENT_ID int '$.eventid'
		,ORDER_ID int '$.orderid'
		,SELLER_CODE nvarchar(20) '$.sellercode'
		,TriggerDate datetime '$.triggerdatetime'
		,IsActive bit '$.isactive'
		,IsAuto bit '$.isauto'
		,HUB_CODE nvarchar(20) '$.hudcode'
	) ev

	return

end
GO
