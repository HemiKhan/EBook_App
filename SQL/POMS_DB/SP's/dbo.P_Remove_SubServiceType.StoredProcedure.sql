USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_SubServiceType]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_Remove_PageGroup 0,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Remove_SubServiceType]
@SST_CODE nvarchar(20),
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @SST_CODE <> ''
BEGIN
	DECLARE @IsActive BIT

	IF EXISTS (SELECT 1 FROM [POMS_DB].dbo.[T_Sub_Service_Type] WITH (NOLOCK) WHERE SST_CODE = @SST_CODE)
	BEGIN
		SELECT @IsActive = IsActive FROM [POMS_DB].dbo.[T_Sub_Service_Type] WITH (NOLOCK) WHERE SST_CODE = @SST_CODE
		IF @IsActive = 0 BEGIN		
			UPDATE [POMS_DB].dbo.[T_Sub_Service_Type] SET IsActive = 1 WHERE SST_CODE = @SST_CODE
			SET @Return_Text = 'Sub Service Type ACTIVE Successfully!'
			SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [POMS_DB].dbo.[T_Sub_Service_Type] SET IsActive = 0 WHERE SST_CODE = @SST_CODE
			SET @Return_Text = 'Sub Service Type IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
		
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Sub Service Type does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Sub Service Type ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
