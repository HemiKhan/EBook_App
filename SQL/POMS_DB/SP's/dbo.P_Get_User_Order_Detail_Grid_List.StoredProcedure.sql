USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_User_Order_Detail_Grid_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec [POMS_DB].[dbo].[P_Get_User_Order_Detail_Grid_List] 'ABDULLAH.ARSHAD'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_User_Order_Detail_Grid_List]
	@Username nvarchar(150)
AS
BEGIN
	
	select ODGL_ID ,GridName ,IsExpand ,NewSort_ ,Sort_ ,PR_ID ,IsActive from [POMS_DB].[dbo].[F_Get_User_Order_Detail_Grid_List] (@Username) order by NewSort_

END
GO
