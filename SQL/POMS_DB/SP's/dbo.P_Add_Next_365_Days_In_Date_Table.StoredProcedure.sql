USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Add_Next_365_Days_In_Date_Table]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Add_Next_365_Days_In_Date_Table]
	
AS
BEGIN
	
	Declare @MinDate date
	Declare @CurrentDate date
	select @MinDate = min([Date]), @CurrentDate = dateadd(day,1,max([Date])) from [POMS_DB].[dbo].[T_Dates] d with (nolock)
	Declare @StartDate date = dateadd(day,-400,getutcdate());
	Declare @EndDate date = dateadd(day,365,getutcdate());
	select @CurrentDate = ISNULL(@CurrentDate,@StartDate), @MinDate = isnull(@MinDate,getutcdate())

	drop table if exists #Dates;
	WITH DateRange AS (
	  SELECT @CurrentDate AS [Date] where @CurrentDate <= @EndDate
	  UNION ALL
	  SELECT DATEADD(DAY, 1, [Date])
	  FROM DateRange
	  WHERE [Date] < @EndDate
	)
	SELECT [Date]
	, [Day] = upper(format([Date],'ddddd'))
	, [Week] = 'WEEK' + cast(((DATEPART(DAY, [Date]) - 1) / 7 + 1) as nvarchar(10))
	, [Month] = format([Date],'MMMMM')
	, [Year] = DATEPART(year, [Date])
	, [DateNum] = DATEPART(day, [Date])
	, [DayNum] = DATEPART(WEEKDAY, [Date])
    , [WeekNum] = ((DATEPART(DAY, [Date]) - 1) / 7 + 1)
	, [MonthNum] = month([Date])
	into #Dates
	FROM DateRange
	OPTION (MAXRECURSION 0);

	insert into [POMS_DB].[dbo].[T_Dates] ([Date] ,[Day] ,[Week] ,[Month] ,[Year] ,[DateNum] ,[DayNum] ,[WeekNum] ,[MonthNum])
	select [Date] ,[Day] ,[Week] ,[Month] ,[Year] ,[DateNum] ,[DayNum] ,[WeekNum] ,[MonthNum] from #Dates

	if @MinDate < @StartDate
	begin
		delete from [POMS_DB].[dbo].[T_Dates] where [Date] < @StartDate
	end

END
GO
