USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_EstimateInvoiceID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @EstimateID bigint exec [POMS_DB].[dbo].[P_Generate_EstimateInvoiceID] @Ret_EstimateID = @EstimateID out select @EstimateID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_EstimateInvoiceID]
	@Ret_EstimateID bigint out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_EstimateInvoiceID] (IsGenerate)
	values (1)
	select @Ret_EstimateID = SCOPE_IDENTITY()
END
GO
