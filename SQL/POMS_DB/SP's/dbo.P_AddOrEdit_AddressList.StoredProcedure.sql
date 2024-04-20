USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_AddressList]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	 				 
CREATE PROC [dbo].[P_AddOrEdit_AddressList] 
	@Address_ID INT
	,@ST_CODE NVARCHAR(40)
	,@ServiceType_MTV_ID INT
	,@IsResidentialAddress BIT
	,@FirstName NVARCHAR(100)
	,@MiddleName NVARCHAR(100)
	,@LastName NVARCHAR(100)
	,@Company NVARCHAR(500)
	,@ContactPerson NVARCHAR(300)
	,@Address NVARCHAR(500)
	,@Address2 NVARCHAR(500)
	,@City NVARCHAR(100)
	,@State NVARCHAR(10)
	,@ZipCode NVARCHAR(10)
	,@County NVARCHAR(100)
	,@CountryRegionCode NVARCHAR(20)
	,@Email NVARCHAR(500)
	,@Mobile NVARCHAR(60)
	,@Phone NVARCHAR(40)
	,@PhoneExt NVARCHAR(20)
	,@Latitude NVARCHAR(60)
	,@Longitude NVARCHAR(60)
	,@PlaceID NVARCHAR(MAX)
	,@AddressType_MTV_ID INT
	,@AddressStatus_MTV_ID INT
	,@Comment NVARCHAR(2000)
	,@IsActive BIT
	,@Username NVARCHAR(150)
	,@IPAddress NVARCHAR(20) = NULL
AS
BEGIN
	DECLARE @maxSortValue INT
	DECLARE @Return_Code BIT = 1
	DECLARE @Return_Text NVARCHAR(1000) = ''
	DECLARE @ADDRESS_CODE NVARCHAR(20) = ''

	SELECT @ADDRESS_CODE = ADDRESS_CODE
	FROM [POMS_DB].[dbo].[T_Address_List] WITH (NOLOCK)
	WHERE ADDRESS_ID = @Address_ID

	SET @ADDRESS_CODE = isnull(@ADDRESS_CODE, '')

	IF @Address_ID > 0
	BEGIN
		IF @ADDRESS_CODE <> ''
		BEGIN
			DECLARE @OldST_CODE NVARCHAR(40)
			DECLARE @OldServiceType_MTV_ID INT
			DECLARE @OldIsResidentialAddress BIT
			DECLARE @OldFirstName NVARCHAR(100)
			DECLARE @OldMiddleName NVARCHAR(100)
			DECLARE @OldLastName NVARCHAR(100)
			DECLARE @OldCompany NVARCHAR(500)
			DECLARE @OldContactPerson NVARCHAR(300)
			DECLARE @OldAddress NVARCHAR(500)
			DECLARE @OldAddress2 NVARCHAR(500)
			DECLARE @OldCity NVARCHAR(100)
			DECLARE @OldState NVARCHAR(10)
			DECLARE @OldZipCode NVARCHAR(10)
			DECLARE @OldCounty NVARCHAR(100)
			DECLARE @OldCountryRegionCode NVARCHAR(20)
			DECLARE @OldEmail NVARCHAR(500)
			DECLARE @OldMobile NVARCHAR(60)
			DECLARE @OldPhone NVARCHAR(40)
			DECLARE @OldPhoneExt NVARCHAR(20)
			DECLARE @OldLatitude NVARCHAR(60)
			DECLARE @OldLongitude NVARCHAR(60)
			DECLARE @OldPlaceID NVARCHAR(MAX)
			DECLARE @OldAddressType_MTV_ID INT
			DECLARE @OldAddressStatus_MTV_ID INT
			DECLARE @OldComment NVARCHAR(2000)
			DECLARE @OldActive BIT

			SELECT @OldActive = IsActive
				,@OldST_CODE = ST_CODE
				,@OldServiceType_MTV_ID = ServiceType_MTV_ID
				,@OldIsResidentialAddress = IsResidentialAddress
				,@OldFirstName = FirstName
				,@OldMiddleName = MiddleName
				,@OldLastName = LastName
				,@OldCompany = Company
				,@OldContactPerson = ContactPerson
				,@OldAddress = Address
				,@OldAddress2 = Address2
				,@OldCity = City
				,@OldState = STATE
				,@OldZipCode = ZipCode
				,@OldCounty = County
				,@OldCountryRegionCode = CountryRegionCode
				,@OldEmail = Email
				,@OldMobile = Mobile
				,@OldPhone = Phone
				,@OldPhoneExt = PhoneExt
				,@OldLatitude = Latitude
				,@OldLongitude = Longitude
				,@OldPlaceID = PlaceID
				,@OldAddressType_MTV_ID = AddressType_MTV_ID
				,@OldAddressStatus_MTV_ID = AddressStatus_MTV_ID
				,@OldComment = Comment
				,@OldActive = IsActive
			FROM [POMS_DB].[dbo].T_Address_List WITH (NOLOCK)
			WHERE ADDRESS_ID = @Address_ID;

			UPDATE [POMS_DB].[dbo].T_Address_List
			SET ST_CODE = @ST_CODE
				,ServiceType_MTV_ID = @ServiceType_MTV_ID
				,IsResidentialAddress = @IsResidentialAddress
				,FirstName = @FirstName
				,MiddleName = @MiddleName
				,LastName = @LastName
				,Company = @Company
				,ContactPerson = @ContactPerson
				,[Address] = @Address
				,Address2 = @Address2
				,City = @City
				,[State] = @State
				,ZipCode = @ZipCode
				,County = @County
				,CountryRegionCode = @CountryRegionCode
				,Email = @Email
				,Mobile = @Mobile
				,Phone = @Phone
				,PhoneExt = @PhoneExt
				,Latitude = @Latitude
				,Longitude = @Longitude
				,PlaceID = @PlaceID
				,AddressType_MTV_ID = @AddressType_MTV_ID
				,AddressStatus_MTV_ID = @AddressStatus_MTV_ID
				,Comment = @Comment
				,IsActive = @IsActive
				,ModifiedBy = @Username
				,ModifiedOn = GETUTCDATE()
			WHERE ADDRESS_ID = @Address_ID;

			IF @OldST_CODE <> @ST_CODE
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'ST_CODE'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldST_CODE
					,@ST_CODE
					,@OldST_CODE
					,@ST_CODE
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldServiceType_MTV_ID <> @ServiceType_MTV_ID
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'ServiceType_MTV_ID'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldServiceType_MTV_ID
					,@ServiceType_MTV_ID
					,@OldServiceType_MTV_ID
					,CAST@ServiceType_MTV_ID
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldFirstName <> @FirstName
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'FirstName'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldFirstName
					,@FirstName
					,@OldFirstName
					,@FirstName
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldMiddleName <> @MiddleName
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'MiddleName'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldMiddleName
					,@MiddleName
					,@OldMiddleName
					,@MiddleName
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldLastName <> @LastName
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'LastName'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldLastName
					,@LastName
					,@OldLastName
					,@LastName
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldCompany <> @Company
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Company'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldCompany
					,@Company
					,@OldCompany
					,@Company
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldContactPerson <> @ContactPerson
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'ContactPerson'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldContactPerson
					,@ContactPerson
					,@OldContactPerson
					,@ContactPerson
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldAddress <> @Address
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Address'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldAddress
					,@Address
					,@OldAddress
					,@Address
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldAddress2 <> @Address2
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Address2'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldAddress2
					,@Address2
					,@OldAddress2
					,@Address2
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldCity <> @City
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'City'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldCity
					,@City
					,@OldCity
					,@City
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldState <> @State
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'State'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldState
					,@State
					,@OldState
					,@State
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldZipCode <> @ZipCode
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'ZipCode'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldZipCode
					,@ZipCode
					,@OldZipCode
					,@ZipCode
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldCounty <> @County
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Country'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldCounty
					,@County
					,@OldCounty
					,@County
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldCountryRegionCode <> @CountryRegionCode
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'CountryRegionCode'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldCountryRegionCode
					,@CountryRegionCode
					,@OldCountryRegionCode
					,@CountryRegionCode
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldEmail <> @Email
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Email'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldEmail
					,@Email
					,@OldEmail
					,@Email
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldMobile <> @Mobile
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Mobile'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldMobile
					,@Mobile
					,@OldMobile
					,@Mobile
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldPhone <> @Phone
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Phone'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldPhone
					,@Phone
					,@OldPhone
					,@Phone
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldPhoneExt <> @PhoneExt
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'PhoneExt'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldPhoneExt
					,@PhoneExt
					,@OldPhoneExt
					,@PhoneExt
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldLatitude <> @Latitude
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Latitude'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldLatitude
					,@Latitude
					,@OldLatitude
					,@Latitude
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldLongitude <> @Longitude
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Longitude'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldLongitude
					,@Longitude
					,@OldLongitude
					,@Longitude
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldPlaceID <> @PlaceID
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'PlaceID'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldPlaceID
					,@PlaceID
					,@OldPlaceID
					,@PlaceID
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldAddressType_MTV_ID <> @AddressType_MTV_ID
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'AddressType_MTV_ID'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldAddressType_MTV_ID
					,@AddressType_MTV_ID
					,@OldAddressType_MTV_ID
					,@AddressType_MTV_ID
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldAddressStatus_MTV_ID <> @AddressStatus_MTV_ID
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'AddressStatus_MTV_ID'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldAddressStatus_MTV_ID
					,@AddressStatus_MTV_ID
					,@OldAddressStatus_MTV_ID
					,@AddressStatus_MTV_ID
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldComment <> @Comment
			BEGIN
				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'Comment'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldComment
					,@Comment
					,@OldComment
					,@Comment
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldIsResidentialAddress <> @IsResidentialAddress
			BEGIN
				DECLARE @OldIsResidentialAddressText NVARCHAR(10) = (
						CASE 
							WHEN @OldActive = 1
								THEN 'Yes'
							ELSE 'No'
							END
						)
				DECLARE @IsResidentialAddressText NVARCHAR(10) = (
						CASE 
							WHEN @IsActive = 1
								THEN 'Yes'
							ELSE 'No'
							END
						)

				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'IsActive'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldIsResidentialAddress
					,@IsResidentialAddress
					,@OldIsResidentialAddressText
					,@IsResidentialAddressText
					,''
					,0
					,167100
					,@UserName
			END

			IF @OldActive <> @IsActive
			BEGIN
				DECLARE @OldIsActiveText NVARCHAR(10) = (
						CASE 
							WHEN @OldActive = 1
								THEN 'Yes'
							ELSE 'No'
							END
						)
				DECLARE @IsActiveText NVARCHAR(10) = (
						CASE 
							WHEN @IsActive = 1
								THEN 'Yes'
							ELSE 'No'
							END
						)

				EXEC [POMS_DB].[dbo].P_Add_Audit_History 'IsActive'
					,'T_Address_List'
					,@Address_ID
					,166148
					,@Address_ID
					,''
					,''
					,@OldActive
					,@IsActive
					,@OldIsActiveText
					,@IsActiveText
					,''
					,0
					,167100
					,@UserName
			END

			SET @Return_Text = ' Address List Updated Successfully!'
			SET @Return_Code = 1
		END
		ELSE
		BEGIN
			SET @Return_Text = 'Invalid Address ID'
			SET @Return_Code = 0
		END
	END
	ELSE
	BEGIN
		EXEC [POMS_DB].[dbo].[P_Generate_AddressID] @Ret_ADDRESS_ID = @Address_ID OUT

		SET @ADDRESS_CODE = 'A' + format(@Address_ID, '000000')

		INSERT INTO [POMS_DB].[dbo].T_Address_List (
			ADDRESS_ID
			,ADDRESS_CODE
			,ST_CODE
			,ServiceType_MTV_ID
			,IsResidentialAddress
			,FirstName
			,MiddleName
			,LastName
			,Company
			,ContactPerson
			,Address
			,Address2
			,City
			,STATE
			,ZipCode
			,County
			,CountryRegionCode
			,Email
			,Mobile
			,Phone
			,PhoneExt
			,Latitude
			,Longitude
			,PlaceID
			,AddressType_MTV_ID
			,AddressStatus_MTV_ID
			,Comment
			,IsActive
			,AddedBy
			,AddedOn
			)
		VALUES (
			@Address_ID
			,@ADDRESS_CODE
			,@ST_CODE
			,@ServiceType_MTV_ID
			,@IsResidentialAddress
			,@FirstName
			,@MiddleName
			,@LastName
			,@Company
			,@ContactPerson
			,@Address
			,@Address2
			,@City
			,@State
			,@ZipCode
			,@County
			,@CountryRegionCode
			,@Email
			,@Mobile
			,@Phone
			,@PhoneExt
			,@Latitude
			,@Longitude
			,@PlaceID
			,@AddressType_MTV_ID
			,@AddressStatus_MTV_ID
			,@Comment
			,@IsActive
			,@Username
			,GETUTCDATE()
			);

		SET @Return_Text = 'Address List Added Successfully!'
		SET @Return_Code = 1
	END

	SELECT @Return_Text Return_Text
		,@Return_Code Return_Code
END
GO
