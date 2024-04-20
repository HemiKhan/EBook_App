USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleScanType_From_NewScanType]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[F_Get_PinnacleScanType_From_NewScanType]
(
	@NewScanType int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Ret int = @NewScanType

	set @Ret = case @NewScanType 
		when 113100 then 10000 
		when 113101 then 20000 
		when 113102 then 30000 
		when 113103 then 40000 
		when 113104 then 50000 
		when 113105 then 60000 
		when 113106 then 70000 
		when 113107 then 80000 
		when 113108 then 90000 
		when 113109 then 100000 
		else @NewScanType end

	return @Ret

end

GO
