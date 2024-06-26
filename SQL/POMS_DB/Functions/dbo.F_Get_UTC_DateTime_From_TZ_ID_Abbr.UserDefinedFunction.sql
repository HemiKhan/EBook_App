USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_UTC_DateTime_From_TZ_ID_Abbr]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[F_Get_UTC_DateTime_From_TZ_ID_Abbr]
(
	@Date datetime
	,@TZ_ID int
	,@Hub nvarchar(20)
	,@TimeZoneName nvarchar(50)
	,@TimeZoneAbbr nvarchar(10)
)
RETURNS nvarchar(50)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Ret datetime = null
	DECLARE @ReturnText nvarchar(50) = null

	if @Date is null or (@TZ_ID is null and @HUB is null)
	begin
		return @ReturnText
	end
	else if year(@Date) < 2000
	begin
		return @ReturnText
	end

	if (@TZ_ID is null)
	begin
		select @TZ_ID = hl.TIMEZONE_ID from [POMS_DB].[dbo].[T_Hub_List] hl with (nolock) where hl.HUB_CODE = @HUB
	end
	
	--if (@TimeZoneName is null or @TimeZoneAbbr is null) and @TZ_ID is not null
	if @TimeZoneName is null and @TZ_ID is not null
	begin
		select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = tzl.TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TZ_ID
	end
	
	SELECT @Ret=cast(@Date AT TIME ZONE @TimeZoneName AT TIME ZONE 'UTC' as datetime)

	if @Ret is not null
	begin
		set @ReturnText = format(@Ret, 'yyyy-MM-dd hh:mm:ss tt') + ' ' + 'UTC'
	end

	return @ReturnText

end

GO
