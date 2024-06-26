USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_UserSellerToSubSellerMapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	EXEC P_AddOrEdit_UserSellerToSubSellerMapping 0 , 'HAMMAS.KHAN', 1, 1, 1, 1, 1, 1, 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_UserSellerToSubSellerMapping]
@USTSSM_ID INT = NULL,
@UName nvarchar(200) = '',
@SSM_ID int,
@IsViewOrder bit,
@IsCreateOrder bit,
@IsGetQuote bit,
@IsFinancial bit,
@IsActive bit,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''

AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @USTSSM_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_User_Seller_To_SubSeller_Mapping] WITH (NOLOCK) WHERE USTSSM_ID = @USTSSM_ID)
	BEGIN
	    
		DECLARE @OldUName nvarchar(200) 
		DECLARE @OldSSM_ID int
		DECLARE @OldIsViewOrder bit
		DECLARE @OldIsCreateOrder bit
		DECLARE @OldIsGetQuote bit
		DECLARE @OldIsFinancial bit
		DECLARE @OldIsActive bit
		
		SELECT @OldUName = UserName , @OldSSM_ID = SSM_ID, @OldIsViewOrder = IsViewOrder, @OldIsCreateOrder = IsCreateOrder, @OldIsGetQuote = IsGetQuote, @OldIsFinancial = IsFinancial, @OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_User_Seller_To_SubSeller_Mapping] WITH (NOLOCK) WHERE USTSSM_ID = @USTSSM_ID
		
		UPDATE [POMS_DB].[dbo].[T_User_Seller_To_SubSeller_Mapping] SET UserName = @UName, SSM_ID = @OldSSM_ID, IsViewOrder = @IsViewOrder, IsCreateOrder = @IsCreateOrder, IsGetQuote = @IsGetQuote, IsFinancial = @IsFinancial, IsActive = @IsActive, ModifiedBy = @Username , ModifiedOn = GETUTCDATE() WHERE USTSSM_ID = @USTSSM_ID

		IF @OldUName <> @UName
		BEGIN
			exec P_Add_Audit_History 'UserName' ,'T_User_Seller_To_SubSeller_Mapping', @USTSSM_ID, 166121, @USTSSM_ID, '', '', @OldUName, @UName, @OldUName, @UserName, '', 0, 167100, @UserName
		END

		IF @OldSSM_ID <> @SSM_ID
		BEGIN
			exec P_Add_Audit_History 'STM_ID' ,'T_User_Seller_To_SubSeller_Mapping', @USTSSM_ID, 166121, @USTSSM_ID, '', '', @OldSSM_ID, @SSM_ID, @OldSSM_ID, @SSM_ID, '', 0, 167100, @UserName
		END	

		IF @OldIsViewOrder <> @IsViewOrder
		BEGIN
			Declare @OldIsViewOrderText nvarchar(10) = (case when @OldIsViewOrder = 1 then 'Yes' else 'No' end)
			Declare @IsViewOrderText nvarchar(10) = (case when @IsViewOrder = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsViewOrder' ,'T_User_Seller_To_SubSeller_Mapping', @USTSSM_ID, 166121, @USTSSM_ID, '', '', @OldIsViewOrder, @IsViewOrder, @OldIsViewOrderText, @IsViewOrderText, '', 0, 167100, @UserName
		END	

		IF @OldIsCreateOrder <> @IsCreateOrder
		BEGIN
			Declare @OldIsCreateOrderText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsCreateOrderText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsCreatedOrder' ,'T_User_Seller_To_SubSeller_Mapping', @USTSSM_ID, 166121, @USTSSM_ID, '', '', @OldIsCreateOrder, @IsCreateOrder, @OldIsCreateOrderText, @IsCreateOrderText, '', 0, 167100, @UserName
		END	

		IF @OldIsGetQuote <> @IsGetQuote
		BEGIN
			Declare @OldIsGetQuoteText nvarchar(10) = (case when @OldIsGetQuote = 1 then 'Yes' else 'No' end)
			Declare @IsGetQuoteText nvarchar(10) = (case when @IsGetQuote = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsGetQuote' ,'T_User_Seller_To_SubSeller_Mapping', @USTSSM_ID, 166121, @USTSSM_ID, '', '', @OldIsGetQuote, @IsGetQuote, @OldIsGetQuoteText, @IsGetQuoteText, '', 0, 167100, @UserName
		END
		
		IF @OldIsFinancial <> @IsFinancial
		BEGIN
			Declare @OldIsFinancialText nvarchar(10) = (case when @OldIsFinancial = 1 then 'Yes' else 'No' end)
			Declare @IsFinancialText nvarchar(10) = (case when @IsFinancial = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsFinancial' ,'T_User_Seller_To_SubSeller_Mapping', @USTSSM_ID, 166121, @USTSSM_ID, '', '', @OldIsFinancial, @IsFinancial, @OldIsFinancialText, @IsFinancialText, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_User_Seller_To_SubSeller_Mapping', @USTSSM_ID, 166121, @USTSSM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'User Seller To SubSeller Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'User Seller To SubSeller Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @UName <> ''
	BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_User_Seller_To_SubSeller_Mapping] (UserName, SSM_ID ,IsViewOrder, IsCreateOrder ,IsGetQuote,IsFinancial, IsActive, AddedBy , AddedOn) VALUES (@UName, @SSM_ID ,@IsViewOrder, @IsCreateOrder ,@IsGetQuote,@IsFinancial,@IsActive, @Username ,GETUTCDATE())
		SET @Return_Text = 'User Seller To SubSeller Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE 
	BEGIN
		SET @Return_Text = 'User Seller To SubSeller Mapping does not exist!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
