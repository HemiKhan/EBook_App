USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Rights_Json]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Get_Role_Rights_Json] 1
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Role_Rights_Json]
	@RoleID int
AS
BEGIN
	
	Declare @Json nvarchar(max) = ''
	select @Json = [POMS_DB].[dbo].[F_Get_Role_Rights_Json] (@RoleID)
	select @Json as [Json]

END
GO
