USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_ImportFileSetup_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [dbo].[P_User_Seller_Allocation_IU] 1 ,'ABDULLAH.ARSHAD', 1 ,1 ,'TAIMOOR.ALI'

CREATE PROC [dbo].[P_ImportFileSetup_IU]
@IOFSS_ID int
,@SELLER_KEY nvarchar(100)
,@FileSource_MTV_CODE nvarchar(100)
,@OrderSubSource_MTV_CODE nvarchar(100)
,@Code_MTV_CODE nvarchar(100)
,@CODE2 nvarchar(100)
,@Description nvarchar(100)
,@REFNO1 nvarchar(100)
,@REFNO2 nvarchar(100)
,@REFNO3 nvarchar(100)
,@IsActive bit
,@Username nvarchar(150)
,@IPAddress nvarchar(20) = ''

AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''
	set @IOFSS_ID = isnull(@IOFSS_ID,0)

	IF @IOFSS_ID > 0 
	BEGIN
		DECLARE @OldSELLER_KEY nvarchar(100)
		DECLARE @OldFileSource_MTV_CODE nvarchar(100)
		DECLARE @OldOrderSubSource_MTV_CODE nvarchar(100)
		DECLARE @OldCode_MTV_CODE nvarchar(100)
		DECLARE @OldCODE2 nvarchar(100)
		DECLARE @OldDescription nvarchar(100)
		DECLARE @OldREFNO1 nvarchar(100)
		DECLARE @OldREFNO2 nvarchar(100)
		DECLARE @OldREFNO3 nvarchar(100)
		DECLARE @OldIsActive BIT
		
		SELECT @OldSELLER_KEY = [SELLER_KEY], @OldFileSource_MTV_CODE = [FileSource_MTV_CODE], @OldOrderSubSource_MTV_CODE = [OrderSubSource_MTV_CODE], @OldCode_MTV_CODE = Code_MTV_CODE, @OldCODE2 = CODE2, @OldDescription = [Description], @OldREFNO1 = REFNO1, @OldREFNO2 = REFNO2, @OldREFNO3 = REFNO3 ,@OldIsActive = [IsActive] FROM [POMS_DB].dbo.[T_Import_Order_File_Source_Setup] iofs WITH (NOLOCK) WHERE iofs.IOFSS_ID = @IOFSS_ID
		
		UPDATE [POMS_DB].dbo.[T_Import_Order_File_Source_Setup] SET [SELLER_KEY] = @SELLER_KEY, [FileSource_MTV_CODE] = @FileSource_MTV_CODE, [OrderSubSource_MTV_CODE] = @OrderSubSource_MTV_CODE, Code_MTV_CODE = @Code_MTV_CODE, CODE2 = @CODE2, [Description] = @Description, REFNO2 = @REFNO2, REFNO3 = REFNO3 ,IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE IOFSS_ID = @IOFSS_ID
		
		IF @OldSELLER_KEY <> @SELLER_KEY
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'SELLER_KEY' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldSELLER_KEY, @SELLER_KEY, @OldSELLER_KEY, @SELLER_KEY, '', 0, 167100, @Username
		END

		IF @OldFileSource_MTV_CODE <> @FileSource_MTV_CODE
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'FileSource_MTV_CODE' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldFileSource_MTV_CODE, @FileSource_MTV_CODE, @OldFileSource_MTV_CODE, @FileSource_MTV_CODE, '', 0, 167100, @Username
		END

		IF @OldOrderSubSource_MTV_CODE <> @OrderSubSource_MTV_CODE
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'OrderSubSource_MTV_CODE' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldOrderSubSource_MTV_CODE, @OrderSubSource_MTV_CODE, @OldOrderSubSource_MTV_CODE, @OrderSubSource_MTV_CODE, '', 0, 167100, @Username
		END

		IF @OldCode_MTV_CODE <> @Code_MTV_CODE
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'Code_MTV_CODE' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldCode_MTV_CODE, @Code_MTV_CODE, @OldCode_MTV_CODE, @Code_MTV_CODE, '', 0, 167100, @Username
		END

		IF @OldCODE2 <> @CODE2
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'CODE2' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldCODE2, @CODE2, @OldCODE2, @CODE2, '', 0, 167100, @Username
		END

		IF @OldDescription <> @Description
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'Description' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 167100, @Username
		END

		IF @OldREFNO1 <> @REFNO1
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'REFNO1' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldREFNO1, @REFNO1, @OldREFNO1, @REFNO1, '', 0, 167100, @Username
		END
		
		IF @OldREFNO2 <> @REFNO2
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'REFNO2' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldREFNO2, @REFNO2, @OldREFNO2, @REFNO2, '', 0, 167100, @Username
		END

		IF @OldREFNO3 <> @REFNO3
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'REFNO3' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldREFNO3, @REFNO3, @OldREFNO3, @REFNO3, '', 0, 167100, @Username
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].dbo.P_Add_Audit_History 'IsActive' ,'T_Import_Order_File_Source_Setup', @IOFSS_ID, 166143, @IOFSS_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @Username
		END		

		SET @Return_Text = 'Import Order File Source Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		INSERT INTO [POMS_DB].dbo.[T_Import_Order_File_Source_Setup] (SELLER_KEY, FileSource_MTV_CODE, OrderSubSource_MTV_CODE, Code_MTV_CODE, CODE2, [Description], REFNO1, REFNO2, REFNO3, IsActive, AddedBy, AddedOn) 
		VALUES (@SELLER_KEY, @FileSource_MTV_CODE, @OrderSubSource_MTV_CODE, @Code_MTV_CODE, @CODE2, @Description, @REFNO1, @REFNO2, @REFNO3, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Import Order File Source Added Successfully!'
		set @Return_Code = 1
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END


GO
