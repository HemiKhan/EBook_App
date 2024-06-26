USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_EventName_From_EventCode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[F_Get_EventName_From_EventCode]  
(
	@EVENT_CODE nvarchar(20)
)
RETURNS nvarchar(250)
AS
BEGIN
	
	Declare @Ret nvarchar(250) = ''

	if isnull(@EVENT_CODE,'') != ''
	begin
		select @Ret = [Name] from [POMS_DB].[dbo].[T_Events_List] with (nolock) where EVENT_CODE = @EVENT_CODE
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
