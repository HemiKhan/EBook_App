USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_LogiwaClient]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[P_AddOrEdit_LogiwaClient]
@LC_ID INT,
@CUSTOMER_KEY nvarchar(36),
@SELLER_KEY nvarchar(36),
@Logiwa_Name nvarchar(50),
@Logiwa_ID int,
@Logiwa_OrderType nvarchar(50),
@IsActive BIT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

	SELECT @SELLER_KEY = SELLER_KEY FROM [POMS_DB].[dbo].[T_Seller_BillTo_Mapping] WITH (NOLOCK) WHERE BillTo_CUSTOMER_KEY = @CUSTOMER_KEY

IF @LC_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].T_LogiwaClient WITH (NOLOCK) WHERE LC_ID = @LC_ID)
	BEGIN
	    

		DECLARE @OldCUSTOMER_NO nvarchar(36)
		DECLARE @OldSELLER_CODE nvarchar(36)
		DECLARE @OldLogiwa_Name nvarchar(50)
		DECLARE @OldLogiwa_ID int
		DECLARE @OldLogiwa_OrderType nvarchar(50)
		DECLARE @OldIsActive BIT = 1

		SELECT @OldCUSTOMER_NO = [CUSTOMER_KEY] , @OldSELLER_CODE = [SELLER_KEY],  @OldLogiwa_Name = [Logiwa_Name], @OldLogiwa_ID = [Logiwa_ID], @OldLogiwa_OrderType = [Logiwa_OrderType], @OldIsActive = [IsActive] FROM [POMS_DB].[dbo].T_LogiwaClient WITH (NOLOCK) WHERE LC_ID = @LC_ID
		
		UPDATE [POMS_DB].[dbo].T_LogiwaClient SET [CUSTOMER_KEY] = @CUSTOMER_KEY, [SELLER_KEY] = @SELLER_KEY, [Logiwa_Name] = @Logiwa_Name, [Logiwa_ID] = @Logiwa_ID, [Logiwa_OrderType] = @Logiwa_OrderType, [IsActive] = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE LC_ID = @LC_ID

		IF @OldCUSTOMER_NO <> @CUSTOMER_KEY
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'CUSTOMER_NO' ,'T_LogiwaClient', @LC_ID, 166150, @LC_ID, '', '', @OldCUSTOMER_NO, @CUSTOMER_KEY, @OldCUSTOMER_NO, @CUSTOMER_KEY, '', 0, 167100, @UserName
		END

		IF @OldSELLER_CODE <> @SELLER_KEY
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'SELLER_CODE' ,'T_LogiwaClient', @LC_ID, 166150, @LC_ID, '', '', @OldSELLER_CODE, @SELLER_KEY, @OldSELLER_CODE, @SELLER_KEY, '', 0, 167100, @UserName
		END

		IF @OldLogiwa_Name <> @Logiwa_Name
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Logiwa_Name' ,'T_LogiwaClient', @LC_ID, 166150, @LC_ID, '', '', @OldLogiwa_Name, @Logiwa_Name, @OldLogiwa_Name, @Logiwa_Name, '', 0, 167100, @UserName
		END

		IF @OldLogiwa_ID <> @Logiwa_ID
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Logiwa_ID' ,'T_LogiwaClient', @LC_ID, 166150, @LC_ID, '', '', @OldLogiwa_ID, @Logiwa_ID, @OldLogiwa_ID, @Logiwa_ID, '', 0, 167100, @UserName
		END

		IF @OldLogiwa_OrderType <> @Logiwa_OrderType
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Logiwa_OrderType' ,'T_LogiwaClient', @LC_ID, 166150, @LC_ID, '', '', @OldLogiwa_OrderType, @Logiwa_OrderType, @OldLogiwa_OrderType, @Logiwa_OrderType, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_LogiwaClient', @LC_ID, 166150, @LC_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Logiwa Client Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Logiwa Client does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN

	INSERT INTO [POMS_DB].[dbo].T_LogiwaClient (CUSTOMER_KEY, SELLER_KEY, [Logiwa_Name], [Logiwa_ID], [Logiwa_OrderType], IsActive,AddedBy, AddedOn) VALUES (@CUSTOMER_KEY, @SELLER_KEY, @Logiwa_Name, @Logiwa_ID, @Logiwa_OrderType,@IsActive ,@Username, GETUTCDATE())
	SET @Return_Text = 'Logiwa Client Added Successfully!'
	SET @Return_Code = 1
	
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END

GO
