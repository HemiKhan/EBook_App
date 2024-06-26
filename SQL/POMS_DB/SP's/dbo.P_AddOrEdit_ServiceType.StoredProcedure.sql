USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ServiceType]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	EXEC P_AddOrEdit_ServiceType 10,'Setting',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_ServiceType]
@ST_CODE nvarchar(20),
@ServiceName nvarchar(100),
@Type_MTV_ID int,
@Sort_ int,
@IsAllowed bit,
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @ST_CODE <> ''
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Service_Type] WITH (NOLOCK) WHERE ST_CODE = @ST_CODE)
	BEGIN
	    
		DECLARE @OldST_CODE nvarchar(20)
		DECLARE @OldServiceName nvarchar(100)
		DECLARE	@OldType_MTV_ID int
		DECLARE @OldSort_ int
		DECLARE @OldIsAllowed bit
		DECLARE @OldIsActive bit
		
		SELECT @OldServiceName = ServiceName, @OldType_MTV_ID = Type_MTV_ID, @OldSort_ = Sort_, @OldIsAllowed = IsAllowed, @OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_Service_Type] WITH (NOLOCK) WHERE ST_CODE = @ST_CODE
		
		UPDATE [POMS_DB].[dbo].[T_Service_Type] SET ServiceName = @ServiceName, Type_MTV_ID = @Type_MTV_ID, Sort_ = @Sort_, IsAllowed = @IsAllowed, IsActive = @IsActive ,ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE ST_CODE = @ST_CODE

		IF @OldServiceName <> @ServiceName
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'ServiceName' ,'T_Service_Type', @ST_CODE, 166100, @ST_CODE, '', '', @OldServiceName, @ServiceName, @OldServiceName, @ServiceName, '', 0, 167100, @UserName
		END

		IF @OldType_MTV_ID <> @Type_MTV_ID
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Type_MTV_ID' ,'T_Service_Type', @ST_CODE, 166100, @ServiceName, '', '', @OldType_MTV_ID, @Type_MTV_ID, @OldType_MTV_ID, @Type_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldIsAllowed <> @IsAllowed
		BEGIN
			Declare @OldIsAllowedText nvarchar(10) = (case when @OldIsAllowed = 1 then 'Yes' else 'No' end)
			Declare @IsAllowedText nvarchar(10) = (case when @IsAllowed = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsAllowed' ,'T_Service_Type', @ST_CODE, 166100, @ServiceName, '', '', @OldIsAllowed, @IsAllowed, @OldIsAllowedText, @IsAllowedText, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Service_Type', @ST_CODE, 166100, @ServiceName, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Service Type Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Service Type does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @ServiceName <> '' 
	BEGIN
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM  [POMS_DB].[dbo].T_Service_Type WITH (NOLOCK) where Type_MTV_ID = @Type_MTV_ID
		INSERT INTO [POMS_DB].[dbo].T_Service_Type (ST_CODE, ServiceName, Type_MTV_ID ,Sort_, IsAllowed, IsActive, AddedBy, AddedOn) VALUES (@ST_CODE, @ServiceName, @Type_MTV_ID, @maxSortValue ,@IsAllowed, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Service Type Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Service Type Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
