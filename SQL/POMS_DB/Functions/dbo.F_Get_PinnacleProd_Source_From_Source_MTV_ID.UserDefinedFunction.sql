USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_Source_From_Source_MTV_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[F_Get_PinnacleProd_Source_From_Source_MTV_ID]
(
	@Source_MTV_ID int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Ret int = @Source_MTV_ID

	set @Ret = case @Source_MTV_ID 
		when 101100 then 20000 
		when 101101 then 50000 
		when 101102 then 10000 
		when 101103 then 70000 
		when 101104 then 60000 
		when 101105 then 80000 
		when 101106 then 80000 
		when 101107 then 40000 
		else @Source_MTV_ID end

	return @Ret

end

GO
