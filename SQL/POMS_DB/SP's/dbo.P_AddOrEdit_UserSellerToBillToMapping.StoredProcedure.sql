USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_UserSellerToBillToMapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_UserSellerToBillToMapping 0,'HAMMAS.KHAN', 1998, 1,1,1,1,1, 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_UserSellerToBillToMapping]
@USTSBM_ID int,
@UName nvarchar(200) = '',
@SBM_ID int,
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

IF @USTSBM_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_User_Seller_To_BillTo_Mapping] WITH (NOLOCK) WHERE USTSBM_ID = @USTSBM_ID)
	BEGIN
	    
		DECLARE @OldUName nvarchar(200) 
		DECLARE @OldSBM_ID int
		DECLARE @OldIsViewOrder bit
		DECLARE @OldIsCreateOrder bit
		DECLARE @OldIsGetQuote bit
		DECLARE @OldIsFinancial bit
		DECLARE @OldIsActive bit
		
		SELECT @OldUName = UserName , @OldSBM_ID = SBM_ID, @OldIsViewOrder = IsViewOrder, @OldIsCreateOrder = IsCreateOrder, @OldIsGetQuote = IsGetQuote, @OldIsFinancial = IsFinancial, @OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_User_Seller_To_BillTo_Mapping] WITH (NOLOCK) WHERE USTSBM_ID = @USTSBM_ID
		
		UPDATE [POMS_DB].[dbo].[T_User_Seller_To_BillTo_Mapping] SET UserName = @UName, SBM_ID = @SBM_ID, IsViewOrder = @IsViewOrder, IsCreateOrder = @IsCreateOrder, IsGetQuote = @IsGetQuote, IsFinancial = @IsFinancial, IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE USTSBM_ID = @USTSBM_ID

		IF @OldUName <> @UName
		BEGIN
			exec P_Add_Audit_History 'UserName' ,'T_User_Seller_To_BillTo_Mapping', @USTSBM_ID, 166119, @USTSBM_ID, '', '', @OldUName, @UName, @OldUName, @UserName, '', 0, 167100, @UserName
		END

		IF @OldSBM_ID <> @SBM_ID
		BEGIN
			exec P_Add_Audit_History 'SBM_ID' ,'T_User_Seller_To_BillTo_Mapping', @USTSBM_ID, 166119, @USTSBM_ID, '', '', @OldSBM_ID, @SBM_ID, @OldSBM_ID, @SBM_ID, '', 0, 167100, @UserName
		END	

		IF @OldIsViewOrder <> @IsViewOrder
		BEGIN
			Declare @OldIsViewOrderText nvarchar(10) = (case when @OldIsViewOrder = 1 then 'Yes' else 'No' end)
			Declare @IsViewOrderText nvarchar(10) = (case when @IsViewOrder = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsViewOrder' ,'T_User_Seller_To_BillTo_Mapping', @USTSBM_ID, 166119, @USTSBM_ID, '', '', @OldIsViewOrder, @IsViewOrder, @OldIsViewOrderText, @IsViewOrderText, '', 0, 167100, @UserName
		END	

		IF @OldIsCreateOrder <> @IsCreateOrder
		BEGIN
			Declare @OldIsCreateOrderText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsCreateOrderText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsCreatedOrder' ,'T_User_Seller_To_BillTo_Mapping', @USTSBM_ID, 166119, @USTSBM_ID, '', '', @OldIsCreateOrder, @IsCreateOrder, @OldIsCreateOrderText, @IsCreateOrderText, '', 0, 167100, @UserName
		END	

		IF @OldIsGetQuote <> @IsGetQuote
		BEGIN
			Declare @OldIsGetQuoteText nvarchar(10) = (case when @OldIsGetQuote = 1 then 'Yes' else 'No' end)
			Declare @IsGetQuoteText nvarchar(10) = (case when @IsGetQuote = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsGetQuote' ,'T_User_Seller_To_BillTo_Mapping', @USTSBM_ID, 166119, @USTSBM_ID, '', '', @OldIsGetQuote, @IsGetQuote, @OldIsGetQuoteText, @IsGetQuoteText, '', 0, 167100, @UserName
		END
		
		IF @OldIsFinancial <> @IsFinancial
		BEGIN
			Declare @OldIsFinancialText nvarchar(10) = (case when @OldIsFinancial = 1 then 'Yes' else 'No' end)
			Declare @IsFinancialText nvarchar(10) = (case when @IsFinancial = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsFinancial' ,'T_User_Seller_To_BillTo_Mapping', @USTSBM_ID, 166119, @USTSBM_ID, '', '', @OldIsFinancial, @IsFinancial, @OldIsFinancialText, @IsFinancialText, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_User_Seller_To_BillTo_Mapping', @USTSBM_ID, 166119, @USTSBM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'User Seller To BillTo Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'User Seller To BillTo Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @UName <> ''
	BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_User_Seller_To_BillTo_Mapping] (UserName, SBM_ID ,IsViewOrder, IsCreateOrder ,IsGetQuote,IsFinancial,IsActive, AddedBy , AddedOn) VALUES (@UName, @SBM_ID ,@IsViewOrder, @IsCreateOrder ,@IsGetQuote,@IsFinancial,@IsActive, @Username ,GETUTCDATE())
		SET @Return_Text = 'User Seller To BillTo Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE 
	BEGIN
		SET @Return_Text = 'User Seller To BillTo Mapping does not exist!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
