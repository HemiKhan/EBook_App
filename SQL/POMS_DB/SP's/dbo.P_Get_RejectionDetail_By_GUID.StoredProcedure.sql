USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_RejectionDetail_By_GUID]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================
-- [dbo].[P_Get_RejectionDetail_By_GUID] '25AACFED-5A9A-4CA0-9B79-8DBE6DB2477F','','',0,'','',1,'S-ESTINV4475928','SI11397925',2,0
-- ==============================================================


CREATE PROCEDURE [dbo].[P_Get_RejectionDetail_By_GUID]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@EstInvoiceNo nvarchar(50)
	,@InvoiceInvoiceNo nvarchar(50)
	,@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@ReturnCode bit output
	,@ReturnText nvarchar(250) output
	,@TotalRecords int output
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

	select [OrderID] 
	,[Reject_Count] 
	,[Cancel_Count] 
	,[EstInvoiceNo] 
	,[InvoiceNo] 
	,[Type] 
	,[Reason] 
	,[RejectedBy] 
	,[RejectionTime] 
	,[CreatedBy] 
	,[CreatedTime] 
	,[PostingDate]
	from [POMS_DB].[dbo].[F_Get_POMS_RejectionDetail_By_OrderID] (@ORDER_ID ,@EstInvoiceNo ,@InvoiceInvoiceNo ,0 ,@UserName ,@UserType_MTV_CODE ,@IsPublic ,@TimeZone_ID ,@GetRecordType_MTV_ID)

END

GO
