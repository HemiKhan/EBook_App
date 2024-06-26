USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Next_Date_From_Month_Day_And_Code]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select [POMS_DB].[dbo].[F_Get_Next_Date_From_Month_Day_And_Code] ('2024-04-16',1,1,'FIXED',0,0)
-- select [POMS_DB].[dbo].[F_Get_Next_Date_From_Month_Day_And_Code] ('2024-04-16',5,2,'LAST',0,0)
-- select [POMS_DB].[dbo].[F_Get_Next_Date_From_Month_Day_And_Code] ('2024-04-16',7,4,'FIXED',0,0)
-- select [POMS_DB].[dbo].[F_Get_Next_Date_From_Month_Day_And_Code] ('2024-04-16',9,2,'FIRST',0,0)
-- select [POMS_DB].[dbo].[F_Get_Next_Date_From_Month_Day_And_Code] ('2024-04-16',11,5,'FOURTH',0,0)
-- select [POMS_DB].[dbo].[F_Get_Next_Date_From_Month_Day_And_Code] ('2024-04-16',12,25,'FIXED',0,0)

CREATE FUNCTION [dbo].[F_Get_Next_Date_From_Month_Day_And_Code]
(
	@CurrentDate date
	,@Month smallint
	,@Day smallint --(1 = Sunday, 2 = Monday, ..., 7 = Saturday) Day in case of Code is FIXED else weekday
	,@Code nvarchar(20)
	,@IsSaturdayInclude bit = 0
	,@IsSundayInclude bit = 0
)
RETURNS date
AS
BEGIN
	-- Declare the return variable here
	DECLARE @TargetDate DATE = null

	set @CurrentDate = isnull(@CurrentDate,getutcdate())
	set @Code = upper(@Code)

	DECLARE @FirstDayOfMonth DATE = DATEFROMPARTS(YEAR(@CurrentDate), @Month, 1);
	
	IF @Code = 'LAST'
	BEGIN
		SET @TargetDate = DATEADD(DAY, -1, DATEADD(MONTH, 1, @FirstDayOfMonth));
		WHILE DATEPART(WEEKDAY, @TargetDate) <> @Day 
		BEGIN
			SET @TargetDate = DATEADD(DAY, -1, @TargetDate);
		END
	END
	ELSE IF @Code = 'FIXED'
	BEGIN
		SET @TargetDate = DATEFROMPARTS(YEAR(@CurrentDate), @Month, @Day);
	END
	ELSE
	BEGIN
		DECLARE @Occurrence INT;
		IF @Code = 'FIRST'
			SET @Occurrence = 1;
		ELSE IF @Code = 'SECOND'
			SET @Occurrence = 2;
		ELSE IF @Code = 'THIRD'
			SET @Occurrence = 3;
		ELSE IF @Code = 'FOURTH'
			SET @Occurrence = 4;
		ELSE IF @Code = 'FIFTH'
			SET @Occurrence = 5;

		SET @TargetDate = DATEADD(DAY, (@Occurrence - 1) * 7, @FirstDayOfMonth);
		WHILE DATEPART(WEEKDAY, @TargetDate) <> @Day 
		BEGIN
			SET @TargetDate = DATEADD(DAY, 1, @TargetDate);
		END

		-- Check if the fifth occurrence exists, if not, use the fourth occurrence
		IF @Occurrence = 5 AND MONTH(@TargetDate) <> @Month
		BEGIN
			SET @Occurrence = 4;
			SET @TargetDate = DATEADD(DAY, (@Occurrence - 1) * 7, @FirstDayOfMonth);
			WHILE DATEPART(WEEKDAY, @TargetDate) <> @Day 
			BEGIN
				SET @TargetDate = DATEADD(DAY, 1, @TargetDate);
			END
		END
	END

	if DATEPART(WEEKDAY, @TargetDate) = 7
	begin
		set @TargetDate = dateadd(day,1,@TargetDate)
	end
	if DATEPART(WEEKDAY, @TargetDate) = 1
	begin
		set @TargetDate = dateadd(day,1,@TargetDate)
	end

	if (@TargetDate < @CurrentDate)
	begin
		set @CurrentDate = DATEFROMPARTS(YEAR(@CurrentDate) + 1, 1, 1)
		set @TargetDate = [POMS_DB].[dbo].[F_Get_Next_Date_From_Month_Day_And_Code] (@CurrentDate ,@Month ,@Day ,@Code ,@IsSaturdayInclude ,@IsSundayInclude)
	end

	return @TargetDate

end

GO
