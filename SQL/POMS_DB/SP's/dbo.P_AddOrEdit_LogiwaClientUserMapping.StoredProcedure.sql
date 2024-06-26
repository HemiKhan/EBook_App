USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_LogiwaClientUserMapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[P_AddOrEdit_LogiwaClientUserMapping]
@LCUM_ID INT,
@LC_ID INT,
@UName nvarchar(150),
@IsActive BIT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @LCUM_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].T_LogiwaClient WITH (NOLOCK) WHERE LC_ID = @LC_ID)
	BEGIN
	    

		DECLARE @OldLC_ID int
		DECLARE @OldUName nvarchar(150)
		DECLARE @OldIsActive BIT = 1

		SELECT @OldLC_ID = [LC_ID], @OldUName = [USERNAME], @OldIsActive = [IsActive] FROM [POMS_DB].[dbo].[T_Clients_Users_Mapping] WITH (NOLOCK) WHERE LCUM_ID = @LCUM_ID
		
		UPDATE [POMS_DB].[dbo].[T_Clients_Users_Mapping] SET LC_ID = @LC_ID , USERNAME = @UName , [IsActive] = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE LCUM_ID = @LCUM_ID

		IF @OldLC_ID <> @LC_ID
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'LC_ID' ,'T_Clients_Users_Mapping', @LCUM_ID, 166151, @LCUM_ID, '', '', @OldLC_ID, @LC_ID, @OldLC_ID, @LC_ID, '', 0, 167100, @UserName
		END

		IF @OldUName <> @UName
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'USERNAME' ,'T_Clients_Users_Mapping', @LCUM_ID, 166151, @LCUM_ID, '', '', @OldUName, @UName, @OldUName, @UName, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Clients_Users_Mapping', @LC_ID, 166151, @LC_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Logiwa Client User Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Logiwa Client User Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN

	INSERT INTO [POMS_DB].[dbo].[T_Clients_Users_Mapping] (LC_ID, USERNAME, IsActive,AddedBy, AddedOn) VALUES (@LC_ID, @UName, @IsActive ,@Username, GETUTCDATE())
	SET @Return_Text = 'Logiwa Client User Mapping Added Successfully!'
	SET @Return_Code = 1
	
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END

GO
