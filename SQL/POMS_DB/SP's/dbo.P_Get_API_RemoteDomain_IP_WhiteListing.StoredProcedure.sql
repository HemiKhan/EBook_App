USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_API_RemoteDomain_IP_WhiteListing]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_API_Host_IP_WhiteListing] @HostName_Or_IP = 'localhost' ,@APIID = 40000 ,@Is_HostName = 1,@IsWhiteList = 1 ,@IsBlackList = 0
-- =============================================
Create PROCEDURE [dbo].[P_Get_API_RemoteDomain_IP_WhiteListing]
	@RemoteDomain_Or_IP nvarchar(150)
	,@APIID int
	,@Is_RemoteDomain bit
AS
BEGIN

	exec [PPlus_DB].[dbo].[P_Get_API_RemoteDomain_IP_WhiteListing] @RemoteDomain_Or_IP ,@APIID ,@Is_RemoteDomain

END
GO
