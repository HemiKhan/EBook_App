USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_InvoiceLine_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_InvoiceLine_By_OrderID] (3251255,'','ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_InvoiceLine_By_OrderID]
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
	Declare @PostedInvoiceNo nvarchar(20) = ''
	Declare @UnPostedInvoiceNo nvarchar(20) = ''
	select @ApprovalValue = seh.[Approval Status], @InvoiceStatus = seh.[Invoice Status], @PostedInvoiceNo = seh.[Posted Invoice No]
	from [MetroPolitanNavProduction].[dbo].[Metropolitan$Sales Estimate Header] seh with (nolock) where seh.[No_] = @EstimateNo

	select @ApprovalValue = isnull(@ApprovalValue,-1), @InvoiceStatus = isnull(@InvoiceStatus,-1), @PostedInvoiceNo = isnull(@PostedInvoiceNo,'')

	if @ApprovalValue = -1
	begin
		return
	end

	if @ApprovalValue in (1,2)
	begin
		select @UnPostedInvoiceNo = sh.No_ from [MetroPolitanNavProduction].[dbo].[Metropolitan$Sales Header] sh with (nolock) where sh.[Estimate Invoice No] = @EstimateNo
		select @UnPostedInvoiceNo = isnull(@UnPostedInvoiceNo,'')
	end

	if @ApprovalValue in (4)
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
		and (((sil.[QB Description] not in (select sll.[Item Description] from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with(nolock) where sll.[Sales Order No] = @ORDER_NO union
					select sll.[Item Description] from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Line Link] sll with(nolock) where sll.[Sales Order No] = @ORDER_NO and @GetRecordType_MTV_ID not in (147103)) 
			and sil.[Sales Line Type] = 0)) or sil.[Sales Line Type] <> 0)
		order by sil.[Line No_]
	
	end
	else if @ApprovalValue in (1,2)
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
		and (((sl.[QB Description] not in (select sll.[Item Description] from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with(nolock) where sll.[Sales Order No] = @ORDER_NO union
					select sll.[Item Description] from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Line Link] sll with(nolock) where sll.[Sales Order No] = @ORDER_NO and @GetRecordType_MTV_ID not in (147103)) 
			and sl.[Sales Line Type] = 0)) or sl.[Sales Line Type] <> 0)
		order by sl.[Line No_]
	
	end	
	
	if @ApprovalValue in (0,3)
	begin
		insert into @ReturnTable
		select  [LineNo] = sel.[Line No_]
				, [ChargeType] = (
					case sel.[Sales Line Type]
						when 1 then concat('Delivery Charges(', (select top 1 gt.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Goods Type] gt with (nolock) where gt.[Good Type Code] = sel.[Goods type]), ')') + ' (G/L No-' + sel.[No_] + ')'
						when 2 then concat('Special Services(', (Select top 1 ss.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Special Service] ss with (nolock) where ss.[SS Code] = sel.[Goods type]), ')') + ' (G/L No-' + sel.[No_] + ')'
						when 3 then (select top 1 ss.[Description] from [MetroPolitanNavProduction].dbo.[Metropolitan$Special Service] ss with (nolock) where ss.[SS Code] = sel.[Goods type]) + ' (G/L No-' + sel.[No_] + ')'
						when 4 then (select top 1 dt.[Discount Name] from [MetroPolitanNavProduction].dbo.[Metropolitan$Discount Type] dt with (nolock) where dt.[Discount Type] = sel.[Goods type]) + ' (G/L No-' + sel.[No_] + ')'
						else ''
					end)
				, [Qty] = case when sel.[Sales Line Type]= 1 then sel.[Total Quantity] else 0 end
				, [Description] = sel.[Description]
				, [IsExtendedText] = (case when (sel.[No_] = '0' or sel.[No_] = '') then 1 else 0 end)
				, [QBDescription] = (case when (sel.[No_] = '0' or sel.[No_] = '') then 'EXTENDED TEXT' else sel.[Description] end)
				, [Amount] = sel.[Unit Price] 
				, [AddedBy] = afn.FullName
				, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC](sel.[Added On],@TimeZone_ID,null,@TimeZoneName)
				, [ModifiedBy] = mfn.FullName
				, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC](sel.[Modified On],@TimeZone_ID,null,@TimeZoneName)
				, [SalesLineType] = sel.[Sales Line Type]
				, [EstimatedInvoiceId]= sel.[Document No_]
				, [NavInvoiceId]= ''
				, [InvoiceAddedDiscount] = 1
				, [GoodsType] = upper(sel.[Goods type])
				, [OrderNo] = sel.[Project ID]
				, [WRDim]=(Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = sel.[Dimension Set ID] and [Dimension Code] = 'WR LOCATION')
				, [SLDim]=(Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = sel.[Dimension Set ID] and [Dimension Code] = 'SERVICE TYPE')
				, [BLDim]=(Select [Dimension Value Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Dimension Set Entry] with (nolock) where [Dimension Set ID] = sel.[Dimension Set ID] and [Dimension Code] = 'BUSINESS LINE')

		from	[MetroPolitanNavProduction].dbo.[Metropolitan$Sales Estimate Line] sel with (nolock)
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (sel.[Added By]) afn
		outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (sel.[Modified By]) mfn
		where sel.[Document No_] = @EstimateNo
		order by sel.[Line No_]
	end

	return

end
GO
