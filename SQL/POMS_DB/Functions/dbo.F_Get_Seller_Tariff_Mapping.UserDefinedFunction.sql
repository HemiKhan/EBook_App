USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Seller_Tariff_Mapping]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Seller_Tariff_Mapping] ('','8EB285F5-9C49-4F6A-AA7A-D7B1F67F38E6')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Seller_Tariff_Mapping]
(	
	@TariffNo nvarchar(36)
	,@SellerKey nvarchar(36)
)
RETURNS @ReturnTable TABLE 
(SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250)
,TariffID int, TariffNo nvarchar(36), TariffName nvarchar(250))
AS
begin

	insert into @ReturnTable (SellerKey , SellerCode , SellerName , TariffID , TariffNo , TariffName)
	SELECT stm.[SELLER_KEY], sl.SELLER_CODE, sl.Company, tl.[TARIFF_ID] , tl.TARIFF_NO , tl.[Name]
	FROM [POMS_DB].[dbo].[T_Seller_Tariff_Mapping] stm with (nolock) 
	inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on stm.[SELLER_KEY] = sl.[SELLER_KEY]
	inner join [POMS_DB].[dbo].[T_Tariff_List] tl with (nolock) on stm.[TARIFF_NO] = tl.[TARIFF_NO]
	where stm.[SELLER_KEY] = @SellerKey and (stm.[TARIFF_NO] = @TariffNo or @TariffNo is null)

	return
	

end
GO
