USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Events_Insert]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Events_Insert]
	@ppJson nvarchar(max)
	,@ppSource_MTV_ID int
	,@ppTriggerDebugInfo nvarchar(4000) = null
	,@ppUserName nvarchar(150)
	,@ppReturn_Code bit output
	,@ppReturn_Text nvarchar(1000) output
	,@ppExecution_Error nvarchar(1000) output
	,@ppError_Text nvarchar(max) output
	,@ppIsBeginTransaction bit = 1
AS
BEGIN
	SET NOCOUNT ON;
	set @ppUserName = upper(@ppUserName)

	set @ppReturn_Code = 0
	set @ppReturn_Text = ''
	set @ppExecution_Error = ''
	set @ppError_Text = ''
	
	Declare @TempReturn_Code bit = 1
	Declare @TempReturn_Text nvarchar(1000) = ''
	Declare @TempExecution_Error nvarchar(1000) = ''
	Declare @TempError_Text nvarchar(max) = ''

	Begin Try
		Create table #JsonOrdersEventsTable
		(ID int identity(1,1)
		,EVENT_ID int
		,ORDER_ID int
		,SELLER_CODE nvarchar(20)
		,TriggerDate datetime
		,IsActive bit
		,IsAuto bit
		,HUB_CODE nvarchar(20))

		Declare @EVENT_ID int
		Declare @ORDER_ID int
		Declare @SELLER_CODE nvarchar(20)
		Declare @TriggerDate datetime
		Declare @IsActive bit
		Declare @IsAuto bit
		Declare @HUB_CODE nvarchar(20)

		insert into #JsonOrdersEventsTable (EVENT_ID ,ORDER_ID ,SELLER_CODE ,TriggerDate ,IsActive ,IsAuto ,HUB_CODE)
		select EVENT_ID,ORDER_ID,SELLER_CODE,TriggerDate,IsActive,IsAuto,HUB_CODE from [POMS_DB].[dbo].[F_Get_Order_JsonEventsTable] (@ppJson) order by ID
		
		if @ppIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if exists(select EVENT_ID from #JsonOrdersEventsTable)
		begin

			Declare @MaxRows int = 0
			Declare @CurrentRow int = 0

			select @MaxRows = max(ID) from #JsonOrdersEventsTable
			set @MaxRows = isnull(@MaxRows,0)
			set @CurrentRow=1
			if (@MaxRows > 0)
			begin
				while (@CurrentRow <= @MaxRows)
				begin
					select @EVENT_ID = EVENT_ID ,@ORDER_ID = ORDER_ID ,@SELLER_CODE = SELLER_CODE ,@TriggerDate = TriggerDate ,@IsActive = [IsActive] ,@IsAuto = [IsAuto] ,@HUB_CODE = [HUB_CODE] from #JsonOrdersEventsTable where ID = @CurrentRow
					
					if (@ppReturn_Text = '' and @ppExecution_Error = '' and @ppError_Text = '')
					begin
						select @TempReturn_Code = 1 ,@TempReturn_Text = '' ,@TempExecution_Error = '' ,@TempError_Text = ''

						exec [POMS_DB].[dbo].[P_Process_Order_Event_IU] @pppEVENT_ID = @EVENT_ID ,@pppORDER_ID = @ORDER_ID ,@pppSELLER_CODE = @SELLER_CODE ,@pppTriggerDate = @TriggerDate ,@pppIsActive = @IsActive 
						,@pppIsAuto = @IsAuto ,@pppHUB_CODE = @HUB_CODE ,@pppSource_MTV_ID = @ppSource_MTV_ID ,@pppTriggerDebugInfo = @ppTriggerDebugInfo ,@pppUserName = @ppUserName ,@pppReturn_Code = @ppReturn_Code out 
						,@pppReturn_Text = @ppReturn_Text out ,@pppExecution_Error = @ppExecution_Error out ,@pppError_Text = @ppError_Text out ,@pppIsBeginTransaction = @ppIsBeginTransaction 

						select @ppReturn_Text = @ppReturn_Text + (case when @ppReturn_Text <> '' then '; ' else '' end) + @TempReturn_Text
						, @ppExecution_Error = @ppExecution_Error + (case when @ppExecution_Error <> '' then '; ' else '' end) + @TempExecution_Error
						, @ppError_Text = @ppError_Text + (case when @ppError_Text <> '' then '; ' else '' end) + @TempError_Text
				end
				end
			end

			--DECLARE db_cursor_jsoneventstrigger CURSOR FOR  
			--select EVENT_ID ,ORDER_ID ,SELLER_CODE ,TriggerDate ,[IsActive] ,[IsAuto] ,[HUB_CODE] from #JsonOrdersEventsTable order by ID
			
			--OPEN db_cursor_jsoneventstrigger   
			--FETCH NEXT FROM db_cursor_jsoneventstrigger INTO @EVENT_ID ,@ORDER_ID ,@SELLER_CODE ,@TriggerDate ,@IsActive ,@IsAuto ,@HUB_CODE

			--WHILE @@FETCH_STATUS = 0   
			--BEGIN
				
			--	if (@ppReturn_Text = '' and @ppExecution_Error = '' and @ppError_Text = '')
			--	begin
			--		select @TempReturn_Code = 1 ,@TempReturn_Text = '' ,@TempExecution_Error = '' ,@TempError_Text = ''

			--		exec [POMS_DB].[dbo].[P_Process_Order_Event_IU] @pppEVENT_ID = @EVENT_ID ,@pppORDER_ID = @ORDER_ID ,@pppSELLER_CODE = @SELLER_CODE ,@pppTriggerDate = @TriggerDate ,@pppIsActive = @IsActive 
			--		,@pppIsAuto = @IsAuto ,@pppHUB_CODE = @HUB_CODE ,@pppSource_MTV_ID = @ppSource_MTV_ID ,@pppTriggerDebugInfo = @ppTriggerDebugInfo ,@pppUserName = @ppUserName ,@pppReturn_Code = @ppReturn_Code out 
			--		,@pppReturn_Text = @ppReturn_Text out ,@pppExecution_Error = @ppExecution_Error out ,@pppError_Text = @ppError_Text out ,@pppIsBeginTransaction = @ppIsBeginTransaction 

			--		select @ppReturn_Text = @ppReturn_Text + (case when @ppReturn_Text <> '' then '; ' else '' end) + @TempReturn_Text
			--		, @ppExecution_Error = @ppExecution_Error + (case when @ppExecution_Error <> '' then '; ' else '' end) + @TempExecution_Error
			--		, @ppError_Text = @ppError_Text + (case when @ppError_Text <> '' then '; ' else '' end) + @TempError_Text
			--	end

			--	FETCH NEXT FROM db_cursor_jsoneventstrigger INTO @EVENT_ID ,@ORDER_ID ,@SELLER_CODE ,@TriggerDate ,@IsActive ,@IsAuto ,@HUB_CODE
			--END   

			--CLOSE db_cursor_jsoneventstrigger   
			--DEALLOCATE db_cursor_jsoneventstrigger

		end

		if @ppExecution_Error = '' and @ppReturn_Text = '' and @ppError_Text = ''
		begin
			set @ppReturn_Code = 1
		end

		if @ppIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @ppReturn_Code = 1
		begin
			COMMIT; 
		end
		else if @ppIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @ppReturn_Code = 0
		begin
			ROLLBACK; 
		end

	End Try
	Begin catch
		if @ppIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @ppError_Text = 'P_Order_Events_Insert: ' + ERROR_MESSAGE()
	End catch

END
GO
