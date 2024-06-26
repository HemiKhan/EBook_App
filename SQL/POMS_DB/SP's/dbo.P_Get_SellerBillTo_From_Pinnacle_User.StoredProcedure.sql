USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_SellerBillTo_From_Pinnacle_User]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_SellerBillTo_From_Pinnacle_User]
	@Username nvarchar(150)
AS
BEGIN
	
	select SellerKey , SellerCode , SellerName , BillToCustomerKey , BillToCustomerNo , BillToCustomerName , PaymentTermsCode , PaymentMethodCode , DepartmentCode from [POMS_DB].[dbo].[F_Get_SellerBillTo_From_Pinnacle_User] (@Username)

END
GO
