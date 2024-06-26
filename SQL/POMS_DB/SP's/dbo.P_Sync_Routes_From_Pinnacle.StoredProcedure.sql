USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sync_Routes_From_Pinnacle]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Sync_Routes_From_Pinnacle]
	
AS
BEGIN
	
	Begin Transaction

	begin try
		Declare @TRRoutetimestamp varbinary(50) = null		Select @TRRoutetimestamp = Max([TimeStamp]) from [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] with (nolock) where TableName = 'TR Routes'
		if @TRRoutetimestamp is null
		begin
			if not exists(select [TimeStamp] from [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] stt with (nolock) where TableName = 'TR Routes')
			begin
				insert into [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] (TableName, [TimeStamp])
				values ('TR Routes', @TRRoutetimestamp)
			end
		end

		drop table if exists #Pinnacle_TRRoutesTable
		select [TimeStamp] = [timestamp]
		,RL_ID = [Route ID]
		,Start_HUB_CODE = rtrim(ltrim(upper([Origin Whse_ Code])))
		,End_HUB_CODE = rtrim(ltrim(upper([Dest_ Whse_ Code])))
		,TransitDays = [Transit Days]
		,Route_MTV_ID = (case when [Route Type] = 1 then 185100 else 185101 end)
		,[Name] = [Route Name]
		,[Description] = null
		--,[Estimated Mileage]
		--,[Blocked]
		--,[Mile Radius]
		,ScheduleType_MTV_ID = (case [Schedule Type] when 1 then 105100
			when 2 then 105101
			when 3 then 105102
			when 4 then 105103
			when 5 then 105104
			when 6 then 105105
			when 7 then 105106
			else 0 end)
		,[DaysofMonth] = [Days of Month]
		,[WeekofMonth] = [Week of Month]
		--,[Density Type]
		,[SpecificDay] = (case when year([Specific Day]) > 2000 and year([Specific Day]) < 2030 then [Specific Day] else null end)
		,AddedOn = [DateAdded]
		,ModifiedOn = (case when year([DateModified]) < 2000 and year([DateDeleted]) < 2000 then null
			when year([DateModified]) < 2000 and year([DateDeleted]) > 2000 then [DateDeleted]
			when year([DateModified]) > 2000 and year([DateDeleted]) < 2000 then [DateModified]
			else null end)
		,IsActive = (case when [Active Status] = 0 or [Blocked] <> 0 then 0 else 1 end)
		--,[Route Type Desc]
		--,[Schedule Type Desc]
		--,[Density Type Desc]
		--,[Route Visual Opacity]
		,[Capacity] = (case when [Capacity] < 10 then 10 else [Capacity] end)
		,AddedBy = isnull((select upper(wul.[Username]) from [MetroPolitanNavProduction].[dbo].[Metropolitan$Web User Login] wul with (nolock) where wul.[Web UserID] = [AddedBy]),'')
		,ModifiedBy = (case when [ModifiedBy] = 0 then null else 
			isnull((select upper([Username]) from [MetroPolitanNavProduction].[dbo].[Metropolitan$Web User Login] wul with (nolock) where wul.[Web UserID] = [ModifiedBy]),'')
			end)
		--,[DateDeleted]
		--,[DeletedBy]
		,AllowAPIScheduling = [Allow API Scheduling]
		,DaysToAppointment = [DaysToAppointment]
		,IsRoundTrip = 0
		into #Pinnacle_TRRoutesTable
		from [PinnacleProd].[dbo].[Metropolitan$TR Routes] tr with (nolock) where [timestamp] >= @TRRoutetimestamp or @TRRoutetimestamp is null

		--	105100 Every Day						105100 Every Day					105103 Specific Week 
		--	105101 Every Week						105101 Every Week					105103 Specific Week 
		--	105102 Specific Week					105103 Specific Date				105103 Specific Week 
		--	105103 Specific Date					105103 Specific Date				105103 Specific Week 
		--	105104 Exception Specific Date			105104 Exception Specific Date		105103 Specific Week
		--	105105 Exception Specific Week			105103 Specific Date				105105 Exception Specific Week
		--	105106 Call Metro (Remote Area)			105103 Specific Date				105103 Specific Week  
		--	105107 Call Metro (3PL/Outsource)		105103 Specific Date				105103 Specific Week

		Declare @TrailerOrderCount float = 20.00
		select @TrailerOrderCount = FullValue_ from [POMS_DB].[dbo].[T_Trailer_Capacity] tc with (nolock) where tc.TL_ID = 1 and tc.DensityType_MTV_CODE = 'ORDER'

		drop table if exists #POMS_RouteTrailerAttached
		select RL_ID 
		,TL_ID = 1
		,TrailerCount = ceiling([Capacity] / @TrailerOrderCount)
		,AddedOn 
		,ModifiedOn 
		,IsActive = 1
		,AddedBy 
		,ModifiedBy 
		into #POMS_RouteTrailerAttached
		from #Pinnacle_TRRoutesTable

		Declare @FMRoutetimestamp varbinary(50) = null		Select @FMRoutetimestamp = Max([TimeStamp]) from [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] with (nolock) where TableName = 'FM Routes'
		if @FMRoutetimestamp is null
		begin
			if not exists(select [TimeStamp] from [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] stt with (nolock) where TableName = 'FM Routes')
			begin
				insert into [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] (TableName, [TimeStamp])
				values ('FM Routes', @FMRoutetimestamp)
			end
		end

		drop table if exists #tZips
		Select ZIP_CODE = z.ZIP_CODE collate Latin1_General_100_CS_AS into #tZips from [POMS_DB].[dbo].[T_Zip_Code_List] z with (nolock)

		drop table if exists #Pinnacle_FMRoutesTable
		select [TimeStamp] = [timestamp]
		,RL_ID_ZIP_CODE = (cast([Route ID] as nvarchar(20)) + rtrim(ltrim([Zip Code])))
		,RL_ID = [Route ID]
		,ZIP_CODE = rtrim(ltrim([Zip Code])) collate SQL_Latin1_General_CP1_CI_AS
		,RowNo = ROW_NUMBER () OVER (PARTITION by [Route ID], [Zip Code] ORDER by [Active Status] desc)
		,AddedOn = [DateAdded]
		,ModifiedOn = null
		,IsActive = [Active Status]
		,AddedBy = isnull((select upper(wul.[Username]) from [MetroPolitanNavProduction].[dbo].[Metropolitan$Web User Login] wul with (nolock) where upper(wul.[Username]) = upper([AddedBy])),'')
		,ModifiedBy = null
		into #Pinnacle_FMRoutesTable
		from [PinnacleProd].[dbo].[Metropolitan$FM Routes] fr with (nolock) 
		inner join #tZips tz on fr.[Zip Code] = tz.ZIP_CODE
		where [timestamp] >= @FMRoutetimestamp or @FMRoutetimestamp is null

		drop table if exists #DuplicatePinnacle_FMRoutesTable
		select * into #DuplicatePinnacle_FMRoutesTable from (
			select RowNo = min(tt.RowNo), RL_ID_ZIP_CODE, tt.[RL_ID], tt.[ZIP_CODE], Count_=count(tt.[ZIP_CODE]) from #Pinnacle_FMRoutesTable tt group by tt.RL_ID_ZIP_CODE, tt.[RL_ID], tt.[ZIP_CODE]
		) A where A.Count_ > 1

		delete t 
		from #Pinnacle_FMRoutesTable t
		inner join #DuplicatePinnacle_FMRoutesTable t1 on t.RL_ID_ZIP_CODE = t1.RL_ID_ZIP_CODE
		where t.RowNo <> (select tt.RowNo from #DuplicatePinnacle_FMRoutesTable tt where tt.RL_ID_ZIP_CODE = t.RL_ID_ZIP_CODE)

		Declare @TRRouteLocktimestamp varbinary(50) = null		Select @TRRouteLocktimestamp = Max([TimeStamp]) from [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] with (nolock) where TableName = 'TR Route Locks'
		if @TRRouteLocktimestamp is null
		begin
			if not exists(select [TimeStamp] from [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] stt with (nolock) where TableName = 'TR Route Locks')
			begin
				insert into [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] (TableName, [TimeStamp])
				values ('TR Route Locks', @TRRouteLocktimestamp)
			end
		end

		drop table if exists #Pinnacle_TRRouteLocksTable
		select [TimeStamp] = trl.[timestamp]
		,RL_ID = [Route ID]
		,LockDateFrom = [Lock From Date]
		,LockDateTo = [Lock Upto Date]
		,LockReleaseDate = [Lock Release Date]
		,LockComment = [Lock Comment]
		,LockReleaseComment = [Lock Release Comment]
		,IsActive = 1
		,AddedBy = isnull((select upper([Username]) from [MetroPolitanNavProduction].[dbo].[Metropolitan$Web User Login] wul with (nolock) where wul.[Web UserID] = [Added By]),'')
		,AddedOn = [Created On]
		,ModifiedBy = (case when [Modified By] = 0 then null else 
			isnull((select upper([Username]) from [MetroPolitanNavProduction].[dbo].[Metropolitan$Web User Login] wul with (nolock) where wul.[Web UserID] = [Modified By]),'')
			end)
		,ModifiedOn = (case when year([Modified On]) > 2000 then [Modified On] else null end)
		into #Pinnacle_TRRouteLocksTable
		from [PinnacleProd].[dbo].[Metropolitan$TR Route Locks] trl with (nolock) 
		inner join #Pinnacle_TRRoutesTable t on trl.[Route ID] = t.RL_ID
		--where trl.[timestamp] >= @TRRouteLocktimestamp or @TRRouteLocktimestamp is null

		MERGE [POMS_DB].[dbo].[T_Route_List] AS Target
			USING #Pinnacle_TRRoutesTable AS Source
			ON Source.[RL_ID] = Target.[RL_ID]
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT (RL_ID ,Start_HUB_CODE ,End_HUB_CODE ,Route_MTV_ID ,[Name] ,[Description] ,[TransitDays] ,[ScheduleType_MTV_ID] ,[IsRoundTrip] ,[AllowAPIScheduling]
				,[DaysToAppointment] ,[IsActive] ,[AddedBy] ,[AddedOn] ,[ModifiedBy] ,[ModifiedOn]) 
				VALUES (Source.RL_ID,Source.Start_HUB_CODE,Source.End_HUB_CODE,Source.Route_MTV_ID,Source.[Name],Source.[Description],Source.[TransitDays],Source.[ScheduleType_MTV_ID]
				,Source.[IsRoundTrip],Source.[AllowAPIScheduling],Source.[DaysToAppointment],Source.[IsActive],Source.[AddedBy],Source.[AddedOn],Source.[ModifiedBy],Source.[ModifiedOn])

			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.Start_HUB_CODE			=	Source.Start_HUB_CODE
				,Target.End_HUB_CODE			=	Source.End_HUB_CODE
				,Target.Route_MTV_ID			=	Source.Route_MTV_ID
				,Target.[Name]					=	Source.[Name]
				,Target.[TransitDays]			=	Source.[TransitDays]
				,Target.[ScheduleType_MTV_ID]	=	Source.[ScheduleType_MTV_ID]
				,Target.[IsRoundTrip]			=	Source.[IsRoundTrip]
				,Target.[AllowAPIScheduling]	=	Source.[AllowAPIScheduling]
				,Target.[DaysToAppointment]		=	Source.[DaysToAppointment]
				,Target.[IsActive]				=	Source.[IsActive]
				,Target.[ModifiedBy]			=	Source.[ModifiedBy]
				,Target.[ModifiedOn]			=	Source.[ModifiedOn];

		delete from [POMS_DB].[dbo].[T_Route_Lock_Dates] where RL_ID in (select t.RL_ID from #Pinnacle_TRRouteLocksTable t)

		MERGE [POMS_DB].[dbo].[T_Route_Lock_Dates] AS Target
			USING #Pinnacle_TRRouteLocksTable AS Source
			ON Source.[RL_ID] = Target.[RL_ID]
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT (RL_ID ,LockDateFrom ,LockDateTo ,LockReleaseDate ,LockComment ,LockReleaseComment ,IsActive ,AddedBy ,AddedOn ,ModifiedBy ,ModifiedOn) 
				VALUES (Source.RL_ID,Source.LockDateFrom,Source.LockDateTo,Source.LockReleaseDate,Source.LockComment,Source.LockReleaseComment,Source.IsActive
				,Source.AddedBy,Source.AddedOn,Source.ModifiedBy,Source.ModifiedOn)

			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.LockDateFrom			=	Source.LockDateFrom
				,Target.LockDateTo			=	Source.LockDateTo
				,Target.LockReleaseDate		=	Source.LockReleaseDate
				,Target.LockComment			=	Source.LockComment
				,Target.LockReleaseComment	=	Source.LockReleaseComment
				,Target.IsActive			=	Source.IsActive
				,Target.ModifiedBy			=	Source.ModifiedBy
				,Target.ModifiedOn			=	Source.ModifiedOn;

		MERGE [POMS_DB].[dbo].[T_Route_Trailer_Attached] AS Target
			USING #POMS_RouteTrailerAttached AS Source
			ON Source.[RL_ID] = Target.[RL_ID]
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT (RL_ID ,TL_ID ,TrailerCount ,IsActive ,AddedBy ,AddedOn ,ModifiedBy ,ModifiedOn) 
				VALUES (Source.RL_ID,Source.TL_ID,Source.TrailerCount,Source.IsActive,Source.AddedBy,Source.AddedOn,Source.ModifiedBy,Source.ModifiedOn)
			
			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.TL_ID			=	Source.TL_ID
				,Target.TrailerCount	=	Source.TrailerCount
				,Target.IsActive		=	Source.IsActive
				,Target.AddedBy			=	Source.AddedBy
				,Target.AddedOn			=	Source.AddedOn
				,Target.ModifiedBy		=	Source.ModifiedBy
				,Target.ModifiedOn		=	Source.ModifiedOn;

		drop table if exists #POMS_RouteTrailerSchedule
		select A.RL_ID 
			,RTA_ID = rta.RTA_ID
			,A.TL_ID
			,A.TypeofMonth_MTV_CODE
			,A.SubTypeofMonth_MTV_CODE
			,A.SpecificDate
			,A.AddedOn 
			,A.ModifiedOn 
			,A.IsActive
			,A.AddedBy 
			,A.ModifiedBy  
			into #POMS_RouteTrailerSchedule from (
			select trt.RL_ID 
			,TL_ID = 1
			,TypeofMonth_MTV_CODE = 'DAYS'
			,SubTypeofMonth_MTV_CODE = mtv.MTV_CODE
			,SpecificDate = null
			,trt.AddedOn 
			,trt.ModifiedOn 
			,IsActive = 1
			,trt.AddedBy 
			,trt.ModifiedBy 
			from #Pinnacle_TRRoutesTable trt 
			cross apply [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock)
			where trt.ScheduleType_MTV_ID = 105100 and mtv.MT_ID = 189 and mtv.Sub_MTV_ID = 188100

			union

			select trt.RL_ID 
			,TL_ID = 1
			,TypeofMonth_MTV_CODE = 'DAYS'
			,SubTypeofMonth_MTV_CODE = rtrim(ltrim(upper(sit.id)))
			,SpecificDate = null
			,trt.AddedOn 
			,trt.ModifiedOn 
			,IsActive = 1
			,trt.AddedBy 
			,trt.ModifiedBy 
			from #Pinnacle_TRRoutesTable trt 
			cross apply [POMS_DB].[dbo].[SplitIntoTable] (trt.[DaysofMonth]) sit 
			where trt.ScheduleType_MTV_ID = 105100 

			union

			select trt.RL_ID 
			,TL_ID = 1
			,TypeofMonth_MTV_CODE = 'WEEKS'
			,SubTypeofMonth_MTV_CODE = mtv.MTV_CODE
			,SpecificDate = null
			,trt.AddedOn 
			,trt.ModifiedOn 
			,IsActive = 1
			,trt.AddedBy 
			,trt.ModifiedBy 
			from #Pinnacle_TRRoutesTable trt 
			cross apply [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock)
			where trt.ScheduleType_MTV_ID = 105101 and mtv.MT_ID = 189 and mtv.Sub_MTV_ID = 188101

			union

			select trt.RL_ID 
			,TL_ID = 1
			,TypeofMonth_MTV_CODE = 'DAYS'
			,SubTypeofMonth_MTV_CODE = rtrim(ltrim(upper(sit.id)))
			,SpecificDate = null
			,trt.AddedOn 
			,trt.ModifiedOn 
			,IsActive = 1
			,trt.AddedBy 
			,trt.ModifiedBy 
			from #Pinnacle_TRRoutesTable trt 
			cross apply [POMS_DB].[dbo].[SplitIntoTable] (trt.[DaysofMonth]) sit 
			where trt.ScheduleType_MTV_ID = 105101

			union

			select trt.RL_ID 
			,TL_ID = 1
			,TypeofMonth_MTV_CODE = 'WEEKS'
			,SubTypeofMonth_MTV_CODE = rtrim(ltrim(upper(sit.id)))
			,SpecificDate = null
			,trt.AddedOn 
			,trt.ModifiedOn 
			,IsActive = 1
			,trt.AddedBy 
			,trt.ModifiedBy 
			from #Pinnacle_TRRoutesTable trt 
			cross apply [POMS_DB].[dbo].[SplitIntoTable] (trt.[WeekofMonth]) sit 
			where trt.ScheduleType_MTV_ID = 105102
			
			union

			select trt.RL_ID 
			,TL_ID = 1
			,TypeofMonth_MTV_CODE = 'DAYS'
			,SubTypeofMonth_MTV_CODE = rtrim(ltrim(upper(sit.id)))
			,SpecificDate = null
			,trt.AddedOn 
			,trt.ModifiedOn 
			,IsActive = 1
			,trt.AddedBy 
			,trt.ModifiedBy 
			from #Pinnacle_TRRoutesTable trt 
			cross apply [POMS_DB].[dbo].[SplitIntoTable] (trt.[DaysofMonth]) sit 
			where trt.ScheduleType_MTV_ID = 105102

			union

			select trt.RL_ID 
			,TL_ID = 1
			,TypeofMonth_MTV_CODE = 'SPECIFIC-DAY'
			,SubTypeofMonth_MTV_CODE = 'SPECIFIC-DATE'
			,SpecificDate = trt.[SpecificDay]
			,trt.AddedOn 
			,trt.ModifiedOn 
			,IsActive = 1
			,trt.AddedBy 
			,trt.ModifiedBy 
			from #Pinnacle_TRRoutesTable trt where trt.ScheduleType_MTV_ID = 105103 and trt.[SpecificDay] is not null
		) A left join [POMS_DB].[dbo].[T_Route_Trailer_Attached] rta with (nolock) on rta.RL_ID = A.RL_ID and rta.TL_ID = A.TL_ID

		drop table if exists #tRTAIDs
		select * into #tRTAIDs from (
			--select rta.RTA_ID from [POMS_DB].[dbo].[T_Route_Trailer_Attached] rta with (nolock) where rta.RL_ID in (select trt.RL_ID from #Pinnacle_TRRoutesTable trt)
			--union
			select rta.RTA_ID from [POMS_DB].[dbo].[T_Route_Trailer_Attached] rta with (nolock) where rta.RL_ID not in (select trt.RL_ID from #Pinnacle_TRRoutesTable trt)
		) A

		MERGE [POMS_DB].[dbo].[T_Route_Trailer_Schedule] AS Target
			USING #POMS_RouteTrailerSchedule AS Source
			ON Source.[RTA_ID] = Target.[RTA_ID] 
				and Source.TypeofMonth_MTV_CODE = Target.TypeofMonth_MTV_CODE 
				and isnull(Source.SubTypeofMonth_MTV_CODE,'') = isnull(Target.SubTypeofMonth_MTV_CODE,'') and isnull(Source.SubTypeofMonth_MTV_CODE,'') <> ''
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT (RTA_ID ,TypeofMonth_MTV_CODE ,SubTypeofMonth_MTV_CODE ,SpecificDate ,IsActive ,AddedBy ,AddedOn ,ModifiedBy ,ModifiedOn) 
				VALUES (Source.RTA_ID,Source.TypeofMonth_MTV_CODE,Source.SubTypeofMonth_MTV_CODE,Source.SpecificDate,Source.IsActive,Source.AddedBy,Source.AddedOn,Source.ModifiedBy,Source.ModifiedOn)
			
			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.TypeofMonth_MTV_CODE		=	Source.TypeofMonth_MTV_CODE
				,Target.SubTypeofMonth_MTV_CODE	=	Source.SubTypeofMonth_MTV_CODE
				,Target.SpecificDate			=	Source.SpecificDate
				,Target.IsActive				=	Source.IsActive
				,Target.ModifiedBy				=	Source.ModifiedBy
				,Target.ModifiedOn				=	Source.ModifiedOn;
			
			--WHEN NOT MATCHED BY SOURCE AND target.RTA_ID NOT IN (SELECT t.RTA_ID FROM #tRTAIDs t) THEN
			--	DELETE;

		MERGE [POMS_DB].[dbo].[T_Route_Zips] AS Target
			USING #Pinnacle_FMRoutesTable AS Source
			ON Source.RL_ID = Target.RL_ID and Source.ZIP_CODE = Target.ZIP_CODE collate database_default
    
			-- For Inserts
			WHEN NOT MATCHED BY Target THEN
				INSERT (RL_ID ,ZIP_CODE ,IsActive ,AddedBy ,AddedOn ,ModifiedBy ,ModifiedOn) 
				VALUES (Source.RL_ID,Source.ZIP_CODE,Source.IsActive, Source.AddedBy, Source.AddedOn, Source.ModifiedBy, Source.ModifiedOn)
			
			-- For Updates
			WHEN MATCHED THEN 
				UPDATE SET
				Target.IsActive			=	Source.IsActive
				,Target.ModifiedBy		=	Source.ModifiedBy
				,Target.ModifiedOn		=	Source.ModifiedOn;
			
			--WHEN NOT MATCHED BY SOURCE AND target.RT_ID IN (SELECT t.RT_ID FROM #Pinnacle_FMRoutesTable t) THEN
			--	DELETE;

		Select @TRRoutetimestamp = Max([TimeStamp]) from #Pinnacle_TRRoutesTable		update [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] set [TimeStamp] = @TRRoutetimestamp where TableName = 'TR Routes' and @TRRoutetimestamp is not null

		Select @FMRoutetimestamp = Max([TimeStamp]) from #Pinnacle_FMRoutesTable		update [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] set [TimeStamp] = @FMRoutetimestamp where TableName = 'FM Routes' and @FMRoutetimestamp is not null

		Select @TRRouteLocktimestamp = Max([TimeStamp]) from #Pinnacle_TRRouteLocksTable		update [POMS_DB].[dbo].[T_Sync_Table_TimeStamp] set [TimeStamp] = @TRRouteLocktimestamp where TableName = 'FM Route Locks' and @TRRouteLocktimestamp is not null
		
		if @@TRANCOUNT > 0
		begin
			COMMIT; 
		end
	end try
	begin catch
		if @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		print ERROR_MESSAGE()
	end catch

END
GO
