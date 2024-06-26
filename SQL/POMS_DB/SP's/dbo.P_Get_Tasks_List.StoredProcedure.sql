USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Tasks_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_Tasks_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, -14400000, 13, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_Tasks_List] 
	-- Add the parameters for the stored procedure here
	@Username nvarchar(150),
	 @pageIndex int,  
	 @pageSize int,  
	 @sortExpression nvarchar(max),  
	 @filterClause nvarchar(max),  
	 @totalRowCount int OUTPUT,
	 @Offset int = -14400000,
	 @TimeZoneID int = 13,
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
	SET @sortExpression = ' T_ID DESC '  
	ELSE
	begin
		SET @sortExpression = replace(@sortExpression,'AddedOn','UTCAddedOn')
		SET @sortExpression = replace(@sortExpression,'ModifiedOn','UTCModifiedOn')
		SET @sortExpression = @sortExpression + ' '
	end
	DROP TABLE IF exists #Table_Fields_Filter
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@filterobject)

	DROP TABLE IF exists #Table_Fields_Column
	CREATE TABLE #Table_Fields_Column (code nvarchar(150) ,name_ nvarchar(150) ,iscolumnrequired bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@columnobject)

	Declare @TimeZoneAbbr nvarchar(10) = ''
	Declare @TimeZoneName nvarchar(50) = ''
	Select @TimeZoneAbbr = TimeZoneAbbreviation, @TimeZoneName = TimeZoneName from [POMS_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where TIMEZONE_ID = @TimeZoneID

	Declare @HideField nvarchar(50) = ',hidefield=0'

   ---- Start Set Filter Variables
  Declare @Applicaiton_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Applicaiton') then 1 else 0 end)
  Declare @TaskName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskName') then 1 else 0 end) 
  Declare @Note_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Note') then 1 else 0 end)    
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  Declare @AddedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedBy') then 1 else 0 end)  
  Declare @AddedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedOn') then 1 else 0 end)  
  Declare @UTCAddedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UTCAddedOn') then 1 else 0 end)  
  Declare @ModifiedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedBy') then 1 else 0 end)  
  Declare @ModifiedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedOn') then 1 else 0 end)  
  Declare @UTCModifiedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UTCModifiedOn') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Applicaiton_Req bit = (case when @Applicaiton_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Applicaiton') then 0 else 1 end)
  Declare @TaskName_Req bit = (case when @TaskName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskName') then 0 else 1 end)
  Declare @Note_Req bit = (case when @Note_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Note') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  Declare @AddedBy_Req bit = (case when @AddedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedBy') then 0 else 1 end)
  Declare @AddedOn_Req bit = (case when @AddedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedOn') then 0 else 1 end)
  Declare @UTCAddedOn_Req bit = (case when @UTCAddedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UTCAddedOn') then 0 else 1 end)
  Declare @ModifiedBy_Req bit = (case when @ModifiedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedBy') then 0 else 1 end)
  Declare @ModifiedOn_Req bit = (case when @ModifiedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedOn') then 0 else 1 end)
  Declare @UTCModifiedOn_Req bit = (case when @UTCModifiedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UTCModifiedOn') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT T_ID, Application_ID=t.Application_MTV_ID'
	+ char(10) + (case when @Applicaiton_Filtered = 1 then '' else @HideField end) + ',Applicaiton=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (t.Application_MTV_ID)'
	+ char(10) + (case when @TaskName_Filtered = 1 then '' else @HideField end) + ',TaskName'
	+ char(10) + (case when @Note_Filtered = 1 then '' else @HideField end) + ',Note'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = t.IsActive'
	+ char(10) + (case when @AddedBy_Filtered = 1 then '' else @HideField end) + ',AddedBy = t.AddedBy'
	+ char(10) + (case when @AddedOn_Filtered = 1 then '' else @HideField end) + ',AddedOn = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (t.AddedOn, ' + cast(@TimeZoneID as nvarchar(20)) + ',null,''' + @TimeZoneName + ''')'
	+ char(10) + (case when @UTCAddedOn_Filtered = 1 then '' else @HideField end) + ',UTCAddedOn = t.AddedOn'
	+ char(10) + (case when @ModifiedBy_Filtered = 1 then '' else @HideField end) + ',ModifiedBy = t.ModifiedBy'
	+ char(10) + (case when @AddedOn_Filtered = 1 then '' else @HideField end) + ',ModifiedOn = [POMS_DB].[dbo].[F_Get_DateTime_From_UTC] (t.ModifiedOn, ' + cast(@TimeZoneID as nvarchar(20)) + ',null,''' + @TimeZoneName + ''')'
	+ char(10) + (case when @UTCModifiedOn_Filtered = 1 then '' else @HideField end) + ',UTCModifiedOn = t.ModifiedOn'
	+ char(10) + ',TimeZoneAbbr = ''' + @TimeZoneAbbr + '''
	FROM [POMS_DB].[dbo].[T_TMS_Tasks] t WITH (NOLOCK) where t.IsActive = 1'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
