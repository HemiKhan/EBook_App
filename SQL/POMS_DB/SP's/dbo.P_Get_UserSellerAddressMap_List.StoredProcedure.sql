USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_UserSellerAddressMap_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_UserSellerAddressMap_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_UserSellerAddressMap_List] 
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
	SET @sortExpression = ' USAM_ID asc '  
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
  Declare @Col1_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UserName') then 1 else 0 end)
  Declare @Col2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'SellerAddress') then 1 else 0 end) 
  Declare @Col3_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Col1_Req bit = (case when @Col1_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UserName') then 0 else 1 end)
  Declare @Col2_Req bit = (case when @Col2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'SellerAddress') then 0 else 1 end)
  Declare @Col3_Req bit = (case when @Col3_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT USAM_ID, usam.SAM_ID'
	+ char(10) + (case when @Col1_Filtered = 1 then '' else @HideField end) + ',UserName = usam.UserName'
	+ char(10) + (case when @Col2_Filtered = 1 then '' else @HideField end) + ',SellerAddress = a.[Address]'
	+ char(10) + (case when @Col3_Filtered = 1 then '' else @HideField end) + ',IsActive = usam.IsActive
	FROM [POMS_DB].[dbo].[T_User_Seller_Address_Mapping] usam WITH (NOLOCK)
INNER JOIN [POMS_DB].[dbo].[T_Seller_Address_Mapping] sam WITH (NOLOCK) ON usam.SAM_ID = sam.SAM_ID
INNER JOIN [POMS_DB].[dbo].[T_Address_List] a WITH (NOLOCK) ON sam.ADDRESS_CODE = a.ADDRESS_CODE'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
