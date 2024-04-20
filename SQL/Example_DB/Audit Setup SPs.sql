
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Audit_History_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	select [value] = MT_ID, [text]= [Name] from [dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 166 and IsActive = 1 order by [Name]

	select [value] = MT_ID, [text]= [Name] from [dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 167 and IsActive = 1 order by [Name]

END
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_AuditColumn_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_AuditColumn_List] 
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
	 CREATE TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
	FROM [dbo].[T_Audit_Column] ac with (nolock)' 
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_AuditHistory_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, -14400000, 13, '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_AuditHistory_List] 
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
	SET @sortExpression = ' AH_ID desc '  
	ELSE
	SET @sortExpression = @sortExpression + ' '

	DROP TABLE IF exists #Table_Fields_Filter
	 CREATE TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@filterobject)

	DROP TABLE IF exists #Table_Fields_Column
	 CREATE TABLE #Table_Fields_Column (code nvarchar(150) ,name_ nvarchar(150) ,iscolumnrequired bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@columnobject)

	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = 'Unknown'

	Declare @HideField nvarchar(50) = ',hidefield=0'

   ---- Start Set Filter Variables
  Declare @TableName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TableName') then 1 else 0 end)
  Declare @DbName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DbName') then 1 else 0 end) 
  Declare @ColumnName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ColumnName') then 1 else 0 end)
  Declare @REF_NO_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'REF_NO') then 1 else 0 end)
  Declare @MasterTypeValueAudit_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MasterTypeValueAudit') then 1 else 0 end)
  Declare @RefNo1_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RefNo1') then 1 else 0 end)
  Declare @RefNo2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RefNo2') then 1 else 0 end)
  Declare @RefNo3_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RefNo3') then 1 else 0 end)
  Declare @OldValueHidden_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'OldValueHidden') then 1 else 0 end)
  Declare @NewValueHidden_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'NewValueHidden') then 1 else 0 end)
  Declare @OldValue_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'OldValue') then 1 else 0 end)
  Declare @NewValue_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'NewValue') then 1 else 0 end)
  Declare @Reason_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Reason') then 1 else 0 end)
  Declare @IsAuto_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsAuto') then 1 else 0 end)
  Declare @MasterTypeValueSource_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MasterTypeValueSource') then 1 else 0 end)
  Declare @TriggerDebugInfo_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TriggerDebugInfo') then 1 else 0 end)
  Declare @ChangedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ChangedBy') then 1 else 0 end)
  Declare @ChangedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ChangedOn') then 1 else 0 end)
  Declare @UTCChangedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UTCChangedOn') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @TableName_Req bit = (case when @TableName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TableName') then 0 else 1 end)
  Declare @DbName_Req bit = (case when @DbName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DbName') then 0 else 1 end)
  Declare @ColumnName_Req bit = (case when @ColumnName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ColumnName') then 0 else 1 end)
  Declare @REF_NO_Req bit = (case when @REF_NO_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'REF_NO') then 0 else 1 end)
  Declare @MasterTypeValueAudit_Req bit = (case when @MasterTypeValueAudit_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MasterTypeValueAudit') then 0 else 1 end)
  Declare @RefNo1_Req bit = (case when @RefNo1_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RefNo1') then 0 else 1 end)
  Declare @RefNo2_Req bit = (case when @RefNo2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RefNo2') then 0 else 1 end)
  Declare @RefNo3_Req bit = (case when @RefNo3_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RefNo3') then 0 else 1 end)
  Declare @OldValueHiddent_Req bit = (case when @OldValueHidden_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'OldValueHidden') then 0 else 1 end)
  Declare @NewValueHidden_Req bit = (case when @NewValueHidden_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'NewValueHidden') then 0 else 1 end)
  Declare @OldValue_Req bit = (case when @OldValue_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'OldValue') then 0 else 1 end)
  Declare @NewValue_Req bit = (case when @NewValue_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'NewValue') then 0 else 1 end)
  Declare @Reason_Req bit = (case when @Reason_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Reason') then 0 else 1 end)
  Declare @IsAuto_Req bit = (case when @IsAuto_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsAuto') then 0 else 1 end)
  Declare @MasterTypeValueSource_Req bit = (case when @MasterTypeValueSource_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MasterTypeValueSource') then 0 else 1 end)
  Declare @TriggerDebugInfo_Req bit = (case when @TriggerDebugInfo_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TriggerDebugInfo') then 0 else 1 end)
  Declare @ChangedBy_Req bit = (case when @ChangedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ChangedBy') then 0 else 1 end)
  Declare @ChangedOn_Req bit = (case when @ChangedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ChangedOn') then 0 else 1 end)
  Declare @UTCChangedOn_Req bit = (case when @ChangedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UTCChangedOn') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'select AH_ID = ah.AH_ID, AC_ID = ac.AC_ID, AuditType_MTV_ID = ah.AuditType_MTV_ID, Source_MTV_ID = ah.Source_MTV_ID, TimeZoneAbbr=''' + @TimeZoneAbbr + ''''
	+ char(10) + (case when @TableName_Filtered = 1 then '' else @HideField end) + ',TableName = ac.TableName'
	+ char(10) + (case when @DbName_Filtered = 1 then '' else @HideField end) + ',DbName = ac.DbName'
	+ char(10) + (case when @ColumnName_Filtered = 1 then '' else @HideField end) + ',ColumnName = ac.Name'
	+ char(10) + (case when @REF_NO_Filtered = 1 then '' else @HideField end) + ',REF_NO'
	+ char(10) + (case when @MasterTypeValueAudit_Filtered = 1 then '' else @HideField end) + ',MasterTypeValueAudit = mtv_audit.Name'
	+ char(10) + (case when @RefNo1_Filtered = 1 then '' else @HideField end) + ',RefNo1'
	+ char(10) + (case when @RefNo2_Filtered = 1 then '' else @HideField end) + ',RefNo2'
	+ char(10) + (case when @RefNo3_Filtered = 1 then '' else @HideField end) + ',RefNo3'
	+ char(10) + (case when @OldValueHidden_Filtered = 1 then '' else @HideField end) + ',OldValueHidden'
	+ char(10) + (case when @NewValueHidden_Filtered = 1 then '' else @HideField end) + ',NewValueHidden'
	+ char(10) + (case when @OldValue_Filtered = 1 then '' else @HideField end) + ',OldValue'
	+ char(10) + (case when @NewValue_Filtered = 1 then '' else @HideField end) + ',NewValue'
	+ char(10) + (case when @Reason_Filtered = 1 then '' else @HideField end) + ',Reason'
	+ char(10) + (case when @IsAuto_Filtered = 1 then '' else @HideField end) + ',IsAuto'
	+ char(10) + (case when @MasterTypeValueSource_Filtered = 1 then '' else @HideField end) + ',MasterTypeValueSource = mtv.Name'
	+ char(10) + (case when @TriggerDebugInfo_Filtered = 1 then '' else @HideField end) + ',TriggerDebugInfo'
	+ char(10) + (case when @ChangedBy_Filtered = 1 then '' else @HideField end) + ',ChangedBy'
	+ char(10) + (case when @ChangedOn_Filtered = 1 then '' else @HideField end) + ',ChangedOn=[dbo].[F_Get_DateTime_From_UTC] ([ChangedOn],' + cast(@TimeZoneID as nvarchar(20)) + ',null,''' + @TimeZoneName + ''')'
	+ char(10) + (case when @UTCChangedOn_Filtered = 1 then '' else @HideField end) + ',UTCChangedOn=ChangedOn
	FROM [dbo].[T_Audit_History] ah with (nolock) 
	INNER JOIN [dbo].[T_Audit_Column] ac with (nolock) ON ah.AC_ID = ac.AC_ID
	left JOIN [dbo].[T_Master_Type_Value] mtv_audit with (nolock) ON ah.AuditType_MTV_ID = mtv_audit.MTV_ID
	left JOIN [dbo].[T_Master_Type_Value] mtv with (nolock) ON ah.Source_MTV_ID = mtv.MTV_ID'

	--select @selectSql

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
