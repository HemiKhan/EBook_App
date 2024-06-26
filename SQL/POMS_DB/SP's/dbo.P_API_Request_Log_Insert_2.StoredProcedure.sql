USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_API_Request_Log_Insert_2]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_API_Request_Log_Insert_2]
	@Username nvarchar(150) 
	,@RemoteDomain nvarchar(250)
	,@IP_ nvarchar(500)
	,@Path nvarchar(50)
	,@APIID int
	,@MethodID int 
	,@RequestString text
	,@InJson text
	,@OutJson text
	,@Source_ nvarchar(20)
	,@RefNo nvarchar(50)
	,@StatusCode int
	,@ResponseCode bit
	,@ErrorCode nvarchar(20)
	,@ErrorText nvarchar(1000)
	,@ResponseJson text
	,@RequestStartTime nvarchar(50) = null
AS
BEGIN
	
	exec [PPlus_LogDB].[dbo].[P_API_Request_Log_Insert_2] @Username ,@RemoteDomain ,@IP_ ,@Path ,@APIID ,@MethodID ,@RequestString ,@InJson ,@OutJson ,@Source_ ,@RefNo ,@StatusCode ,@ResponseCode ,@ErrorCode ,@ErrorText ,@ResponseJson ,@RequestStartTime

END
GO
