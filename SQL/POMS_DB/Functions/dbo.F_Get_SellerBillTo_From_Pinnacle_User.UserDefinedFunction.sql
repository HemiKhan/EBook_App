USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_SellerBillTo_From_Pinnacle_User]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_SellerBillTo_From_Pinnacle_User] ('ABDULLAH.ARSHAD')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_SellerBillTo_From_Pinnacle_User]
(	
	@Username nvarchar(150)
)
RETURNS @ReturnTable TABLE 
(SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250)
,BillToCustomerKey nvarchar(36), BillToCustomerNo nvarchar(20), BillToCustomerName nvarchar(250)
,PaymentTermsCode nvarchar(20), PaymentMethodCode nvarchar(20), DepartmentCode nvarchar(20))
AS
begin

	set @Username = upper(@Username)

	insert into @ReturnTable (SellerKey , SellerCode , SellerName , BillToCustomerKey , BillToCustomerNo , BillToCustomerName , PaymentTermsCode , PaymentMethodCode , DepartmentCode)
	select sl.SELLER_KEY, sl.SELLER_CODE, sl.Company, BillToCustomerKey = cast(c.[Customer GUID] as nvarchar(36)) , c.No_, C.[Name]
	, [Payment Terms Code], [Payment Method Code], [Department Code]
	from [PinnacleProd].[dbo].[Metropolitan$Web User Login] wul with (nolock)
	inner join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on wul.[Customer No_] = c.[No_] 
	inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on sl.SELLER_CODE = replace(c.[No_],'C','S') collate Latin1_General_100_CS_AS and sl.IsActive = 1
	where upper(wul.Username) = @Username
	
	return

end
GO
