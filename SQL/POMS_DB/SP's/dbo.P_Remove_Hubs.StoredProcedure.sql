USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_Hubs]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_Remove_Hubs 0,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Remove_Hubs]
@HL_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @HL_ID > 0
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].T_Hub_List WITH (NOLOCK) WHERE HL_ID = @HL_ID)
	BEGIN	    
		SELECT @IsActive = IsActive FROM [POMS_DB].dbo.T_Hub_List WITH (NOLOCK) WHERE HL_ID = @HL_ID
		IF @IsActive = 0 BEGIN		
			UPDATE [POMS_DB].dbo.T_Hub_List SET IsActive = 1 WHERE HL_ID = @HL_ID
		SET @Return_Text = 'Hub ACTIVE Successfully!'
		SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [POMS_DB].dbo.T_Hub_List SET IsActive = 0 WHERE HL_ID = @HL_ID
			SET @Return_Text = 'Hub IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Hub does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Hub ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
