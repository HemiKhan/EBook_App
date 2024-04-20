USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Generate_OrderID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @OrderID bigint exec [POMS_DB].[dbo].[P_Generate_OrderID] @Ret_OrderID = @OrderID out select @OrderID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_OrderID]
	@Ret_OrderID bigint out
AS
BEGIN
	insert into [POMS_DB].[dbo].[T_Generate_OrderID] (IsGenerate)
	values (1)
	select @Ret_OrderID = SCOPE_IDENTITY()
	--delete from [POMS_DB].[dbo].[T_Generate_OrderID] where ORDER_ID = @Ret_OrderID
END
GO
