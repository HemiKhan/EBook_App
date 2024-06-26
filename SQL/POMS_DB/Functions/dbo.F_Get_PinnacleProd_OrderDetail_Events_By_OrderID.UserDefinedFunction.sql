USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PinnacleProd_OrderDetail_Events_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_PinnacleProd_OrderDetail_Events_By_OrderID] (3652511,'ABDULLAH.ARSHAD','METRO-USER',1,13,147103)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_PinnacleProd_OrderDetail_Events_By_OrderID]
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

	Declare @ORDER_NO nvarchar(20) = cast(@ORDER_ID as nvarchar(20))

	if @GetRecordType_MTV_ID in (147103,147105)
	begin
		select @TotalRecords = (@TotalRecords + count(ordEvnt.ID)) from [PinnacleProd].[dbo].[Metropolitan$Event Master Log] ordEvnt with (nolock)
		Left join [PinnacleProd].[dbo].[Metropolitan$Event Master] EveMas with (nolock) on EveMas.[Entry No] = ordEvnt.[EventID]
		Where ordEvnt.[Order Number]= @ORDER_NO and EveMas.[Active] = 1 and ((EveMas.[Public  (Pinnacle)] = 1 and  @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [EL_ID] , [Activity] , [Event] , [Date] , [Trigger] , [Location] , [InitiatedBy] , TotalRecords)
			select OrderID = @ORDER_ID
				,[EL_ID] = ordEvnt.ID
				,[Activity] = (select mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID]=10320 and mtv.[ID] = EveMas.[Metro Activity Code])
				,[Event] = EveMas.[Events]
				,[Date]= [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ordEvnt.[Created On],@TimeZone_ID,null,@TimeZoneName)
				,[Trigger]=(select mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID]=10310 and mtv.[ID] = EveMas.[Event Trigger])
				,[Location]= isnull(ordEvnt.[City] + ', ', '') + isnull(ordEvnt.[State], '')
				,[InitiatedBy]= afn.FullName
				,TotalRecords = @TotalRecords
			from [PinnacleProd].[dbo].[Metropolitan$Event Master Log] ordEvnt with (nolock)
			Left join [PinnacleProd].[dbo].[Metropolitan$Event Master] EveMas with (nolock) on EveMas.[Entry No] = ordEvnt.[EventID]
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (ordEvnt.[Created By]) afn
			Where ordEvnt.[Order Number]= @ORDER_NO and EveMas.[Active] = 1 and ((EveMas.[Public  (Pinnacle)] = 1 and  @IsPublic = 0) or @IsPublic = 1)
		end

		if @GetRecordType_MTV_ID in (147105)
		begin
			Declare @TempTotalRecords int = 0
			select @TempTotalRecords = (@TempTotalRecords + count(ordEvnt.ID)) from [PinnacleArchiveDB].[dbo].[Metropolitan$Event Master Log] ordEvnt with (nolock)
			Left join [PinnacleProd].[dbo].[Metropolitan$Event Master] EveMas with (nolock) on EveMas.[Entry No] = ordEvnt.[EventID]
			Where ordEvnt.[Order Number]= @ORDER_NO and EveMas.[Active] = 1 and ((EveMas.[Public  (Pinnacle)] = 1 and  @IsPublic = 0) or @IsPublic = 1)

			if @TempTotalRecords > 0
			begin
				set @TotalRecords = @TotalRecords + @TempTotalRecords
				insert into @ReturnTable ([OrderID] , [EL_ID] , [Activity] , [Event] , [Date] , [Trigger] , [Location] , [InitiatedBy] , TotalRecords)
				select OrderID = @ORDER_ID
					,[EL_ID] = ordEvnt.ID
					,[Activity] = (select mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID]=10320 and mtv.[ID] = EveMas.[Metro Activity Code])
					,[Event] = EveMas.[Events]
					,[Date]= [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ordEvnt.[Created On],@TimeZone_ID,null,@TimeZoneName)
					,[Trigger]=(select mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID]=10310 and mtv.[ID] = EveMas.[Event Trigger])
					,[Location]= ''
					,[InitiatedBy]= afn.FullName
					,TotalRecords = @TotalRecords
				from [PinnacleArchiveDB].[dbo].[Metropolitan$Event Master Log] ordEvnt with (nolock)
				Left join [PinnacleProd].[dbo].[Metropolitan$Event Master] EveMas with (nolock) on EveMas.[Entry No] = ordEvnt.[EventID]
				outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (ordEvnt.[Created By]) afn
				Where ordEvnt.[Order Number]= @ORDER_NO and EveMas.[Active] = 1 and ((EveMas.[Public  (Pinnacle)] = 1 and  @IsPublic = 0) or @IsPublic = 1)
			end
		end
	end
	else if @GetRecordType_MTV_ID in (147104)
	begin
		select @TotalRecords = (@TotalRecords + count(ordEvnt.ID)) from [PinnacleArchiveDB].[dbo].[Metropolitan$Event Master Log] ordEvnt with (nolock)
		Left join [PinnacleProd].[dbo].[Metropolitan$Event Master] EveMas with (nolock) on EveMas.[Entry No] = ordEvnt.[EventID]
		Where ordEvnt.[Order Number]= @ORDER_NO and EveMas.[Active] = 1 and ((EveMas.[Public  (Pinnacle)] = 1 and  @IsPublic = 0) or @IsPublic = 1)

		if @TotalRecords > 0
		begin
			insert into @ReturnTable ([OrderID] , [EL_ID] , [Activity] , [Event] , [Date] , [Trigger] , [Location] , [InitiatedBy] , TotalRecords)
			select OrderID = @ORDER_ID
				,[EL_ID] = ordEvnt.ID
				,[Activity] = (select mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID]=10320 and mtv.[ID] = EveMas.[Metro Activity Code])
				,[Event] = EveMas.[Events]
				,[Date]= [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (ordEvnt.[Created On],@TimeZone_ID,null,@TimeZoneName)
				,[Trigger]=(select mtv.[Description] from [PinnacleProd].[dbo].[Metropolitan$Master Type Value] mtv with (nolock) where mtv.[Master Type ID]=10310 and mtv.[ID] = EveMas.[Event Trigger])
				,[Location]= ''
				,[InitiatedBy]= afn.FullName
				,TotalRecords = @TotalRecords
			from [PinnacleArchiveDB].[dbo].[Metropolitan$Event Master Log] ordEvnt with (nolock)
			Left join [PinnacleProd].[dbo].[Metropolitan$Event Master] EveMas with (nolock) on EveMas.[Entry No] = ordEvnt.[EventID]
			outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (ordEvnt.[Created By]) afn
			Where ordEvnt.[Order Number]= @ORDER_NO and EveMas.[Active] = 1 and ((EveMas.[Public  (Pinnacle)] = 1 and  @IsPublic = 0) or @IsPublic = 1)
		end
	end

	return
	

end
GO
