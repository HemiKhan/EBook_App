USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_AuditColumn_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_AuditColumn_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_AuditColumn_List] 
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
	SET @sortExpression = ' AC_ID desc '  
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
  Declare @TableName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TableName') then 1 else 0 end)
  Declare @DbName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DbName') then 1 else 0 end) 
  Declare @ColumnName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end)
   
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @TableName_Req bit = (case when @TableName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TableName') then 0 else 1 end)
  Declare @DbName_Req bit = (case when @DbName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DbName') then 0 else 1 end)
  Declare @ColumnName_Req bit = (case when @ColumnName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
  
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'select ac.AC_ID'
	+ char(10) + (case when @TableName_Filtered = 1 then '' else @HideField end) + ',TableName = ac.TableName'
	+ char(10) + (case when @DbName_Filtered = 1 then '' else @HideField end) + ',DbName = ac.DbName'
	+ char(10) + (case when @ColumnName_Filtered = 1 then '' else @HideField end) + ',Name = ac.Name,ac.IsPublic
	FROM [POMS_DB].[dbo].[T_Audit_Column] ac with (nolock)' 
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
