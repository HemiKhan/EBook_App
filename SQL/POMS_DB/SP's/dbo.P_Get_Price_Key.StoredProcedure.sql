USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Price_Key]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Get_Price_Key] '','','','','',''
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Price_Key]
	@SellToCustomerKey nvarchar(36)
	,@SubSellToCustomerKey nvarchar(36)
	,@SellToPartnerKey nvarchar(36)
	,@TariffNo nvarchar(36)
	,@BillToCustomerKey nvarchar(36)
	,@Username nvarchar(150)

AS
BEGIN
	
	select * from [POMS_DB].[dbo].[F_Get_Price_Key] (@SellToCustomerKey ,@SubSellToCustomerKey ,@SellToPartnerKey ,@TariffNo ,@BillToCustomerKey ,@Username)

END
GO
