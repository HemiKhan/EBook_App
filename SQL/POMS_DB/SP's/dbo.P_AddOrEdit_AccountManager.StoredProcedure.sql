USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_AccountManager]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--						EXEC P_AddOrEdit_AccountManager 0, 'ABDULLAH.ARSHAD', 1, 'MUSA.RAZA', ''
CREATE PROC [dbo].[P_AddOrEdit_AccountManager]
@AML_ID INT = NULL,
@UNAME nvarchar(150),
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = Null
AS
BEGIN
	DECLARE @maxSortValue INT
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @AML_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Account_Manager_List] WHERE AML_ID = @AML_ID)
	BEGIN
	    
		DECLARE @OldAML_ID nvarchar(150)
		DECLARE @OldUSERNAME nvarchar(250)
		DECLARE @OldActive BIT

		SELECT @OldUSERNAME = USERNAME, @OldActive = IsActive FROM [POMS_DB].[dbo].[T_Account_Manager_List] WHERE AML_ID = @AML_ID
		
		UPDATE [POMS_DB].[dbo].[T_Account_Manager_List] SET USERNAME = @UNAME, IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE AML_ID = @AML_ID
		
		IF @OldUSERNAME <> @UNAME
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'USERNAME' ,'T_Account_Manager_List', @AML_ID, 166146, @AML_ID, '', '', @OldUSERNAME, @UNAME, @OldUSERNAME, @UNAME, '', 0, 167100, @UserName
		END


		IF @OldActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Account_Manager_List', @AML_ID, 166146, @AML_ID, '', '', @OldActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'Account Manager List Updated Successfully!'
		SET @Return_Code = 1

	END
	ELSE
	BEGIN
		SET @Return_Text = 'Account Manager List does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @UNAME <> '' 
	BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_Account_Manager_List] (USERNAME, IsActive, AddedBy, AddedOn) VALUES (@UNAME, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Account Manager List Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Account Manager List Not Found!'
		set @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
