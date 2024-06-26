USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sync_SKUs_From_Pinnacle]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Sync_SKUs_From_Pinnacle]
	
AS
BEGIN
	
	Begin Transaction

	begin try

		drop table if exists #tmp
		select 
		SELLER_KEY=SELLER_KEY
		,SELLER_CODE=[CustomerNo]
		,Type_MTV_CODE=(case when isnull(ItemType,'') <> '' then (select top 1 mtv.MTV_CODE from [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MTV_CODE = upper(ItemType) collate Latin1_General_100_CS_AS) else null end)
		,MasterSKU_No=MasterSkuNo
		,MasterSKUDescription
		,SKU_No=[ItemSKU]
		,[Description]=[ItemDescription]
		,IsMasterSKU
		,[Weight]=[ItemWeight]
		,WeightUnit_MTV_CODE='LB'
		,DimLength=[DimLength]
		,DimWidth=[DimWidth]
		,DimHeight=[DimHeight]
		,DimUnit_MTV_CODE='IN'
		,CalculatedCuFt=round((case when ([DimLength]*[DimWidth]*[DimHeight]) > 0 then ([DimLength]*[DimWidth]*[DimHeight]) / 1728.00 else 0 end),2)
		,UserCuFt=null
		,[Value]=(case when isnull([ItemValue],0) = 0 then null else [ItemValue] end)
		,Sort_=SortPos
		,IsActive=[IsActive]
		,AddedBy=aun.Username
		,AddedOn=[DateCreated]
		,ModifiedBy=mun.Username
		,ModifiedOn=[DateModified]
		into #tmp 
		from (
			SELECT sl.ID
			  ,SELLER_KEY=(select top 1 sl2.SELLER_KEY from [POMS_DB].[dbo].[T_Seller_List] sl2 with (nolock) where sl2.SELLER_CODE = replace(sl.[CustomerNo],'C','S') collate Latin1_General_100_CS_AS)
			  ,[CustomerNo]=replace(sl.[CustomerNo],'C','S')
			  ,MasterSkuNo=(select top 1 sl1.ItemSKU from [PinnacleProd].[dbo].[Metropolitan_SKUList] sl1 with (nolock) where sl1.ID = skcm.SKU_KitID)
			  ,MasterSKUDescription=(select top 1 sl1.ItemDescription from [PinnacleProd].[dbo].[Metropolitan_SKUList] sl1 with (nolock) where sl1.ID = skcm.SKU_KitID)
			  ,sl.[ItemSKU]
			  ,sl.[ItemDescription]
			  ,IsMasterSKU=1
			  ,sl.[IsKitItem]
			  ,sl.[ItemWeight]
			  ,sl.[DimLength]
			  ,sl.[DimWidth]
			  ,sl.[DimHeight]
			  ,sl.[ItemValue]
			  ,sl.[IsActive]
			  ,sl.[DateCreated]
			  ,sl.[CreatedBy]
			  ,sl.[CreationSource]
			  ,sl.[DateModified]
			  ,sl.[ModifiedBy]
			  ,sl.[ModificationSource]
			  ,sl.[ItemType]
			  ,sl.[ItemCuFt]
			  ,sl.[DimUnit]
			  ,SortPos=skcm.SortPos
			FROM [PinnacleProd].[dbo].[Metropolitan_SKUList] sl with (nolock)
			inner join [PinnacleProd].[dbo].[Metropolitan_SKU_KitComponentMap] skcm with (nolock) on skcm.SKU_ComponentID = sl.ID and skcm.[IsActive] = 1
			where upper(sl.[CustomerNo]) like '%C%' and sl.IsKitItem = 0
			union
			SELECT sl.ID
			  ,SELLER_KEY=(select top 1 sl1.SELLER_KEY from [POMS_DB].[dbo].[T_Seller_List] sl1 with (nolock) where sl1.SELLER_CODE = replace(sl.[CustomerNo],'C','S') collate Latin1_General_100_CS_AS)
			  ,[CustomerNo]=replace(sl.[CustomerNo],'C','S')
			  ,MasterSkuNo=sl.[ItemSKU]
			  ,MasterSKUDescription=''
			  ,sl.[ItemSKU]
			  ,sl.[ItemDescription]
			  ,IsMasterSKU=0
			  ,sl.[IsKitItem]
			  ,sl.[ItemWeight]
			  ,sl.[DimLength]
			  ,sl.[DimWidth]
			  ,sl.[DimHeight]
			  ,sl.[ItemValue]
			  ,sl.[IsActive]
			  ,sl.[DateCreated]
			  ,sl.[CreatedBy]
			  ,sl.[CreationSource]
			  ,sl.[DateModified]
			  ,sl.[ModifiedBy]
			  ,sl.[ModificationSource]
			  ,sl.[ItemType]
			  ,sl.[ItemCuFt]
			  ,sl.[DimUnit]
			  ,SortPos=1
			FROM [PinnacleProd].[dbo].[Metropolitan_SKUList] sl with (nolock)
			left join [PinnacleProd].[dbo].[Metropolitan_SKU_KitComponentMap] skcm with (nolock) on skcm.SKU_ComponentID = sl.ID and skcm.[IsActive] = 1
			where upper(sl.[CustomerNo]) like '%C%' and sl.IsKitItem = 0 and skcm.SKU_ComponentID is null 
		) ilv outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] ((case when isnull(ilv.[CreatedBy],0) = 0 then 934 else ilv.[CreatedBy] end)) aun
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] ((case when isnull(ilv.[ModifiedBy],0) = 0 then null else ilv.[ModifiedBy] end)) mun
		where SELLER_KEY is not null
		order by ilv.ID 

		MERGE [POMS_DB].[dbo].[T_Seller_Sku_Setup] AS Target
			USING #tmp AS Source
			ON Source.SELLER_KEY = Target.SELLER_KEY collate Latin1_General_100_CS_AS and Source.MasterSKU_No = Target.MasterSKU_No collate Latin1_General_100_CS_AS and Source.SKU_No = Target.SKU_No collate Latin1_General_100_CS_AS
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT (SELLER_KEY,[Type_MTV_CODE],[MasterSKU_No],MasterSKUDescription,[SKU_No],[Description],[IsMasterSKU],[Weight],[WeightUnit_MTV_CODE],[DimLength]
				,[DimWidth],[DimHeight],[DimUnit_MTV_CODE],[CalculatedCuFt],[UserCuFt],[Value],[Sort_],[IsActive],[AddedBy],[AddedOn],[ModifiedBy],[ModifiedOn]) 
				
				VALUES (Source.SELLER_KEY,Source.[Type_MTV_CODE],Source.[MasterSKU_No],Source.MasterSKUDescription,Source.[SKU_No],Source.[Description],Source.[IsMasterSKU]
				,Source.[Weight],Source.[WeightUnit_MTV_CODE],Source.[DimLength],Source.[DimWidth],Source.[DimHeight],Source.[DimUnit_MTV_CODE],Source.[CalculatedCuFt]
				,Source.[UserCuFt],Source.[Value],Source.[Sort_],Source.[IsActive],Source.[AddedBy],Source.[AddedOn],Source.[ModifiedBy],Source.[ModifiedOn])

			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.[Type_MTV_CODE]			= Source.[Type_MTV_CODE] 
				,Target.[MasterSKUDescription]	= Source.[MasterSKUDescription]
				,Target.[Description]			= Source.[Description] 
				,Target.[IsMasterSKU]			= Source.[IsMasterSKU] 
				,Target.[Weight]				= Source.[Weight] 
				,Target.[WeightUnit_MTV_CODE]	= Source.[WeightUnit_MTV_CODE] 
				,Target.[DimLength]				= Source.[DimLength] 
				,Target.[DimWidth]				= Source.[DimWidth] 
				,Target.[DimHeight]				= Source.[DimHeight] 
				,Target.[DimUnit_MTV_CODE]		= Source.[DimUnit_MTV_CODE] 
				,Target.[CalculatedCuFt]		= Source.[CalculatedCuFt] 
				,Target.[UserCuFt]				= Source.[UserCuFt] 
				,Target.[Value]					= Source.[Value] 
				,Target.[Sort_]					= Source.[Sort_] 
				,Target.[IsActive]				= Source.[IsActive] 
				,Target.[AddedBy]				= Source.[AddedBy] 
				,Target.[AddedOn]				= Source.[AddedOn] 
				,Target.[ModifiedBy]			= Source.[ModifiedBy] 
				,Target.[ModifiedOn]			= Source.[ModifiedOn];
		
		
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
