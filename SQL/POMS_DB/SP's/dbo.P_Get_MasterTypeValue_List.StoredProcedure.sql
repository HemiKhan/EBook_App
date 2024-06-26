USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_MasterTypeValue_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_MasterTypeValue_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_MasterTypeValue_List] 
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
	SET @sortExpression = ' MT_ID , Sort_ ,MTV_ID asc '  
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
  Declare @MTV_CODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MTV_CODE') then 1 else 0 end)
  Declare @MasterType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end)
  Declare @MasterTypeValue_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end) 
  Declare @Sub_MTV_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sub_MTV_ID') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @MTV_CODE_Req bit = (case when @MTV_CODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MTV_CODE') then 0 else 1 end)
  Declare @MasterType_Req bit = (case when @MasterType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
  Declare @MasterTypeValue_Req bit = (case when @MasterTypeValue_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
  Declare @Sub_MTV_ID_Req bit = (case when @Sub_MTV_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sub_MTV_ID') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'select MTV_ID = mtv.MTV_ID, MT_ID = mtv.MT_ID'
	+ char(10) + (case when @MasterType_Filtered = 1 then '' else @HideField end) + ',MTV_CODE = mtv.MTV_CODE'
	+ char(10) + (case when @MasterType_Filtered = 1 then '' else @HideField end) + ',MasterType = mt.Name'
	+ char(10) + (case when @MasterTypeValue_Filtered = 1 then '' else @HideField end) + ',MasterTypeValue = mtv.Name, Sort_'
	+ char(10) + (case when @Sub_MTV_ID_Filtered = 1 then '' else @HideField end) + ',Sub_MTV_ID = mtv.Sub_MTV_ID'
	+ char(10) + (case when @Sub_MTV_ID_Filtered = 1 then '' else @HideField end) + ',Sub_MTV_Name = (case when mtv.Sub_MTV_ID = 0 then '''' else (select top 1 m.[Name] from [POMS_DB].[dbo].[T_Master_Type_Value] m with (nolock) where m.MTV_ID = mtv.Sub_MTV_ID) end)'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = mtv.IsActive
	FROM [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) 
	INNER JOIN [POMS_DB].[dbo].[T_Master_Type] mt with (nolock) ON mtv.MT_ID = mt.MT_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
