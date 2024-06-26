USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Client_Identifier_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Client_Identifier_IU]
	@pJson nvarchar(max)
	,@pOrder_ID int
	,@pUserName nvarchar(150)
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
	set @pUserName = upper(@pUserName)

	set @pAddRowCount = 0
	set @pEditRowCount = 0
	set @pDeleteRowCount = 0
	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	Begin Try
	
		drop table if exists #JsonClientIdentifierTable
		select OIF_CODE,Value_ into #JsonClientIdentifierTable
		from [POMS_DB].[dbo].[F_Get_Order_JsonClientIdentifierTable] (@pJson)
	
		if @pIsBeginTransaction = 1
		begin	
			Begin Transaction
		end

		if exists(select OIF_CODE from #JsonClientIdentifierTable where Value_ <> '' and OIF_CODE not in (select OIF_CODE from [POMS_DB].[dbo].[T_Order_Client_Identifier] with (nolock) where ORDER_ID = @pOrder_ID))
		begin
			insert into [POMS_DB].[dbo].[T_Order_Client_Identifier] ([ORDER_ID] ,[OIF_CODE] ,[Value_] ,[AddedBy])
			select @pOrder_ID as Order_ID, OIF_CODE, Value_ ,@pUserName from #JsonClientIdentifierTable
			where Value_ <> '' and OIF_CODE not in (select OIF_CODE from [POMS_DB].[dbo].[T_Order_Client_Identifier] with (nolock) where ORDER_ID = @pOrder_ID)
	
			set @pAddRowCount = @@ROWCOUNT
			if (@pAddRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Client Identifier was not Insert'
			end
		end

		if exists(select OIF_CODE from #JsonClientIdentifierTable where Value_ <> '' and OIF_CODE in (select OIF_CODE from [POMS_DB].[dbo].[T_Order_Client_Identifier] with (nolock) where ORDER_ID = @pOrder_ID)) and @pExecution_Error = ''
		begin
			drop table if exists #JsonOldEditClientIdentifierTable 
			select oci.ORDER_ID, oci.OIF_CODE ,Value_ = oci.Value_
			into #JsonOldEditClientIdentifierTable 
			from [POMS_DB].[dbo].[T_Order_Client_Identifier] oci
			inner join #JsonClientIdentifierTable joci on oci.OIF_CODE = joci.OIF_CODE
			where oci.ORDER_ID = @pOrder_ID and joci.Value_ <> ''
	
			update oci
			set oci.Value_ = joci.Value_ 
			, ModifiedBy = @pUserName
			, ModifiedOn = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Client_Identifier] oci
			inner join #JsonClientIdentifierTable joci on oci.OIF_CODE = joci.OIF_CODE
			where oci.ORDER_ID = @pOrder_ID and joci.Value_ <> ''
	
			set @pEditRowCount = @@ROWCOUNT
			if (@pEditRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Client Identifier was not Updated'
			end

			drop table if exists #JsonNewEditClientIdentifierTable 
			select ORDER_ID = @pOrder_ID, joci.OIF_CODE ,Value_ = joci.Value_
			into #JsonNewEditClientIdentifierTable 
			from #JsonClientIdentifierTable joci where joci.Value_ <> ''
			
			exec [POMS_DB].[dbo].[P_Order_Client_Identifier_IU_ChangeLog] @plogIsEdit = 1 ,@plogIsDelete = 0 ,@plogUserName = @pUserName ,@plogSource_MTV_ID = @pSource_MTV_ID
		end

		if exists(select OIF_CODE from #JsonClientIdentifierTable where Value_ = '' and OIF_CODE in (select OIF_CODE from [POMS_DB].[dbo].[T_Order_Client_Identifier] with (nolock) where ORDER_ID = @pOrder_ID)) and @pExecution_Error = ''
		begin
			drop table if exists #JsonOldDeleteClientIdentifierTable 
			select oci.ORDER_ID, oci.OIF_CODE ,Value_ = oci.Value_
			into #JsonOldDeleteClientIdentifierTable 
			from [POMS_DB].[dbo].[T_Order_Client_Identifier] oci with (nolock)
			inner join #JsonClientIdentifierTable joci on oci.OIF_CODE = joci.OIF_CODE
			where oci.ORDER_ID = @pOrder_ID and joci.Value_ = ''
	
			Delete from [POMS_DB].[dbo].[T_Order_Client_Identifier] where ORDER_ID = @pOrder_ID and OIF_CODE in (select OIF_CODE from #JsonClientIdentifierTable where Value_ = '')
	
			set @pDeleteRowCount = @@ROWCOUNT
			if (@pDeleteRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error  + (case when @pExecution_Error <> '' then '; ' else '' end) + 'Order Client Identifier was not Deleted'
			end

			drop table if exists #JsonNewDeleteClientIdentifierTable 
			select oci.ORDER_ID, oci.OIF_CODE ,Value_ = 'Deleted'
			into #JsonNewDeleteClientIdentifierTable 
			from #JsonOldDeleteClientIdentifierTable oci
			inner join #JsonClientIdentifierTable joci on oci.OIF_CODE = joci.OIF_CODE
			where oci.ORDER_ID = @pOrder_ID and joci.Value_ = ''
			
			exec [POMS_DB].[dbo].[P_Order_Client_Identifier_IU_ChangeLog] @plogIsEdit = 0 ,@plogIsDelete = 1 ,@plogUserName = @pUserName ,@plogSource_MTV_ID = @pSource_MTV_ID
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
		Set @pError_Text = 'P_Order_Client_Identifier_IU: ' + ERROR_MESSAGE()
	End catch

END
GO
