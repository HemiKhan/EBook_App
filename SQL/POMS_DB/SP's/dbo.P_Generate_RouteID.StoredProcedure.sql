USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_RouteID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @RouteID int exec [POMS_DB].[dbo].[P_Generate_RouteID] @Ret_RouteID = @RouteID out select @RouteID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_RouteID]
	@Ret_RouteID int out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_RouteID] (IsGenerate)
	values (1)
	select @Ret_RouteID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_RouteID] where RL_ID = @Ret_RouteID
END
GO
