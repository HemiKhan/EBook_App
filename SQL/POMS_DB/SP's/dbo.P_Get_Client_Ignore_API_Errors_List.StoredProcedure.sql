USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Client_Ignore_API_Errors_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_Client_Ignore_API_Errors_List] '','S100052'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Client_Ignore_API_Errors_List]
	-- Add the parameters for the stored procedure here
	@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(250) = null
AS
BEGIN
	
	select IAPIEL_ID,[Name],IsActive,IsIgnore from [POMS_DB].[dbo].[F_Get_Client_Ignore_API_Errors_List] (@SELLER_KEY, @SELLER_CODE, @SELLER_NAME)
	

END
GO
