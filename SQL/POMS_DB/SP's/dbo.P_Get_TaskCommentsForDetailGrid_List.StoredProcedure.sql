USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskCommentsForDetailGrid_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from  T_TMS_TaskComments
--	Declare @TotalCount int = 0 exec [dbo].[P_Get_TaskCommentsForDetailGrid_List] 'Ihtisham',92, 0, 30, '', '', @TotalCount out, 18000000, '', ''select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_TaskCommentsForDetailGrid_List] 
	-- Add the parameters for the stored procedure here
	 @Username nvarchar(150),
	 @TD_TD int,
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
	SET @sortExpression = ' TC_ID ASC '  
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
  Declare @CommentText_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CommentText') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end) 
  Declare @Application_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application') then 1 else 0 end)  
  Declare @TaskName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskName') then 1 else 0 end)  
  Declare @Application_URL_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application_URL') then 1 else 0 end)  
  Declare @Task_Start_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Start_Date') then 1 else 0 end)    
  Declare @Task_End_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_End_Date') then 1 else 0 end)    
  Declare @Status_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Status') then 1 else 0 end)  
  Declare @Priority_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Priority') then 1 else 0 end)  
  Declare @BUILDCODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'BUILDCODE') then 1 else 0 end)  
  Declare @TaskCategory_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskCategory') then 1 else 0 end)  
  Declare @IsPrivate_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsPrivate') then 1 else 0 end)  
  Declare @Review_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Review_Date') then 1 else 0 end)  
  Declare @ETA_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ETA_Date') then 1 else 0 end) 
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Task_Item_Req bit = (case when @Task_Item_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Item') then 0 else 1 end)
  Declare @CommentText_Req bit = (case when @CommentText_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CommentText') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  Declare @Application_Req bit = (case when @Application_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application') then 0 else 1 end)
  Declare @TaskName_Req bit = (case when @TaskName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskName') then 0 else 1 end)
  Declare @Application_URL_Req bit = (case when @Application_URL_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application_URL') then 0 else 1 end)
  Declare @Task_Start_Date_Req bit = (case when @Task_Start_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Start_Date') then 0 else 1 end)
  Declare @Task_End_Date_Req bit = (case when @Task_End_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_End_Date') then 0 else 1 end)
  Declare @Status_Req bit = (case when @Status_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Status') then 0 else 1 end)
  Declare @Priority_Req bit = (case when @Priority_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Priority') then 0 else 1 end)
  Declare @BUILDCODE_Req bit = (case when @BUILDCODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'BUILDCODE') then 0 else 1 end)
  Declare @TaskCategory_Req bit = (case when @TaskCategory_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskCategory') then 0 else 1 end)
  Declare @IsPrivate_Req bit = (case when @IsPrivate_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsPrivate') then 0 else 1 end)
  Declare @Review_Date_Req bit = (case when @Review_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Review_Date') then 0 else 1 end)
  Declare @ETA_Date_Req bit = (case when @ETA_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ETA_Date') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT TC_ID, tc.TD_ID,tc.Status_MTV_ID ,tc.Priority_MTV_ID,Application_ID=t.Application_MTV_ID,p.P_ID,tc.TaskCategory_MTV_ID'
    + char(10) + (case when @Task_Item_Filtered = 1 then '' else @HideField end) + ',td.Task_Item'
    + char(10) + (case when @CommentText_Filtered = 1 then '' else @HideField end) + ',tc.CommentText'
    + char(10) + (case when @Application_Filtered = 1 then '' else @HideField end) + ',Application=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (t.Application_MTV_ID)'
    + char(10) + (case when @TaskName_Filtered = 1 then '' else @HideField end) + ',t.TaskName'
    + char(10) + (case when @Application_URL_Filtered = 1 then '' else @HideField end) + ',Application_URL=p.PageName'
    + char(10) + (case when @Task_Start_Date_Filtered = 1 then '' else @HideField end) + ',tc.Task_Start_Date'
    + char(10) + (case when @Task_End_Date_Filtered = 1 then '' else @HideField end) + ',tc.Task_End_Date'
    + char(10) + (case when @Status_Filtered = 1 then '' else @HideField end) + ',Status=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](tc.Status_MTV_ID)'
    + char(10) + (case when @Priority_Filtered = 1 then '' else @HideField end) + ',Priority=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](tc.Priority_MTV_ID)'
    + char(10) + (case when @BUILDCODE_Filtered = 1 then '' else @HideField end) + ',BUILDCODE=[POMS_DB].[dbo].[F_GetBuildCodeName](tc.BUILDCODE)'
    + char(10) + (case when @TaskCategory_Filtered = 1 then '' else @HideField end) + ',TaskCategory=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](tc.TaskCategory_MTV_ID)'
    + char(10) + (case when @IsPrivate_Filtered = 1 then '' else @HideField end) + ',tc.IsPrivate'
    + char(10) + (case when @Review_Date_Filtered = 1 then '' else @HideField end) + ',Review_Date = tc.Review_Date'
    + char(10) + (case when @ETA_Date_Filtered = 1 then '' else @HideField end) + ',ETA_Date = tc.ETA_Date'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = tc.IsActive
    FROM [POMS_DB].[dbo].[T_TMS_TaskComments] tc WITH (NOLOCK) 
    INNER JOIN [POMS_DB].[dbo].[T_TMS_TaskDetail] td WITH (NOLOCK) ON tc.TD_ID = td.TD_ID
    INNER JOIN [POMS_DB].[dbo].[T_TMS_Tasks]  t WITH (NOLOCK) ON td.T_ID = t.T_ID
	left Join [POMS_DB].[dbo].[T_Page] p  WITH (NOLOCK) ON tc.Application_URL = p.P_ID
    where tc.TD_ID=' + cast(@TD_TD as nvarchar(20)); 

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
