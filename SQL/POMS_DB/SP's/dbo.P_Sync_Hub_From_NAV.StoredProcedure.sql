USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sync_Hub_From_NAV]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Sync_Hub_From_NAV]
	
AS
BEGIN
	
	Begin Transaction

	begin try

		drop table if exists #tmp
		select [HUB_CODE]=[Code]
		,[HubName]=[Wharehouse Name]
		,[Address]=[Address]
		,[Address2]=[Address 2]
		,[City]=[City]
		,[ZipCode]=[Post Code]
		,[County]=''
		,[CountryRegionCode]=[Country_Region Code]
		,[LHBuffer]=[LH Buffer]
		,[FMBuffer]=[FM Buffer]
		,[TIMEZONE_ID]=[Time Zone ID]
		,[IsActive]=[Active Status]
		,[IsActiveOnMap]=[Active Status]
		,[Region_MTV_CODE]=(case when [Region] = 'Central' then 'CENTRAL'
			when [Region] = 'NorthEast' then 'NORTHEAST'
			when [Region] = 'NorthWest' then 'NORTHWEST'
			when [Region] = 'SouthEast' then 'SOUTHEAST'
			when [Region] = 'West' then 'WEST'
			when [Region] = '' and Code = 'EV-CD' then 'WEST'
			when [Region] = '' and Code = 'NC-CD' then 'SOUTHEAST'
			else '' end)
		,[LocationType_MTV_CODE]=(case when [Code] in ('EV-CD','NC-CD') then 'MWD-CROSSDOCK' else 'MWD-WH' end)
		,[SqFeet]=[SqFeet]
		,[Latitude]=[Latitude]
		,[Longitude]=[Longitude]
		,[PlaceID]=[PlaceID]
		,[HUB_ZONE]=[DestZone]
		,[State]=[State Abbr]
		,[NAV_DIMENSION_CODE]=[NAV Dimension Value] 
		into #tmp
		from [MetroPolitanNavProduction].[dbo].[Metropolitan$TR Warehouse Hub] with (nolock) where Location_Type = 10000

		MERGE [POMS_DB].[dbo].[T_Hub_List] AS Target
			USING #tmp AS Source
			ON Source.[HUB_CODE] = Target.[HUB_CODE] collate Latin1_General_100_CS_AS
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT ([HUB_CODE],[HubName],[Address],[Address2],[City],[State],[ZipCode],[County],[CountryRegionCode],[Latitude],[Longitude],[PlaceID],[IsActive],[IsActiveOnMap]
				,[TIMEZONE_ID],[Region_MTV_CODE],[SqFeet],[LocationType_MTV_CODE],[HUB_ZONE],[NAV_DIMENSION_CODE],[LHBuffer],[FMBuffer],[AddedBy]) 
				
				VALUES (Source.[HUB_CODE],Source.[HubName],Source.[Address],Source.[Address2],Source.[City],Source.[State],Source.[ZipCode],Source.[County],Source.[CountryRegionCode]
				,Source.[Latitude],Source.[Longitude],Source.[PlaceID],Source.[IsActive],Source.[IsActiveOnMap],Source.[TIMEZONE_ID],Source.[Region_MTV_CODE],Source.[SqFeet]
				,Source.[LocationType_MTV_CODE],Source.[HUB_ZONE],Source.[NAV_DIMENSION_CODE],Source.[LHBuffer],Source.[FMBuffer],'AUTOSYNC')

			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.[HubName]				=	Source.[HubName]
				,Target.[Address]				=	Source.[Address]
				,Target.[Address2]				=	Source.[Address2]
				,Target.[City]					=	Source.[City]
				,Target.[State]					=	Source.[State]
				,Target.[ZipCode]				=	Source.[ZipCode]
				,Target.[County]				=	Source.[County]
				,Target.[CountryRegionCode]		=	Source.[CountryRegionCode]
				,Target.[Latitude]				=	Source.[Latitude]
				,Target.[Longitude]				=	Source.[Longitude]
				,Target.[PlaceID]				=	Source.[PlaceID]
				,Target.[IsActive]				=	Source.[IsActive]
				,Target.[IsActiveOnMap]			=	Source.[IsActiveOnMap]
				,Target.[TIMEZONE_ID]			=	Source.[TIMEZONE_ID]
				,Target.[Region_MTV_CODE]		=	Source.[Region_MTV_CODE]
				,Target.[SqFeet]				=	Source.[SqFeet]
				,Target.[LocationType_MTV_CODE]	=	Source.[LocationType_MTV_CODE]
				,Target.[HUB_ZONE]				=	Source.[HUB_ZONE]
				,Target.[NAV_DIMENSION_CODE]	=	Source.[NAV_DIMENSION_CODE]
				,Target.[LHBuffer]				=	Source.[LHBuffer]
				,Target.[FMBuffer]				=	Source.[FMBuffer]
				,Target.[ModifiedBy]			= 'AUTOSYNC' 
				,Target.[ModifiedOn]			= getutcdate();
		
		if @@TRANCOUNT > 0
		begin
			COMMIT; 
		end
	end try
	begin catch
		if @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		print ERROR_MESSAGE()
	end catch

END
GO
