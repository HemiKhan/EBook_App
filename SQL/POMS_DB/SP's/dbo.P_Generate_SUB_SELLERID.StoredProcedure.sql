USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_SUB_SELLERID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @SUB_SELLERID int exec [POMS_DB].[dbo].[P_Generate_SUB_SELLERID] @Ret_SUB_SELLERID = @SUB_SELLERID out select @SUB_SELLERID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_SUB_SELLERID]
	@Ret_SUB_SELLERID int out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_SUB_SELLERID] (IsGenerate)
	values (1)
	select @Ret_SUB_SELLERID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_SUB_SELLERID] where SUB_SELLER_ID = @Ret_SUB_SELLERID
END
GO
