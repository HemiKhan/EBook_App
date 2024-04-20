USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TariffList]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_PageGroup 10,'Setting',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_TariffList]
@TARIFF_ID INT = NULL,
--@TARIFF_NO nvarchar(50),
@Name nvarchar(250),
@Description nvarchar(250),
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TARIFF_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Tariff_List] WITH (NOLOCK) WHERE TARIFF_ID = @TARIFF_ID)
	BEGIN
	    
		DECLARE @OldTARIFF_NO nvarchar(50)
		DECLARE @OldName nvarchar(250)
		DECLARE @OldDescription nvarchar(250)
		DECLARE @OldIsActive bit
		
		SELECT @OldTARIFF_NO = TARIFF_NO, @OldName = Name, @OldDescription = Description, @OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_Tariff_List] WITH (NOLOCK) WHERE TARIFF_ID = @TARIFF_ID
		
		UPDATE [POMS_DB].[dbo].[T_Tariff_List] SET [Name] = @Name, [Description] = @Description, IsActive = @IsActive ,ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE TARIFF_ID = @TARIFF_ID

		IF @OldName <> @Name
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Name' ,'T_Tariff_List', @TARIFF_ID, 166129, @TARIFF_ID, '', '', @OldName, @Name, @OldName, @Name, '', 0, 167100, @UserName
		END

		IF @OldDescription <> @Description
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Description' ,'T_Tariff_List', @TARIFF_ID, 166129, @TARIFF_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Tariff_List', @TARIFF_ID, 166129, @TARIFF_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Tariff List Name Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Tariff List does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	
	DECLARE @Tariff_NO nvarchar(100) = ''
	DECLARE @Tariff_Hash nvarchar(13) = ''

	exec [POMS_DB].[dbo].[P_Generate_TariffID] @Ret_TariffID = @TARIFF_ID out
	select @Tariff_Hash=[POMS_DB].[dbo].[F_Get_Traiff_ID] (@Tariff_ID)
	select @Tariff_NO=CONVERT(varchar(12), right(newid(),12))
	select @Tariff_NO=right(@Tariff_NO + @Tariff_Hash,12)
	set @Tariff_NO=Stuff(@Tariff_NO, Len(@Tariff_NO)-5, 0, '-')
	set @Tariff_NO = isnull(@Tariff_NO,'')
		
	IF @TARIFF_NO <> '' BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_Tariff_List] (TARIFF_ID, TARIFF_NO, Name, Description, IsActive, AddedBy, AddedOn) VALUES (@TARIFF_ID, @TARIFF_NO, @Name, @Description, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Tariff List Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Tariff List Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
