USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Assignment_By_GUID_IU]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ===============================================================
 Declare @Ret_ReturnCode bit = 0 Declare @Ret_ReturnText nvarchar(250) = '' 
 exec [dbo].[P_Assignment_By_GUID_IU] '',10100168,0,0,0,'ABDULLAH.ARSHAD','METRO-USER',null,13,147100,@ReturnCode=@Ret_ReturnCode out,@ReturnText=@Ret_ReturnText out select @Ret_ReturnCode,@Ret_ReturnText 
=============================================================== */

CREATE PROCEDURE [dbo].[P_Assignment_By_GUID_IU]
(
	 @ORDER_CODE_GUID nvarchar(36)
	,@ORDER_ID int
	
	,@pIsUpdateAssignToDeptOnly bit = 0
	,@pCurrentAssignToDept_MTV_CODE nvarchar(20)
	,@pAssignTo nvarchar(150)
	,@pStatus_MTV_ID int
	,@pFollowUpDateTime datetime
	,@pComment nvarchar(1000)
	,@pIsPublicComment bit = 0
	
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
set @pComment = isnull(@pComment,'')
set @pIsPublicComment = isnull(@pIsPublicComment,0)

set @ORDER_ID = isnull(@ORDER_ID,0)

if @ORDER_ID = 0
begin
	select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@ORDER_CODE_GUID,@GetRecordType_MTV_ID)
end

Declare @ReturnTable table
(
 ORDER_ID INT
,CurrentAssignToDept_MTV_CODE nvarchar(20)
,AssignTo nvarchar(150)
,AssignToDateTime datetime
,Status_MTV_ID int
,StatusDateTime datetime
,CompletedDateTime datetime
,FollowUpDateTime datetime
,FollowUPCount int
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

set @pIsUpdateAssignToDeptOnly = isnull(@pIsUpdateAssignToDeptOnly,0)
set @pCurrentAssignToDept_MTV_CODE = isnull(upper(@pCurrentAssignToDept_MTV_CODE),'')
set @pAssignTo = isnull(upper(@pAssignTo),'')
set @pIsPublicComment = isnull(@pIsPublicComment,0)

if @GetRecordType_MTV_ID in (147100,147101,147102)
	begin
		Declare @CurrentAssignToDeptName nvarchar(50) = null
		Declare @CurrentAssignTo nvarchar(150) = null
		Declare @AssignToDateTime datetime = null
		Declare @StatusName nvarchar(50) = null
		Declare @StatusDateTime datetime = null
		Declare @CompletedDateTime datetime = null
		Declare @FollowUPCount int = null
		
		Declare @OldCurrentAssignToDept_MTV_CODE nvarchar(20) = null
		Declare @OldCurrentAssignToDeptName nvarchar(50) = null
		Declare @OldCurrentAssignTo nvarchar(150) = null
		Declare @OldAssignTo nvarchar(150) = null
		Declare @OldAssignToDateTime datetime = null
		Declare @OldStatus_MTV_ID int = null
		Declare @OldStatusName nvarchar(50) = null
		Declare @OldStatusDateTime datetime = null
		Declare @OldCompletedDateTime datetime = null
		Declare @OldFollowUpDateTime datetime = null
		Declare @OldFollowUPCount int = null
		Declare @IsAssignToUserChanged bit = 0

		if (@pIsUpdateAssignToDeptOnly = 0)
		begin
			select @OldCurrentAssignToDept_MTV_CODE = od.CurrentAssignToDept_MTV_CODE
			,@OldCurrentAssignTo = (case 
				when od.CurrentAssignToDept_MTV_CODE = 'OED' then od.OEDAssignTo
				when od.CurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRAssignTo
				when od.CurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchAssignTo
				when od.CurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountAssignTo
				else null end)
			,@OldAssignTo = (case 
				when @pCurrentAssignToDept_MTV_CODE = 'OED' then od.OEDAssignTo
				when @pCurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRAssignTo
				when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchAssignTo
				when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountAssignTo
				else null end)
			,@OldAssignToDateTime = (case 
				when @pCurrentAssignToDept_MTV_CODE = 'OED' then od.OEDAssignToDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRAssignToDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchAssignToDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountAssignToDateTime
				else null end)
			,@OldStatus_MTV_ID = (case 
				when @pCurrentAssignToDept_MTV_CODE = 'OED' then od.OEDStatus_MTV_ID
				when @pCurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRStatus_MTV_ID
				when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchStatus_MTV_ID
				when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountStatus_MTV_ID
				else null end)
			,@OldStatusDateTime = (case 
				when @pCurrentAssignToDept_MTV_CODE = 'OED' then od.OEDStatusDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRStatusDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchStatusDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountStatusDateTime
				else null end)
			,@OldCompletedDateTime = (case 
				when @pCurrentAssignToDept_MTV_CODE = 'OED' then od.OEDCompletedDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRCompletedDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchCompletedDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountCompletedDateTime
				else null end)
			,@OldFollowUpDateTime = (case 
				when @pCurrentAssignToDept_MTV_CODE = 'OED' then od.OEDFollowUpDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRFollowUpDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchFollowUpDateTime
				when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountFollowUpDateTime
				else null end)
			,@OldFollowUPCount = (case 
				when @pCurrentAssignToDept_MTV_CODE = 'OED' then od.OEDFollowUPCount
				when @pCurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRFollowUPCount
				when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchFollowUPCount
				when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountFollowUPCount
				else null end)
			from [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) where od.ORDER_ID = @ORDER_ID

			set @IsAssignToUserChanged = (case when isnull(@pAssignTo,'') <> isnull(@OldAssignTo,'') then 1 else 0 end)
			set @AssignToDateTime = (case when @IsAssignToUserChanged = 1 then getutcdate() else @OldAssignToDateTime end)
			set @StatusDateTime = (case when @pStatus_MTV_ID <> @OldStatus_MTV_ID then getutcdate() else @OldStatusDateTime end)
			set @CompletedDateTime = (case when @pStatus_MTV_ID <> @OldStatus_MTV_ID then 
					(case
						when @pCurrentAssignToDept_MTV_CODE = 'OED' and @pStatus_MTV_ID = 140102 then getutcdate()
						when @pCurrentAssignToDept_MTV_CODE = 'CSR' and @pStatus_MTV_ID = 141103 then getutcdate()
						when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' and @pStatus_MTV_ID = 142102 then getutcdate()
						when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' and @pStatus_MTV_ID = 143103 then getutcdate()
					else null end)
				else @OldCompletedDateTime end)
			set @FollowUPCount = (case when @pFollowUpDateTime is not null and @OldFollowUpDateTime is null then 1
				when @pFollowUpDateTime > @OldFollowUpDateTime then @OldFollowUPCount + 1 else @OldFollowUPCount end)
			
			if (isnull(@OldCurrentAssignToDept_MTV_CODE,'') <> isnull(@pCurrentAssignToDept_MTV_CODE,'')
				or isnull(@OldAssignTo,'') <> isnull(@pAssignTo,'')
				or isnull(@OldAssignToDateTime,'') <> isnull(@AssignToDateTime,'')
				or isnull(@OldStatus_MTV_ID,'') <> isnull(@pStatus_MTV_ID,'')
				or isnull(@OldStatusDateTime,'') <> isnull(@StatusDateTime,'')
				or isnull(@OldCompletedDateTime,'') <> isnull(@CompletedDateTime,'')
				or isnull(@OldFollowUpDateTime,'') <> isnull(@pFollowUpDateTime,'')
				or isnull(@OldFollowUPCount,'') <> isnull(@FollowUPCount,''))
			begin

				update od
				set od.CurrentAssignToDept_MTV_CODE = @pCurrentAssignToDept_MTV_CODE
		
				,od.OEDAssignTo = (case when @pCurrentAssignToDept_MTV_CODE = 'OED' then @pAssignTo else od.OEDAssignTo end)
				,od.CSRAssignTo = (case when @pCurrentAssignToDept_MTV_CODE = 'CSR' then @pAssignTo else od.CSRAssignTo end)
				,od.DispatchAssignTo = (case when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then @pAssignTo else od.DispatchAssignTo end)
				,od.AccountAssignTo = (case when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then @pAssignTo else od.AccountAssignTo end)

				,od.OEDAssignToDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'OED' then @AssignToDateTime else od.OEDAssignToDateTime end)
				,od.CSRAssignToDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'CSR' then @AssignToDateTime else od.CSRAssignToDateTime end)
				,od.DispatchAssignToDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then @AssignToDateTime else od.DispatchAssignToDateTime end)
				,od.AccountAssignToDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then @AssignToDateTime else od.AccountAssignToDateTime end)

				,od.OEDStatus_MTV_ID = (case when @pCurrentAssignToDept_MTV_CODE = 'OED' then @pStatus_MTV_ID else od.OEDStatus_MTV_ID end)
				,od.CSRStatus_MTV_ID = (case when @pCurrentAssignToDept_MTV_CODE = 'CSR' then @pStatus_MTV_ID else od.CSRStatus_MTV_ID end)
				,od.DispatchStatus_MTV_ID = (case when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then @pStatus_MTV_ID else od.DispatchStatus_MTV_ID end)
				,od.AccountStatus_MTV_ID = (case when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then @pStatus_MTV_ID else od.AccountStatus_MTV_ID end)
		
				,od.OEDStatusDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'OED' then @StatusDateTime else od.OEDStatusDateTime end)
				,od.CSRStatusDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'CSR' then @StatusDateTime else od.CSRStatusDateTime end)
				,od.DispatchStatusDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then @StatusDateTime else od.DispatchStatusDateTime end)
				,od.AccountStatusDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then @StatusDateTime else od.AccountStatusDateTime end)
		
				,od.OEDCompletedDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'OED' then @CompletedDateTime else od.OEDCompletedDateTime end)
				,od.CSRCompletedDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'CSR' then @CompletedDateTime else od.CSRCompletedDateTime end)
				,od.DispatchCompletedDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then @CompletedDateTime else od.DispatchCompletedDateTime end)
				,od.AccountCompletedDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then @CompletedDateTime else od.AccountCompletedDateTime end)
		
				,od.OEDFollowUpDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'OED' then @pFollowUpDateTime else od.OEDFollowUpDateTime end)
				,od.CSRFollowUpDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'CSR' then @pFollowUpDateTime else od.CSRFollowUpDateTime end)
				,od.DispatchFollowUpDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then @pFollowUpDateTime else od.DispatchFollowUpDateTime end)
				,od.AccountFollowUpDateTime = (case when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then @pFollowUpDateTime else od.AccountFollowUpDateTime end)
		
				,od.OEDFollowUPCount = (case when @pCurrentAssignToDept_MTV_CODE = 'OED' then @FollowUPCount else od.OEDFollowUPCount end)
				,od.CSRFollowUPCount = (case when @pCurrentAssignToDept_MTV_CODE = 'CSR' then @FollowUPCount else od.CSRFollowUPCount end)
				,od.DispatchFollowUPCount = (case when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then @FollowUPCount else od.DispatchFollowUPCount end)
				,od.AccountFollowUPCount = (case when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then @FollowUPCount else od.AccountFollowUPCount end)

				,od.ModifiedBy = @UserName
				,od.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_Order_Detail] od where od.ORDER_ID = @ORDER_ID
		
				SET @ReturnCode = 1
				SET @ReturnText = 'Updated'

			end
			else
			begin
				set @ReturnText = 'No Change'
			end
		end
		else
		begin
			select @OldCurrentAssignToDept_MTV_CODE = od.CurrentAssignToDept_MTV_CODE
			,@OldCurrentAssignTo = (case 
				when od.CurrentAssignToDept_MTV_CODE = 'OED' then od.OEDAssignTo
				when od.CurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRAssignTo
				when od.CurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchAssignTo
				when od.CurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountAssignTo
				else null end)
			,@CurrentAssignTo = (case 
				when @pCurrentAssignToDept_MTV_CODE = 'OED' then od.OEDAssignTo
				when @pCurrentAssignToDept_MTV_CODE = 'CSR' then od.CSRAssignTo
				when @pCurrentAssignToDept_MTV_CODE = 'DISPATCH' then od.DispatchAssignTo
				when @pCurrentAssignToDept_MTV_CODE = 'ACCOUNT' then od.AccountAssignTo
				else null end)
			from [POMS_DB].[dbo].[T_Order_Detail] od with (nolock) where od.ORDER_ID = @ORDER_ID

			if (@OldCurrentAssignToDept_MTV_CODE <> @pCurrentAssignToDept_MTV_CODE)
			begin
				
				update od
				set od.CurrentAssignToDept_MTV_CODE = @pCurrentAssignToDept_MTV_CODE
				,od.ModifiedBy = @UserName
				,od.ModifiedOn = getutcdate()
				from [POMS_DB].[dbo].[T_Order_Detail] od where od.ORDER_ID = @ORDER_ID
				
				SET @ReturnCode = 1
				SET @ReturnText = 'Assign To Department Updated'

				if @pCurrentAssignToDept_MTV_CODE <> @OldCurrentAssignToDept_MTV_CODE
				begin
					exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = ''
					, @pNewValueHidden = '' ,@pOldValue = @OldCurrentAssignToDept_MTV_CODE, @pNewValue = @pCurrentAssignToDept_MTV_CODE, @pColumn_Name = 'CurrentAssignToDept_MTV_CODE', @pTable_Name = 'T_Order_Detail', @pReason = ''
					, @pSource_MTV_ID = 0, @pChangedBy = @UserName, @pIsAuto = 0, @pTriggerDebugInfo = 'P_Assignment_By_GUID_IU'
				end
				if @CurrentAssignTo <> @OldCurrentAssignTo
				begin
					exec [POMS_DB].[dbo].[P_Add_Order_Change_Log] @pORDER_ID = @ORDER_ID ,@pAuditType_MTV_ID = 108100, @pRefNo1 = '', @pRefNo2 = '', @pRefNo3 = '', @pOldValueHidden = ''
					, @pNewValueHidden = '' ,@pOldValue = @OldCurrentAssignTo, @pNewValue = @CurrentAssignTo, @pColumn_Name = 'CurrentAssignTo', @pTable_Name = 'T_Order_Detail', @pReason = ''
					, @pSource_MTV_ID = 0, @pChangedBy = @UserName, @pIsAuto = 1, @pTriggerDebugInfo = 'P_Assignment_By_GUID_IU'
				end
			end
			else
			begin
				set @ReturnText = 'No Change'
			end
		end

		if @pComment <> '' and @ReturnCode = 1
		begin
			Declare @Ret_AddRowCount int = 0
			Declare @Ret_EditRowCount int = 0
			Declare @Ret_DeleteRowCount int = 0
			Declare @Ret_Return_Code bit = 0
			Declare @Ret_Return_Text nvarchar(1000) = ''
			Declare @Ret_Execution_Error nvarchar(1000) = ''
			Declare @Ret_Error_Text nvarchar(max) = ''

			exec [POMS_DB].[dbo].[P_Order_Comments_IU] @pJson = '' ,@pOrder_ID = @ORDER_ID ,@pOC_ID = 0 ,@pComment = @pComment ,@pIsPublic = @pIsPublicComment ,@pUserName = @UserName 
			,@pIsCall = 0 ,@pIsActive = 1 ,@pImportanceLevel_MTV_ID = null ,@pAddRowCount = @Ret_AddRowCount out ,@pEditRowCount = @Ret_EditRowCount out ,@pDeleteRowCount = @Ret_DeleteRowCount out 
			,@pReturn_Code = @Ret_Return_Code out ,@pReturn_Text = @Ret_Return_Text out ,@pExecution_Error = @Ret_Execution_Error out ,@pError_Text = @Ret_Error_Text out ,@pIsBeginTransaction = 0	,@pSource_MTV_ID = @Source_MTV_ID

			if @Ret_Return_Code = 0
			begin
				set @ReturnText = @ReturnText + ' but comment not added'
			end

		end

	end

END
GO
