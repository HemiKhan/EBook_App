USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_ZipCode]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_Remove_ZipCode 0,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Remove_ZipCode]
@ZIP_CODE nvarchar(20),
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @ZIP_CODE <> ''
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].T_Zip_Code_List WITH (NOLOCK) WHERE ZIP_CODE = @ZIP_CODE)
	BEGIN	    
		SELECT @IsActive = IsActive FROM [POMS_DB].dbo.T_Zip_Code_List WITH (NOLOCK) WHERE ZIP_CODE = @ZIP_CODE
		IF @IsActive = 0 BEGIN		
			UPDATE [POMS_DB].dbo.T_Zip_Code_List SET IsActive = 1 WHERE ZIP_CODE = @ZIP_CODE
		SET @Return_Text = 'Zip Code ACTIVE Successfully!'
		SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [POMS_DB].dbo.T_Zip_Code_List SET IsActive = 0 WHERE ZIP_CODE = @ZIP_CODE
			SET @Return_Text = 'Zip Code IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Zip Code does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Zip Code Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
