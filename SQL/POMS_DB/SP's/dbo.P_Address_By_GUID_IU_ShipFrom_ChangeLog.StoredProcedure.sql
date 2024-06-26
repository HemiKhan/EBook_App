USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Address_By_GUID_IU_ShipFrom_ChangeLog]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Address_By_GUID_IU_ShipFrom_ChangeLog]
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
			insert into #JsonChangeLog ([AC_ID] ,[ORDER_ID] ,[OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] ,[Column_Name] ,[Table_Name] ,[IsAuto] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [ORDER_ID] , [OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Order' ,[IsAuto] ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_Address_By_GUID_IU_ShipFrom_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 0 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_ADDRESS_CODE','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_ADDRESS_CODE ,[NewValue]=new.ShipFrom_ADDRESS_CODE 
				,[Column_Name]='ShipFrom_ADDRESS_CODE', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 1 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_FirstName','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_FirstName ,[NewValue]=new.ShipFrom_FirstName 
				,[Column_Name]='ShipFrom_FirstName', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 2 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_MiddleName','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_MiddleName ,[NewValue]=new.ShipFrom_MiddleName 
				,[Column_Name]='ShipFrom_MiddleName', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 3 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_LastName','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_LastName ,[NewValue]=new.ShipFrom_LastName 
				,[Column_Name]='ShipFrom_LastName', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 4 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_Company','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_Company ,[NewValue]=new.ShipFrom_Company 
				,[Column_Name]='ShipFrom_Company', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 5 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_ContactPerson','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_ContactPerson ,[NewValue]=new.ShipFrom_ContactPerson 
				,[Column_Name]='ShipFrom_ContactPerson', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 6 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_Address','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_Address ,[NewValue]=new.ShipFrom_Address 
				,[Column_Name]='ShipFrom_Address', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 7 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_Address2','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_Address2 ,[NewValue]=new.ShipFrom_Address2 
				,[Column_Name]='ShipFrom_Address2', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 8 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_City','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_City ,[NewValue]=new.ShipFrom_City 
				,[Column_Name]='ShipFrom_City', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 9 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_State','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_State ,[NewValue]=new.ShipFrom_State 
				,[Column_Name]='ShipFrom_State', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 10 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_ZipCode','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_ZipCode ,[NewValue]=new.ShipFrom_ZipCode 
				,[Column_Name]='ShipFrom_ZipCode', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 11 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_County','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_County ,[NewValue]=new.ShipFrom_County 
				,[Column_Name]='ShipFrom_County', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 12 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_CountryRegionCode','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_CountryRegionCode ,[NewValue]=new.ShipFrom_CountryRegionCode 
				,[Column_Name]='ShipFrom_CountryRegionCode', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 13 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_Email','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_Email ,[NewValue]=new.ShipFrom_Email 
				,[Column_Name]='ShipFrom_Email', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 14 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_Mobile','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_Mobile ,[NewValue]=new.ShipFrom_Mobile 
				,[Column_Name]='ShipFrom_Mobile', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 15 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_Phone','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_Phone ,[NewValue]=new.ShipFrom_Phone 
				,[Column_Name]='ShipFrom_Phone', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 16 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_PhoneExt','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_PhoneExt ,[NewValue]=new.ShipFrom_PhoneExt 
				,[Column_Name]='ShipFrom_PhoneExt', [IsAuto] = 0 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 17 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('IsShipFrom_ValidAddress','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.IsShipFrom_ValidAddress ,[NewValueHidden]=new.IsShipFrom_ValidAddress ,[OldValue]=old.IsShipFrom_ValidAddressText ,[NewValue]=new.IsShipFrom_ValidAddressText
				,[Column_Name]='IsShipFrom_ValidAddress', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 18 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_Lat','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_Lat ,[NewValue]=new.ShipFrom_Lat 
				,[Column_Name]='ShipFrom_Lat', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 19 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_Lng','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_Lng ,[NewValue]=new.ShipFrom_Lng 
				,[Column_Name]='ShipFrom_Lng', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 20 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_PlaceID','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_PlaceID ,[NewValue]=new.ShipFrom_PlaceID 
				,[Column_Name]='ShipFrom_PlaceID', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 21 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_AreaType_MTV_ID','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.ShipFrom_AreaType_MTV_ID ,[NewValueHidden]=new.ShipFrom_AreaType_MTV_ID ,[OldValue]=old.ShipFrom_AreaTypeName ,[NewValue]=new.ShipFrom_AreaTypeName 
				,[Column_Name]='ShipFrom_AreaType_MTV_ID', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 22 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_HUB_CODE','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.ShipFrom_HUB_CODE ,[NewValueHidden]=new.ShipFrom_HUB_CODE ,[OldValue]=old.ShipFrom_HUB_Name ,[NewValue]=new.ShipFrom_HUB_Name 
				,[Column_Name]='ShipFrom_HUB_CODE', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 23 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('LiveShipFrom_HUB_CODE','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.LiveShipFrom_HUB_CODE ,[NewValueHidden]=new.LiveShipFrom_HUB_CODE ,[OldValue]=old.LiveShipFrom_HUB_Name ,[NewValue]=new.LiveShipFrom_HUB_Name 
				,[Column_Name]='LiveShipFrom_HUB_CODE', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 24 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_ZONE_CODE','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.ShipFrom_ZONE_CODE ,[NewValueHidden]=new.ShipFrom_ZONE_CODE ,[OldValue]=old.ShipFrom_ZONE_Name ,[NewValue]=new.ShipFrom_ZONE_Name 
				,[Column_Name]='ShipFrom_ZONE_CODE', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 25 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ShipFrom_ChangeCount','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]='' ,[NewValueHidden]='' ,[OldValue]=old.ShipFrom_ChangeCount ,[NewValue]=new.ShipFrom_ChangeCount 
				,[Column_Name]='ShipFrom_ChangeCount', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 26 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PickupScheduleType_MTV_ID','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.PickupScheduleType_MTV_ID ,[NewValueHidden]=new.PickupScheduleType_MTV_ID ,[OldValue]=old.PickupScheduleType_Name ,[NewValue]=new.PickupScheduleType_Name 
				,[Column_Name]='PickupScheduleType_MTV_ID', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
				union
				select ID = 27 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('FirstOffered_PickupDate','T_Order') , [ORDER_ID] = old.ORDER_ID
				,[OldValueHidden]=old.FirstOfferDate ,[NewValueHidden]=new.FirstOfferDate ,[OldValue]=old.FirstOfferDate ,[NewValue]=new.FirstOfferDate 
				,[Column_Name]='FirstOffered_PickupDate', [IsAuto] = 1 from #JsonOldShipFromOrderTable old inner join #JsonNewShipFromOrderTable new on old.ORDER_ID = new.ORDER_ID
			) ilv where ilv.[OldValue] <> ilv.[NewValue]
			order by ilv.ID
		end

		exec [POMS_DB].[dbo].[P_Add_Order_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_Address_By_GUID_IU_ShipFrom_ChangeLog Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
