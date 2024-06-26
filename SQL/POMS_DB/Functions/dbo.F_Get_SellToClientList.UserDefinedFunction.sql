USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_SellToClientList]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_SellToClientList] (null,'ABDULLAH.ARSHAD')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_SellToClientList]
(	
	@SellerKey nvarchar(36)
	,@Username nvarchar(150)
)
RETURNS @SellerTable TABLE 
(SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250), IsViewOrder bit ,IsCreateOrder bit ,IsGetQuote bit ,IsFinancial bit ,IsAdmin bit ,IsSellerMapped bit)
AS
begin

	if @SellerKey is not null and @Username is null
	begin
		insert into @SellerTable
		select SELLER_KEY ,SELLER_CODE ,Company ,1 ,1 ,1 ,1 ,1 ,0
		from [POMS_DB].[dbo].[T_Seller_List] with (nolock) where SELLER_KEY = @SellerKey
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
			insert into @SellerTable
			select SELLER_KEY ,SELLER_CODE ,SELLER_NAME ,IsViewOrder ,IsCreateOrder ,IsGetQuote ,IsFinancial ,IsAdmin ,IsSellerMapped
			from [POMS_DB].[dbo].[V_Seller_Assigned_To_User_List] satul with (nolock) 
			where 1 = 0
			--where UserName is null
			--select [UserName], [SELLER_CODE], [SELLER_NAME] ,[BillTo_CUSTOMER_NO] ,[SUB_SELLER_CODE] ,[SELLER_PARTNER_CODE] ,[TARIFF_NO] ,[IsViewOrder] 
			--,[IsCreateOrder], [IsGetQuote] ,[IsFinancial] ,[IsAdmin] ,[IsSellerMapped] ,[IsBlankSubSellerAllowed] ,[IsAllSubSellerAllowed] ,[IsBlankPartnerAllowed]
			--,[IsAllPartnerAllowed] ,[IsBlankTariffAllowed] ,[IsAllTariffAllowed]
			--from [POMS_DB].[dbo].[V_Seller_Assigned_To_User_Full_List] with (nolock) where 1 = 0
		end
		else if @UserType_MTV_CODE = 'CLIENT-USER'
		begin
			insert into @SellerTable 
			select SELLER_KEY ,SELLER_CODE ,SELLER_NAME ,IsViewOrder ,IsCreateOrder ,IsGetQuote ,IsFinancial ,IsAdmin ,IsSellerMapped
			from [POMS_DB].[dbo].[V_Seller_Assigned_To_User_List] satul with (nolock) where UserName = @Username
			and (satul.SELLER_KEY = isnull(@SellerKey,'') or @SellerKey is null)
		end
		else if @UserType_MTV_CODE = 'METRO-USER'
		begin
			insert into @SellerTable 
			select SELLER_KEY ,SELLER_CODE ,SELLER_NAME ,IsViewOrder ,IsCreateOrder ,IsGetQuote ,IsFinancial ,IsAdmin ,IsSellerMapped
			from [POMS_DB].[dbo].[V_Seller_Assigned_To_User_List] satul with (nolock) where satul.UserName is null
			and (satul.SELLER_KEY = isnull(@SellerKey,'') or @SellerKey is null)
		end
	end

	return
	

end
GO
