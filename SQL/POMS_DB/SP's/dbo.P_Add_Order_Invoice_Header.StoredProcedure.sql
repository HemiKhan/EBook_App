USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Add_Order_Invoice_Header]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(50) = '' Declare @Ret_EstimateNo nvarchar(50) = '' exec [POMS_DB].[dbo].[P_Add_Order_Invoice_Header] 10100656, 'ABDULLAH.ARSHAD', @ReturnCode = @Ret_ReturnCode out, @ReturnText = @Ret_ReturnText out, @EstimateNo = @Ret_EstimateNo out select @Ret_ReturnCode ,@Ret_ReturnText ,@Ret_EstimateNo
-- =============================================
CREATE PROCEDURE [dbo].[P_Add_Order_Invoice_Header]
	@ORDER_ID int
	,@Username nvarchar(150)
	,@ReturnCode bit out
	,@ReturnText nvarchar(250) out
	,@EstimateNo nvarchar(20) out
AS
BEGIN
	
	--Start Insert Same Column Record From T_Order To T_Order_Invoice_Header_Additional_Info

	begin try

		set @ReturnCode = 0
		set @ReturnText = ''
		set @EstimateNo = ''

		Declare @CurrentInvoiceStatus_MTV_ID int = 0
		Declare @EstimateID bigint = 0
		Declare @SELLER_CODE nvarchar(20) = ''
		Declare @SUB_SELLER_CODE nvarchar(20) = ''
		Declare @SELLER_PARTNER_CODE nvarchar(20) = ''
		Declare @TARIFF_NO nvarchar(20) = ''
		Declare @BillTo_CUSTOMER_NO nvarchar(20) = ''
		Declare @PaymentTermsCode nvarchar(20) = ''
		Declare @WRDimensionHubCode nvarchar(20) = ''
		Declare @BLDimensionMTVCode nvarchar(20) = 'HOMEDELIVERY'
		Declare @SLDimensionSLCode nvarchar(20) = ''
		Declare @QBInvoiceNo nvarchar(50) = ''
		Declare @RECTXT nvarchar(50) = ''
		Declare @POCustRefNo nvarchar(50) = ''
		Declare @DueDate date = cast(getutcdate() as date)

		select @CurrentInvoiceStatus_MTV_ID = oih.InvoiceStatus_MTV_ID from [POMS_DB].[dbo].[T_Order_Invoice_Header] oih with (nolock) where ORDER_ID = @ORDER_ID
		select @CurrentInvoiceStatus_MTV_ID = isnull(@CurrentInvoiceStatus_MTV_ID,0)
		
		if @CurrentInvoiceStatus_MTV_ID = 153100
		begin
			set @ReturnText = 'Estimate Invoice Already Exists'
			return
		end
		else if @CurrentInvoiceStatus_MTV_ID = 153101
		begin
			set @ReturnText = 'Unposted Invoice Already Exists'
			return
		end

		select @SELLER_CODE = o.SELLER_CODE 
		,@SUB_SELLER_CODE = o.SUB_SELLER_CODE 
		,@SELLER_PARTNER_CODE = o.SELLER_PARTNER_CODE
		,@TARIFF_NO = o.TARIFF_NO 
		,@BillTo_CUSTOMER_NO = o.BillTo_CUSTOMER_NO
		,@WRDimensionHubCode = o.ShipTo_HUB_CODE
		,@SLDimensionSLCode = o.DELIVERY_ST_CODE 
		from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID

		select @SELLER_CODE = isnull(@SELLER_CODE,'')
		,@SUB_SELLER_CODE = isnull(@SUB_SELLER_CODE,'')
		,@SELLER_PARTNER_CODE = isnull(@SELLER_PARTNER_CODE,'')
		,@TARIFF_NO = isnull(@TARIFF_NO,'')
		,@BillTo_CUSTOMER_NO = isnull(@BillTo_CUSTOMER_NO,'')
		,@WRDimensionHubCode = isnull(@WRDimensionHubCode,'')
		,@SLDimensionSLCode = isnull(@SLDimensionSLCode,'')

		if @SELLER_CODE = ''
		begin
			set @ReturnText = 'Invalid Order No'
			return
		end

		select @PaymentTermsCode = [Payment Terms Code] from [MetroPolitanNavProduction].[dbo].[Metropolitan$Customer] with (nolock) where No_ = @BillTo_CUSTOMER_NO
		select @PaymentTermsCode = isnull(@PaymentTermsCode,'')

		Declare @DueDateCalculationName nvarchar(20) = ''
		Declare @Days int = -1
		Declare @IsNextMonthOf bit = 0
		Declare @IsMonthOf bit = 0
		Declare @Months int = 0
		
		select @DueDateCalculationName =replace(replace(replace([Due Date Calculation],char(2),char(68)),char(5),char(77)),char(1),char(67))
		from [MetroPolitanNavProduction].[dbo].[Metropolitan$Payment Terms] pt with (nolock) where Code = 'NET 45' --@PaymentTermsCode

		select @DueDateCalculationName = upper(isnull(@DueDateCalculationName,''))

		if @DueDateCalculationName <> ''
		begin
			set @IsNextMonthOf = (case when len(@DueDateCalculationName) > 6 then 
				(case when left(@DueDateCalculationName,6) in ('1M-CM+','2M-CM+','3M-CM+','4M-CM+','5M-CM+','6M-CM+','7M-CM+','8M-CM+','9M-CM+','10M-CM','11M-CM','12M-CM') then 1 else 0 end) 
			else 0 end)
			if @IsNextMonthOf = 1
			begin
				select @Months = SUBSTRING(@DueDateCalculationName, 1, CHARINDEX('M', @DueDateCalculationName) - 1)
			end
			else
			begin
				set @IsMonthOf = (case when len(@DueDateCalculationName) > 1 then 
					(case when left(@DueDateCalculationName,1) = 'D' then 1 else 0 end) 
				else 0 end)
				if @IsMonthOf = 1
				begin
					set @Days = replace(@DueDateCalculationName,'D','')
					DECLARE @CurrentDate date = getutcdate();
					DECLARE @TargetDay int = @Days;
					set @Days = case when DAY(@CurrentDate) <= @TargetDay then @TargetDay - DAY(@CurrentDate)
						else DAY(EOMONTH(@CurrentDate)) - DAY(@CurrentDate) + @TargetDay
					end
				end
				else if right(@DueDateCalculationName,1) = 'D'
				begin
					set @Days = replace(@DueDateCalculationName,'D','')
				end
			end
		end

		if @Days = -1
		begin
			set @ReturnText = 'Unable to Calculate Due Date'
			return
		end

		if @Days > 0
		begin
			set @DueDate = dateadd(day,@Days,@DueDate)
		end

		select @RECTXT = left(Value_,50) from [POMS_DB].[dbo].[T_Order_Client_Identifier] oci with (nolock) where oci.ORDER_ID = @ORDER_ID and oci.OIF_CODE = 'PONUMBER'
		select @POCustRefNo = left(Value_,50) from [POMS_DB].[dbo].[T_Order_Client_Identifier] oci with (nolock) where oci.ORDER_ID = @ORDER_ID and oci.OIF_CODE = 'REF2'

		select @RECTXT = isnull(@RECTXT,'')
		select @POCustRefNo = isnull(@POCustRefNo,'')

		DECLARE @ColumnsToCopy NVARCHAR(MAX);
		DECLARE @ColumnsFromCopy NVARCHAR(MAX);

		-- Get common columns between Table1 and Table2
		SET @ColumnsToCopy = (
			SELECT COLUMN_NAME + ','
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = 'T_Order_Invoice_Header_Additional_Info' AND COLUMN_NAME IN (
				SELECT COLUMN_NAME
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = 'T_Order'
				and COLUMN_NAME not in ('TimeStamp','AddedBy','AddedOn','ModifiedBy','ModifiedOn')
			)
			FOR XML PATH('')
		);

		SET @ColumnsFromCopy = (
			SELECT 'o.' + COLUMN_NAME + ','
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = 'T_Order' AND COLUMN_NAME IN (
				SELECT COLUMN_NAME
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = 'T_Order_Invoice_Header_Additional_Info'
				and COLUMN_NAME not in ('TimeStamp','AddedBy','AddedOn','ModifiedBy','ModifiedOn')
			)
			FOR XML PATH('')
		);

		-- Remove the trailing comma
		SET @ColumnsToCopy = LEFT(@ColumnsToCopy, LEN(@ColumnsToCopy) - 1);
		SET @ColumnsFromCopy = LEFT(@ColumnsFromCopy, LEN(@ColumnsFromCopy) - 1);

		DECLARE @SqlQuery NVARCHAR(MAX);

		exec [POMS_DB].[dbo].[P_Generate_EstimateInvoiceID] @Ret_EstimateID = @EstimateID out
		set @EstimateID = isnull(@EstimateID,0)

		if @EstimateID = 0
		begin
			set @ReturnText = 'Unable To Get Estimate Invoice No'
			return
		end

		SET @SqlQuery = 
			'INSERT INTO [POMS_DB].[dbo].[T_Order_Invoice_Header_Additional_Info]' +
			' (' + 'EstimateID,' + @ColumnsToCopy + ',AddedBy' + ')' + char(10) +
			' SELECT EstimateID=''' + cast(@EstimateID as nvarchar(20)) + ''',' + @ColumnsFromCopy + ',AddedBy=''' + @Username + '''' + char(10) +
			' FROM [POMS_DB].[dbo].[T_Order] o with (nolock) ' + char(10) +
			' Where o.ORDER_ID = ' + cast(@ORDER_ID as nvarchar(20))
		
		set @EstimateNo = 'S-ESTINV' + cast(@EstimateID as nvarchar(20))

		Begin Transaction

		insert into [POMS_DB].[dbo].[T_Order_Invoice_Header] ([EstimateID] ,[EstimateNo] ,[ORDER_ID] ,[PaymentTermsCode] ,[DueDate] ,[WRDimension_HUB_CODE] ,[BLDimension_MTV_CODE] ,[SLDimension_SL_CODE] ,[QBInvoiceNo] ,[RECTXT] ,[POCustRefNo] ,[AddedBy])
		values (@EstimateID, @EstimateNo, @ORDER_ID, @PaymentTermsCode, @DueDate, @WRDimensionHubCode, @BLDimensionMTVCode, @SLDimensionSLCode, @QBInvoiceNo, @RECTXT, @POCustRefNo, @Username)
			
		EXEC sp_executesql @SqlQuery;

		set @ReturnCode = 1

		exec [POMS_DB].[dbo].[P_Order_Invoice_Line_IU] @pEstimateID = @EstimateID ,@pUnitPrice = 0 ,@pDescription = 'Delivery Charges' ,@pGoodsType = 'DEL' ,@pUsername = @Username ,@pWRDimension_HUB_CODE = null
		,@pBLDimension_MTV_CODE = null ,@pSLDimension_SL_CODE = null ,@pUpdateWRDimensionType_MTV_ID = null ,@pInvoiceLineType = 1 ,@pIsBeginTransaction = 0 ,@pReturnCode = @ReturnCode out ,@pReturnText = @ReturnText out

		if @@TRANCOUNT > 0 and @ReturnCode = 1
		begin
			COMMIT; 
			set @ReturnText = 'Invoice Created'
		end
		else if @@TRANCOUNT > 0 and @ReturnCode = 0
		begin
			ROLLBACK; 
		end

	end try
	begin catch
		if @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		print ERROR_MESSAGE()
		set @ReturnText = 'Internal Server Error'
		set @EstimateNo = ''
	end catch

	--End Insert Same Column Record From T_Order To T_Order_Invoice_Header_Additional_Info

END
GO
