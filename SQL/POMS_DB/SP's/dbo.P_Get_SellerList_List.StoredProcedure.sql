USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_SellerList_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_SellerList_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_SellerList_List]
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
	SET @sortExpression = ' SELLER_ID asc '  
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
  Declare @SellerCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'SELLER_CODE') then 1 else 0 end)
  Declare @SellerKey_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'SELLER_KEY') then 1 else 0 end) 
  Declare @Company_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Company') then 1 else 0 end)
  Declare @ContactPerson_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ContactPerson') then 1 else 0 end)
  Declare @Address_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Address') then 1 else 0 end)
  Declare @Address2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Address2') then 1 else 0 end)
  Declare @City_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'City') then 1 else 0 end)
  Declare @State_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'State') then 1 else 0 end)
  Declare @ZipCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ZipCode') then 1 else 0 end)
  Declare @County_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'County') then 1 else 0 end)
  Declare @CountryRegionCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CountryRegionCode') then 1 else 0 end)
  Declare @EmailTo_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'EmailTo') then 1 else 0 end)
  Declare @EmailCC_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'EmailCC') then 1 else 0 end)
  Declare @Mobile_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Mobile') then 1 else 0 end)
  Declare @Mobile2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Mobile2') then 1 else 0 end)
  Declare @Phone_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Phone') then 1 else 0 end)
  Declare @PhoneExt_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PhoneExt') then 1 else 0 end)
  Declare @Phone2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Phone2') then 1 else 0 end)
  Declare @Phone2Ext_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Phone2Ext') then 1 else 0 end)
  Declare @D_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DepartmentName') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)


  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @SellerCode_Req bit = (case when @SellerCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'SELLER_CODE') then 0 else 1 end)
  Declare @SellerKey_Req bit = (case when @SellerKey_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'SELLER_KEY') then 0 else 1 end)
  Declare @Company_Req bit = (case when @Company_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Company') then 0 else 1 end)
  Declare @ContactPerson_Req bit = (case when @ContactPerson_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ContactPerson') then 0 else 1 end)
	Declare @Address_Req bit = (case when @Address_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Address') then 0 else 1 end)
	  Declare @Address2_Req bit = (case when @Address2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Address2') then 0 else 1 end)
	  Declare @City_Req bit = (case when @City_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'City') then 0 else 1 end)
	  Declare @State_Req bit = (case when @State_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'State') then 0 else 1 end)
	  Declare @ZipCode_Req bit = (case when @ZipCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ZipCode') then 0 else 1 end)
	  Declare @County_Req bit = (case when @County_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'County') then 0 else 1 end)
	  Declare @CountryRegionCode_Req bit = (case when @CountryRegionCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CountryRegionCode') then 0 else 1 end)
	Declare @EmailTo_Req bit = (case when @EmailTo_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'EmailTo') then 0 else 1 end)
	Declare @EmailCC_Req bit = (case when @EmailCC_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'EmailCC') then 0 else 1 end)
	Declare @Mobile_Req bit = (case when @Mobile_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Mobile') then 0 else 1 end)
	Declare @Mobile2_Req bit = (case when @Mobile2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Mobile2') then 0 else 1 end)
	Declare @Phone_Req bit = (case when @Phone_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Phone') then 0 else 1 end)
	Declare @PhoneExt_Req bit = (case when @PhoneExt_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PhoneExt') then 0 else 1 end)
	Declare @Phone2_Req bit = (case when @Phone2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Phone2') then 0 else 1 end)
	Declare @Phone2Ext_Req bit = (case when @PhoneExt_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Phone2Ext') then 0 else 1 end)
	Declare @D_ID_Req bit = (case when @D_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DepartmentName') then 0 else 1 end)
	Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)


  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
	set @selectSql = N'select SELLER_ID = pg.SELLER_ID, dep.D_ID'
	+ char(10) + (case when @SellerCode_Filtered = 1 then '' else @HideField end) + ',SELLER_CODE = pg.SELLER_CODE'
	+ char(10) + (case when @SellerKey_Filtered = 1 then '' else @HideField end) + ',SELLER_KEY = pg.SELLER_KEY'
	+ char(10) + (case when @Company_Filtered = 1 then '' else @HideField end) + ',Company = pg.Company'
	+ char(10) + (case when @ContactPerson_Filtered = 1 then '' else @HideField end) + ',ContactPerson = pg.ContactPerson'
	+ char(10) + (case when @Address_Filtered = 1 then '' else @HideField end) + ',Address = pg.Address'
	+ char(10) + (case when @Address2_Filtered = 1 then '' else @HideField end) + ',Address2 = pg.Address2'
	+ char(10) + (case when @City_Filtered = 1 then '' else @HideField end) + ',City = pg.City'
	+ char(10) + (case when @State_Filtered = 1 then '' else @HideField end) + ',State = pg.State'
	+ char(10) + (case when @ZipCode_Filtered = 1 then '' else @HideField end) + ',ZipCode = pg.ZipCode'
	+ char(10) + (case when @County_Filtered = 1 then '' else @HideField end) + ',County = pg.County'
	+ char(10) + (case when @CountryRegionCode_Filtered = 1 then '' else @HideField end) + ',CountryRegionCode = pg.CountryRegionCode'
	+ char(10) + (case when @EmailTo_Filtered = 1 then '' else @HideField end) + ',EmailTo = pg.EmailTo'
	+ char(10) + (case when @EmailCC_Filtered = 1 then '' else @HideField end) + ',EmailCC = pg.EmailCC'
	+ char(10) + (case when @Mobile_Filtered = 1 then '' else @HideField end) + ',Mobile = pg.Mobile'
	+ char(10) + (case when @Mobile2_Filtered = 1 then '' else @HideField end) + ',Mobile2 = pg.Mobile2'
	+ char(10) + (case when @Phone_Filtered = 1 then '' else @HideField end) + ',Phone = pg.Phone'
	+ char(10) + (case when @PhoneExt_Filtered = 1 then '' else @HideField end) + ',PhoneExt = pg.PhoneExt'
	+ char(10) + (case when @Phone2_Filtered = 1 then '' else @HideField end) + ',Phone2 = pg.Phone2'
	+ char(10) + (case when @Phone2Ext_Filtered = 1 then '' else @HideField end) + ',Phone2Ext = pg.Phone2Ext'
	+ char(10) + (case when @D_ID_Filtered = 1 then '' else @HideField end) + ',DepartmentName = dep.DepartmentName'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = pg.IsActive
		FROM [POMS_DB].[dbo].[T_Seller_List] pg with (nolock)
	LEFT JOIN [POMS_DB].[dbo].[T_Department] dep with (nolock) ON pg.D_ID = dep.D_ID'
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
