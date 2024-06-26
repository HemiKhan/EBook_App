USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Invoice_Line_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Invoice_Line_IU]
	@pEstimateID int
	,@pUnitPrice decimal(18,6)
	,@pDescription nvarchar(150)
	,@pGoodsType nvarchar(20)
	,@pUsername nvarchar(150)
	,@pWRDimension_HUB_CODE nvarchar(20) = null
	,@pBLDimension_MTV_CODE nvarchar(20) = null
	,@pSLDimension_SL_CODE nvarchar(20) = null
	,@pUpdateWRDimensionType_MTV_ID int = null
	,@pInvoiceLineType int = 1
	,@pIsBeginTransaction bit = 1
	,@pReturnCode bit out
	,@pReturnText nvarchar(250) out
AS
BEGIN
	
	begin try

		set @pReturnCode = 0
		set @pReturnText = ''

		set @pGoodsType = upper(isnull(@pGoodsType,''))
		Declare @EstimateNo nvarchar(20) = ''
		Declare @ORDER_ID int = 0
		Declare @InvoiceStatus_MTV_ID int = 0
		Declare @ApprovalValue_MTV_ID int = 0
		Declare @WRDimension_HUB_CODE nvarchar(20) = ''
		Declare @BLDimension_MTV_CODE nvarchar(20) = ''
		Declare @SLDimension_SL_CODE nvarchar(20) = ''
		Declare @DimensionID int = 0

		Declare @Quantity int = 1
		Declare @ItemsQty int = 0
		Declare @ItemsWeight decimal(18,6) = 0
		Declare @ItemsCuFt decimal(18,6) = 0
		Declare @ItemsValue decimal(18,6) = 0
		Declare @SalesLineType int  = 1
		Declare @LineAmount decimal(18,6) = (@Quantity * @pUnitPrice)
		Declare @LineNo_ int = 0
		Declare @GL_NO nvarchar(20) = '41050'
	
		select @EstimateNo = EstimateNo, @ORDER_ID = oih.ORDER_ID, @InvoiceStatus_MTV_ID = oih.InvoiceStatus_MTV_ID, @ApprovalValue_MTV_ID = oih.ApprovalValue_MTV_ID
		, @WRDimension_HUB_CODE = isnull(@pWRDimension_HUB_CODE,oih.WRDimension_HUB_CODE)
		, @BLDimension_MTV_CODE = isnull(@pBLDimension_MTV_CODE,oih.BLDimension_MTV_CODE)
		, @SLDimension_SL_CODE = isnull(@pSLDimension_SL_CODE,oih.SLDimension_SL_CODE)
		, @DimensionID = (case when oih.DimensionID = 0 then 0 else 
			(case when isnull(@pWRDimension_HUB_CODE,WRDimension_HUB_CODE) = WRDimension_HUB_CODE and isnull(@pBLDimension_MTV_CODE,oih.BLDimension_MTV_CODE) = oih.BLDimension_MTV_CODE and isnull(@pSLDimension_SL_CODE,SLDimension_SL_CODE) = oih.SLDimension_SL_CODE
			then oih.DimensionID else 0 end)
		end)
		, @pUpdateWRDimensionType_MTV_ID = isnull(@pUpdateWRDimensionType_MTV_ID,oih.UpdateWRDimensionType_MTV_ID) 
		from [POMS_DB].[dbo].[T_Order_Invoice_Header] oih with (nolock) where oih.EstimateID = @pEstimateID

		select @EstimateNo = isnull(@EstimateNo,'')
		
		if @EstimateNo = ''
		begin
			set @pReturnText = 'Invalid Estimate Invoice No'
			return
		end
		else
		begin
			if @InvoiceStatus_MTV_ID <> 153100
			begin
				set @pReturnText = 'Invoice Status is ' + [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@InvoiceStatus_MTV_ID)
				return
			end
			else if @ApprovalValue_MTV_ID not in (154100,154103,154105)
			begin
				set @pReturnText = 'Approval Status is ' + [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@ApprovalValue_MTV_ID)
				return
			end
		end

		if @pGoodsType in ('DEL')
		begin
			select @ItemsQty = od.TotalQty
			,@ItemsWeight = od.TotalWeight
			,@ItemsCuFt = od.TotalCubes
			,@ItemsValue = TotalValue
			from [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) where od.ORDER_ID = @ORDER_ID
			select @ItemsQty = isnull(@ItemsQty,0)
			,@ItemsWeight = isnull(@ItemsWeight,0)
			,@ItemsCuFt = isnull(@ItemsCuFt,0)
			,@ItemsValue = isnull(@ItemsValue,0)
		end
		
		if @pIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		select @LineNo_ = max(LineNo_) from [POMS_DB].[dbo].[T_Order_Invoice_Line] oil with (nolock) where oil.EstimateID = @pEstimateID
		set @LineNo_ = isnull(@LineNo_,0)
		set @LineNo_ = @LineNo_ + 10000

		insert into [POMS_DB].[dbo].[T_Order_Invoice_Line] (EstimateID ,ORDER_ID ,LineNo_ ,InvoiceLineType ,GL_NO ,Quantity ,UnitPrice ,LineAmount ,[Description] ,SalesLineType ,WRDimension_HUB_CODE  ,BLDimension_MTV_CODE 
		,SLDimension_SL_CODE ,DimensionID ,UpdateWRDimensionType_MTV_ID ,GoodsType ,ItemsQty ,ItemsWeight ,ItemsCuFt ,ItemsValue ,AddedBy)
		values (@pEstimateID, @ORDER_ID, @LineNo_, @pInvoiceLineType, @GL_NO, @Quantity, @pUnitPrice, @LineAmount, @pDescription, @SalesLineType, @WRDimension_HUB_CODE, @BLDimension_MTV_CODE,
		@SLDimension_SL_CODE, @DimensionID, @pUpdateWRDimensionType_MTV_ID, @pGoodsType, @ItemsQty, @ItemsWeight, @ItemsCuFt, @ItemsValue, @pUsername)

		Declare @TotalAmount decimal(18,6) = @LineAmount
		select @TotalAmount = sum(oil.LineAmount) from [POMS_DB].[dbo].[T_Order_Invoice_Line] oil with (nolock) where oil.EstimateID = @pEstimateID

		update oih
		set oih.Amount = @TotalAmount
		from [POMS_DB].[dbo].[T_Order_Invoice_Header] oih
		where EstimateID = @pEstimateID

		set @pReturnCode = 1
		set @pReturnText = 'Invoice Line Added'

		if @pIsBeginTransaction = 1
		begin
			if @@TRANCOUNT > 0 and @pReturnCode = 1
			begin
				COMMIT; 
			end
		end

	end try
	begin catch
		if @pIsBeginTransaction = 1
		begin
			if @@TRANCOUNT > 0 and @pReturnCode = 1
			begin
				ROLLBACK; 
			end
		end
		print ERROR_MESSAGE()
		set @pReturnText = 'Internal Server Error'
	end catch

END
GO
