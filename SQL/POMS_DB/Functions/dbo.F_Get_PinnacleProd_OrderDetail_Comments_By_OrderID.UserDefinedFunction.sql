USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_Comments_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_Comments_By_OrderID] (3652511,'ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_Comments_By_OrderID]
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

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	if @GetRecordType_MTV_ID in (147103,147105)
	begin
		select @TotalRecords = (@TotalRecords + count(cm.[ID])) from [PinnacleProd].[dbo].[Metropolitan$Comments] cm with (nolock) where cm.[Order ID] = @ORDER_NO and cm.[Active Status] = 1 and cm.[Comment] != '' 
		and ((cm.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)

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
				select OrderID = @ORDER_ID
					, [OC_ID] = cm.[ID]
					, [Comment]= cm.[Comment]
					, [Source] = em.[Events]
					, [IsPublic] = cm.[IsPublic]
					, [AddedByName] = afn.FullName
					, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (cm.[Created On],@TimeZone_ID,null,@TimeZoneName)
					, [ModifiedByName] = mfn.FullName
					, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (cm.[Modified On],@TimeZone_ID,null,@TimeZoneName)
					, [IsCall] = cm.[Is Call]
					, ImportanceLevel = ''
					, TotalRecords = @TotalRecords
				from [PinnacleProd].[dbo].[Metropolitan$Comments] cm with (nolock)
				left join [PinnacleProd].[dbo].[Metropolitan$Event Master] em with (nolock) on cm.[Shipping Status] = em.[Entry No]
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (cm.[Created By]) afn
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (cm.[Modified By]) mfn
				where cm.[Order ID] = @ORDER_NO and cm.[Active Status] = 1 and cm.[Comment] != ''
				and ((cm.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)
			) ilv
		end

		if @GetRecordType_MTV_ID in (147105)
		begin
			Declare @TempTotalRecords int = 0
			select @TempTotalRecords = (@TempTotalRecords + count(cm.[ID])) from [PinnacleArchiveDB].[dbo].[Metropolitan$Comments] cm with (nolock) where cm.[Order ID] = @ORDER_NO and cm.[Active Status] = 1 and cm.[Comment] != '' 
			and ((cm.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)

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
					select OrderID = @ORDER_ID
						, [OC_ID] = cm.[ID]
						, [Comment]= cm.[Comment]
						, [Source] = em.[Events]
						, [IsPublic] = cm.[IsPublic]
						, [AddedByName] = afn.FullName
						, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (cm.[Created On],@TimeZone_ID,null,@TimeZoneName)
						, [ModifiedByName] = mfn.FullName
						, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (cm.[Modified On],@TimeZone_ID,null,@TimeZoneName)
						, [IsCall] = cm.[Is Call]
						, ImportanceLevel = ''
						, TotalRecords = @TotalRecords
					from [PinnacleArchiveDB].[dbo].[Metropolitan$Comments] cm with (nolock)
					left join [PinnacleProd].[dbo].[Metropolitan$Event Master] em with (nolock) on cm.[Shipping Status] = em.[Entry No]
					outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (cm.[Created By]) afn
					outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (cm.[Modified By]) mfn
					where cm.[Order ID] = @ORDER_NO and cm.[Active Status] = 1 and cm.[Comment] != ''
					and ((cm.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)
				) ilv
			end
		end
	end
	else if @GetRecordType_MTV_ID in (147104)
	begin
		select @TotalRecords = (@TotalRecords + count(cm.[ID])) from [PinnacleArchiveDB].[dbo].[Metropolitan$Comments] cm with (nolock) where cm.[Order ID] = @ORDER_NO and cm.[Active Status] = 1 and cm.[Comment] != '' 
		and ((cm.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)

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
				select OrderID = @ORDER_ID
					, [OC_ID] = cm.[ID]
					, [Comment]= cm.[Comment]
					, [Source] = em.[Events]
					, [IsPublic] = cm.[IsPublic]
					, [AddedByName] = afn.FullName
					, [AddedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (cm.[Created On],@TimeZone_ID,null,@TimeZoneName)
					, [ModifiedByName] = mfn.FullName
					, [ModifiedOn] = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (cm.[Modified On],@TimeZone_ID,null,@TimeZoneName)
					, [IsCall] = cm.[Is Call]
					, ImportanceLevel = ''
					, TotalRecords = @TotalRecords
				from [PinnacleArchiveDB].[dbo].[Metropolitan$Comments] cm with (nolock)
				left join [PinnacleProd].[dbo].[Metropolitan$Event Master] em with (nolock) on cm.[Shipping Status] = em.[Entry No]
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (cm.[Created By]) afn
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (cm.[Modified By]) mfn
				where cm.[Order ID] = @ORDER_NO and cm.[Active Status] = 1 and cm.[Comment] != ''
				and ((cm.IsPublic = 1 and @IsPublic = 0) or @IsPublic = 1)
			) ilv
		end
	end

	return
	

end
GO
