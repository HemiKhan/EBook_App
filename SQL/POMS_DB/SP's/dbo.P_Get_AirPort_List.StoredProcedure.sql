USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_AirPort_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_AirPort_List] 'Ihtisham.Ulhaq', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_AirPort_List] 
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
	SET @sortExpression = ' AL_ID asc '  
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
  
 Declare @AIRPORT_CODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AIRPORT_CODE') then 1 else 0 end)
Declare @Name_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end)
Declare @Number_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Number') then 1 else 0 end)
Declare @Address_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Address') then 1 else 0 end)
Declare @Address2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Address2') then 1 else 0 end)
Declare @City_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'City') then 1 else 0 end)
Declare @State_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'State') then 1 else 0 end)
Declare @ZipCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ZipCode') then 1 else 0 end)
Declare @CountryRegionCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CountryRegionCode') then 1 else 0 end)
Declare @County_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'County') then 1 else 0 end)
 Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)

  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @AIRPORT_COD_Req bit = (case when @AIRPORT_CODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AIRPORT_CODE') then 0 else 1 end)
Declare @Name_Req bit = (case when @Name_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
Declare @Number_Req bit = (case when @Number_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Number') then 0 else 1 end)
Declare @Address_Req bit = (case when @Address_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Address') then 0 else 1 end)
Declare @Address2_Req bit = (case when @Address2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Address2') then 0 else 1 end)
Declare @City_Req bit = (case when @City_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'City') then 0 else 1 end)
Declare @State_Req bit = (case when @State_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'State') then 0 else 1 end)
Declare @ZipCode_Req bit = (case when @ZipCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ZipCode') then 0 else 1 end)
Declare @CountryRegionCode_Req bit = (case when @CountryRegionCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CountryRegionCode') then 0 else 1 end)
Declare @County_Req bit = (case when @County_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'County') then 0 else 1 end)
Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)

  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT AL_ID'
	+ char(10) + (case when @AIRPORT_CODE_Filtered = 1 then '' else @HideField end) + ',AIRPORT_CODE=a.AIRPORT_CODE'
	 + char(10) + (case when @Name_Filtered = 1 then '' else @HideField end) + ',Name=a.Name'
	 + char(10) + (case when @Number_Filtered = 1 then '' else @HideField end) + ',Number=a.Number'
	 + char(10) + (case when @Address_Req = 1 then '' else @HideField end) + ',Address=a.Address'
	 + char(10) + (case when @Address2_Req = 1 then '' else @HideField end) + ',Address2=a.Address2'
	 + char(10) + (case when @City_Req = 1 then '' else @HideField end) + ',City=a.City'
	 + char(10) + (case when @ZipCode_Req = 1 then '' else @HideField end) + ',ZipCode=a.ZipCode'
	 + char(10) + (case when @State_Req = 1 then '' else @HideField end) + ',State=a.State'
	 + char(10) + (case when @CountryRegionCode_Req = 1 then '' else @HideField end) + ',CountryRegionCode=a.CountryRegionCode'
	 + char(10) + (case when @County_Filtered = 1 then '' else @HideField end) + ',County=a.County'
	 + char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = a.IsActive
	FROM [POMS_DB].[dbo].[T_AirPort_List] a WITH (NOLOCK)'
	 
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
