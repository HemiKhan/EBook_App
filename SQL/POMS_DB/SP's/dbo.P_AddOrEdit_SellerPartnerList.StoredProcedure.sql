USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_SellerPartnerList]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[P_AddOrEdit_SellerPartnerList]
@SELLER_PARTNER_ID INT = NULL,
@Company nvarchar(250),
@ContactPerson nvarchar(250),
@Address nvarchar(250),
@Address2 nvarchar(250),
@City nvarchar(50),
@State nvarchar(20),
@ZipCode nvarchar(10),
@County nvarchar(50),
@CountryRegionCode nvarchar(10),
@Email nvarchar(1000),
@Mobile nvarchar(30),
@Phone nvarchar(30),
@PhoneExt nvarchar(10),
@IsActive BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @SELLER_PARTNER_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Seller_Partner_List] WITH (NOLOCK) WHERE SELLER_PARTNER_ID = @SELLER_PARTNER_ID)
	BEGIN
	    
		DECLARE @OldCompany nvarchar(250)
		DECLARE @OldContactPerson nvarchar(250)
		DECLARE @OldAddress nvarchar(250)
		DECLARE @OldAddress2 nvarchar(250)
		DECLARE @OldCity nvarchar(50)
		DECLARE @OldState nvarchar(20)
		DECLARE @OldZipCode nvarchar(10)
		DECLARE @OldCounty nvarchar(50)
		DECLARE @OldCountryRegionCode nvarchar(10)
		DECLARE @OldEmail nvarchar(1000)
		DECLARE @OldMobile nvarchar(30)
		DECLARE @OldPhone nvarchar(30)
		DECLARE @OldPhoneExt nvarchar(10)
		DECLARE @OldD_ID INT
		DECLARE @OldActive BIT = 1

		SELECT @OldCompany = Company, @OldContactPerson = ContactPerson, @OldAddress = Address, @OldAddress2 = Address2, @OldCity = City, @OldState = State, @OldZipCode = ZipCode,  @OldCounty = County, @OldCountryRegionCode = CountryRegionCode, @OldEmail = Email, @OldMobile = Mobile, @OldPhone = Phone, @OldPhoneExt = PhoneExt, @OldActive = IsActive FROM [POMS_DB].[dbo].[T_Seller_Partner_List] WITH (NOLOCK) WHERE SELLER_PARTNER_ID = @SELLER_PARTNER_ID
		
		UPDATE [POMS_DB].[dbo].[T_Seller_Partner_List] SET Company = @Company, ContactPerson = @ContactPerson, Address = @Address, Address2 = @Address2, City = @City, State = @State, County = @County, CountryRegionCode = @CountryRegionCode, Email = @Email, Mobile = @Mobile,  Phone = @Phone, PhoneExt = @PhoneExt, IsActive = @IsActive ,ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE SELLER_PARTNER_ID = @SELLER_PARTNER_ID

		IF @OldCompany <> @Company
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Company' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldCompany, @Company, @OldCompany, @Company, '', 0, 167100, @UserName
		END

		IF @OldContactPerson <> @ContactPerson
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'ContactPerson' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldContactPerson, @ContactPerson, @OldContactPerson, @ContactPerson, '', 0, 167100, @UserName
		END

		IF @OldAddress <> @Address
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Address' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldAddress, @Address, @OldAddress, @Address, '', 0, 167100, @UserName
		END

		IF @OldAddress2 <> @Address2
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Address2' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldAddress2, @Address2, @OldAddress2, @Address2, '', 0, 167100, @UserName
		END

		IF @OldCity <> @City
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'City' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldCity, @City, @OldCity, @City, '', 0, 167100, @UserName
		END

		IF @OldState <> @State
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'State' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldState, @State, @OldState, @State, '', 0, 167100, @UserName
		END

		IF @OldZipCode <> @ZipCode
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'ZipCode' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldZipCode, @ZipCode, @OldZipCode, @ZipCode, '', 0, 167100, @UserName
		END

		IF @OldCounty <> @County
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'County' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldCounty, @County, @OldCounty, @County, '', 0, 167100, @UserName
		END

		IF @OldCountryRegionCode <> @CountryRegionCode
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'CountryRegionCode' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldCountryRegionCode, @CountryRegionCode, @OldCountryRegionCode, @CountryRegionCode, '', 0, 167100, @UserName
		END

		IF @OldEmail <> @Email
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Email' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldEmail, @Email, @OldEmail, @Email, '', 0, 167100, @UserName
		END


		IF @OldMobile <> @Mobile
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Mobile' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldMobile, @Mobile, @OldMobile, @Mobile, '', 0, 167100, @UserName
		END

		IF @OldPhone <> @Phone
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Phone' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldPhone, @Phone, @OldPhone, @Phone, '', 0, 167100, @UserName
		END

		IF @OldPhoneExt <> @PhoneExt
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'PhoneExt' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldPhoneExt, @PhoneExt, @OldPhoneExt, @PhoneExt, '', 0, 167100, @UserName
		END

		IF @OldActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Seller_Partner_List', @SELLER_PARTNER_ID, 166128, @SELLER_PARTNER_ID, '', '', @OldActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Seller Partner List Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Seller Partner List does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	DECLARE @SELLER_PARTNER_CODE nvarchar(20), @SELLER_PARTNER_KEY nvarchar(36)

	exec [POMS_DB].[dbo].[P_Generate_SELLER_PARTNERID] @Ret_SUB_SELLERID = @SELLER_PARTNER_ID out
	set @SELLER_PARTNER_CODE = 'SP' + Cast(@SELLER_PARTNER_ID as nvarchar(20))
	set @SELLER_PARTNER_KEY = lower(newid())

	BEGIN
		INSERT INTO [POMS_DB].[dbo].[T_Seller_Partner_List] (SELLER_PARTNER_ID, SELLER_PARTNER_CODE, SELLER_PARTNER_KEY, Company, ContactPerson, Address, Address2, City, State, ZipCode, County, CountryRegionCode, Email, Mobile, Phone, PhoneExt,IsActive, AddedBy, AddedOn) VALUES (@SELLER_PARTNER_ID, @SELLER_PARTNER_CODE, @SELLER_PARTNER_KEY, @Company, @ContactPerson, @Address, @Address2, @City, @State, @ZipCode, @County, @CountryRegionCode, @Email, @Mobile, @Phone, @PhoneExt,@IsActive ,@Username, GETUTCDATE())
		SET @Return_Text = 'Seller Partner List Added Successfully!'
		SET @Return_Code = 1
	END
	
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END

GO
