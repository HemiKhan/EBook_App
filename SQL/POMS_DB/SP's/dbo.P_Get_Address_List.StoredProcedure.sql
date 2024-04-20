USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Address_List]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_Address_List] 'Ihtisham.Ulhaq', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_Address_List] 
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
	SET @sortExpression = ' ADDRESS_ID asc '  
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
 Declare @IsResidentialAddress_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsResidentialAddress') then 1 else 0 end)
 Declare @FirstName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'FirstName') then 1 else 0 end)
Declare @MiddleNamee_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MiddleName') then 1 else 0 end)
Declare @ServiceType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ServiceType') then 1 else 0 end)
Declare @LastName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'LastName') then 1 else 0 end)
Declare @Company_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Company') then 1 else 0 end)
Declare @ContactPerson_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ContactPerson') then 1 else 0 end)
Declare @Address_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Address') then 1 else 0 end)
Declare @Address2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Address2') then 1 else 0 end)
Declare @City_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'City') then 1 else 0 end)
Declare @State_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'State') then 1 else 0 end)
Declare @ZipCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ZipCode') then 1 else 0 end)
Declare @CountryRegionCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CountryRegionCode') then 1 else 0 end)
Declare @Email_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Email') then 1 else 0 end)
Declare @Mobile_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Mobile') then 1 else 0 end)
Declare @Phone_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Phone') then 1 else 0 end)
Declare @PhoneExt_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PhoneExt') then 1 else 0 end)
Declare @Latitude_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Latitude') then 1 else 0 end)
Declare @Longitude_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Longitude') then 1 else 0 end)
Declare @PlaceID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PlaceID') then 1 else 0 end)
Declare @AddressType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddressType') then 1 else 0 end)
Declare @AddressStatus_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddressStatus') then 1 else 0 end)
Declare @Comment_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Comment') then 1 else 0 end)
Declare @ST_CODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ST_CODE') then 1 else 0 end)
Declare @ServiceName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ServiceName') then 1 else 0 end)
Declare @County_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'County') then 1 else 0 end)
Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)

  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
 Declare @IsResidentialAddress_Req bit = (case when @IsResidentialAddress_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsResidentialAddress') then 0 else 1 end)
Declare @FirstName_Req bit = (case when @FirstName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'FirstName') then 0 else 1 end)
Declare @MiddleName_Req bit = (case when @MiddleNamee_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MiddleName') then 0 else 1 end)
Declare @ServiceType_Req bit = (case when @ServiceType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ServiceType') then 0 else 1 end)
Declare @LastName_Req bit = (case when @LastName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'LastName') then 0 else 1 end)
Declare @Company_Req bit = (case when @Company_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Company') then 0 else 1 end)
Declare @ContactPerson_Req bit = (case when @ContactPerson_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ContactPerson') then 0 else 1 end)
Declare @Address_Req bit = (case when @Address_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Address') then 0 else 1 end)
Declare @Address2_Req bit = (case when @Address2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Address2') then 0 else 1 end)
Declare @City_Req bit = (case when @City_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'City') then 0 else 1 end)
Declare @State_Req bit = (case when @State_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'State') then 0 else 1 end)
Declare @ZipCode_Req bit = (case when @ZipCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ZipCode') then 0 else 1 end)
Declare @CountryRegionCode_Req bit = (case when @CountryRegionCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CountryRegionCode') then 0 else 1 end)
Declare @Email_Req bit = (case when @Email_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Email') then 0 else 1 end)
Declare @Mobile_Req bit = (case when @Mobile_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Mobile') then 0 else 1 end)
Declare @Phone_Req bit = (case when @Phone_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Phone') then 0 else 1 end)
Declare @PhoneExt_Req bit = (case when @PhoneExt_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PhoneExt') then 0 else 1 end)
Declare @Latitude_Req bit = (case when @Latitude_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Latitude') then 0 else 1 end)
Declare @Longitude_Req bit = (case when @Longitude_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Longitude') then 0 else 1 end)
Declare @PlaceID_Req bit = (case when @PlaceID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PlaceID') then 0 else 1 end)
Declare @AddressType_Req bit = (case when @AddressType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddressType') then 0 else 1 end)
Declare @AddressStatus_Req bit = (case when @AddressStatus_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddressStatus') then 0 else 1 end)
Declare @Comment_Req bit = (case when @Comment_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Comment') then 0 else 1 end)
Declare @ST_Code_Req bit = (case when @ST_CODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ST_CODE') then 0 else 1 end)
Declare @ServiceName_Req bit = (case when @ServiceName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ServiceName') then 0 else 1 end)
Declare @County_Req bit = (case when @County_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'County') then 0 else 1 end)
Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)

  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT a.ADDRESS_ID,a.ADDRESS_CODE, a.ServiceType_MTV_ID,a.AddressType_MTV_ID,a.AddressStatus_MTV_ID'
	+ char(10) + (case when @FirstName_Filtered = 1 then '' else @HideField end) + ',FirstName=a.FirstName'
	 + char(10) + (case when @LastName_Filtered = 1 then '' else @HideField end) + ',LastName=a.LastName'
	  + char(10) + (case when @ServiceType_Filtered = 1 then '' else @HideField end) + ',ServiceType=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE](isnull(a.ServiceType_MTV_ID,0))'
	 + char(10) + (case when @Company_Filtered = 1 then '' else @HideField end) + ',Company =a.Company'
	 + char(10) + (case when @ContactPerson_Filtered = 1 then '' else @HideField end) + ',ContactPerson=a.ContactPerson'
	 + char(10) + (case when @Address_Filtered = 1 then '' else @HideField end) + ',Address=a.Address'
	 + char(10) + (case when @Address2_Filtered= 1 then '' else @HideField end) + ',Address2=a.Address2'
	 + char(10) + (case when @City_Filtered = 1 then '' else @HideField end) + ',City=a.City'
	 + char(10) + (case when @ZipCode_Filtered= 1 then '' else @HideField end) + ',ZipCode=a.ZipCode'
	 + char(10) + (case when @State_Filtered = 1 then '' else @HideField end) + ',State=a.State'
	 + char(10) + (case when @CountryRegionCode_Filtered = 1 then '' else @HideField end) + ',CountryRegionCode=a.CountryRegionCode'
	 + char(10) + (case when @Email_Filtered = 1 then '' else @HideField end) + ',Email=a.Email'
	 + char(10) + (case when @Mobile_Filtered = 1 then '' else @HideField end) + ',Mobile=a.Mobile'
	 + char(10) + (case when @Phone_Filtered = 1 then '' else @HideField end) + ',Phone=a.Phone'
	 + char(10) + (case when @Latitude_Filtered = 1 then '' else @HideField end) + ',Latitude=a.Latitude'
	 + char(10) + (case when @Longitude_Filtered = 1 then '' else @HideField end) + ',Longitude=a.Longitude'
	 + char(10) + (case when @PlaceID_Filtered = 1 then '' else @HideField end) + ',PlaceID=a.PlaceID'
	 + char(10) + (case when @AddressType_Filtered = 1 then '' else @HideField end) + ',AddressType=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE](isnull(a.AddressType_MTV_ID,0))'
	 + char(10) + (case when @AddressStatus_Filtered = 1 then '' else @HideField end) + ',AddressStatus=[POMS_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE](isnull(a.AddressStatus_MTV_ID,0))'
	 + char(10) + (case when @Comment_Filtered = 1 then '' else @HideField end) + ',Comment=a.Comment'
	 + char(10) + (case when @ST_CODE_Filtered = 1 then '' else @HideField end) + ',ST_CODE=st.ST_CODE'
	 + char(10) + (case when @ServiceName_Filtered = 1 then '' else @HideField end) + ',ServiceName=st.ServiceName'
	 + char(10) + (case when @County_Filtered = 1 then '' else @HideField end) + ',County=a.County'
	 + char(10) + (case when @IsResidentialAddress_Filtered = 1 then '' else @HideField end) + ',IsResidentialAddress=a.IsResidentialAddress'
	 + char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = a.IsActive
	FROM [POMS_DB].[dbo].[T_Address_List] a WITH (NOLOCK)
	Left Join [POMS_DB].[dbo].[T_Service_Type]  st on a.ST_CODE=st.ST_CODE
	'
	 
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END

 
GO
