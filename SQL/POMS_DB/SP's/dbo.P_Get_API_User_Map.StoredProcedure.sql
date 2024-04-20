USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_API_User_Map]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[P_Get_API_User_Map]
	@UserID int
	,@APIID int
	,@Username nvarchar(150) = null
AS
BEGIN
	
	exec [PPlus_DB].[dbo].[P_Get_API_User_Map] @UserID ,@APIID ,@Username 

END
GO
