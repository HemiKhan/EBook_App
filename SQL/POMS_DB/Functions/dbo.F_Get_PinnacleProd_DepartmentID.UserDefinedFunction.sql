USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_DepartmentID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_Get_PinnacleProd_DepartmentID]
(
	@DepartmentID int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Ret int = @DepartmentID

	set @Ret = case @DepartmentID 
		when 2 then 10000 
		when 3 then 20000 
		when 4 then 30000 
		when 5 then 40000 
		else @DepartmentID end

	return @Ret

end

GO
