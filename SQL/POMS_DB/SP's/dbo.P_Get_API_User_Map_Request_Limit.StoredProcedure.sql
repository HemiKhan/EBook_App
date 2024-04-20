USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_API_User_Map_Request_Limit]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[P_Get_API_User_Map_Request_Limit]
	@UserID int
	,@MethodID int
	,@Username nvarchar(150) = null
AS
BEGIN
	
	exec [PPlus_DB].[dbo].[P_Get_API_User_Map_Request_Limit] @UserID ,@MethodID, @Username

END
GO
