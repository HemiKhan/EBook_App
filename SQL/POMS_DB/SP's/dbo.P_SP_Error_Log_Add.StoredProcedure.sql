USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_SP_Error_Log_Add]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_SP_Error_Log_Add]
	@SPName nvarchar(500)
	,@ParameterString nvarchar(max)
	,@ErrorString nvarchar(max)

AS
BEGIN
	
	Declare @Database_ nvarchar(150) = 'POMS_DB'

	exec [PPlus_LogDB].[dbo].[P_SP_Error_Log_Add] @SPName ,@ParameterString ,@Database_ ,@ErrorString

END
GO
