USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskManagementSystem_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_TaskManagementSystem_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_TaskManagementSystem_List]
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
	SET @sortExpression = ' T_ID asc '  
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
  --Declare @Application_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application') then 1 else 0 end)
  --Declare @TaskName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskName') then 1 else 0 end) 
  --Declare @Status_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Status') then 1 else 0 end)
  --Declare @Priority_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Priority') then 1 else 0 end)
  --Declare @TotalMemebers_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalMemebers') then 1 else 0 end)
  --Declare @TotalAttachments_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalAttachments') then 1 else 0 end)
  --Declare @TotalComments_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalComments') then 1 else 0 end)
  --Declare @ETA_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ETA') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  --Declare @Application_Req bit = (case when @Application_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application') then 0 else 1 end)
  --Declare @TaskName_Req bit = (case when @TaskName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskName') then 0 else 1 end)
  --Declare @Status_Req bit = (case when @Status_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Status') then 0 else 1 end)
  --Declare @Priority_Req bit = (case when @Priority_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Priority') then 0 else 1 end)
  --Declare @TotalMemebers_Req bit = (case when @TotalMemebers_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalMemebers') then 0 else 1 end)
  --Declare @TotalAttachments_Req bit = (case when @TotalAttachments_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalAttachments') then 0 else 1 end)
  --Declare @TotalComments_Req bit = (case when @TotalComments_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalComments') then 0 else 1 end)
  --Declare @ETA_Req bit = (case when @ETA_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ETA') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
   
	set @selectSql = N'SELECT t.Application_MTV_ID, t.T_ID, td.TD_ID, td.Status_MTV_ID, td.Priority_MTV_ID, 
	[Application] = mtv_a.[Name], t.TaskName, td.Task_Item, [Status] = mtv_s.[Name], [Priority] = mtv_p.[Name], td.IsActive
	,TotalMemebers = isnull((SELECT count(TATM_ID) FROM [POMS_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tatm WITH (NOLOCK) WHERE IsActive = 1 and tatm.TD_ID = td.TD_ID),0)
	,TotalAttachments = isnull((SELECT count(TA_ID) FROM [POMS_DB].[dbo].[T_TMS_TaskAttachments] ta WITH (NOLOCK) WHERE IsActive = 1 and ta.REFID2 = td.TD_ID),0)
	,TotalComments = isnull((SELECT count(TC_ID) FROM [POMS_DB].[dbo].[T_TMS_TaskComments] tc WITH (NOLOCK) WHERE IsActive = 1 and tc.TD_ID = td.TD_ID),0)
	,Task_Start_Date
	,Task_End_Date
	,AddedOn=cast(td.AddedOn as date)
	,ETA_Date
	,ETA=(case when ETA_Date is null then '''' else (CASE WHEN DATEDIFF(MONTH, Task_Start_Date, ETA_Date) > 0 
		THEN CAST(DATEDIFF(MONTH, Task_Start_Date, ETA_Date) AS nvarchar(50)) + '' Month'' 
		ELSE CAST(DATEDIFF(DAY, Task_Start_Date, ETA_Date) AS nvarchar(50)) + '' Days'' END) end)
	,LeftDays=(case when ETA_Date is null then 0 else (CASE WHEN GETDATE() > ETA_Date THEN 0 ELSE DATEDIFF(DAY, GETDATE(), ETA_Date) END) end)
	FROM [POMS_DB].[dbo].[T_TMS_Tasks] t WITH (NOLOCK)
	INNER JOIN [POMS_DB].[dbo].[T_TMS_TaskDetail] td WITH (NOLOCK) ON td.T_ID = t.T_ID
	LEFT JOIN [POMS_DB].[dbo].[T_Master_Type_Value] mtv_a WITH (NOLOCK) ON t.Application_MTV_ID = mtv_a.MTV_ID
	LEFT JOIN [POMS_DB].[dbo].[T_Master_Type_Value] mtv_s WITH (NOLOCK) ON td.Status_MTV_ID = mtv_s.MTV_ID
	LEFT JOIN [POMS_DB].[dbo].[T_Master_Type_Value] mtv_p WITH (NOLOCK) ON td.Priority_MTV_ID = mtv_p.MTV_ID
	WHERE td.IsActive = 1'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
