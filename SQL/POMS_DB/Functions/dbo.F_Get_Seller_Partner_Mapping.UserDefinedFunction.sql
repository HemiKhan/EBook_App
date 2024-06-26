USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Seller_Partner_Mapping]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Seller_Partner_Mapping] ('8EB285F5-9C49-4F6A-AA7A-D7B1F67F38E6',null)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Seller_Partner_Mapping]
(	
	@SellerKey nvarchar(36)
	,@SellerPartnerKey nvarchar(36) = null
)
RETURNS @ReturnTable TABLE 
(SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250)
,SellerPartnerKey nvarchar(36), SellerPartnerCode nvarchar(20), SellerPartnerName nvarchar(250))
AS
begin

	insert into @ReturnTable (SellerKey , SellerCode , SellerName , SellerPartnerKey , SellerPartnerCode , SellerPartnerName)
	SELECT spm.[SELLER_KEY], sl.SELLER_CODE, sl.Company, spl.[SELLER_PARTNER_KEY] , spl.SELLER_PARTNER_CODE , spl.Company
	FROM [POMS_DB].[dbo].[T_Seller_Partner_Mapping] spm with (nolock) 
	inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on spm.[SELLER_KEY] = sl.[SELLER_KEY]
	inner join [POMS_DB].[dbo].[T_Seller_Partner_List] spl with (nolock) on spm.[SELLER_PARTNER_KEY] = spl.[SELLER_PARTNER_KEY]
	where spm.[SELLER_KEY] = @SellerKey and (spm.[SELLER_PARTNER_KEY] = @SellerPartnerKey or @SellerPartnerKey is null)

	return
	

end
GO
