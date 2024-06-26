USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sync_Seller_From_NAV]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Sync_Seller_From_NAV]
	
AS
BEGIN
	
	Begin Transaction

	begin try

		drop table if exists #tmp
		select [SELLER_ID]=cast(replace(No_,'C','') as int)
		  ,[SELLER_CODE]=replace(No_,'C','S')
		  ,[SELLER_KEY]=upper(cast([Customer GUID] as nvarchar(36)))
		  ,[Company]=[Name]
		  ,[ContactPerson]=Contact
		  ,[Address]=[Address]
		  ,[Address2]=[Address 2]
		  ,[City]=City
		  ,[State]=County
		  ,[ZipCode]=[Post Code]
		  ,[County]=County
		  ,[CountryRegionCode]=[Country_Region Code]
		  ,[EmailTo]=[E-Mail]
		  ,[EmailCC]=[CC Email]
		  ,[Mobile]=Mobile
		  ,[Mobile2]=null
		  ,[Phone]=[Phone No_]
		  ,[PhoneExt]=null
		  ,[Phone2]=null
		  ,[Phone2Ext]=null
		  ,[D_ID]=null
		  ,[IsActive]=[Is Active]
		into #tmp
		from [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] with (nolock) 

		MERGE [POMS_DB].[dbo].[T_Seller_List] AS Target
			USING #tmp AS Source
			ON Source.[SELLER_ID] = Target.[SELLER_ID]
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT ([SELLER_ID],[SELLER_CODE],[SELLER_KEY],[Company],[ContactPerson],[Address],[Address2],[City],[State],[ZipCode],[County],[CountryRegionCode],[EmailTo],[EmailCC]
				,[Mobile],[Mobile2],[Phone],[PhoneExt],[Phone2],[Phone2Ext],[D_ID],[IsActive],[AddedBy]) 
				
				VALUES (Source.[SELLER_ID],Source.[SELLER_CODE],Source.[SELLER_KEY],Source.[Company],Source.[ContactPerson],Source.[Address],Source.[Address2],Source.[City],Source.[State]
				,Source.[ZipCode],Source.[County],Source.[CountryRegionCode],Source.[EmailTo],Source.[EmailCC],Source.[Mobile],Source.[Mobile2],Source.[Phone],Source.[PhoneExt]
				,Source.[Phone2],Source.[Phone2Ext],Source.[D_ID],Source.[IsActive],'AUTOSYNC')

			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.[SELLER_CODE]			=	Source.[SELLER_CODE]
				,Target.[SELLER_KEY]			=	Source.[SELLER_KEY]
				,Target.[Company]				=	Source.[Company]
				,Target.[ContactPerson]			=	Source.[ContactPerson]
				,Target.[Address]				=	Source.[Address]
				,Target.[Address2]				=	Source.[Address2]
				,Target.[City]					=	Source.[City]
				,Target.[State]					=	Source.[State]
				,Target.[ZipCode]				=	Source.[ZipCode]
				,Target.[County]				=	Source.[County]
				,Target.[CountryRegionCode]		=	Source.[CountryRegionCode]
				,Target.[EmailTo]				=	Source.[EmailTo]
				,Target.[EmailCC]				=	Source.[EmailCC]
				,Target.[Mobile]				=	Source.[Mobile]
				,Target.[Mobile2]				=	Source.[Mobile2]
				,Target.[Phone]					=	Source.[Phone]
				,Target.[PhoneExt]				=	Source.[PhoneExt]
				,Target.[Phone2]				=	Source.[Phone2]
				,Target.[Phone2Ext]				=	Source.[Phone2Ext]
				,Target.[D_ID]					=	Source.[D_ID]
				,Target.[IsActive]				=	Source.[IsActive]
				,Target.[ModifiedBy]			= 'AUTOSYNC' 
				,Target.[ModifiedOn]			= getutcdate();

		MERGE [POMS_DB].[dbo].[T_Seller_BillTo_Mapping] AS Target
			USING #tmp AS Source
			ON Source.[SELLER_KEY] = Target.[SELLER_KEY] Collate database_default
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT ([SELLER_KEY],[BillTo_CUSTOMER_KEY],[AddedBy]) 
				
				VALUES (Source.[SELLER_KEY],Source.[SELLER_KEY],'AUTOSYNC');

		
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
