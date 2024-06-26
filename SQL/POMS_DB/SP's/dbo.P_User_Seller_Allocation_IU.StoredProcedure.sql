USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_User_Seller_Allocation_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [dbo].[P_User_Seller_Allocation_IU] 1 ,'ABDULLAH.ARSHAD', 1 ,1 ,'TAIMOOR>ALI'

CREATE PROC [dbo].[P_User_Seller_Allocation_IU]
@USAM_ID int
,@SellerUsername nvarchar(150)
,@SAL_ID int
,@IsActive bit
,@Username nvarchar(150)
,@IPAddress nvarchar(20) = ''

AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''
	set @USAM_ID = isnull(@USAM_ID,0)

	IF @USAM_ID > 0 
	BEGIN
		DECLARE @OldSellerUsername nvarchar(150)
		DECLARE @OldSAL_ID int
		DECLARE @OldIsActive BIT
		
		SELECT @OldSellerUsername = [USERNAME], @OldSAL_ID = [SAL_ID], @OldIsActive = IsActive FROM [POMS_DB].dbo.[T_User_Seller_Allocation_Mapping] usal WITH (NOLOCK) WHERE usal.USAM_ID = @USAM_ID
		
		UPDATE [POMS_DB].dbo.[T_User_Seller_Allocation_Mapping] SET [SAL_ID] = @SAL_ID, IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE USAM_ID = @USAM_ID
	

		IF @OldSAL_ID <> @SAL_ID
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'SAL_ID' ,'T_User_Seller_Allocation_Mapping', @USAM_ID, 166108, @USAM_ID, '', '', @OldSAL_ID, @SAL_ID, @OldSAL_ID, @SAL_ID, '', 0, 167100, @Username
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].dbo.P_Add_Audit_History 'IsActive' ,'T_User_Seller_Allocation_Mapping', @USAM_ID, 166108, @USAM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @Username
		END		

		SET @Return_Text = 'User Seller Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		INSERT INTO [POMS_DB].dbo.T_User_Seller_Allocation_Mapping ([USERNAME], [SAL_ID], IsActive, AddedBy) 
		VALUES (@SellerUsername, @SAL_ID, @IsActive, @Username)
		SET @Return_Text = 'User Seller Mapping Added Successfully!'
		set @Return_Code = 1
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
