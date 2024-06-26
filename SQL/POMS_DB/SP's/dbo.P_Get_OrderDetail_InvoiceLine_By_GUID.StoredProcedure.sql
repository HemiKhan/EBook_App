USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_OrderDetail_InvoiceLine_By_GUID]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_Get_OrderDetail_InvoiceLine_By_GUID] '',10100656,'S-ESTINV10000011','ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode ,@Ret_ReturnText
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_Get_OrderDetail_InvoiceLine_By_GUID] '7ECADB58-AC2A-4535-BECE-40B1441999F5',0,'S-ESTINV5243220','ABDULLAH.ARSHAD','METRO-USER',null,13,147103,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode ,@Ret_ReturnText
-- ===============================================================

CREATE PROCEDURE [dbo].[P_Get_OrderDetail_InvoiceLine_By_GUID]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	,@EstimateNo nvarchar(20)
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@ReturnCode bit output
	,@ReturnText nvarchar(250) output
)

AS

BEGIN

set @ORDER_CODE_GUID = upper(@ORDER_CODE_GUID)
set @UserName = upper(@UserName)
set @ReturnCode = 0
set @ReturnText = ''

set @ORDER_ID = isnull(@ORDER_ID,0)

if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

if @ORDER_ID = 0
begin
	set @ReturnText = 'Invalid OrderID'
end
else
begin
	set @ReturnCode = 1
end

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

Declare @ReturnTable table
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

if @GetRecordType_MTV_ID in (147100,147101,147102)
begin
	insert into @ReturnTable
	select [LineNo] 
	, [ChargeType] 
	, [Qty] 
	, [Description] 
	, [IsExtendedText] 
	, [QBDescription] 
	, [Amount] 
	, [AddedBy] 
	, [AddedOn] 
	, [ModifiedBy] 
	, [ModifiedOn] 
	, [SalesLineType] 
	, [EstimatedNO] 
	, [NavInvoiceId] 
	, [InvoiceAddedDiscount] 
	, [GoodsType] 
	, [OrderNo] 
	, [WRDim] 
	, [SLDim] 
	, [BLDim] 
	from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_InvoiceLine_By_OrderID] (@ORDER_ID,@EstimateNo,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end
else if @GetRecordType_MTV_ID in (147103,147104,147105)
begin
	insert into @ReturnTable
	select [LineNo] 
	, [ChargeType] 
	, [Qty] 
	, [Description] 
	, [IsExtendedText] 
	, [QBDescription] 
	, [Amount] 
	, [AddedBy] 
	, [AddedOn] 
	, [ModifiedBy] 
	, [ModifiedOn] 
	, [SalesLineType] 
	, [EstimatedNO] 
	, [NavInvoiceId] 
	, [InvoiceAddedDiscount] 
	, [GoodsType] 
	, [OrderNo] 
	, [WRDim] 
	, [SLDim] 
	, [BLDim] 
	from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_InvoiceLine_By_OrderID] (@ORDER_ID,@EstimateNo,@UserName,@UserType_MTV_CODE,@IsPublic,@TimeZone_ID,@GetRecordType_MTV_ID)
end

--if not exists(select * from @ReturnTable) and @ReturnText = ''
--begin
--	set @ReturnText = 'No Record Found'
--end
--else
--begin
--	set @ReturnCode = 1
--end

select * from @ReturnTable order by [LineNo]

END
GO
