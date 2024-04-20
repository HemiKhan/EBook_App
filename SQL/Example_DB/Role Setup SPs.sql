
--	EXEC P_AddOrEdit_Roles 'Test','HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_AddOrEdit_Roles]
@RoleID INT = NULL,
@RoleName NVARCHAR(50),
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	DECLARE @maxSortValue INT
	DECLARE @OldRoleName NVARCHAR(50)
	DECLARE @OldActive BIT
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @RoleID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [dbo].T_Roles WHERE R_ID = @RoleID)
	BEGIN
	    
		SELECT @OldRoleName = RoleName, @OldActive = IsActive FROM [dbo].T_Roles WHERE R_ID = @RoleID
		
		UPDATE [dbo].T_Roles SET RoleName = @RoleName, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE R_ID = @RoleID
		
		IF @OldRoleName <> @RoleName
		BEGIN	
			exec dbo.P_Add_Audit_History 'RoleName' ,'T_Roles', @RoleID, 166103, '', '', '', @OldRoleName, @RoleName, @OldRoleName, @RoleName, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec dbo.P_Add_Audit_History 'IsActive' ,'T_Roles', @RoleID, 166103, '', '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Role Name Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Role does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @RoleName <> '' BEGIN
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [dbo].T_Roles WITH (NOLOCK)
		INSERT INTO [dbo].T_Roles (RoleName, Sort_, IsActive, AddedBy, AddedOn) VALUES (@RoleName, @maxSortValue, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Role Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Role Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

-- EXEC P_AddOrEdit_Role_Group 0,'Test',1,'HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_AddOrEdit_Role_Group]
@RoleGroupID INT = 0,
@RoleGroupName NVARCHAR(50),
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	DECLARE @maxSortValue INT
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @RoleGroupID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [dbo].T_Role_Group WITH (NOLOCK) WHERE RG_ID = @RoleGroupID)
	BEGIN
	    
		DECLARE @OldRoleGroupName NVARCHAR(50)
		DECLARE @OldActive BIT
		
		SELECT @OldRoleGroupName = RoleGroupName, @OldActive = IsActive FROM [dbo].T_Role_Group WITH (NOLOCK) WHERE RG_ID = @RoleGroupID
		
		UPDATE [dbo].T_Role_Group SET RoleGroupName = @RoleGroupName, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE RG_ID = @RoleGroupID
		
		IF @OldRoleGroupName <> @RoleGroupName
		BEGIN	
			exec P_Add_Audit_History 'RoleGroupName' ,'T_Role_Group', @RoleGroupID, 166104, @RoleGroupID, '', '', @OldRoleGroupName, @RoleGroupName, @OldRoleGroupName, @RoleGroupName, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_Role_Group', @RoleGroupID, 166104, @RoleGroupID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Role Group Name Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Role Group does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @RoleGroupName <> '' BEGIN
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [dbo].T_Role_Group WITH (NOLOCK)
		SELECT @RoleGroupID = ISNULL(MAX(RG_ID),0) + 1 FROM [dbo].T_Role_Group WITH (NOLOCK)
		INSERT INTO [dbo].T_Role_Group (RG_ID, RoleGroupName, Sort_, IsActive, AddedBy, AddedOn) VALUES (@RoleGroupID,@RoleGroupName, @maxSortValue, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Role Group Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Role Group Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

-- EXEC P_AddOrEdit_Role_Group_Mapping 'Test','HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_AddOrEdit_Role_Group_Mapping]
@RoleGroupMappingID INT = NULL,
@RoleID INT,
@RoleGroupID INT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @RoleGroupMappingID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [dbo].T_Role_Group_Mapping WITH (NOLOCK) WHERE RGM_ID = @RoleGroupMappingID)
	BEGIN
	    
		DECLARE @OldR_ID INT
		DECLARE @OldRG_ID INT
		DECLARE @OldActive BIT

		SELECT @OldR_ID = R_ID, @OldRG_ID = RG_ID, @OldActive = IsActive FROM [dbo].T_Role_Group_Mapping WITH (NOLOCK) WHERE RGM_ID = @RoleGroupMappingID
				
		UPDATE [dbo].T_Role_Group_Mapping SET R_ID = @RoleID, RG_ID = @RoleGroupID, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE RGM_ID = @RoleGroupMappingID

		IF @OldR_ID <> @RoleID
		BEGIN	
			exec [dbo].P_Add_Audit_History 'R_ID' ,'T_Role_Group_Mapping', @RoleID, 166115, @RoleGroupID, @RoleGroupMappingID, '', @OldR_ID, @RoleID, @OldR_ID, @RoleID, '', 0, 167100, @UserName
		END

		IF @OldRG_ID <> @RoleGroupID
		BEGIN	
			exec [dbo].P_Add_Audit_History 'RG_ID' ,'T_Role_Group_Mapping', @RoleID, 166115, @RoleGroupID, @RoleGroupMappingID, '', @OldRG_ID, @RoleGroupID, @OldRG_ID, @RoleGroupID, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [dbo].P_Add_Audit_History 'IsActive' ,'T_Role_Group_Mapping', @RoleID, 166115, @RoleGroupID, @RoleGroupMappingID, '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END		

		SET @Return_Text = 'Role Group Mapping Name Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Role Group Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @RoleID > 0 AND @RoleGroupID > 0 BEGIN
		INSERT INTO [dbo].T_Role_Group_Mapping (R_ID, RG_ID, IsActive, AddedBy, AddedOn) VALUES (@RoleID, @RoleGroupID, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Role Group Mapping Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Role Group Mapping Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

--	exec [dbo].[P_Get_PageChart_Json]
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_PageChart_Json]
	@RoleID int = null,
	@ApplicationID int = null
AS
BEGIN
	
	Declare @Json nvarchar(max) = ''
	select @Json = [dbo].[F_Get_PageChart_Json] (@RoleID,@ApplicationID)
	select @Json as [Json]

END
GO

 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Role_Setup_DropDown_Lists]
	@Username nvarchar(150)

AS
BEGIN
	
	SELECT [value] = R_ID, [text]= RoleName FROM [dbo].[T_Roles] WITH (NOLOCK) ORDER BY RoleName
	SELECT [value] = RG_ID, [text]= RoleGroupName FROM [dbo].[T_Role_Group] WITH (NOLOCK) ORDER BY RoleGroupName

END
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Roles_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Roles_List]
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
	SET @sortExpression = ' R_ID asc '  
	ELSE
	SET @sortExpression = @sortExpression + ' '

	DROP TABLE IF exists #Table_Fields_Filter
	 CREATE TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@filterobject)

	DROP TABLE IF exists #Table_Fields_Column
	 CREATE TABLE #Table_Fields_Column (code nvarchar(150) ,name_ nvarchar(150) ,iscolumnrequired bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@columnobject)

	Declare @HideField nvarchar(50) = ',hidefield=0'

  ---- Start Set Filter Variables
  Declare @RoleName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RoleName') then 1 else 0 end)
  Declare @Sort_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sort_') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @RoleName_Req bit = (case when @RoleName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RoleName') then 0 else 1 end)
  Declare @Sort_Req bit = (case when @Sort_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sort_') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
	set @selectSql = N'select R_ID = r.R_ID'
	+ char(10) + (case when @RoleName_Filtered = 1 then '' else @HideField end) + ',RoleName = r.RoleName'
	+ char(10) + (case when @Sort_Filtered = 1 then '' else @HideField end) + ',Sort_ = r.Sort_'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = r.IsActive
	FROM [dbo].[T_Roles] r with (nolock)'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Roles_Group_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Roles_Group_List]
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
	SET @sortExpression = ' RG_ID asc '  
	ELSE
	SET @sortExpression = @sortExpression + ' '

	DROP TABLE IF exists #Table_Fields_Filter
	 CREATE TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@filterobject)

	DROP TABLE IF exists #Table_Fields_Column
	 CREATE TABLE #Table_Fields_Column (code nvarchar(150) ,name_ nvarchar(150) ,iscolumnrequired bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@columnobject)

	Declare @HideField nvarchar(50) = ',hidefield=0'

  ---- Start Set Filter Variables
  Declare @RoleGroupName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RoleGroupName') then 1 else 0 end)
  Declare @Sort_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sort_') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @RoleGroupName_Req bit = (case when @RoleGroupName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RoleGroupName') then 0 else 1 end)
  Declare @Sort_Req bit = (case when @Sort_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sort_') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
	set @selectSql = N'select RG_ID = rg.RG_ID'
	+ char(10) + (case when @RoleGroupName_Filtered = 1 then '' else @HideField end) + ',RoleGroupName = rg.RoleGroupName'
	+ char(10) + (case when @Sort_Filtered = 1 then '' else @HideField end) + ',Sort_ = rg.Sort_'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = rg.IsActive
	FROM [dbo].[T_Role_Group] rg with (nolock)'
	
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_RolesGroupMap_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_RolesGroupMap_List]
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
	SET @sortExpression = ' RGM_ID asc '  
	ELSE
	SET @sortExpression = @sortExpression + ' '

	DROP TABLE IF exists #Table_Fields_Filter
	 CREATE TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@filterobject)

	DROP TABLE IF exists #Table_Fields_Column
	 CREATE TABLE #Table_Fields_Column (code nvarchar(150) ,name_ nvarchar(150) ,iscolumnrequired bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@columnobject)

	Declare @HideField nvarchar(50) = ',hidefield=0'

  ---- Start Set Filter Variables
  Declare @RoleName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RoleName') then 1 else 0 end)
  Declare @@RoleGroupName_Req_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RoleGroupName') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @RoleName_Req bit = (case when @RoleName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RoleName') then 0 else 1 end)
  Declare @RoleGroupName_Req bit = (case when @@RoleGroupName_Req_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RoleGroupName') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT RGM_ID = rgm.RGM_ID, R_ID = r.R_ID, RG_ID = rg.RG_ID'
	+ char(10) + (case when @RoleName_Filtered = 1 then '' else @HideField end) + ',RoleName = r.RoleName'
	+ char(10) + (case when @@RoleGroupName_Req_Filtered = 1 then '' else @HideField end) + ',RoleGroupName = rg.RoleGroupName'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = rgm.IsActive
	FROM [dbo].[T_Role_Group_Mapping] rgm with (nolock) 
	INNER JOIN [dbo].[T_Role_Group] rg with (nolock) ON rgm.RG_ID = rg.RG_ID 
	INNER JOIN [dbo].[T_Roles] r with (nolock) ON rgm.R_ID = r.R_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_UserRoleMap_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_UserRoleMap_List] 
	-- Add the parameters for the stored procedure here
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
	SET @sortExpression = ' USERNAME, R_ID, IsGroupRoleID asc '  
	ELSE
	SET @sortExpression = @sortExpression + ' '

	DROP TABLE IF exists #Table_Fields_Filter
	 CREATE TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@filterobject)

	DROP TABLE IF exists #Table_Fields_Column
	 CREATE TABLE #Table_Fields_Column (code nvarchar(150) ,name_ nvarchar(150) ,iscolumnrequired bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@columnobject)

	Declare @HideField nvarchar(50) = ',hidefield=0'

  ---- Start Set Filter Variables
  Declare @USERNAME_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'USERNAME') then 1 else 0 end)
  Declare @RoleName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RoleName') then 1 else 0 end)
  Declare @IsGroupRoleID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsGroupRoleID') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @USERNAME_Req bit = (case when @USERNAME_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'USERNAME') then 0 else 1 end)
  Declare @RoleName_Req bit = (case when @RoleName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RoleName') then 0 else 1 end)
  Declare @IsGroupRoleID_Req bit = (case when @IsGroupRoleID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsGroupRoleID') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  

	set @selectSql = N'SELECT URM_ID = urm.URM_ID, R_ID = r.R_ID'
	+ char(10) + (case when @USERNAME_Filtered = 1 then '' else @HideField end) + ',USERNAME = urm.USERNAME'
	+ char(10) + (case when @RoleName_Filtered = 1 then '' else @HideField end) + ',RoleName = r.RoleName'
	+ char(10) + (case when @IsGroupRoleID_Filtered = 1 then '' else @HideField end) + ',IsGroupRoleID =  urm.IsGroupRoleID'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = urm.IsActive
	FROM [dbo].T_User_Role_Mapping urm with (nolock) 
INNER JOIN [dbo].T_Roles r with (nolock) ON urm.ROLE_ID = r.R_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

--	EXEC P_AddOrEdit_User_Role_Map 0,2,'ABDULLAH.ARSHAD',0,1,'HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_AddOrEdit_User_Role_Map]
@URM_ID INT = NULL,
@R_ID INT,
@UNAME nvarchar(150),
@IsGroupRoleID BIT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @URM_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [dbo].[T_User_Role_Mapping] WITH (NOLOCK) WHERE URM_ID = @URM_ID)
	BEGIN
	    
		DECLARE @OldR_ID INT
		DECLARE @OldUNAME nvarchar(150)
		DECLARE @OldIsGroupRoleID BIT
		DECLARE @OldActive BIT
		
		SELECT @OldR_ID = ROLE_ID, @OldUNAME = USERNAME, @OldIsGroupRoleID = IsGroupRoleID, @OldActive = IsActive FROM [dbo].[T_User_Role_Mapping] WITH (NOLOCK) WHERE URM_ID = @URM_ID
		
		UPDATE [dbo].[T_User_Role_Mapping] SET ROLE_ID = @R_ID, USERNAME = @UNAME, IsGroupRoleID = @IsGroupRoleID, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE URM_ID = @URM_ID
		
		IF @OldR_ID <> @R_ID
		BEGIN	
			exec P_Add_Audit_History 'ROLE_ID' ,'T_User_Role_Mapping', @R_ID, 166105, @URM_ID, '', '', @OldR_ID, @R_ID, @OldR_ID, @R_ID, '', 0, 107100, @UserName
		END

		IF @OldUNAME <> @UNAME
		BEGIN	
			exec P_Add_Audit_History 'USERNAME' ,'T_User_Role_Mapping', @R_ID, 166105, @URM_ID, '', '', @OldUNAME, @UNAME, @OldUNAME, @UNAME, '', 0, 107100, @UserName
		END

		IF @OldIsGroupRoleID <> @IsGroupRoleID
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsGroupRoleID = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsGroupRoleID = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsRightActive' ,'T_User_Role_Mapping', @R_ID, 166105, @URM_ID, '', '', @OldIsGroupRoleID, @IsGroupRoleID, @OldIsHideText, @IsHideText, '', 0, 107100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_User_Role_Mapping', @R_ID, 166105, @URM_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 107100, @UserName
		END		

		SET @Return_Text = 'User Role Mapping Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'User Role Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @R_ID > 0 AND @UNAME <> '' BEGIN
		INSERT INTO [dbo].[T_User_Role_Mapping] (ROLE_ID, USERNAME, IsGroupRoleID, IsActive, AddedBy, AddedOn) VALUES (@R_ID, @UNAME, @IsGroupRoleID, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'User Role Mapping Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'User Role Mapping Not Found!'
		set @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO