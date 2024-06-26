USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Items_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> 
-- Declare @AddRowCount int Declare @EditRowCount int Declare @DeleteRowCount int Declare @AddImagesCount int Declare @Return_Code bit Declare @Return_Text nvarchar(1000) Declare @Execution_Error nvarchar(1000) Declare @Error_Text nvarchar(max) exec [dbo].[P_Order_Items_IU] '','10','123456789012','abdullah' ,@pAddRowCount = @AddRowCount output,@pEditRowCount = @EditRowCount output,@pDeleteRowCount = @DeleteRowCount output,@pReturn_Code = @Return_Code output,@pReturn_Text = @Return_Text output,@pExecution_Error = @Execution_Error output,@pError_Text = @Error_Text output,@pAddImagesCount = @AddImagesCount output
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Items_IU]
	@pJson nvarchar(max) = ''
	,@pOrder_ID int
	,@pTRACKING_NO nvarchar(40)
	,@pUserName nvarchar(150)
	,@pAddRowCount int output
	,@pEditRowCount int output
	,@pDeleteRowCount int output
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(1000) output
	,@pError_Text nvarchar(max) output
	,@pAddImagesCount int output
	,@pIsBeginTransaction bit = 1
	,@pSource_MTV_ID int = 101100
AS
BEGIN
	SET NOCOUNT ON;

	set @pUserName = upper(@pUserName)

	set @pAddRowCount = 0
	set @pEditRowCount = 0
	set @pDeleteRowCount = 0
	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	Declare @TotalQty int = 0
	Declare @TotalValue decimal(18,6) = 0
	Declare @TotalWeight decimal(18,6) = 0
	Declare @TotalCubes decimal(18,6) = 0
	Declare @TotalAssemblyMinutes int = 0
	Declare @LastGeneratedBarcode nvarchar(10) = ''

	Declare @ItemImages_Json nvarchar(max) = ''

	Begin Try

		drop table if exists #JsonItemsTable
		select RequestItemID,RowNo,OI_ID,PARENT_OI_ID,ORDER_ID,BARCODE,BARCODE_GUID,ItemToShip_MTV_CODE,ItemCode_MTV_CODE,PackingCode_MTV_CODE,SKU_NO,ItemDescription
			,Quantity,ItemWeight,WeightUnit_MTV_CODE,ItemLength,ItemWidth,ItemHeight,Dimensions,DimensionUnit_MTV_CODE,Cu_Ft_,Amount,AssemblyTime,PackageDetailsNote
			,ItemClientRef1,ItemClientRef2,ItemClientRef3,ItemImages,IsAddItem,IsEditItem,IsDeleteItem into #JsonItemsTable 
			from [POMS_DB].[dbo].[F_Get_Order_JsonItemsTable] (@pJson)

		if not exists(select OI_ID from #JsonItemsTable) 
		begin
			set @pReturn_Text = 'Item Detail is Required'
			return
		end
	
		drop table if exists #TmpBarcodes 
		select [BARCODE],[BARCODE_GUID] into #TmpBarcodes from #JsonItemsTable

		drop table if exists #JsonItemImages
		Create Table #JsonItemImages 
		(FileGUID nvarchar(36)
		,Path_ nvarchar(250)
		,OriginalFileName nvarchar(250)
		,FileExt nvarchar(10)
		,Description_ nvarchar(250)
		,DocumentType_MTV_ID int
		,IsPublic bit
		,AttachmentType_MTV_ID int
		,RefNo nvarchar(40)
		,RefNo2 nvarchar(40)
		,RefID int
		,RefID2 int
		,RefGUID nvarchar(36))

		if exists(select OI_ID from #JsonItemsTable where [ItemImages] is not null)
		begin
			select @ItemImages_Json = (Select SUBSTRING([ItemImages] ,2, len([ItemImages])-2) + ','  AS [text()]
				From #JsonItemsTable where [ItemImages] is not null
				For XML Path(''), TYPE).value('.', 'nvarchar(MAX)')

			set @ItemImages_Json = '[' + left(@ItemImages_Json,len(@ItemImages_Json)-1) + ']'
			
			insert into #JsonItemImages
			select distinct FileGUID,Path_,OriginalFileName,FileExt,Description_,DocumentType_MTV_ID,IsPublic,AttachmentType_MTV_ID,RefNo,RefNo2,RefID,RefID2,RefGUID 
			from [POMS_DB].[dbo].[F_Get_Order_JsonDocTable] (@ItemImages_Json)

		end
	
		if @pIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if exists(select [BARCODE] from #TmpBarcodes where [BARCODE] is null) 
		begin
			Declare @LastUsedBarcode nvarchar(10) = ''
			select @LastUsedBarcode = right(max([BARCODE]),4) from [POMS_DB].[dbo].[T_Order_Items] with (nolock) where ORDER_ID = @pOrder_ID
			update item
			set item.[BARCODE] = format((cast(@LastUsedBarcode as int) + ROW_NUMBER() OVER (ORDER BY item.RowNo)),'0000')
			from #TmpBarcodes item where item.[BARCODE] is null
		end
		update item
		set item.[BARCODE] = (@pTRACKING_NO + right(tb.[BARCODE],4))
		,item.[ORDER_ID] = @pOrder_ID
		from #JsonItemsTable item
		inner join #TmpBarcodes tb on item.[BARCODE_GUID] = tb.[BARCODE_GUID]

		if exists(select FileGUID from #JsonItemImages) 
		begin
			update item
			set item.[RefNo] = (@pTRACKING_NO + right(tb.[BARCODE],4))
			from #JsonItemImages item
			inner join #TmpBarcodes tb on item.[RefGUID] = tb.[BARCODE_GUID]
		end

		if exists(select OI_ID from #JsonItemsTable where IsAddItem = 1)
		begin
			insert into [POMS_DB].[dbo].[T_Order_Items] ([PARENT_OI_ID] ,[ORDER_ID] ,[BARCODE] ,[ItemToShip_MTV_CODE] ,[ItemCode_MTV_CODE] ,[PackingCode_MTV_CODE] 
			,[SKU_NO] ,[ItemDescription] ,[Quantity] ,[ItemWeight] ,[WeightUnit_MTV_CODE] ,[ItemLength] ,[ItemWidth] ,[ItemHeight] ,[Dimensions] ,[DimensionUnit_MTV_CODE] 
			,[Cu_Ft_] ,[Amount] ,[AssemblyTime] ,[PackageDetailsNote] ,[ItemClientRef1]	,[ItemClientRef2] ,[ItemClientRef3] ,[CreatedBy])
			select [PARENT_OI_ID] ,[ORDER_ID] ,[BARCODE] ,[ItemToShip_MTV_CODE] ,[ItemCode_MTV_CODE] ,[PackingCode_MTV_CODE] ,[SKU_NO] ,[ItemDescription] 
			,[Quantity]	,[ItemWeight] ,[WeightUnit_MTV_CODE] ,[ItemLength] ,[ItemWidth] ,[ItemHeight] ,[Dimensions] ,[DimensionUnit_MTV_CODE] ,[Cu_Ft_] ,[Amount] ,[AssemblyTime] 
			,[PackageDetailsNote] ,[ItemClientRef1]	,[ItemClientRef2] ,[ItemClientRef3] ,@pUserName as [CreatedBy] from #JsonItemsTable where IsAddItem = 1 order by [BARCODE]
	
			set @pAddRowCount = @@ROWCOUNT
			if (@pAddRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Items was not Insert'
			end

			if exists(select [ORDER_ID] from [POMS_DB].[dbo].[T_Order_Detail] with (nolock) where [ORDER_ID] = @pOrder_ID) and @pAddRowCount > 0
			begin
				select @TotalQty = sum(Quantity)
				,@TotalValue = sum(Amount)
				,@TotalWeight = sum(ItemWeight)
				,@TotalCubes = sum(Cu_Ft_)
				,@TotalAssemblyMinutes = sum(AssemblyTime)
				,@LastGeneratedBarcode = max(right(BARCODE,4))
				from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.ORDER_ID = @pOrder_ID

				update od
				set od.IsItemAdded = 1
				,od.TotalQty = @TotalQty
				,od.TotalValue = @TotalValue
				,od.TotalWeight = @TotalWeight
				,od.TotalCubes = @TotalCubes
				,od.TotalAssemblyMinutes = @TotalAssemblyMinutes
				,od.LastGeneratedBarcode = @LastGeneratedBarcode
				,od.ModifiedBy = @pUserName
				,od.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_Order_Detail] od 
				where [ORDER_ID] = @pOrder_ID

				set @pAddRowCount = @@ROWCOUNT
				if (@pAddRowCount = 0)
				begin
					set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Detail was not Updated'
				end
			end

			if @pAddRowCount > 0
			begin
				insert into [POMS_DB].[dbo].[T_Order_Items_Additional_Info] ([ORDER_ID],[BARCODE],[AddedBy])
				select [ORDER_ID] ,[BARCODE] ,@pUserName as [CreatedBy] 
				from #JsonItemsTable where IsAddItem = 1 order by [BARCODE]
	
				set @pAddRowCount = @@ROWCOUNT
				if (@pAddRowCount = 0)
				begin
					set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Items Additional Info Record was not Insert'
				end
			end
		end

		if exists(select OI_ID from #JsonItemsTable where IsEditItem = 1) and @pExecution_Error = ''
		begin
			drop table if exists #JsonOldEditItemsTable 
			select item.ORDER_ID, item.BARCODE ,[PARENT_OI_ID]=[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[PARENT_OI_ID])
			,[ItemToShip_MTV_CODE] = item.[ItemToShip_MTV_CODE]
			,[ItemCode_MTV_CODE] = item.[ItemCode_MTV_CODE]
			,[PackingCode_MTV_CODE] = item.[PackingCode_MTV_CODE]
			,[ItemToShip_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 117 and MTV_ID = item.[ItemToShip_MTV_CODE]),'')
			,[ItemCode_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 118 and MTV_ID = item.[ItemCode_MTV_CODE]),'')
			,[PackingCode_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 119 and MTV_ID = item.[PackingCode_MTV_CODE]),'')
			,item.[SKU_NO] ,item.[ItemDescription] ,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemWeight])
			,[WeightUnit_MTV_CODE] = item.[WeightUnit_MTV_CODE]
			,[WeightUnit_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 120 and MTV_ID = item.[WeightUnit_MTV_CODE]),'')
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemLength]) ,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemWidth]) 
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemHeight]) ,item.[Dimensions] 
			,[DimensionUnit_MTV_CODE] = item.[DimensionUnit_MTV_CODE]
			,[DimensionUnit_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 121 and MTV_ID = item.[DimensionUnit_MTV_CODE]),'')
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[Cu_Ft_]) ,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[Amount]) 
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[AssemblyTime]) ,[PackageDetailsNote]=isnull(item.[PackageDetailsNote],'')
			,item.[ItemClientRef1] ,item.[ItemClientRef2] ,item.[ItemClientRef3] 
			into #JsonOldEditItemsTable 
			from [POMS_DB].[dbo].[T_Order_Items] item with (nolock)
			inner join #JsonItemsTable jitem on item.BARCODE = jitem.Barcode where jitem.IsEditItem = 1

			update item
			set item.[PARENT_OI_ID] = jitem.[PARENT_OI_ID]
			,item.[ItemToShip_MTV_CODE] = jitem.[ItemToShip_MTV_CODE] 
			,item.[ItemCode_MTV_CODE] = jitem.[ItemCode_MTV_CODE] 
			,item.[PackingCode_MTV_CODE] = jitem.[PackingCode_MTV_CODE] 
			,item.[SKU_NO] = jitem.[SKU_NO] 
			,item.[ItemDescription] = jitem.[ItemDescription] 
			,item.[ItemWeight] = jitem.[ItemWeight] 
			,item.[WeightUnit_MTV_CODE] = jitem.[WeightUnit_MTV_CODE] 
			,item.[ItemLength] = jitem.[ItemLength] 
			,item.[ItemWidth] = jitem.[ItemWidth] 
			,item.[ItemHeight] = jitem.[ItemHeight] 
			,item.[Dimensions] = jitem.[Dimensions] 
			,item.[DimensionUnit_MTV_CODE] = jitem.[DimensionUnit_MTV_CODE] 
			,item.[Cu_Ft_] = jitem.[Cu_Ft_] 
			,item.[Amount] = jitem.[Amount] 
			,item.[AssemblyTime] = jitem.[AssemblyTime] 
			,item.[PackageDetailsNote] = jitem.[PackageDetailsNote] 
			,item.[ItemClientRef1] = jitem.[ItemClientRef1]
			,item.[ItemClientRef2] = jitem.[ItemClientRef2] 
			,item.[ItemClientRef3] = jitem.[ItemClientRef3] 
			,item.[ModifiedBy]=@pUserName
			,item.[ModifiedOn]=getutcdate()
			from [POMS_DB].[dbo].[T_Order_Items] item
			inner join #JsonItemsTable jitem on item.BARCODE = jitem.Barcode 
			where jitem.IsEditItem = 1
			
			set @pEditRowCount = @@ROWCOUNT
			if (@pEditRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Items was not Updated'
			end

			if exists(select [ORDER_ID] from [POMS_DB].[dbo].[T_Order_Detail] with (nolock) where [ORDER_ID] = @pOrder_ID) and @pEditRowCount > 0
			begin
				select @TotalQty = sum(Quantity)
				,@TotalValue = sum(Amount)
				,@TotalWeight = sum(ItemWeight)
				,@TotalCubes = sum(Cu_Ft_)
				,@TotalAssemblyMinutes = sum(AssemblyTime)
				from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.ORDER_ID = @pOrder_ID

				update od
				set od.TotalQty = @TotalQty
				,od.TotalValue = @TotalValue
				,od.TotalWeight = @TotalWeight
				,od.TotalCubes = @TotalCubes
				,od.TotalAssemblyMinutes = @TotalAssemblyMinutes
				,od.ModifiedBy = @pUserName
				,od.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_Order_Detail] od 
				where [ORDER_ID] = @pOrder_ID

				set @pAddRowCount = @@ROWCOUNT
				if (@pAddRowCount = 0)
				begin
					set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Detail was not Updated'
				end
			end

			drop table if exists #JsonNewEditItemsTable 
			select item.ORDER_ID, item.BARCODE ,[PARENT_OI_ID]=[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[PARENT_OI_ID])
			,[ItemToShip_MTV_CODE] = item.[ItemToShip_MTV_CODE]
			,[ItemCode_MTV_CODE] = item.[ItemCode_MTV_CODE]
			,[PackingCode_MTV_CODE] = item.[PackingCode_MTV_CODE]
			,[ItemToShip_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 117 and MTV_ID = item.[ItemToShip_MTV_CODE]),'')
			,[ItemCode_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 118 and MTV_ID = item.[ItemCode_MTV_CODE]),'')
			,[PackingCode_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 119 and MTV_ID = item.[PackingCode_MTV_CODE]),'')
			,item.[SKU_NO] ,item.[ItemDescription] ,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemWeight])
			,[WeightUnit_MTV_CODE] = item.[WeightUnit_MTV_CODE]
			,[WeightUnit_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 120 and MTV_ID = item.[WeightUnit_MTV_CODE]),'')
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemLength]) ,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemWidth]) 
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemHeight]) ,item.[Dimensions] 
			,[DimensionUnit_MTV_CODE] = item.[DimensionUnit_MTV_CODE]
			,[DimensionUnit_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 121 and MTV_ID = item.[DimensionUnit_MTV_CODE]),'')
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[Cu_Ft_]) ,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[Amount]) 
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[AssemblyTime]) ,[PackageDetailsNote]=isnull(item.[PackageDetailsNote],'')
			,item.[ItemClientRef1] ,item.[ItemClientRef2] ,item.[ItemClientRef3] 
			into #JsonNewEditItemsTable 
			from [POMS_DB].[dbo].[T_Order_Items] item with (nolock)
			inner join #JsonItemsTable jitem on item.BARCODE = jitem.Barcode where jitem.IsEditItem = 1

			exec [POMS_DB].[dbo].[P_Order_Items_IU_ChangeLog] @plogIsEdit = 1 ,@plogIsDelete = 0 ,@plogUserName = @pUserName ,@plogSource_MTV_ID = @pSource_MTV_ID
		end

		if exists(select OI_ID from [POMS_DB].[dbo].[T_Order_Items] with (nolock) where BARCODE in (select Barcode from #JsonItemsTable jitem where IsDeleteItem = 1)) and @pExecution_Error = ''
		begin
			drop table if exists #JsonOldDeleteItemsTable 
			select item.ORDER_ID, item.BARCODE ,[PARENT_OI_ID]=[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[PARENT_OI_ID])
			,[ItemToShip_MTV_CODE] = item.[ItemToShip_MTV_CODE]
			,[ItemCode_MTV_CODE] = item.[ItemCode_MTV_CODE]
			,[PackingCode_MTV_CODE] = item.[PackingCode_MTV_CODE]
			,[ItemToShip_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 117 and MTV_ID = item.[ItemToShip_MTV_CODE]),'')
			,[ItemCode_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 118 and MTV_ID = item.[ItemCode_MTV_CODE]),'')
			,[PackingCode_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 119 and MTV_ID = item.[PackingCode_MTV_CODE]),'')
			,item.[SKU_NO] ,item.[ItemDescription] ,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemWeight])
			,[WeightUnit_MTV_CODE] = item.[WeightUnit_MTV_CODE]
			,[WeightUnit_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 120 and MTV_ID = item.[WeightUnit_MTV_CODE]),'')
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemLength]) ,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemWidth]) 
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[ItemHeight]) ,item.[Dimensions] 
			,[DimensionUnit_MTV_CODE] = item.[DimensionUnit_MTV_CODE]
			,[DimensionUnit_MTV_CODE_Name] = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 121 and MTV_ID = item.[DimensionUnit_MTV_CODE]),'')
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[Cu_Ft_]) ,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[Amount]) 
			,[POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (item.[AssemblyTime]) ,[PackageDetailsNote]=isnull(item.[PackageDetailsNote],'')
			,item.[ItemClientRef1] ,item.[ItemClientRef2] ,item.[ItemClientRef3] 
			into #JsonOldDeleteItemsTable 
			from [POMS_DB].[dbo].[T_Order_Items] item with (nolock)
			inner join #JsonItemsTable jitem on item.BARCODE = jitem.Barcode where jitem.IsDeleteItem = 1

			Delete from [POMS_DB].[dbo].[T_Order_Items] where BARCODE in (select Barcode from #JsonItemsTable jitem where IsDeleteItem = 1)
			
			set @pDeleteRowCount = @@ROWCOUNT
			if (@pDeleteRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Items was not Deleted'
			end


			if @pAddRowCount > 0
			begin
				update oi 
				set oi.IsActive = 0
				,oi.ModifiedBy = @pUserName
				,oi.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_Order_Items] oi where BARCODE in (select Barcode from #JsonItemsTable jitem where IsDeleteItem = 1)
				
				set @pAddRowCount = @@ROWCOUNT
				if (@pAddRowCount = 0)
				begin
					set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Items Additional Info Record was not Deleted'
				end

			end

			if exists(select [ORDER_ID] from [POMS_DB].[dbo].[T_Order_Detail] with (nolock) where [ORDER_ID] = @pOrder_ID) and @pEditRowCount > 0
			begin
				select @TotalQty = sum(Quantity)
				,@TotalValue = sum(Amount)
				,@TotalWeight = sum(ItemWeight)
				,@TotalCubes = sum(Cu_Ft_)
				,@TotalAssemblyMinutes = sum(AssemblyTime)
				from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.ORDER_ID = @pOrder_ID

				update od
				set od.TotalQty = @TotalQty
				,od.TotalValue = @TotalValue
				,od.TotalWeight = @TotalWeight
				,od.TotalCubes = @TotalCubes
				,od.TotalAssemblyMinutes = @TotalAssemblyMinutes
				,od.ModifiedBy = @pUserName
				,od.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_Order_Detail] od 
				where [ORDER_ID] = @pOrder_ID

				set @pAddRowCount = @@ROWCOUNT
				if (@pAddRowCount = 0)
				begin
					set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Detail was not Updated'
				end
			end

			drop table if exists #JsonNewDeleteItemsTable 
			select ORDER_ID = @pOrder_ID, jitem.Barcode ,[PARENT_OI_ID]='Deleted'
			,[ItemToShip_MTV_CODE] = 'Deleted'
			,[ItemCode_MTV_CODE] = 'Deleted'
			,[PackingCode_MTV_CODE] = 'Deleted'
			,[ItemToShip_MTV_CODE_Name] = 'Deleted'
			,[ItemCode_MTV_CODE_Name] = 'Deleted'
			,[PackingCode_MTV_CODE_Name] = 'Deleted'
			,[SKU_NO] = 'Deleted' ,[ItemDescription] = 'Deleted' ,[ItemWeight] = 'Deleted'
			,[WeightUnit_MTV_CODE] = 'Deleted'
			,[WeightUnit_MTV_CODE_Name] = 'Deleted'
			,[ItemLength] = 'Deleted' ,[ItemWidth] = 'Deleted' ,[ItemHeight] = 'Deleted' ,[Dimensions] = 'Deleted'
			,[DimensionUnit_MTV_CODE] = 'Deleted'
			,[DimensionUnit_MTV_CODE_Name] = 'Deleted'
			,[Cu_Ft_] = 'Deleted' ,[Amount] = 'Deleted' ,[AssemblyTime] = 'Deleted' ,[PackageDetailsNote] = 'Deleted'
			,[ItemClientRef1] = 'Deleted' ,[ItemClientRef2] = 'Deleted' ,[ItemClientRef3] = 'Deleted'
			into #JsonNewDeleteItemsTable 
			from #JsonItemsTable jitem where jitem.IsDeleteItem = 1

			exec [POMS_DB].[dbo].[P_Order_Items_IU_ChangeLog] @plogIsEdit = 0 ,@plogIsDelete = 1 ,@plogUserName = @pUserName ,@plogSource_MTV_ID = @pSource_MTV_ID
		end

		if @pExecution_Error = '' and @pReturn_Text = '' and @pError_Text = ''
		begin
			set @pReturn_Code = 1
		end

		if isnull(@ItemImages_Json,'') <> '' and @pReturn_Code = 1
		begin
			Declare @TempReturn_Code bit = 0
			Declare @TempReturn_Text nvarchar(1000) = ''
			Declare @TempExecution_Error nvarchar(1000) = ''
			Declare @TempError_Text nvarchar(max) = ''
			select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''
			
			exec [POMS_DB].[dbo].[P_Order_Docs_Insert] @ppJson = @ItemImages_Json ,@ppOrder_ID = @pOrder_ID ,@ppTRACKING_NO = @pTRACKING_NO 
					--,@ppAttachmentType_MTV_ID = 128101 
					,@ppUserName = @pUserName
					,@ppAddRowCount = @pAddImagesCount output ,@ppReturn_Code = @TempReturn_Code output ,@ppReturn_Text = @TempReturn_Text output 
					,@ppExecution_Error = @TempExecution_Error output ,@ppError_Text = @TempError_Text output ,@ppIsBeginTransaction = 0
			
			set @pReturn_Code = @TempReturn_Code
			select @pReturn_Text = @pReturn_Text + (case when @pReturn_Text <> '' then '; ' else '' end) + @TempReturn_Text
			, @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TempExecution_Error
			, @pError_Text = @pError_Text + (case when @pError_Text <> '' then '; ' else '' end) + @TempError_Text
		end

		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 1
		begin
			COMMIT; 
		end
		else if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 0
		begin
			ROLLBACK; 
		end

	End Try
	Begin catch
		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @pError_Text = 'P_Order_Items_IU: ' + ERROR_MESSAGE()
	End catch

END
GO
