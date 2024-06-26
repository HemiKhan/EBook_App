USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Default_Setup_DropDown_Lists]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[P_Get_Default_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	SELECT DISTINCT [value] = tb1.SELLER_KEY, [text]= tb2.Company FROM [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] tb1 with (nolock) LEFT JOIN [POMS_DB].[dbo].[T_SELLER_LIST] tb2 with (nolock) ON tb2.SELLER_KEY = tb1.SELLER_KEY WHERE tb2.Company IS NOT NULL ORDER BY tb2.Company 

	SELECT DISTINCT [value] = FileSource_MTV_CODE, [text]= FileSource_MTV_CODE FROM [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] with (nolock) where isActive = 1 ORDER BY FileSource_MTV_CODE 

	SELECT DISTINCT [value] = OrderSubSource_MTV_CODE, [text]= OrderSubSource_MTV_CODE FROM [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] with (nolock) where isActive = 1 ORDER BY OrderSubSource_MTV_CODE 

	SELECT DISTINCT [value] = Code_MTV_CODE, [text]= Code_MTV_CODE FROM [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] with (nolock) where isActive = 1 ORDER BY Code_MTV_CODE 

	SELECT DISTINCT [value] = CODE2, [text]= CODE2 FROM [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] with (nolock) where CODE2 IS NOT NULL AND isActive = 1 ORDER BY CODE2 

	SELECT DISTINCT [value] = MTV_CODE, [text]= tb2.[Name] FROM [POMS_DB].[dbo].[T_Master_Type_Value] tb2 with (nolock) where IsActive = 1 AND MT_ID = 174 ORDER BY [Name]

	SELECT DISTINCT [value] = CONFIG_TYPE, [text]= [Name] FROM [POMS_DB].[dbo].[T_Default_Setup_Config_Type] with (nolock) ORDER BY [Name]

END
GO
