USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_MasterType]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--							EXEC [P_AddOrEdit_MasterType] 103,'Billing Type 1','',1,'HAMMAS.KHAN',''
CREATE PROC [dbo].[P_AddOrEdit_MasterType]
@MT_ID INT = NULL,
@MasterTypeName nvarchar(50),
@Description nvarchar(150) = '',
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @MT_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Master_Type] with (nolock) WHERE MT_ID = @MT_ID)
	BEGIN
	    
		DECLARE @OldMasterTypeName nvarchar(150)
		DECLARE @OldDescription nvarchar(250)
		DECLARE @OldActive BIT

		SELECT @OldMasterTypeName = Name, @OldDescription = Description, @OldActive = IsActive FROM [POMS_DB].[dbo].[T_Master_Type] with (nolock) WHERE MT_ID = @MT_ID
		
		UPDATE [POMS_DB].dbo.T_Master_Type SET Name = @MasterTypeName, Description = @Description, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE MT_ID = @MT_ID
		
		IF @OldMasterTypeName <> @MasterTypeName
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'Name', 'T_Master_Type', @MT_ID, 166109, @MT_ID, '', '', @OldMasterTypeName, @MasterTypeName, @OldMasterTypeName, @MasterTypeName, '', 0, 167100, @UserName
		END

		IF @OldDescription <> @Description
		BEGIN	
			exec [POMS_DB].dbo.P_Add_Audit_History 'Description', 'T_Master_Type', @MT_ID, 166109, @MT_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 167100, @UserName
		END	

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].dbo.P_Add_Audit_History 'IsActive' ,'T_Master_Type', @MT_ID, 166109, @MT_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'Master Type Updated Successfully!'
		SET @Return_Code = 1

	END
	ELSE
	BEGIN
		SET @Return_Text = 'Master Type does not exist!'
		SET @Return_Code = 0
	END
END

ELSE BEGIN
	IF @MasterTypeName <> '' BEGIN
		SELECT @MT_ID = ISNULL(MAX(MT_ID),0) + 1 FROM [POMS_DB].[dbo].[T_Master_Type] WITH (NOLOCK) 
		INSERT INTO [POMS_DB].[dbo].[T_Master_Type] (MT_ID, Name, Description, IsActive, AddedBy, AddedOn) VALUES (@MT_ID, @MasterTypeName, @Description, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Master Type Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Master Type Name Not Found!'
		set @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
