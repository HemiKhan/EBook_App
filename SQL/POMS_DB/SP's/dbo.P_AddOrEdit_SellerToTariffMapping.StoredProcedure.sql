USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_SellerToTariffMapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_PageGroup 10,'Setting',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_SellerToTariffMapping]
@STM_ID INT = NULL,
@SELLER_KEY nvarchar(40),
@TARIFF_NO nvarchar(40),
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @STM_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Seller_Tariff_Mapping] WITH (NOLOCK) WHERE STM_ID = @STM_ID)
	BEGIN
	    
		DECLARE @OldSELLER_KEY nvarchar(40)
		DECLARE @OldTARIFF_NO nvarchar(40)
		DECLARE @OldIsActive BIT


		SELECT @OldSELLER_KEY = SELLER_KEY, @OldTARIFF_NO = TARIFF_NO ,@OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_Seller_Tariff_Mapping] WITH (NOLOCK) WHERE STM_ID = @STM_ID
		
		UPDATE [POMS_DB].[dbo].[T_Seller_Tariff_Mapping] SET SELLER_KEY = @SELLER_KEY, TARIFF_NO = @TARIFF_NO, IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE STM_ID = @STM_ID

		IF @OldTARIFF_NO <> @TARIFF_NO
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'TARIFF_NO' ,'T_Seller_Tariff_Mapping', @STM_ID, 166134, @STM_ID, '', '', @OldTARIFF_NO, @TARIFF_NO, @OldTARIFF_NO, @TARIFF_NO, '', 0, 167100, @UserName
		END

		IF @OldSELLER_KEY <> @SELLER_KEY
		BEGIN
			exec [POMS_DB].[dbo].P_Add_Audit_History 'SELLER_KEY' ,'T_Seller_Tariff_Mapping', @STM_ID, 166134, @STM_ID, '', '', @OldSELLER_KEY, @SELLER_KEY, @OldSELLER_KEY, @SELLER_KEY, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Seller_Tariff_Mapping', @STM_ID, 166134, @STM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Seller To Tariff Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Seller To Tariff Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @SELLER_KEY <> '' BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_Seller_Tariff_Mapping] (SELLER_KEY, TARIFF_NO ,IsActive, AddedBy, AddedOn) VALUES ( @SELLER_KEY, @TARIFF_NO,@IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Seller To Tariff Mapping Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Seller To Tariff Mapping Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
