USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProdArchive_OrderDetail_ClientIdentifier_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProdArchive_Order_Detail_ClientIdentifier_By_OrderID] (3251020,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProdArchive_OrderDetail_ClientIdentifier_By_OrderID]
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
)
AS
begin
	
	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	--select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @SellerCode nvarchar(20) = ''
	select @SellerCode = sh.[Bill-to Customer No_] from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Header] sh with (nolock) where sh.[No_] = @ORDER_NO
	set @SellerCode = replace(isnull(@SellerCode,''),'C','S')

	if @SellerCode = ''
	begin
		return
	end

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
	,[IsActive] bit)
	
	insert into @ClientIndentifierTable (SellerKey ,SellerCode ,SellerName ,OIF_CODE ,[Description] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden] ,[IsAllowed] ,[IsActive])
	select SellerKey ,SellerCode ,SellerName ,OIF_CODE ,[Description] ,[IsRequired] ,[IsDuplicateAllowed] ,[IsModifyAllowed] ,[IsHidden] ,[IsAllowed] ,[IsActive] 
	from [POMS_DB].[dbo].[F_Get_Order_Client_Identifier_Fields_List] (null, @SellerCode,null)

	Declare @ClientIndentifierValuesTable table
	([ORDER_ID] int
	,[Carrier Name] nvarchar(50)
	,[Carrier PRO] nvarchar(250)
	,[Carrier Tag] nvarchar(50)
	,[Client Refrence #1] nvarchar(50)
	,[Client Refrence #2] nvarchar(50))
	
	insert into @ClientIndentifierValuesTable ([ORDER_ID] ,[Carrier Name] ,[Carrier PRO] ,[Carrier Tag] ,[Client Refrence #1] ,[Client Refrence #2])
	select ORDER_ID = @ORDER_ID, sl.[Carrier Name] ,sl.[Carrier PRO] ,sl.[Carrier Tag] ,sl.[Client Refrence #1] ,sl.[Client Refrence #2]
	from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) where sl.[Document No] = @ORDER_NO
	
	insert into @ReturnTable ([ORDER_ID] , [Code] , [Name] , [Value] , [IsRequired] , [IsDuplicateAllowed] , [IsModifyAllowed] ,[IsHidden])
	select * from (
		select civt1.ORDER_ID , cit1.OIF_CODE, cit1.[Description], [Value] = civt1.[Client Refrence #1], [IsRequired] = 0 , [IsDuplicateAllowed] = 0 , [IsModifyAllowed] = 1 , [IsHidden] = 0
		from @ClientIndentifierValuesTable civt1
		cross apply @ClientIndentifierTable cit1 
		where cit1.OIF_CODE = 'PONUMBER'
		
		union
		
		select civt2.ORDER_ID , cit2.OIF_CODE, cit2.[Description], [Value] = civt2.[Carrier Name], [IsRequired] = 0 , [IsDuplicateAllowed] = 1 , [IsModifyAllowed] = 1 , [IsHidden] = 0
		from @ClientIndentifierValuesTable civt2
		cross apply @ClientIndentifierTable cit2
		where cit2.OIF_CODE = 'CARRIER'
		
		union
		
		select civt3.ORDER_ID , cit3.OIF_CODE, cit3.[Description], [Value] = civt3.[Carrier PRO], [IsRequired] = 0 , [IsDuplicateAllowed] = 1 , [IsModifyAllowed] = 1 , [IsHidden] = 0
		from @ClientIndentifierValuesTable civt3
		cross apply @ClientIndentifierTable cit3 
		where cit3.OIF_CODE = 'PRO'
		
		union
		
		select civt4.ORDER_ID , cit4.OIF_CODE, cit4.[Description], [Value] = civt4.[Client Refrence #2], [IsRequired] = 0 , [IsDuplicateAllowed] = 1 , [IsModifyAllowed] = 1 , [IsHidden] = 0
		from @ClientIndentifierValuesTable civt4
		cross apply @ClientIndentifierTable cit4 
		where cit4.OIF_CODE = 'REF2'
		
		union
		
		select civt5.ORDER_ID , cit5.OIF_CODE, cit5.[Description], [Value] = civt5.[Carrier Tag], [IsRequired] = 0 , [IsDuplicateAllowed] = 1 , [IsModifyAllowed] = 1 , [IsHidden] = 0
		from @ClientIndentifierValuesTable civt5
		cross apply @ClientIndentifierTable cit5 
		where cit5.OIF_CODE = 'TAG'
	) ilv

	return
	

end
GO
