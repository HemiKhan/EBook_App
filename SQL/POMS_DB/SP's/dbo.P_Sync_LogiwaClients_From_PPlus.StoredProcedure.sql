USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sync_LogiwaClients_From_PPlus]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Sync_LogiwaClients_From_PPlus]
	
AS
BEGIN
	
	Begin Transaction

	begin try

		drop table if exists #tmp
		select 
		[CUSTOMER_KEY] = (Select cast(mc.[Customer GUID] as nvarchar(36)) from MetroPolitanNavProduction.dbo.[Metropolitan$Customer] mc with (nolock) where mc.No_ = c.Pinnacle_ID collate database_default)
		,[SELLER_KEY] = (Select sl.SELLER_KEY from POMS_DB.dbo.[T_Seller_List] sl with (nolock) where sl.SELLER_CODE = replace(c.Pinnacle_ID,'C','S'))
		,[Logiwa_Name] = c.Logiwa_ID
		,[Logiwa_ID] = c.Logiwa_No
		,[Logiwa_OrderType] = c.Logiwa_OrderType
		,IsActive = c.Active
		,[AddedBy] = 'AUTOSYNC'
		into #tmp
		from PPlus_DB.dbo.T_Client c where c.Logiwa_ID is not null and c.Logiwa_No is not null and c.Logiwa_No not in (10634,13289)

		MERGE [POMS_DB].[dbo].[T_LogiwaClient] AS Target
			USING #tmp AS Source
			ON Source.Logiwa_ID = Target.Logiwa_ID
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT ([CUSTOMER_KEY],[SELLER_KEY],[Logiwa_Name],[Logiwa_ID],[Logiwa_OrderType],[IsActive],[AddedBy]) 
				VALUES (Source.[CUSTOMER_KEY],Source.[SELLER_KEY],Source.[Logiwa_Name],Source.[Logiwa_ID],Source.[Logiwa_OrderType],Source.[IsActive],Source.[AddedBy])

			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.[CUSTOMER_KEY]				=	Source.[CUSTOMER_KEY]
				,Target.[SELLER_KEY]				=	Source.[SELLER_KEY]
				,Target.[Logiwa_Name]				=	Source.[Logiwa_Name]
				,Target.[Logiwa_OrderType]			=	Source.[Logiwa_OrderType]
				,Target.IsActive					=	Source.[IsActive]
				,Target.[ModifiedBy]				= 'AUTOSYNC' 
				,Target.[ModifiedOn]				= getutcdate();
		
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
