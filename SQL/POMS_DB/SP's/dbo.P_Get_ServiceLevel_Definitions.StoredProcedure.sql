USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ServiceLevel_Definitions]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_ServiceLevel_Definitions]
	@ST_CODE nvarchar(20)
	,@SST_CODE nvarchar(20)
AS
BEGIN
	
	SELECT [ServiceDetail] FROM [POMS_DB].[dbo].[T_Service_Type_Detail] where ST_CODE = @ST_CODE and SST_CODE = @SST_CODE and IsActive = 1 order by Sort_, STD_ID

END
GO
