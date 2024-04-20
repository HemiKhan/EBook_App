USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Search_Sku_And_Desc]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Search_Sku_And_Desc] ('AD330B2D-DC87-4512-88B4-C8D5ECCE8B38','78',10,'ABDULLAH.ARSHAD')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Search_Sku_And_Desc]
(	
	@SELLER_KEY nvarchar(36)
	,@SearchSKU nvarchar(150)
	,@TopRecord int
	,@Username nvarchar(150)
)
RETURNS @ReturnTable TABLE 
(SSS_ID int, IsMasterSKU bit)
AS
begin
	
	if (@TopRecord > 0)
	begin
		insert into @ReturnTable (SSS_ID , IsMasterSKU)
		
		select top (@TopRecord) SSS_ID,IsMasterSKU from (
		
			select SSS_ID=min(sss.SSS_ID), IsMasterSKU=1
			, SKU_No=sss.MasterSKU_No, [Description]=sss.MasterSKUDescription 
			from [POMS_DB].[dbo].[T_Seller_Sku_Setup] sss with (nolock) where sss.IsActive = 1 and sss.SELLER_KEY = @SELLER_KEY 
			and (sss.MasterSKU_No like '%'+ @SearchSKU +'%' or sss.MasterSKUDescription like '%'+ @SearchSKU +'%') and sss.IsMasterSKU = 1
			group by sss.MasterSKU_No,sss.MasterSKUDescription

			union

			select sss.SSS_ID, IsMasterSKU=0
			, SKU_No=sss.SKU_No, [Description]=sss.[Description] 
			from [POMS_DB].[dbo].[T_Seller_Sku_Setup] sss with (nolock) where sss.IsActive = 1 and sss.SELLER_KEY = @SELLER_KEY 
			and (sss.SKU_No like '%'+ @SearchSKU +'%' or sss.[Description] like '%'+ @SearchSKU +'%')
		) ilv order by SSS_ID asc, [Description] asc, IsMasterSKU desc
	end

	return
	

end
GO
