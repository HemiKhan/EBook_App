USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_TariffName_From_TariffNo]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_TariffName_From_TariffNo]  
(
	@TARIFF_NO nvarchar(36)
)
RETURNS nvarchar(250)
AS
BEGIN
	
	Declare @Ret nvarchar(250) = ''
	
	if isnull(@TARIFF_NO,'') != ''
	begin
		select @Ret = TL.[Name] from [POMS_DB].[dbo].[T_Tariff_List] TL with (nolock) where TL.TARIFF_NO = @TARIFF_NO
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
