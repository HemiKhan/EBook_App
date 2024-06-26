USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_SellerToSellerMapping_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_SellerToSellerMapping_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_SellerToSellerMapping_List]
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
	SET @sortExpression = ' STSM_ID asc '  
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
  Declare @Parent_SELLER_KEY_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Company') then 1 else 0 end)
  Declare @Child_SELLER_KEY_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ChildCompany') then 1 else 0 end) 
  Declare @IsViewOrder_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsViewOrder') then 1 else 0 end)
  Declare @IsCreateOrder_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsCreateOrder') then 1 else 0 end)
  Declare @IsGetQuote_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsGetQuote') then 1 else 0 end)
  Declare @IsFinancial_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsFinancial') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)

  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Parent_SELLER_KEY_Req bit = (case when @Parent_SELLER_KEY_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Company') then 0 else 1 end)
  Declare @Child_SELLER_KEY_Req bit = (case when @Child_SELLER_KEY_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ChildCompany') then 0 else 1 end)
  Declare @IsViewOrder_Req bit = (case when @IsViewOrder_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsViewOrder') then 0 else 1 end)
  Declare @IsCreateOrder_Req bit = (case when @IsCreateOrder_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsCreateOrder') then 0 else 1 end)
  Declare @IsGetQuote_Req bit = (case when @IsGetQuote_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsGetQuote') then 0 else 1 end)
  Declare @IsFinancial_Req bit = (case when @IsFinancial_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsFinancial') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)

  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
	set @selectSql = N'select STSM_ID = pg.STSM_ID, Parent_SELLER_KEY = dep.SELLER_KEY, childKey = dep2.SELLER_KEY'
	+ char(10) + (case when @Parent_SELLER_KEY_Filtered = 1 then '' else @HideField end) + ',Company = dep.Company'
	+ char(10) + (case when @Child_SELLER_KEY_Filtered = 1 then '' else @HideField end) + ',ChildCompany = dep2.Company'
	+ char(10) + (case when @IsViewOrder_Filtered = 1 then '' else @HideField end) + ',IsViewOrder = pg.IsViewOrder'
	+ char(10) + (case when @IsCreateOrder_Filtered = 1 then '' else @HideField end) + ',IsCreateOrder = pg.IsCreateOrder'
	+ char(10) + (case when @IsGetQuote_Filtered = 1 then '' else @HideField end) + ',IsGetQuote = pg.IsGetQuote'
	+ char(10) + (case when @IsFinancial_Filtered = 1 then '' else @HideField end) + ',IsFinancial = pg.IsFinancial'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = pg.IsActive
	FROM [POMS_DB].[dbo].[T_Seller_To_Seller_Mapping] pg with (nolock)
	LEFT JOIN [POMS_DB].[dbo].[T_Seller_List] dep with (nolock) ON dep.SELLER_KEY = pg.Parent_SELLER_KEY
	LEFT JOIN [POMS_DB].[dbo].[T_Seller_List] dep2 with (nolock) ON dep2.SELLER_KEY = pg.Child_SELLER_KEY'
	
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
