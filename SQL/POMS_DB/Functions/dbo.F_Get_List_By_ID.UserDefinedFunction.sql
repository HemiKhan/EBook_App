USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_List_By_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_List_By_ID] (100,'42A988E7-12FA-48B6-BF38-EF900E6ED9AB', 'S100052', 'GlobalTranz')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_List_By_ID]
(	
	@MT_ID int
	,@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(250) = null
)
returns @ReturnTable table
(MT_ID int
,[Name] nvarchar(100)
,MTV_ID int
,MTV_CODE nvarchar(20)
,[SubName] nvarchar(100)
,Sort_ int
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
	select 
	MT_ID = mt.MT_ID
	,[Name] = mt.[Name]
	,MTV_ID = mtv.MTV_ID
	,MTV_CODE = mtv.MTV_CODE
	,[SubName] = mtv.[Name]
	,Sort_ = mtv.Sort_
	from [POMS_DB].[dbo].[T_Master_Type] mt 
	left join [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = @MT_ID
	and exists(select * from @SellerTable)
	order by Sort_

	return

end
GO
