
--	EXEC P_AddOrEdit_Page 0,10,'Events Setup','/Settings/EventsSetup',148100,0,1,'HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_AddOrEdit_Page]
@P_ID INT = NULL,
@PG_ID INT,
@PageName nvarchar(50),
@PageUrl nvarchar(250),
@Application_MTV_ID INT,
@IsHide BIT = 0,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = Null
AS
BEGIN
	DECLARE @maxSortValue INT
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @P_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [dbo].T_Page WHERE P_ID = @P_ID)
	BEGIN
	    
		DECLARE @OldPageName nvarchar(150)
		DECLARE @OldPageUrl nvarchar(250)
		DECLARE @OldApplication_MTV_ID INT
		DECLARE @OldIsHide BIT
		DECLARE @OldActive BIT

		SELECT @OldPageName = PageName, @OldIsHide = IsHide, @OldActive = IsActive FROM [dbo].T_Page WHERE P_ID = @P_ID
		
		UPDATE [dbo].T_Page SET PageName = @PageName, PageUrl = @PageUrl, Application_MTV_ID = @Application_MTV_ID, IsHide = @IsHide, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE P_ID = @P_ID
		
		IF @OldPageName <> @PageName
		BEGIN	
			exec [dbo].P_Add_Audit_History 'PageName' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldPageName, @PageName, @OldPageName, @PageName, '', 0, 167100, @UserName
		END

		IF @OldPageUrl <> @PageUrl
		BEGIN	
			exec [dbo].P_Add_Audit_History 'PageUrl' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldPageUrl, @PageUrl, @OldPageUrl, @PageUrl, '', 0, 167100, @UserName
		END

		IF @OldApplication_MTV_ID <> @Application_MTV_ID
		BEGIN	
			exec [dbo].P_Add_Audit_History 'Application_MTV_ID' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldApplication_MTV_ID, @Application_MTV_ID, @OldApplication_MTV_ID, @Application_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldIsHide <> @IsHide
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsHide = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsHide = 1 then 'Yes' else 'No' end)
			exec [dbo].P_Add_Audit_History 'IsHide' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldIsHide, @IsHide, @OldIsHideText, @IsHideText, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [dbo].P_Add_Audit_History 'IsActive' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'Page Updated Successfully!'
		SET @Return_Code = 1

	END
	ELSE
	BEGIN
		SET @Return_Text = 'Page does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @PageName <> '' AND @PageUrl <> '' AND @PG_ID > 0 BEGIN
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [dbo].T_Page WITH (NOLOCK) WHERE PG_ID = @PG_ID
		SELECT @P_ID = (CASE WHEN ISNULL(MAX(P_ID),0) = 0 THEN @PG_ID * 100 ELSE ISNULL(MAX(P_ID),0) + 1 END) FROM [dbo].T_Page WITH (NOLOCK) WHERE PG_ID = @PG_ID
		INSERT INTO [dbo].T_Page (P_ID, PG_ID, PageName, PageURL, Application_MTV_ID, Sort_, IsHide, IsActive, AddedBy, AddedOn) VALUES (@P_ID, @PG_ID, @PageName, @PageUrl, @Application_MTV_ID, @maxSortValue, @IsHide, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Page Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Page Not Found!'
		set @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

--	EXEC P_AddOrEdit_PageGroup 10,'Setting',0,1,'HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_AddOrEdit_PageGroup]
@PG_ID INT = NULL,
@PageGroupName nvarchar(50),
@IsHide BIT = 0,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @PG_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [dbo].[T_Page_Group] WITH (NOLOCK) WHERE PG_ID = @PG_ID)
	BEGIN
	    
		DECLARE @OldPageGroupName nvarchar(150)
		DECLARE @OldIsHide BIT
		DECLARE @OldActive BIT
		
		SELECT @OldPageGroupName = PageGroupName, @OldIsHide = IsHide, @OldActive = IsActive FROM [dbo].T_Page_Group WITH (NOLOCK) WHERE PG_ID = @PG_ID
		
		UPDATE [dbo].T_Page_Group SET PageGroupName = @PageGroupName, IsHide = @IsHide, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE PG_ID = @PG_ID

		IF @OldPageGroupName <> @PageGroupName
		BEGIN	
			exec [dbo].P_Add_Audit_History 'PageGroupName' ,'T_Page_Group', @PG_ID, 166100, @PG_ID, '', '', @OldPageGroupName, @PageGroupName, @OldPageGroupName, @PageGroupName, '', 0, 167100, @UserName
		END

		IF @OldIsHide <> @IsHide
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsHide = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsHide = 1 then 'Yes' else 'No' end)
			exec [dbo].P_Add_Audit_History 'IsHide' ,'T_Page_Group', @PG_ID, 166100, @PG_ID, '', '', @OldIsHide, @IsHide, @OldIsHideText, @IsHideText, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [dbo].P_Add_Audit_History 'IsActive' ,'T_Page_Group', @PG_ID, 166100, @PG_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	
		

		SET @Return_Text = 'Page Group Name Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Page Group does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @PageGroupName <> '' BEGIN
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1, @PG_ID = ISNULL(MAX(PG_ID),0) + 1 FROM dbo.T_Page_Group WITH (NOLOCK)
		INSERT INTO [dbo].T_Page_Group (PG_ID, PageGroupName, Sort_, IsHide, IsActive, AddedBy, AddedOn) VALUES (@PG_ID, @PageGroupName, @maxSortValue, @IsHide, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Page Group Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Page Group Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_PageGroup_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '[]', '[{"Code":"RowNo","Name":"#","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"PG_ID","Name":"Page ID","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"PageGroupName","Name":"Page Group Name","IsColumnRequired":false,"IsHidden":false,"IsChecked":false},{"Code":"Sort_","Name":"Sort_","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"IsHide","Name":"IsHide","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"IsActive","Name":"IsActive","IsColumnRequired":false,"IsHidden":false,"IsChecked":false},{"Code":"Action","Name":"Action","IsColumnRequired":false,"IsHidden":false,"IsChecked":false}]' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_PageGroup_List]
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
	SET @sortExpression = ' PG_ID asc '  
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
  Declare @PageGroupName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageGroupName') then 1 else 0 end)
  Declare @Sort_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sort_') then 1 else 0 end) 
  Declare @IsHide_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsHide') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @PageGroupName_Req bit = (case when @PageGroupName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageGroupName') then 0 else 1 end)
  Declare @Sort_Req bit = (case when @Sort_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sort_') then 0 else 1 end)
  Declare @IsHide_Req bit = (case when @IsHide_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsHide') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
	set @selectSql = N'select PG_ID = pg.PG_ID'
	+ char(10) + (case when @PageGroupName_Filtered = 1 then '' else @HideField end) + (case when @PageGroupName_Req = 0 then '' else ',PageGroupName = pg.PageGroupName' end)
	+ char(10) + (case when @Sort_Filtered = 1 then '' else @HideField end) + (case when @Sort_Req = 0 then '' else ',Sort_ = pg.Sort_' end)
	+ char(10) + (case when @IsHide_Filtered = 1 then '' else @HideField end) + (case when @IsHide_Req = 0 then '' else ',IsHide = pg.IsHide' end)
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + (case when @IsActive_Req = 0 then '' else ',IsActive = pg.IsActive' end)
	+ char(10) + 'FROM [dbo].[T_Page_Group] pg with (nolock)'
	
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

-- Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Page_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Page_List]
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
	SET @sortExpression = ' PG_ID asc '  
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
  Declare @PG_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageGroupName') then 1 else 0 end)
  Declare @PageName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageName') then 1 else 0 end) 
  Declare @PageURL_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageURL') then 1 else 0 end)
  Declare @Application_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application') then 1 else 0 end)
  Declare @Sort_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sort') then 1 else 0 end)
  Declare @IsHide_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsHide') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @PG_ID_Req bit = (case when @PG_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageGroupName') then 0 else 1 end)
  Declare @PageName_Req bit = (case when @PageName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageName') then 0 else 1 end)
  Declare @PageURL_Req bit = (case when @PageURL_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PageURL') then 0 else 1 end)
  Declare @Application_Req bit = (case when @Application_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application') then 0 else 1 end)
  Declare @Sort_Req bit = (case when @Sort_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sort') then 0 else 1 end)
  Declare @IsHide_Req bit = (case when @IsHide_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsHide') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)

  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
   
	set @selectSql = N'select P_ID = p.P_ID, PG_ID = p.PG_ID, Application_MTV_ID = p.Application_MTV_ID'
	+ char(10) + (case when @PG_ID_Filtered = 1 then '' else @HideField end) + ',PageGroupName = pg.PageGroupName'
	+ char(10) + (case when @PageName_Filtered = 1 then '' else @HideField end) + ',PageName = p.PageName'
	+ char(10) + (case when @PageURL_Filtered = 1 then '' else @HideField end) + ',PageURL = p.PageURL'
	+ char(10) + (case when @Application_Filtered = 1 then '' else @HideField end) + ',[Application] = mtv.Name'
	+ char(10) + (case when @Sort_Filtered = 1 then '' else @HideField end) + ',Sort_ = p.Sort_'
	+ char(10) + (case when @IsHide_Filtered = 1 then '' else @HideField end) + ',IsHide = p.IsHide'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = p.IsActive
	FROM [dbo].[T_Page] p with (nolock)
	INNER JOIN [dbo].[T_Page_Group] pg with (nolock) ON p.PG_ID = pg.PG_ID
	INNER JOIN [dbo].[T_Master_Type_Value] mtv with (nolock) ON p.Application_MTV_ID = mtv.MTV_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Page_Setup_DropDown_Lists]
	@Username nvarchar(150)

AS
BEGIN
	
	select [value] = PG_ID, [text]= PageGroupName from [dbo].[T_Page_Group] with (nolock) order by PageGroupName

	select [value] = P_ID, [text]= PageName from [dbo].[T_Page] with (nolock) order by PageName

	SELECT [value] = [MTV_ID] ,[text]= [Name] FROM [dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 148 order by [Name]
END
GO

 CREATE OR ALTER PROCEDURE [dbo].[P_Get_PageChart_Dropdown_Lists]
AS
BEGIN
	
	SELECT code = MTV_CODE, [name] = SubName FROM [dbo].[F_Get_MTV_List_By_ID] (148, null) ORDER BY Sort_
	SELECT code = R_ID, [name] = RoleName FROM [dbo].[T_Roles] WITH (NOLOCK) WHERE IsActive = 1
	SELECT code = UserName, [name] = CONCAT(FirstName, ' ', LastName) FROM [dbo].[T_Users] WITH (NOLOCK) WHERE IsActive = 1 

END
GO

-- EXEC [P_Update_PageGroup_Sorting] '[{"New_Sort_Value":1,"Sort_ID":1,"Sort_Text":"General","Old_Sort_Value":1},{"New_Sort_Value":2,"Sort_ID":2,"Sort_Text":"Home","Old_Sort_Value":2},{"New_Sort_Value":3,"Sort_ID":3,"Sort_Text":"Medical Claim","Old_Sort_Value":3},{"New_Sort_Value":4,"Sort_ID":5,"Sort_Text":"Reports","Old_Sort_Value":4},{"New_Sort_Value":5,"Sort_ID":4,"Sort_Text":"Security","Old_Sort_Value":5}]','HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_Update_Page_Sorting]
@Json nvarchar(max),
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

	IF OBJECT_ID('tempdb..#Sorting_Temp') IS NOT NULL BEGIN DROP TABLE #Sorting_Temp END
	SELECT New_Sort_Value,Sort_ID,Sort_Text,Old_Sort_Value 
	INTO #Sorting_Temp from [dbo].[F_Get_Sorting_JsonTable] (@Json) s
	INNER JOIN [dbo].T_Page p WITH (NOLOCK) ON s.Sort_ID = p.P_ID
	WHERE s.New_Sort_Value <> p.Sort_
	
	
	IF EXISTS (SELECT 1 FROM #Sorting_Temp WITH (NOLOCK))
	BEGIN	
		UPDATE [dbo].T_Page
		SET Sort_ = t.New_Sort_Value 
		FROM #Sorting_Temp t WHERE P_ID = t.Sort_ID		
		SET @Return_Text = 'Page Sorting UPDATED Successfully!'
		SET @Return_Code = 1	
	END
	ELSE BEGIN
		SET @Return_Text = 'Data Already Sorted'
		SET @Return_Code = 0
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

-- EXEC [P_Update_PageGroup_Sorting] '[{"New_Sort_Value":1,"Sort_ID":1,"Sort_Text":"General","Old_Sort_Value":1},{"New_Sort_Value":2,"Sort_ID":2,"Sort_Text":"Home","Old_Sort_Value":2},{"New_Sort_Value":3,"Sort_ID":3,"Sort_Text":"Medical Claim","Old_Sort_Value":3},{"New_Sort_Value":4,"Sort_ID":5,"Sort_Text":"Reports","Old_Sort_Value":4},{"New_Sort_Value":5,"Sort_ID":4,"Sort_Text":"Security","Old_Sort_Value":5}]','HAMMAS.KHAN'
 CREATE OR ALTER PROC [dbo].[P_Update_PageGroup_Sorting]
@Json nvarchar(max),
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

	IF OBJECT_ID('tempdb..#Sorting_Temp') IS NOT NULL BEGIN DROP TABLE #Sorting_Temp END
	SELECT New_Sort_Value,Sort_ID,Sort_Text,Old_Sort_Value 
	INTO #Sorting_Temp from [dbo].[F_Get_Sorting_JsonTable] (@Json) s
	INNER JOIN [dbo].T_Page_Group pg WITH (NOLOCK) ON s.Sort_ID = pg.PG_ID
	WHERE s.New_Sort_Value <> pg.Sort_
	
	
	IF EXISTS (SELECT 1 FROM #Sorting_Temp WITH (NOLOCK))
	BEGIN	
		UPDATE [dbo].T_Page_Group
		SET Sort_ = t.New_Sort_Value 
		FROM #Sorting_Temp t WHERE PG_ID = t.Sort_ID		
		SET @Return_Text = 'Page Group Sorting UPDATED Successfully!'
		SET @Return_Code = 1	
	END
	ELSE BEGIN
		SET @Return_Text = 'Data Already Sorted'
		SET @Return_Code = 0
	END

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

-- [dbo].[P_Get_Pages_Info_By_User] 'HAMMA>KHAN', 148100
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Pages_Info_By_User] 
	-- Add the parameters for the stored procedure here
    @USERNAME nvarchar(150)
	,@Application_MTV_ID int 
	,@CurrentURL nvarchar(250) = ''
As
Begin
	
	DECLARE @Is_Admin bit = 0

	Declare @ROLE_ID int = 0
	Declare @IsGroupRoleID bit = 0
	
	select @ROLE_ID = ROLE_ID, @IsGroupRoleID = [IsGroupRoleID] FROM [dbo].[T_User_Role_Mapping] with (nolock) where USERNAME = @USERNAME and [IsActive] = 1

	Declare @RolesTable table (R_ID int)
	insert into @RolesTable
	select @ROLE_ID where @IsGroupRoleID = 0

	insert into @RolesTable
	select RG_ID from [dbo].[T_Role_Group_Mapping] with (nolock) where RG_ID = @ROLE_ID and @IsGroupRoleID = 1

	if exists(select * from @RolesTable where R_ID in (12,16))
	begin
		set @Is_Admin = 1
	end
	
	Declare @PageRightsTable table (P_ID int, PR_ID int, PG_ID int)
	if (@Is_Admin=0)
	begin
		insert into @PageRightsTable
		select p.P_ID, pr.PR_ID, p.PG_ID
		from [dbo].[T_Page_Rights] pr with (nolock) 
		inner join [dbo].[T_Page] p with (nolock) on pr.P_ID = p.P_ID
		where p.Application_MTV_ID in (@Application_MTV_ID,0) and pr.PageRightType_MTV_CODE='VIEW' and pr.IsActive = 1 and p.IsActive = 1
			and pr.PR_ID in (select rprm.PR_ID from [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable))
	end

	drop table if exists #PageGroupTable
	select pg.PG_ID,pg.PageGroupName,pg.Sort_
	,FirstURL=isnull((select top 1 p.PageURL from [dbo].[T_Page] p with (nolock) where p.PG_ID = pg.PG_ID and p.Application_MTV_ID in (@Application_MTV_ID,0) order by p.Sort_),'')
	into #PageGroupTable
	from [dbo].[T_Page_Group] pg with (nolock) where pg.IsHide = 0 and pg.IsActive = 1 
		and ((pg.PG_ID in (select PG_ID from @PageRightsTable) and @Is_Admin = 0) or @Is_Admin = 1)
	Order by pg.Sort_

	set @CurrentURL = (case when left(@CurrentURL,1) = '/' then '' else '/' end) + @CurrentURL

	Declare @CurrentPG_ID int = 0
	Declare @CurrentP_ID int = 0
	select @CurrentPG_ID=p.PG_ID ,@CurrentP_ID=p.P_ID from [dbo].[T_Page] p with (nolock) where p.PageURL= @CurrentURL and p.Application_MTV_ID in (@Application_MTV_ID,0)

	select pg.PG_ID,pg.PageGroupName,pg.Sort_,pg.FirstURL
	,PageGroupSelected=(case when @CurrentPG_ID = pg.PG_ID then 'selected' else '' end)
	,PageGroupActive=(case when @CurrentPG_ID = pg.PG_ID then 'active' else '' end)
	,PageGroupActiveIn=(case when @CurrentPG_ID = pg.PG_ID then 'in' else '' end)
	,CurrentPG_ID=@CurrentPG_ID
	from #PageGroupTable pg where pg.FirstURL <> '' order by pg.Sort_

	select p.P_ID,p.PG_ID,p.PageName,p.PageURL,p.Sort_
	,PageActive=(case when @CurrentP_ID = p.P_ID then 'active' else '' end)
	,CurrentP_ID=@CurrentP_ID
	from [dbo].[T_Page] p with (nolock) 
	inner join [dbo].[T_Page_Group] pg with (nolock) on p.PG_ID = pg.PG_ID and pg.IsHide = 0 and pg.IsActive = 1
	where p.Application_MTV_ID in (@Application_MTV_ID,0) and p.IsHide = 0 and p.IsActive = 1
	and ((p.P_ID in (select P_ID from @PageRightsTable) and @Is_Admin = 0) or @Is_Admin = 1)
	Order by pg.Sort_,pg.PG_ID,p.Sort_
	
End
GO