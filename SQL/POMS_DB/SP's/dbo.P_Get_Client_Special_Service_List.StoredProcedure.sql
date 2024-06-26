USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Client_Special_Service_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Get_Client_Special_Service_List] 'QUOTE', '', 'S100052'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Client_Special_Service_List]
	-- Add the parameters for the stored procedure here
	@ST_CODE nvarchar(20)
	,@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(150) = null
AS
BEGIN
	
	if (@ST_CODE = 'QUOTE')
	begin
		select SellerKey,SellerCode,SellerName,SLSS_ID,ST_CODE,SSL_CODE,[Name],IsAvailableForPickup,IsAvailableForDelivery,IsReqMints,IsFloorsRequired,IsDaysRequired
		,IsEstAmountRequired,IsFromDateRequired,IsToDateRequired,IsManRequired,IsDefaultMintsZero,IsDefaultDaysZero,IsDefaultEstAmountZero,IsDefaultFromDateNULL
		,IsDefaultToDateNULL,IsDefaultManZero,IsOpted,IsActive from [POMS_DB].[dbo].[F_Get_Client_Special_Service_List_Quote] (@ST_CODE ,@SELLER_KEY ,@SELLER_CODE ,@SELLER_NAME)
	end
	else
	begin
		select SellerKey,SellerCode,SellerName,SLSS_ID,ST_CODE,SSL_CODE,[Name],IsAvailableForPickup,IsAvailableForDelivery,IsReqMints,IsFloorsRequired,IsDaysRequired
		,IsEstAmountRequired,IsFromDateRequired,IsToDateRequired,IsManRequired,IsDefaultMintsZero,IsDefaultDaysZero,IsDefaultEstAmountZero,IsDefaultFromDateNULL
		,IsDefaultToDateNULL,IsDefaultManZero,IsOpted,IsActive from [POMS_DB].[dbo].[F_Get_Client_Special_Service_List] (@ST_CODE ,@SELLER_KEY ,@SELLER_CODE ,@SELLER_NAME)
	end

END
GO
