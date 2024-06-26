USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Client_Ignore_API_Errors_List]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Client_Ignore_API_Errors_List] ('42A988E7-12FA-48B6-BF38-EF900E6ED9AB', 'S100052','GlobalTranz')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Client_Ignore_API_Errors_List]
(	
	@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(250) = null
)
returns @ReturnTable table
(IAPIEL_ID int
,[Name] nvarchar(100)
,IsActive bit
,IsIgnore bit
)
AS
Begin

	set @SELLER_KEY = isnull(@SELLER_KEY,'')

	Declare @SellerTable table (SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250), IsViewOrder bit ,IsCreateOrder bit ,IsGetQuote bit ,IsFinancial bit, IsAdmin bit ,IsSellerMapped bit)
	
	if @SELLER_CODE is null
	begin
		insert into @SellerTable
		select SellerKey , SellerCode , SellerName , IsViewOrder ,IsCreateOrder ,IsGetQuote ,IsFinancial, IsAdmin, IsSellerMapped from [POMS_DB].[dbo].[F_Get_SellToClientList] (@SELLER_KEY,null)
	end
	else
	begin
		insert into @SellerTable
		select @SELLER_KEY, @SELLER_CODE, @SELLER_NAME, 0, 0, 0, 0, 0, 0
	end

	insert into @ReturnTable 
	select ilv2.IAPIEL_ID
	,ilv2.[Name]
	,IsActive=isnull(ciael.IsActive,ilv2.IsActive)
	,IsIgnore=isnull(ciael.IsIgnore,ilv2.IsIgnore)
	from (Select c.SellerKey
	,c.SellerCode
	,c.SellerName
	,iael.IAPIEL_ID
	,iael.[Name]
	,iael.IsActive
	,iael.IsIgnore
	FROM [POMS_DB].[dbo].[T_Ignore_API_Errors_List] iael with (nolock)
	cross apply @SellerTable c 
	where iael.IsActive = 1
	) ilv2 left join [POMS_DB].[dbo].[T_Client_Ignore_API_Errors_List] ciael with (nolock) on ciael.IAPIEL_ID = ilv2.IAPIEL_ID and ilv2.SellerCode = ciael.SELLER_CODE 

	return

end
GO
