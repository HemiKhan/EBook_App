USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_ClientIdentifier_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_Order_Detail_ClientIdentifier_By_OrderID] (10100640,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_ClientIdentifier_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([ORDER_ID] int
, [Code] nvarchar(20)
, [Name] nvarchar(50)
, [Value] nvarchar(250)
, [IsRequired] bit
, [IsDuplicateAllowed] bit
, [IsModifyAllowed] bit
, [IsHidden] bit
, [CharacterLimit] int
)
AS
begin
	
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	--select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @SellerCode nvarchar(20) = ''
	select @SellerCode = o.SELLER_CODE from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID

	Declare @ClientIndentifierTable table
	(SellerKey nvarchar(36)
	,SellerCode nvarchar(20)
	,SellerName nvarchar(250)
	,OIF_CODE nvarchar(50)
	,[Description] nvarchar(250)
	,[IsRequired] bit
	,[IsDuplicateAllowed] bit
	,[IsModifyAllowed] bit
	,[IsHidden] bit
	,[IsAllowed] bit
	,[CharacterLimit] int
	,[IsActive] bit)
	
	insert into @ClientIndentifierTable (SellerKey ,SellerCode ,SellerName ,OIF_CODE ,[Description] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden] ,[IsAllowed] ,[CharacterLimit] ,[IsActive])
	select SellerKey ,SellerCode ,SellerName ,OIF_CODE ,[Description] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden] ,[IsAllowed] ,[CharacterLimit] ,[IsActive] 
	from [POMS_DB].[dbo].[F_Get_Order_Client_Identifier_Fields_List] (null, @SellerCode,null)
	
	insert into @ReturnTable ([ORDER_ID] , [Code] , [Name] , [Value] , [IsRequired] , [IsDuplicateAllowed] , [IsModifyAllowed] ,[IsHidden] ,[CharacterLimit])
	select ORDER_ID = @ORDER_ID, cit.OIF_CODE, cit.[Description], oci.[Value_], cit.[IsRequired] , cit.[IsDuplicateAllowed] , cit.[IsModifyAllowed] ,cit.[IsHidden], cit.[CharacterLimit]
	from @ClientIndentifierTable cit
	left join [POMS_DB].[dbo].[T_Order_Client_Identifier] oci with (nolock) on cit.OIF_CODE = oci.OIF_CODE and oci.ORDER_ID = @ORDER_ID

	return
	

end
GO
