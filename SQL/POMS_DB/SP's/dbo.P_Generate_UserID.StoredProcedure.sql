USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_UserID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @UserID int exec [POMS_DB].[dbo].[P_Generate_UserID] @Ret_UserID = @UserID out select @UserID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_UserID]
	@Ret_UserID int out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_UserID] (IsGenerate)
	values (1)
	select @Ret_UserID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_UserID] where USER_ID = @Ret_UserID
END
GO
