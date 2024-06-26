USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PriceKey_JsonInfo]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PriceKey_JsonInfo] ('{SellerKey: "42A988E7-12FA-48B6-BF38-EF900E6ED9AB", SubSellerKey: "", SellerPartnerKey: "", TariffNo: "", BillToCustomerKey: ""}')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PriceKey_JsonInfo]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(SellerKey nvarchar(36)
,SubSellerKey nvarchar(36)
,SellerPartnerKey nvarchar(36)
,TariffNo nvarchar(36)
,BillToCustomerKey nvarchar(36)
)
AS
begin
	
	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end
	
	insert into @ReturnTable
	select *
	from OpenJson(@Json)
	WITH (
		SellerKey nvarchar(36) '$.SellerKey'
		,SubSellerKey nvarchar(36) '$.SubSellerKey'
		,SellerPartnerKey nvarchar(36) '$.SellerPartnerKey'
		,TariffNo nvarchar(36) '$.TariffNo'
		,BillToCustomerKey nvarchar(36) '$.BillToCustomerKey'
	) 

	return

end
GO
