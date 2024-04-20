USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_CustomRoleID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @CustomRoleID int exec [POMS_DB].[dbo].[P_Generate_CustomRoleID] @Ret_CustomRoleID = @CustomRoleID out select @CustomRoleID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_CustomRoleID]
	@Ret_CustomRoleID int out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_CustomRoleID] (IsGenerate)
	values (1)
	select @Ret_CustomRoleID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_CustomRoleID] where CustomRole_ID = @Ret_CustomRoleID
END
GO
