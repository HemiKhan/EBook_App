USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_BillToClientList]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_BillToClientList] 'C100052', null
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_BillToClientList]
	-- Add the parameters for the stored procedure here
	@CustomerKey nvarchar(36)
	,@Username nvarchar(150)
AS
BEGIN
	
	select CustomerKey,CustomerNo,CustomerName,PaymentTermsCode,PaymentMethodCode,DepartmentCode from [POMS_DB].[dbo].[F_Get_BillToClientList] (@CustomerKey,@Username)
	
END
GO
