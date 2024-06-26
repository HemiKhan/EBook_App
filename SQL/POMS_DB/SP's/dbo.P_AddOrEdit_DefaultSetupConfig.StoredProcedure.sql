USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_DefaultSetupConfig]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [dbo].[P_AddOrEdit_DefaultSetupConfig] 0, 'LABEL_SIZE', 'Label size', 'This is Just for Testing Purpose', 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_DefaultSetupConfig]
@DSCT_ID INT,
@CONFIG_TYPE nvarchar(50) = '',
@Name nvarchar(250),
@Description nvarchar(1000) = '',
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''

AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @DSCT_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Default_Setup_Config_Type] WITH (NOLOCK) WHERE DSCT_ID = @DSCT_ID)
	BEGIN
	    
		DECLARE @OldCONFIG_TYPE nvarchar(50)
		DECLARE	@OldName nvarchar(250)
		DECLARE @OldDescription nvarchar(1000)
		
		SELECT @OldCONFIG_TYPE = CONFIG_TYPE , @OldName = Name ,@OldDescription = Description   FROM [POMS_DB].[dbo].[T_Default_Setup_Config_Type] WITH (NOLOCK) WHERE DSCT_ID = @DSCT_ID
		
		UPDATE [POMS_DB].[dbo].[T_Default_Setup_Config_Type] SET CONFIG_TYPE = @CONFIG_TYPE, Name = @Name ,Description = @Description, ModifiedBy = @Username ,ModifiedOn = GETUTCDATE() WHERE DSCT_ID = @DSCT_ID

		IF @OldCONFIG_TYPE <> @CONFIG_TYPE
		BEGIN
			exec P_Add_Audit_History 'CONFIG_TYPE' ,'T_Default_Setup_Config_Type', @DSCT_ID, 166138, @DSCT_ID, '', '', @OldCONFIG_TYPE, @CONFIG_TYPE, @OldCONFIG_TYPE, @CONFIG_TYPE, '', 0, 167100, @UserName
		END

		IF @OldName <> @Name
		BEGIN
			exec P_Add_Audit_History 'Name' ,'T_Default_Setup_Config_Type', @DSCT_ID, 166138, @DSCT_ID, '', '', @OldName, @Name, @OldName, @Name, '', 0, 167100, @UserName
		END	
		

		IF @OldDescription <> @Description
		BEGIN
			exec P_Add_Audit_History 'Description_' ,'T_Default_Setup_Config_Type', @DSCT_ID, 166138, @DSCT_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 167100, @UserName
		END	
		
		

		SET @Return_Text = 'Client Default Setting Setup Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Client Default Setting Setup does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @CONFIG_TYPE <> '' 
	BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_Default_Setup_Config_Type] (CONFIG_TYPE, Name ,Description ,CreatedBy , CreatedOn) VALUES (@CONFIG_TYPE, @Name, @Description, @Username ,GETUTCDATE())
		SET @Return_Text = 'Client Default Setting Setup Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE 
	BEGIN
		SET @Return_Text = 'Client Default Setting Setup does not exist!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
