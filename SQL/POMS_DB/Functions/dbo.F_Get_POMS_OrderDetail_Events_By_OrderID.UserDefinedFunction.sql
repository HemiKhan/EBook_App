USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_Events_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_Events_By_OrderID] (3652511,'ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_Events_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
([OrderID] int
, [EL_ID] int
, [Activity] nvarchar(50)
, [Event] nvarchar(50)
, [Date] datetime
, [Trigger] nvarchar(50)
, [Location] nvarchar(50)
, [InitiatedBy] nvarchar(250)
, TotalRecords int
)
AS
begin
	
	Declare @TotalRecords int = 0
	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZone_ID

	if @GetRecordType_MTV_ID in (147100,147102)
	begin
		select @TotalRecords = (@TotalRecords + count(oe.OE_ID)) from [POMS_DB].[dbo].[T_Order_Events] oe with (nolock)
		inner join [POMS_DB].[dbo].[T_Events_List] el with (nolock) on oe.EVENT_ID = el.EVENT_ID
		Where oe.ORDER_ID= @ORDER_ID and oe.IsActive = 1 and el.IsActive = 1 and ((el.IsPublic = 1 and  @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [EL_ID] , [Activity] , [Event] , [Date] , [Trigger] , [Location] , [InitiatedBy] , TotalRecords)
			select OrderID = oe.ORDER_ID
				,[EL_ID] = oe.EVENT_ID
				,[Activity] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (el.[Activity_MTV_ID])
				,[Event] = el.[Name]
				,[Date]= [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oe.TriggerDate,@TimeZone_ID,null,@TimeZoneName)
				,[Trigger]=(case when oe.IsAuto = 1 then 'Automatic' else 'Manual' end)
				,[Location]= isnull(hl.City + ', ','') + isnull(hl.[State],'')
				,[InitiatedBy]= afn.FullName
				,TotalRecords = @TotalRecords
			from [POMS_DB].[dbo].[T_Order_Events] oe with (nolock)
			inner join [POMS_DB].[dbo].[T_Events_List] el with (nolock) on oe.EVENT_ID = el.EVENT_ID
			left join [POMS_DB].[dbo].[T_Hub_List] hl with (nolock) on oe.HUB_CODE = hl.HUB_CODE
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (oe.CreatedBy) afn
			Where oe.ORDER_ID= @ORDER_ID and oe.IsActive = 1 and el.IsActive = 1 and ((el.IsPublic = 1 and  @IsPublic = 0) or @IsPublic = 1)
		end

		if @GetRecordType_MTV_ID in (147101)
		begin
			Declare @TempTotalRecords int = 0
			select @TempTotalRecords = (@TempTotalRecords + count(oe.OE_ID)) from [POMSArchive_DB].[dbo].[T_Order_Events] oe with (nolock)
			inner join [POMS_DB].[dbo].[T_Events_List] el with (nolock) on oe.EVENT_ID = el.EVENT_ID
			Where oe.ORDER_ID= @ORDER_ID and oe.IsActive = 1 and el.IsActive = 1 and ((el.IsPublic = 1 and  @IsPublic = 0) or @IsPublic = 1)

			if @TempTotalRecords > 0
			begin
				set @TotalRecords = @TotalRecords + @TempTotalRecords
				insert into @ReturnTable ([OrderID] , [EL_ID] , [Activity] , [Event] , [Date] , [Trigger] , [Location] , [InitiatedBy] , TotalRecords)
				select OrderID = oe.ORDER_ID
					,[EL_ID] = oe.EVENT_ID
					,[Activity] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (el.[Activity_MTV_ID])
					,[Event] = el.[Name]
					,[Date]= [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oe.TriggerDate,@TimeZone_ID,null,@TimeZoneName)
					,[Trigger]=(case when oe.IsAuto = 1 then 'Automatic' else 'Manual' end)
					,[Location]= isnull(hl.City + ', ','') + isnull(hl.[State],'')
					,[InitiatedBy]= afn.FullName
					,TotalRecords = @TotalRecords
				from [POMSArchive_DB].[dbo].[T_Order_Events] oe with (nolock)
				inner join [POMS_DB].[dbo].[T_Events_List] el with (nolock) on oe.EVENT_ID = el.EVENT_ID
				left join [POMS_DB].[dbo].[T_Hub_List] hl with (nolock) on oe.HUB_CODE = hl.HUB_CODE
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (oe.CreatedBy) afn
				Where oe.ORDER_ID= @ORDER_ID and oe.IsActive = 1 and el.IsActive = 1 and ((el.IsPublic = 1 and  @IsPublic = 0) or @IsPublic = 1)
			end
		end
	end
	else if @GetRecordType_MTV_ID in (147101)
	begin
		select @TotalRecords = (@TotalRecords + count(oe.OE_ID)) from [POMSArchive_DB].[dbo].[T_Order_Events] oe with (nolock)
		inner join [POMS_DB].[dbo].[T_Events_List] el with (nolock) on oe.EVENT_ID = el.EVENT_ID
		Where oe.ORDER_ID= @ORDER_ID and oe.IsActive = 1 and el.IsActive = 1 and ((el.IsPublic = 1 and  @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [EL_ID] , [Activity] , [Event] , [Date] , [Trigger] , [Location] , [InitiatedBy] , TotalRecords)
			select OrderID = oe.ORDER_ID
				,[EL_ID] = oe.EVENT_ID
				,[Activity] = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (el.[Activity_MTV_ID])
				,[Event] = el.[Name]
				,[Date]= [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oe.TriggerDate,@TimeZone_ID,null,@TimeZoneName)
				,[Trigger]=(case when oe.IsAuto = 1 then 'Automatic' else 'Manual' end)
				,[Location]= isnull(hl.City + ', ','') + isnull(hl.[State],'')
				,[InitiatedBy]= afn.FullName
				,TotalRecords = @TotalRecords
			from [POMSArchive_DB].[dbo].[T_Order_Events] oe with (nolock)
			inner join [POMS_DB].[dbo].[T_Events_List] el with (nolock) on oe.EVENT_ID = el.EVENT_ID
			left join [POMS_DB].[dbo].[T_Hub_List] hl with (nolock) on oe.HUB_CODE = hl.HUB_CODE
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (oe.CreatedBy) afn
			Where oe.ORDER_ID= @ORDER_ID and oe.IsActive = 1 and el.IsActive = 1 and ((el.IsPublic = 1 and  @IsPublic = 0) or @IsPublic = 1)
		end
	end

	return
	

end
GO
