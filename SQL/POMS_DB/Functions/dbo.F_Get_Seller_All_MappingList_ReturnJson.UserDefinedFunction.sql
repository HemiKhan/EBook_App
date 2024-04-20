USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Seller_All_MappingList_ReturnJson]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select [POMS_DB].[dbo].[F_Get_Seller_All_MappingList_ReturnJson] ('F2817325-D86E-44FE-B163-67FF209B5017','ABDULLAH.ARSHAD')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Seller_All_MappingList_ReturnJson]
(	
	@SellerKey nvarchar(36)
	,@Username nvarchar(150) = null
)
RETURNS nvarchar(max) 
AS
begin

	Declare @Return_Json nvarchar(max) = ''
	Declare @SellerMappingTable TABLE 
	(SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250)
	,SubSellerKey nvarchar(36), SubSellerCode nvarchar(20), SubSellerName nvarchar(250), IsDefaultSubSeller bit null
	,SellToPartnerKey nvarchar(36), SellToPartnerCode nvarchar(20), SellToPartnerName nvarchar(250), IsDefaultSellToPartner bit null
	,SellToTariffID int, SellToTariffNo nvarchar(36), SellToTariffName nvarchar(250), IsDefaultSellToTariff bit null
	,BillToCustomerKey nvarchar(36), BillToCustomerNo nvarchar(20), BillToCustomerName nvarchar(250), IsDefaultBillTo bit null
	,PaymentTermsCode nvarchar(20), PaymentMethodCode nvarchar(20), DepartmentCode nvarchar(20))
	insert into @SellerMappingTable
	select SellerKey
		,SellerCode
		,SellerName
		,SubSellerKey
		,SubSellerCode
		,SubSellerName
		,IsDefaultSubSeller
		,SellToPartnerKey
		,SellToPartnerCode
		,SellToPartnerName
		,IsDefaultSellToPartner
		,SellToTariffID
		,SellToTariffNo
		,SellToTariffName
		,IsDefaultSellToTariff
		,BillToCustomerKey
		,BillToCustomerNo
		,BillToCustomerName
		,IsDefaultBillTo
		,PaymentTermsCode
		,PaymentMethodCode
		,DepartmentCode
	from [POMS_DB].[dbo].[F_Get_Seller_All_MappingList] (@SellerKey,@Username)

	select @Return_Json = (SELECT (
		SELECT distinct s.SellerKey AS 'SellerKey',
			   s.SellerCode AS 'SellerCode',
			   s.SellerName AS 'SellerName',
			   (
				   SELECT distinct ss.SubSellerKey AS 'SubSellerKey',
						  ss.SubSellerCode AS 'SubSellerCode',
						  ss.SubSellerName AS 'SubSellerName',
						  ss.IsDefaultSubSeller AS 'IsDefaultSubSeller'
				   FROM @SellerMappingTable ss
				   WHERE ss.SellerKey = s.SellerKey
				   FOR JSON PATH
			   ) AS 'SubSellerDetailInfo',
			   (
				   SELECT distinct sp.SellToPartnerKey AS 'SellToPartnerKey',
						  sp.SellToPartnerCode AS 'SellToPartnerCode',
						  sp.SellToPartnerName AS 'SellToPartnerName',
						  sp.IsDefaultSellToPartner AS 'IsDefaultSellToPartner'
				   FROM @SellerMappingTable sp
				   WHERE sp.SellerKey = s.SellerKey
				   FOR JSON PATH
			   ) AS 'PartnerDetailInfo',
			   (
				   SELECT distinct st.SellToTariffID AS 'SellToTariffID',
						  st.SellToTariffNo AS 'SellToTariffNo',
						  st.SellToTariffName AS 'SellToTariffName',
						  st.IsDefaultSellToTariff AS 'IsDefaultSellToTariff'
				   FROM @SellerMappingTable st
				   WHERE st.SellerKey = s.SellerKey
				   FOR JSON PATH
			   ) AS 'TariffDetailInfo',
			   (
				   SELECT distinct b.BillToCustomerKey AS 'BillToCustomerKey',
						  b.BillToCustomerNo AS 'BillToCustomerNo',
						  b.BillToCustomerName AS 'BillToCustomerName',
						  b.IsDefaultBillTo AS 'IsDefaultBillTo',
						  b.PaymentTermsCode AS 'PaymentTermsCode',
						  b.PaymentMethodCode AS 'PaymentMethodCode',
						  b.DepartmentCode AS 'DepartmentCode'
				   FROM @SellerMappingTable b
				   WHERE b.SellerKey = s.SellerKey
				   FOR JSON PATH
			   ) AS 'BillToDetailInfo'
		FROM @SellerMappingTable s
		FOR JSON PATH
	) AS json_result)

	if @Return_Json is null
		begin set @Return_Json = '' end
	else
		begin set @Return_Json = replace(replace(replace(replace(@Return_Json,'{},',''),'[{}]','null'),'[]','null'),'[]','null') end

	return @Return_Json

end
GO
