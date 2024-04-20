USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_AddressID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @ADDRESS_ID int exec [POMS_DB].[dbo].[P_Generate_AddressID] @Ret_ADDRESS_ID = @ADDRESS_ID out select @ADDRESS_ID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_AddressID]
	@Ret_ADDRESS_ID int out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_AddressID] (IsGenerate)
	values (1)
	select @Ret_ADDRESS_ID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_AddressID] where ADDRESS_ID = @Ret_ADDRESS_ID
END
GO
