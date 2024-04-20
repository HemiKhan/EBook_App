USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Order_Items_IU_ChangeLog]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Order_Items_IU_ChangeLog]
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
	,[AuditType_MTV_ID] [int] NOT NULL default 108101
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
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Order_Items' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_Order_Items_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 0 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('BARCODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[BARCODE] ,[NewValue]=new.[BARCODE] ,[Column_Name]='BARCODE'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 1 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PARENT_OI_ID','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[PARENT_OI_ID] ,[NewValue]=new.[PARENT_OI_ID] ,[Column_Name]='PARENT_OI_ID'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 2 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemToShip_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[ItemToShip_MTV_CODE] ,[NewValueHidden]=new.[ItemToShip_MTV_CODE] 
				,[OldValue]=old.[ItemToShip_MTV_CODE_Name] ,[NewValue]=new.[ItemToShip_MTV_CODE_Name] ,[Column_Name]='ItemToShip_MTV_CODE'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 3 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemCode_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[ItemCode_MTV_CODE] ,[NewValueHidden]=new.[ItemCode_MTV_CODE] 
				,[OldValue]=old.[ItemCode_MTV_CODE_Name] ,[NewValue]=new.[ItemCode_MTV_CODE_Name] ,[Column_Name]='ItemCode_MTV_CODE'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 4 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PackingCode_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[PackingCode_MTV_CODE] ,[NewValueHidden]=new.[PackingCode_MTV_CODE] 
				,[OldValue]=old.[PackingCode_MTV_CODE_Name] ,[NewValue]=new.[PackingCode_MTV_CODE_Name] ,[Column_Name]='PackingCode_MTV_CODE'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 5 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('SKU_NO','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[SKU_NO] ,[NewValue]=new.[SKU_NO] ,[Column_Name]='SKU_NO'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 6 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemDescription','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[ItemDescription] ,[NewValue]=new.[ItemDescription] ,[Column_Name]='ItemDescription'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 7 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemWeight','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[ItemWeight] ,[NewValue]=new.[ItemWeight] ,[Column_Name]='ItemWeight'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 8 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('WeightUnit_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[WeightUnit_MTV_CODE] ,[NewValueHidden]=new.[WeightUnit_MTV_CODE]
				,[OldValue]=old.[WeightUnit_MTV_CODE_Name] ,[NewValue]=new.[WeightUnit_MTV_CODE_Name] ,[Column_Name]='WeightUnit_MTV_CODE'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 9 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemLength','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemLength] ,[NewValue]=new.[ItemLength] ,[Column_Name]='ItemLength'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 10 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemWidth','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemWidth] ,[NewValue]=new.[ItemWidth] ,[Column_Name]='ItemWidth'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 11 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemHeight','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemHeight] ,[NewValue]=new.[ItemHeight] ,[Column_Name]='ItemHeight'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 12 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Dimensions','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[Dimensions] ,[NewValue]=new.[Dimensions] ,[Column_Name]='Dimensions'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 13 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('DimensionUnit_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[DimensionUnit_MTV_CODE] ,[NewValueHidden]=new.[DimensionUnit_MTV_CODE]
				,[OldValue]=old.[DimensionUnit_MTV_CODE_Name] ,[NewValue]=new.[DimensionUnit_MTV_CODE_Name] ,[Column_Name]='DimensionUnit_MTV_CODE'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 14 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Cu_Ft_','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[Cu_Ft_] ,[NewValue]=new.[Cu_Ft_] ,[Column_Name]='Cu_Ft_'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 15 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Amount','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[Amount] ,[NewValue]=new.[Amount] ,[Column_Name]='Amount'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 16 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('AssemblyTime','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[AssemblyTime] ,[NewValue]=new.[AssemblyTime] ,[Column_Name]='AssemblyTime'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 17 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PackageDetailsNote','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[PackageDetailsNote] ,[NewValue]=new.[PackageDetailsNote] ,[Column_Name]='PackageDetailsNote'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 18 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemClientRef1','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemClientRef1] ,[NewValue]=new.[ItemClientRef1] ,[Column_Name]='ItemClientRef1'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 19 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemClientRef2','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemClientRef2] ,[NewValue]=new.[ItemClientRef2] ,[Column_Name]='ItemClientRef2'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 20 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemClientRef3','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemClientRef3] ,[NewValue]=new.[ItemClientRef3] ,[Column_Name]='ItemClientRef3'
				from #JsonOldEditItemsTable old inner join #JsonNewEditItemsTable new on old.BARCODE = new.Barcode
			) ilv where ilv.[OldValue] <> ilv.[NewValue]
			order by ilv.RefNo1 ,ilv.ID
		end
		else if @plogIsDelete = 1
		begin

			insert into #JsonChangeLog ([AC_ID] ,[ORDER_ID] ,[RefNo1] ,[OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
			,[Column_Name] ,[Table_Name] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [ORDER_ID] , RefNo1 ,[OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Order_Items' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_Order_Items_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 0 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('BARCODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[BARCODE] ,[NewValue]=new.[BARCODE] ,[Column_Name]='BARCODE'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 1 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PARENT_OI_ID','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[PARENT_OI_ID] ,[NewValue]=new.[PARENT_OI_ID] ,[Column_Name]='PARENT_OI_ID'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 2 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemToShip_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[ItemToShip_MTV_CODE] ,[NewValueHidden]=new.[ItemToShip_MTV_CODE] 
				,[OldValue]=old.[ItemToShip_MTV_CODE_Name] ,[NewValue]=new.[ItemToShip_MTV_CODE_Name] ,[Column_Name]='ItemToShip_MTV_CODE'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 3 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemCode_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[ItemCode_MTV_CODE] ,[NewValueHidden]=new.[ItemCode_MTV_CODE] 
				,[OldValue]=old.[ItemCode_MTV_CODE_Name] ,[NewValue]=new.[ItemCode_MTV_CODE_Name] ,[Column_Name]='ItemCode_MTV_CODE'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 4 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PackingCode_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[PackingCode_MTV_CODE] ,[NewValueHidden]=new.[PackingCode_MTV_CODE] 
				,[OldValue]=old.[PackingCode_MTV_CODE_Name] ,[NewValue]=new.[PackingCode_MTV_CODE_Name] ,[Column_Name]='PackingCode_MTV_CODE'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 5 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('SKU_NO','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[SKU_NO] ,[NewValue]=new.[SKU_NO] ,[Column_Name]='SKU_NO'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 6 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemDescription','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[ItemDescription] ,[NewValue]=new.[ItemDescription] ,[Column_Name]='ItemDescription'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 7 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemWeight','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]='' 
				,[OldValue]=old.[ItemWeight] ,[NewValue]=new.[ItemWeight] ,[Column_Name]='ItemWeight'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 8 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('WeightUnit_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[WeightUnit_MTV_CODE] ,[NewValueHidden]=new.[WeightUnit_MTV_CODE]
				,[OldValue]=old.[WeightUnit_MTV_CODE_Name] ,[NewValue]=new.[WeightUnit_MTV_CODE_Name] ,[Column_Name]='WeightUnit_MTV_CODE'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 9 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemLength','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemLength] ,[NewValue]=new.[ItemLength] ,[Column_Name]='ItemLength'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 10 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemWidth','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemWidth] ,[NewValue]=new.[ItemWidth] ,[Column_Name]='ItemWidth'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 11 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemHeight','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemHeight] ,[NewValue]=new.[ItemHeight] ,[Column_Name]='ItemHeight'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 12 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Dimensions','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[Dimensions] ,[NewValue]=new.[Dimensions] ,[Column_Name]='Dimensions'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 13 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('DimensionUnit_MTV_CODE','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]=old.[DimensionUnit_MTV_CODE] ,[NewValueHidden]=new.[DimensionUnit_MTV_CODE]
				,[OldValue]=old.[DimensionUnit_MTV_CODE_Name] ,[NewValue]=new.[DimensionUnit_MTV_CODE_Name] ,[Column_Name]='DimensionUnit_MTV_CODE'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 14 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Cu_Ft_','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[Cu_Ft_] ,[NewValue]=new.[Cu_Ft_] ,[Column_Name]='Cu_Ft_'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 15 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('Amount','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[Amount] ,[NewValue]=new.[Amount] ,[Column_Name]='Amount'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 16 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('AssemblyTime','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[AssemblyTime] ,[NewValue]=new.[AssemblyTime] ,[Column_Name]='AssemblyTime'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 17 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('PackageDetailsNote','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[PackageDetailsNote] ,[NewValue]=new.[PackageDetailsNote] ,[Column_Name]='PackageDetailsNote'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 18 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemClientRef1','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemClientRef1] ,[NewValue]=new.[ItemClientRef1] ,[Column_Name]='ItemClientRef1'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 19 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemClientRef2','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemClientRef2] ,[NewValue]=new.[ItemClientRef2] ,[Column_Name]='ItemClientRef2'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
				union
				select ID = 20 ,[AC_ID] = [POMS_DB].[dbo].[F_Get_AC_ID] ('ItemClientRef3','T_Order_Items') , [ORDER_ID] = old.ORDER_ID
				, RefNo1 = old.[BARCODE] ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[ItemClientRef3] ,[NewValue]=new.[ItemClientRef3] ,[Column_Name]='ItemClientRef3'
				from #JsonOldDeleteItemsTable old inner join #JsonNewDeleteItemsTable new on old.BARCODE = new.Barcode
			) ilv where ilv.[OldValue] <> ilv.[NewValue] and ilv.[OldValue] <> ''
			order by ilv.RefNo1 ,ilv.ID
		end

		exec [POMS_DB].[dbo].[P_Add_Order_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_Order_Items_IU_ChangeLog Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
