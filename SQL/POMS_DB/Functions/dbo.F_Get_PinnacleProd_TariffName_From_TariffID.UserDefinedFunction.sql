USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_TariffName_From_TariffID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_TariffName_From_TariffID]  
(
	@Tariff_ID nvarchar(36)
)
RETURNS nvarchar(150)
AS
BEGIN
	
	Declare @Ret nvarchar(150) = ''
	
	if isnull(@Tariff_ID,'') != ''
	begin
		select @Ret = TL.[Name] from [PinnacleProd].[dbo].[T_Tariff_List] TL with (nolock) where TL.Tariff_ID = @Tariff_ID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
