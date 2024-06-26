USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleHubName_From_HubCode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleHubName_From_HubCode]  
(
	@Code nvarchar(20)
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''
	
	if isnull(@Code,'') != ''
	begin
		select @Ret = [Wharehouse Name] from [MetroPolitanNavProduction].[dbo].[Metropolitan$TR Warehouse Hub] TWH with (nolock) where TWH.[Code] = @Code
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
