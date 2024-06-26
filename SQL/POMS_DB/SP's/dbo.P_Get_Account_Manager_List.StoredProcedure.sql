USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Account_Manager_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Account_Manager_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_Account_Manager_List]
	@Username nvarchar(150),
	@PageIndex int,  
	@PageSize int,  
	@SortExpression nvarchar(max),  
	@FilterClause nvarchar(max),  
	@TotalRowCount int OUTPUT,
	@TimeZoneID int = 0,
	@FilterObject nvarchar(max) = '',
	@ColumnObject nvarchar(max) = ''

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

	IF len(@sortExpression) = 0  
	SET @sortExpression = ' AML_ID asc '  
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
  Declare @Name_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'USERNAME') then 1 else 0 end)
  Declare @FullName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'FullName') then 1 else 0 end)
  Declare @DepartmentName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DepartmentName') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Name_Req bit = (case when @Name_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'USERNAME') then 0 else 1 end)
    Declare @FullName_Req bit = (case when @FullName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'FullName') then 0 else 1 end)
    Declare @DepartmentName_Req bit = (case when @DepartmentName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DepartmentName') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

	Declare @selectSql nvarchar(max);  
	SET @selectSql = N'select AML_ID'
	+ char(10) + (case when @Name_Filtered = 1 then '' else @HideField end) + ',USERNAME = tb1.USERNAME'
	+ char(10) + (case when @FullName_Filtered = 1 then '' else @HideField end) + ',FullName = fdu.FullName'
	+ char(10) + (case when @FullName_Filtered = 1 then '' else @HideField end) + ',DepartmentName = tb3.DepartmentName'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = tb1.IsActive'
	+ char(10) + 'FROM [POMS_DB].[dbo].[T_Account_Manager_List] tb1 with (nolock)
	INNER JOIN [POMS_DB].[dbo].[T_Users] tb2 with (nolock) ON tb1.USERNAME = tb2.USERNAME
	LEFT JOIN [POMS_DB].[dbo].[T_Department] tb3 with (nolock) ON tb3.D_ID = tb2.D_ID
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (tb1.USERNAME) fdu
	'

	exec [POMS_DB].[dbo].[P_Get_Common_List] @SelectSql, @PageIndex, @PageSize, @SortExpression, @FilterClause , @SetTop , @TotalRowCount OUTPUT

END
GO
