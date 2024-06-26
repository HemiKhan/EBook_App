USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sync_Import_Order_File_Source_Setup_Other_Info]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Sync_Import_Order_File_Source_Setup_Other_Info]
	
AS
BEGIN
	
	Begin Transaction

	begin try
		Declare @Marker varbinary(50) = null
		--Select @Marker = Max([TimeStamp]) from [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] with (nolock) where TableName = 'T_T_Import_Order_File_Source_Setup_Other_Info'

		Declare  @NAV_ASNSetupTable TABLE (
			[TimeStamp] [varbinary](50) NOT NULL
			,[SellerCode] nvarchar(20)
			,[SellerKey]  nvarchar(36)
			,[BillToCode]  nvarchar(20)
			,[BillToKey]  nvarchar(36)
			,[File Type]  int
			,[File Type Name]  nvarchar(20)
			,[FileSource_MTV_CODE]  nvarchar(20)
			,[OrderSubSource_MTV_CODE]  nvarchar(20)
			,[ITEM-CODE]  nvarchar(20)
			,[SHIPFROM-ADDRESSCODE]  nvarchar(20)			,[DELIVERY-SERVICECODE]  nvarchar(20)			,[SHIPFROM-EMAIL]  nvarchar(1000)			,[SHIPTO-EMAIL]  nvarchar(1000)			,[ITEM-DIMENSION-Length]  nvarchar(20)			,[ITEM-DIMENSION-Width]  nvarchar(20)			,[ITEM-DIMENSION-Height]  nvarchar(20)			,[PICKUP-DRIVER-INST]  nvarchar(1000)			,[DELIVERY-DRIVER-INST]  nvarchar(1000)
			,[PICKUP-SERVICECODE]  nvarchar(20)
			,[ITEM-WEIGHT]  nvarchar(20)
			,[ITEM-VALUE]  nvarchar(20)
			,[ITEM-PACKINGCODE]  nvarchar(20)
			,[ITEMTOSHIP-CODE]  nvarchar(20)
			,[INITIAL-COM-PUBLIC]  nvarchar(20)
			,[ORDER-INITIAL-COM]  nvarchar(20)
			,[INITIAL-COM-PUBLIC2]  nvarchar(20)
			,[ORDER-INITIAL-COM2]  nvarchar(100)
		);

		insert into @NAV_ASNSetupTable ([TimeStamp] ,[SellerCode] ,[SellerKey] ,[BillToCode] ,[BillToKey] ,[File Type] ,[File Type Name] ,[FileSource_MTV_CODE] ,[OrderSubSource_MTV_CODE] 		,[ITEM-CODE] ,[SHIPFROM-ADDRESSCODE] ,[DELIVERY-SERVICECODE] ,[SHIPFROM-EMAIL] ,[SHIPTO-EMAIL] ,[ITEM-DIMENSION-Length] ,[ITEM-DIMENSION-Width] ,[ITEM-DIMENSION-Height] ,[PICKUP-DRIVER-INST] 
		,[DELIVERY-DRIVER-INST] ,[PICKUP-SERVICECODE] ,[ITEM-WEIGHT] ,[ITEM-VALUE] ,[ITEM-PACKINGCODE] ,[ITEMTOSHIP-CODE] ,[INITIAL-COM-PUBLIC] ,[ORDER-INITIAL-COM] ,[INITIAL-COM-PUBLIC2] 
		,[ORDER-INITIAL-COM2])
		select ilv.[TimeStamp] ,[SellerCode] ,[SellerKey]=sl.SELLER_KEY ,[BillToCode] ,[BillToKey] ,[File Type] ,[File Type Name] ,[FileSource_MTV_CODE]
		,[OrderSubSource_MTV_CODE] ,[ITEM-CODE] ,[SHIPFROM-ADDRESSCODE] ,[DELIVERY-SERVICECODE] ,[SHIPFROM-EMAIL] ,[SHIPTO-EMAIL] ,[ITEM-DIMENSION-Length] ,[ITEM-DIMENSION-Width] 
		,[ITEM-DIMENSION-Height] ,[PICKUP-DRIVER-INST] ,[DELIVERY-DRIVER-INST] ,[PICKUP-SERVICECODE] ,[ITEM-WEIGHT] ,[ITEM-VALUE] ,[ITEM-PACKINGCODE] ,[ITEMTOSHIP-CODE] 		,[INITIAL-COM-PUBLIC] ,[ORDER-INITIAL-COM] ,[INITIAL-COM-PUBLIC2] ,[ORDER-INITIAL-COM2]		from (			select [TimeStamp]=as_.[timestamp]			,[SellerCode]=replace(as_.[CustomerNo],'C','S')			,[BillToCode]=as_.[CustomerNo]			,[BillToKey] = cast(c.[Customer GUID] as nvarchar(36)) 			,as_.[File Type]			,as_.[File Type Name]			,[FileSource_MTV_CODE]=(case when as_.[File Type] = 20000 then 'ASN-CSV'				when as_.[File Type] = 30000 then 'ASN-EXCEL'				when as_.[File Type] = 100000 then 'API'				when as_.[File Type] = 10000 then 'ASN-XML'				when as_.[File Type] = 90000 and as_.[CustomerNo] = 'C100872' then 'COMMERENCE-HUB'				when as_.[File Type] = 90000 and as_.[CustomerNo] <> 'C100872' then 'ASN-EDI-850'				else cast(as_.[File Type] as nvarchar(20)) end)			,[OrderSubSource_MTV_CODE]=(case when as_.[File Type] = 20000 then 'CSV'				when as_.[File Type] = 30000 then 'EXCEL'				when as_.[File Type] = 100000 then 'API'				when as_.[File Type] = 10000 then 'XML'				when as_.[File Type] = 90000 then 'EDI-850'				else cast(as_.[File Type] as nvarchar(20)) end)			,[ITEM-CODE]=ltrim(rtrim(upper(as_.[DefaultItemCode])))
			,[SHIPFROM-ADDRESSCODE]=(case when as_.[Origin Zip] = '08861' then 'A000001' 
				when as_.[Origin Zip] = '85043' and as_.CustomerNo = 'C100008' then 'A000005' 
				when as_.[Origin Zip] = '27265' and as_.CustomerNo = 'C100093' then 'A000006'
				else '' end)
			,[DELIVERY-SERVICECODE]=(case ltrim(rtrim(upper(as_.[Service Type]))) when 'WG' then 'WG-RESI' when 'PWG' then 'PWG-RESI' else ltrim(rtrim(upper(as_.[Service Type]))) end)
			,[SHIPFROM-EMAIL]=ltrim(rtrim(lower(as_.[Origin Email])))
			,[SHIPTO-EMAIL]=ltrim(rtrim(lower(as_.[Destination Email])))
			,[ITEM-DIMENSION-Length]=(case when as_.[Length] > 0 then cast(cast(as_.[Length] as float) as nvarchar(20)) else '' end)
			,[ITEM-DIMENSION-Width]=(case when as_.[Width] > 0 then cast(cast(as_.[Width] as float) as nvarchar(20)) else '' end)
			,[ITEM-DIMENSION-Height]=(case when as_.[Height] > 0 then cast(cast(as_.[Height] as float) as nvarchar(20)) else '' end)
			,[PICKUP-DRIVER-INST]=''
			,[DELIVERY-DRIVER-INST]=[Order Comment]
			,[PICKUP-SERVICECODE]=(case ltrim(rtrim(upper(as_.[Pickup Type]))) when 'WG' then 'WG-RESI' else ltrim(rtrim(upper(as_.[Pickup Type]))) end)
			,[ITEM-WEIGHT]=(case when as_.[Weight] > 0 then cast(cast(as_.[Weight] as float) as nvarchar(20)) else '' end)
			,[ITEM-VALUE]=(case when as_.[Value] > 0 then cast(cast(as_.[Value] as float) as nvarchar(20)) else '' end)
			,[ITEM-PACKINGCODE]=(case when as_.[Packed By Shipper] = 0 then 'PK-SP' else 'PK-REQ' end)
			,[ITEMTOSHIP-CODE]=''
			,[INITIAL-COM-PUBLIC]=1
			,[ORDER-INITIAL-COM]=''
			,[INITIAL-COM-PUBLIC2]=1
			,[ORDER-INITIAL-COM2]=as_.Comment
			FROM [MetroPolitanNavProduction].[dbo].[Metropolitan$ASN Setup] as_ with (nolock) 
			inner join [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] c with (nolock) on as_.[CustomerNo] = c.No_			and as_.ID not in (3,2,1050,1040,1045,1102,1104,1103)			--and abi.[timestamp] > @Marker or @Marker is null
		) ilv inner join [POMS_DB].[dbo].[T_Seller_List] sl with (nolock) on ilv.SellerCode = sl.SELLER_CODE collate database_default
		
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
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ITEM-CODE' , CODE2 = '' , ast.[ITEM-CODE] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[ITEM-CODE] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='SHIPFROM-ADDRESSCODE' , CODE2 = '' , ast.[SHIPFROM-ADDRESSCODE] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[SHIPFROM-ADDRESSCODE] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='DELIVERY-SERVICECODE' , CODE2 = '' , ast.[DELIVERY-SERVICECODE] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[DELIVERY-SERVICECODE] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='SHIPFROM-EMAIL' , CODE2 = '' , ast.[SHIPFROM-EMAIL] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[SHIPFROM-EMAIL] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='SHIPTO-EMAIL' , CODE2 = '' , ast.[SHIPTO-EMAIL] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[SHIPTO-EMAIL] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ITEM-DIMENSION' , CODE2 = '' , ast.[ITEM-DIMENSION-Length] , ast.[ITEM-DIMENSION-Width] 
		, ast.[ITEM-DIMENSION-Height] from @NAV_ASNSetupTable ast where ast.[ITEM-DIMENSION-Length] <> '' and ast.[ITEM-DIMENSION-Width] <> '' and ast.[ITEM-DIMENSION-Height] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ITEM-DIMENSION-UNIT' , CODE2 = '' , 'IN' , ast.[ITEM-DIMENSION-Width] 
		, ast.[ITEM-DIMENSION-Height] from @NAV_ASNSetupTable ast where ast.[ITEM-DIMENSION-Length] <> '' and ast.[ITEM-DIMENSION-Width] <> '' and ast.[ITEM-DIMENSION-Height] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='PICKUP-DRIVER-INST' , CODE2 = '' , ast.[PICKUP-DRIVER-INST] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[PICKUP-DRIVER-INST] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='DELIVERY-DRIVER-INST' , CODE2 = '' , ast.[DELIVERY-DRIVER-INST] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[DELIVERY-DRIVER-INST] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='PICKUP-SERVICECODE' , CODE2 = '' , ast.[PICKUP-SERVICECODE] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[PICKUP-SERVICECODE] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ITEM-WEIGHT' , CODE2 = '' , ast.[ITEM-WEIGHT] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[ITEM-WEIGHT] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ITEM-WEIGHT-UNIT' , CODE2 = '' , 'LB' , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[ITEM-WEIGHT] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ITEM-VALUE' , CODE2 = '' , ast.[ITEM-VALUE] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[ITEM-VALUE] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ITEM-PACKINGCODE' , CODE2 = '' , ast.[ITEM-PACKINGCODE] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[ITEM-PACKINGCODE] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ITEMTOSHIP-CODE' , CODE2 = '' , ast.[ITEMTOSHIP-CODE] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[ITEMTOSHIP-CODE] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='INITIAL-COM-PUBLIC' , CODE2 = '' , ast.[INITIAL-COM-PUBLIC] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[INITIAL-COM-PUBLIC] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ORDER-INITIAL-COM' , CODE2 = '' , ast.[ORDER-INITIAL-COM] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[ORDER-INITIAL-COM] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='INITIAL-COM-PUBLIC2' , CODE2 = '' , ast.[INITIAL-COM-PUBLIC2] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[INITIAL-COM-PUBLIC2] <> ''

		insert into @POMS_ImportOrderFileSourceSetupSellerInfoTable (SELLER_KEY ,FileSource_MTV_CODE ,OrderSubSource_MTV_CODE ,Code_MTV_CODE ,CODE2 ,REFNO1 ,REFNO2 ,REFNO3)
		select ast.[SellerKey], ast.FileSource_MTV_CODE, ast.OrderSubSource_MTV_CODE, Code_MTV_CODE='ORDER-INITIAL-COM2' , CODE2 = '' , ast.[ORDER-INITIAL-COM2] , REFNO2=null , REFNO3=null 
		from @NAV_ASNSetupTable ast where ast.[ORDER-INITIAL-COM2] <> ''

		Delete s
		from [POMS_DB].[dbo].[T_Import_Order_File_Source_Setup] s where s.AddedBy = 'AUTOSYNC' 
		and s.Code_MTV_CODE in ('ITEM-CODE','SHIPFROM-ADDRESSCODE','DELIVERY-SERVICECODE','SHIPFROM-EMAIL','SHIPTO-EMAIL','ITEM-DIMENSION','ITEM-DIMENSION-UNIT','PICKUP-DRIVER-INST','DELIVERY-DRIVER-INST','PICKUP-SERVICECODE','ITEM-WEIGHT','ITEM-WEIGHT-UNIT','ITEM-VALUE','ITEM-PACKINGCODE','ITEMTOSHIP-CODE','INITIAL-COM-PUBLIC','ORDER-INITIAL-COM','INITIAL-COM-PUBLIC2','ORDER-INITIAL-COM2')
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

		Select @Marker = Max([TimeStamp]) from @NAV_ASNSetupTable

		update [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] set [TimeStamp] = @Marker where TableName = 'T_T_Import_Order_File_Source_Setup_Other_Info' and @Marker is not null

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
