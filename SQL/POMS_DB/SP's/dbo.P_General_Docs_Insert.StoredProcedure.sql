USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_General_Docs_Insert]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_General_Docs_Insert]
	@ppJson nvarchar(max)
	--,@ppAttachmentType_MTV_ID int
	,@ppUserName nvarchar(150)
	,@ppAddRowCount int output
	,@ppReturn_Code bit output
	,@ppReturn_Text nvarchar(1000) output
	,@ppExecution_Error nvarchar(1000) output
	,@ppError_Text nvarchar(max) output
	,@ppIsBeginTransaction bit = 1
AS
BEGIN
	SET NOCOUNT ON;
	set @ppUserName = upper(@ppUserName)

	set @ppAddRowCount = 0
	set @ppReturn_Code = 0
	set @ppReturn_Text = ''
	set @ppExecution_Error = ''
	set @ppError_Text = ''
	
	Begin Try
		drop table if exists #JsonGeneralDocTable
		select distinct FileGUID,Path_,OriginalFileName,FileExt,Description_,IsPublic,AttachmentType_MTV_ID,RefNo,RefNo2,RefID,RefID2 into #JsonGeneralDocTable 
		from [POMS_DB].[dbo].[F_Get_General_JsonDocTable] (@ppJson)
		
		if @ppIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if exists(select FileGUID from #JsonGeneralDocTable)
		begin
			Declare @AttachmentType_MTV_ID bit = 0
			set @AttachmentType_MTV_ID = (select top 1 AttachmentType_MTV_ID from #JsonGeneralDocTable)

			insert into [POMS_DB].[dbo].[T_Docs] ([AttachmentType_MTV_ID] ,[OriginalFileName] ,[ImageName] ,[Description_] ,[Path_] ,[RefNo] ,[RefNo2] ,[RefID] ,[RefID2] ,[IsPublic] ,[AddedBy])
			select AttachmentType_MTV_ID, [OriginalFileName], [ImageName] = (FileGUID + '.' + FileExt), [Description_], [Path_], [RefNo], [RefNo2], [RefID], [RefID2], [IsPublic], @ppUserName as [AddedBy] 
			from #JsonGeneralDocTable order by RefNo
	
			set @ppAddRowCount = @@ROWCOUNT
			if (@ppAddRowCount = 0)
			begin
				set @ppExecution_Error = @ppExecution_Error + (case when @ppExecution_Error <> '' then '; ' else '' end) + (case when @AttachmentType_MTV_ID = 128100 then 'Order Docs' when @AttachmentType_MTV_ID = 128101 then 'OrderItem Docs' when @AttachmentType_MTV_ID = 128102 then 'OrderItemScan Docs' else 'Order Docs' end) + ' was not Insert'
			end
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
		Set @ppError_Text = 'P_General_Docs_Insert: ' + ERROR_MESSAGE()
	End catch

END
GO
