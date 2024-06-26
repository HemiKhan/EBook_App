USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ZipCodes_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_ZipCodes_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_ZipCodes_List] 
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
	SET @sortExpression = ' ZIP_CODE asc '  
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
  Declare @Col1_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'StateName') then 1 else 0 end)
  Declare @Col2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'State') then 1 else 0 end) 
  Declare @Col3_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AreaType') then 1 else 0 end)  
  Declare @Col4_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TimeZone') then 1 else 0 end)  
  Declare @Col5_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Region') then 1 else 0 end)  
  Declare @Col6_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'HUB_CODE') then 1 else 0 end)  
  Declare @Col7_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DrivingMiles') then 1 else 0 end)  
  Declare @Col8_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MilesRadius') then 1 else 0 end)  
  Declare @Col9_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Col1_Req bit = (case when @Col1_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'StateName') then 0 else 1 end)
  Declare @Col2_Req bit = (case when @Col2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'State') then 0 else 1 end)
  Declare @Col3_Req bit = (case when @Col3_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AreaType') then 0 else 1 end)
  Declare @Col4_Req bit = (case when @Col4_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TimeZone') then 0 else 1 end)
  Declare @Col5_Req bit = (case when @Col5_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Region') then 0 else 1 end)
  Declare @Col6_Req bit = (case when @Col6_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'HUB_CODE') then 0 else 1 end)
  Declare @Col7_Req bit = (case when @Col7_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DrivingMiles') then 0 else 1 end)
  Declare @Col8_Req bit = (case when @Col8_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MilesRadius') then 0 else 1 end)
  Declare @Col9_Req bit = (case when @Col9_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT ZIP_CODE, AreaType_MTV_ID, zc.TIMEZONE_ID, Region_MTV_CODE'
	+ char(10) + (case when @Col1_Filtered = 1 then '' else @HideField end) + ',StateName'
	+ char(10) + (case when @Col2_Filtered = 1 then '' else @HideField end) + ',State, Latitude = ROUND(Latitude, 10), Longitude = ROUND(Longitude, 10)'
	+ char(10) + (case when @Col3_Filtered = 1 then '' else @HideField end) + ',AreaType = at_mtv.Name'
	+ char(10) + (case when @Col4_Filtered = 1 then '' else @HideField end) + ',TimeZone = tz.TimeZoneDisplay'
	+ char(10) + (case when @Col5_Filtered = 1 then '' else @HideField end) + ',Region = r_mtv.Name'
	+ char(10) + (case when @Col6_Filtered = 1 then '' else @HideField end) + ',HUB_CODE'
	+ char(10) + (case when @Col7_Filtered = 1 then '' else @HideField end) + ',DrivingMiles'
	+ char(10) + (case when @Col8_Filtered = 1 then '' else @HideField end) + ',MilesRadius'
	+ char(10) + (case when @Col9_Filtered = 1 then '' else @HideField end) + ',IsActive = zc.IsActive
	FROM [POMS_DB].[dbo].[T_Zip_Code_List] zc WITH (NOLOCK) 
LEFT JOIN [POMS_DB].[dbo].[T_Master_Type_Value] at_mtv WITH (NOLOCK) ON zc.AreaType_MTV_ID = at_mtv.MTV_ID
LEFT JOIN [POMS_DB].[dbo].[T_Time_Zone_List] tz WITH (NOLOCK) ON zc.TIMEZONE_ID = tz.TIMEZONE_ID
LEFT JOIN [POMS_DB].[dbo].[T_Master_Type_Value] r_mtv WITH (NOLOCK) ON zc.Region_MTV_CODE = r_mtv.MTV_CODE'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
