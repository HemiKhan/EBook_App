USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ApplicationSettingSetup]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--		EXEC [P_AddOrEdit_ApplicationSettingSetup]  0, 'S100000', 'PICKUP_ST_CODE', 'Only For testing Purpose', 'RN01', 'RN02', NULL, NULL, NULL,1, 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_ApplicationSettingSetup]
@ASS_ID INT,
@CONFIG_TYPE_MTV_CODE nvarchar(50),
@Description nvarchar(1000),
@REFNO1 nvarchar(50) = NULL,
@REFNO2 nvarchar(50) = NULL,
@REFNO3 nvarchar(50) = NULL,
@REFID1 int = NULL,
@REFID2 int = NULL,
@REFID3 int = NULL,
@IsActive bit = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @ASS_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Application_Setting_Setup] WITH (NOLOCK) WHERE ASS_ID = @ASS_ID)
	BEGIN
	    

		DECLARE @OldCONFIG_TYPE nvarchar(50)
		DECLARE @OldDescription nvarchar(1000)
		DECLARE @OldREFNO1 nvarchar(50)
		DECLARE @OldREFNO2 nvarchar(50)
		DECLARE @OldREFNO3 nvarchar(50)
		DECLARE @OldREFID1 int
		DECLARE @OldREFID2 int
		DECLARE @OldREFID3 int
		DECLARE @OldIsActive bit
		
		SELECT @OldCONFIG_TYPE = CONFIG_TYPE_MTV_CODE , @OldDescription = Description_, @OldREFNO1 = REFNO1, @OldREFNO2 = REFNO2, @OldREFNO3 = REFNO3, @OldREFID1 = REFID1, @OldREFID2 = REFID2, @OldREFID3 = REFID3, @OldIsActive = IsActive  FROM [POMS_DB].[dbo].[T_Application_Setting_Setup] WITH (NOLOCK) WHERE ASS_ID = @ASS_ID
		
		UPDATE [POMS_DB].[dbo].[T_Application_Setting_Setup] SET CONFIG_TYPE_MTV_CODE = @CONFIG_TYPE_MTV_CODE, Description_ = @Description, REFNO1 = @REFNO1, REFNO2 = @REFNO2, REFNO3 = @REFNO3, REFID1 = @REFID1, REFID2 = @REFID2, REFID3 = @REFID3, IsActive = @IsActive ,ModifiedOn = GETUTCDATE() WHERE ASS_ID = @ASS_ID

		IF @OldCONFIG_TYPE <> @CONFIG_TYPE_MTV_CODE
		BEGIN
			exec P_Add_Audit_History 'CONFIG_TYPE', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldCONFIG_TYPE, @CONFIG_TYPE_MTV_CODE, @OldCONFIG_TYPE, @CONFIG_TYPE_MTV_CODE, '', 0, 167100, @UserName
		END

		IF @OldDescription <> @Description
		BEGIN
			exec P_Add_Audit_History 'Description_' ,'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 167100, @UserName
		END	
		
		IF @OldREFNO1 <> @REFNO1
		BEGIN 
			exec P_Add_Audit_History 'REFNO1', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFNO1, @REFNO1, @OldREFNO1, @REFNO1, '', 0, 167100, @UserName
		END

		IF @OldREFNO2 <> @REFNO2
		BEGIN 
			exec P_Add_Audit_History 'REFNO2', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFNO2, @REFNO2, @OldREFNO2, @REFNO2, '', 0, 167100, @UserName
		END

		IF @OldREFNO3 <> @REFNO3
		BEGIN 
			exec P_Add_Audit_History 'REFNO3', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFNO3, @REFNO3, @OldREFNO3, @REFNO3, '', 0, 167100, @UserName
		END

		IF @OldREFID1 <> @REFID1
		BEGIN 
			exec P_Add_Audit_History 'REFID1', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFID1, @REFID1, @OldREFID1, @REFID1, '', 0, 167100, @UserName
		END

		IF @OldREFID2 <> @REFID2
		BEGIN 
			exec P_Add_Audit_History 'REFID2', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFID2, @REFID2, @OldREFID2, @REFID2, '', 0, 167100, @UserName
		END

		IF @OldREFID3 <> @REFID3
		BEGIN 
			exec P_Add_Audit_History 'REFID3', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFID3, @REFID3, @OldREFID3, @REFID3, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Application Setting Setup Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Application Setting Setup does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @CONFIG_TYPE_MTV_CODE <> '' 
	BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_Application_Setting_Setup] (CONFIG_TYPE_MTV_CODE, Description_, REFNO1, REFNO2, REFNO3, REFID1, REFID2, REFID3, IsActive, AddedBy, AddedOn) VALUES (@CONFIG_TYPE_MTV_CODE, @Description, @REFNO1, @REFNO2, @REFNO3, @REFID1 ,@REFID2, @REFID3, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Application Setting Setup Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE 
	BEGIN
		SET @Return_Text = 'Application Setting Setup does not exist!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
