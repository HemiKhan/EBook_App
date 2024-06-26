USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_MasterTypeValue]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--							EXEC [P_AddOrEdit_MasterTypeValue] 0,174,'PRIMARY_DOMAIN','Primary Domain',0,1,'ABDULLAH.ARSHAD',''
CREATE PROC [dbo].[P_AddOrEdit_MasterTypeValue]
@MTV_ID INT = NULL,
@MT_ID INT,
@MTV_CODE nvarchar(20) = '',
@MasterTypeValueName nvarchar(50),
@Sub_MTV_ID int,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @MTV_ID > 0 
BEGIN

	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MTV_ID = @MTV_ID)
	BEGIN
	    
		DECLARE @OldMTV_Code nvarchar(20)
		DECLARE @OldMasterTypeValueName nvarchar(50)
		DECLARE @OldSub_MTV_ID int
		DECLARE @OldActive BIT

		SELECT @OldMTV_Code = MTV_CODE, @OldMasterTypeValueName = Name, @OldSub_MTV_ID = Sub_MTV_ID ,@OldActive = IsActive FROM [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MTV_ID = @MTV_ID
		
		UPDATE [POMS_DB].dbo.T_Master_Type_Value SET MTV_Code = @MTV_CODE, Name = @MasterTypeValueName, Sub_MTV_ID = @Sub_MTV_ID ,IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE MTV_ID = @MTV_ID
		
		IF @OldMTV_Code <> @MTV_CODE
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'MTV_Code' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldMTV_Code, @MTV_CODE, @OldMTV_Code, @MTV_CODE, '', 0, 167100, @UserName
		END

		IF @OldMasterTypeValueName <> @MasterTypeValueName
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Name' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldMasterTypeValueName, @MasterTypeValueName, @OldMasterTypeValueName, @MasterTypeValueName, '', 0, 167100, @UserName
		END

		IF @OldSub_MTV_ID <> @Sub_MTV_ID
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Sub_MTV_ID' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldSub_MTV_ID, @Sub_MTV_ID, @OldSub_MTV_ID, @Sub_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'Master Type Value Updated Successfully!'
		SET @Return_Code = 1

	END
	ELSE
	BEGIN
		SET @Return_Text = 'Master Type Value does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
	BEGIN
		DECLARE @maxSortValue INT
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [POMS_DB].[dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = @MT_ID
		SELECT @MTV_ID = (CASE WHEN ISNULL(MAX(MTV_ID),0) = 0 THEN cast((cast(@MT_ID as nvarchar(max)) + '100') as int) ELSE ISNULL(MAX(MTV_ID),0) + 1 END) FROM [POMS_DB].[dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = @MT_ID
		IF @MTV_CODE = '' BEGIN SET @MTV_CODE = @MTV_ID END
		INSERT INTO [POMS_DB].[dbo].[T_Master_Type_Value] (MTV_ID, MT_ID, MTV_CODE, Name, Sort_, Sub_MTV_ID ,IsActive, AddedBy, AddedOn) VALUES (@MTV_ID, @MT_ID, @MTV_CODE, @MasterTypeValueName, @maxSortValue, @Sub_MTV_ID ,@Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Master Type Value Added Successfully!'
		set @Return_Code = 1
	END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
