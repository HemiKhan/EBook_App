USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_PageGroup]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_PageGroup 10,'Setting',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_PageGroup]
@PG_ID INT = NULL,
@PageGroupName nvarchar(50),
@IsHide BIT = 0,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @PG_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Page_Group] WITH (NOLOCK) WHERE PG_ID = @PG_ID)
	BEGIN
	    
		DECLARE @OldPageGroupName nvarchar(150)
		DECLARE @OldIsHide BIT
		DECLARE @OldActive BIT
		
		SELECT @OldPageGroupName = PageGroupName, @OldIsHide = IsHide, @OldActive = IsActive FROM [POMS_DB].[dbo].T_Page_Group WITH (NOLOCK) WHERE PG_ID = @PG_ID
		
		UPDATE [POMS_DB].[dbo].T_Page_Group SET PageGroupName = @PageGroupName, IsHide = @IsHide, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE PG_ID = @PG_ID

		IF @OldPageGroupName <> @PageGroupName
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'PageGroupName' ,'T_Page_Group', @PG_ID, 166100, @PG_ID, '', '', @OldPageGroupName, @PageGroupName, @OldPageGroupName, @PageGroupName, '', 0, 167100, @UserName
		END

		IF @OldIsHide <> @IsHide
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsHide = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsHide = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsHide' ,'T_Page_Group', @PG_ID, 166100, @PG_ID, '', '', @OldIsHide, @IsHide, @OldIsHideText, @IsHideText, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Page_Group', @PG_ID, 166100, @PG_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Page Group Name Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Page Group does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @PageGroupName <> '' BEGIN
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1, @PG_ID = ISNULL(MAX(PG_ID),0) + 1 FROM dbo.T_Page_Group WITH (NOLOCK)
		INSERT INTO [POMS_DB].[dbo].T_Page_Group (PG_ID, PageGroupName, Sort_, IsHide, IsActive, AddedBy, AddedOn) VALUES (@PG_ID, @PageGroupName, @maxSortValue, @IsHide, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Page Group Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Page Group Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
