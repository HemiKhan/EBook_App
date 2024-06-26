USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ApplicationBuilds_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_ApplicationBuilds_List] 'Ihtisham', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_ApplicationBuilds_List] 
	-- Add the parameters for the stored procedure here
	@Username nvarchar(150),
	 @pageIndex int,  
	 @pageSize int,  
	 @sortExpression nvarchar(max),  
	 @filterClause nvarchar(max),  
	 @totalRowCount int OUTPUT,
	 @Offset int = -14400000,
	 @TimeZoneID int = 0,
	 @filterobject nvarchar(max) = '',
	 @columnobject nvarchar(max) = ''
	
AS
BEGIN
	
	IF(@filterClause = '' OR @filterClause = null)  
	BEGIN SET @filterClause = ' AND 1=1' END 

	IF(@pageIndex = null)  
	BEGIN SET @pageIndex = 0 END  
  
	IF(@pageSize = null)  
	BEGIN SET @pageSize = 0 END  

	Declare @SetTop int = 30
	SET @SetTop = (@pageindex + 1) * @pagesize

	IF(@Offset = null)  
	BEGIN SET @Offset = 0 END

	IF len(@sortExpression) = 0  
	SET @sortExpression = ' AB_ID ASC '  
	ELSE
	SET @sortExpression = @sortExpression + ' '

	DROP TABLE IF exists #Table_Fields_Filter
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@filterobject)

	DROP TABLE IF exists #Table_Fields_Column
	CREATE TABLE #Table_Fields_Column (code nvarchar(150) ,name_ nvarchar(150) ,iscolumnrequired bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@columnobject)

	Declare @HideField nvarchar(50) = ',hidefield=0'

   ---- Start Set Filter Variables
  Declare @BUILDCODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'BUILDCODE') then 1 else 0 end)
  Declare @BuildName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'BuildName') then 1 else 0 end) 
  Declare @Application_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application') then 1 else 0 end)  
  Declare @Description_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Description') then 1 else 0 end)  
  Declare @ScheduleDate_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ScheduleDate') then 1 else 0 end)    
  Declare @Status_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Status') then 1 else 0 end)  
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
   
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @BuildName_Req bit = (case when @BuildName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'BuildName') then 0 else 1 end)
  Declare @Description_Req bit = (case when @Description_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Description') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  Declare @Application_Req bit = (case when @Application_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application') then 0 else 1 end)
  Declare @ScheduleDate_Req bit = (case when @ScheduleDate_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ScheduleDate') then 0 else 1 end)
  Declare @Status_Req bit = (case when @Status_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Status') then 0 else 1 end)
  Declare @BUILDCODE_Req bit = (case when @BUILDCODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'BUILDCODE') then 0 else 1 end)
   
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT ab.AB_ID,ab.Status_MTV_CODE,ab.Application_MTV_ID'
    + char(10) + (case when @BUILDCODE_Filtered = 1 then '' else @HideField end) + ',BUILDCODE=ab.BUILDCODE'
    + char(10) + (case when @BuildName_Filtered = 1 then '' else @HideField end) + ',ab.BuildName'
    + char(10) + (case when @Description_Filtered = 1 then '' else @HideField end) + ',ab.Description'
    + char(10) + (case when @Application_Filtered = 1 then '' else @HideField end) + ',Application=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](ab.Application_MTV_ID)'
    + char(10) + (case when @ScheduleDate_Filtered = 1 then '' else @HideField end) + ',ScheduleDate=FORMAT(ab.ScheduleDate, ''MM/dd/yyyy'')'
    + char(10) + (case when @Status_Filtered = 1 then '' else @HideField end) + ',Status=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE](ab.Status_MTV_CODE)'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = ab.IsActive
    FROM [POMS_DB].[dbo].[T_Application_Builds] ab WITH (NOLOCK)'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END

 
GO
