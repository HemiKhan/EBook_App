USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ServiceTypeDetails]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_PageGroup 10,'Setting',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_ServiceTypeDetails]
@STD_ID INT = NULL,
@SST_CODE nvarchar(20),
@ST_CODE nvarchar(20),
@ServiceDetail nvarchar(100),
--@Sort int,
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''
	DECLARE @Sort INT = 0

IF @STD_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Service_Type_Detail] WITH (NOLOCK) WHERE STD_ID = @STD_ID)
	BEGIN
	    
		DECLARE @OldSST_CODE nvarchar(20)
		DECLARE @OldST_CODE nvarchar(20)
		DECLARE @OldServiceDetail nvarchar(100)
		DECLARE @OldSort int
		DECLARE @OldIsActive BIT
		
		SELECT @OldSST_CODE = SST_CODE, @OldST_CODE = ST_CODE, @OldServiceDetail = ServiceDetail, @OldSort = Sort_ ,@OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_Service_Type_Detail] WITH (NOLOCK) WHERE STD_ID = @STD_ID
		
		UPDATE [POMS_DB].[dbo].[T_Service_Type_Detail] SET SST_CODE = @SST_CODE, ST_CODE = @ST_CODE, ServiceDetail = @ServiceDetail, Sort_ = @Sort , IsActive = @IsActive, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE STD_ID = @STD_ID

		IF @OldSST_CODE <> @SST_CODE
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'SST_CODE' ,'T_Service_Type_Detail', @STD_ID, 166140, @STD_ID, '', '', @OldSST_CODE, @SST_CODE, @OldSST_CODE, @SST_CODE, '', 0, 167100, @UserName
		END

		IF @OldST_CODE <> @ST_CODE
		BEGIN
			exec [POMS_DB].[dbo].P_Add_Audit_History 'ST_CODE' ,'T_Service_Type_Detail', @STD_ID, 166140, @SST_CODE, '', '', @OldST_CODE, @ST_CODE, @OldST_CODE, @ST_CODE, '', 0, 167100, @UserName
		END

		IF @OldServiceDetail <> @ServiceDetail
		BEGIN
			exec [POMS_DB].[dbo].P_Add_Audit_History 'ServiceDetail' ,'T_Service_Type_Detail', @STD_ID, 166140, @SST_CODE, '', '', @OldServiceDetail, @ServiceDetail, @OldServiceDetail, @ServiceDetail, '', 0, 167100, @UserName
		END

		IF @OldSort <> @Sort
		BEGIN
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Sort' ,'T_Service_Type_Detail', @STD_ID, 166140, @SST_CODE, '', '', @OldSort, @Sort, @OldSort, @Sort, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Service_Type_Detail', @STD_ID, 166140, @SST_CODE, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
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
	IF @SST_CODE <> '' BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_Service_Type_Detail] (STD_ID, SST_CODE, ST_CODE, ServiceDetail ,Sort_, IsActive, AddedBy, AddedOn) VALUES (@STD_ID, @SST_CODE, @ST_CODE, @ServiceDetail, @Sort ,@IsActive, @Username, GETUTCDATE())
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
