USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_DateTime_From_UTC]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[F_Get_DateTime_From_UTC]
(
	@Date datetime
	,@TZ_ID int
	,@Hub nvarchar(20)
	,@TimeZoneName nvarchar(50)
)
RETURNS datetime
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Ret datetime = null

	if @Date is null or (@TZ_ID is null and @HUB is null)
	begin
		return @Ret
	end
	else if year(@Date) < 2000
	begin
		return @Ret
	end

	if (@TZ_ID is null)
	begin
		select @TZ_ID = hl.TIMEZONE_ID from [POMS_DB].[dbo].[T_Hub_List] hl with (nolock) where hl.HUB_CODE = @HUB
	end
	
	if @TimeZoneName is null and @TZ_ID is not null
	begin
		select @TimeZoneName = tzl.TimeZoneName from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TZ_ID
	end

	SELECT @Ret=cast(@Date AT TIME ZONE 'UTC' AT TIME ZONE @TimeZoneName as datetime)

	return @Ret

end

GO
