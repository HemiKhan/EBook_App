USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Sub_Seller_Name_From_SubSellerCode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Sub_Seller_Name_From_SubSellerCode]  
(
	@SUBSELLERCODE nvarchar(20)
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@SUBSELLERCODE,'') != ''
	begin
		select @Ret = Company from [POMS_DB].[dbo].[T_SubSeller_List] ssl_ with (nolock) where ssl_.SUB_SELLER_CODE = @SUBSELLERCODE
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
