USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_UserSellerAddressMapping]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [dbo].[P_AddOrEdit_UserSellerAddressMapping] 
@USAM_ID int,
@InputUserName nvarchar(300),
@SAM_ID  int,
@IsActive bit,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @USAM_ID>0
 BEGIN
 IF EXISTS(SELECT 1 FROM  [POMS_DB].[dbo].[T_User_Seller_Address_Mapping] WITH (NOLOCK) WHERE USAM_ID=@USAM_ID)
     BEGIN
	 DECLARE @OldInputUserName nvarchar(20)
	 DECLARE @OldSAM_ID int
	 DECLARE @OldIsActive bit

	 SELECT @OldInputUserName = UserName, @OldSAM_ID = SAM_ID, @OldIsActive = IsActive FROM [POMS_DB].[dbo].[T_User_Seller_Address_Mapping] WITH(NOLOCK) WHERE USAM_ID=@USAM_ID

	 UPDATE [POMS_DB].[dbo].[T_User_Seller_Address_Mapping] SET SAM_ID=@SAM_ID, UserName=@InputUserName, IsActive=@IsActive, ModifiedBy = @Username , ModifiedOn=GETUTCDATE() WHERE USAM_ID=@USAM_ID

	 IF @OldInputUserName <> @InputUserName
		BEGIN	
			exec P_Add_Audit_History 'UserName' ,'T_User_Seller_Address_Mapping', @USAM_ID, 166142, @USAM_ID, '', '', @OldInputUserName, @InputUserName, @OldInputUserName, @InputUserName, '', 0, 107100, @UserName
		END

		 IF @OldSAM_ID <> @SAM_ID 
		BEGIN	
			exec P_Add_Audit_History 'USAM_ID' ,'T_User_Seller_Address_Mapping', @USAM_ID, 166142, @USAM_ID, '', '', @OldSAM_ID, @SAM_ID, @OldSAM_ID, @SAM_ID, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_User_Seller_Address_Mapping', @USAM_ID, 166142, @USAM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'User Seller Address Mapping Updated Successfully!'
		SET @Return_Code = 1
		 
	  
	 END
	 ELSE
	BEGIN
		SET @Return_Text = 'User Seller Address Mapping does not exist!'
		SET @Return_Code = 0
	END
 END
 ElSE
 BEGIN
  IF @SAM_ID <> ''
  BEGIN
		 
		INSERT INTO [POMS_DB].[dbo].[T_User_Seller_Address_Mapping] (UserName, SAM_ID, IsActive, AddedBy, AddedOn) VALUES (@InputUserName, @SAM_ID,  @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'User Seller Address Mapping Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'User Seller Address Mapping Name Not Found!'
		set @Return_Code = 0
	END
 END
 SELECT @Return_Text Return_Text, @Return_Code Return_Code
END



 
GO
