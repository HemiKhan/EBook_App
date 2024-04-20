USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Captcha_Log_Insert]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[P_Captcha_Log_Insert]
	@VersionName nvarchar(50)
	,@ApplicationID int
	,@Page nvarchar(250)
	,@Domain nvarchar(250)
	,@IsSuccess bit
	,@Error nvarchar(1000)
	,@Score decimal(4,2)
	,@SetScore decimal(4,2)
	,@Ref1 nvarchar(1000)
	,@IPAddress nvarchar(20)
AS
BEGIN

	exec [PPlus_DB].[dbo].[P_Captcha_Log_Insert] @VersionName ,@ApplicationID ,@Page ,@Domain ,@IsSuccess ,@Error ,@Score ,@SetScore ,@Ref1 ,@IPAddress 

END
GO
