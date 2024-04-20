USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_TariffID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @TariffID int exec [dbo].[P_Generate_TariffID] @Ret_TariffID = @TariffID out select @TariffID
-- =============================================
create PROCEDURE [dbo].[P_Generate_TariffID]
	@Ret_TariffID int out
AS
BEGIN
	insert into [dbo].[T_Generate_TariffID] (IsGenerate)
	values (1)
	select @Ret_TariffID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_TariffID] where Tariff_ID = @Ret_TariffID
END
GO
