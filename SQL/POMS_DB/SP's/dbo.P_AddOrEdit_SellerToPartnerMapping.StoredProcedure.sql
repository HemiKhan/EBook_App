USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_SellerToPartnerMapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC [P_AddOrEdit_SellerToPartnerMapping] 10,'Setting',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_SellerToPartnerMapping]
@SPM_ID INT = NULL,
@SELLER_KEY nvarchar(40),
@SELLER_PARTNER_KEY nvarchar(40),
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @SPM_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Seller_Partner_Mapping] WITH (NOLOCK) WHERE SPM_ID = @SPM_ID)
	BEGIN
	    
		DECLARE @OldSELLER_KEY nvarchar(40)
		DECLARE @OldSELLER_PARTNER_KEY nvarchar(40)
		DECLARE @OldIsActive BIT


		SELECT @OldSELLER_KEY = SELLER_KEY, @OldSELLER_PARTNER_KEY = SELLER_PARTNER_KEY ,@OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_Seller_Partner_Mapping] WITH (NOLOCK) WHERE SPM_ID = @SPM_ID
		
		UPDATE [POMS_DB].[dbo].[T_Seller_Partner_Mapping] SET SELLER_KEY = @SELLER_KEY, SELLER_PARTNER_KEY = @SELLER_PARTNER_KEY, IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE SPM_ID = @SPM_ID

		IF @OldSELLER_PARTNER_KEY <> @SELLER_PARTNER_KEY
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'SELLER_PARTNER_KEY' ,'T_Seller_Partner_Mapping', @SPM_ID, 166132, @SPM_ID, '', '', @OldSELLER_PARTNER_KEY, @SELLER_PARTNER_KEY, @OldSELLER_PARTNER_KEY, @SELLER_PARTNER_KEY, '', 0, 167100, @UserName
		END

		IF @OldSELLER_KEY <> @SELLER_KEY
		BEGIN
			exec [POMS_DB].[dbo].P_Add_Audit_History 'SELLER_KEY' ,'T_Seller_Partner_Mapping', @SPM_ID, 166132, @SPM_ID, '', '', @OldSELLER_KEY, @SELLER_KEY, @OldSELLER_KEY, @SELLER_KEY, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Seller_Partner_Mapping', @SPM_ID, 166132, @SPM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Seller To Partner Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Seller To Partner Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @SELLER_KEY <> '' BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_Seller_Partner_Mapping] (SELLER_KEY, SELLER_PARTNER_KEY ,IsActive, AddedBy, AddedOn) VALUES ( @SELLER_KEY, @SELLER_PARTNER_KEY ,@IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Seller To Partner Mapping Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Seller To Partner Mapping Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
