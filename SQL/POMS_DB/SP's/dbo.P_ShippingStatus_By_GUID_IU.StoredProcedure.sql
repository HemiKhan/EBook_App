USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_ShippingStatus_By_GUID_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- ===============================================================
-- Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' exec [dbo].[P_ShippingStatus_By_GUID_IU] '',10100781,1,0,0,166100,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
-- ===============================================================

CREATE PROCEDURE [dbo].[P_ShippingStatus_By_GUID_IU]
(
	@ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	
	,@IsUpdateRecord bit
	,@pEvent_Activity_MTV_ID int
	,@pEventID int
	,@pComment nvarchar(1000) = null
	
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
set @pEvent_Activity_MTV_ID = isnull(@pEvent_Activity_MTV_ID,0)
set @pEventID = isnull(@pEventID,0)
set @pComment = isnull(@pComment,'')

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
,ShippingStatus_EVENT_ID int default null
,ShippingStatus_Name nvarchar(250) default null
,IsEventUpdate bit default 0
,IsCommentUpdate bit default 0
,ActivitiesEvent int default 0
,PublicComments int default 0
,PrivateComments int default 0
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
	Declare @ShippingStatus_EVENT_ID int = 0
	Declare @ShippingStatus_Name nvarchar(250) = ''
	Declare @IsEventUpdate bit = 0
	Declare @IsCommentUpdate bit = 0
	Declare @ActivitiesEvent int = 0
	Declare @PublicComments int = 0
	Declare @PrivateComments int = 0

	if (@IsUpdateRecord = 1)
	begin
		if not exists(select el.EVENT_ID from [POMS_DB].[dbo].[T_Events_List] el with (nolock) where el.EVENT_ID = @pEVENTID and el.Activity_MTV_ID = @pEvent_Activity_MTV_ID and el.IsActive = 1) and @ReturnText = '' and @pEvent_Activity_MTV_ID <> 0
		begin
			set @ReturnText = 'Invalid Event ID'
		end
		else if not exists(select el.EVENT_ID from [POMS_DB].[dbo].[T_Events_List] el with (nolock) where el.EVENT_ID = @pEVENTID and el.IsActive = 1) and @ReturnText = ''
		begin
			set @ReturnText = 'Invalid Event ID'
		end
		else
		begin
			
			begin transaction

			begin try
					
				--exec [POMS_DB].[dbo].[EventTrigger]
				
				Set @ReturnCode = 1
				Set @ReturnText = 'Updated'
				
				if @pComment <> ''
				begin
					Declare @Ret_AddRowCount int = 0
					Declare @Ret_EditRowCount int = 0
					Declare @Ret_DeleteRowCount int = 0
					Declare @Ret_Return_Code bit = 0
					Declare @Ret_Return_Text nvarchar(1000) = ''
					Declare @Ret_Execution_Error nvarchar(1000) = ''
					Declare @Ret_Error_Text nvarchar(max) = ''

					exec [POMS_DB].[dbo].[P_Order_Comments_IU] @pJson = '' ,@pOrder_ID = @ORDER_ID ,@pOC_ID = 0 ,@pComment = @pComment ,@pIsPublic = 0 ,@pUserName = @UserName 
					,@pIsCall = 0 ,@pIsActive = 1 ,@pImportanceLevel_MTV_ID = null ,@pAddRowCount = @Ret_AddRowCount out ,@pEditRowCount = @Ret_EditRowCount out ,@pDeleteRowCount = @Ret_DeleteRowCount out 
					,@pReturn_Code = @Ret_Return_Code out ,@pReturn_Text = @Ret_Return_Text out ,@pExecution_Error = @Ret_Execution_Error out ,@pError_Text = @Ret_Error_Text out ,@pIsBeginTransaction = 0	,@pSource_MTV_ID = @Source_MTV_ID

					if @Ret_Return_Code = 0
					begin
						set @ReturnCode = @Ret_Return_Code
						set @ReturnText = (case when @Ret_Return_Text = '' then 'Unable to Added Comment' else @Ret_Return_Text end)
					end

				end

				if @@TRANCOUNT > 0 and @ReturnCode = 1
				begin
					COMMIT; 
				end
				else if @@TRANCOUNT > 0 and @ReturnCode = 0
				begin
					ROLLBACK; 
				end

				if (@ReturnCode = 1)
				begin

					select @ShippingStatus_EVENT_ID = ShippingStatus_EVENT_ID from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID
					set @ShippingStatus_Name = [POMS_DB].[dbo].[F_Get_EventName_From_EventID] (@ShippingStatus_EVENT_ID)

					if (@IsEventUpdate = 1)
					begin
						select @ActivitiesEvent = count(oe.OE_ID) from [POMS_DB].[dbo].[T_Order_Events] oe with (nolock) where oe.ORDER_ID = @ORDER_ID and oe.IsActive = 1
					end

					if (@IsCommentUpdate = 1)
					begin
						select @PublicComments = sum(case when oc.[IsPublic] = 1 then 1 else 0 end) 
							,@PrivateComments = sum(case when oc.[IsPublic] = 0 then 1 else 0 end) 
						from [POMS_DB].[dbo].[T_Order_Comments] oc with (nolock) where oc.ORDER_ID = @ORDER_ID and oc.IsActive = 1
					end
						
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

				exec [POMS_DB].[dbo].[P_SP_Error_Log_Add] @SPName = 'P_ShippingStatus_By_GUID_IU', @ParameterString = null, @ErrorString = @ERRORMESSAGE

			end catch

		end
	end

	if @IsUpdateRecord = 0
	begin
		set @ReturnCode = 1
		select @ShippingStatus_EVENT_ID = ShippingStatus_EVENT_ID from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.ORDER_ID = @ORDER_ID
		set @ShippingStatus_Name = [POMS_DB].[dbo].[F_Get_EventName_From_EventID] (@ShippingStatus_EVENT_ID)

		insert into @ReturnTable (ORDER_ID, ReturnCode, UserName, ShippingStatus_EVENT_ID ,ShippingStatus_Name)
		Select @ORDER_ID, @ReturnCode, @UserName, @ShippingStatus_EVENT_ID, @ShippingStatus_Name
	end
	else
	begin
		insert into @ReturnTable (ORDER_ID ,ReturnCode ,ReturnText ,UserName ,ShippingStatus_EVENT_ID ,ShippingStatus_Name ,IsEventUpdate ,IsCommentUpdate ,ActivitiesEvent ,PublicComments ,PrivateComments)
		Select @ORDER_ID, @ReturnCode, @ReturnText ,@UserName ,@ShippingStatus_EVENT_ID ,@ShippingStatus_Name ,@IsEventUpdate ,@IsCommentUpdate ,@ActivitiesEvent ,@PublicComments ,@PrivateComments
	end

end

select * from @ReturnTable

END

GO
