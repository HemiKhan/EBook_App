USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskAssignedToMap_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_TaskAssignedToMap_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_TaskAssignedToMap_List] 
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
	SET @sortExpression = ' TD_ID ASC, TATM_ID asc '  
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
  Declare @Task_Item_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Item') then 1 else 0 end)
  Declare @AssignedTo_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AssignedTo') then 1 else 0 end) 
  Declare @AssignToType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AssignToType') then 1 else 0 end) 
  Declare @Comment_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Comment') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end) 
  Declare @AddedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedBy') then 1 else 0 end)  
  Declare @AddedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedOn') then 1 else 0 end) 
  Declare @ModifiedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedBy') then 1 else 0 end) 
  Declare @ModifiedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedOn') then 1 else 0 end) 
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Task_Item_Req bit = (case when @Task_Item_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Item') then 0 else 1 end)
  Declare @AssignedTo_Req bit = (case when @AssignedTo_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AssignedTo') then 0 else 1 end)
  Declare @AssignToType_Req bit = (case when @AssignToType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AssignToType') then 0 else 1 end)
  Declare @Comment_Req bit = (case when @Comment_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Comment') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  Declare @AddedBy_Req bit = (case when @AddedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedBy') then 0 else 1 end)
  Declare @AddedOn_Req bit = (case when @AddedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedOn') then 0 else 1 end)
  Declare @ModifiedBy_Req bit = (case when @ModifiedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedBy') then 0 else 1 end)
  Declare @ModifiedOn_Req bit = (case when @ModifiedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedOn') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  SET @selectSql = N'Select Distinct tatm.TATM_ID, tatm.TD_ID'
    + CHAR(10) + (CASE WHEN @Task_Item_Filtered = 1 THEN '' ELSE @HideField END) + ', td.Task_Item'
    + CHAR(10) + (CASE WHEN @AssignedTo_Filtered = 1 THEN '' ELSE @HideField END) + ',AssignedTo = tatm.AssignedTo'
	+ CHAR(10) + (CASE WHEN @AssignToType_Filtered = 1 THEN '' ELSE @HideField END) + ', AssignToType = tatm.AssignToType_MTV_CODE'
	+ CHAR(10) + (CASE WHEN @Comment_Filtered = 1 THEN '' ELSE @HideField END) + ', Comment = tatm.Comment'
    + CHAR(10) + (CASE WHEN @IsActive_Filtered = 1 THEN '' ELSE @HideField END) + ', IsActive = tatm.IsActive'
	+ CHAR(10) + (CASE WHEN @AddedBy_Filtered = 1 THEN '' ELSE @HideField END) + ', AddedBy = tatm.AddedBy'
	+ CHAR(10) + (CASE WHEN @AddedOn_Filtered = 1 THEN '' ELSE @HideField END) + ', AddedOn = tatm.AddedOn'
	+ CHAR(10) + (CASE WHEN @ModifiedBy_Filtered = 1 THEN '' ELSE @HideField END) + ', ModifiedBy = tatm.ModifiedBy'
	+ CHAR(10) + (CASE WHEN @ModifiedOn_Filtered = 1 THEN '' ELSE @HideField END) + ', ModifiedOn = tatm.ModifiedOn
FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tatm WITH (NOLOCK) 
INNER JOIN [POMS_DB].[dbo].[T_TMS_TaskDetail] td WITH (NOLOCK) ON tatm.TD_ID = td.TD_ID'
	
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END

 
GO
