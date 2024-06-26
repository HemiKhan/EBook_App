USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_SubOrderType_By_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_SubOrderType_By_ID]  
(
	@OrderType_ID int
	,@SubOrderType_ID int
)
RETURNS nvarchar(100)
AS
BEGIN
	
	Declare @Ret nvarchar(100) = ''

	if isnull(@OrderType_ID,0) != 0 and isnull(@SubOrderType_ID,0) != 0
	begin
		select @Ret = sotv.[Name] from [PinnacleProd].[dbo].[T_Sub_Order_Type_Value] sotv with (nolock) where sotv.Order_Type_ID = @OrderType_ID and sotv.Sub_Order_Type_ID = @SubOrderType_ID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
