USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Is_Has_Right_From_Username]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Is_Has_Right_From_Username]
	@Username nvarchar(150)
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''

AS
BEGIN
	
	select [POMS_DB].[dbo].[F_Is_Has_Right_From_Username] (@Username ,@PR_ID ,@PageRightType_MTV_CODE)

END
GO
