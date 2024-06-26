USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TimeZone_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_TimeZone_List] 'Ihtisham.Ulhaq', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

Create PROCEDURE [dbo].[P_Get_TimeZone_List] 
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
	SET @sortExpression = ' TIMEZONE_ID asc '  
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
  
 Declare @TimeZoneDisplay_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TimeZoneDisplay') then 1 else 0 end)
Declare @TimeZoneName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TimeZoneName') then 1 else 0 end)
Declare @Offset_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Offset') then 1 else 0 end)
Declare @UTCOffset_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UTCOffset') then 1 else 0 end)
Declare @TimeZoneFullDispaly_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TimeZoneFullDispaly') then 1 else 0 end)
Declare @TimeZoneAbbreviation_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TimeZoneAbbreviation') then 1 else 0 end)
Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
 

  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @TimeZoneDisplay_Req bit = (case when @TimeZoneDisplay_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TimeZoneDisplay') then 0 else 1 end)
Declare @TimeZoneName_Req bit = (case when @TimeZoneName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TimeZoneName') then 0 else 1 end)
Declare @Offset_Req bit = (case when @Offset_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Offset') then 0 else 1 end)
Declare @UTCOffse_Req bit = (case when @UTCOffset_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UTCOffset') then 0 else 1 end)
Declare @TimeZoneFullDispaly_Req bit = (case when @TimeZoneFullDispaly_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TimeZoneFullDispaly') then 0 else 1 end)
Declare @TimeZoneAbbreviation_Req bit = (case when @TimeZoneAbbreviation_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TimeZoneAbbreviation') then 0 else 1 end)
 Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)

  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT TIMEZONE_ID'
	+ char(10) + (case when @TimeZoneDisplay_Filtered = 1 then '' else @HideField end) + ',TimeZoneDisplay=t.TimeZoneDisplay'
	 + char(10) + (case when @TimeZoneName_Filtered = 1 then '' else @HideField end) + ',TimeZoneName=t.TimeZoneName'
	 + char(10) + (case when @Offset_Filtered = 1 then '' else @HideField end) + ',Offset=t.Offset'
	 + char(10) + (case when @UTCOffset_Filtered = 1 then '' else @HideField end) + ',UTCOffset=t.UTCOffset'
	 + char(10) + (case when @TimeZoneFullDispaly_Filtered = 1 then '' else @HideField end) + ',TimeZoneFullDispaly=t.TimeZoneFullDispaly'
	 + char(10) + (case when @TimeZoneAbbreviation_Filtered = 1 then '' else @HideField end) + ',TimeZoneAbbreviation=t.TimeZoneAbbreviation'
	 + char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = t.IsActive
	FROM [POMS_DB].[dbo].[T_Time_Zone_List] t WITH (NOLOCK)'
	 
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
