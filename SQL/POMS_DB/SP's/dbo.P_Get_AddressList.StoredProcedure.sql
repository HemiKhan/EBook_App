USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_AddressList]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_AddressList] 'ABDULLAH.ARSHAD','130100','A000005'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_AddressList]
	-- Add the parameters for the stored procedure here
	@Username nvarchar(150) 
	,@AddressType int
	,@AddressCode nvarchar(20) 
AS
BEGIN
	
	select ADDRESS_ID,ADDRESS_CODE,ST_CODE,ServiceType_MTV_ID,ServiceType_Name,IsResidentialAddress,FirstName,MiddleName,LastName,Company,ContactPerson,[Address],Address2,City
	,[State],ZipCode,County,CountryRegionCode,Email,Mobile,Phone,PhoneExt,Latitude,Longitude,PlaceID,AddressType_MTV_ID,AddressType_Name,AddressStatus_MTV_ID,AddressStatus_Name 
	from [POMS_DB].[dbo].[F_Get_AddressList] (@Username ,@AddressType ,@AddressCode)

END
GO
