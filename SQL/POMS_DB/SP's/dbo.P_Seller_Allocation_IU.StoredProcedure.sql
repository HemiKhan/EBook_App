USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Seller_Allocation_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [dbo].[P_Seller_Allocation_IU] 1 ,'Ecommerence abc1', 'Testing1' ,1 ,'ABDULLAH.ARSHAD'

CREATE PROC [dbo].[P_Seller_Allocation_IU]
@SAL_ID int
,@Name nvarchar(150)
,@Description nvarchar(500)
,@AML_ID int
,@IsActive bit
,@Username nvarchar(150)
,@IPAddress nvarchar(20) = ''

AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''
	set @SAL_ID = isnull(@SAL_ID,0)

	IF @SAL_ID > 0 
	BEGIN
		DECLARE @OldName nvarchar(150)
		DECLARE @OldDescription nvarchar(500)
		DECLARE @OldAML_ID int
		DECLARE @OldIsActive BIT
		
		SELECT @OldName = [Name], @OldDescription = [Description], @OldAML_ID = AML_ID ,@OldIsActive = IsActive FROM [POMS_DB].dbo.[T_Seller_Allocation_List] sal WITH (NOLOCK) WHERE sal.SAL_ID = @SAL_ID
		
		UPDATE [POMS_DB].dbo.[T_Seller_Allocation_List] SET [Name] = @Name, [Description] = @Description, AML_ID = @AML_ID , IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE SAL_ID = @SAL_ID
		
		IF @OldName <> @Name
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'Name' ,'T_Seller_Allocation_List', @SAL_ID, 166106, @SAL_ID, '', '', @OldName, @Name, @OldName, @Name, '', 0, 167100, @Username
		END

		IF @OldDescription <> @Description
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'Description' ,'T_Seller_Allocation_List', @SAL_ID, 166106, @SAL_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 167100, @Username
		END

		IF @OldAML_ID <> @AML_ID
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'AML_ID' ,'T_Seller_Allocation_List', @SAL_ID, 166106, @SAL_ID, '', '', @OldAML_ID, @AML_ID, @OldAML_ID, @AML_ID, '', 0, 167100, @Username
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].dbo.P_Add_Audit_History 'IsActive' ,'T_Seller_Allocation_List', @SAL_ID, 166106, @SAL_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @Username
		END		

		SET @Return_Text = 'Seller Allocation Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		INSERT INTO [POMS_DB].dbo.[T_Seller_Allocation_List] ([Name], [Description], AML_ID ,IsActive, AddedBy) 
		VALUES (@Name, @Description, @AML_ID ,@IsActive, @Username)
		SET @Return_Text = 'Seller Allocation Added Successfully!'
		set @Return_Code = 1
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
