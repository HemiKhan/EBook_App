USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_API_RemoteDomain_IP_Request_Limit]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[P_Get_API_RemoteDomain_IP_Request_Limit]
	@RemoteDomain_Or_IP nvarchar(150)
	,@MethodID int
	,@Is_RemoteDomain bit
AS
BEGIN

	exec [PPlus_DB].[dbo].[P_Get_API_RemoteDomain_IP_Request_Limit] @RemoteDomain_Or_IP ,@MethodID ,@Is_RemoteDomain

END
GO
