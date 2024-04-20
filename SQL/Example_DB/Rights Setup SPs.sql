
--	EXEC [P_AddOrEdit_Page_Rights] 4,'Test','sss','HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_AddOrEdit_Page_Rights]
@PR_ID INT = NULL,
@P_ID INT,
@PR_CODE nvarchar(50),
@PageRightName nvarchar(50),
@PageRightType nvarchar(20),
@IsHide BIT = 0,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @PR_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM dbo.T_Page_Rights WITH (NOLOCK) WHERE PR_ID = @PR_ID)
	BEGIN
	    
		DECLARE @OldPR_CODE nvarchar(50)
		DECLARE @OldPageRightName nvarchar(50)
		DECLARE @OldPageRightType nvarchar(20)
		DECLARE @OldIsHide BIT
		DECLARE @OldActive BIT
		
		SELECT @OldPR_CODE = PR_CODE, @OldPageRightName = PageRightName, @OldPageRightType = PageRightType_MTV_CODE, @OldIsHide = IsHide, @OldActive = IsActive FROM dbo.T_Page_Rights WITH (NOLOCK) WHERE PR_ID = @PR_ID
		
		UPDATE dbo.T_Page_Rights SET PR_CODE = @PR_CODE, PageRightName = @PageRightName, PageRightType_MTV_CODE = @PageRightType, IsHide = @IsHide, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE PR_ID = @PR_ID
		
		IF @OldPR_CODE <> @PR_CODE
		BEGIN	
			exec dbo.P_Add_Audit_History 'PR_CODE' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldPR_CODE, @PR_CODE, @OldPR_CODE, @PR_CODE, '', 0, 167100, @UserName
		END

		IF @OldPageRightName <> @PageRightName
		BEGIN	
			exec dbo.P_Add_Audit_History 'PageRightName' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldPageRightName, @PageRightName, @OldPageRightName, @PageRightName, '', 0, 167100, @UserName
		END

		IF @OldPageRightType <> @PageRightType
		BEGIN	
			exec dbo.P_Add_Audit_History 'PageRightType_MTV_CODE' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldPageRightType, @PageRightType, @OldPageRightType, @PageRightType, '', 0, 167100, @UserName
		END

		IF @OldIsHide <> @IsHide
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsHide = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsHide = 1 then 'Yes' else 'No' end)
			exec dbo.P_Add_Audit_History 'IsHide' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldIsHide, @IsHide, @OldIsHideText, @IsHideText, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec dbo.P_Add_Audit_History 'IsActive' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END		

		SET @Return_Text = 'Page Rights Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Page Rights does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @PR_CODE <> '' AND @PageRightName <> '' AND @P_ID > 0 BEGIN
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM dbo.T_Page_Rights WITH (NOLOCK) WHERE P_ID = @P_ID
		SELECT @PR_ID = (CASE WHEN ISNULL(MAX(PR_ID),0) = 0 THEN cast((cast(@P_ID as nvarchar(max)) + '100') as int) ELSE ISNULL(MAX(PR_ID),0) + 1 END) FROM dbo.T_Page_Rights WITH (NOLOCK) WHERE P_ID = @P_ID
		INSERT INTO dbo.T_Page_Rights (PR_ID, P_ID, PR_CODE, PageRightName, PageRightType_MTV_CODE, Sort_, IsHide, IsActive, AddedBy, AddedOn) VALUES (@PR_ID, @P_ID, @PR_CODE, @PageRightName, @PageRightType, @maxSortValue, @IsHide, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Page Rights Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Page Rights Not Found!'
		set @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

--	EXEC [P_AddOrEdit_RolePageRight_Json] 4,'Test','sss','HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_AddOrEdit_RolePageRight_Json]
@Json nvarchar(max),
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

	IF OBJECT_ID('tempdb..#RolePageRight_Temp') IS NOT NULL BEGIN DROP TABLE #RolePageRight_Temp END
	SELECT RPRM_ID,R_ID,PR_ID,IsRightActive,Active 
	INTO #RolePageRight_Temp from [dbo].[F_Get_RolePageRight_JsonTable] (@Json) s

	DELETE dbo.T_Role_Page_Rights_Mapping WHERE R_ID = (SELECT DISTINCT R_ID FROM #RolePageRight_Temp)
		
	INSERT INTO dbo.T_Role_Page_Rights_Mapping (R_ID, PR_ID, IsRightActive, IsActive, AddedBy, AddedOn)		
	SELECT R_ID, PR_ID, IsRightActive, Active, @Username, GETUTCDATE() FROM #RolePageRight_Temp
	WHERE PR_ID NOT IN (SELECT RPR.PR_ID 
	FROM T_Role_Page_Rights_Mapping rprm WITH (NOLOCK) 
	INNER JOIN #RolePageRight_Temp rpr on  rpr.R_ID = rprm.R_ID and rpr.PR_ID = rprm.PR_ID)
		
	SET @Return_Text = 'Role Page Rights Added Successfully!'
	SET @Return_Code = 1	

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Rights_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	SELECT [value] = R_ID, [text]= RoleName FROM [dbo].[T_Roles] WITH (NOLOCK) ORDER BY RoleName
	SELECT [value] = P_ID, [text]= PageName FROM [dbo].[T_Page] WITH (NOLOCK) ORDER BY PageName
	SELECT [value] = PR_ID, [text]= PageRightName FROM [dbo].[T_Page_Rights] WITH (NOLOCK) ORDER BY PageRightName

END
GO

--Declare @TotalCount int = 0 exec [dbo].[P_Get_PageRight_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_PageRight_List] 
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
	SET @sortExpression = ' P_ID, Sort_, PR_ID asc '  
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
  Declare @P_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageName') then 1 else 0 end)
  Declare @PR_CODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PR_CODE') then 1 else 0 end) 
  Declare @PageRightName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageRightName') then 1 else 0 end)
  Declare @PageRightType_MTV_CODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageRightType_MTV_CODE') then 1 else 0 end)
  Declare @Sort_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sort_') then 1 else 0 end)
  Declare @IsHide_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsHide') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @P_ID_Req bit = (case when @P_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageName') then 0 else 1 end)
  Declare @PR_CODE_Req bit = (case when @PR_CODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PR_CODE') then 0 else 1 end)
  Declare @PageRightName_Req bit = (case when @PageRightName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageRightName') then 0 else 1 end)
  Declare @PageRightType_MTV_CODE_Req bit = (case when @PageRightType_MTV_CODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageRightType_MTV_CODE') then 0 else 1 end)
  Declare @Sort_Req bit = (case when @Sort_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sort_') then 0 else 1 end)
  Declare @IsHide_Req bit = (case when @IsHide_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsHide') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
   
	set @selectSql = N'SELECT PR_ID = pr.PR_ID, P_ID = pr.P_ID'
	+ char(10) + (case when @P_ID_Filtered = 1 then '' else @HideField end) + ',PageName = p.PageName'
	+ char(10) + (case when @PR_CODE_Filtered = 1 then '' else @HideField end) + ',PR_CODE = pr.PR_CODE'
	+ char(10) + (case when @PageRightName_Filtered = 1 then '' else @HideField end) + ',PageRightName = pr.PageRightName'
	+ char(10) + (case when @PageRightType_MTV_CODE_Filtered = 1 then '' else @HideField end) + ',PageRightType_MTV_CODE = pr.PageRightType_MTV_CODE'
	+ char(10) + (case when @Sort_Filtered = 1 then '' else @HideField end) + ',Sort_ = pr.Sort_'
	+ char(10) + (case when @IsHide_Filtered = 1 then '' else @HideField end) + ',IsHide = pr.IsHide'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = pr.IsActive	
	FROM [dbo].[T_Page_Rights] pr with (nolock) 
INNER JOIN [dbo].[T_Page] p with (nolock) ON pr.P_ID = p.P_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Page_Rights] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Page_Rights]
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
	SET @sortExpression = ' PR_ID asc '  
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
  Declare @PageRightsCode_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PR_CODE') then 1 else 0 end)
  Declare @PageRightName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageRightName') then 1 else 0 end)
  Declare @PageRightType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageRightType_MTV_CODE') then 1 else 0 end)
  Declare @Sort_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sort_') then 1 else 0 end) 
  Declare @IsHide_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsHide') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @PageRightsCode_Req bit = (case when @PageRightsCode_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageName') then 0 else 1 end)
  Declare @PageRightName_Req bit = (case when @PageRightName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageRightName') then 0 else 1 end)
  Declare @PageRightType_Req bit = (case when @PageRightType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageRightType_MTV_CODE') then 0 else 1 end)
  Declare @Sort_Req bit = (case when @Sort_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sort_') then 0 else 1 end)
  Declare @IsHide_Req bit = (case when @IsHide_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsHide') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  SET @selectSql = N'select PR_ID = pr.PR_ID, P_ID = pr.P_ID'
	+ char(10) + (case when @PageRightsCode_Filtered = 1 then '' else @HideField end) + ',PR_CODE = pr.PR_CODE'
	+ char(10) + (case when @PageRightName_Filtered = 1 then '' else @HideField end) + ',PageRightName = pr.PageRightName'
	+ char(10) + (case when @PageRightType_Filtered = 1 then '' else @HideField end) + ',PageRightType_MTV_CODE = pr.PageRightType_MTV_CODE'
	+ char(10) + (case when @Sort_Filtered = 1 then '' else @HideField end) + ',Sort_ = pr.Sort_'
	+ char(10) + (case when @IsHide_Filtered = 1 then '' else @HideField end) + ',IsHide = pr.IsHide
	FROM [dbo].[T_Page_Rights] pr with (nolock) where IsActive = 1'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO


--	Declare @TotalCount int = 0 exec [dbo].[P_Get_RolePageRightMap_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_RolePageRightMap_List] 
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
	SET @sortExpression = ' R_ID, PR_ID asc '  
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
  Declare @@RoleGroupName_Req_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageRightName') then 1 else 0 end) 
  Declare @IsRightActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsRightActive') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @RoleName_Req bit = (case when @RoleName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RoleName') then 0 else 1 end)
  Declare @RoleGroupName_Req bit = (case when @@RoleGroupName_Req_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageRightName') then 0 else 1 end)
  Declare @IsRightActive_Req bit = (case when @IsRightActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsRightActive') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  

	set @selectSql = N'SELECT RPRM_ID = rprm.RPRM_ID, R_ID = rprm.R_ID, PR_ID = rprm.PR_ID'
		+ char(10) + (case when @RoleName_Filtered = 1 then '' else @HideField end) + ',RoleName = r.RoleName'
		+ char(10) + (case when @@RoleGroupName_Req_Filtered = 1 then '' else @HideField end) + ',PageRightName =  pr.PageRightName'
		+ char(10) + (case when @@RoleGroupName_Req_Filtered = 1 then '' else @HideField end) + ',IsRightActive =  rprm.IsRightActive'
		+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = rprm.IsActive
		FROM [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) 
	INNER JOIN [dbo].[T_Roles] r with (nolock) ON rprm.R_ID = r.R_ID
	INNER JOIN [dbo].[T_Page_Rights] pr with (nolock) ON rprm.PR_ID = pr.PR_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

-- EXEC [P_Sync_RolePageRights] 3,2,0,0,303,NULL,'HAMMAS.KHAN'
-- EXEC [P_Sync_RolePageRights] 3,2,0,0,303,1,'HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_Sync_RolePageRights]
@RoleID INT,
@RoleIDCompare INT,
@CopyR_ID INT = 0,
@CopyPG_ID INT = 0,
@CopyP_ID INT = 0,
@Active BIT = 0,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''
	set @Active = isnull(@Active,0)

	IF EXISTS (SELECT top 1 1 FROM [dbo].[T_Roles] r with (nolock) where r.R_ID = @RoleIDCompare and r.IsActive = 1 and @RoleIDCompare <> 1)
	BEGIN

		IF (@CopyR_ID = @RoleIDCompare)
		BEGIN
			IF @CopyR_ID > 0
			BEGIN 				
				IF (@Active = 0)
				BEGIN
					DELETE FROM [dbo].[T_Role_Page_Rights_Mapping] 
					where R_ID = @RoleID
				END
		
				INSERT INTO [dbo].[T_Role_Page_Rights_Mapping] (R_ID, PR_ID, IsRightActive, IsActive, AddedBy)
				SELECT R_ID = @RoleID, PR_ID = rprm.PR_ID, rprm.IsRightActive, IsActive, AddedBy = @Username
				FROM [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID = @RoleIDCompare and rprm.IsActive = 1 and @RoleIDCompare <> 1 
				and rprm.RPRM_ID not in (select rprm1.RPRM_ID from [dbo].[T_Role_Page_Rights_Mapping] rprm1 with (nolock) where R_ID = @RoleID)
				and ((rprm.IsRightActive = 1 and @Active = 1) or @Active = 0)
				order by rprm.RPRM_ID
		
				SET @Return_Text = 'Role Rights Synced Successfully!'
				SET @Return_Code = 1		
			END
		END
		ELSE IF (@CopyR_ID != @RoleIDCompare and @CopyR_ID > 0)
		BEGIN
			SET @Return_Text = 'Invalid Copy Role ID'
			SET @Return_Code = 0
		END
		ELSE IF @CopyPG_ID > 0
		BEGIN 
			IF (@Active = 0)
			BEGIN
				DELETE rprm 
				FROM [dbo].[T_Role_Page_Rights_Mapping] rprm
				INNER JOIN [dbo].[T_Page_Rights] pr on rprm.PR_ID = pr.PR_ID
				INNER JOIN [dbo].[T_Page] p on pr.P_ID = p.P_ID
				where rprm.R_ID = @RoleID and p.PG_ID = @CopyPG_ID
			END
		
			INSERT INTO [dbo].T_Role_Page_Rights_Mapping (R_ID, PR_ID, IsRightActive, IsActive, AddedBy)
			SELECT R_ID = @RoleID, PR_ID = rprm.PR_ID, rprm.IsRightActive, rprm.IsActive, AddedBy = @Username
			FROM [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) 
			INNER JOIN [dbo].[T_Page_Rights] pr on rprm.PR_ID = pr.PR_ID
			INNER JOIN [dbo].[T_Page] p on pr.P_ID = p.P_ID
			where rprm.R_ID = @RoleIDCompare and rprm.IsActive = 1 and @RoleIDCompare <> 1 and p.PG_ID = @CopyPG_ID
			and rprm.RPRM_ID not in (select rprm1.RPRM_ID from [dbo].[T_Role_Page_Rights_Mapping] rprm1 with (nolock) where R_ID = @RoleID)
			and ((rprm.IsRightActive = 1 and @Active = 1) or @Active = 0)
			order by rprm.RPRM_ID
		
			SET @Return_Text = 'Page Group Rights Synced Successfully!'
			SET @Return_Code = 1
		
		END
		ELSE IF @CopyP_ID > 0
		BEGIN 
			IF (@Active = 0)
			BEGIN
				DELETE rprm 
				FROM [dbo].[T_Role_Page_Rights_Mapping] rprm
				INNER JOIN [dbo].[T_Page_Rights] pr on rprm.PR_ID = pr.PR_ID
				where rprm.R_ID = @RoleID and pr.P_ID = @CopyP_ID
			END
		
			INSERT INTO [dbo].[T_Role_Page_Rights_Mapping] (R_ID, PR_ID, IsRightActive, IsActive, AddedBy)
			SELECT R_ID = @RoleID, PR_ID = rprm.PR_ID, rprm.IsRightActive, rprm.IsActive, AddedBy = @Username
			FROM [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) 
			INNER JOIN [dbo].[T_Page_Rights] pr on rprm.PR_ID = pr.PR_ID
			where rprm.R_ID = @RoleIDCompare and rprm.IsActive = 1 and @RoleIDCompare <> 1 and pr.P_ID = @CopyP_ID
			and rprm.RPRM_ID not in (select rprm1.RPRM_ID from [dbo].[T_Role_Page_Rights_Mapping] rprm1 with (nolock) where R_ID = @RoleID)
			and ((rprm.IsRightActive = 1 and @Active = 1) or @Active = 0)
			order by rprm.RPRM_ID
		
			SET @Return_Text = 'Page Rights Synced Successfully!'
			SET @Return_Code = 1
		
		END
		ELSE
		BEGIN
			SET @Return_Text = 'NOT Synced Successfully!'
			SET @Return_Code = 1	
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Invalid Compare Role ID'
		SET @Return_Code = 0
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

-- [dbo].[P_Get_Page_Rights_Struct_Class] '2024-03-22','2024-03-22',null,0,0
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Page_Rights_Struct_Class]
	@FromDate date = null
	,@ToDate date = null
	,@Page_ID int = null
	,@IsIncludeClassName bit = 1
	,@IsIncludeRegion bit = 1
AS
BEGIN
	
	Declare @tmp table (ID int identity(1,1), PR_ID int, P_ID int, PageName nvarchar(50), PR_CODE nvarchar(50), PageRightName nvarchar(50), PageRightType_MTV_CODE nvarchar(20), AddedOn datetime, ModifiedOn datetime)
	insert into @tmp (PR_ID, P_ID, PageName, PR_CODE, PageRightName , PageRightType_MTV_CODE, AddedOn , ModifiedOn )
	select PR_ID, pr.P_ID, p.PageName, PR_CODE, PageRightName, PageRightType_MTV_CODE, pr.AddedOn , pr.ModifiedOn 
	from [dbo].[T_Page_Rights] pr with (nolock) 
	inner join [dbo].[T_Page] p with (nolock) on pr.P_ID = p.P_ID
	where ((cast(pr.AddedOn as date) >= @FromDate or @FromDate is null) or (cast(pr.ModifiedOn as date) >= @FromDate or @FromDate is null))
	and ((cast(pr.AddedOn as date) <= @ToDate or @ToDate is null) or (cast(pr.ModifiedOn as date) <= @ToDate or @ToDate is null))
	and (p.P_ID = @Page_ID or @Page_ID is null)
	and pr.PR_ID <> 100100
	order by P_ID, pr.Sort_, PR_ID
	
	select * from @tmp

	Declare @StructClassIDString nvarchar(max) = ''
	Declare @StructClassCodeString nvarchar(max) = ''
	Declare @PR_ID int = 0
	Declare @PR_CODE nvarchar(50) = ''
	Declare @PageRightName nvarchar(50) = ''
	Declare @PageRightType_MTV_CODE nvarchar(20) = ''
	Declare @P_ID int = 0
	Declare @PreviousP_ID int = 0
	Declare @PageName nvarchar(50) = ''
	Declare @PreviousPageName nvarchar(50) = ''

	if exists(select * from @tmp) and @IsIncludeClassName = 1
	begin
		set @StructClassIDString = 'public struct RightsList_ID 
		{'
		set @StructClassCodeString = 'public struct RightsList_Code 
		{'
	end

	Declare @TryCount int = 1
	Declare @MaxCount int = (select count(*) from @tmp)
	set @MaxCount = ISNULL(@MaxCount,0)
	
	WHILE @TryCount <= @MaxCount
	BEGIN
		select @PR_ID = PR_ID 
		,@P_ID = P_ID 
		,@PageName = replace(PageName,' ','')
		,@PR_CODE = PR_CODE 
		,@PageRightName = replace(replace(replace(replace(PageRightName,' ','_'),'&','And'),'/','_'),',','_')
		,@PageRightType_MTV_CODE = PageRightType_MTV_CODE
		from @tmp where ID = @TryCount

		if (@PageName <> '' and @PreviousPageName <> '' and @PageName <> @PreviousPageName and @TryCount > 0) and @IsIncludeRegion = 1
		begin
			set @StructClassIDString = @StructClassIDString + ' 
			#endregion ' + @PreviousPageName + ';'

			set @StructClassCodeString = @StructClassCodeString + ' 
			#endregion ' + @PreviousPageName + ';'
		end

		if ((@PageName <> '' and @PreviousPageName <> '' and @PageName <> @PreviousPageName) or @TryCount = 1) and @IsIncludeRegion = 1
		begin
			set @StructClassIDString = @StructClassIDString + ' 
			#region ' + @PageName + ';'

			set @StructClassCodeString = @StructClassCodeString + ' 
			#region ' + @PageName + ';'
		end

		set @StructClassIDString = @StructClassIDString + ' 
		public const int ' + @PageRightName + ' = ' + cast(@PR_ID as nvarchar(20)) + ';'

		set @StructClassCodeString = @StructClassCodeString + ' 
		public const string ' + @PageRightName + ' = "' + @PR_CODE + '";'

		if (@TryCount = @MaxCount) and @IsIncludeRegion = 1
		begin
			set @StructClassIDString = @StructClassIDString + ' 
			#endregion ' + @PreviousPageName + ';'

			set @StructClassCodeString = @StructClassCodeString + ' 
			#endregion ' + @PreviousPageName + ';'
		end

		set @PreviousP_ID = @P_ID
		set @PreviousPageName = @PageName
		set @TryCount = @TryCount + 1
	END

	if exists(select * from @tmp) and @IsIncludeClassName = 1
	begin
		set @StructClassIDString = @StructClassIDString + '
		}'
		set @StructClassCodeString = @StructClassCodeString + '
		}'
	end

	select @StructClassIDString  as StructClassIDString ,@StructClassCodeString  as StructClassCodeString 

END
GO