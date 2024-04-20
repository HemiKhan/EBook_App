
-- EXEC [P_AddOrEdit_MasterType] 103,'Billing Type 1','',1,'HAMMAS.KHAN',''
CREATE OR ALTER PROC [dbo].[P_AddOrEdit_MasterType]
@MT_ID INT = NULL,
@MasterTypeName nvarchar(50),
@Description nvarchar(150) = '',
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @MT_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [dbo].[T_Master_Type] with (nolock) WHERE MT_ID = @MT_ID)
	BEGIN
	    
		DECLARE @OldMasterTypeName nvarchar(150)
		DECLARE @OldDescription nvarchar(250)
		DECLARE @OldActive BIT

		SELECT @OldMasterTypeName = Name, @OldDescription = Description, @OldActive = IsActive FROM [dbo].[T_Master_Type] with (nolock) WHERE MT_ID = @MT_ID
		
		UPDATE dbo.T_Master_Type SET Name = @MasterTypeName, Description = @Description, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE MT_ID = @MT_ID
		
		IF @OldMasterTypeName <> @MasterTypeName
		BEGIN	
			exec dbo.P_Add_Audit_History 'Name', 'T_Master_Type', @MT_ID, 166109, @MT_ID, '', '', @OldMasterTypeName, @MasterTypeName, @OldMasterTypeName, @MasterTypeName, '', 0, 167100, @UserName
		END

		IF @OldDescription <> @Description
		BEGIN	
			exec dbo.P_Add_Audit_History 'Description', 'T_Master_Type', @MT_ID, 166109, @MT_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 167100, @UserName
		END	

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec dbo.P_Add_Audit_History 'IsActive' ,'T_Master_Type', @MT_ID, 166109, @MT_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'Master Type Updated Successfully!'
		SET @Return_Code = 1

	END
	ELSE
	BEGIN
		SET @Return_Text = 'Master Type does not exist!'
		SET @Return_Code = 0
	END
END

ELSE BEGIN
	IF @MasterTypeName <> '' BEGIN
		SELECT @MT_ID = ISNULL(MAX(MT_ID),0) + 1 FROM [dbo].[T_Master_Type] WITH (NOLOCK) 
		INSERT INTO [dbo].[T_Master_Type] (MT_ID, Name, Description, IsActive, AddedBy, AddedOn) VALUES (@MT_ID, @MasterTypeName, @Description, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Master Type Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Master Type Name Not Found!'
		set @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

-- EXEC [P_AddOrEdit_MasterTypeValue] 0,174,'PRIMARY_DOMAIN','Primary Domain',0,1,'ABDULLAH.ARSHAD',''
CREATE OR ALTER PROC [dbo].[P_AddOrEdit_MasterTypeValue]
@MTV_ID INT = NULL,
@MT_ID INT,
@MTV_CODE nvarchar(20) = '',
@MasterTypeValueName nvarchar(50),
@Sub_MTV_ID int,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @MTV_ID > 0 
BEGIN

	IF EXISTS (SELECT 1 FROM [dbo].[T_Master_Type_Value] with (nolock) WHERE MTV_ID = @MTV_ID)
	BEGIN
	    
		DECLARE @OldMTV_Code nvarchar(20)
		DECLARE @OldMasterTypeValueName nvarchar(50)
		DECLARE @OldSub_MTV_ID int
		DECLARE @OldActive BIT

		SELECT @OldMTV_Code = MTV_CODE, @OldMasterTypeValueName = Name, @OldSub_MTV_ID = Sub_MTV_ID ,@OldActive = IsActive FROM [dbo].[T_Master_Type_Value] with (nolock) WHERE MTV_ID = @MTV_ID
		
		UPDATE dbo.T_Master_Type_Value SET MTV_Code = @MTV_CODE, Name = @MasterTypeValueName, Sub_MTV_ID = @Sub_MTV_ID ,IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE MTV_ID = @MTV_ID
		
		IF @OldMTV_Code <> @MTV_CODE
		BEGIN	
			exec [dbo].P_Add_Audit_History 'MTV_Code' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldMTV_Code, @MTV_CODE, @OldMTV_Code, @MTV_CODE, '', 0, 167100, @UserName
		END

		IF @OldMasterTypeValueName <> @MasterTypeValueName
		BEGIN	
			exec [dbo].P_Add_Audit_History 'Name' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldMasterTypeValueName, @MasterTypeValueName, @OldMasterTypeValueName, @MasterTypeValueName, '', 0, 167100, @UserName
		END

		IF @OldSub_MTV_ID <> @Sub_MTV_ID
		BEGIN	
			exec [dbo].P_Add_Audit_History 'Sub_MTV_ID' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldSub_MTV_ID, @Sub_MTV_ID, @OldSub_MTV_ID, @Sub_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [dbo].P_Add_Audit_History 'IsActive' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'Master Type Value Updated Successfully!'
		SET @Return_Code = 1

	END
	ELSE
	BEGIN
		SET @Return_Text = 'Master Type Value does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
	BEGIN
		DECLARE @maxSortValue INT
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = @MT_ID
		SELECT @MTV_ID = (CASE WHEN ISNULL(MAX(MTV_ID),0) = 0 THEN cast((cast(@MT_ID as nvarchar(max)) + '100') as int) ELSE ISNULL(MAX(MTV_ID),0) + 1 END) FROM [dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = @MT_ID
		IF @MTV_CODE = '' BEGIN SET @MTV_CODE = @MTV_ID END
		INSERT INTO [dbo].[T_Master_Type_Value] (MTV_ID, MT_ID, MTV_CODE, Name, Sort_, Sub_MTV_ID ,IsActive, AddedBy, AddedOn) VALUES (@MTV_ID, @MT_ID, @MTV_CODE, @MasterTypeValueName, @maxSortValue, @Sub_MTV_ID ,@Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Master Type Value Added Successfully!'
		set @Return_Code = 1
	END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO

--	exec [P_Get_Master_Setup_DropDown_Lists] 'HAMMAS.KHAN'
CREATE OR ALTER PROCEDURE [dbo].[P_Get_Master_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	select [value] = MT_ID, [text]= [Name] from [dbo].[T_Master_Type] with (nolock) order by [Name]

	select [value] = MTV_ID , [text]= Name from [dbo].[T_Master_Type_Value] with (nolock) WHERE IsActive = 1 order by [Name]
END
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_MasterType_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
CREATE OR ALTER PROCEDURE [dbo].[P_Get_MasterType_List] 
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
	SET @sortExpression = ' MT_ID asc '  
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
  Declare @MasterTypeName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end)
  Declare @Description_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Description') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @MasterTypeName_Req bit = (case when @MasterTypeName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
  Declare @Description_Req bit = (case when @Description_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Description') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  	set @selectSql = N'select MT_ID = mt.MT_ID'
	+ char(10) + (case when @MasterTypeName_Filtered = 1 then '' else @HideField end) + ',MasterTypeName = mt.Name'
	+ char(10) + (case when @Description_Filtered = 1 then '' else @HideField end) + ',Description = mt.Description'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = mt.IsActive
	FROM [dbo].[T_Master_Type] mt with (nolock)'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_MasterTypeValue_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
CREATE OR ALTER PROCEDURE [dbo].[P_Get_MasterTypeValue_List] 
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
	SET @sortExpression = ' MT_ID , Sort_ ,MTV_ID asc '  
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
  Declare @MTV_CODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MTV_CODE') then 1 else 0 end)
  Declare @MasterType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end)
  Declare @MasterTypeValue_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end) 
  Declare @Sub_MTV_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sub_MTV_ID') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @MTV_CODE_Req bit = (case when @MTV_CODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MTV_CODE') then 0 else 1 end)
  Declare @MasterType_Req bit = (case when @MasterType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
  Declare @MasterTypeValue_Req bit = (case when @MasterTypeValue_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
  Declare @Sub_MTV_ID_Req bit = (case when @Sub_MTV_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sub_MTV_ID') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'select MTV_ID = mtv.MTV_ID, MT_ID = mtv.MT_ID'
	+ char(10) + (case when @MasterType_Filtered = 1 then '' else @HideField end) + ',MTV_CODE = mtv.MTV_CODE'
	+ char(10) + (case when @MasterType_Filtered = 1 then '' else @HideField end) + ',MasterType = mt.Name'
	+ char(10) + (case when @MasterTypeValue_Filtered = 1 then '' else @HideField end) + ',MasterTypeValue = mtv.Name, Sort_'
	+ char(10) + (case when @Sub_MTV_ID_Filtered = 1 then '' else @HideField end) + ',Sub_MTV_ID = mtv.Sub_MTV_ID'
	+ char(10) + (case when @Sub_MTV_ID_Filtered = 1 then '' else @HideField end) + ',Sub_MTV_Name = (case when mtv.Sub_MTV_ID = 0 then '''' else (select top 1 m.[Name] from [dbo].[T_Master_Type_Value] m with (nolock) where m.MTV_ID = mtv.Sub_MTV_ID) end)'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = mtv.IsActive
	FROM [dbo].[T_Master_Type_Value] mtv with (nolock) 
	INNER JOIN [dbo].[T_Master_Type] mt with (nolock) ON mtv.MT_ID = mt.MT_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

