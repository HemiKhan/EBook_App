USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Seller_Setup_DropDown_Lists]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[P_Get_Seller_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	select [value] = SELLER_KEY, [text]= Company + ' - ' + SELLER_CODE from [POMS_DB].[dbo].[T_Seller_List] with (nolock) where IsActive = 1 order by Company

	select [value] = D_ID, [text]= DepartmentName from [POMS_DB].[dbo].[T_Department] with (nolock) where IsActive = 1 and D_ID <> 1 order by DepartmentName
	
	select [value] = SUB_SELLER_KEY, [text]= Company + ' - ' + SUB_SELLER_CODE from [POMS_DB].[dbo].[T_SubSeller_List] with (nolock) where IsActive = 1 order by Company
	
	select [value] = SELLER_PARTNER_KEY, [text] = Company + ' - ' + SELLER_PARTNER_CODE from [POMS_DB].[dbo].[T_Seller_Partner_List] with (nolock) where IsActive = 1 order by Company

	select [value] = TARIFF_NO, [text]= [Name] + ' - ' + TARIFF_NO from [POMS_DB].[dbo].[T_Tariff_List] with (nolock) where IsActive = 1 order by [Name]

	select [value] = BillTo_CUSTOMER_KEY , [text] = [Name] + '  -  ' + No_ FROM [POMS_DB].[dbo].[T_Seller_BillTo_Mapping] ssm WITH (NOLOCK) LEFT JOIN [MetroPolitanNavProduction].dbo.[Metropolitan$Customer] tb2 with (NOLOCK) ON TB2.[Customer GUID] = ssm.BillTo_CUSTOMER_KEY where [Is Active] = 1 order by Name

END
GO
