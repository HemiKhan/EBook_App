USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetAddressListModal]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec [P_GetAddressListModal] 1
CREATE Procedure [dbo].[P_GetAddressListModal]
@Address_ID int
As
Begin
SELECT ADDRESS_ID, ADDRESS_CODE, ST_CODE, ServiceType_MTV_ID, IsResidentialAddress, FirstName, MiddleName, LastName, Company, ContactPerson, [Address], Address2, City ,[State], ZipCode,
County, CountryRegionCode,Email,Mobile,Phone,PhoneExt,Latitude,Longitude,PlaceID,AddressType_MTV_ID,AddressStatus_MTV_ID As Sp_AddressStatus_MTV_ID,Comment,IsActive
FROM [POMS_DB].[dbo].[T_Address_List] WITH (NOLOCK) WHERE Address_ID = @Address_ID
End


 
GO
