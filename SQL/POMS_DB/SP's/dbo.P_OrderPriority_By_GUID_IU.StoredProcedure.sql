USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_OrderPriority_By_GUID_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_OrderPriority_By_GUID_IU] '',10100168,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_OrderPriority_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	
	,@IsUpdateRecord bit
	,@pOrderPriority_MTV_ID int
	
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
set @pOrderPriority_MTV_ID = isnull(@pOrderPriority_MTV_ID,0)

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
,OrderPriority_MTV_ID int
,OrderPriority_Name nvarchar(50) default null
,OldOrderPriority_MTV_ID int default null
,OldOrderPriority_Name nvarchar(50) default null
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

if @GetRecordType_MTV_ID in (147100,147102) and @ReturnText = ''
begin
	Declare @OldOrderPriority_MTV_ID int = 0
	Declare @OldOrderPriority_Name nvarchar(50) = ''
	Declare @OrderPriority_Name nvarchar(50) = ''

	if (@IsUpdateRecord = 1)
	begin
		if not exists(select mtv.MTV_ID from [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MTV_ID = @pOrderPriority_MTV_ID and mtv.MT_ID = 138 and mtv.IsActive = 1) and @ReturnText = ''
		begin
			set @ReturnText = 'Invalid Order Priority'
		end
		else
		begin
			select @OldOrderPriority_MTV_ID = OrderPriority_MTV_ID from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID

			set @OldOrderPriority_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@OldOrderPriority_MTV_ID)
			set @OrderPriority_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@pOrderPriority_MTV_ID)

			if(@OldOrderPriority_MTV_ID <> @pOrderPriority_MTV_ID)
			begin
				begin transaction

				begin try
				
					update [POMS_DB].[dbo].[T_Order] set OrderPriority_MTV_ID = @pOrderPriority_MTV_ID where ORDER_ID = @ORDER_ID
		
					Set @ReturnCode = 1
					Set @ReturnText = 'Updated'
		
					exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = @OldOrderPriority_MTV_ID
					, @pNewValueHidden = @pOrderPriority_MTV_ID ,@pOldValue = @OldOrderPriority_Name, @pNewValue = @OrderPriority_Name, @pColumn_Name = 'OrderPriority_MTV_ID', @pTable_Name = 'T_Order', @pReason = ''
					, @pSource_MTV_ID = @Source_MTV_ID, @pChangedBy = @UserName, @pIsAuto = 0, @pTriggerDebugInfo = 'P_OrderPriority_By_GUID_IU'

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

					exec [POMS_DB].[dbo].[P_SP_Error_Log_Add] @SPName = 'P_OrderPriority_By_GUID_IU', @ParameterString = null, @ErrorString = @ERRORMESSAGE

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
		insert into @ReturnTable (ORDER_ID, ReturnCode, OrderPriority_MTV_ID , UserName)
		Select @ORDER_ID, @ReturnCode, o.OrderPriority_MTV_ID ,@UserName from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID
	end
	else
	begin
		insert into @ReturnTable (ORDER_ID, ReturnCode ,ReturnText ,UserName ,OrderPriority_MTV_ID ,OrderPriority_Name ,OldOrderPriority_MTV_ID ,OldOrderPriority_Name)
		Select @ORDER_ID, @ReturnCode, @ReturnText ,@UserName ,@pOrderPriority_MTV_ID ,@OrderPriority_Name ,@OldOrderPriority_MTV_ID, @OldOrderPriority_Name
	end
end

select * from @ReturnTable

END
GO
