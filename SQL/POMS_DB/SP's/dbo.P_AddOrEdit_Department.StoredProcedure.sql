USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Department]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--							EXEC [P_AddOrEdit_Department] 1,'All 1',1,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Department]
@D_ID INT = NULL,
@DepartmentName nvarchar(150),
@IsHidden BIT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @D_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Department] WITH (NOLOCK) WHERE D_ID = @D_ID)
	BEGIN
	    
		DECLARE @OldDepartmentName nvarchar(150)
		DECLARE @OldIsHide BIT
		DECLARE @OldActive BIT
		
		SELECT @OldDepartmentName = DepartmentName, @OldIsHide = IsHidden, @OldActive = IsActive FROM [POMS_DB].[dbo].[T_Department] WITH (NOLOCK) WHERE D_ID = @D_ID
		
		UPDATE [POMS_DB].[dbo].[T_Department] SET DepartmentName = @DepartmentName, IsHidden = @IsHidden, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE D_ID = @D_ID
		
		IF @OldDepartmentName <> @DepartmentName
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'DepartmentName' ,'T_Department', @D_ID, 166113, @D_ID, '', '', @OldDepartmentName, @DepartmentName, @OldDepartmentName, @DepartmentName, '', 0, 167100, @Username
		END

		IF @OldIsHide <> @IsHidden
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsHide = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsHidden = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsHidden' ,'T_Department', @D_ID, 166113, @D_ID, '', '', @OldIsHide, @IsHidden, @OldIsHideText, @IsHideText, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Department', @D_ID, 166113, @D_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END		

		SET @Return_Text = 'Department Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Department does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @DepartmentName <> '' BEGIN
		DECLARE @maxSortValue INT
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [POMS_DB].[dbo].[T_Department] WITH (NOLOCK)
		INSERT INTO [POMS_DB].[dbo].[T_Department] (DepartmentName, Sort_, IsHidden, IsActive, AddedBy, AddedOn) VALUES (@DepartmentName, @maxSortValue, @IsHidden, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Department Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Department Not Found!'
		set @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
