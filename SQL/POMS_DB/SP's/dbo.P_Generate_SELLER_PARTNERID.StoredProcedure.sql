USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_SELLER_PARTNERID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @SELLER_PARTNERID int exec [POMS_DB].[dbo].[P_Generate_SELLER_PARTNERID] @Ret_SELLER_PARTNERID = @SELLER_PARTNERID out select @SELLER_PARTNERID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_SELLER_PARTNERID]
	@Ret_SELLER_PARTNERID int out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_SELLER_PARTNERID] (IsGenerate)
	values (1)
	select @Ret_SELLER_PARTNERID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_SELLER_PARTNERID] where SELLER_PARTNER_ID = @Ret_SELLER_PARTNERID
END
GO
