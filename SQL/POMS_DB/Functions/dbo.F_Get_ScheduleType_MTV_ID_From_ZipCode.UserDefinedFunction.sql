USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_ScheduleType_MTV_ID_From_ZipCode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_ScheduleType_MTV_ID_From_ZipCode]  
(
	@ZipCode nvarchar(10)
)
RETURNS int
AS
BEGIN
	
	Declare @Ret int = null
	set @ZipCode = isnull(@ZipCode,'')

	if (@ZipCode <> '')
	begin
		select @Ret = null
	end

	return @Ret
END
GO
