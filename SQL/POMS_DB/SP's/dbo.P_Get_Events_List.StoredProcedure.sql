USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Events_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_Events_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_Events_List] 
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
	SET @sortExpression = ' EL_ID asc '  
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
  Declare @Col1_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end)
  Declare @Col2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Activity') then 1 else 0 end) 
  Declare @Col3_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsAutoTrigger') then 1 else 0 end)  
  Declare @Col4_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsManualTrigger') then 1 else 0 end)  
  Declare @Col5_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsOutboundRequired') then 1 else 0 end)  
  Declare @Col6_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Metro_Email') then 1 else 0 end)  
  Declare @Col7_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Client_Email') then 1 else 0 end)  
  Declare @Col8_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Client_SMS') then 1 else 0 end)  
  Declare @Col9_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Metro_SMS') then 1 else 0 end)  
  Declare @Col10_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_OED_Email') then 1 else 0 end)  
  Declare @Col11_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_OED_SMS') then 1 else 0 end)  
  Declare @Col12_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_CSR_Email') then 1 else 0 end)  
  Declare @Col13_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_CSR_SMS') then 1 else 0 end)  
  Declare @Col14_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Dispatch_Email') then 1 else 0 end)  
  Declare @Col15_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Dispatch_SMS') then 1 else 0 end)  
  Declare @Col16_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Accounting_Email') then 1 else 0 end)  
  Declare @Col17_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Accounting_SMS') then 1 else 0 end)  
  Declare @Col18_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Warehouse_Email') then 1 else 0 end)  
  Declare @Col19_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Warehouse_SMS') then 1 else 0 end)  
  Declare @Col20_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_ShipFrom_Email') then 1 else 0 end)  
  Declare @Col21_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_ShipFrom_SMS') then 1 else 0 end)  
  Declare @Col22_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_ShipTo_Email') then 1 else 0 end)  
  Declare @Col23_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_ShipTo_SMS') then 1 else 0 end)  
  Declare @Col24_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_SellTo_Email') then 1 else 0 end)  
  Declare @Col25_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_SellTo_SMS') then 1 else 0 end)  
  Declare @Col26_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_BillTo_Email') then 1 else 0 end)  
  Declare @Col27_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_BillTo_SMS') then 1 else 0 end)  
  Declare @Col28_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsRecurring') then 1 else 0 end)  
  Declare @Col29_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsPublic') then 1 else 0 end)  
  Declare @Col30_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsTrackingAvailable') then 1 else 0 end)  
  Declare @Col31_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Col1_Req bit = (case when @Col1_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
  Declare @Col2_Req bit = (case when @Col2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Activity') then 0 else 1 end)
  Declare @Col3_Req bit = (case when @Col3_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsAutoTrigger') then 0 else 1 end)
  Declare @Col4_Req bit = (case when @Col4_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsManualTrigger') then 0 else 1 end)
  Declare @Col5_Req bit = (case when @Col5_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsOutboundRequired') then 0 else 1 end)
  Declare @Col6_Req bit = (case when @Col6_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Metro_Email') then 0 else 1 end)
  Declare @Col7_Req bit = (case when @Col7_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Metro_SMS') then 0 else 1 end)
  Declare @Col8_Req bit = (case when @Col8_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Client_Email') then 0 else 1 end)
  Declare @Col9_Req bit = (case when @Col9_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Client_SMS') then 0 else 1 end)
  Declare @Col18_Req bit = (case when @Col10_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_OED_Email') then 0 else 1 end)
  Declare @Col10_Req bit = (case when @Col11_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_OED_SMS') then 0 else 1 end)
  Declare @Col11_Req bit = (case when @Col12_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_CSR_Email') then 0 else 1 end)
  Declare @Col12_Req bit = (case when @Col13_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_CSR_SMS') then 0 else 1 end)
  Declare @Col13_Req bit = (case when @Col14_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Dispatch_Email') then 0 else 1 end)
  Declare @Col14_Req bit = (case when @Col15_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Dispatch_SMS') then 0 else 1 end)
  Declare @Col15_Req bit = (case when @Col16_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Accounting_Email') then 0 else 1 end)
  Declare @Col16_Req bit = (case when @Col17_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Accounting_SMS') then 0 else 1 end)
  Declare @Col17_Req bit = (case when @Col18_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Warehouse_Email') then 0 else 1 end)
  Declare @Col19_Req bit = (case when @Col19_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Warehouse_SMS') then 0 else 1 end)
  Declare @Col20_Req bit = (case when @Col20_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_ShipFrom_Email') then 0 else 1 end)
  Declare @Col21_Req bit = (case when @Col21_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_ShipFrom_SMS') then 0 else 1 end)
  Declare @Col22_Req bit = (case when @Col22_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_ShipTo_Email') then 0 else 1 end)
  Declare @Col23_Req bit = (case when @Col23_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_ShipTo_SMS') then 0 else 1 end)
  Declare @Col24_Req bit = (case when @Col24_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_SellTo_Email') then 0 else 1 end)
  Declare @Col25_Req bit = (case when @Col25_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_SellTo_SMS') then 0 else 1 end)
  Declare @Col26_Req bit = (case when @Col26_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_BillTo_Email') then 0 else 1 end)
  Declare @Col27_Req bit = (case when @Col27_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_BillTo_SMS') then 0 else 1 end)
  Declare @Col28_Req bit = (case when @Col28_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsRecurring') then 0 else 1 end)
  Declare @Col29_Req bit = (case when @Col29_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsPublic') then 0 else 1 end)
  Declare @Col30_Req bit = (case when @Col30_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsTrackingAvailable') then 0 else 1 end)
  Declare @Col31_Req bit = (case when @Col31_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT EL_ID, EVENT_ID, EVENT_CODE, Activity_MTV_ID'
	+ char(10) + (case when @Col1_Filtered = 1 then '' else @HideField end) + ',e.Name, Description'
	+ char(10) + (case when @Col2_Filtered = 1 then '' else @HideField end) + ',Activity = a_mtv.Name'
	+ char(10) + (case when @Col3_Filtered = 1 then '' else @HideField end) + ',IsAutoTrigger'
	+ char(10) + (case when @Col4_Filtered = 1 then '' else @HideField end) + ',IsManualTrigger'
	+ char(10) + (case when @Col5_Filtered = 1 then '' else @HideField end) + ',IsOutboundRequired'
	+ char(10) + (case when @Col6_Filtered = 1 then '' else @HideField end) + ',IsNotify_Metro_Email'
	+ char(10) + (case when @Col7_Filtered = 1 then '' else @HideField end) + ',IsNotify_Metro_SMS'
	+ char(10) + (case when @Col8_Filtered = 1 then '' else @HideField end) + ',IsNotify_Client_Email'
	+ char(10) + (case when @Col9_Filtered = 1 then '' else @HideField end) + ',IsNotify_Client_SMS'
	+ char(10) + (case when @Col10_Filtered = 1 then '' else @HideField end) + ',IsNotify_OED_Email'
	+ char(10) + (case when @Col11_Filtered = 1 then '' else @HideField end) + ',IsNotify_OED_SMS'
	+ char(10) + (case when @Col12_Filtered = 1 then '' else @HideField end) + ',IsNotify_CSR_Email'
	+ char(10) + (case when @Col13_Filtered = 1 then '' else @HideField end) + ',IsNotify_CSR_SMS'
	+ char(10) + (case when @Col14_Filtered = 1 then '' else @HideField end) + ',IsNotify_Dispatch_Email'
	+ char(10) + (case when @Col15_Filtered = 1 then '' else @HideField end) + ',IsNotify_Dispatch_SMS'
	+ char(10) + (case when @Col16_Filtered = 1 then '' else @HideField end) + ',IsNotify_Accounting_Email'
	+ char(10) + (case when @Col17_Filtered = 1 then '' else @HideField end) + ',IsNotify_Accounting_SMS'
	+ char(10) + (case when @Col18_Filtered = 1 then '' else @HideField end) + ',IsNotify_Warehouse_Email'
	+ char(10) + (case when @Col19_Filtered = 1 then '' else @HideField end) + ',IsNotify_Warehouse_SMS'
	+ char(10) + (case when @Col20_Filtered = 1 then '' else @HideField end) + ',IsNotify_ShipFrom_Email'
	+ char(10) + (case when @Col21_Filtered = 1 then '' else @HideField end) + ',IsNotify_ShipFrom_SMS'
	+ char(10) + (case when @Col22_Filtered = 1 then '' else @HideField end) + ',IsNotify_ShipTo_Email'
	+ char(10) + (case when @Col23_Filtered = 1 then '' else @HideField end) + ',IsNotify_ShipTo_SMS'
	+ char(10) + (case when @Col24_Filtered = 1 then '' else @HideField end) + ',IsNotify_SellTo_Email'
	+ char(10) + (case when @Col25_Filtered = 1 then '' else @HideField end) + ',IsNotify_SellTo_SMS'
	+ char(10) + (case when @Col26_Filtered = 1 then '' else @HideField end) + ',IsNotify_BillTo_Email'
	+ char(10) + (case when @Col27_Filtered = 1 then '' else @HideField end) + ',IsNotify_BillTo_SMS'
	+ char(10) + (case when @Col28_Filtered = 1 then '' else @HideField end) + ',IsRecurring'
	+ char(10) + (case when @Col29_Filtered = 1 then '' else @HideField end) + ',IsPublic'
	+ char(10) + (case when @Col30_Filtered = 1 then '' else @HideField end) + ',IsTrackingAvailable'
	+ char(10) + (case when @Col31_Filtered = 1 then '' else @HideField end) + ',IsActive = e.IsActive
	FROM [POMS_DB].[dbo].[T_Events_List] e WITH (NOLOCK)
	INNER JOIN [POMS_DB].[dbo].[T_Master_Type_Value] a_mtv WITH (NOLOCK) ON e.Activity_MTV_ID = a_mtv.MTV_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
