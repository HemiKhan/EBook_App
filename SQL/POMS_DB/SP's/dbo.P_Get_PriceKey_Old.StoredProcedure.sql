USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_PriceKey_Old]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec [dbo].[P_Get_PriceKey] '{"SellerKey": "42A988E7-12FA-48B6-BF38-EF900E6ED9AB", "SubSellerKey": "", "SellerPartnerKey": "", "TariffNo": "", "BillToCustomerKey": ""}'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_PriceKey_Old]
	-- Add the parameters for the stored procedure here
	@Json nvarchar(max)

AS
BEGIN
	
	Declare @ReturnCode bit = 0
	Declare @ReturnText nvarchar(1000) = ''

	Drop table if exists #PriceKeyList
	select SellerKey,SubSellerKey,SellerPartnerKey,TariffNo,BillToCustomerKey into #PriceKeyList from [POMS_DB].[dbo].[F_Get_PriceKey_JsonInfo] (@Json)

	Declare @SellerKey nvarchar(36) 
	Declare @SellerCode nvarchar(20) 
	Declare @SubSellerKey nvarchar(36)
	Declare @SellerPartnerKey nvarchar(36)
	Declare @TariffNo nvarchar(36)
	Declare @BillToCustomerKey nvarchar(36)
	Declare @RecordCount int = 0
	Declare @PriceKey nvarchar(36) = ''
	Declare @Is_Auto_Get_Pinnacle bit = 0
	Declare @Is_Active_In_Pinnacle bit = 0
	
	select @SellerKey = SellerKey 
	,@SubSellerKey = SubSellerKey 
	,@SellerPartnerKey = SellerPartnerKey
	,@TariffNo = TariffNo 
	,@BillToCustomerKey = BillToCustomerKey
	from #PriceKeyList

	drop table if exists #SellerAllMappingList
	select SellerKey,SellerCode,SellerName,SubSellerKey,SubSellerCode,SubSellerName,IsDefaultSubSeller,SellToPartnerKey,SellToPartnerCode,SellToPartnerName,IsDefaultSellToPartner
	SellToTariffID,SellToTariffNo,SellToTariffName,IsDefaultSellToTariff,BillToCustomerKey,BillToCustomerNo,BillToCustomerName,IsDefaultBillTo,PaymentTermsCode,PaymentMethodCode
	,DepartmentCode into #SellerAllMappingList from [POMS_DB].[dbo].[F_Get_Seller_All_MappingList] (@SellerKey,null)

	select @RecordCount = count(SellerKey) from #SellerAllMappingList
	print @RecordCount 

	if @RecordCount = 0
	begin
		set @ReturnText = 'Invalid Seller Key'
		select @ReturnCode as ReturnCode, @ReturnText as ReturnText, @PriceKey as PriceKey, @Is_Auto_Get_Pinnacle as Is_Auto_Get_Pinnacle, @Is_Active_In_Pinnacle as Is_Active_In_Pinnacle
		return;
	end

	select top 1 @SellerCode = SellerCode from #SellerAllMappingList

	select @PriceKey = [PRICE_KEY]
	FROM [POMS_DB].[dbo].[T_Seller_All_Mapping_Price_Key] with (nolock)
	where [IsActive] = 1 and [SELLER_KEY] = @SellerKey and isnull([SUB_SELLER_KEY],'') = @SubSellerKey and isnull([SELLER_PARTNER_KEY],'') = @SellerPartnerKey 
	and isnull([TARIFF_NO],'') = @TariffNo and isnull([BillTo_CUSTOMER_NO],'') = @BillToCustomerKey

	set @PriceKey = isnull(@PriceKey,'')

	if @PriceKey = '' and @RecordCount > 1
	begin
		set @ReturnText = 'Price Key is Not Setup'
		select @ReturnCode as ReturnCode, @ReturnText as ReturnText, @PriceKey as PriceKey, @Is_Auto_Get_Pinnacle as Is_Auto_Get_Pinnacle, @Is_Active_In_Pinnacle as Is_Active_In_Pinnacle
		return;
	end
	else
	begin
		select @Is_Auto_Get_Pinnacle = Is_Auto_Get_Pinnacle 
		,@Is_Active_In_Pinnacle = Is_Active_In_Pinnacle 
		from [Quotes].[dbo].[T_Price_Key] with (nolock)
		where [Is_Active] = 1 and [P_Key] = @PriceKey
	end

	if @PriceKey = '' and @RecordCount = 1
	begin
		select @PriceKey = [P_Key]
		,@Is_Auto_Get_Pinnacle = Is_Auto_Get_Pinnacle 
		,@Is_Active_In_Pinnacle = Is_Active_In_Pinnacle 
		from [Quotes].[dbo].[T_Price_Key] with (nolock)
		where [Is_Active] = 1 and [Client_ID] = replace(@SellerCode,'S','C')
		
		set @PriceKey = isnull(@PriceKey,'')
	end

	set @Is_Auto_Get_Pinnacle = isnull(@Is_Auto_Get_Pinnacle,0)
	set @Is_Active_In_Pinnacle = isnull(@Is_Active_In_Pinnacle,0)

	if @PriceKey = ''
	begin
		set @ReturnText = 'Price Key is Not Setup'
		select @ReturnCode as ReturnCode, @ReturnText as ReturnText, @PriceKey as PriceKey, @Is_Auto_Get_Pinnacle as Is_Auto_Get_Pinnacle, @Is_Active_In_Pinnacle as Is_Active_In_Pinnacle
		return;
	end

	set @ReturnCode = 1

	select @ReturnCode as ReturnCode, @ReturnText as ReturnText, @PriceKey as PriceKey, @Is_Auto_Get_Pinnacle as Is_Auto_Get_Pinnacle, @Is_Active_In_Pinnacle as Is_Active_In_Pinnacle

END
GO
