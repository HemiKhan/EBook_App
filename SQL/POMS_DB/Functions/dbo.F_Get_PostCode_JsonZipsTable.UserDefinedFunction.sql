USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PostCode_JsonZipsTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PostCode_JsonZipsTable] ('[{"zipcode":"08861","type_": 1},{"zipcode":"27260","type_": 2},{"zipcode":"91752","type_": 3}]')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PostCode_JsonZipsTable]
(	
	@ZipJson nvarchar(max) 
)
RETURNS @ReturnTable TABLE 
([ZipCode] nvarchar(20), Type_ int, TypeName nvarchar(50)
--, [Country_Region Code] nvarchar(10), [Zone ID] nvarchar(10)
, [State] nvarchar(10), Latitude decimal(16,8)
, Longitude decimal(16,8)
--, [Is Remote] bit, [Is Outsource] bit, [Is_Ferry] bit, [Time Zone ID] int
, [TIMEZONE_ID] int, DrivingMiles decimal(38,17), MilesRadius decimal(38,17)
, AreaType_MTV_ID int
, [Area_Type_Name] nvarchar(50)
, Carrier nvarchar(50)
--, [PinAreaTypeCode] int, [PinAreaTypeName] nvarchar(50)
, [HubCode] nvarchar(20), HubName nvarchar(50), HubAddress nvarchar(250)
, [HubAddress2] nvarchar(250), HubCity nvarchar(30), HubState nvarchar(5), [HubPostCode] nvarchar(10), [HubZone] nvarchar(10)
--, [HubZonePostCode] nvarchar(10)
)
AS
begin
	
	--Type	Name
	--1		BillTo
	--2		ShipFrom
	--3		ShipTo

	
	Declare @ZipsList table (zipcode nvarchar(20), type_ int, typename nvarchar(50))
	if ISJSON(@ZipJson) = 1
	begin
		insert into @ZipsList
		select zipcode = isnull(ilv.zipcode,'')
		,type_ = isnull(type_,0)
		,typename = (case when ilv.type_ is null then ''
			when ilv.type_ = 1 then 'BillTo'
			when ilv.type_ = 2 then 'ShipFrom'
			when ilv.type_ = 3 then 'ShipTo'
			else '' end)
		from (
			select ziplist.* from openjson(@ZipJson)
			WITH (
				zipcode nvarchar(20) '$.zipcode'
				,type_ int '$.type_'
			) ziplist
		) ilv where zipcode <> ''
	end

	insert into @ReturnTable ([ZipCode], Type_, TypeName, [State], Latitude, Longitude, [TIMEZONE_ID], DrivingMiles
	,MilesRadius, AreaType_MTV_ID, [Area_Type_Name], Carrier, [HubCode], HubName, HubAddress, [HubAddress2], HubCity, HubState, [HubPostCode], [HubZone])
	select distinct Zipcode=pca.[ZipCode], Type_=zl.type_, TypeName=zl.typename, pca.[State], pca.Latitude, pca.Longitude, pca.[TIMEZONE_ID], pca.[DrivingMiles]
	, pca.[MilesRadius] , AreaType_MTV_ID, [Area_Type_Name], Carrier, [HubCode] ,HubName, HubAddress, [HubAddress2], HubCity, HubState, [HubPostCode], [HubZone]
	FROM [POMS_DB].[dbo].[V_Post_Code_AreasType] pca with (nolock) inner join @ZipsList zl on pca.ZipCode = zl.zipcode

	return

end
GO
