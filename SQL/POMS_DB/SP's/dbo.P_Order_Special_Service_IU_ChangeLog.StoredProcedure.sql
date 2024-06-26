USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Special_Service_IU_ChangeLog]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Special_Service_IU_ChangeLog]
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
	,[AuditType_MTV_ID] [int] NOT NULL default 108107
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
		if @plogIsEdit = 1
		begin
			insert into #JsonChangeLog ([AC_ID] ,[ORDER_ID] ,[RefNo1], [RefNo2] ,[OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
			,[Column_Name] ,[Table_Name] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [ORDER_ID] , RefNo1 ,RefNo2 ,[OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Order_Special_Service' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_Order_Special_Service_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 0 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('SLSS_ID','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]=old.SLSS_ID ,[NewValueHidden]=new.SLSS_ID 
				,[OldValue]=old.[SLSS_ID_Name] ,[NewValue]=new.[SLSS_ID_Name] ,[Column_Name]='SLSS_ID'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 1 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Description_','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Description_] ,[NewValue]=new.[Description_] ,[Column_Name]='Description_'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 2 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Mints','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Mints] ,[NewValue]=new.[Mints] ,[Column_Name]='Mints'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 3 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Floor','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Floor_] ,[NewValue]=new.[Floor_] ,[Column_Name]='Floor_'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 4 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('EST_Amount','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[EST_Amount] ,[NewValue]=new.[EST_Amount] ,[Column_Name]='EST_Amount'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 5 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Days_','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Days_] ,[NewValue]=new.[Days_] ,[Column_Name]='Days_'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 6 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('From_Date','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[From_Date] ,[NewValue]=new.[From_Date] ,[Column_Name]='From_Date'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 7 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('To_Date','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[To_Date] ,[NewValue]=new.[To_Date] ,[Column_Name]='To_Date'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 8 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Man','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Man] ,[NewValue]=new.[Man] ,[Column_Name]='Man'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 9 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsPublic','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]=cast(old.[IsPublic] as nvarchar(20)),[NewValueHidden]=cast(new.[IsPublic] as nvarchar(20))
				,[OldValue]=old.[IsPublicName] ,[NewValue]=new.[IsPublicName] ,[Column_Name]='IsPublic'
				from #JsonOldEditSpecialServiceTable old inner join #JsonNewEditSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
			) ilv where ilv.[OldValue] <> ilv.[NewValue]
			order by ilv.RefNo1 ,ilv.ID
		end
		else if @plogIsDelete = 1
		begin
			insert into #JsonChangeLog ([AC_ID] ,[ORDER_ID] ,[RefNo1], [RefNo2] ,[OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
			,[Column_Name] ,[Table_Name] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [ORDER_ID] , RefNo1 ,RefNo2 ,[OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Order_Special_Service' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_Order_Special_Service_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 0 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('SLSS_ID','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]=old.SLSS_ID ,[NewValueHidden]=new.SLSS_ID 
				,[OldValue]=old.[SLSS_ID_Name] ,[NewValue]=new.[SLSS_ID_Name] ,[Column_Name]='SLSS_ID'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 1 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Description_','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Description_] ,[NewValue]=new.[Description_] ,[Column_Name]='Description_'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 2 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Mints','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Mints] ,[NewValue]=new.[Mints] ,[Column_Name]='Mints'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 3 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Floor','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Floor_] ,[NewValue]=new.[Floor_] ,[Column_Name]='Floor_'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 4 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('EST_Amount','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[EST_Amount] ,[NewValue]=new.[EST_Amount] ,[Column_Name]='EST_Amount'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 5 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Days_','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Days_] ,[NewValue]=new.[Days_] ,[Column_Name]='Days_'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 6 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('From_Date','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[From_Date] ,[NewValue]=new.[From_Date] ,[Column_Name]='From_Date'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 7 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('To_Date','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[To_Date] ,[NewValue]=new.[To_Date] ,[Column_Name]='To_Date'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 8 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Man','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[Man] ,[NewValue]=new.[Man] ,[Column_Name]='Man'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
				union
				select ID = 9 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsPublic','T_Order_Special_Service') , [ORDER_ID] = old.ORDER_ID
				,RefNo1=old.SLSS_ID ,RefNo2=old.RefNo2 ,[OldValueHidden]=cast(old.[IsPublic] as nvarchar(20)),[NewValueHidden]=cast(new.[IsPublic] as nvarchar(20))
				,[OldValue]=old.[IsPublicName] ,[NewValue]=new.[IsPublicName] ,[Column_Name]='IsPublic'
				from #JsonOldDeleteSpecialServiceTable old inner join #JsonNewDeleteSpecialServiceTable new on old.OSS_ID = new.OSS_ID 
				and old.ORDER_ID = new.ORDER_ID and old.[SLSS_ID] = new.[SLSS_ID]
			) ilv where ilv.[OldValue] <> ilv.[NewValue] and ilv.[OldValue] <> ''
			order by ilv.RefNo1 ,ilv.ID
		end

		exec [POMS_DB].[dbo].[P_Add_Order_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_Order_Special_Service_IU_ChangeLog Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
