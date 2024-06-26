USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Seller_SubSeller_Mapping]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Seller_SubSeller_Mapping] ('8EB285F5-9C49-4F6A-AA7A-D7B1F67F38E6',null)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Seller_SubSeller_Mapping]
(	
	@SellerKey nvarchar(36)
	,@SubSellerKey nvarchar(36) = null
)
RETURNS @ReturnTable TABLE 
(SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250)
,SubSellerKey nvarchar(36), SubSellerCode nvarchar(20), SubSellerName nvarchar(250))
AS
begin

	insert into @ReturnTable (SellerKey , SellerCode , SellerName , SubSellerKey , SubSellerCode , SubSellerName)
	SELECT ssm.[SELLER_KEY], sl.SELLER_CODE, sl.Company, sul.[SUB_SELLER_KEY] , sul.SUB_SELLER_CODE , sul.Company
	FROM [POMS_DB].[dbo].[T_Seller_SubSeller_Mapping] ssm with (nolock) 
	inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on ssm.[SELLER_KEY] = sl.[SELLER_KEY]
	inner join [POMS_DB].[dbo].[T_SubSeller_List] sul with (nolock) on ssm.[SUB_SELLER_KEY] = sul.[SUB_SELLER_KEY]
	where ssm.[SELLER_KEY] = @SellerKey and (ssm.[SUB_SELLER_KEY] = @SubSellerKey or @SubSellerKey is null)

	return
	

end
GO
