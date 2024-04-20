USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Next_Dates_From_Month_Day_And_Code]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Next_Dates_From_Month_Day_And_Code] (null)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Next_Dates_From_Month_Day_And_Code]
(	
	@CurrentDate date
)
RETURNS @ReturnTable TABLE 
(HM_ID int 
,[Date] date
)
AS
begin
	
	set @CurrentDate = ISNULL(@CurrentDate,getutcdate())

	Declare @tmp table
	(ID int identity(1,1)
	,[HM_ID] int
	,[Name] nvarchar(150)
	,[Month] smallint
	,[Day] smallint
	,[DayofMonth_MTV_CODE] nvarchar(20)
	,[IsSaturdayInclude] bit
	,[IsSundayInclude] bit)

	insert into @tmp ([HM_ID] ,[Name] ,[Month] ,[Day] ,[DayofMonth_MTV_CODE] ,[IsSaturdayInclude] ,[IsSundayInclude])
	select [HM_ID] ,[Name] ,[Month] ,[Day] ,[DayofMonth_MTV_CODE] ,[IsSaturdayInclude] ,[IsSundayInclude] 
	from [POMS_DB].[dbo].[T_Holiday_Master] hm with (nolock) where hm.IsActive = 1

	Declare @HM_ID int = 0
	Declare @Name nvarchar(150) = ''
	Declare @Month smallint = 0
	Declare @Day smallint = 0
	Declare @DayofMonth_MTV_CODE nvarchar(20) = ''
	Declare @IsSaturdayInclude bit = 0
	Declare @IsSundayInclude bit = 0
	Declare @Date date = null
	
	Declare @TryCount int = 1
	Declare @MaxCount int = 0
	select @MaxCount = max(ID) from @tmp
	set @MaxCount = isnull(@MaxCount,0)

	WHILE @TryCount <= @MaxCount
	BEGIN
		select @HM_ID = HM_ID ,@Name = [Name] ,@Month = [Month] ,@Day = [Day] ,@DayofMonth_MTV_CODE = DayofMonth_MTV_CODE ,@IsSaturdayInclude = IsSaturdayInclude ,@IsSundayInclude = IsSundayInclude from @tmp where ID = @TryCount
		select @Date = [POMS_DB].[dbo].[F_Get_Next_Date_From_Month_Day_And_Code] (@Currentdate,@Month,@Day,@DayofMonth_MTV_CODE,@IsSaturdayInclude,@IsSundayInclude)
		insert into @ReturnTable (HM_ID, [Date])
		values (@HM_ID,@Date)
		set @TryCount = @TryCount + 1
	END

	return

end
GO
