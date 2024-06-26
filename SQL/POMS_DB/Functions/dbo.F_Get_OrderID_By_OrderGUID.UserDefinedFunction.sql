USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_OrderID_By_OrderGUID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] ('8EB285F5-9C49-4F6A-AA7A-D7B1F67F38E6',null)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_OrderID_By_OrderGUID]
(	
	@OrderGUID nvarchar(36)
	,@GetRecordType_MTV_ID int = 147100
)
RETURNS int

AS
begin
	
	set @OrderGUID = isnull(@OrderGUID,'')
	Declare @ORDER_ID int = 0
	if (isnull(@GetRecordType_MTV_ID,0) = 0)
	begin
		set @GetRecordType_MTV_ID = 147100
	end

	--MTV_ID	MT_ID	Name
	--147100	147		POMS Data
	--147101	147		POMS Archive Data
	--147102	147		POMS & Archive Data
	--147103	147		Pinnacle Data
	--147104	147		Pinnacle Archive Data
	--147105	147		Pinnacle & Archive Data

	if @GetRecordType_MTV_ID in (147100) and @OrderGUID != ''
	begin
		select @ORDER_ID = o.[ORDER_ID] from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.[ORDER_CODE_GUID] = @OrderGUID
		set @ORDER_ID = isnull(@ORDER_ID,0)
	end
	else if @GetRecordType_MTV_ID in (147101) and @OrderGUID != ''
	begin
		select @ORDER_ID = o.[ORDER_ID] from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.[ORDER_CODE_GUID] = @OrderGUID
		set @ORDER_ID = isnull(@ORDER_ID,0)
	end
	else if @GetRecordType_MTV_ID in (147102) and @OrderGUID != ''
	begin
		select @ORDER_ID = o.[ORDER_ID] from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.[ORDER_CODE_GUID] = @OrderGUID
		set @ORDER_ID = isnull(@ORDER_ID,0)
		if (@ORDER_ID = 0)
		begin
			select @ORDER_ID = o.[ORDER_ID] from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.[ORDER_CODE_GUID] = @OrderGUID
			set @ORDER_ID = isnull(@ORDER_ID,0)
		end
	end
	else if @GetRecordType_MTV_ID in (147103,147104,147105) and @OrderGUID != ''
	begin
		select @ORDER_ID = od.OrderId from [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) where od.[GUID_] = @OrderGUID
		set @ORDER_ID = isnull(@ORDER_ID,0)
	end

	return @ORDER_ID 

end
GO
