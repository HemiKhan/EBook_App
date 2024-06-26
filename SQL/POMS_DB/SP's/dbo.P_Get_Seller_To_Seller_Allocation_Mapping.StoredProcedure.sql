USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Seller_To_Seller_Allocation_Mapping]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[P_Get_Seller_To_Seller_Allocation_Mapping]
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

	IF(@FilterClause = '' OR @FilterClause = null)  
	BEGIN SET @FilterClause = ' AND 1=1' END 

	IF(@PageIndex = null)  
	BEGIN SET @PageIndex = 0 END  
  
	IF(@PageSize = null)  
	BEGIN SET @PageSize = 0 END  

	Declare @SetTop int = 30
	SET @SetTop = (@PageIndex + 1) * @PageSize

	IF len(@SortExpression) = 0  
	SET @SortExpression = ' SSAM_ID asc '  
	ELSE
	SET @SortExpression = @SortExpression + ' '

	DROP TABLE IF exists #Table_Fields_Filter
	Create TABLE #Table_Fields_Filter ([Code] nvarchar(150) ,[Name] nvarchar(150) ,[IsFilterApplied] bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@FilterObject)

	DROP TABLE IF exists #Table_Fields_Column
	CREATE TABLE #Table_Fields_Column ([Code] nvarchar(150) ,[Name] nvarchar(150) ,[IsColumnRequired] bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@ColumnObject)

	Declare @HideField nvarchar(50) = ',hidefield=0'

	 ---- Start Set Filter Variables
	Declare @Name_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'Name') then 1 else 0 end)
	Declare @SellerCode_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'SellerCode') then 1 else 0 end)
	Declare @SellerName_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'SellerName') then 1 else 0 end)
	Declare @IsActive_Filtered bit = (case when exists(select [Code] from #Table_Fields_Filter where [IsFilterApplied] = 1 and [Code] = 'IsActive') then 1 else 0 end)
	---- End Set Filter Variables

	---- Start Set Column Required Variables
	Declare @Name_Req bit = (case when @Name_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'Name') then 0 else 1 end)
	Declare @SellerCode_Req bit = (case when @SellerCode_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'SellerCode') then 0 else 1 end)
	Declare @SellerName_Req bit = (case when @SellerName_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'SellerName') then 0 else 1 end)
	Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select [Code] from #Table_Fields_Column where [IsColumnRequired] = 0 and Code = 'IsActive') then 0 else 1 end)
	---- End Set Column Required Variables

	Declare @selectSql nvarchar(max);  
	SET @selectSql = N'select SSAM_ID = ssam.SSAM_ID'
	+ char(10) + (case when @Name_Filtered = 1 then '' else @HideField end) + ',Name = sal.Name'
	+ char(10) + (case when @SellerCode_Filtered = 1 then '' else @HideField end) + ',SellerCode = ssam.SELLER_CODE'
	+ char(10) + (case when @SellerName_Filtered = 1 then '' else @HideField end) + ',SellerName = [POMS_DB].[dbo].[F_Get_Seller_Name_From_SellerCode] (ssam.SELLER_CODE)'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = ssam.IsActive'
	+ char(10) + 'FROM [POMS_DB].[dbo].[T_Seller_To_Seller_Allocation_Mapping] ssam with (nolock) 
	inner join [POMS_DB].[dbo].[T_Seller_Allocation_List] sal with (nolock) on ssam.SAL_ID = sal.SAL_ID '
	
	exec [POMS_DB].[dbo].[P_Get_Common_List] @SelectSql, @PageIndex, @PageSize, @SortExpression, @FilterClause , @SetTop , @TotalRowCount OUTPUT

END
GO
