USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_User_IU_ChangeLog]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[P_User_IU_ChangeLog]
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
	,[AuditType_MTV_ID] [int] NOT NULL default 166120
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
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Users' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_User_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 1 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('UserType_MTV_CODE','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.UserType_MTV_CODE ,[NewValueHidden]=new.UserType_MTV_CODE
				,[OldValue]=old.UserType_MTV_CODE_Name ,[NewValue]=new.UserType_MTV_CODE_Name ,[Column_Name]='UserType_MTV_CODE'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 2 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PasswordHash','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]='' ,[NewValue]='Changed' ,[Column_Name]='PasswordHash'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 3 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PasswordSalt','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]='' ,[NewValue]='Changed' ,[Column_Name]='PasswordSalt'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 4 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('D_ID','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.D_ID ,[NewValueHidden]=new.D_ID
				,[OldValue]=old.D_ID_Name ,[NewValue]=new.D_ID_Name ,[Column_Name]='D_ID'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 5 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Designation','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Designation ,[NewValue]=new.Designation ,[Column_Name]='Designation'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 6 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('FirstName','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.FirstName ,[NewValue]=new.FirstName ,[Column_Name]='FirstName'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 7 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('MiddleName','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.MiddleName ,[NewValue]=new.MiddleName ,[Column_Name]='MiddleName'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 8 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('LastName','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.LastName ,[NewValue]=new.LastName ,[Column_Name]='LastName'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 9 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Company','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Company ,[NewValue]=new.Company ,[Column_Name]='Company'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 10 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Address','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[Address] ,[NewValue]=new.[Address] ,[Column_Name]='Address'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 11 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Address2','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Address2 ,[NewValue]=new.Address2 ,[Column_Name]='Address2'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 12 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('City','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.City ,[NewValue]=new.City ,[Column_Name]='City'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 13 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('State','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[State] ,[NewValue]=new.[State] ,[Column_Name]='State'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 14 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ZipCode','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.ZipCode ,[NewValue]=new.ZipCode ,[Column_Name]='ZipCode'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 15 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Country','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Country ,[NewValue]=new.Country ,[Column_Name]='Country'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 16 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Email','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Email ,[NewValue]=new.Email ,[Column_Name]='Email'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 17 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Mobile','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Mobile ,[NewValue]=new.Mobile ,[Column_Name]='Mobile'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 18 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Phone','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Phone ,[NewValue]=new.Phone ,[Column_Name]='Phone'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 19 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PhoneExt','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.PhoneExt ,[NewValue]=new.PhoneExt ,[Column_Name]='PhoneExt'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 20 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('SecurityQuestion_MTV_ID','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.SecurityQuestion_MTV_ID ,[NewValueHidden]=new.SecurityQuestion_MTV_ID
				,[OldValue]=old.SecurityQuestion_MTV_ID_Name ,[NewValue]=new.SecurityQuestion_MTV_ID_Name ,[Column_Name]='SecurityQuestion_MTV_ID'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 21 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('EncryptedAnswer','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]='' ,[NewValue]='Changed' ,[Column_Name]='EncryptedAnswer'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 22 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('TIMEZONE_ID','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.TIMEZONE_ID ,[NewValueHidden]=new.TIMEZONE_ID
				,[OldValue]=old.TIMEZONE_ID_Name ,[NewValue]=new.TIMEZONE_ID_Name ,[Column_Name]='TIMEZONE_ID'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 23 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsApproved','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.IsApproved ,[NewValueHidden]=new.IsApproved
				,[OldValue]=old.IsApproved_Name ,[NewValue]=new.IsApproved_Name ,[Column_Name]='IsApproved'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 24 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('BlockType_MTV_ID','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.BlockType_MTV_ID ,[NewValueHidden]=new.BlockType_MTV_ID
				,[OldValue]=old.BlockType_MTV_ID_Name ,[NewValue]=new.BlockType_MTV_ID_Name ,[Column_Name]='BlockType_MTV_ID'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 25 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsAPIUser','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.IsAPIUser ,[NewValueHidden]=new.IsAPIUser
				,[OldValue]=old.IsAPIUser_Name ,[NewValue]=new.IsAPIUser_Name ,[Column_Name]='IsAPIUser'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 26 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsActive','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.IsActive ,[NewValueHidden]=new.IsActive
				,[OldValue]=old.IsActive_Name ,[NewValue]=new.IsActive_Name ,[Column_Name]='IsActive'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
			) ilv where ilv.[OldValue] <> ilv.[NewValue]
			order by ilv.RefNo1 ,ilv.ID
		end
		
		exec [POMS_DB].[dbo].[P_Add_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_User_IU_ChangeLog Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
