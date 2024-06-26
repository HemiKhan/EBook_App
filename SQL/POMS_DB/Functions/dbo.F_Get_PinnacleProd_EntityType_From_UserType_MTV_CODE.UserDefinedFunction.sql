USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_EntityType_From_UserType_MTV_CODE]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[F_Get_PinnacleProd_EntityType_From_UserType_MTV_CODE]
(
	@UserType_MTV_CODE nvarchar(20)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Ret int = 0

	set @Ret = case @UserType_MTV_CODE 
		when 'CLIENT-USER' then 1 
		when 'METRO-USER' then 2
		when 'COD-USER' then 3
		when 'GUEST-USER' then 4
		else 0 end

	return @Ret

end

GO
