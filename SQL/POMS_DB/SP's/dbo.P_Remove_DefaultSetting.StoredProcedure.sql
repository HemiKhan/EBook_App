USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_DefaultSetting]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_Remove_PageGroup 0,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Remove_DefaultSetting]
@DSS INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @DSS > 0
BEGIN
	DECLARE @IsActive BIT

	IF EXISTS (SELECT 1 FROM [POMS_DB].dbo.T_Default_Setting_Setup WITH (NOLOCK) WHERE DSS = @DSS)
	BEGIN
		SELECT @IsActive = IsActive FROM [POMS_DB].dbo.T_Default_Setting_Setup WITH (NOLOCK) WHERE DSS = @DSS
		IF @IsActive = 0 BEGIN		
			UPDATE [POMS_DB].dbo.T_Default_Setting_Setup SET IsActive = 1 WHERE DSS = @DSS
			SET @Return_Text = 'Default Setting ACTIVE Successfully!'
			SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [POMS_DB].dbo.T_Default_Setting_Setup SET IsActive = 0 WHERE DSS = @DSS
			SET @Return_Text = 'Default Setting IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
		
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Default Setting does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Default Setting ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
