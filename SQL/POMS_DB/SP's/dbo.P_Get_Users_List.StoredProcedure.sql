USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Users_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_Users_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, 0,'', '','METRO-USER' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_Users_List] 
	-- Add the parameters for the stored procedure here
	@Username nvarchar(150),
	 @pageIndex int,  
	 @pageSize int,  
	 @sortExpression nvarchar(max),  
	 @filterClause nvarchar(max),  
	 @totalRowCount int OUTPUT,
	 @Offset int = -14400000,
	 @TimeZoneID int = 0,
	 @filterobject nvarchar(max),
	 @columnobject nvarchar(max),
	 @UserType_MTV_CODE nvarchar(20)
	
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
	SET @sortExpression = ' USERNAME asc '  
	ELSE
	SET @sortExpression = @sortExpression + ' '

	DROP TABLE IF exists #UsersList
	Create Table #UsersList ([USER_ID] int)
	if @UserType_MTV_CODE <> 'METRO-USER'
	begin
		insert into #UsersList ([USER_ID])
		select u.[USER_ID]
		from [POMS_DB].[dbo].[T_User_To_Seller_Mapping] usm with (nolock) 
		inner join [POMS_DB].[dbo].[T_User_To_Seller_Mapping] usm1 with (nolock) on usm.SELLER_ID = usm1.SELLER_ID
		inner join [POMS_DB].[dbo].[T_Users] u with (nolock) on usm1.UserName = u.USERNAME
		where usm.UserName = @Username and u.UserType_MTV_CODE = @UserType_MTV_CODE
	end

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
  Declare @USERNAME_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'USERNAME') then 1 else 0 end)
  Declare @UserType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UserType') then 1 else 0 end) 
  Declare @Department_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Department') then 1 else 0 end) 
  Declare @Designation_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Designation') then 1 else 0 end) 
  Declare @FirstName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'FirstName') then 1 else 0 end)
  Declare @MiddleName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MiddleName') then 1 else 0 end)
  Declare @LastName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'LastName') then 1 else 0 end)
  Declare @Company_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Company') then 1 else 0 end) 
  Declare @Address_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Address') then 1 else 0 end) 
  Declare @Address2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Address2') then 1 else 0 end) 
  Declare @City_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'City') then 1 else 0 end) 
  Declare @State_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'State') then 1 else 0 end) 
  Declare @Country_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Country') then 1 else 0 end) 
  Declare @Email_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Email') then 1 else 0 end) 
  Declare @Mobile_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Mobile') then 1 else 0 end) 
  Declare @Phone_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Phone') then 1 else 0 end) 
  Declare @PhoneExt_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PhoneExt') then 1 else 0 end) 
  Declare @SecurityQuestion_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'SecurityQuestion') then 1 else 0 end) 
  Declare @EncryptedAnswer_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'EncryptedAnswer') then 1 else 0 end) 
  Declare @TIMEZONE_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TIMEZONE_ID') then 1 else 0 end) 
  Declare @TIMEZONE_Name_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TIMEZONE_Name') then 1 else 0 end) 
  Declare @IsApproved_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsApproved') then 1 else 0 end) 
  Declare @BlockType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'BlockType') then 1 else 0 end) 
  Declare @IsAPIUser_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsAPIUser') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @USERNAME_Req bit = (case when @USERNAME_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'USERNAME') then 0 else 1 end)
  Declare @UserType_Req bit = (case when @UserType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UserType') then 0 else 1 end)
  Declare @Department_Req bit = (case when @Department_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Department') then 0 else 1 end)
  Declare @Designation_Req bit = (case when @Designation_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Designation') then 0 else 1 end)
  Declare @FirstName_Req bit = (case when @FirstName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'FirstName') then 0 else 1 end)
  Declare @MiddleName_Req bit = (case when @MiddleName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MiddleName') then 0 else 1 end)
  Declare @LastName_Req bit = (case when @LastName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'LastName') then 0 else 1 end)
  Declare @Company_Req bit = (case when @Company_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Company') then 0 else 1 end)
  Declare @Address_Req bit = (case when @Address_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Address') then 0 else 1 end)
  Declare @Address2_Req bit = (case when @Address2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Address2') then 0 else 1 end)
  Declare @City_Req bit = (case when @City_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'City') then 0 else 1 end)
  Declare @State_Req bit = (case when @State_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'State') then 0 else 1 end)
  Declare @Country_Req bit = (case when @Country_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Country') then 0 else 1 end)
  Declare @Email_Req bit = (case when @Email_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Email') then 0 else 1 end)
  Declare @Mobile_Req bit = (case when @Mobile_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Mobile') then 0 else 1 end)
  Declare @Phone_Req bit = (case when @Phone_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Phone') then 0 else 1 end)
  Declare @PhoneExt_Req bit = (case when @PhoneExt_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PhoneExt') then 0 else 1 end)
  Declare @SecurityQuestion_Req bit = (case when @SecurityQuestion_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'SecurityQuestion') then 0 else 1 end)
  Declare @EncryptedAnswer_Req bit = (case when @EncryptedAnswer_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'EncryptedAnswer') then 0 else 1 end)
  Declare @TIMEZONE_ID_Req bit = (case when @TIMEZONE_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TIMEZONE_ID') then 0 else 1 end)
  Declare @TIMEZONE_Name_Req bit = (case when @TIMEZONE_Name_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TIMEZONE_Name') then 0 else 1 end)
  Declare @IsApproved_Req bit = (case when @IsApproved_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsApproved') then 0 else 1 end)
  Declare @BlockType_Req bit = (case when @BlockType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'BlockType') then 0 else 1 end)
  Declare @IsAPIUser_Req bit = (case when @IsAPIUser_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsAPIUser') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT u.USER_ID, u.UserType_MTV_CODE, u.D_ID, u.SecurityQuestion_MTV_ID, u.BlockType_MTV_ID'
	+ char(10) + (case when @USERNAME_Filtered = 1 then '' else @HideField end) + ',USERNAME = u.USERNAME'
	+ char(10) + (case when @UserType_Filtered = 1 then '' else @HideField end) + ',UserType = mtv_ut.Name'
	+ char(10) + (case when @Department_Filtered = 1 then '' else @HideField end) + ',Department = d.DepartmentName'
	+ char(10) + (case when @Designation_Filtered = 1 then '' else @HideField end) + ',Designation = u.Designation'
	+ char(10) + (case when @FirstName_Filtered = 1 then '' else @HideField end) + ',FirstName = u.FirstName'
	+ char(10) + (case when @MiddleName_Filtered = 1 then '' else @HideField end) + ',MiddleName = u.MiddleName'
	+ char(10) + (case when @LastName_Filtered = 1 then '' else @HideField end) + ',LastName = u.LastName'
	+ char(10) + (case when @Company_Filtered = 1 then '' else @HideField end) + ',Company = u.Company'
	+ char(10) + (case when @Address_Filtered = 1 then '' else @HideField end) + ', u.Address'
	+ char(10) + (case when @Address2_Filtered = 1 then '' else @HideField end) + ', u.Address2'
	+ char(10) + (case when @City_Filtered = 1 then '' else @HideField end) + ',City = u.City'
	+ char(10) + (case when @State_Filtered = 1 then '' else @HideField end) + ',State = u.State'
	+ char(10) + (case when @Country_Filtered = 1 then '' else @HideField end) + ',Country = u.Country'
	+ char(10) + (case when @Email_Filtered = 1 then '' else @HideField end) + ',u.Email'
	+ char(10) + (case when @Mobile_Filtered = 1 then '' else @HideField end) + ',u.Mobile'
	+ char(10) + (case when @Phone_Filtered = 1 then '' else @HideField end) + ',u.Phone'
	+ char(10) + (case when @PhoneExt_Filtered = 1 then '' else @HideField end) + ',u.PhoneExt'
	--+ char(10) + (case when @SecurityQuestion_Filtered = 1 then '' else @HideField end) + ',SecurityQuestion = mtv_sq.Name'
	--+ char(10) + (case when @EncryptedAnswer_Filtered = 1 then '' else @HideField end) + ',u.EncryptedAnswer'
	+ char(10) + (case when @TIMEZONE_ID_Filtered = 1 then '' else @HideField end) + ',u.TIMEZONE_ID'
	+ char(10) + (case when @TIMEZONE_Name_Filtered = 1 then '' else @HideField end) + ',[TIMEZONE_Name]=[POMS_DB].[dbo].[F_Get_TimeZoneName_From_TimeZoneID] (u.TIMEZONE_ID)'
	+ char(10) + (case when @IsApproved_Filtered = 1 then '' else @HideField end) + ',IsApproved = u.IsApproved'
	+ char(10) + (case when @BlockType_Filtered = 1 then '' else @HideField end) + ',BlockType = mtv_bt.Name'
	--+ char(10) + (case when @BlockType_Filtered = 1 then '' else @HideField end) + ',PasswordExpiry = u.PasswordExpiryDateTime'
	+ char(10) + (case when @IsAPIUser_Filtered = 1 then '' else @HideField end) + ',IsAPIUser = u.IsAPIUser'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = u.IsActive'
	+ char(10) + 'FROM [POMS_DB].[dbo].[T_Users] u with (nolock)'
	+ char(10) + 'left JOIN [POMS_DB].[dbo].[T_Master_Type_Value] mtv_ut with (nolock) ON u.UserType_MTV_CODE = mtv_ut.MTV_CODE'
	+ char(10) + 'left JOIN [POMS_DB].[dbo].[T_Department] d with (nolock) ON u.D_ID = d.D_ID'
	--+ char(10) 'left JOIN [POMS_DB].[dbo].[T_Master_Type_Value] mtv_sq with (nolock) ON u.SecurityQuestion_MTV_ID = mtv_sq.MTV_ID'
	+ char(10) + 'left JOIN [POMS_DB].[dbo].[T_Master_Type_Value] mtv_bt with (nolock) ON u.BlockType_MTV_ID = mtv_bt.MTV_ID'
	+ char(10) + 'where 1 = 1'
	+ char(10) + (case when @UserType_MTV_CODE = 'METRO-USER' then '' else 'where u.USER_ID in (select [USER_ID] from #UsersList ul)' end)

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
