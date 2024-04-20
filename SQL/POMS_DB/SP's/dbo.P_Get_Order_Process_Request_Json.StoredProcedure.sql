USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Order_Process_Request_Json]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_Order_Process_Request_Json] '9ee27a65-ae33-4fa6-b8fe-120af069be6a'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Order_Process_Request_Json]
	@RequestID nvarchar(36)
AS
BEGIN
	
	select [Json] = oplj.[Json] from [POMS_DB].[dbo].[T_Order_Process_Log_Json] oplj with (nolock) where oplj.RequestID = @RequestID

END
GO
