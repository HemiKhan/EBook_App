USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Order_Client_Identifier_Fields_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Get_Order_Client_Identifier_Fields_List] '','S100052'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Order_Client_Identifier_Fields_List]
	-- Add the parameters for the stored procedure here
	@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(150) = null
AS
BEGIN
	
	select SellerKey,SellerCode,SellerName,OIF_CODE,[Description],IsRequired,IsDuplicateAllowed,IsModifyAllowed,IsHidden,IsAllowed,CharacterLimit,IsActive 
	from [POMS_DB].[dbo].[F_Get_Order_Client_Identifier_Fields_List] (@SELLER_KEY ,@SELLER_CODE ,@SELLER_NAME)

END
GO
