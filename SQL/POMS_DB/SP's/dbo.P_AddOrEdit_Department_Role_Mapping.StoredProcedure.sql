USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Department_Role_Mapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--						EXEC P_AddOrEdit_Department_Role_Mapping 'Test','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Department_Role_Mapping]
@DepartmentRoleMappingID INT = NULL,
@RoleID INT,
@DepartmentID INT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @DepartmentRoleMappingID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].T_Department_Role_Mapping WHERE DRM_ID = @DepartmentRoleMappingID)
	BEGIN
	    
		DECLARE @OldR_ID INT
		DECLARE @OldD_ID INT
		DECLARE @OldActive BIT

		SELECT @OldR_ID = R_ID, @OldD_ID = @DepartmentID, @OldActive = IsActive FROM [POMS_DB].[dbo].T_Department_Role_Mapping WHERE DRM_ID = @DepartmentRoleMappingID
		
		UPDATE [POMS_DB].[dbo].T_Department_Role_Mapping SET R_ID = @RoleID, D_ID = @DepartmentID, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE DRM_ID = @DepartmentRoleMappingID
		
		IF @OldR_ID <> @RoleID
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'R_ID' ,'T_Department_Role_Mapping', @DepartmentID, 166116, @DepartmentRoleMappingID, '', '', @OldR_ID, @RoleID, @OldR_ID, @RoleID, '', 0, 167100, @UserName
		END

		IF @OldD_ID <> @DepartmentID
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'D_ID' ,'T_Department_Role_Mapping', @DepartmentID, 166116, @DepartmentRoleMappingID, '', '', @OldD_ID, @DepartmentID, @OldD_ID, @DepartmentID, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Department_Role_Mapping', @DepartmentID, 166116, @DepartmentRoleMappingID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Department Role Mapping Name Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Department Role Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @RoleID > 0 AND @DepartmentID > 0 BEGIN
		INSERT INTO [POMS_DB].[dbo].T_Department_Role_Mapping (R_ID, D_ID, IsActive, AddedBy, AddedOn) VALUES (@RoleID, @DepartmentID, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Department Role Mapping Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Department Role Mapping Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
