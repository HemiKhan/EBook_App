USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_UserToSellerMapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--				EXEC P_AddOrEdit_UserToSellerMapping 1, 'HAMMAS.KHAN', 101001, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_UserToSellerMapping]
@UTSM_ID INT = NULL,
@UName nvarchar(200) = '',
@SELLER_ID int,
@IsViewOrder bit,
@IsCreateOrder bit,
@IsGetQuote bit,
@IsFinancial bit,
@IsAdmin bit,
@IsBlankSubSellerAllowed bit,
@IsAllSubSellerAllowed bit,
@IsBlankPartnerAllowed bit,
@IsAllPartnerAllowed bit,
@IsBlankTariffAllowed bit,
@IsAllTariffAllowed bit,
@IsActive bit,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''

AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @UTSM_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_User_To_Seller_Mapping] WITH (NOLOCK) WHERE UTSM_ID = @UTSM_ID)
	BEGIN
	    
		DECLARE @OldUName nvarchar(200) 
		DECLARE @OldSELLER_ID int
		DECLARE @OldIsViewOrder bit
		DECLARE @OldIsCreateOrder bit
		DECLARE @OldIsGetQuote bit
		DECLARE @OldIsFinancial bit
		DECLARE @OldIsAdmin bit
		DECLARE	@OldIsBlankSubSellerAllowed bit
		DECLARE @OldIsAllSubSellerAllowed bit
		DECLARE @OldIsBlankPartnerAllowed bit
		DECLARE @OldIsAllPartnerAllowed bit
		DECLARE @OldIsBlankTariffAllowed bit
		DECLARE @OldIsAllTariffAllowed bit
		DECLARE @OldIsActive bit
		
		SELECT @OldUName = UserName , @OldSELLER_ID = SELLER_ID, @OldIsViewOrder = IsViewOrder, @OldIsCreateOrder = IsCreateOrder, @OldIsGetQuote = IsGetQuote, @OldIsFinancial = IsFinancial, @OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_User_To_Seller_Mapping] WITH (NOLOCK) WHERE UTSM_ID = @UTSM_ID
		
		UPDATE [POMS_DB].[dbo].[T_User_To_Seller_Mapping] SET UserName = @UName, SELLER_ID = @OldSELLER_ID, IsViewOrder = @IsViewOrder, IsCreateOrder = @IsCreateOrder, IsGetQuote = @IsGetQuote, IsFinancial = @IsFinancial, IsActive = @IsActive, ModifiedBy = @Username , ModifiedOn = GETUTCDATE() WHERE UTSM_ID = @UTSM_ID

		IF @OldUName <> @UName
		BEGIN
			exec P_Add_Audit_History 'UserName' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldUName, @UName, @OldUName, @UserName, '', 0, 167100, @UserName
		END

		IF @OldSELLER_ID <> @SELLER_ID
		BEGIN
			exec P_Add_Audit_History 'SELLER_ID' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldSELLER_ID, @SELLER_ID, @OldSELLER_ID, @SELLER_ID, '', 0, 167100, @UserName
		END	

		IF @OldIsViewOrder <> @IsViewOrder
		BEGIN
			Declare @OldIsViewOrderText nvarchar(10) = (case when @OldIsViewOrder = 1 then 'Yes' else 'No' end)
			Declare @IsViewOrderText nvarchar(10) = (case when @IsViewOrder = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsViewOrder' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsViewOrder, @IsViewOrder, @OldIsViewOrderText, @IsViewOrderText, '', 0, 167100, @UserName
		END	

		IF @OldIsCreateOrder <> @IsCreateOrder
		BEGIN
			Declare @OldIsCreateOrderText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsCreateOrderText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsCreatedOrder' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsCreateOrder, @IsCreateOrder, @OldIsCreateOrderText, @IsCreateOrderText, '', 0, 167100, @UserName
		END	

		IF @OldIsGetQuote <> @IsGetQuote
		BEGIN
			Declare @OldIsGetQuoteText nvarchar(10) = (case when @OldIsGetQuote = 1 then 'Yes' else 'No' end)
			Declare @IsGetQuoteText nvarchar(10) = (case when @IsGetQuote = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsGetQuote' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsGetQuote, @IsGetQuote, @OldIsGetQuoteText, @IsGetQuoteText, '', 0, 167100, @UserName
		END
		
		IF @OldIsFinancial <> @IsFinancial
		BEGIN
			Declare @OldIsFinancialText nvarchar(10) = (case when @OldIsFinancial = 1 then 'Yes' else 'No' end)
			Declare @IsFinancialText nvarchar(10) = (case when @IsFinancial = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsFinancial' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsFinancial, @IsFinancial, @OldIsFinancialText, @IsFinancialText, '', 0, 167100, @UserName
		END

		IF @OldIsAdmin <> @IsAdmin
		BEGIN
			Declare @OldIsAdminText nvarchar(10) = (case when @OldIsAdmin = 1 then 'Yes' else 'No' end)
			Declare @IsAdminText nvarchar(10) = (case when @IsAdmin = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsAdmin' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsAdmin, @IsAdmin, @OldIsAdminText, @IsAdminText, '', 0, 167100, @UserName
		END

		IF @OldIsBlankSubSellerAllowed <> @IsBlankSubSellerAllowed
		BEGIN
			Declare @OldIsBlankSubSellerAllowedText nvarchar(10) = (case when @OldIsBlankSubSellerAllowed = 1 then 'Yes' else 'No' end)
			Declare @IsBlankSubSellerAllowedText nvarchar(10) = (case when @IsBlankSubSellerAllowed = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsBlankSubSellerAllowed' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsBlankSubSellerAllowed, @IsBlankSubSellerAllowed, @OldIsBlankSubSellerAllowedText, @IsBlankSubSellerAllowedText, '', 0, 167100, @UserName
		END

		IF @OldIsAllSubSellerAllowed <> @IsAllSubSellerAllowed
		BEGIN
			Declare @OldIsAllSubSellerAllowedText nvarchar(10) = (case when @OldIsAllSubSellerAllowed = 1 then 'Yes' else 'No' end)
			Declare @IsAllSubSellerAllowedText nvarchar(10) = (case when @IsAllSubSellerAllowed = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsAllSubSellerAllowed' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsAllSubSellerAllowed, @IsAllSubSellerAllowed, @OldIsAllSubSellerAllowedText, @IsAllSubSellerAllowedText, '', 0, 167100, @UserName
		END

		IF @OldIsBlankPartnerAllowed <> @IsBlankPartnerAllowed
		BEGIN
			Declare @OldIsBlankPartnerAllowedText nvarchar(10) = (case when @OldIsBlankPartnerAllowed = 1 then 'Yes' else 'No' end)
			Declare @IsBlankPartnerAllowedText nvarchar(10) = (case when @OldIsBlankPartnerAllowed = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsBlankPartnerAllowed' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsBlankPartnerAllowed, @IsBlankPartnerAllowed, @OldIsBlankPartnerAllowedText, @IsBlankPartnerAllowedText, '', 0, 167100, @UserName
		END

		IF @OldIsAllPartnerAllowed <> @IsAllPartnerAllowed
		BEGIN
			Declare @OldIsAllPartnerAllowedText nvarchar(10) = (case when @OldIsAllPartnerAllowed = 1 then 'Yes' else 'No' end)
			Declare @IsAllPartnerAllowedText nvarchar(10) = (case when @IsAllPartnerAllowed = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsAllPartnerAllowed' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsAllPartnerAllowed, @IsAllPartnerAllowed, @OldIsAllPartnerAllowedText, @IsAllPartnerAllowedText, '', 0, 167100, @UserName
		END

		IF @OldIsBlankTariffAllowed <> @IsBlankTariffAllowed
		BEGIN
			Declare @OldIsBlankTariffAllowedText nvarchar(10) = (case when @OldIsBlankTariffAllowed = 1 then 'Yes' else 'No' end)
			Declare @IsBlankTariffAllowedText nvarchar(10) = (case when @IsBlankTariffAllowed = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsBlankTariffAllowed' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsBlankTariffAllowed, @IsBlankTariffAllowed, @OldIsBlankTariffAllowedText, @IsBlankTariffAllowedText, '', 0, 167100, @UserName
		END

		IF @OldIsAllTariffAllowed <> @IsAllTariffAllowed
		BEGIN
			Declare @OldIsAllTariffAllowedText nvarchar(10) = (case when @OldIsAllTariffAllowed = 1 then 'Yes' else 'No' end)
			Declare @IsAllTariffAllowedText nvarchar(10) = (case when @IsAllTariffAllowed = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsAllTariffAllowed' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsAllTariffAllowed, @IsAllTariffAllowed, @OldIsAllTariffAllowedText, @IsAllTariffAllowedText, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_User_To_Seller_Mapping', @UTSM_ID, 166118, @UTSM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'User to Seller Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'User to Seller Mapping Records does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @UName <> ''
	BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_User_To_Seller_Mapping] (UserName, SELLER_ID ,IsViewOrder, IsCreateOrder ,IsGetQuote,IsFinancial, IsAdmin, IsBlankSubSellerAllowed,IsAllSubSellerAllowed,IsBlankPartnerAllowed,IsAllPartnerAllowed,IsBlankTariffAllowed,IsAllTariffAllowed, IsActive, AddedBy , AddedOn) VALUES (@UName, @SELLER_ID ,@IsViewOrder, @IsCreateOrder ,@IsGetQuote,@IsFinancial,@IsAdmin, @IsBlankSubSellerAllowed,@IsAllSubSellerAllowed,@IsBlankPartnerAllowed,@IsAllPartnerAllowed,@IsBlankTariffAllowed,@IsAllTariffAllowed,@IsActive, @Username ,GETUTCDATE())
		SET @Return_Text = 'User to Seller Mapping Inserted Successfully!'
		SET @Return_Code = 1
	END
	ELSE 
	BEGIN
		SET @Return_Text = 'User to Seller Mapping Records does not exist!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
