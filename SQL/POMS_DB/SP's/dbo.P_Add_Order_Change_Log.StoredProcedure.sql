USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Add_Order_Change_Log]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Add_Order_Change_Log]
	@pORDER_ID int
	,@pAuditType_MTV_ID int
	,@pRefNo1 nvarchar(50)
	,@pRefNo2 nvarchar(50)
	,@pRefNo3 nvarchar(50)
	,@pOldValueHidden nvarchar(2000)
	,@pNewValueHidden nvarchar(2000)
	,@pOldValue nvarchar(2000)
	,@pNewValue nvarchar(2000)
	,@pColumn_Name nvarchar(100)
	,@pTable_Name nvarchar(150)
	,@pReason nvarchar(1000)
	,@pSource_MTV_ID int
	,@pChangedBy nvarchar(150)
	,@pIsAuto bit
	,@pTriggerDebugInfo nvarchar(4000) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	drop table if exists #JsonChangeLog
	Create Table #JsonChangeLog
	(ID [int] identity(1,1) NOT NULL
	,[AC_ID] [int] NOT NULL
	,[ORDER_ID] [int] NOT NULL
	,[AuditType_MTV_ID] [int] NOT NULL
	,[RefNo1] [nvarchar](50) NOT NULL
	,[RefNo2] [nvarchar](50) NOT NULL
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
		Declare @AC_ID int = 0
		set @AC_ID = [POMS_DB].[dbo].[F_Get_AC_ID] (@pColumn_Name, @pTable_Name)

		insert into #JsonChangeLog ([AC_ID] ,[ORDER_ID] ,[AuditType_MTV_ID] ,[RefNo1] ,[RefNo2] ,[RefNo3] ,[OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
		,[Column_Name] ,[Table_Name] ,[Reason] ,[IsAuto] ,[Source_MTV_ID] ,[TriggerDebugInfo] ,[ChangedBy])
		select @AC_ID ,@pORDER_ID ,@pAuditType_MTV_ID ,@pRefNo1 ,@pRefNo2 ,@pRefNo3 ,@pOldValueHidden ,@pNewValueHidden ,@pOldValue ,@pNewValue 
		,@pColumn_Name ,@pTable_Name ,@pReason ,@pIsAuto ,@pSource_MTV_ID ,@pTriggerDebugInfo ,@pChangedBy

		exec [POMS_DB].[dbo].[P_Add_Order_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_Add_Order_Change_Log Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
