USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_SellToClientList]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_SellToClientList] null, 'ABDULLAH.ARSHAD'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_SellToClientList]
	-- Add the parameters for the stored procedure here
	@SellerKey nvarchar(36)
	,@Username nvarchar(150)
AS
BEGIN
	
	select SellerKey,SellerCode,SellerName,IsViewOrder,IsCreateOrder,IsGetQuote,IsFinancial from [POMS_DB].[dbo].[F_Get_SellToClientList] (@SellerKey,@Username)
	
END
GO
