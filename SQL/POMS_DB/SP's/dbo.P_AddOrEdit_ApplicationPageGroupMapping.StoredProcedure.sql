USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ApplicationPageGroupMapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[P_AddOrEdit_ApplicationPageGroupMapping] 2,'148102',2,1,'Ihtisham.Ulhaq'
CREATE PROCEDURE [dbo].[P_AddOrEdit_ApplicationPageGroupMapping]
@APGM_ID int,
@Application_MTV_CODE nvarchar(20),
@PG_ID int,
@IsActive bit,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @APGM_ID>0
 BEGIN
 IF EXISTS(SELECT 1 FROM  [POMS_DB].[dbo].[T_Application_Page_Group_Mapping] WITH (NOLOCK) WHERE APGM_ID=@APGM_ID)
     BEGIN
	 DECLARE @OldApplication_MTV_CODE nvarchar(20)
	 DECLARE @OldPG_ID int
	 DECLARE @OldIsActive bit

	 SELECT @OldApplication_MTV_CODE = Application_MTV_CODE, @OldPG_ID = PG_ID, @OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_Application_Page_Group_Mapping] WITH(NOLOCK) WHERE APGM_ID=@APGM_ID

	 UPDATE [POMS_DB].[dbo].[T_Application_Page_Group_Mapping] SET Application_MTV_CODE=@Application_MTV_CODE,PG_ID=@PG_ID, IsActive=@IsActive, ModifiedBy = @Username , ModifiedOn=GETUTCDATE() WHERE APGM_ID=@APGM_ID

	 IF @OldApplication_MTV_CODE <> @Application_MTV_CODE
		BEGIN	
			exec P_Add_Audit_History 'Application_MTV_CODE' ,'T_Application_Page_Group_Mapping', @APGM_ID, 166111, @APGM_ID, '', '', @OldApplication_MTV_CODE, @Application_MTV_CODE, @OldApplication_MTV_CODE, @Application_MTV_CODE, '', 0, 107100, @UserName
		END

		 IF @OldPG_ID <> @PG_ID
		BEGIN	

			exec P_Add_Audit_History 'PG_ID' ,'T_Application_Page_Group_Mapping', @APGM_ID, 166111, @APGM_ID, '', '', @OldPG_ID, @PG_ID, @OldPG_ID, @PG_ID, '', 0, 167100, @UserName
			--exec P_Add_Audit_History 'Description' ,'T_Master_Type', @MT_ID, 166101, @MT_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 107100, @UserName
		   
		END
		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_Application_Page_Group_Mapping', @APGM_ID, 166111, @APGM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'Application Page Group Mapping Updated Successfully!'
		SET @Return_Code = 1
		 
	  
	 END
	 ELSE
	BEGIN
		SET @Return_Text = 'Application Page Group Mapping does not exist!'
		SET @Return_Code = 0
	END
 END
 ElSE
 BEGIN
  IF @Application_MTV_CODE <> ''
  BEGIN
		--SELECT @APGM_ID = ISNULL(MAX(APGM_ID),0) + 1 FROM [POMS_DB].[dbo].[T_Application_Page_Group_Mapping] WITH (NOLOCK) 
		INSERT INTO [POMS_DB].[dbo].[T_Application_Page_Group_Mapping] (Application_MTV_CODE, PG_ID, IsActive, AddedBy, AddedOn) VALUES (@Application_MTV_CODE, @PG_ID, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Application Page Group Mapping Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Application Page Group Mapping Name Not Found!'
		set @Return_Code = 0
	END
 END
 SELECT @Return_Text Return_Text, @Return_Code Return_Code
END



 
GO
