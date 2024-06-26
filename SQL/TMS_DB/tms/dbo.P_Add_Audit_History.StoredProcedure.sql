USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Add_Audit_History]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================================================
-- Author		: abdullah
-- Create date	: 
-- Description	: To Insert Table Columns in Table 
-- =====================================================================================================================

create PROCEDURE [dbo].[P_Add_Audit_History]
(
	@ColumnName nvarchar(100),
	@TableName nvarchar(100),
	@REF_NO nvarchar(150),
	@AuditType_MTV_ID int,
	@RefNo1 nvarchar(50),
	@RefNo2 nvarchar(50),
	@RefNo3 nvarchar(50),
	@OldValueHidden nvarchar(2000),
	@NewValueHidden nvarchar(2000),
	@OldValue nvarchar(2000),
	@NewValue nvarchar(2000),
	@Reason nvarchar(1000),
	@IsAuto bit,
	@Source_MTV_ID int,
	@ChangedBy nvarchar(150),
	@TriggerDebugInfo nvarchar(max) = null
)

AS

BEGIN  

if (@NewValue = @OldValue)
begin
	return
end

set nocount on;

begin try

	declare @AC_ID int = 0
	
	select @AC_ID = [dbo].[F_Get_AC_ID] (@ColumnName,@TableName)

	if (@AC_ID > 0)
	begin
		insert into [T_Audit_History] (AC_ID, REF_NO, AuditType_MTV_ID, RefNo1, RefNo2, RefNo3, OldValueHidden, NewValueHidden, OldValue, NewValue, Reason, IsAuto, Source_MTV_ID, TriggerDebugInfo, ChangedBy)
		values (@AC_ID, @REF_NO, @AuditType_MTV_ID, @RefNo1, @RefNo2, @RefNo3, @OldValueHidden, @NewValueHidden, @OldValue, @NewValue, @Reason, @IsAuto, @Source_MTV_ID, @TriggerDebugInfo, @ChangedBy)
	end
	else
	begin
		raiserror ('P_Add_Audit_History: %d: %s', 16, 1, 547, 'Column Does Not Exists In Audit Column Table');
	end

	--if (@trancount = 0)
	--	commit;
end try 
begin catch
	declare @error int, @message varchar(4000), @xstate int;
	select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
	
	raiserror ('usp_my_procedure_name: %d: %s', 16, 1, @error, @message) ;
end catch

END

GO
