USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_BuildID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @BUILD_ID int exec [POMS_DB].[dbo].[P_Generate_BuildID] @Ret_BUILD_ID = @BUILD_ID out select @BUILD_ID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_BuildID]
	@Ret_BUILD_ID int out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_BuildID] (IsGenerate)
	values (1)
	select @Ret_BUILD_ID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_BuildID] where BUILD_ID = @Ret_BUILD_ID
END
GO
