USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_TimeFrameName_12Hour_From_TFL_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[F_Get_TimeFrameName_12Hour_From_TFL_ID]  
(
	@TFL_ID int
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@TFL_ID,0) != 0
	begin
		select @Ret = (format(cast(FromTime as datetime),'hh:mm tt') + ' To ' + format(cast(ToTime as datetime),'hh:mm tt'))
		from [POMS_DB].[dbo].[T_Time_Frame_List] with (nolock) where TFL_ID = @TFL_ID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
