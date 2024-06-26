USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Add_Session_History]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Add_Session_History]
	@WebUserID int
	,@Username nvarchar(150)
	,@SessionID nvarchar(100)
	,@DeviceTypeID int
	,@LoginTime datetime
	,@Latitude nvarchar(50)
	,@Longitude nvarchar(50)
	,@LocalIPAddress nvarchar(50)
	,@InternetAddress nvarchar(50)
	,@ApplicationID int
	,@IsSuccess bit
AS
BEGIN
	
	exec [PinnacleProd].[dbo].[P_Add_Session_History] @WebUserID ,@Username ,@SessionID ,@DeviceTypeID ,@LoginTime ,@Latitude ,@Longitude ,@LocalIPAddress ,@InternetAddress ,@ApplicationID ,@IsSuccess 

END
GO
