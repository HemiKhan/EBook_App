USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_User_Seller_Mapping_IU_ChangeLog]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_User_Seller_Mapping_IU_ChangeLog]
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
	,[REF_NO] [nvarchar](150) NOT NULL
	,[AuditType_MTV_ID] [int] NOT NULL default 166118
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
			insert into #JsonChangeLog ([AC_ID] ,[REF_NO] ,[RefNo1], [OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
			,[Column_Name] ,[Table_Name] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [REF_NO] , RefNo1 ,[OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_User_To_Seller_Mapping' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_User_Seller_Mapping_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 0 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('SELLER_ID','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.SELLER_ID ,[NewValueHidden]=new.SELLER_ID
				,[OldValue]=old.SELLER_NAME ,[NewValue]=new.SELLER_NAME ,[Column_Name]='SELLER_ID'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 1 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsViewOrder','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsViewOrder ,[NewValueHidden]=new.IsViewOrder
				,[OldValue]=old.IsViewOrderName ,[NewValue]=new.IsViewOrderName ,[Column_Name]='IsViewOrder'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 2 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsCreateOrder','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsCreateOrder ,[NewValueHidden]=new.IsCreateOrder
				,[OldValue]=old.IsCreateOrderName ,[NewValue]=new.IsCreateOrderName ,[Column_Name]='IsCreateOrder'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 3 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsGetQuote','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsGetQuote ,[NewValueHidden]=new.IsGetQuote
				,[OldValue]=old.IsGetQuoteName ,[NewValue]=new.IsGetQuoteName ,[Column_Name]='IsGetQuote'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 4 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('SELLER_ID','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.SELLER_ID ,[NewValueHidden]=new.SELLER_ID
				,[OldValue]=old.SELLER_NAME ,[NewValue]=new.SELLER_NAME ,[Column_Name]='SELLER_ID'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 5 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsFinancial','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsFinancial ,[NewValueHidden]=new.IsFinancial
				,[OldValue]=old.IsFinancialName ,[NewValue]=new.IsFinancialName ,[Column_Name]='IsFinancial'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 6 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsAdmin','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsAdmin ,[NewValueHidden]=new.IsAdmin
				,[OldValue]=old.IsAdminName ,[NewValue]=new.IsAdminName ,[Column_Name]='IsAdmin'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 7 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsBlankSubSellerAllowed','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsBlankSubSellerAllowed ,[NewValueHidden]=new.IsBlankSubSellerAllowed
				,[OldValue]=old.IsBlankSubSellerAllowedName ,[NewValue]=new.IsBlankSubSellerAllowedName ,[Column_Name]='IsBlankSubSellerAllowed'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 8 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsAllSubSellerAllowed','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsAllSubSellerAllowed ,[NewValueHidden]=new.IsAllSubSellerAllowed
				,[OldValue]=old.IsAllSubSellerAllowedName ,[NewValue]=new.IsAllSubSellerAllowedName ,[Column_Name]='IsAllSubSellerAllowed'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 9 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsBlankPartnerAllowed','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsBlankPartnerAllowed ,[NewValueHidden]=new.IsBlankPartnerAllowed
				,[OldValue]=old.IsBlankPartnerAllowedName ,[NewValue]=new.IsBlankPartnerAllowedName ,[Column_Name]='IsBlankPartnerAllowed'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 10 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsAllPartnerAllowed','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsAllPartnerAllowed ,[NewValueHidden]=new.IsAllPartnerAllowed
				,[OldValue]=old.IsAllPartnerAllowedName ,[NewValue]=new.IsAllPartnerAllowedName ,[Column_Name]='IsAllPartnerAllowed'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 11 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsBlankTariffAllowed','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsBlankTariffAllowed ,[NewValueHidden]=new.IsBlankTariffAllowed
				,[OldValue]=old.IsBlankTariffAllowedName ,[NewValue]=new.IsBlankTariffAllowedName ,[Column_Name]='IsBlankTariffAllowed'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 12 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsAllTariffAllowed','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsAllTariffAllowed ,[NewValueHidden]=new.IsAllTariffAllowed
				,[OldValue]=old.IsAllTariffAllowedName ,[NewValue]=new.IsAllTariffAllowedName ,[Column_Name]='IsAllTariffAllowed'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
				union
				select ID = 13 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsActive','T_User_To_Seller_Mapping') , [REF_NO] = old.UTSM_ID
				,RefNo1=old.UserName ,[OldValueHidden]=old.IsActive ,[NewValueHidden]=new.IsActive
				,[OldValue]=old.IsActiveName ,[NewValue]=new.IsActiveName ,[Column_Name]='IsActive'
				from #JsonOldEditUserSellerMappingTable old inner join #JsonNewEditUserSellerMappingTable new on old.UTSM_ID = new.UTSM_ID and old.UserName = new.UserName
			) ilv where ilv.[OldValue] <> ilv.[NewValue]
			order by ilv.RefNo1 ,ilv.ID
		end
		
		exec [POMS_DB].[dbo].[P_Add_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_User_Seller_Mapping_IU_ChangeLog Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
