USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Add_Change_Log_From_JsonChangeLog_Table]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[P_Add_Change_Log_From_JsonChangeLog_Table]
	
AS
BEGIN
	SET NOCOUNT ON;

	begin try

		insert into [dbo].[T_Audit_History] ([AC_ID] ,[REF_NO] ,[AuditType_MTV_ID] ,[RefNo1] ,[RefNo2] ,[RefNo3]
		,[OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] ,[Reason] ,[IsAuto] ,[Source_MTV_ID] ,[TriggerDebugInfo] ,[ChangedBy])
		select [AC_ID] ,[REF_NO] ,[AuditType_MTV_ID] ,[RefNo1] ,[RefNo2] ,[RefNo3] ,[OldValueHidden] ,[NewValueHidden] 
		,[OldValue] ,[NewValue] ,[Reason] ,[IsAuto] ,[Source_MTV_ID] ,[TriggerDebugInfo] ,[ChangedBy] 
		from #JsonChangeLog where AC_ID > 0 and [OldValue] <> [NewValue] order by ID

		begin try

			if exists(select AC_ID from #JsonChangeLog where AC_ID = 0 and [OldValue] <> [NewValue])
			begin
				Declare @ColumnList table
				(ID [int] IDENTITY(1,1) NOT NULL
				,ColumnName nvarchar(100)
				,TableName nvarchar(150)
				,TriggerDebugInfo nvarchar(1000))
				insert into @ColumnList (ColumnName ,TableName ,TriggerDebugInfo)
				select Distinct [Column_Name] ,[Table_Name] ,[TriggerDebugInfo] 
				from #JsonChangeLog where AC_ID = 0 and [OldValue] <> [NewValue]

				Declare @ColumnName nvarchar(100) = ''
				Declare @TableName nvarchar(150) = ''
				Declare @TriggerDebugInfo nvarchar(1000) = ''
				Declare @Body nvarchar(max) = ''

				Declare @MaxRows int = 0
				Declare @CurrentRow int = 0

				select @MaxRows = max(ID) from @ColumnList
				set @MaxRows = isnull(@MaxRows,0)
				set @CurrentRow=1
				set @Body = 'Please see below missing column list in Audit Column Table. <br><tr><td>ColumnName</td><td>TableName</td><td>TriggerDebugInfo</td></tr>'
				if (@MaxRows > 0 and @MaxRows < 9999)
				begin
					while (@CurrentRow <= @MaxRows)
					begin
						SELECT @ColumnName = ColumnName ,@TableName = TableName ,@TriggerDebugInfo = TriggerDebugInfo FROM @ColumnList where ID = @CurrentRow
						select @ColumnName = isnull(@ColumnName,'') ,@TableName = isnull(@TableName,'') ,@TriggerDebugInfo = isnull(@TriggerDebugInfo,'')
						set @Body = @Body + '<tr><td>' + @ColumnName + '</td><td>' + @TableName + '</td><td>' + @TriggerDebugInfo + '</td></tr>'
						set @CurrentRow = @CurrentRow + 1
					end
				end

				--DECLARE db_cursor_changelog_missingcol CURSOR FOR  
				--SELECT ColumnName,TableName,TriggerDebugInfo FROM @ColumnList 

				--OPEN db_cursor_changelog_missingcol
				--FETCH NEXT FROM db_cursor_changelog_missingcol INTO @ColumnName,@TableName,@TriggerDebugInfo

				--set @Body = 'Please see below missing column list in Audit Column Table. <br><tr><td>ColumnName</td><td>TableName</td><td>TriggerDebugInfo</td></tr>'

				--WHILE @@FETCH_STATUS = 0   
				--BEGIN   
			
				--	set @Body = @Body + '<tr><td>' + @ColumnName + '</td><td>' + @TableName + '</td><td>' + @TriggerDebugInfo + '</td></tr>'

				--	FETCH NEXT FROM db_cursor_changelog_missingcol INTO @ColumnName,@TableName,@TriggerDebugInfo
				--END   

				--CLOSE db_cursor_changelog_missingcol
				--DEALLOCATE db_cursor_changelog_missingcol

				exec [dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 1,@Email_Subject = 'Change Missing Column Alert',@Email_Body = @Body ,@Is_Error = 1,@Is_HTML = 1
				,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
			end

		end try
		begin catch


		end catch

	end try
	begin catch
		exec [dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 1,@Email_Subject = 'Add Audit History Table Error',@Email_Body = 'P_Add_Change_Log_From_JsonChangeLog_Table Add Audit History Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	end catch
END
GO
