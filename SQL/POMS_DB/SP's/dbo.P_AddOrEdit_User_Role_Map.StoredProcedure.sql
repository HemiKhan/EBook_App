USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_User_Role_Map]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--							EXEC P_AddOrEdit_User_Role_Map 0,2,'ABDULLAH.ARSHAD',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_User_Role_Map]
@URM_ID INT = NULL,
@R_ID INT,
@UNAME nvarchar(150),
@IsGroupRoleID BIT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @URM_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_User_Role_Mapping] WITH (NOLOCK) WHERE URM_ID = @URM_ID)
	BEGIN
	    
		DECLARE @OldR_ID INT
		DECLARE @OldUNAME nvarchar(150)
		DECLARE @OldIsGroupRoleID BIT
		DECLARE @OldActive BIT
		
		SELECT @OldR_ID = ROLE_ID, @OldUNAME = USERNAME, @OldIsGroupRoleID = IsGroupRoleID, @OldActive = IsActive FROM [POMS_DB].[dbo].[T_User_Role_Mapping] WITH (NOLOCK) WHERE URM_ID = @URM_ID
		
		UPDATE [POMS_DB].[dbo].[T_User_Role_Mapping] SET ROLE_ID = @R_ID, USERNAME = @UNAME, IsGroupRoleID = @IsGroupRoleID, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE URM_ID = @URM_ID
		
		IF @OldR_ID <> @R_ID
		BEGIN	
			exec P_Add_Audit_History 'ROLE_ID' ,'T_User_Role_Mapping', @R_ID, 166105, @URM_ID, '', '', @OldR_ID, @R_ID, @OldR_ID, @R_ID, '', 0, 107100, @UserName
		END

		IF @OldUNAME <> @UNAME
		BEGIN	
			exec P_Add_Audit_History 'USERNAME' ,'T_User_Role_Mapping', @R_ID, 166105, @URM_ID, '', '', @OldUNAME, @UNAME, @OldUNAME, @UNAME, '', 0, 107100, @UserName
		END

		IF @OldIsGroupRoleID <> @IsGroupRoleID
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsGroupRoleID = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsGroupRoleID = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsRightActive' ,'T_User_Role_Mapping', @R_ID, 166105, @URM_ID, '', '', @OldIsGroupRoleID, @IsGroupRoleID, @OldIsHideText, @IsHideText, '', 0, 107100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_User_Role_Mapping', @R_ID, 166105, @URM_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 107100, @UserName
		END		

		SET @Return_Text = 'User Role Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'User Role Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @R_ID > 0 AND @UNAME <> '' BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_User_Role_Mapping] (ROLE_ID, USERNAME, IsGroupRoleID, IsActive, AddedBy, AddedOn) VALUES (@R_ID, @UNAME, @IsGroupRoleID, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'User Role Mapping Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'User Role Mapping Not Found!'
		set @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
