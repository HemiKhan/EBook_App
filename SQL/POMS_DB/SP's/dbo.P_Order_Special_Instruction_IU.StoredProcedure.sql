USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Special_Instruction_IU]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Special_Instruction_IU]
	@pJson nvarchar(max)
	,@pOrder_ID int
	,@pOSI_ID int
	,@pInstructionType_MTV_ID int
	,@pInstruction nvarchar(max)
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
	set @pInstruction = isnull(@pInstruction,'')

	set @pAddRowCount = 0
	set @pEditRowCount = 0
	set @pDeleteRowCount = 0
	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''
	Declare @TypeName nvarchar(50) = ''

	Begin Try
	
	set @TypeName = (case when @pInstructionType_MTV_ID = 124100 then 'Pickup Driver ' when @pInstructionType_MTV_ID = 124101 then 'Delivery Driver ' else '' end)
	
	if len(@pInstruction) > 1000
	begin
		set @pReturn_Text = @TypeName + 'Instruction Lenght cannot be more than 1000 Characters'
		return
	end

		if @pIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if @pInstruction <> '' and @pOSI_ID = 0
		begin
			insert into [POMS_DB].[dbo].[T_Order_Special_Instruction] ([ORDER_ID] ,[InstructionType_MTV_ID] ,[Instruction] ,[CreatedBy])
			select @pOrder_ID  , @pInstructionType_MTV_ID, @pInstruction, @pUserName
	
			set @pAddRowCount = @@ROWCOUNT
			if (@pAddRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TypeName + 'Instruction was not Inserted'
			end
		end

		if @pInstruction <> '' and @pOSI_ID > 0 and @pExecution_Error = ''
		begin
			drop table if exists #JsonOldEditSpecialInstructionTable 
			select osi.ORDER_ID, osi.OSI_ID ,osi.[Instruction]
			,[InstructionType_MTV_ID] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (osi.[InstructionType_MTV_ID])
			,InstructionType_MTV_ID_Name = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 124 and MTV_ID = osi.[InstructionType_MTV_ID]),'')
			into #JsonOldEditSpecialInstructionTable  
			from [POMS_DB].[dbo].[T_Order_Special_Instruction] osi with (nolock) where osi.[ORDER_ID] = @pOrder_ID and osi.OSI_ID = @pOSI_ID

			update osi
			set osi.[Instruction] = @pInstruction
			,osi.ModifiedBy = @pUserName
			,osi.ModifiedOn = getutcdate()
			from [POMS_DB].[dbo].[T_Order_Special_Instruction] osi where osi.[ORDER_ID] = @pOrder_ID and osi.OSI_ID = @pOSI_ID
	
			set @pEditRowCount = @@ROWCOUNT
			if (@pEditRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TypeName + 'Instruction was not Updated'
			end

			drop table if exists #JsonNewEditSpecialInstructionTable 
			select ORDER_ID = @pOrder_ID, OSI_ID = @pOSI_ID ,[Instruction] = @pInstruction
			,[InstructionType_MTV_ID] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (@pInstructionType_MTV_ID)
			,InstructionType_MTV_ID_Name = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 124 and MTV_ID = @pInstructionType_MTV_ID),'')
			into #JsonNewEditSpecialInstructionTable  

			exec [POMS_DB].[dbo].[P_Order_Special_Instruction_IU_ChangeLog] @plogIsEdit = 1 ,@plogIsDelete = 0 ,@plogUserName = @pUserName ,@plogSource_MTV_ID = @pSource_MTV_ID
		end
		else if @pInstruction = '' and @pOSI_ID > 0 and @pExecution_Error = ''
		begin
			drop table if exists #JsonOldDeleteSpecialInstructionTable 
			select osi.ORDER_ID, osi.OSI_ID ,osi.[Instruction]
			,[InstructionType_MTV_ID] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (osi.[InstructionType_MTV_ID])
			,InstructionType_MTV_ID_Name = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 124 and MTV_ID = osi.[InstructionType_MTV_ID]),'')
			into #JsonOldDeleteSpecialInstructionTable  
			from [POMS_DB].[dbo].[T_Order_Special_Instruction] osi with (nolock) where osi.[ORDER_ID] = @pOrder_ID and osi.OSI_ID = @pOSI_ID

			delete from [POMS_DB].[dbo].[T_Order_Special_Instruction] where [ORDER_ID] = @pOrder_ID and OSI_ID = @pOSI_ID
	
			set @pDeleteRowCount = @@ROWCOUNT
			if (@pDeleteRowCount = 0)
			begin
				set @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TypeName + 'Instruction was not Deleted'
			end

			drop table if exists #JsonNewDeleteSpecialInstructionTable 
			select ORDER_ID = @pOrder_ID, OSI_ID = @pOSI_ID ,[Instruction] = 'Deleted'
			,[InstructionType_MTV_ID] = [POMS_DB].[dbo].[F_Get_Nvarchar_From_Numeric] (@pInstructionType_MTV_ID)
			,InstructionType_MTV_ID_Name = isnull((select top 1 [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 124 and MTV_ID = @pInstructionType_MTV_ID),'')
			into #JsonNewDeleteSpecialInstructionTable 

			exec [POMS_DB].[dbo].[P_Order_Special_Instruction_IU_ChangeLog] @plogIsEdit = 0 ,@plogIsDelete = 1 ,@plogUserName = @pUserName ,@plogSource_MTV_ID = @pSource_MTV_ID
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
		Set @pError_Text = 'P_Order_Special_Instruction_IU: ' + ERROR_MESSAGE()
	End catch

END
GO
