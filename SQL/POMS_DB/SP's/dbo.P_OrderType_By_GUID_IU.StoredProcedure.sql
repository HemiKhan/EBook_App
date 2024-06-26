USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_OrderType_By_GUID_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_OrderType_By_GUID_IU] '',10100781,1,0,0,166100,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_OrderType_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	
	,@IsUpdateRecord bit
	,@pOrderType_MTV_ID int
	,@pSubOrderType_ID int
	
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
set @pOrderType_MTV_ID = isnull(@pOrderType_MTV_ID,0)

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
,OrderType_MTV_ID int
,OrderType_Name nvarchar(50) default null
,SubOrderType int
,SubOrderType_Name nvarchar(100) default null
,OldOrderType_MTV_ID int default null
,OldOrderType_Name nvarchar(50) default null
,OldSubOrderType int default null
,OldSubOrderType_Name nvarchar(100) default null
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

	Declare @OldOrderType_MTV_ID int = 0
	Declare @OldOrderType_Name nvarchar(50) = ''
	Declare @OrderType_Name nvarchar(50) = ''
	Declare @OldSubOrderType_ID int = 0
	Declare @OldSubOrderType_Name nvarchar(50) = ''
	Declare @SubOrderType_Name nvarchar(50) = ''

	if (@IsUpdateRecord = 1)
	begin
		if not exists(select mtv.MTV_ID from [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MTV_ID = @pOrderType_MTV_ID and mtv.MT_ID = 146 and mtv.IsActive = 1) and @ReturnText = ''
		begin
			set @ReturnText = 'Invalid Order Type'
		end
		else if not exists(select sotv.SOTV_ID from [POMS_DB].[dbo].[T_Sub_Order_Type_Value] sotv with (nolock) where sotv.OrderType_MTV_ID = @pOrderType_MTV_ID and sotv.SubOrderType_ID = @pSubOrderType_ID and sotv.IsActive = 1) and @ReturnText = '' and @pSubOrderType_ID is not null
		begin
			set @ReturnText = 'Invalid Sub Order Type'
		end
		else
		begin
			Select @OldOrderType_MTV_ID = od.OrderType_MTV_ID ,@OldSubOrderType_ID = od.SubOrderType_ID from [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) where od.ORDER_ID = @ORDER_ID
			select @OldOrderType_MTV_ID = isnull(@OldOrderType_MTV_ID,0)

			set @OldOrderType_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@OldOrderType_MTV_ID)
			set @OrderType_Name = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@pOrderType_MTV_ID)

			select @OldSubOrderType_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_SubOrderType_By_ID] (@OldOrderType_MTV_ID ,@OldSubOrderType_ID)
			select @SubOrderType_Name = [POMS_DB].[dbo].[F_Get_PinnacleProd_SubOrderType_By_ID] (@pOrderType_MTV_ID ,@pSubOrderType_ID)

			if (@OldOrderType_MTV_ID <> @pOrderType_MTV_ID or isnull(@OldOrderType_MTV_ID,0) <> isnull(@OldOrderType_MTV_ID,0))
			begin
				
				begin transaction

				begin try
					
					update [POMS_DB].[dbo].[T_Order_Detail] set OrderType_MTV_ID = @pOrderType_MTV_ID, SubOrderType_ID = @pSubOrderType_ID where ORDER_ID = @ORDER_ID
		
					Set @ReturnCode = 1
					Set @ReturnText = 'Updated'
		
					if @OldOrderType_Name <> @OrderType_Name
					begin
						exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = @OldOrderType_MTV_ID
						, @pNewValueHidden = @pOrderType_MTV_ID ,@pOldValue = @OldOrderType_Name, @pNewValue = @OrderType_Name, @pColumn_Name = 'OrderType_MTV_ID', @pTable_Name = 'T_Order_Detail', @pReason = ''
						, @pSource_MTV_ID = 0, @pChangedBy = @UserName, @pIsAuto = 0, @pTriggerDebugInfo = 'P_OrderType_By_GUID_IU'
					end
					if @OldSubOrderType_Name <> @SubOrderType_Name
					begin
						exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = @OldSubOrderType_ID
						, @pNewValueHidden = @pSubOrderType_ID ,@pOldValue = @OldSubOrderType_Name, @pNewValue = @SubOrderType_Name, @pColumn_Name = 'SubOrderType_ID', @pTable_Name = 'T_Order_Detail', @pReason = ''
						, @pSource_MTV_ID = @Source_MTV_ID, @pChangedBy = @UserName, @pIsAuto = 0, @pTriggerDebugInfo = 'P_OrderType_By_GUID_IU'
					end

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

					exec [POMS_DB].[dbo].[P_SP_Error_Log_Add] @SPName = 'P_OrderType_By_GUID_IU', @ParameterString = null, @ErrorString = @ERRORMESSAGE

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
		insert into @ReturnTable (ORDER_ID, ReturnCode, OrderType_MTV_ID ,SubOrderType, UserName)
		Select @ORDER_ID, @ReturnCode, od.OrderType_MTV_ID ,od.SubOrderType_ID ,@UserName from [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) where od.ORDER_ID = @ORDER_ID
	end
	else
	begin
		insert into @ReturnTable (ORDER_ID, ReturnCode ,ReturnText ,UserName ,OrderType_MTV_ID ,OrderType_Name ,SubOrderType ,SubOrderType_Name ,OldOrderType_MTV_ID ,OldOrderType_Name ,OldSubOrderType ,OldSubOrderType_Name)
		Select @ORDER_ID, @ReturnCode, @ReturnText ,@UserName ,@pOrderType_MTV_ID ,@OrderType_Name ,@pSubOrderType_ID ,@SubOrderType_Name, @OldOrderType_MTV_ID, @OldOrderType_Name, @OldSubOrderType_ID, @OldSubOrderType_Name
	end

end

select * from @ReturnTable

END

GO
