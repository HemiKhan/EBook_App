USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_TimeZoneName_From_TimeZoneID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_TimeZoneName_From_TimeZoneID]  
(
	@TimeZoneID int
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@TimeZoneID,0) != 0
	begin
		select @Ret = [TimeZoneDisplay] from [POMS_DB].[dbo].[T_Time_Zone_List] with (nolock) where TIMEZONE_ID = @TimeZoneID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
