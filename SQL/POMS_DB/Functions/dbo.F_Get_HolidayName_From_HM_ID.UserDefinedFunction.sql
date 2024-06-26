USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_HolidayName_From_HM_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_HolidayName_From_HM_ID]  
(
	@HM_ID int
)
RETURNS nvarchar(150)
AS
BEGIN
	
	Declare @Ret nvarchar(150) = ''

	if isnull(@HM_ID,0) != 0
	begin
		select @Ret = [Name] from [POMS_DB].[dbo].[T_Holiday_Master] hm with (nolock) where hm.HM_ID = @HM_ID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
