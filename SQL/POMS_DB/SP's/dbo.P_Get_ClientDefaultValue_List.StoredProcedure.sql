USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ClientDefaultValue_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_ClientDefaultValue_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount


CREATE PROCEDURE [dbo].[P_Get_ClientDefaultValue_List] 
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
	SET @sortExpression = ' CDVS_ID asc '  
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
  Declare @SELLER_CODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'SELLER_CODE') then 1 else 0 end)
  Declare @CONFIG_TYPE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CONFIG_TYPE') then 1 else 0 end) 
  Declare @Description_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Description') then 1 else 0 end) 
  Declare @REFNO1_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'REFNO1') then 1 else 0 end) 
  Declare @REFNO2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'REFNO2') then 1 else 0 end)
  Declare @REFNO3_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'REFNO3') then 1 else 0 end)
  Declare @REFID1_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'REFID1') then 1 else 0 end)
  Declare @REFID2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'REFID2') then 1 else 0 end) 
  Declare @REFID3_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'REFID3') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end) 
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @SELLER_CODE_Req bit = (case when @SELLER_CODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'SELLER_CODE') then 0 else 1 end)
  Declare @CONFIG_TYPE_Req bit = (case when @CONFIG_TYPE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CONFIG_TYPE') then 0 else 1 end)
  Declare @Description_Req bit = (case when @Description_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Description') then 0 else 1 end)
  Declare @REFNO1_Req bit = (case when @REFNO1_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'REFNO1') then 0 else 1 end)
  Declare @REFNO2_Req bit = (case when @REFNO2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'REFNO2') then 0 else 1 end)
  Declare @REFNO3_Req bit = (case when @REFNO3_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'REFNO3') then 0 else 1 end)
  Declare @REFID1_Req bit = (case when @REFID1_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'REFID1') then 0 else 1 end)
  Declare @REFID2_Req bit = (case when @REFID2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'REFID2') then 0 else 1 end)
  Declare @REFID3_Req bit = (case when @REFID3_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'REFID3') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)

  ---- End Set Column Required Variables
  
  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT CDVS_ID'
	+ char(10) + (case when @SELLER_CODE_Filtered = 1 then '' else @HideField end) + ',SELLER_CODE = SELLER_CODE'
	+ char(10) + (case when @CONFIG_TYPE_Filtered = 1 then '' else @HideField end) + ',CONFIG_TYPE = CONFIG_TYPE'
	+ char(10) + (case when @Description_Filtered = 1 then '' else @HideField end) + ',Description = Description_'
	+ char(10) + (case when @REFNO1_Filtered = 1 then '' else @HideField end) + ',REFNO1 = REFNO1'
	+ char(10) + (case when @REFNO2_Filtered = 1 then '' else @HideField end) + ',REFNO2 = REFNO2'
	+ char(10) + (case when @REFNO3_Filtered = 1 then '' else @HideField end) + ',REFNO3 = REFNO3'
	+ char(10) + (case when @REFID1_Filtered = 1 then '' else @HideField end) + ',REFID1 = REFID1'
	+ char(10) + (case when @REFID2_Filtered = 1 then '' else @HideField end) + ',REFID2 = REFID2'
	+ char(10) + (case when @REFID3_Filtered = 1 then '' else @HideField end) + ',REFID3 = REFID3'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = IsActive
	FROM [POMS_DB].[dbo].[T_Client_Default_Value_Setup] with (nolock)'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT


END;
GO
