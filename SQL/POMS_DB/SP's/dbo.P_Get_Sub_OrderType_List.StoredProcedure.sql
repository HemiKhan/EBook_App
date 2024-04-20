USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Sub_OrderType_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_Sub_OrderType_List] 146101, 'ABDULLAH.ARSHAD'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Sub_OrderType_List]
	-- Add the parameters for the stored procedure here
	@OrderType_MTV_ID int
	,@Username nvarchar(150) = null
AS
BEGIN
	
	select MTV_ID ,ID ,[Name] from [POMS_DB].[dbo].[F_Get_Sub_OrderType_List] (@OrderType_MTV_ID,@Username)

END
GO
