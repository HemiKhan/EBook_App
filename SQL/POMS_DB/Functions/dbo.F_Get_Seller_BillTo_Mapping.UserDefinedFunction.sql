USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Seller_BillTo_Mapping]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Seller_BillTo_Mapping] ('66E0D120-8856-4E0C-A26F-2F95A008B1F1',null)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Seller_BillTo_Mapping]
(	
	@SellerKey nvarchar(36)
	,@BillToCustomerKey nvarchar(36) = null
)
RETURNS @ReturnTable TABLE 
(SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250)
,BillToCustomerKey nvarchar(36), BillToCustomerNo nvarchar(20), BillToCustomerName nvarchar(250))
AS
begin

	insert into @ReturnTable (SellerKey , SellerCode , SellerName , BillToCustomerKey , BillToCustomerNo , BillToCustomerName)
	SELECT sbm.[SELLER_KEY], sl.SELLER_CODE, sl.Company, sbm.[BillTo_CUSTOMER_KEY] , c.No_ , c.[Name]
	FROM [POMS_DB].[dbo].[T_Seller_BillTo_Mapping] sbm with (nolock) 
	inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on sbm.[SELLER_KEY] = sl.[SELLER_KEY]
	inner join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on cast(c.[Customer GUID] as nvarchar(36)) = sbm.[BillTo_CUSTOMER_KEY] collate SQL_Latin1_General_CP1_CI_AS
	where sbm.[SELLER_KEY] = @SellerKey and (sbm.[BillTo_CUSTOMER_KEY] = @BillToCustomerKey or @BillToCustomerKey is null)

	return
	

end
GO
