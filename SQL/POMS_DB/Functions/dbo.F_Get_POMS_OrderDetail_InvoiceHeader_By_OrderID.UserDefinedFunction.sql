USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_InvoiceHeader_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_InvoiceHeader_By_OrderID] (3134111,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_InvoiceHeader_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([OrderID] int
, [EstimateID] int
, [EstimateNO] nvarchar(20)
, [CreatedOn] datetime
, [PostingDate] date
, [CreatedBy] nvarchar(150)
, [Amount] decimal(18,2)
, [InvoiceStatusID] int
, [ApprovalValueID] int
, [InvoiceStatus] nvarchar(50)
, [NavInvoiceID] nvarchar(20)
, [PaymentStatus] nvarchar(50)
, [PaidAmount] decimal(18,2)
, [CMAmount] decimal(18,2)
, [Balance] decimal(18,2)
, [ApprovalValue] nvarchar(50)
, [RejectCount] int
, [CancelCount] int
, [NeedEDI] nvarchar(50)
, [NeedEDIType] int
, [EDIStatus] nvarchar(50)
, [EDIStatusCode] int
, [WRDim] nvarchar(50)
, [SLDim] nvarchar(50)
, [BLDim] nvarchar(50)
, [IsInvoiceMapOrdersExist] bit
, [APIDetail] nvarchar(250)
, TotalRecords int
)
AS
begin
	
	Declare @TotalRecords int = 0
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	Declare @EstimateNO nvarchar(50) = null
	Declare @NavInvoiceID nvarchar(50) = null
	Declare @Ret_Reject_Count int = 0
	Declare @Ret_Cancel_Count int = 0
	Declare @Ret_ReturnCode bit = 0
	Declare @Ret_ReturnText nvarchar(250) = ''
	Declare @IsAPIInvoiceActive bit = 0

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	--if 1 = 1
	--begin
	--	Declare @SELLER_CODE nvarchar(20) = ''
	--	Declare @SUB_SELLER_CODE nvarchar(20)
	--	Declare @SELLER_PARTNER_CODE nvarchar(20)
	--	Declare @TARIFF_NO nvarchar(36)
	--	Declare @BillTo_CUSTOMER_NO nvarchar(20)
	--	select @SELLER_CODE = o.SELLER_CODE
	--	,@SUB_SELLER_CODE = o.SUB_SELLER_CODE
	--	,@SELLER_PARTNER_CODE = o.SELLER_PARTNER_CODE
	--	,@TARIFF_NO = o.TARIFF_NO
	--	,@BillTo_CUSTOMER_NO = o.BillTo_CUSTOMER_NO
	--	from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID
		
	--	select @IsAPIInvoiceActive = pk.[Is_Enable_Green_Button] from [PPlus_DB].[dbo].[T_Price_Key] pk with (nolock) 
	--	where pk.[Is_Active] = 1 and pk.[P_Key] = ''
	--	set @IsAPIInvoiceActive = isnull(@IsAPIInvoiceActive,0)
	--end

	select @TotalRecords = count([Order ID]) from [POMS_DB].[dbo].[V_POMS_Order_Invoice_Detail] poid with (nolock) where poid.[Order ID] = @ORDER_ID 
	
	if @TotalRecords > 0
	begin
		select @EstimateNO = poid.[Estimated InvoiceNo] ,@NavInvoiceID = poid.[Nav Invoice ID] from [POMS_DB].[dbo].[V_POMS_Order_Invoice_Detail] poid with (nolock) 
		where poid.[Order ID] = @ORDER_ID and poid.[Approval Value_] in (154101,154102,154103,154105)
		
		if @EstimateNO is not null
		begin
			select top 1 @Ret_Reject_Count = Reject_Count, @Ret_Cancel_Count = Cancel_Count from [POMS_DB].[dbo].[F_Get_RejectionDetail_By_OrderID] (@ORDER_ID ,@EstimateNO ,@NavInvoiceID ,1 ,@UserName ,@UserType_MTV_CODE ,@IsPublic ,@TimeZone_ID ,@GetRecordType_MTV_ID)
			select @Ret_Reject_Count = isnull(@Ret_Reject_Count,0), @Ret_Cancel_Count = isnull(@Ret_Cancel_Count,0)
		end
		
		insert into @ReturnTable ([OrderID] , [EstimateID] , [EstimateNO] , [CreatedOn] , [PostingDate] , [CreatedBy] , [Amount] , [InvoiceStatusID] , [ApprovalValueID] , [InvoiceStatus] , [NavInvoiceID] 
		, [PaymentStatus] , [PaidAmount] , [CMAmount] , [Balance] , [ApprovalValue] , [RejectCount] , [CancelCount] , [NeedEDI] , [NeedEDIType] , [EDIStatus] , [EDIStatusCode] , [WRDim] , [SLDim] 
		, [BLDim] , [IsInvoiceMapOrdersExist] , [APIDetail] , TotalRecords)
		select *
		,[APIDetail] = (case when invoice.[ApprovalValue_] in (154101,154102) and invoice.InvoiceStatus_ = 153101 then [POMS_DB].[dbo].[F_Get_Is_API_Invoice] (invoice.[EstimateNO],@ORDER_NO,@ORDER_ID,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID,@TimeZoneName) else '' end)
		,@TotalRecords
		from (
		select oid.[Order ID]
			,[EstimateID] = oid.[Estimated ID]
		
			, [EstimateNO] = oid.[Estimated InvoiceNo]

			--, [CreatedOn]=getutcdate()
			, [CreatedOn]=[POMS_DB].[dbo].[F_Get_DateTime_From_UTC](oid.[Create Time],@TimeZone_ID,null,@TimeZoneName)

			, [PostingDate]=(case when oid.[Approval Value_] = 154100 then cast(getutcdate() as date) else oid.[Posting Date] end)
			
			, [CreatedBy] =oid.[Created By]

			--, [Amount] = 0
			, [Amount] = isnull(oid.[Amount],0)

			, [InvoiceStatus_] = oid.[Invoice Status_]
			, [ApprovalValue_] = oid.[Approval Value_]

			, [InvoiceStatus] = oid.[Invoice Status]

			, [NavInvoiceID] = oid.[Nav Invoice ID]

			--, [PaymentStatus] = ''
			, [PaymentStatus] = oid.[Payment Status]

			, [PaidAmount] = oid.[Payment Amount]

			, [CMAmount] = oid.[Credit Memo Amount]

			--, [Balance] = 0
			, [Balance] = oid.[Remaining Amount]

			, [ApprovalValue] = oid.[Approval Value]

			, [Reject_Count] = @Ret_Reject_Count

			, [Cancel_Count] = @Ret_Cancel_Count

			, [NeedEDI]= oid.[NeedEDI]

			, [NeedEDIType] = [NeedEDICode]
		
			, [EDIStatus] = oid.[EDIStatus]

			, [EDIStatusCode] = oid.[EDIStatusCode]

			, [WRDim] = [Warehouse Dimension ID]

			, [SLDim] = [Service Level Dimension ID]
		
			, [BLDim] = [Business Line Dimension ID]
		
			--, [Invoice Map Orders] = isnull(oid.[Invoice Map Orders],'')
			, [IsInvoiceMapOrdersExist] = (Case when (Select top 1 1 from [POMS_DB].[dbo].[T_Invoice_Order_Mapping] iom with (nolock) where iom.InvoiceNo = oid.[Estimated InvoiceNo] collate Latin1_General_100_CS_AS and iom.ORDER_ID = oid.[Order ID] and iom.IsActive = 1) = 1 then 1 else 0 end)

		from [POMS_DB].[dbo].[V_POMS_Order_Invoice_Detail] oid with (nolock)
		where oid.[Order ID] = @ORDER_ID

		) invoice 
		order by invoice.EstimateID asc
	end

	return
	

end
GO
