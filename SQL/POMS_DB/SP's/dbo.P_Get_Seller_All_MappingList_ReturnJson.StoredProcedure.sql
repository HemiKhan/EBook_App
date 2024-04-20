USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Seller_All_MappingList_ReturnJson]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_Seller_All_MappingList_ReturnJson] 'B40869B4-14B5-40EE-A702-D8F57765570E', null
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Seller_All_MappingList_ReturnJson]
	-- Add the parameters for the stored procedure here
	@SellerKey nvarchar(36) = null
	,@Username nvarchar(150) = null
AS
BEGIN
	
	select [POMS_DB].[dbo].[F_Get_Seller_All_MappingList_ReturnJson] (@SellerKey,@Username)
	
END
GO
