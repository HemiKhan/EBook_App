USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Client_Identifier_IU_ChangeLog]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Client_Identifier_IU_ChangeLog]
	@plogIsEdit bit 
	,@plogIsDelete bit 
	,@plogUserName nvarchar(150)
	,@plogSource_MTV_ID int
AS
BEGIN
	SET NOCOUNT ON;
	drop table if exists #JsonChangeLog
	Create Table #JsonChangeLog
	(ID [int] identity(1,1) NOT NULL
	,[AC_ID] [int] NOT NULL
	,[ORDER_ID] [int] NOT NULL
	,[AuditType_MTV_ID] [int] NOT NULL default 108105
	,[RefNo1] [nvarchar](50) NOT NULL
	,[RefNo2] [nvarchar](50) NOT NULL default ''
	,[RefNo3] [nvarchar](50) NOT NULL default ''
	,[OldValueHidden] [nvarchar](2000) NOT NULL
	,[NewValueHidden] [nvarchar](2000) NOT NULL
	,[OldValue] [nvarchar](2000) NOT NULL
	,[NewValue] [nvarchar](2000) NOT NULL
	,[Column_Name] [nvarchar](100) NOT NULL default ''
	,[Table_Name] [nvarchar](150) NOT NULL default ''
	,[Reason] [nvarchar](1000) NOT NULL default ''
	,[IsAuto] [bit] NOT NULL default 0
	,[Source_MTV_ID] [int] NOT NULL default 0
	,[TriggerDebugInfo] [nvarchar](4000) NULL
	,[ChangedBy] [nvarchar](150) NOT NULL)

	Begin Try
		if @plogIsEdit = 1
		begin
			insert into #JsonChangeLog ([AC_ID] ,[ORDER_ID] ,[RefNo1] ,[OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
			,[Column_Name] ,[Table_Name] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [ORDER_ID] , RefNo1 ,[OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Order_Client_Identifier' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_Order_Client_Identifier_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 0 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Value_','T_Order_Client_Identifier') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[OIF_CODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Value_] ,[NewValue]=new.[Value_] ,[Column_Name]='Value_'
				from #JsonOldEditClientIdentifierTable old inner join #JsonNewEditClientIdentifierTable new on old.OIF_CODE = new.OIF_CODE and old.ORDER_ID = new.ORDER_ID
				) ilv where ilv.[OldValue] <> ilv.[NewValue]
			order by ilv.RefNo1 ,ilv.ID
		end
		else if @plogIsDelete = 1
		begin

			insert into #JsonChangeLog ([AC_ID] ,[ORDER_ID] ,[RefNo1] ,[OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
			,[Column_Name] ,[Table_Name] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [ORDER_ID] , RefNo1 ,[OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Order_Client_Identifier' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_Order_Client_Identifier_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 0 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Value_','T_Order_Client_Identifier') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[OIF_CODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Value_] ,[NewValue]=new.[Value_] ,[Column_Name]='Value_'
				from #JsonOldDeleteClientIdentifierTable old inner join #JsonNewDeleteClientIdentifierTable new on old.OIF_CODE = new.OIF_CODE and old.ORDER_ID = new.ORDER_ID
			) ilv where ilv.[OldValue] <> ilv.[NewValue] and ilv.[OldValue] <> ''
			order by ilv.RefNo1 ,ilv.ID
		end

		exec [POMS_DB].[dbo].[P_Add_Order_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_Order_Client_Identifier_IU_ChangeLog Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
