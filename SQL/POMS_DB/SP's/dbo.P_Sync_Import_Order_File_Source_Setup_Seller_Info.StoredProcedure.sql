USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sync_Import_Order_File_Source_Setup_Seller_Info]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Sync_Import_Order_File_Source_Setup_Seller_Info]
	
AS
BEGIN
	
	Begin Transaction

	begin try
		Declare @Marker varbinary(50) = null
		--Select @Marker = Max([TimeStamp]) from [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] with (nolock) where TableName = 'T_T_Import_Order_File_Source_Setup_Seller_Info'

		Declare  @NAV_ASNBillingInfoTable TABLE (
			[TimeStamp] [varbinary](50) NOT NULL,
			[MAP_SELLER_CODE] [nvarchar](20) NOT NULL,
			[MAP_SELLER_KEY] [nvarchar](36) NOT NULL,
			[SELLER_CODE] [nvarchar](20) NOT NULL,
			[SELLER_KEY] [nvarchar](36) NOT NULL,
			[BillToCode] [nvarchar](20) NOT NULL,
			[BillToKey] [nvarchar](36) NOT NULL,
			[BillingCode] [nvarchar](50) NOT NULL
		);

		insert into @NAV_ASNBillingInfoTable ([TimeStamp] , [MAP_SELLER_CODE] , [MAP_SELLER_KEY] , [SELLER_CODE] , [SELLER_KEY] , [BillToCode] , [BillToKey] , [BillingCode])
		select ilv.[timestamp], SELLER_CODE=sl.SELLER_CODE, SELLER_KEY=sl.SELLER_KEY, MAP_SELLER_CODE=sl1.SELLER_CODE, MAP_SELLER_KEY=sl1.SELLER_KEY 		,BillToCode, BillToKey, [Billing Code] = upper([Billing Code]) from (			SELECT abi.[timestamp], SellerCode = replace([Customer No_],'C','S')			,BillToCode = [Billing Customer No]			,MapSellerCode = replace([Billing Customer No],'C','S')			,BillToKey = upper(cast(c.[Customer GUID] as nvarchar(36)))			,[Billing Code] 			FROM [MetroPolitanNavProduction].[dbo].[Metropolitan$ASN Billing Info] abi with (nolock) 
			inner join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on abi.[Billing Customer No] = c.No_
			where [Customer No_] <> [Billing Customer No]
			--and abi.[timestamp] > @Marker or @Marker is null
		) ilv inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on ilv.SellerCode = sl.SELLER_CODE collate database_default
		inner join [POMS_DB].[dbo].[T_Seller_List] sl1 with (nolock) on ilv.MapSellerCode = sl1.SELLER_CODE collate database_default
		
		Declare @POMS_ImportOrderFileSourceSetupSellerInfoTable table (
			SELLER_KEY nvarchar(36)
			,FileSource_MTV_CODE nvarchar(20)
			,OrderSubSource_MTV_CODE nvarchar(20)
			,Code_MTV_CODE nvarchar(20)
			,CODE2 nvarchar(50)
			,REFNO1 nvarchar(1000)
			,REFNO2 nvarchar(1000)
			,REFNO3 nvarchar(1000)
		)

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select [MAP_SELLER_KEY] , FileSource_MTV_CODE='COMMERENCE-HUB' , OrderSubSource_MTV_CODE='EDI-850' , Code_MTV_CODE='SELLER-CODE' , CODE2 = [BillingCode] 
		, [SELLER_KEY] , REFNO2=null , REFNO3=null from @NAV_ASNBillingInfoTable 

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select [MAP_SELLER_KEY] , FileSource_MTV_CODE='COMMERENCE-HUB' , OrderSubSource_MTV_CODE='EDI-850' , Code_MTV_CODE='BILLTO-CODE' , CODE2 = [BillingCode] 
		, [BillToKey] , REFNO2=null, REFNO3=null
		from @NAV_ASNBillingInfoTable 

		Delete s
		from [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] s where s.AddedBy = 'AUTOSYNC' and s.Code_MTV_CODE in ('SELLER-CODE','BILLTO-CODE')
		and not exists(select t.SELLER_KEY from @POMS_ImportOrderFileSourceSetupSellerInfoTable t where t.FileSource_MTV_CODE = s.FileSource_MTV_CODE 
		and t.OrderSubSource_MTV_CODE = s.OrderSubSource_MTV_CODE and t.Code_MTV_CODE = s.Code_MTV_CODE and t.CODE2 = s.CODE2 and t.SELLER_KEY = s.SELLER_KEY)

		MERGE [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] AS Target
			USING @POMS_ImportOrderFileSourceSetupSellerInfoTable AS Source
			ON Source.SELLER_KEY = Target.SELLER_KEY and Source.FileSource_MTV_CODE = Target.FileSource_MTV_CODE and Source.OrderSubSource_MTV_CODE = Target.OrderSubSource_MTV_CODE
			and Source.Code_MTV_CODE = Target.Code_MTV_CODE and Source.CODE2 = Target.CODE2
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT (SELLER_KEY 
				,FileSource_MTV_CODE 
				,OrderSubSource_MTV_CODE 
				,Code_MTV_CODE 
				,CODE2 
				,REFNO1 
				,REFNO2 
				,REFNO3
				,AddedBy) 
				VALUES (Source.SELLER_KEY 
				,Source.FileSource_MTV_CODE 
				,Source.OrderSubSource_MTV_CODE 
				,Source.Code_MTV_CODE 
				,Source.CODE2 
				,Source.REFNO1 
				,Source.REFNO2 
				,Source.REFNO3
				,'AUTOSYNC')

			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.CODE2					= Source.CODE2 
				,Target.REFNO1					= Source.REFNO1 
				,Target.REFNO2					= Source.REFNO2 
				,Target.REFNO3					= Source.REFNO3 
				,Target.ModifiedBy				= 'AUTOSYNC'
				,Target.ModifiedOn				= getutcdate();

		Select @Marker = Max([TimeStamp]) from @NAV_ASNBillingInfoTable

		update [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] set [TimeStamp] = @Marker where TableName = 'T_T_Import_Order_File_Source_Setup_Seller_Info' and @Marker is not null

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
