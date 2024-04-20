USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleAreaType_From_NewAreaType]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[F_Get_PinnacleAreaType_From_NewAreaType]
(
	@NewAreaType int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Ret int = @NewAreaType

	set @Ret = case @NewAreaType 
		when 104100 then 10000 
		when 104101 then 15000 
		when 104102 then 20000 
		when 104103 then 25000
		when 104104 then 30000 
		when 104105 then 35000
		when 104106 then 30000 
		else @NewAreaType end

	return @Ret

end

GO
