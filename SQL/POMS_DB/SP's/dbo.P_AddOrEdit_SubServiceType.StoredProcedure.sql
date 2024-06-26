USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_SubServiceType]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	EXEC P_AddOrEdit_SubServiceType 'OFFICE','OTH','To a Office/ Busine',1,'BABAR.ALI', '0'
CREATE PROC [dbo].[P_AddOrEdit_SubServiceType]
@SST_CODE nvarchar(20),
@ST_CODE nvarchar(20),
@SubServiceName nvarchar(100),
--@Type_MTV_ID int,
--@Sort_ int,
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	DECLARE @Sort_ INT	= 0
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @SST_CODE <> ''
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Sub_Service_Type] WITH (NOLOCK) WHERE SST_CODE = @SST_CODE AND ST_CODE = @ST_CODE)
	BEGIN
	    
		DECLARE @OldSST_CODE nvarchar(20)
		DECLARE @OldST_CODE nvarchar(20)
		DECLARE @OldSubServiceName nvarchar(100)
		DECLARE @OldSort_ int
		DECLARE @OldIsActive bit
		
		SELECT @OldSST_CODE = SST_CODE ,@OldST_CODE = ST_CODE , @OldSubServiceName = SubServiceName, @OldSort_ = Sort_,  @OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_Sub_Service_Type] WITH (NOLOCK) WHERE SST_CODE = @SST_CODE AND ST_CODE = @ST_CODE
		
		UPDATE [POMS_DB].[dbo].[T_Sub_Service_Type] SET ST_CODE = @ST_CODE, SubServiceName = @SubServiceName, Sort_ = @Sort_, IsActive = @IsActive ,ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE SST_CODE = @SST_CODE AND ST_CODE = @ST_CODE

		--IF @OldSubServiceName <> @SubServiceName
		--BEGIN	
		--	exec [POMS_DB].[dbo].P_Add_Audit_History 'SubServiceName' ,'T_SubService_Type', @ST_CODE, 166100, @ST_CODE, '', '', @OldServiceName, @ServiceName, @OldServiceName, @ServiceName, '', 0, 167100, @UserName
		--END

		--IF @OldType_MTV_ID <> @Type_MTV_ID
		--BEGIN	
		--	exec [POMS_DB].[dbo].P_Add_Audit_History 'Type_MTV_ID' ,'T_Service_Type', @ST_CODE, 166100, @ServiceName, '', '', @OldType_MTV_ID, @Type_MTV_ID, @OldType_MTV_ID, @Type_MTV_ID, '', 0, 167100, @UserName
		--END

		--IF @OldIsAllowed <> @IsAllowed
		--BEGIN
		--	Declare @OldIsAllowedText nvarchar(10) = (case when @OldIsAllowed = 1 then 'Yes' else 'No' end)
		--	Declare @IsAllowedText nvarchar(10) = (case when @IsAllowed = 1 then 'Yes' else 'No' end)
		--	exec [POMS_DB].[dbo].P_Add_Audit_History 'IsAllowed' ,'T_Service_Type', @ST_CODE, 166100, @ServiceName, '', '', @OldIsAllowed, @IsAllowed, @OldIsAllowedText, @IsAllowedText, '', 0, 167100, @UserName
		--END

		--IF @OldIsActive <> @IsActive
		--BEGIN
		--	Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
		--	Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
		--	exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Service_Type', @ST_CODE, 166100, @ServiceName, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		--END	
		

		SET @Return_Text = 'SubService Type Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'SubService Type does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @SubServiceName <> '' 
	BEGIN
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM  [POMS_DB].[dbo].T_Sub_Service_Type WITH (NOLOCK) where ST_CODE = @ST_CODE
		INSERT INTO [POMS_DB].[dbo].[T_Sub_Service_Type] (SST_CODE,ST_CODE, SubServiceName, Sort_, IsActive, AddedBy, AddedOn) VALUES (@SST_CODE,@ST_CODE, @SubServiceName, @maxSortValue , @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'SubService Type Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'SubService Type Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
