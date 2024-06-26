USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ClientUserMapping_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_ClientUserMapping_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_ClientUserMapping_List] 
(	
	@Username nvarchar(150),
	@PageIndex int,  
	@PageSize int,  
	@SortExpression nvarchar(max),  
	@FilterClause nvarchar(max),  
	@TotalRowCount int OUTPUT,
	@TimeZoneID int = 0,
	@FilterObject nvarchar(max) = '',
	@ColumnObject nvarchar(max) = ''
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

	IF len(@sortExpression) = 0  
	SET @sortExpression = ' LCUM_ID asc '  
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
  Declare @LC_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'LC_ID') then 1 else 0 end)
  Declare @CUSTOMER_Name_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CUSTOMER_Name') then 1 else 0 end)
  Declare @SELLER_Name_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'SELLER_Name') then 1 else 0 end)
  Declare @USER_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'USER_ID') then 1 else 0 end)
  Declare @USERNAME_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'USERNAME') then 1 else 0 end)
  Declare @Logiwa_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Logiwa_ID') then 1 else 0 end)
  Declare @Logiwa_Name_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Logiwa_Name') then 1 else 0 end)
  Declare @Logiwa_OrderType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Logiwa_OrderType') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @LC_ID_Req bit = (case when @LC_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'LC_ID') then 0 else 1 end)
  Declare @CUSTOMER_Name_Req bit = (case when @CUSTOMER_Name_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CUSTOMER_Name') then 0 else 1 end)
  Declare @SELLER_Name_Req bit = (case when @SELLER_Name_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'SELLER_Name') then 0 else 1 end)
  Declare @USER_ID_Req bit = (case when @USER_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'USER_ID') then 0 else 1 end)
  Declare @USERNAME_Req bit = (case when @USERNAME_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'USERNAME') then 0 else 1 end)
  Declare @Logiwa_ID_Req bit = (case when @Logiwa_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Logiwa_ID') then 0 else 1 end)
  Declare @Logiwa_Name_Req bit = (case when @Logiwa_Name_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Logiwa_Name') then 0 else 1 end)
  Declare @Logiwa_OrderType_Req bit = (case when @Logiwa_OrderType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Logiwa_OrderType') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'select LCUM_ID '
	+ char(10) + (case when @LC_ID_Filtered = 1 then '' else @HideField end) + ',LC_ID = tb1.LC_ID'
	+ char(10) + (case when @CUSTOMER_Name_Filtered = 1 then '' else @HideField end) + ',CUSTOMER_Name = tb3.Name'
	+ char(10) + (case when @CUSTOMER_Name_Filtered = 1 then '' else @HideField end) + ',SELLER_Name = tb4.Company'
	+ char(10) + (case when @USERNAME_Filtered = 1 then '' else @HideField end) + ',USERNAME = tb1.USERNAME'
	+ char(10) + (case when @Logiwa_ID_Filtered = 1 then '' else @HideField end) + ',Logiwa_ID = tb2.Logiwa_ID'
	+ char(10) + (case when @Logiwa_Name_Filtered = 1 then '' else @HideField end) + ',Logiwa_Name = tb2.Logiwa_Name'
	+ char(10) + (case when @Logiwa_OrderType_Filtered = 1 then '' else @HideField end) + ',Logiwa_OrderType = tb2.Logiwa_OrderType'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = tb1.IsActive
	FROM [POMS_DB].[dbo].[T_Clients_Users_Mapping] tb1 WITH (NOLOCK)
	LEFT JOIN [POMS_DB].[dbo].[T_LogiwaClient] tb2 WITH (NOLOCK) ON tb2.LC_ID = tb1.LC_ID
	INNER JOIN [MetroPolitanNavProduction].dbo.[Metropolitan$Customer] tb3 WITH (NOLOCK) ON cast([Customer GUID] as nvarchar(50)) = tb2.CUSTOMER_KEY
	INNER JOIN [POMS_DB].[dbo].[T_Seller_List] tb4 WITH (NOLOCK) ON tb4.SELLER_KEY = tb2.SELLER_KEY
	'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
