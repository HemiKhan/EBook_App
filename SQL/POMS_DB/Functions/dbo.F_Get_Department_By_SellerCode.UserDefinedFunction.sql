USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Department_By_SellerCode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Department_By_SellerCode] ('S100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Department_By_SellerCode]
(	
	@SellerCode nvarchar(20)
)
RETURNS @ReturnTable TABLE 
(D_ID int, DepartmentName nvarchar(50))
AS
begin

	insert into @ReturnTable
	select D_ID 
	,DepartmentName=(case when D_ID is not null then isnull((select top 1 DepartmentName from [POMS_DB].[dbo].[T_Department] d with (nolock) where d.D_ID = sl.D_ID),'') else '' end)
	from [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) where sl.SELLER_CODE = @SellerCode

	return
	

end
GO
