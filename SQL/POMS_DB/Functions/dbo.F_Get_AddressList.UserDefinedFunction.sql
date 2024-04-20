USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_AddressList]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_AddressList] ('ABDULLAH.ARSHAD',130100,'A100005')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_AddressList]
(	
	@Username nvarchar(150) 
	,@AddressType int
	,@AddressCode nvarchar(20) 
)
RETURNS @ReturnTable TABLE 
([ADDRESS_ID] [int] 
,[ADDRESS_CODE] [nvarchar](50) 
,[ST_CODE] [nvarchar](20) 
,[ServiceType_MTV_ID] [int] 
,[ServiceType_Name] [nvarchar](250) 
,[IsResidentialAddress] [bit] 
,[FirstName] [nvarchar](50) 
,[MiddleName] [nvarchar](50) 
,[LastName] [nvarchar](50) 
,[Company] [nvarchar](250) 
,[ContactPerson] [nvarchar](150) 
,[Address] [nvarchar](250) 
,[Address2] [nvarchar](250) 
,[City] [nvarchar](50) 
,[State] [nvarchar](5) 
,[ZipCode] [nvarchar](10) 
,[County] [nvarchar](50) 
,[CountryRegionCode] [nvarchar](10) 
,[Email] [nvarchar](250) 
,[Mobile] [nvarchar](30) 
,[Phone] [nvarchar](20) 
,[PhoneExt] [nvarchar](10) 
,[Latitude] [nvarchar](30) 
,[Longitude] [nvarchar](30) 
,[PlaceID] [nvarchar](max) 
,[AddressType_MTV_ID] [int] 
,[AddressType_Name] [nvarchar](250) 
,[AddressStatus_MTV_ID] [int] 
,[AddressStatus_Name] [nvarchar](250)
)
AS
begin

	Declare @AddressListTable table ([ADDRESS_CODE] nvarchar(20))
	insert into @AddressListTable
	select Distinct al.[ADDRESS_CODE] 
	from [POMS_DB].[dbo].[T_Address_List] al with (nolock)
	where al.AddressType_MTV_ID = @AddressType and al.[AddressStatus_MTV_ID] = 131101
	and al.ADDRESS_CODE = @AddressCode

	insert into @ReturnTable
	select Distinct [ADDRESS_ID] ,al.[ADDRESS_CODE] ,[ST_CODE] ,[ServiceType_MTV_ID] = [ServiceType_MTV_ID]
	,[ServiceType_Name] = (select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_ID = [AddressType_MTV_ID] and MT_ID = 125)
	,[IsResidentialAddress] = [IsResidentialAddress] ,[FirstName] ,[MiddleName] ,[LastName] ,[Company] ,[ContactPerson] , [Address] ,[Address2] ,[City] ,[State] ,[ZipCode] 
	,[County] ,[CountryRegionCode] ,[Email] ,[Mobile] ,[Phone] ,[PhoneExt] ,[Latitude] ,[Longitude] ,[PlaceID] ,[AddressType_MTV_ID] 
	,[AddressType_Name] = (select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_ID = al.[AddressType_MTV_ID] and MT_ID = 130)
	,[AddressStatus_MTV_ID]
	,[AddressStatus_Name] = (select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_ID = al.[AddressStatus_MTV_ID] and MT_ID = 131)
	from [POMS_DB].[dbo].[T_Address_List] al with (nolock)
	where al.ADDRESS_CODE in (select alt.[ADDRESS_CODE] from @AddressListTable alt)

	return
	

end
GO
