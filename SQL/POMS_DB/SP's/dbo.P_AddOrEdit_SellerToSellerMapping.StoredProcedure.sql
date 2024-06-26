USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_SellerToSellerMapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_PageGroup 10,'Setting',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_SellerToSellerMapping]
@STSM_ID INT = NULL,
@Parent_SELLER_KEY nvarchar(40),
@Child_SELLER_KEY nvarchar(40),
@IsViewOrder BIT,
@IsCreateOrder BIT,
@IsGetQuote BIT,
@IsFinancial BIT,
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @STSM_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Seller_To_Seller_Mapping] WITH (NOLOCK) WHERE STSM_ID = @STSM_ID)
	BEGIN
	    
		DECLARE @OldParent_SELLER_KEY nvarchar(40)
		DECLARE @OldChild_SELLER_KEY nvarchar(40)
		DECLARE @OldIsViewOrder BIT
		DECLARE @OldIsCreateOrder BIT
		DECLARE @OldIsGetQuote BIT
		DECLARE @OldIsFinancial BIT
		DECLARE @OldIsActive BIT


		SELECT @OldParent_SELLER_KEY = Parent_SELLER_KEY, @OldChild_SELLER_KEY = Child_SELLER_KEY, @OldIsViewOrder = IsViewOrder, @OldIsCreateOrder = IsCreateOrder, @OldIsGetQuote = IsGetQuote, @OldIsFinancial = IsFinancial ,@OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_Seller_To_Seller_Mapping] WITH (NOLOCK) WHERE STSM_ID = @STSM_ID
		
		UPDATE [POMS_DB].[dbo].[T_Seller_To_Seller_Mapping] SET Parent_SELLER_KEY = @Parent_SELLER_KEY, Child_SELLER_KEY = @Child_SELLER_KEY, IsViewOrder = @IsViewOrder, IsCreateOrder = @IsCreateOrder, IsGetQuote = @IsGetQuote, IsFinancial = @IsFinancial ,IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE STSM_ID = @STSM_ID

		IF @OldParent_SELLER_KEY <> @Parent_SELLER_KEY
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Parent_SELLER_KEY' ,'T_Seller_To_Seller_Mapping', @STSM_ID, 166130, @STSM_ID, '', '', @OldParent_SELLER_KEY, @Parent_SELLER_KEY, @OldParent_SELLER_KEY, @Parent_SELLER_KEY, '', 0, 167100, @UserName
		END

		IF @OldChild_SELLER_KEY <> @Child_SELLER_KEY
		BEGIN
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Child_SELLER_KEY' ,'T_Seller_To_Seller_Mapping', @STSM_ID, 166130, @STSM_ID, '', '', @OldChild_SELLER_KEY, @Child_SELLER_KEY, @OldChild_SELLER_KEY, @Child_SELLER_KEY, '', 0, 167100, @UserName
		END

		IF @OldIsViewOrder <> @IsViewOrder
		BEGIN
			Declare @OldIsViewOrderText nvarchar(10) = (case when @OldIsViewOrder = 1 then 'Yes' else 'No' end)
			Declare @IsViewOrderText nvarchar(10) = (case when @IsViewOrder = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsViewOrder' ,'T_Seller_To_Seller_Mapping', @STSM_ID, 166130, @STSM_ID, '', '', @OldIsViewOrder, @IsViewOrder, @OldIsViewOrderText, @IsViewOrderText, '', 0, 167100, @UserName
		END	

		IF @OldIsCreateOrder <> @IsCreateOrder
		BEGIN
			Declare @OldIsCreateOrderText nvarchar(10) = (case when @OldIsCreateOrder = 1 then 'Yes' else 'No' end)
			Declare @IsCreateOrderText nvarchar(10) = (case when @IsCreateOrder = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsCreateOrder' ,'T_Seller_To_Seller_Mapping', @STSM_ID, 166130, @STSM_ID, '', '', @OldIsCreateOrder, @IsCreateOrder, @OldIsCreateOrderText, @IsCreateOrderText, '', 0, 167100, @UserName
		END	

		IF @OldIsGetQuote <> @IsGetQuote
		BEGIN
			Declare @OldIsGetQuoteText nvarchar(10) = (case when @OldIsGetQuote = 1 then 'Yes' else 'No' end)
			Declare @IsGetQuoteText nvarchar(10) = (case when @IsGetQuote = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsGetQuote' ,'T_Seller_To_Seller_Mapping', @STSM_ID, 166130, @STSM_ID, '', '', @OldIsGetQuote, @IsGetQuote, @OldIsGetQuoteText, @IsGetQuoteText, '', 0, 167100, @UserName
		END	
		
		IF @OldIsFinancial <> @IsFinancial
		BEGIN
			Declare @OldIsFinancialText nvarchar(10) = (case when @OldIsFinancial = 1 then 'Yes' else 'No' end)
			Declare @IsFinancialText nvarchar(10) = (case when @IsFinancial = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsFinancial' ,'T_Seller_To_Seller_Mapping', @STSM_ID, 166130, @STSM_ID, '', '', @OldIsFinancial, @IsFinancial, @OldIsFinancialText, @IsFinancialText, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Seller_To_Seller_Mapping', @STSM_ID, 166130, @STSM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Seller To Seller Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Seller To Seller Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @Parent_SELLER_KEY <> '' BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_Seller_To_Seller_Mapping] (Parent_SELLER_KEY, Child_SELLER_KEY , IsViewOrder, IsCreateOrder, IsGetQuote, IsFinancial ,IsActive, AddedBy, AddedOn) VALUES ( @Parent_SELLER_KEY, @Child_SELLER_KEY, @IsViewOrder, @IsCreateOrder, @IsGetQuote, @IsFinancial ,@IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Seller To Seller Mapping Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Seller To Seller Mapping Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
