USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_User_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_User_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount


CREATE PROCEDURE [dbo].[P_Get_User_List]
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
	SET @sortExpression = ' USER_ID asc '  
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
  Declare @DepartmentName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DepartmentName') then 1 else 0 end)
  Declare @Designation_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Designation') then 1 else 0 end)
  Declare @FirstName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'FirstName') then 1 else 0 end)
  Declare @MiddleName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MiddleName') then 1 else 0 end)
  Declare @LastName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'LastName') then 1 else 0 end)
  Declare @Company_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Company') then 1 else 0 end)
  Declare @IsAPIUser_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsAPIUser') then 1 else 0 end) 
  Declare @IsApproved_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsApproved') then 1 else 0 end) 
  Declare @IsHide_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @DepartmentName_Req bit = (case when @DepartmentName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DepartmentName') then 0 else 1 end)
  Declare @Designation_Req bit = (case when @Designation_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Designation') then 0 else 1 end)
  Declare @FirstName_Req bit = (case when @FirstName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'FirstName') then 0 else 1 end)
  Declare @MiddleName_Req bit = (case when @MiddleName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MiddleName') then 0 else 1 end)
  Declare @LastName_Req bit = (case when @LastName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'LastName') then 0 else 1 end)
  Declare @Company_Req bit = (case when @Company_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Company') then 0 else 1 end)
  Declare @IsAPIUser_Req bit = (case when @IsAPIUser_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsAPIUser') then 0 else 1 end)
  Declare @IsApproved_Req bit = (case when @IsApproved_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsApproved') then 0 else 1 end)
  Declare @IsHide_Req bit = (case when @IsHide_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  SET @selectSql = N'select USER_ID = USER_ID, USERNAME = USERNAME, UserType_MTV_CODE, PasswordHash, PasswordSalt, d.D_ID'
	+ char(10) + (case when @DepartmentName_Filtered = 1 then '' else @HideField end) + ',DepartmentName = d.DepartmentName'
	+ char(10) + (case when @Designation_Filtered = 1 then '' else @HideField end) + ',Designation = Designation'
	+ char(10) + (case when @FirstName_Filtered = 1 then '' else @HideField end) + ',FirstName = FirstName'
	+ char(10) + (case when @MiddleName_Filtered = 1 then '' else @HideField end) + ',MiddleName = MiddleName'
	+ char(10) + (case when @LastName_Filtered = 1 then '' else @HideField end) + ',LastName = LastName'
	+ char(10) + (case when @Company_Filtered = 1 then '' else @HideField end) + ',Company = Company, Address = Address, Address2 = Address2, City = City, State = State, ZipCode = ZipCode, Country = Country, Email = Email, Mobile = Mobile, Phone = Phone, PhoneExt = PhoneExt, SecurityQuestion_MTV_ID = SecurityQuestion_MTV_ID, EncryptedAnswer = EncryptedAnswer, TIMEZONE_ID = TIMEZONE_ID, BlockType_MTV_ID = BlockType_MTV_ID, PasswordExpiryDateTime = PasswordExpiryDateTime'
	+ char(10) + (case when @IsAPIUser_Filtered = 1 then '' else @HideField end) + ',IsAPIUser = IsAPIUser'
	+ char(10) + (case when @IsApproved_Filtered = 1 then '' else @HideField end) + ',IsApproved = IsApproved'
	+ char(10) + (case when @IsHide_Filtered = 1 then '' else @HideField end) + ',IsActive = u.IsActive
	FROM T_Users u with (nolock) INNER JOIN T_Department d with (nolock) ON u.D_ID = d.D_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
