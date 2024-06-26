USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Seller_All_MappingList]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Seller_All_MappingList] ('0A8B8263-C9DE-4AFD-BCC6-8FAFD12C9E08','ABDULLAH.ARSHAD')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Seller_All_MappingList]
(	
	@SellerKey nvarchar(36)
	,@Username nvarchar(150)
)
RETURNS @SellerMappingTable TABLE 
(SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250)
,SubSellerKey nvarchar(36), SubSellerCode nvarchar(20), SubSellerName nvarchar(250), IsDefaultSubSeller bit
,SellToPartnerKey nvarchar(36), SellToPartnerCode nvarchar(20), SellToPartnerName nvarchar(250), IsDefaultSellToPartner bit
,SellToTariffID int, SellToTariffNo nvarchar(36), SellToTariffName nvarchar(250), IsDefaultSellToTariff bit
,BillToCustomerKey nvarchar(36), BillToCustomerNo nvarchar(20), BillToCustomerName nvarchar(250), IsDefaultBillTo bit
,PaymentTermsCode nvarchar(20), PaymentMethodCode nvarchar(20), DepartmentCode nvarchar(20))
AS
begin

	Declare @ClientSellerCode nvarchar(20) = ''

	if @SellerKey is not null and @Username is null
	begin
		insert into @SellerMappingTable (SellerKey , SellerCode , SellerName , SubSellerKey , SubSellerCode , SubSellerName , IsDefaultSubSeller , 
		SellToPartnerKey , SellToPartnerCode , SellToPartnerName , IsDefaultSellToPartner 
		, SellToTariffID , SellToTariffNo , SellToTariffName , IsDefaultSellToTariff 
		, BillToCustomerKey , BillToCustomerNo , BillToCustomerName , IsDefaultBillTo 
		, PaymentTermsCode , PaymentMethodCode , DepartmentCode)
		select sl.SELLER_KEY, sl.SELLER_CODE, sl.Company, sul.SUB_SELLER_KEY, sul.SUB_SELLER_CODE, sul.Company
		, IsDefaultSubSeller = (case when sul.SUB_SELLER_KEY is null then null when cdvs1.[REFNO1] is null then 0 when cdvs1.[REFNO1] = sul.SUB_SELLER_KEY then 1 else 0 end)
		, spl.SELLER_PARTNER_KEY, spl.SELLER_PARTNER_CODE, spl.Company
		, IsDefaultSellToPartner = (case when spl.SELLER_PARTNER_KEY is null then null when cdvs2.[REFNO1] is null then 0 when cdvs2.[REFNO1] = spl.SELLER_PARTNER_KEY then 1 else 0 end)
		, tl.TARIFF_ID , tl.TARIFF_NO , tl.[Name] 
		, IsDefaultSellToTariff = (case when tl.TARIFF_NO is null then null when cdvs3.[REFNO1] is null then 0 when cdvs3.[REFNO1] = tl.TARIFF_NO then 1 else 0 end)
		, BillToCustomerKey = cast(c.[Customer GUID] as nvarchar(36)) collate SQL_Latin1_General_CP1_CI_AS, c.No_, C.[Name]
		, IsDefaultBillTo = (case when c.[Customer GUID] is null then null when cdvs4.[REFNO1] is null then 0 when cdvs4.[REFNO1] = cast(c.[Customer GUID] as nvarchar(36)) collate SQL_Latin1_General_CP1_CI_AS then 1 else 0 end)
		, [Payment Terms Code], [Payment Method Code], [Department Code]
		from [POMS_DB].[dbo].[V_Seller_Assigned_To_User_Full_List] satufl with (nolock)
		inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on satufl.SELLER_CODE = sl.SELLER_CODE and sl.IsActive = 1
		left join [POMS_DB].[dbo].[T_SubSeller_List] sul with (nolock) on satufl.SUB_SELLER_CODE = sul.SUB_SELLER_CODE and sul.IsActive = 1
		left join [POMS_DB].[dbo].[T_Seller_Partner_List] spl with (nolock) on satufl.SELLER_PARTNER_CODE = spl.SELLER_PARTNER_CODE and sul.IsActive = 1
		left join [POMS_DB].[dbo].[T_Tariff_List] tl with (nolock) on satufl.TARIFF_NO = tl.TARIFF_NO and tl.IsActive = 1
		left join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on satufl.BillTo_CUSTOMER_NO = c.[No_] collate SQL_Latin1_General_CP1_CI_AS and c.Blocked in (0,2) and c.[Is Active] = 1
		left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs1 with (nolock) on sl.SELLER_CODE = cdvs1.SELLER_CODE and cdvs1.IsActive = 1 and cdvs1.CONFIG_TYPE in ('SUB_SELLER')
		left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs2 with (nolock) on sl.SELLER_CODE = cdvs2.SELLER_CODE and cdvs2.IsActive = 1 and cdvs2.CONFIG_TYPE in ('SELLER_PARTNER')
		left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs3 with (nolock) on sl.SELLER_CODE = cdvs3.SELLER_CODE and cdvs3.IsActive = 1 and cdvs3.CONFIG_TYPE in ('SELLER_TARIFF')
		left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs4 with (nolock) on sl.SELLER_CODE = cdvs4.SELLER_CODE and cdvs4.IsActive = 1 and cdvs4.CONFIG_TYPE in ('SELLER_BILLTO')
		where sl.[IsActive] = 1 and sl.SELLER_KEY = @SellerKey and satufl.UserName is null
	end
	else
	begin
		Declare @UserType_MTV_CODE nvarchar(20) = ''
		if (@Username is not null)
		begin
			set @Username = upper(@Username)
			select @UserType_MTV_CODE = UserType_MTV_CODE
			from [POMS_DB].[dbo].[T_Users] with (nolock) where USERNAME = @Username
			set @UserType_MTV_CODE = isnull(@UserType_MTV_CODE,'')
		end
		if @UserType_MTV_CODE = ''
		begin
			insert into @SellerMappingTable (SellerKey , SellerCode , SellerName , SubSellerKey , SubSellerCode , SubSellerName , IsDefaultSubSeller , 
			SellToPartnerKey , SellToPartnerCode , SellToPartnerName , IsDefaultSellToPartner 
			, SellToTariffID , SellToTariffNo , SellToTariffName , IsDefaultSellToTariff 
			, BillToCustomerKey , BillToCustomerNo , BillToCustomerName , IsDefaultBillTo 
			, PaymentTermsCode , PaymentMethodCode , DepartmentCode)
			select sl.SELLER_KEY, sl.SELLER_CODE, sl.Company, sul.SUB_SELLER_KEY, sul.SUB_SELLER_CODE, sul.Company
			, IsDefaultSubSeller = (case when sul.SUB_SELLER_KEY is null then null when cdvs1.[REFNO1] is null then 0 when cdvs1.[REFNO1] = sul.SUB_SELLER_KEY then 1 else 0 end)
			, spl.SELLER_PARTNER_KEY, spl.SELLER_PARTNER_CODE, spl.Company
			, IsDefaultSellToPartner = (case when spl.SELLER_PARTNER_KEY is null then null when cdvs2.[REFNO1] is null then 0 when cdvs2.[REFNO1] = spl.SELLER_PARTNER_KEY then 1 else 0 end)
			, tl.TARIFF_ID , tl.TARIFF_NO , tl.[Name] 
			, IsDefaultSellToTariff = (case when tl.TARIFF_NO is null then null when cdvs3.[REFNO1] is null then 0 when cdvs3.[REFNO1] = tl.TARIFF_NO then 1 else 0 end)
			, BillToCustomerKey = cast(c.[Customer GUID] as nvarchar(36)) collate SQL_Latin1_General_CP1_CI_AS, c.No_, C.[Name]
			, IsDefaultBillTo = (case when c.[Customer GUID] is null then null when cdvs4.[REFNO1] is null then 0 when cdvs4.[REFNO1] = cast(c.[Customer GUID] as nvarchar(36)) collate SQL_Latin1_General_CP1_CI_AS then 1 else 0 end)
			, [Payment Terms Code], [Payment Method Code], [Department Code]
			from [POMS_DB].[dbo].[V_Seller_Assigned_To_User_Full_List] satufl with (nolock)
			inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on satufl.SELLER_CODE = sl.SELLER_CODE and sl.IsActive = 1
			left join [POMS_DB].[dbo].[T_SubSeller_List] sul with (nolock) on satufl.SUB_SELLER_CODE = sul.SUB_SELLER_CODE and sul.IsActive = 1
			left join [POMS_DB].[dbo].[T_Seller_Partner_List] spl with (nolock) on satufl.SELLER_PARTNER_CODE = spl.SELLER_PARTNER_CODE and sul.IsActive = 1
			left join [POMS_DB].[dbo].[T_Tariff_List] tl with (nolock) on satufl.TARIFF_NO = tl.TARIFF_NO and tl.IsActive = 1
			left join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on satufl.BillTo_CUSTOMER_NO = c.[No_] collate SQL_Latin1_General_CP1_CI_AS and c.Blocked in (0,2) and c.[Is Active] = 1
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs1 with (nolock) on sl.SELLER_CODE = cdvs1.SELLER_CODE and cdvs1.IsActive = 1 and cdvs1.CONFIG_TYPE in ('SUB_SELLER')
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs2 with (nolock) on sl.SELLER_CODE = cdvs2.SELLER_CODE and cdvs2.IsActive = 1 and cdvs2.CONFIG_TYPE in ('SELLER_PARTNER')
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs3 with (nolock) on sl.SELLER_CODE = cdvs3.SELLER_CODE and cdvs3.IsActive = 1 and cdvs3.CONFIG_TYPE in ('SELLER_TARIFF')
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs4 with (nolock) on sl.SELLER_CODE = cdvs4.SELLER_CODE and cdvs4.IsActive = 1 and cdvs4.CONFIG_TYPE in ('SELLER_BILLTO')
			where 1 = 0
		end
		else if @UserType_MTV_CODE = 'CLIENT-USER'
		begin
			insert into @SellerMappingTable (SellerKey , SellerCode , SellerName , SubSellerKey , SubSellerCode , SubSellerName , IsDefaultSubSeller , 
			SellToPartnerKey , SellToPartnerCode , SellToPartnerName , IsDefaultSellToPartner 
			, SellToTariffID , SellToTariffNo , SellToTariffName , IsDefaultSellToTariff 
			, BillToCustomerKey , BillToCustomerNo , BillToCustomerName , IsDefaultBillTo 
			, PaymentTermsCode , PaymentMethodCode , DepartmentCode)
			select sl.SELLER_KEY, sl.SELLER_CODE, sl.Company, sul.SUB_SELLER_KEY, sul.SUB_SELLER_CODE, sul.Company
			, IsDefaultSubSeller = (case when sul.SUB_SELLER_KEY is null then null when cdvs1.[REFNO1] is null then 0 when cdvs1.[REFNO1] = sul.SUB_SELLER_KEY then 1 else 0 end)
			, spl.SELLER_PARTNER_KEY, spl.SELLER_PARTNER_CODE, spl.Company
			, IsDefaultSellToPartner = (case when spl.SELLER_PARTNER_KEY is null then null when cdvs2.[REFNO1] is null then 0 when cdvs2.[REFNO1] = spl.SELLER_PARTNER_KEY then 1 else 0 end)
			, tl.TARIFF_ID , tl.TARIFF_NO , tl.[Name] 
			, IsDefaultSellToTariff = (case when tl.TARIFF_NO is null then null when cdvs3.[REFNO1] is null then 0 when cdvs3.[REFNO1] = tl.TARIFF_NO then 1 else 0 end)
			, BillToCustomerKey = cast(c.[Customer GUID] as nvarchar(36)) collate SQL_Latin1_General_CP1_CI_AS, c.No_, C.[Name]
			, IsDefaultBillTo = (case when c.[Customer GUID] is null then null when cdvs4.[REFNO1] is null then 0 when cdvs4.[REFNO1] = cast(c.[Customer GUID] as nvarchar(36)) collate SQL_Latin1_General_CP1_CI_AS then 1 else 0 end)
			, [Payment Terms Code], [Payment Method Code], [Department Code]
			from [POMS_DB].[dbo].[V_Seller_Assigned_To_User_Full_List] satufl with (nolock)
			inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on satufl.SELLER_CODE = sl.SELLER_CODE and sl.IsActive = 1
			left join [POMS_DB].[dbo].[T_SubSeller_List] sul with (nolock) on satufl.SUB_SELLER_CODE = sul.SUB_SELLER_CODE and sul.IsActive = 1
			left join [POMS_DB].[dbo].[T_Seller_Partner_List] spl with (nolock) on satufl.SELLER_PARTNER_CODE = spl.SELLER_PARTNER_CODE and sul.IsActive = 1
			left join [POMS_DB].[dbo].[T_Tariff_List] tl with (nolock) on satufl.TARIFF_NO = tl.TARIFF_NO and tl.IsActive = 1
			left join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on satufl.BillTo_CUSTOMER_NO = c.[No_] collate SQL_Latin1_General_CP1_CI_AS and c.Blocked in (0,2) and c.[Is Active] = 1
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs1 with (nolock) on sl.SELLER_CODE = cdvs1.SELLER_CODE and cdvs1.IsActive = 1 and cdvs1.CONFIG_TYPE in ('SUB_SELLER')
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs2 with (nolock) on sl.SELLER_CODE = cdvs2.SELLER_CODE and cdvs2.IsActive = 1 and cdvs2.CONFIG_TYPE in ('SELLER_PARTNER')
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs3 with (nolock) on sl.SELLER_CODE = cdvs3.SELLER_CODE and cdvs3.IsActive = 1 and cdvs3.CONFIG_TYPE in ('SELLER_TARIFF')
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs4 with (nolock) on sl.SELLER_CODE = cdvs4.SELLER_CODE and cdvs4.IsActive = 1 and cdvs4.CONFIG_TYPE in ('SELLER_BILLTO')
			where satufl.UserName = @Username and (sl.SELLER_KEY = isnull(@SellerKey,'') or @SellerKey is null)
			
			--[POMS_DB].[dbo].[T_Seller_List] sl with (nolock) 
			--left join [POMS_DB].[dbo].[T_Seller_SubSeller_Mapping] ssm with (nolock) on sl.SELLER_KEY = ssm.SELLER_KEY
			--left join [POMS_DB].[dbo].[T_SubSeller_List] sul with (nolock) on ssm.SUB_SELLER_KEY = sul.SUB_SELLER_KEY
			--left join [POMS_DB].[dbo].[T_Seller_BillTo_Mapping] sbm with (nolock) on sl.SELLER_KEY = sbm.SELLER_KEY
			--left join [POMS_DB].[dbo].[T_Seller_Partner_Mapping] spm with (nolock) on sl.SELLER_KEY = spm.SELLER_KEY
			--left join [POMS_DB].[dbo].[T_Seller_Partner_List] spl with (nolock) on spm.SELLER_PARTNER_KEY = spl.SELLER_PARTNER_KEY
			--left join [POMS_DB].[dbo].[T_Seller_Tariff_Mapping] stm with (nolock) on sl.SELLER_KEY = stm.SELLER_KEY
			--left join [POMS_DB].[dbo].[T_Tariff_List] tl with (nolock) on stm.TARIFF_NO = tl.TARIFF_NO
			--left join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on sbm.BillTo_CUSTOMER_KEY = cast(c.[Customer GUID] as nvarchar(36)) collate SQL_Latin1_General_CP1_CI_AS and c.Blocked in (0,2) and c.[Is Active] = 1
			--left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs1 with (nolock) on sl.SELLER_CODE = cdvs1.SELLER_CODE and cdvs1.IsActive = 1 and cdvs1.CONFIG_TYPE in ('SUB_SELLER')
			--left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs2 with (nolock) on sl.SELLER_CODE = cdvs2.SELLER_CODE and cdvs2.IsActive = 1 and cdvs2.CONFIG_TYPE in ('SELLER_PARTNER')
			--left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs3 with (nolock) on sl.SELLER_CODE = cdvs3.SELLER_CODE and cdvs3.IsActive = 1 and cdvs3.CONFIG_TYPE in ('SELLER_TARIFF')
			--left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs4 with (nolock) on sl.SELLER_CODE = cdvs4.SELLER_CODE and cdvs4.IsActive = 1 and cdvs4.CONFIG_TYPE in ('SELLER_BILLTO')
			--where sl.IsActive in (1) and ((sl.SELLER_KEY = @SellerKey and sl.SELLER_CODE = @ClientSellerCode) or (sl.SELLER_CODE = @ClientSellerCode and @SellerKey is null))
		end
		else if @UserType_MTV_CODE = 'METRO-USER'
		begin
			insert into @SellerMappingTable (SellerKey , SellerCode , SellerName , SubSellerKey , SubSellerCode , SubSellerName , IsDefaultSubSeller , 
			SellToPartnerKey , SellToPartnerCode , SellToPartnerName , IsDefaultSellToPartner 
			, SellToTariffID , SellToTariffNo , SellToTariffName , IsDefaultSellToTariff 
			, BillToCustomerKey , BillToCustomerNo , BillToCustomerName , IsDefaultBillTo 
			, PaymentTermsCode , PaymentMethodCode , DepartmentCode)
			select sl.SELLER_KEY, sl.SELLER_CODE, sl.Company, sul.SUB_SELLER_KEY, sul.SUB_SELLER_CODE, sul.Company
			, IsDefaultSubSeller = (case when sul.SUB_SELLER_KEY is null then null when cdvs1.[REFNO1] is null then 0 when cdvs1.[REFNO1] = sul.SUB_SELLER_KEY then 1 else 0 end)
			, spl.SELLER_PARTNER_KEY, spl.SELLER_PARTNER_CODE, spl.Company
			, IsDefaultSellToPartner = (case when spl.SELLER_PARTNER_KEY is null then null when cdvs2.[REFNO1] is null then 0 when cdvs2.[REFNO1] = spl.SELLER_PARTNER_KEY then 1 else 0 end)
			, tl.TARIFF_ID , tl.TARIFF_NO , tl.[Name] 
			, IsDefaultSellToTariff = (case when tl.TARIFF_NO is null then null when cdvs3.[REFNO1] is null then 0 when cdvs3.[REFNO1] = tl.TARIFF_NO then 1 else 0 end)
			, BillToCustomerKey = cast(c.[Customer GUID] as nvarchar(36)) collate SQL_Latin1_General_CP1_CI_AS, c.No_, C.[Name]
			, IsDefaultBillTo = (case when c.[Customer GUID] is null then null when cdvs4.[REFNO1] is null then 0 when cdvs4.[REFNO1] = cast(c.[Customer GUID] as nvarchar(36)) collate SQL_Latin1_General_CP1_CI_AS then 1 else 0 end)
			, [Payment Terms Code], [Payment Method Code], [Department Code]
			from [POMS_DB].[dbo].[V_Seller_Assigned_To_User_Full_List] satufl with (nolock)
			inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on satufl.SELLER_CODE = sl.SELLER_CODE and sl.IsActive = 1
			left join [POMS_DB].[dbo].[T_SubSeller_List] sul with (nolock) on satufl.SUB_SELLER_CODE = sul.SUB_SELLER_CODE and sul.IsActive = 1
			left join [POMS_DB].[dbo].[T_Seller_Partner_List] spl with (nolock) on satufl.SELLER_PARTNER_CODE = spl.SELLER_PARTNER_CODE and sul.IsActive = 1
			left join [POMS_DB].[dbo].[T_Tariff_List] tl with (nolock) on satufl.TARIFF_NO = tl.TARIFF_NO and tl.IsActive = 1
			left join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on satufl.BillTo_CUSTOMER_NO = c.[No_] collate SQL_Latin1_General_CP1_CI_AS and c.Blocked in (0,2) and c.[Is Active] = 1
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs1 with (nolock) on sl.SELLER_CODE = cdvs1.SELLER_CODE and cdvs1.IsActive = 1 and cdvs1.CONFIG_TYPE in ('SUB_SELLER')
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs2 with (nolock) on sl.SELLER_CODE = cdvs2.SELLER_CODE and cdvs2.IsActive = 1 and cdvs2.CONFIG_TYPE in ('SELLER_PARTNER')
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs3 with (nolock) on sl.SELLER_CODE = cdvs3.SELLER_CODE and cdvs3.IsActive = 1 and cdvs3.CONFIG_TYPE in ('SELLER_TARIFF')
			left join [POMS_DB].[dbo].[T_Client_Default_Value_Setup] cdvs4 with (nolock) on sl.SELLER_CODE = cdvs4.SELLER_CODE and cdvs4.IsActive = 1 and cdvs4.CONFIG_TYPE in ('SELLER_BILLTO')
			where satufl.UserName is null and (sl.SELLER_KEY = isnull(@SellerKey,'') or @SellerKey is null)
			--where sl.IsActive in (1) and (sl.SELLER_KEY = @SellerKey or @SellerKey is null)
		end
	end

	return
	

end
GO
