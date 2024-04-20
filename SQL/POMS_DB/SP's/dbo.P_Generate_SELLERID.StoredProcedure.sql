USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_SELLERID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @SELLERID int exec [POMS_DB].[dbo].[P_Generate_SELLERID] @Ret_SELLERID = @SELLERID out select @SELLERID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_SELLERID]
	@Ret_SELLERID int out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_SELLERID] (IsGenerate)
	values (1)
	select @Ret_SELLERID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_SELLERID] where SELLER_ID = @Ret_SELLERID
END
GO
