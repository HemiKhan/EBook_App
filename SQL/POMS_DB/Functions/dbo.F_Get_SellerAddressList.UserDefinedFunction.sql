USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_SellerAddressList]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_SellerAddressList] ('','S100052','ABDULLAH.ARSHAD',130100,null,0)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_SellerAddressList]
(	
	@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@Username nvarchar(150) = null
	,@AddressType int
	,@AddressCode nvarchar(20) = null
	,@IsApplyUserCheck bit = 1
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

	set @SELLER_KEY = isnull(@SELLER_KEY,'')
	set @Username = isnull(@Username,'')

	Declare @SellerTable table (SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250))
	
	if @SELLER_CODE is null
	begin
		insert into @SellerTable
		select SellerKey , SellerCode , SellerName from [POMS_DB].[dbo].[F_Get_SellToClientList] (@SELLER_KEY,null)
	end
	else
	begin
		insert into @SellerTable
		select @SELLER_KEY, @SELLER_CODE, ''
	end

	Declare @AddressListTable table ([ADDRESS_CODE] nvarchar(20))
	insert into @AddressListTable
	select Distinct al.[ADDRESS_CODE] 
	from [POMS_DB].[dbo].[T_Address_List] al with (nolock)
	inner join [POMS_DB].[dbo].[T_Seller_Address_Mapping] sam with (nolock) on sam.ADDRESS_CODE = al.ADDRESS_CODE and sam.IsActive = 1 and al.IsActive = 1 
	inner join @SellerTable st on sam.SELLER_CODE = st.SellerCode
	left join [POMS_DB].[dbo].[T_User_Seller_Address_Mapping] usam with (nolock) on usam.SAM_ID = usam.SAM_ID and usam.IsActive = 1 
	where ((usam.UserName = @Username and @IsApplyUserCheck = 1) or @IsApplyUserCheck = 0)
	and al.AddressType_MTV_ID = @AddressType and al.[AddressStatus_MTV_ID] = 131101
	and ((al.ADDRESS_CODE = @AddressCode and @AddressCode is not null) or @AddressCode is null)

	insert into @AddressListTable
	select Distinct al.[ADDRESS_CODE] 
	from [POMS_DB].[dbo].[T_Address_List] al with (nolock)
	inner join [POMS_DB].[dbo].[T_Seller_Address_Mapping] sam with (nolock) on sam.ADDRESS_CODE = al.ADDRESS_CODE and sam.IsActive = 1 and al.IsActive = 1 and sam.SELLER_CODE = ''
	left join [POMS_DB].[dbo].[T_User_Seller_Address_Mapping] usam with (nolock) on usam.SAM_ID = usam.SAM_ID and usam.IsActive = 1 
	where ((usam.UserName = @Username and @IsApplyUserCheck = 1) or @IsApplyUserCheck = 0)
	and al.AddressType_MTV_ID = @AddressType and al.[AddressStatus_MTV_ID] = 131101
	and ((al.ADDRESS_CODE = @AddressCode and @AddressCode is not null) or @AddressCode is null)

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
