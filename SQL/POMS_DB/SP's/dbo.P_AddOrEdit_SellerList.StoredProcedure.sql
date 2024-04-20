USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_SellerList]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[P_AddOrEdit_SellerList]
@SELLER_ID INT,
@Company nvarchar(250),
@ContactPerson nvarchar(250),
@Address nvarchar(250),
@Address2 nvarchar(250),
@City nvarchar(50),
@State nvarchar(20),
@ZipCode nvarchar(10),
@County nvarchar(50),
@CountryRegionCode nvarchar(10),
@EmailTo nvarchar(1000),
@EmailCC nvarchar(1000),
@Mobile nvarchar(30),
@Mobile2 nvarchar(30),
@Phone nvarchar(30),
@PhoneExt nvarchar(10),
@Phone2 nvarchar(30),
@Phone2Ext nvarchar(10),
@D_ID INT,
@IsActive BIT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @SELLER_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [POMS_DB].[dbo].[T_Seller_List] WITH (NOLOCK) WHERE SELLER_ID = @SELLER_ID)
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
		DECLARE @OldEmailTo nvarchar(1000)
		DECLARE @OldEmailCC nvarchar(1000)
		DECLARE @OldMobile nvarchar(30)
		DECLARE @OldMobile2 nvarchar(30)
		DECLARE @OldPhone nvarchar(30)
		DECLARE @OldPhoneExt nvarchar(10)
		DECLARE @OldPhone2 nvarchar(30)
		DECLARE @OldPhone2Ext nvarchar(10)
		DECLARE @OldD_ID INT
		DECLARE @OldActive BIT = 1

		SELECT @OldCompany = Company, @OldContactPerson = ContactPerson, @OldAddress = Address, @OldAddress2 = Address2, @OldCity = City, @OldState = State, @OldZipCode = ZipCode,  @OldCounty = County, @OldCountryRegionCode = CountryRegionCode, @OldEmailTo = EmailTo, @OldEmailCC = EmailCC, @OldMobile = Mobile, @OldMobile2 = Mobile2, @OldPhone = Phone, @OldPhoneExt = PhoneExt, @OldPhone2 = Phone2, @OldPhone2Ext = Phone2Ext, @OldD_ID = D_ID FROM [POMS_DB].[dbo].[T_Seller_List] WITH (NOLOCK) WHERE SELLER_ID = @SELLER_ID
		
		UPDATE [POMS_DB].[dbo].[T_Seller_List] SET Company = @Company, ContactPerson = @ContactPerson, Address = @Address, Address2 = @Address2, City = @City, State = @State, County = @County, CountryRegionCode = @CountryRegionCode, EmailTo = @EmailTo, EmailCC = @EmailCC, Mobile = @Mobile, Mobile2 = @Mobile2, Phone = @Phone, PhoneExt = @PhoneExt, Phone2 = @Phone2, Phone2Ext = @Phone2Ext, D_ID = @D_ID, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE SELLER_ID = @SELLER_ID

		IF @OldCompany <> @Company
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Company' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldCompany, @Company, @OldCompany, @Company, '', 0, 167100, @UserName
		END

		IF @OldContactPerson <> @ContactPerson
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'ContactPerson' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldContactPerson, @ContactPerson, @OldContactPerson, @ContactPerson, '', 0, 167100, @UserName
		END

		IF @OldAddress <> @Address
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Address' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldAddress, @Address, @OldAddress, @Address, '', 0, 167100, @UserName
		END

		IF @OldAddress2 <> @Address2
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Address2' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldAddress2, @Address2, @OldAddress2, @Address2, '', 0, 167100, @UserName
		END

		IF @OldCity <> @City
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'City' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldCity, @City, @OldCity, @City, '', 0, 167100, @UserName
		END

		IF @OldState <> @State
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'State' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldState, @State, @OldState, @State, '', 0, 167100, @UserName
		END

		IF @OldZipCode <> @ZipCode
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'ZipCode' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldZipCode, @ZipCode, @OldZipCode, @ZipCode, '', 0, 167100, @UserName
		END

		IF @OldCounty <> @County
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'County' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldCounty, @County, @OldCounty, @County, '', 0, 167100, @UserName
		END

		IF @OldCountryRegionCode <> @CountryRegionCode
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'CountryRegionCode' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldCountryRegionCode, @CountryRegionCode, @OldCountryRegionCode, @CountryRegionCode, '', 0, 167100, @UserName
		END

		IF @OldEmailTo <> @EmailTo
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'EmailTo' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldEmailTo, @EmailTo, @OldEmailTo, @EmailTo, '', 0, 167100, @UserName
		END

		IF @OldEmailCC <> @EmailCC
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'EmailCC' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldEmailCC, @EmailCC, @OldEmailCC, @EmailCC, '', 0, 167100, @UserName
		END

		IF @OldMobile <> @Mobile
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Mobile' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldMobile, @Mobile, @OldMobile, @Mobile, '', 0, 167100, @UserName
		END

		IF @OldMobile2 <> @Mobile2
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Mobile2' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldMobile2, @Mobile2, @OldMobile2, @Mobile2, '', 0, 167100, @UserName
		END

		IF @OldPhone <> @Phone
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Phone' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldPhone, @Phone, @OldPhone, @Phone, '', 0, 167100, @UserName
		END

		IF @OldPhoneExt <> @PhoneExt
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'PhoneExt' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldPhoneExt, @PhoneExt, @OldPhoneExt, @PhoneExt, '', 0, 167100, @UserName
		END

		IF @OldPhone2 <> @Phone2
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Phone2' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldPhone2, @Phone2, @OldPhone2, @Phone2, '', 0, 167100, @UserName
		END

		IF @OldPhone2Ext <> @Phone2Ext
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'Phone2Ext' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldPhone2Ext, @Phone2Ext, @OldPhone2Ext, @Phone2Ext, '', 0, 167100, @UserName
		END

		IF @OldD_ID <> @D_ID
		BEGIN	
			exec [POMS_DB].[dbo].P_Add_Audit_History 'D_ID' ,'T_Seller_List', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldD_ID, @D_ID, @OldD_ID, @D_ID, '', 0, 167100, @UserName
		END

		IF @OldActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec [POMS_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Page_Group', @SELLER_ID, 166126, @SELLER_ID, '', '', @OldActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Seller List Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Seller List does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	DECLARE @SELLER_CODE nvarchar(20), @SELLER_KEY nvarchar(36)

	exec [POMS_DB].[dbo].[P_Generate_SELLERID] @Ret_SELLERID = @SELLER_ID out
	set @SELLER_CODE = 'S' + Cast(@SELLER_ID as nvarchar(20))
	set @SELLER_KEY = lower(newid())

	INSERT INTO [POMS_DB].[dbo].[T_Seller_List] (SELLER_ID, SELLER_CODE, SELLER_KEY, Company, ContactPerson, Address, Address2, City, State, ZipCode, County, CountryRegionCode, EmailTo, EmailCC, Mobile, Mobile2, Phone, PhoneExt, Phone2, Phone2Ext, D_ID, IsActive,AddedBy, AddedOn) VALUES (@SELLER_ID, @SELLER_CODE, @SELLER_KEY, @Company, @ContactPerson, @Address, @Address2, @City, @State, @ZipCode, @County, @CountryRegionCode, @EmailTo, @EmailCC, @Mobile, @Mobile2, @Phone, @PhoneExt, @Phone2, @Phone2Ext, @D_ID, @IsActive ,@Username, GETUTCDATE())
	SET @Return_Text = 'Seller List Added Successfully!'
	SET @Return_Code = 1
	
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END

GO
