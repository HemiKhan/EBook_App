USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Client_Service_Type_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Get_Client_Service_Type_List] 125100, '', 0 , 'S100052','GlobalTranz','DKBI,WG'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Client_Service_Type_List]
	-- Add the parameters for the stored procedure here
	@Type_MTV_ID int
	,@SELLER_KEY nvarchar(36)
	,@IsAll bit = 0
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(150) = null
	,@ST_CODE nvarchar(max) = null
AS
BEGIN

	select ID,SellerKey,SellerCode,SellerName,Required_CODE,ST_CODE,ServiceName,SST_CODE,SubServiceName,ServiceLevelDetails,Type_MTV_ID
	,[Type_Name],IsDefault,IsActive,IsAllowed from [POMS_DB].[dbo].[F_Get_Client_Service_Type_List] (@Type_MTV_ID ,@SELLER_KEY ,@IsAll ,@SELLER_CODE ,@SELLER_NAME ,@ST_CODE)

END
GO
