USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_ScheduleDate_By_GUID_IU_ChangeLog]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_ScheduleDate_By_GUID_IU_ChangeLog]
	@plogIsEdit bit 
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
	,[AuditType_MTV_ID] [int] NOT NULL default 108100
	,[RefNo1] [nvarchar](50) NOT NULL default ''
	,[RefNo2] [nvarchar](50) NOT NULL default ''
	,[RefNo3] [nvarchar](50) NOT NULL default ''
	,[OldValueHidden] [nvarchar](2000) NOT NULL
	,[NewValueHidden] [nvarchar](2000) NOT NULL
	,[OldValue] [nvarchar](2000) NOT NULL
	,[NewValue] [nvarchar](2000) NOT NULL
	,[Column_Name] [nvarchar](100) NOT NULL default ''
	,[Table_Name] [nvarchar](150) NOT NULL default ''
	,[Reason] [nvarchar](1000) NOT NULL default ''
	,[IsAuto] [bit] NOT NULL
	,[Source_MTV_ID] [int] NOT NULL default 0
	,[TriggerDebugInfo] [nvarchar](4000) NULL
	,[ChangedBy] [nvarchar](150) NOT NULL)

	Begin Try
		if @plogIsEdit = 1
		begin
			insert into #JsonChangeLog ([AC_ID] ,[ORDER_ID] ,[OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
			,[Column_Name] ,[Table_Name] ,[IsAuto] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [ORDER_ID] , [OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Order' ,[IsAuto] ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_ScheduleDate_By_GUID_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 1 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('FirstOffered_PickupDate','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.FirstOffered_PickupDate ,[NewValueHidden]=new.FirstOffered_PickupDate
				,[OldValue]=old.FirstOffered_PickupDateText ,[NewValue]=new.FirstOffered_PickupDateText ,[Column_Name]='FirstOffered_PickupDate', [IsAuto] = 1
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 2 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PromisedPickupDate','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.PromisedPickupDate ,[NewValueHidden]=new.PromisedPickupDate
				,[OldValue]=old.PromisedPickupDateText ,[NewValue]=new.PromisedPickupDateText ,[Column_Name]='PromisedPickupDate', [IsAuto] = 0
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 3 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ReqPickupTimeFrame_TFL_ID','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.ReqPickupTimeFrame_TFL_ID ,[NewValueHidden]=new.ReqPickupTimeFrame_TFL_ID
				,[OldValue]=old.ReqPickupTimeFrameName ,[NewValue]=new.ReqPickupTimeFrameName ,[Column_Name]='ReqPickupTimeFrame_TFL_ID', [IsAuto] = 0
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 4 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PickupFMManifest','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.PickupFMManifest ,[NewValueHidden]=new.PickupFMManifest
				,[OldValue]=old.PickupFMManifest ,[NewValue]=new.PickupFMManifest ,[Column_Name]='PickupFMManifest', [IsAuto] = 1
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 5 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ConfirmedPickupDate','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.ConfirmedPickupDate ,[NewValueHidden]=new.ConfirmedPickupDate
				,[OldValue]=old.ConfirmedPickupDateText ,[NewValue]=new.ConfirmedPickupDateText ,[Column_Name]='ConfirmedPickupDate', [IsAuto] = 1
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 6 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ConfirmedPickupTimeFrame_TFL_ID','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.ConfirmedPickupTimeFrame_TFL_ID ,[NewValueHidden]=new.ConfirmedPickupTimeFrame_TFL_ID
				,[OldValue]=old.ConfirmedPickupTimeFrameName ,[NewValue]=new.ConfirmedPickupTimeFrameName ,[Column_Name]='ConfirmedPickupTimeFrame_TFL_ID', [IsAuto] = 1
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 7 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('FirstOffered_DeliveryDate','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.FirstOffered_DeliveryDate ,[NewValueHidden]=new.FirstOffered_DeliveryDate
				,[OldValue]=old.FirstOffered_DeliveryDateText ,[NewValue]=new.FirstOffered_DeliveryDateText ,[Column_Name]='FirstOffered_DeliveryDate', [IsAuto] = 1
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 8 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PromisedDeliveryDate','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.PromisedDeliveryDate ,[NewValueHidden]=new.PromisedDeliveryDate
				,[OldValue]=old.PromisedDeliveryDateText ,[NewValue]=new.PromisedDeliveryDateText ,[Column_Name]='PromisedDeliveryDate', [IsAuto] = 0
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 9 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ReqDeliveryTimeFrame_TFL_ID','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.ReqDeliveryTimeFrame_TFL_ID ,[NewValueHidden]=new.ReqDeliveryTimeFrame_TFL_ID
				,[OldValue]=old.ReqDeliveryTimeFrameName ,[NewValue]=new.ReqDeliveryTimeFrameName ,[Column_Name]='ReqDeliveryTimeFrame_TFL_ID', [IsAuto] = 0
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 10 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('DeliveryFMManifest','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.DeliveryFMManifest ,[NewValueHidden]=new.DeliveryFMManifest
				,[OldValue]=old.DeliveryFMManifest ,[NewValue]=new.DeliveryFMManifest ,[Column_Name]='DeliveryFMManifest', [IsAuto] = 1
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 11 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ConfirmedDeliveryDate','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.ConfirmedDeliveryDate ,[NewValueHidden]=new.ConfirmedDeliveryDate
				,[OldValue]=old.ConfirmedDeliveryDateText ,[NewValue]=new.ConfirmedDeliveryDateText ,[Column_Name]='ConfirmedDeliveryDate', [IsAuto] = 1
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 12 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ConfirmedDeliveryTimeFrame_TFL_ID','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.ConfirmedDeliveryTimeFrame_TFL_ID ,[NewValueHidden]=new.ConfirmedDeliveryTimeFrame_TFL_ID
				,[OldValue]=old.ConfirmedDeliveryTimeFrameName ,[NewValue]=new.ConfirmedDeliveryTimeFrameName ,[Column_Name]='ConfirmedDeliveryTimeFrame_TFL_ID', [IsAuto] = 1
				from #JsonOldEditOrderTable old inner join #JsonNewEditOrderTable new on old.ORDER_ID = new.ORDER_ID
			) ilv where ilv.[OldValue] <> ilv.[NewValue]
			order by ilv.ID
		end

		exec [POMS_DB].[dbo].[P_Add_Order_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_ScheduleDate_By_GUID_IU_ChangeLog Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
