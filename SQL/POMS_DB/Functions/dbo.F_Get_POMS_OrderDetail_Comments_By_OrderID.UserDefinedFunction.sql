USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_POMS_OrderDetail_Comments_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_POMS_OrderDetail_Comments_By_OrderID] (10100656,'ABDULLAH.ARSHAD','METRO-USER',1,13,147100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_POMS_OrderDetail_Comments_By_OrderID]
(	
	@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable table
(OrderID int
, [OC_ID] int
, [Comment] nvarchar(1000)
, [Source] nvarchar(150)
, [IsPublic] bit
, [AddedByName] nvarchar(250)
, [AddedOn] datetime
, [ModifiedByName] nvarchar(250)
, [ModifiedOn] datetime
, [IsCall] bit
, ImportanceLevel nvarchar(50)
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
		select @TotalRecords = (@TotalRecords + count(oc.OC_ID)) from [POMS_DB].[dbo].[T_Order_Comments] oc with (nolock) where oc.ORDER_ID = @ORDER_ID and oc.[IsActive] = 1
		and ((oc.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable (OrderID , [OC_ID] , [Comment] , [Source] , [IsPublic] , [AddedByName] , [AddedOn] , [ModifiedByName] , [ModifiedOn] , [IsCall] , ImportanceLevel , TotalRecords)
			select OrderID 
			, [OC_ID] 
			, [Comment]
			, [Source] 
			, [IsPublic] 
			, [AddedByName] 
			, [AddedOn] 
			, [ModifiedByName] 
			, [ModifiedOn] = isnull([ModifiedOn],[AddedOn])
			, [IsCall] 
			, ImportanceLevel 
			, TotalRecords
			from (
				select OrderID = oc.ORDER_ID
					, [OC_ID] = oc.OC_ID
					, [Comment] = oc.[Comment]
					, [Source] = el.[Name]
					, [IsPublic] = oc.[IsPublic]
					, [AddedByName] = afn.FullName
					, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oc.CreatedOn,@TimeZone_ID,null,@TimeZoneName)
					, [ModifiedByName] = mfn.FullName
					, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oc.[ModifiedOn],@TimeZone_ID,null,@TimeZoneName)
					, [IsCall] = oc.[IsCall]
					, ImportanceLevel = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oc.ImportanceLevel_MTV_ID)
					, TotalRecords = @TotalRecords
				from [POMS_DB].[dbo].[T_Order_Comments] oc with (nolock)
				left join [POMS_DB].[dbo].[T_Events_list] el with (nolock) on oc.ShippingStatus_EVENT_ID = el.EVENT_ID
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oc.CreatedBy) afn
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (oc.[ModifiedBy]) mfn
				where oc.ORDER_ID = @ORDER_ID and oc.IsActive = 1
				and ((oc.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)
			) ilv 
		end

		if @GetRecordType_MTV_ID in (147102)
		begin
			Declare @TempTotalRecords int = 0
			select @TempTotalRecords = (@TempTotalRecords + count(oc.OC_ID)) from [POMSArchive_DB].[dbo].[T_Order_Comments] oc with (nolock) where oc.ORDER_ID = @ORDER_ID and oc.[IsActive] = 1
			and ((oc.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)

			if @TempTotalRecords > 0
			begin
				set @TotalRecords = @TotalRecords + @TempTotalRecords
				insert into @ReturnTable (OrderID , [OC_ID] , [Comment] , [Source] , [IsPublic] , [AddedByName] , [AddedOn] , [ModifiedByName] , [ModifiedOn] , [IsCall] , ImportanceLevel , TotalRecords)
				select OrderID 
				, [OC_ID] 
				, [Comment]
				, [Source] 
				, [IsPublic] 
				, [AddedByName] 
				, [AddedOn] 
				, [ModifiedByName] 
				, [ModifiedOn] = isnull([ModifiedOn],[AddedOn])
				, [IsCall] 
				, ImportanceLevel 
				, TotalRecords
				from (
					select OrderID = oc.ORDER_ID
						, [OC_ID] = oc.OC_ID
						, [Comment] = oc.[Comment]
						, [Source] = el.[Name]
						, [IsPublic] = oc.[IsPublic]
						, [AddedByName] = afn.FullName
						, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oc.CreatedOn,@TimeZone_ID,null,@TimeZoneName)
						, [ModifiedByName] = mfn.FullName
						, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oc.[ModifiedOn],@TimeZone_ID,null,@TimeZoneName)
						, [IsCall] = oc.[IsCall]
						, ImportanceLevel = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oc.ImportanceLevel_MTV_ID)
						, TotalRecords = @TotalRecords
					from [POMSArchive_DB].[dbo].[T_Order_Comments] oc with (nolock)
					left join [POMS_DB].[dbo].[T_Events_list] el with (nolock) on oc.ShippingStatus_EVENT_ID = el.EVENT_ID
					outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oc.CreatedBy) afn
					outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (oc.[ModifiedBy]) mfn
					where oc.ORDER_ID = @ORDER_ID and oc.IsActive = 1
					and ((oc.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)
				) ilv
			end
		end
	end
	else if @GetRecordType_MTV_ID in (147101)
	begin
		select @TotalRecords = (@TotalRecords + count(oc.OC_ID)) from [POMSArchive_DB].[dbo].[T_Order_Comments] oc with (nolock) where oc.ORDER_ID = @ORDER_ID and oc.[IsActive] = 1
		and ((oc.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable (OrderID , [OC_ID] , [Comment] , [Source] , [IsPublic] , [AddedByName] , [AddedOn] , [ModifiedByName] , [ModifiedOn] , [IsCall] , ImportanceLevel , TotalRecords)
			select OrderID 
			, [OC_ID] 
			, [Comment]
			, [Source] 
			, [IsPublic] 
			, [AddedByName] 
			, [AddedOn] 
			, [ModifiedByName] 
			, [ModifiedOn] = isnull([ModifiedOn],[AddedOn])
			, [IsCall] 
			, ImportanceLevel 
			, TotalRecords
			from (
				select OrderID = oc.ORDER_ID
					, [OC_ID] = oc.OC_ID
					, [Comment] = oc.[Comment]
					, [Source] = el.[Name]
					, [IsPublic] = oc.[IsPublic]
					, [AddedByName] = afn.FullName
					, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oc.CreatedOn,@TimeZone_ID,null,@TimeZoneName)
					, [ModifiedByName] = mfn.FullName
					, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (oc.[ModifiedOn],@TimeZone_ID,null,@TimeZoneName)
					, [IsCall] = oc.[IsCall]
					, ImportanceLevel = [POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (oc.ImportanceLevel_MTV_ID)
					, TotalRecords = @TotalRecords
				from [POMSArchive_DB].[dbo].[T_Order_Comments] oc with (nolock)
				left join [POMS_DB].[dbo].[T_Events_list] el with (nolock) on oc.ShippingStatus_EVENT_ID = el.EVENT_ID
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (oc.CreatedBy) afn
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (oc.[ModifiedBy]) mfn
				where oc.ORDER_ID = @ORDER_ID and oc.IsActive = 1
				and ((oc.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)
			) ilv
		end
	end

	return
	

end
GO
