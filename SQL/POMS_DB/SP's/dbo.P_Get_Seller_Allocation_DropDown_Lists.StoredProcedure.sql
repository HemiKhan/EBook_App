USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Seller_Allocation_DropDown_Lists]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_Get_Seller_Allocation_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	SELECT DISTINCT [value] = [Name] , [text]= [Name] FROM [POMS_DB]. [dbo].[T_Seller_Allocation_List] with (nolock) where isActive = 1 ORDER BY [Name] 

	SELECT DISTINCT [value] = [USERNAME] , [text]= USERNAME FROM [POMS_DB].[dbo].[T_Account_Manager_List] with (nolock) where isActive = 1 ORDER BY USERNAME 

	SELECT DISTINCT [value] = SELLER_CODE , [text]= SELLER_CODE FROM [POMS_DB].[dbo].[T_Seller_To_Seller_Allocation_Mapping] with (nolock) where isActive = 1 ORDER BY SELLER_CODE 

	SELECT DISTINCT [value] = tb1.Company , [text]= tb1.Company FROM [POMS_DB].[dbo].[T_Seller_List] tb1 with (nolock) INNER JOIN [POMS_DB].[dbo].[T_Seller_To_Seller_Allocation_Mapping] tb2 with (nolock) ON tb2.SELLER_CODE = tb1.SELLER_CODE where tb1.IsActive = 1 ORDER BY Company 

	SELECT DISTINCT [value] = [USERNAME] , [text] = [USERNAME] FROM [POMS_DB].[dbo].[T_Users] with (nolock) WHERE UserType_MTV_CODE = 'METRO-USER' AND D_ID = 3 AND IsActive = 1 ORDER BY USERNAME

END
GO
