USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_List_By_ID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_List_By_ID] 111,'','S100052'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_List_By_ID]
	-- Add the parameters for the stored procedure here
	@MT_ID int
	,@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(150) = null
AS
BEGIN
	
	select MT_ID,[Name],MTV_ID,MTV_CODE,SubName,Sort_ from [POMS_DB].[dbo].[F_Get_List_By_ID] (@MT_ID,@SELLER_KEY,@SELLER_CODE,@SELLER_NAME) order by Sort_

END
GO
