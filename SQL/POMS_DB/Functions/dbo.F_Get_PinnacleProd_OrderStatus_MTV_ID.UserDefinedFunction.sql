USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderStatus_MTV_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderStatus_MTV_ID]
(
	@OrderStatus_MTV_ID int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Ret int = @OrderStatus_MTV_ID

	set @Ret = case @OrderStatus_MTV_ID 
		when 100100 then 10000 
		when 100101 then 20000 
		when 100103 then 30000 
		when 100104 then 40000 
		when 100102 then 50000 
		else @OrderStatus_MTV_ID end

	return @Ret

end

GO
