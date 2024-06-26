USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_InvoiceLine_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_InvoiceLine_By_OrderID] (3251255,'','ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_InvoiceLine_By_OrderID]
(	
	@ORDER_ID int
	,@EstimateNo nvarchar(20)
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([LineNo] int
, [ChargeType] nvarchar(250)
, [Qty] nvarchar(20)
, [Description] nvarchar(250)
, [IsExtendedText] bit
, [QBDescription] nvarchar(250)
, [Amount] decimal(18,6)
, [AddedBy] nvarchar(150)
, [AddedOn] datetime
, [ModifiedBy] nvarchar(150)
, [ModifiedOn] datetime
, [SalesLineType] int
, [EstimatedNO] nvarchar(20)
, [NavInvoiceId] nvarchar(20)
, [InvoiceAddedDiscount] int
, [GoodsType] nvarchar(20)
, [OrderNo] nvarchar(20)
, [WRDim] nvarchar(20)
, [SLDim] nvarchar(20)
, [BLDim] nvarchar(20)
)
AS
begin
	
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))
	Declare @ApprovalValue int = 0
	Declare @InvoiceStatus int = 0
	Declare @EstimateID int = 0
	Declare @PostedInvoiceNo nvarchar(20) = ''
	Declare @UnPostedInvoiceNo nvarchar(20) = ''
	select @EstimateID = oih.EstimateID, @ApprovalValue = oih.ApprovalValue_MTV_ID, @InvoiceStatus = oih.InvoiceStatus_MTV_ID, @PostedInvoiceNo = oih.PostedInvoiceNo
	, @UnPostedInvoiceNo = oih.UnpostedInvoiceNo from [POMS_DB].[dbo].[T_Order_Invoice_Header] oih with (nolock) where oih.[EstimateNo] = @EstimateNo

	select @ApprovalValue = isnull(@ApprovalValue,0), @InvoiceStatus = isnull(@InvoiceStatus,0), @PostedInvoiceNo = isnull(@PostedInvoiceNo,''), @UnPostedInvoiceNo = isnull(@UnPostedInvoiceNo,'')

	if @ApprovalValue = 0
	begin
		return
	end

	if @ApprovalValue in (154104)
	begin
		insert into @ReturnTable
		select  [LineNo] = sil.[Line No_]
				, [ChargeType] = isnull(
					case sil.[Sales Line Type]
						when 1 then concat('Delivery Charges(', (select top 1 gt.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Goods Type] gt with (nolock) where gt.[Good Type Code] = sil.[Goods type]), ')') + ' (G/L No-' + sil.[No_] + ')'
						when 2 then concat('Special Services(', (Select top 1 ss.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Special Service] ss with (nolock) where ss.[SS Code] = sil.[Goods type]), ')') + ' (G/L No-' + sil.[No_] + ')'
						when 3 then (select top 1 ss.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Special Service] ss with (nolock) where ss.[SS Code] = sil.[Goods type]) + ' (G/L No-' + sil.[No_] + ')'
						when 4 then (select top 1 dt.[Discount Name] from [MetroPolitanNavProduction].dbo.[Metropolitan$Discount Type] dt with (nolock) where dt.[Discount Type] = sil.[Goods type]) + ' (G/L No-' + sil.[No_] + ')'
						else ''
					end, '')
				, [Qty] = case when sil.[Sales Line Type]= 1 then sil.[Total Quantity] else 0 end
				, [Description] = sil.[Description]
				, [IsExtendedText] = (case when upper(sil.[Description]) = 'EXTENDED TEXT' then 1 else 0 end)
				, [QBDescription] = (case when upper(sil.[Description]) = 'EXTENDED TEXT' then 'EXTENDED TEXT' else sil.[QB Description] end)
				, [Amount] = sil.[Unit Price] 
				, [AddedBy] = afn.FullName
				, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC](sil.[Added On],@TimeZone_ID,null,@TimeZoneName)
				, [ModifiedBy] = mfn.FullName
				, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC](sil.[Modified On],@TimeZone_ID,null,@TimeZoneName)
				, [SalesLineType] = sil.[Sales Line Type]
				, [EstimatedInvoiceId]= @EstimateNo
				, [NavInvoiceId]= sil.[Document No_]
				, [InvoiceAddedDiscount] = 1
				, [GoodsType] = upper(sil.[Goods type])
				, [OrderNo] = sil.[Project ID]
				, [WRDim]=isnull((Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = sil.[Dimension Set ID] and [Dimension Code] = 'WR LOCATION'),'')
				, [SLDim]=isnull((Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = sil.[Dimension Set ID] and [Dimension Code] = 'SERVICE TYPE'),'')
				, [BLDim]=isnull((Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = sil.[Dimension Set ID] and [Dimension Code] = 'BUSINESS LINE'),'')

		from	[MetroPolitanNavProduction].dbo.[Metropolitan$Sales Invoice Line] sil with (nolock)
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (sil.[Added By]) afn
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (sil.[Modified By]) mfn
		where sil.[Document No_] = @PostedInvoiceNo
		and (((sil.[QB Description] not in (select oi.ItemDescription collate Latin1_General_100_CS_AS from [POMS_DB].[dbo].[T_Order_Items] oi with(nolock) where oi.[ORDER_ID] = @ORDER_ID union
					select aoi.ItemDescription collate Latin1_General_100_CS_AS from [POMSArchive_DB].[dbo].[T_Order_Items] aoi with(nolock) where aoi.[ORDER_ID] = @ORDER_ID and @GetRecordType_MTV_ID not in (147100)) 
			and sil.[Sales Line Type] = 0)) or sil.[Sales Line Type] <> 0)
		order by sil.[Line No_]
	
	end
	else if @ApprovalValue in (154101,154102)
	begin
		insert into @ReturnTable
		select  [LineNo] = sl.[Line No_]
				, [ChargeType] = (
					case sl.[Sales Line Type]
						when 1 then concat('Delivery Charges(', (select top 1 gt.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Goods Type] gt with (nolock) where gt.[Good Type Code] = sl.[Goods type]), ')') + ' (G/L No-' + sl.[No_] + ')'
						when 2 then concat('Special Services(', (Select top 1 ss.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Special Service] ss with (nolock) where ss.[SS Code] = sl.[Goods type]), ')') + ' (G/L No-' + sl.[No_] + ')'
						when 3 then (select top 1 ss.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Special Service] ss with (nolock) where ss.[SS Code] = sl.[Goods type]) + ' (G/L No-' + sl.[No_] + ')'
						when 4 then (select top 1 dt.[Discount Name] from [MetroPolitanNavProduction].dbo.[Metropolitan$Discount Type] dt with (nolock) where dt.[Discount Type] = sl.[Goods type]) + ' (G/L No-' + sl.[No_] + ')'
						else ''
					end)
				, [Qty] = case when sl.[Sales Line Type]= 1 then sl.[Total Quantity] else 0 end
				, [Description] = sl.[Description]
				, [IsExtendedText] = (case when upper(sl.[Description]) = 'EXTENDED TEXT' then 1 else 0 end)
				, [QBDescription] = (case when upper(sl.[Description]) = 'EXTENDED TEXT' then 'EXTENDED TEXT' else sl.[QB Description] end)
				, [Amount] = sl.[Unit Price] 
				, [AddedBy] = afn.FullName
				, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC](sl.[Added On],@TimeZone_ID,null,@TimeZoneName)
				, [ModifiedBy] = mfn.FullName
				, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC](sl.[Modified On],@TimeZone_ID,null,@TimeZoneName)
				, [SalesLineType] = sl.[Sales Line Type]
				, [EstimatedInvoiceId]= @EstimateNo
				, [NavInvoiceId]= sl.[Document No_]
				, [InvoiceAddedDiscount] = 1
				, [GoodsType] = upper(sl.[Goods type])
				, [OrderNo] = sl.[Project ID]
				, [WRDim]=(Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = sl.[Dimension Set ID] and [Dimension Code] = 'WR LOCATION')
				, [SLDim]=(Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = sl.[Dimension Set ID] and [Dimension Code] = 'SERVICE TYPE')
				, [BLDim]=(Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = sl.[Dimension Set ID] and [Dimension Code] = 'BUSINESS LINE')

		from	[MetroPolitanNavProduction].dbo.[Metropolitan$Sales Line] sl with (nolock)
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (sl.[Added By]) afn
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (sl.[Modified By]) mfn
		where sl.[Document No_] = @UnPostedInvoiceNo
		and (((sl.[QB Description] not in (select oi.ItemDescription collate Latin1_General_100_CS_AS from [POMS_DB].[dbo].[T_Order_Items] oi with(nolock) where oi.[ORDER_ID] = @ORDER_ID union
					select aoi.ItemDescription collate Latin1_General_100_CS_AS from [POMSArchive_DB].[dbo].[T_Order_Items] aoi with(nolock) where aoi.[ORDER_ID] = @ORDER_ID and @GetRecordType_MTV_ID not in (147100)) 
			and sl.[Sales Line Type] = 0)) or sl.[Sales Line Type] <> 0)
		order by sl.[Line No_]
	
	end	
	
	if @ApprovalValue in (154100,154103,154105)
	begin
		insert into @ReturnTable
		select  [LineNo] = oil.LineNo_
				, [ChargeType] = (
					case oil.SalesLineType
						when 1 then concat('Delivery Charges(', (select top 1 gt.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Goods Type] gt with (nolock) where gt.[Good Type Code] = oil.GoodsType collate Latin1_General_100_CS_AS), ')') + ' (G/L No-' + oil.GL_NO + ')'
						when 2 then concat('Special Services(', (Select top 1 ss.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Special Service] ss with (nolock) where ss.[SS Code] = oil.GoodsType collate Latin1_General_100_CS_AS), ')') + ' (G/L No-' + oil.GL_NO + ')'
						when 3 then (select top 1 ss.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Special Service] ss with (nolock) where ss.[SS Code] = oil.GoodsType collate Latin1_General_100_CS_AS) + ' (G/L No-' + oil.GL_NO + ')'
						when 4 then (select top 1 dt.[Discount Name] from [MetroPolitanNavProduction].dbo.[Metropolitan$Discount Type] dt with (nolock) where dt.[Discount Type] = oil.GoodsType collate Latin1_General_100_CS_AS) + ' (G/L No-' + oil.GL_NO + ')'
						else ''
					end)
				, [Qty] = oil.ItemsQty
				, [Description] = oil.[Description]
				, [IsExtendedText] = (case when oil.InvoiceLineType = 0 then 1 else 1 end)
				, [QBDescription] = (case when oil.InvoiceLineType = 0 then 'EXTENDED TEXT' else oil.[Description] end)
				, [Amount] = oil.LineAmount 
				, [AddedBy] = afn.FullName
				, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC](oil.[AddedOn],@TimeZone_ID,null,@TimeZoneName)
				, [ModifiedBy] = mfn.FullName
				, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC](oil.[ModifiedOn],@TimeZone_ID,null,@TimeZoneName)
				, [SalesLineType] = oil.SalesLineType
				, [EstimatedInvoiceId]= @EstimateNo
				, [NavInvoiceId]= ''
				, [InvoiceAddedDiscount] = 1
				, [GoodsType] = oil.GoodsType
				, [OrderNo] = @ORDER_NO
				, [WRDim]=(case when oil.DimensionID = 0 then oil.WRDimension_HUB_CODE else
					(Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = oil.DimensionID and [Dimension Code] = 'WR LOCATION')
					end)
				, [SLDim]=(case when oil.DimensionID = 0 then oil.SLDimension_SL_CODE else
					(Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = oil.DimensionID and [Dimension Code] = 'SERVICE TYPE')
					end)
				, [BLDim]=(case when oil.DimensionID = 0 then oil.BLDimension_MTV_CODE else
					(Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = oil.DimensionID and [Dimension Code] = 'BUSINESS LINE')
					end)
		from	[POMS_DB].[dbo].[T_Order_Invoice_Line] oil with (nolock)
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oil.AddedBy) afn
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oil.ModifiedBy) mfn
		where oil.EstimateID = @EstimateID
		order by oil.LineNo_
	end

	return

end
GO
