USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_AccountManager_CSRMapping_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_AccountManager_CSRMapping_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_AccountManager_CSRMapping_List]
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
	SET @sortExpression = ' AMCM_ID asc '  
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
  Declare @ManagerName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ManagerName') then 1 else 0 end)
  Declare @ManagerFullName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ManagerFullName') then 1 else 0 end)
  Declare @ManagerDepartment_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ManagerDepartment') then 1 else 0 end)
    Declare @USERNAME_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'USERNAME') then 1 else 0 end)
  Declare @CSRFullName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CSRFullName') then 1 else 0 end)
  Declare @CSRDepartment_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CSRDepartment') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @ManagerName_Req bit = (case when @ManagerName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ManagerName') then 0 else 1 end)
  Declare @ManagerFullName_Req bit = (case when @ManagerFullName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ManagerFullName') then 0 else 1 end)
  Declare @ManagerDepartment_Req bit = (case when @ManagerDepartment_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ManagerDepartment') then 0 else 1 end)
  Declare @USERNAME_Req bit = (case when @USERNAME_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'USERNAME') then 0 else 1 end)
  Declare @CSRFullName_Req bit = (case when @CSRFullName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CSRFullName') then 0 else 1 end)
  Declare @CSRDepartment_Req bit = (case when @CSRDepartment_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CSRDepartment') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

	Declare @selectSql nvarchar(max);  
	SET @selectSql = N'select sal.AMCM_ID, AML_ID = sal.AML_ID'
	+ char(10) + (case when @ManagerName_Filtered = 1 then '' else @HideField end) + ',ManagerName = tb2.USERNAME'
	+ char(10) + (case when @ManagerFullName_Filtered = 1 then '' else @HideField end) + ',ManagerFullName = amfn.FullName'
	+ char(10) + (case when @ManagerFullName_Filtered = 1 then '' else @HideField end) + ',ManagerDepartment = amfn.DeptName'
	+ char(10) + (case when @USERNAME_Filtered = 1 then '' else @HideField end) + ',USERNAME = sal.USERNAME'
	+ char(10) + (case when @CSRFullName_Filtered = 1 then '' else @HideField end) + ',CSRFullName = csrfn.FullName'
	+ char(10) + (case when @CSRFullName_Filtered = 1 then '' else @HideField end) + ',CSRDepartment = csrfn.DeptName'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = sal.IsActive'
	+ char(10) + 'FROM [POMS_DB].[dbo].[T_Account_Manager_CSR_Mapping] sal with (nolock)
	JOIN [dbo].[T_Account_Manager_List] tb2 with (nolock) ON tb2.AML_ID = sal.AML_ID
	JOIN [POMS_DB].[dbo].[T_Users] tb3 with (nolock) ON tb3.USERNAME = tb2.USERNAME
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (tb2.USERNAME) amfn

	LEFT JOIN [POMS_DB].[dbo].[T_Users] tb5 with (nolock) ON tb5.USERNAME = sal.USERNAME
	outer apply [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Username] (sal.USERNAME) csrfn
	'

	exec [POMS_DB].[dbo].[P_Get_Common_List] @SelectSql, @PageIndex, @PageSize, @SortExpression, @FilterClause , @SetTop , @TotalRowCount OUTPUT

END
GO
