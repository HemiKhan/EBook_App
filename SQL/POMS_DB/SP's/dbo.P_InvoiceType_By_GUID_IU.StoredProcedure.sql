USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_InvoiceType_By_GUID_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_InvoiceType_By_GUID_IU] '',10100168,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_InvoiceType_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int

	,@IsUpdateRecord bit
	,@pInvoiceType_MTV_ID int
	
	,@Source_MTV_ID int
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
set @pInvoiceType_MTV_ID = isnull(@pInvoiceType_MTV_ID,0)

set @ORDER_ID = isnull(@ORDER_ID,0)

if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

Declare @ReturnTable table
(ORDER_ID int default 0
,ReturnCode bit default 0
,ReturnText nvarchar(250) default ''
,UserName nvarchar(150) default ''
,InvoiceType_MTV_ID int
,InvoiceType_Name nvarchar(50) default null
,OldInvoiceType_MTV_ID int default null
,OldInvoiceType_Name nvarchar(50) default null
)

if @ORDER_ID = 0
begin
	set @ReturnText = 'Invalid OrderID'
	select * from @ReturnTable
	return
end

if (@IsPublic is null)
begin 
	select @IsPublic = (case when @UserType_MTV_CODE = 'CLIENT-USER' then 0
	when @UserType_MTV_CODE = 'METRO-USER' then 1
	else 0 end)
end

if @GetRecordType_MTV_ID in (147100,147102)
begin
	Declare @OldInvoiceType_MTV_ID int
	Declare @OldInvoiceType_Name nvarchar(50)
	Declare @InvoiceType_Name nvarchar(50)

	if (@IsUpdateRecord = 1)
	begin
		if not exists(select mtv.MTV_ID from [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MTV_ID = @pInvoiceType_MTV_ID and mtv.MT_ID = 145 and mtv.IsActive = 1) and @ReturnText = ''
		begin
			set @ReturnText = 'Invalid Invoice Type'
		end
		else
		begin
			select @OldInvoiceType_MTV_ID = InvoiceType_MTV_ID from [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) where od.ORDER_ID = @ORDER_ID

			set @OldInvoiceType_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@OldInvoiceType_MTV_ID)
			set @InvoiceType_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@pInvoiceType_MTV_ID)

			if(@OldInvoiceType_MTV_ID <> @pInvoiceType_MTV_ID)
			begin
				begin transaction

				begin try
					
					update [POMS_DB].[dbo].[T_Order_Detail] set InvoiceType_MTV_ID = @pInvoiceType_MTV_ID where ORDER_ID = @ORDER_ID
		
					Set @ReturnCode = 1
					set @ReturnText = 'Updated'
		
					exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = @OldInvoiceType_MTV_ID
					, @pNewValueHidden = @pInvoiceType_MTV_ID ,@pOldValue = @OldInvoiceType_Name, @pNewValue = @InvoiceType_Name, @pColumn_Name = 'InvoiceType_MTV_ID', @pTable_Name = 'T_Order_Detail', @pReason = ''
					, @pSource_MTV_ID = @Source_MTV_ID, @pChangedBy = @UserName, @pIsAuto = 0, @pTriggerDebugInfo = 'P_InvoiceType_By_GUID_IU'

					if @@TRANCOUNT > 0 and @ReturnCode = 1
					begin
						COMMIT; 
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

					Set @ReturnCode = 0
					Set @ReturnText = 'Internal Server Error'
					
					Declare @ERRORMESSAGE nvarchar(max) = ERROR_MESSAGE()

					exec [POMS_DB].[dbo].[P_SP_Error_Log_Add] @SPName = 'P_InvoiceType_By_GUID_IU', @ParameterString = null, @ErrorString = @ERRORMESSAGE

				end catch

			end
			else
			begin
				set @ReturnText = 'No Change'
			end
		end
	end

	if @IsUpdateRecord = 0
	begin
		set @ReturnCode = 1
		insert into @ReturnTable (ORDER_ID, ReturnCode, InvoiceType_MTV_ID ,UserName)
		Select @ORDER_ID, @ReturnCode, od.InvoiceType_MTV_ID ,@UserName from [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) where od.ORDER_ID = @ORDER_ID
	end
	else
	begin
		insert into @ReturnTable (ORDER_ID, ReturnCode ,ReturnText ,UserName ,InvoiceType_MTV_ID ,InvoiceType_Name ,OldInvoiceType_MTV_ID ,OldInvoiceType_Name)
		Select @ORDER_ID, @ReturnCode, @ReturnText ,@UserName ,@pInvoiceType_MTV_ID ,@InvoiceType_Name ,@OldInvoiceType_MTV_ID, @OldInvoiceType_Name
	end

end

select * from @ReturnTable

END
GO
