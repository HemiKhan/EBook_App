USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_SellerAddressList]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_SellerAddressList] 'ABDULLAH.ARSHAD','130100'
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_SellerAddressList]
	-- Add the parameters for the stored procedure here
	@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@Username nvarchar(150) = null
	,@AddressType int
	,@AddressCode nvarchar(20) = null
	,@IsApplyUserCheck bit = 1
AS
BEGIN
	
	select ADDRESS_ID,ADDRESS_CODE,ST_CODE,ServiceType_MTV_ID,ServiceType_Name,IsResidentialAddress,FirstName,MiddleName,LastName,Company,ContactPerson,[Address],Address2,City
	,[State],ZipCode,County,CountryRegionCode,Email,Mobile,Phone,PhoneExt,Latitude,Longitude,PlaceID,AddressType_MTV_ID,AddressType_Name,AddressStatus_MTV_ID,AddressStatus_Name 
	from [POMS_DB].[dbo].[F_Get_SellerAddressList] (@SELLER_KEY ,@SELLER_CODE ,@Username ,@AddressType ,@AddressCode ,@IsApplyUserCheck)

END
GO
