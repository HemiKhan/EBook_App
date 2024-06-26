USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Comments_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Comments_IU]
	@pJson nvarchar(max)
	,@pOrder_ID int
	,@pOC_ID int
	,@pComment nvarchar(max)
	,@pIsPublic bit
	,@pUserName nvarchar(150)
	,@pIsCall bit
	,@pIsActive bit = 1
	,@pImportanceLevel_MTV_ID int = null
	,@pAddRowCount int output
	,@pEditRowCount int output
	,@pDeleteRowCount int output
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(1000) output
	,@pError_Text nvarchar(max) output
	,@pIsBeginTransaction bit = 1 
	,@pSource_MTV_ID int = 101100
AS
BEGIN
	SET NOCOUNT ON;
	Declare @ShippingStatus_EVENT_ID int = 0
	Declare @OrderStatus_MTV_ID int = 10000

	set @pUserName = upper(@pUserName)
	set @pComment = isnull(@pComment,'')

	set @pAddRowCount = 0
	set @pEditRowCount = 0
	set @pDeleteRowCount = 0
	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	if len(@pComment) > 1000
	begin
		set @pReturn_Text = 'Comment Length cannot be more than 1000 Characters'
		return
	end

	Begin Try
		select @ShippingStatus_EVENT_ID = ShippingStatus_EVENT_ID ,@OrderStatus_MTV_ID = OrderStatus_MTV_ID from [POMS_DB].[dbo].[T_Order] with (nolock) where ORDER_ID = @pOrder_ID
		select @ShippingStatus_EVENT_ID = isnull(@ShippingStatus_EVENT_ID,0) ,@OrderStatus_MTV_ID = isnull(@OrderStatus_MTV_ID,10000)

		if @pIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if @pComment <> '' and @pOC_ID = 0
		begin
			insert into [POMS_DB].[dbo].[T_Order_Comments] ([ORDER_ID] ,[ShippingStatus_EVENT_ID] ,[OrderStatus_MTV_ID] ,[Comment] ,[IsPublic] ,[CreatedBy] ,[IsCall], [IsActive], ImportanceLevel_MTV_ID)
			select @pOrder_ID  , @ShippingStatus_EVENT_ID, @OrderStatus_MTV_ID, @pComment, @pIsPublic, @pUserName, @pIsCall, @pIsActive, @pImportanceLevel_MTV_ID 
	
			set @pAddRowCount = @@ROWCOUNT
			if (@pAddRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Comment was not Inserted'
			end
		end

		if @pOC_ID > 0 and @pIsActive = 1 and @pExecution_Error = ''
		begin
			drop table if exists #JsonOldEditCommentTable 
			select oc.ORDER_ID, oc.OC_ID ,oc.[Comment]
			,[IsPublic] = cast(oc.[IsPublic] as nvarchar(10))
			,[IsCall] = cast(oc.[IsCall] as nvarchar(10))
			,[IsActive] = cast(oc.[IsActive] as nvarchar(10))
			,[IsPublic_Name] = (case when oc.[IsPublic] = 1 then 'Yes' else 'No' end)
			,[IsCall_Name] = (case when oc.[IsCall] = 1 then 'Yes' else 'No' end)
			,[IsActive_Name] = (case when oc.[IsActive] = 1 then 'Yes' else 'No' end)
			,ImportanceLevel_MTV_ID = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (oc.ImportanceLevel_MTV_ID)
			,ImportanceLevel_MTV_ID_Name = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 110 and MTV_ID = oc.ImportanceLevel_MTV_ID),'')
			into #JsonOldEditCommentTable 
			from [POMS_DB].[dbo].[T_Order_Comments] oc with (nolock) where oc.[ORDER_ID] = @pOrder_ID and oc.OC_ID = @pOC_ID

			update oc
			set oc.[Comment] = @pComment
			,oc.[IsPublic] = @pIsPublic
			,oc.[IsCall] = @pIsCall
			,oc.[IsActive] = @pIsActive
			,oc.ImportanceLevel_MTV_ID = @pImportanceLevel_MTV_ID
			,oc.ModifiedBy = @pUserName
			,oc.ModifiedOn = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Comments] oc where oc.[ORDER_ID] = @pOrder_ID and oc.OC_ID = @pOC_ID
	
			set @pEditRowCount = @@ROWCOUNT
			if (@pEditRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Comment was not Updated'
			end

			drop table if exists #JsonNewEditCommentTable 
			select ORDER_ID = @pOrder_ID, OC_ID = @pOC_ID ,[Comment] = @pComment
			,[IsPublic] = cast(@pIsPublic as nvarchar(10))
			,[IsCall] = cast(@pIsCall as nvarchar(10))
			,[IsActive] = cast(@pIsActive as nvarchar(10))
			,[IsPublic_Name] = (case when @pIsPublic = 1 then 'Yes' else 'No' end)
			,[IsCall_Name] = (case when @pIsCall = 1 then 'Yes' else 'No' end)
			,[IsActive_Name] = (case when @pIsActive = 1 then 'Yes' else 'No' end)
			,ImportanceLevel_MTV_ID = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (@pImportanceLevel_MTV_ID)
			,ImportanceLevel_MTV_ID_Name = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 110 and MTV_ID = @pImportanceLevel_MTV_ID),'')
			into #JsonNewEditCommentTable 
			
			exec [POMS_DB].[dbo].[P_Order_Comments_IU_ChangeLog] @plogIsEdit = 1 ,@plogIsDelete = 0 ,@plogUserName = @pUserName ,@plogSource_MTV_ID = @pSource_MTV_ID
		end
		else if @pOC_ID > 0 and @pIsActive = 0 and @pExecution_Error = ''
		begin
			drop table if exists #JsonOldDeleteCommentTable 
			select oc.ORDER_ID, oc.OC_ID ,oc.[Comment]
			,[IsActive] = cast(oc.[IsActive] as nvarchar(10))
			,[IsActive_Name] = (case when oc.[IsActive] = 1 then 'Yes' else 'No' end)
			into #JsonOldDeleteCommentTable 
			from [POMS_DB].[dbo].[T_Order_Comments] oc with (nolock) where oc.[ORDER_ID] = @pOrder_ID and oc.OC_ID = @pOC_ID
			
			update oc
			set oc.[IsActive] = @pIsActive
			,oc.ModifiedBy = @pUserName
			,oc.ModifiedOn = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Comments] oc where oc.[ORDER_ID] = @pOrder_ID and oc.OC_ID = @pOC_ID
	
			set @pDeleteRowCount = @@ROWCOUNT
			if (@pDeleteRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Comment was not Deleted'
			end

			drop table if exists #JsonNewDeleteCommentTable 
			select ORDER_ID = @pOrder_ID, OC_ID = @pOC_ID ,[Comment] = 'Deleted'
			,[IsActive] = cast(@pIsActive as nvarchar(10))
			,[IsActive_Name] = (case when @pIsActive = 1 then 'Yes' else 'No' end)
			into #JsonNewDeleteCommentTable 
			
			exec [POMS_DB].[dbo].[P_Order_Comments_IU_ChangeLog] @plogIsEdit = 0 ,@plogIsDelete = 1 ,@plogUserName = @pUserName ,@plogSource_MTV_ID = @pSource_MTV_ID
		end

		if @pExecution_Error = '' and @pReturn_Text = '' and @pError_Text = ''
		begin
			set @pReturn_Code = 1
		end

		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 1
		begin
			COMMIT; 
		end
		else if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 0
		begin
			ROLLBACK; 
		end

	End Try
	Begin catch
		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @pError_Text = 'P_Order_Comments_IU: ' + ERROR_MESSAGE()
	End catch

END
GO
