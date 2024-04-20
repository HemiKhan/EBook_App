USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_Client_Identifier_Fields_List]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_Client_Identifier_Fields_List] ('42A988E7-12FA-48B6-BF38-EF900E6ED9AB', 'S100052','GlobalTranz')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_Client_Identifier_Fields_List]
(	
	@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(250) = null
)
returns @ReturnTable table
(SellerKey nvarchar(36)
,SellerCode nvarchar(20)
,SellerName nvarchar(250)
,OIF_CODE nvarchar(20)
,[Description] nvarchar(50)
,[IsRequired] bit
,[IsDuplicateAllowed] bit
,[IsModifyAllowed] bit
,[IsHidden] bit
,[IsAllowed] bit
,[CharacterLimit] int
,[IsActive] bit
)
AS
Begin

	set @SELLER_KEY = isnull(@SELLER_KEY,'')

	Declare @SellerTable table (SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250))
	
	if @SELLER_CODE is null
	begin
		insert into @SellerTable
		select SellerKey , SellerCode , SellerName  from [POMS_DB].[dbo].[F_Get_SellToClientList] (@SELLER_KEY,null)
	end
	else
	begin
		insert into @SellerTable
		select @SELLER_KEY, @SELLER_CODE, @SELLER_NAME
	end

	insert into @ReturnTable 
	--select * from (
	select ilv.[SellerKey]
	,ilv.[SellerCode]
	,ilv.[SellerName]
	,ilv.[OIF_CODE]
	,ilv.[Description]
	,[IsRequired]=(case when ocif.[OIF_CODE] is null then ilv.[IsRequired] else ocif.[IsRequired] end)
	,[IsDuplicateAllowed]=(case when ocif.[OIF_CODE] is null then ilv.[IsDuplicateAllowed] else ocif.[IsDuplicateAllowed] end)
	,[IsModifyAllowed]=(case when ocif.[OIF_CODE] is null then ilv.[IsModifyAllowed] else ocif.[IsModifyAllowed] end)
	,[IsHidden]=(case when ocif.[OIF_CODE] is null then ilv.[IsHidden] else ocif.[IsHidden] end)
	,[IsAllowed]=(case when ocif.[OIF_CODE] is null then ilv.[IsAllowed] else ocif.[IsAllowed] end)
	,[CharacterLimit]=(case when ocif.[OIF_CODE] is null then ilv.[CharacterLimit] else ocif.[CharacterLimit] end)
	,ilv.[IsActive]
	from (Select s.SellerKey
	,s.SellerCode
	,s.SellerName
	,[OIF_CODE]
	,[Description]
	,[IsRequired]
	,[IsDuplicateAllowed]
	,[IsModifyAllowed]
	,[IsHidden]
	,[IsAllowed]
	,[CharacterLimit]
	,[IsActive]
	FROM [POMS_DB].[dbo].[T_Order_Identifier_Fields] oif with (nolock)
	cross apply @SellerTable s
	where oif.[IsActive] = 1
	) ilv left join [POMS_DB].[dbo].[T_Order_Client_Identifier_Fields] ocif with (nolock) on ilv.OIF_CODE = ocif.OIF_CODE and ilv.SellerCode = ocif.SELLER_CODE
	where isnull(ocif.[IsAllowed],ilv.[IsAllowed]) = 1
	--) ilv2 where ilv2.[IsAllowed] = 1

	return

end
GO
