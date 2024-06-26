USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_EventName_From_EventID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[F_Get_EventName_From_EventID]  
(
	@EVENT_ID int
)
RETURNS nvarchar(250)
AS
BEGIN
	
	Declare @Ret nvarchar(250) = ''

	if isnull(@EVENT_ID,0) != 0
	begin
		select @Ret = [Name] from [POMS_DB].[dbo].[T_Events_List] with (nolock) where EVENT_ID = @EVENT_ID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
