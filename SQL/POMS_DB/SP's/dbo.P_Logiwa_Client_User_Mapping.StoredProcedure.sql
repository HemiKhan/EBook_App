USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Logiwa_Client_User_Mapping]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--	EXEC [P_Logiwa_Client_User_Mapping] 'PPLUSAPI.USER', 'Metro User'

CREATE PROCEDURE [dbo].[P_Logiwa_Client_User_Mapping]
	 @Username nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@SellerKey nvarchar(150) = null
AS
BEGIN
	
   set @SellerKey = isnull(@SellerKey,'')

   SELECT lc.CUSTOMER_KEY, 
   lc.SELLER_KEY, 
   lc.Logiwa_ID, 
   lc.Logiwa_Name, 
   lc.Logiwa_OrderType 
   FROM [POMS_DB].[dbo].[T_LogiwaClient] lc with (nolock)
   inner join [POMS_DB].[dbo].[T_Clients_Users_Mapping] cum with (nolock) on lc.LC_ID = cum.LC_ID AND
   lc.IsActive = 1 AND cum.IsActive = 1
   and cum.USERNAME = @Username
   and (lc.SELLER_KEY = @SellerKey or @SellerKey = '');

END
GO
