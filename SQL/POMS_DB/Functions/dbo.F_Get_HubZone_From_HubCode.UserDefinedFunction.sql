USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_HubZone_From_HubCode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_HubZone_From_HubCode]  
(
	@Code nvarchar(20)
)
RETURNS nvarchar(20)
AS
BEGIN
	
	Declare @Ret nvarchar(20) = ''
	
	if isnull(@Code,'') != ''
	begin
		select @Ret = [HUB_ZONE] from [POMS_DB].[dbo].[T_Hub_List] HL with (nolock) where HL.[HUB_CODE] = @Code
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
