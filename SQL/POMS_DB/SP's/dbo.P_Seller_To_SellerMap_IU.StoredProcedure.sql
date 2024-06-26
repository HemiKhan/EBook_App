USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Seller_To_SellerMap_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [dbo].[P_Seller_Allocation_IU] 1 ,'Ecommerence abc1', 'Testing1' ,1 ,'ABDULLAH.ARSHAD'

Create PROC [dbo].[P_Seller_To_SellerMap_IU]
@SSAM_ID int
,@SAL_ID int
,@SELLER_CODE nvarchar(20)
,@IsActive bit
,@Username nvarchar(150)
,@IPAddress nvarchar(20) = ''

AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''
	set @SSAM_ID = isnull(@SSAM_ID,0)

	IF @SSAM_ID > 0 
	BEGIN
		DECLARE @OldSAL_ID int
		DECLARE @OldSELLER_CODE nvarchar(20)
		DECLARE @OldIsActive BIT
		
		SELECT @OldSAL_ID = [SAL_ID], @OldSELLER_CODE = [SELLER_CODE], @OldIsActive = IsActive FROM [POMS_DB].dbo.[T_Seller_To_Seller_Allocation_Mapping] salm WITH (NOLOCK) WHERE salm.SSAM_ID = @SSAM_ID
		
		UPDATE [POMS_DB].dbo.[T_Seller_To_Seller_Allocation_Mapping] SET [SAL_ID] = @SAL_ID, [SELLER_CODE] = @SELLER_CODE, IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE SSAM_ID = @SSAM_ID
		
		IF @OldSAL_ID <> @SAL_ID
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'SAL_ID' ,'T_Seller_To_Seller_Allocation_Mapping', @SAL_ID, 166107, @SSAM_ID, '', '', @OldSAL_ID, @SAL_ID, @OldSAL_ID, @SAL_ID, '', 0, 167100, @Username
		END

		IF @OldSELLER_CODE <> @SELLER_CODE
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'SELLER_CODE' ,'T_Seller_To_Seller_Allocation_Mapping', @SAL_ID, 166107, @SSAM_ID, '', '', @OldSELLER_CODE, @SELLER_CODE, @OldSELLER_CODE, @SELLER_CODE, '', 0, 167100, @Username
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].dbo.P_Add_Audit_History 'IsActive' ,'T_Seller_To_Seller_Allocation_Mapping', @SAL_ID, 166107, @SSAM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @Username
		END		

		SET @Return_Text = 'Seller To Seller Allocation_Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		INSERT INTO [POMS_DB].dbo.[T_Seller_To_Seller_Allocation_Mapping] (SAL_ID, SELLER_CODE, IsActive, AddedBy) 
		VALUES (@SAL_ID, @SELLER_CODE, @IsActive, @Username)
		SET @Return_Text = 'Seller To Seller Allocation_Mapping Added Successfully!'
		set @Return_Code = 1
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
