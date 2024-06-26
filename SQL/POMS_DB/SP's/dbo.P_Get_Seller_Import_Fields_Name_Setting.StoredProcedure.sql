USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Seller_Import_Fields_Name_Setting]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_Seller_Import_Fields_Name_Setting] '9A84FB40-6AF0-465A-936C-13139909FEEC', 'EXCEL', 'ABDULLAH.ARSHAD'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Seller_Import_Fields_Name_Setting]
	-- Add the parameters for the stored procedure here
	@SellerKey nvarchar(36)
	,@OrderSubSource_MTV_CODE nvarchar(20)
	,@Username nvarchar(150)
AS
BEGIN
	
	select SellerKey ,SellerCode ,SellerName ,OIFFN_ID ,OrderSubSource_MTV_CODE ,[UniqueIDForOrderImport] ,OriginalFieldName ,FieldName ,[Description] ,SetType_MTV_ID ,FieldType_MTV_ID
	,OriginalRequired ,IsRequired ,IsCustomAllowed ,OriginalIsActive ,IsActive from [POMS_DB].[dbo].[F_Get_Seller_Import_Fields_Name_Setting] (@SellerKey, @OrderSubSource_MTV_CODE)
	
END
GO
