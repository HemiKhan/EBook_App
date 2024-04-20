USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Seller_Partner_Name_From_SellerPartnerCode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Seller_Partner_Name_From_SellerPartnerCode]  
(
	@SELLERPARTNERCODE nvarchar(20)
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@SELLERPARTNERCODE,'') != ''
	begin
		select @Ret = Company from [POMS_DB].[dbo].[T_Seller_Partner_List] spl with (nolock) where spl.SELLER_PARTNER_CODE = @SELLERPARTNERCODE
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
