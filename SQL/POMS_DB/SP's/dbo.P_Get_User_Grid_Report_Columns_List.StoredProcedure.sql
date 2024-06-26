USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_User_Grid_Report_Columns_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Get_User_Grid_Report_Columns_List] 0, 0, '78007833-1daa-43e5-a893-cdc7f4d0bbf8', '', 'ABDULLAH.ARSHAD', 'METRO-USER'
-- [P_Get_User_Grid_Report_Columns_List] 1, 0, '', '', 'ABDULLAH.ARSHAD', 'METRO-USER'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_User_Grid_Report_Columns_List]
	@GRL_ID int
	,@UGRTL_ID int
	,@GRGUID nvarchar(36)
	,@UGRCGUID nvarchar(36)
	,@Username nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
AS
BEGIN
	
	select UGRTL_ID
		,GRLID
		,GRGUID_
		,GRName
		,GRCID
		,uiid=GRCGUID_
		,Code
		,[Name]=GRCName
		,UGRCName
		,IsHidden
		,IsChecked
		,SortPosition=NewSortID
		,IsPublic
	from [POMS_DB].[dbo].[F_Get_User_Grid_Report_Columns_List] (@GRL_ID ,@UGRTL_ID ,@GRGUID ,@UGRCGUID ,@Username ,@UserType_MTV_CODE) order by SortPosition

END
GO
