USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Roles_Group_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Roles_Group_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount


CREATE PROCEDURE [dbo].[P_Get_Roles_Group_List]
(	
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
)

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
	SET @sortExpression = ' RG_ID asc '  
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
  Declare @RoleGroupName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RoleGroupName') then 1 else 0 end)
  Declare @Sort_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sort_') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @RoleGroupName_Req bit = (case when @RoleGroupName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RoleGroupName') then 0 else 1 end)
  Declare @Sort_Req bit = (case when @Sort_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sort_') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
	set @selectSql = N'select RG_ID = rg.RG_ID'
	+ char(10) + (case when @RoleGroupName_Filtered = 1 then '' else @HideField end) + ',RoleGroupName = rg.RoleGroupName'
	+ char(10) + (case when @Sort_Filtered = 1 then '' else @HideField end) + ',Sort_ = rg.Sort_'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = rg.IsActive
	FROM [POMS_DB].[dbo].[T_Role_Group] rg with (nolock)'
	
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
