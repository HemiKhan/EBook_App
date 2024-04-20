USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_JsonAddressInfo]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_AddressInfo] ('C100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_JsonAddressInfo]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(FirstName nvarchar(50)
,MiddleName nvarchar(50)
,LastName nvarchar(50)
,Company nvarchar(250)
,ContactPerson nvarchar(50)
,[Address] nvarchar(250)
,Address2 nvarchar(250)
,City nvarchar(50)
,[State] nvarchar(5)
,ZipCode nvarchar(10)
,County nvarchar(50)
,CountryRegionCode nvarchar(10)
,Email nvarchar(250)
,Mobile nvarchar(30)
,Phone nvarchar(20)
,PhoneExt nvarchar(10)
,IsValidAddress bit
,Lat nvarchar(30)
,Lng nvarchar(30)
,PlaceID nvarchar(500)
)
AS
begin
	
	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end
	
	insert into @ReturnTable
	select addr.* 
	from OpenJson(@Json)
	WITH (
		FirstName nvarchar(50) '$.firstname'
		,MiddleName nvarchar(50) '$.middlename'
		,LastName nvarchar(50) '$.lastname'
		,Company nvarchar(250) '$.company'
		,ContactPerson nvarchar(50) '$.contactperson'
		,[Address] nvarchar(250) '$.address'
		,Address2 nvarchar(250) '$.address2'
		,City nvarchar(50) '$.city'
		,[State] nvarchar(5) '$.state'
		,ZipCode nvarchar(10) '$.zipcode'
		,County nvarchar(50) '$.county'
		,CountryRegionCode nvarchar(10) '$.countryregioncode'
		,Email nvarchar(250) '$.email'
		,Mobile nvarchar(30) '$.mobile'
		,Phone nvarchar(20) '$.phone'
		,PhoneExt nvarchar(10) '$.phoneext'
		,IsValidAddress bit '$.isvalidaddress'
		,Lat nvarchar(30) '$.lat'
		,Lng nvarchar(30) '$.lng'
		,PlaceID nvarchar(500) '$.placeid'
	) addr

	return

end
GO
