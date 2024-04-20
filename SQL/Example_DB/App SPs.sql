

-- [dbo].[P_Get_MTV_List_By_ID] 111
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_MTV_List_By_ID]
	@MT_ID int
	,@Username nvarchar(150) = null
AS
BEGIN	
	select MT_ID,[Name],MTV_ID,MTV_CODE,SubName,Sort_ from [dbo].[F_Get_MTV_List_By_ID] (@MT_ID,@Username) order by Sort_
END
GO

 CREATE OR ALTER PROCEDURE [dbo].[P_Auto_Insert_Columns_In_Audit_Column_Table]
AS
BEGIN

	drop table if exists #oldtmptablecolumn
	select * into #oldtmptablecolumn from (
		SELECT AC_ID, [TableName] ,[DbName] ,[ConcTableAndColumnName]=([TableName] + ' (' + [DbName] + ')')
		FROM [dbo].[T_Audit_Column] with (nolock)
	) ilv
	
	drop table if exists #newtmptablecolumn
	SELECT [Table Name]=ilv.[TABLE_NAME], [Column Name] = ilv.COLUMN_NAME, [Conc Table Column Name] = (ilv.[TABLE_NAME] + ' (' + ilv.[COLUMN_NAME] + ')') into #newtmptablecolumn FROM (
		SELECT isc.[TABLE_NAME],COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS isc
		inner join INFORMATION_SCHEMA.TABLES ist on isc.[TABLE_NAME] = ist.[TABLE_NAME] and ist.TABLE_TYPE = 'BASE TABLE' and ist.[TABLE_NAME] <> 'T_Audit_Column' 
		and isc.COLUMN_NAME not in ('TimeStamp',' CREATE OR ALTERdBy',' CREATE OR ALTERdOn','AddedBy','AddedOn','ModifiedBy','ModifiedOn','OrderID','OrderNo','OrderNoGUID')
	) ilv

	insert into [dbo].[T_Audit_Column] ([TableName],[DbName],[Name],[AddedBy])
	select [Table Name] ,[Column Name] ,[Column Name] ,'AUTOIMPORT' from #newtmptablecolumn A
	where A.[Conc Table Column Name] not in (Select B.[ConcTableAndColumnName] from #oldtmptablecolumn B)

	drop table if exists #deleteACIDs
	select * into #deleteACIDs from [dbo].[T_Audit_Column] au with (nolock)
	where (au.[TableName] + ' (' + au.[DbName] + ')') not in (select n.[Conc Table Column Name] from #newtmptablecolumn n)
	and au.AC_ID not in (select ah.AC_ID from [dbo].[T_Audit_History] ah with (nolock))

	delete from [dbo].[T_Audit_Column] where AC_ID in (select d.AC_ID from #deleteACIDs d)

END
GO

 CREATE OR ALTER PROCEDURE [dbo].[P_Add_Audit_History]
(
	@ColumnName nvarchar(100),
	@TableName nvarchar(100),
	@REF_NO nvarchar(150),
	@AuditType_MTV_ID int,
	@RefNo1 nvarchar(50),
	@RefNo2 nvarchar(50),
	@RefNo3 nvarchar(50),
	@OldValueHidden nvarchar(2000),
	@NewValueHidden nvarchar(2000),
	@OldValue nvarchar(2000),
	@NewValue nvarchar(2000),
	@Reason nvarchar(1000),
	@IsAuto bit,
	@Source_MTV_ID int,
	@ChangedBy nvarchar(150),
	@TriggerDebugInfo nvarchar(max) = null
)

AS

BEGIN  

if (@NewValue = @OldValue)
begin
	return
end

set nocount on;

begin try

	declare @AC_ID int = 0
	
	select @AC_ID = [dbo].[F_Get_AC_ID] (@ColumnName,@TableName)

	if (@AC_ID > 0)
	begin
		insert into [T_Audit_History] (AC_ID, REF_NO, AuditType_MTV_ID, RefNo1, RefNo2, RefNo3, OldValueHidden, NewValueHidden, OldValue, NewValue, Reason, IsAuto, Source_MTV_ID, TriggerDebugInfo, ChangedBy)
		values (@AC_ID, @REF_NO, @AuditType_MTV_ID, @RefNo1, @RefNo2, @RefNo3, @OldValueHidden, @NewValueHidden, @OldValue, @NewValue, @Reason, @IsAuto, @Source_MTV_ID, @TriggerDebugInfo, @ChangedBy)
	end
	else
	begin
		raiserror ('P_Add_Audit_History: %d: %s', 16, 1, 547, 'Column Does Not Exists In Audit Column Table');
	end

	--if (@trancount = 0)
	--	commit;
end try 
begin catch
	declare @error int, @message varchar(4000), @xstate int;
	select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
	
	raiserror ('usp_my_procedure_name: %d: %s', 16, 1, @error, @message) ;
end catch

END

GO

 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Common_List]
(
	@SelectSql nvarchar(max),
	@PageIndex int,
	@PageSize int,
	@SortExpression nvarchar(max),
	@FilterClause nvarchar(max),
	@SetTop int,
	@TotalRowCount int OUTPUT
)

AS

BEGIN 		

	Declare @Sql nvarchar(max)	

	if (@PageSize > 0) 
	begin
		--Get List with Pagination
		set @Sql =N'select * from (
						select top (' + cast(@SetTop as nvarchar(50)) + ') 
							RowNo = row_number() over (order by ' + @SortExpression + ')
							, ilv.*
						from ('+ replace(@SelectSql,',hidefield=0','') +') ilv
					where 1 = 1  '+ @FilterClause + ' order by rowno ) ilvouter '
					+ ' order by rowno 
					OFFSET ' + cast((@PageIndex * @PageSize) as nvarchar(100)) + ' ROWS
					FETCH NEXT ' + cast(@PageSize as nvarchar(100)) + ' ROWS ONLY;'
	end
	else
	begin
		set @Sql =N'select RowNo = row_number() over (order by ' + @SortExpression + ')
						, ilv.*
					from (' + replace(@SelectSql,',hidefield=0','') + ') as ilv
					where 1 = 1  ' + @FilterClause + ' order by rowno '  
	end
	
	Declare @SqlForCount nvarchar(max);
	Declare @ParmDefinition nvarchar(4000);
	
	set @SqlForCount = N'select @TotalRowCount = count(1) from  ( ' + replace(@SelectSql,',hidefield=0','--') + ') as ilv where 1 = 1  ' + @FilterClause;   
	set @ParmDefinition = N' @TotalRowCount int OUTPUT ';

	--select @SqlForCount
	--select @Sql

	exec sp_executesql @SqlForCount, @ParmDefinition, @TotalRowCount OUTPUT; 
	exec sp_executesql @Sql 

END

GO

--		EXEC [dbo].[P_Remove_Generic] '','',1,'',''
 CREATE OR ALTER PROC [dbo].[P_Remove_Generic]
    @TableName NVARCHAR(150),
    @ColumnName NVARCHAR(150),
    @ColumnValue INT,
    @Username NVARCHAR(150),
    @IPAddress NVARCHAR(20) = ''
AS
BEGIN
    DECLARE @Return_Code BIT = 1;
    DECLARE @Return_Text NVARCHAR(1000) = '';

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @TableName)
    BEGIN
        DECLARE @IsActive BIT;
        DECLARE @Sql NVARCHAR(MAX);

        SET @Sql = N'SELECT @IsActive = IsActive FROM ' + QUOTENAME(@TableName) + ' WHERE ' + QUOTENAME(@ColumnName) + ' = @ColumnValue;';

        EXEC sp_executesql @Sql, N'@ColumnValue INT, @IsActive BIT OUTPUT', @ColumnValue, @IsActive OUTPUT;

        IF @@ROWCOUNT > 0
        BEGIN
            IF @IsActive = 0
            BEGIN
                SET @Sql = N'UPDATE ' + QUOTENAME(@TableName) + ' SET IsActive = 1 WHERE ' + QUOTENAME(@ColumnName) + ' = @ColumnValue;';
                EXEC sp_executesql @Sql, N'@ColumnValue INT', @ColumnValue;
                SET @Return_Text = 'Record ACTIVE Successfully!';
                SET @Return_Code = 1;
            END
            ELSE
            BEGIN
                SET @Sql = N'UPDATE ' + QUOTENAME(@TableName) + ' SET IsActive = 0 WHERE ' + QUOTENAME(@ColumnName) + ' = @ColumnValue;';
                EXEC sp_executesql @Sql, N'@ColumnValue INT', @ColumnValue;
                SET @Return_Text = 'Record IN-ACTIVE Successfully!';
                SET @Return_Code = 1;
            END
        END
        ELSE
        BEGIN
            SET @Return_Text = 'Record with specified parm value does not exist!';
            SET @Return_Code = 0;
        END
    END
    ELSE
    BEGIN
        SET @Return_Text = 'Table does not exist!';
        SET @Return_Code = 0;
    END

    SELECT @Return_Text AS Return_Text, @Return_Code AS Return_Code;
END
GO

-- [dbo].[P_Get_Role_Rights_From_RoleID] 12,0,0.0,''
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Role_Rights_From_RoleID]
	@ROLE_ID int
	,@IsGroupRoleID bit
	,@P_ID int = 0
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
AS
BEGIN
	
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID ,@IsGroupRoleID ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

END
GO

-- [dbo].[P_Get_Role_Rights_From_Username] 'ABDULLAH.ARSHAD',0.0,''
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Role_Rights_From_Username]
	@Username nvarchar(150)
	,@P_ID int = 0
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
AS
BEGIN
	
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [dbo].[F_Get_Role_Rights_From_Username] (@Username ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

END
GO

-- [dbo].[P_Is_Has_Right_From_RoleID] 1,true,0,''
 CREATE OR ALTER PROCEDURE [dbo].[P_Is_Has_Right_From_RoleID]
	@ROLE_ID int
	,@IsGroupRoleID bit
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
AS
BEGIN
	select [dbo].[F_Is_Has_Right_From_RoleID] (@ROLE_ID ,@IsGroupRoleID ,@PR_ID ,@PageRightType_MTV_CODE)
END
GO

 CREATE OR ALTER PROCEDURE [dbo].[P_Is_Has_Right_From_Username]
	@Username nvarchar(150)
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
AS
BEGIN
	DECLARE @ROLE_ID int
	DECLARE @IsGroupRoleID bit
	SELECT @ROLE_ID = ROLE_ID, @IsGroupRoleID = IsGroupRoleID FROM dbo.T_User_Role_Mapping WHERE USERNAME = @Username
	SELECT [dbo].[F_Is_Has_Right_From_RoleID] (@ROLE_ID ,@IsGroupRoleID ,@PR_ID ,@PageRightType_MTV_CODE)
END
GO

-- [dbo].[P_Get_User_Info] 'Hammas.Khan',1
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_User_Info]
	@UserName nvarchar(100)
	,@ApplicationID int
AS
BEGIN
	Set @UserName = upper(isnull(@UserName,''))
	SELECT 
	u.[User_ID]
	,u.UserName
	,u.Email
	,FullName = CONCAT(u.FirstName,' ',u.LastName)
	,u.FirstName
	,u.LastName
	,[UserType] = [dbo].[F_Get_MTV_Name_By_CODE](u.UserType_MTV_CODE)
	,[Department] = [dbo].[F_Get_MTV_Name_By_CODE](u.Department_MTV_CODE)
	,[Designation] = [dbo].[F_Get_MTV_Name_By_CODE](u.Designation_MTV_CODE)
	,[BlockType] = [dbo].[F_Get_MTV_Name_By_CODE](u.BlockType_MTV_CODE)
	,u.PasswordHash
	,u.PasswordSalt
	,u.PasswordExpiryDateTime
	,[IsBlocked] = CASE WHEN ISNULL(u.BlockType_MTV_CODE,'') = '' THEN 1 ELSE 0 END
	,[IsAdmin] = CASE WHEN ISNULL(r.RoleName,'') = 'Admin' THEN 1 ELSE 0 END
	,[RoleID] =  r.R_ID 
	,[IsGroupRoleID] = urm.IsGroupRoleID
	,[IsApplicationAccessAllowed] = CAsE WHEN ISNULL(urm.USERNAME,'') = '' THEN 0 ELSE 1 END
	FROM [dbo].[T_Users] u WITH (NOLOCK)
	LEFT JOIN [dbo].[T_Application_User_Mapping] aum WITH (NOLOCK) ON u.[User_ID] = aum.[User_ID]
	LEFT JOIN [dbo].[T_Application] a WITH (NOLOCK) ON aum.App_ID = a.App_ID
	INNER JOIN [dbo].[T_User_Role_Mapping] urm WITH (NOLOCK) ON u.UserName = urm.USERNAME
	INNER JOIN [dbo].[T_Roles] r WITH (NOLOCK) ON urm.ROLE_ID = r.R_ID
	WHERE u.UserName = @UserName AND u.IsActive = 1 AND a.App_ID = @ApplicationID
END
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Users_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_Users_List]
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
	SET @sortExpression = ' User_ID asc '  
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
  Declare @Col1_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AppName') then 1 else 0 end)
  Declare @Col2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UserName') then 1 else 0 end)
  Declare @Col3_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Email') then 1 else 0 end)
  Declare @Col4_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'FirstName') then 1 else 0 end)
  Declare @Col5_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'LastName') then 1 else 0 end)
  Declare @Col6_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UserType') then 1 else 0 end)
  Declare @Col7_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Department') then 1 else 0 end)
  Declare @Col8_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Designation') then 1 else 0 end)
  Declare @Col9_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'BlockType') then 1 else 0 end)
  Declare @Col10_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RoleName') then 1 else 0 end)
  Declare @Col11_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsGroupRoleID') then 1 else 0 end)
  Declare @Col12_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Col1_Req bit = (case when @Col1_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AppName') then 0 else 1 end)
  Declare @Col2_Req bit = (case when @Col2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UserName') then 0 else 1 end)
  Declare @Col3_Req bit = (case when @Col3_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Email') then 0 else 1 end)
  Declare @Col4_Req bit = (case when @Col4_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'FirstName') then 0 else 1 end)
  Declare @Col5_Req bit = (case when @Col5_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'LastName') then 0 else 1 end)
  Declare @Col6_Req bit = (case when @Col6_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UserType') then 0 else 1 end)
  Declare @Col7_Req bit = (case when @Col7_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Department') then 0 else 1 end)
  Declare @Col8_Req bit = (case when @Col8_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Designation') then 0 else 1 end)
  Declare @Col9_Req bit = (case when @Col9_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'BlockType') then 0 else 1 end)
  Declare @Col10_Req bit = (case when @Col10_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RoleName') then 0 else 1 end)
  Declare @Col11_Req bit = (case when @Col11_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsGroupRoleID') then 0 else 1 end)
  Declare @Col12_Req bit = (case when @Col12_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  SET @selectSql = N'SELECT u.[User_ID],u.PasswordHash,u.PasswordSalt,u.PasswordExpiryDateTime,[RoleID] =  r.R_ID, a.App_ID'
	+ char(10) + (case when @Col1_Filtered = 1 then '' else @HideField end) + ',AppName = a.App_Name'
	+ char(10) + (case when @Col2_Filtered = 1 then '' else @HideField end) + ',UserName = u.UserName'
	+ char(10) + (case when @Col3_Filtered = 1 then '' else @HideField end) + ',Email = u.Email'
	+ char(10) + (case when @Col4_Filtered = 1 then '' else @HideField end) + ',FirstName = u.FirstName'
	+ char(10) + (case when @Col5_Filtered = 1 then '' else @HideField end) + ',LastName = u.LastName'
	+ char(10) + (case when @Col6_Filtered = 1 then '' else @HideField end) + ',UserType = [dbo].[F_Get_MTV_Name_By_CODE](u.UserType_MTV_CODE)'
	+ char(10) + (case when @Col7_Filtered = 1 then '' else @HideField end) + ',Department = [dbo].[F_Get_MTV_Name_By_CODE](u.Department_MTV_CODE)'
	+ char(10) + (case when @Col8_Filtered = 1 then '' else @HideField end) + ',Designation = [dbo].[F_Get_MTV_Name_By_CODE](u.Designation_MTV_CODE)'
	+ char(10) + (case when @Col9_Filtered = 1 then '' else @HideField end) + ',BlockType = [dbo].[F_Get_MTV_Name_By_CODE](u.BlockType_MTV_CODE)'
	+ char(10) + (case when @Col10_Filtered = 1 then '' else @HideField end) + ',RoleName = r.RoleName'
	+ char(10) + (case when @Col11_Filtered = 1 then '' else @HideField end) + ',urm.IsGroupRoleID'
	+ char(10) + (case when @Col12_Filtered = 1 then '' else @HideField end) + ',IsActive = u.IsActive
	FROM [dbo].[T_Users] u WITH (NOLOCK)
	LEFT JOIN [dbo].[T_Application_User_Mapping] aum WITH (NOLOCK) ON u.[User_ID] = aum.[User_ID]
	LEFT JOIN [dbo].[T_Application] a WITH (NOLOCK) ON aum.App_ID = a.App_ID
	LEFT JOIN [dbo].[T_User_Role_Mapping] urm WITH (NOLOCK) ON u.UserName = urm.USERNAME
	LEFT JOIN [dbo].[T_Roles] r WITH (NOLOCK) ON urm.ROLE_ID = r.R_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO

--Exec P_Get_ApplicationPageMapping_List 'Ihtisham',0,2,'asc',' asc',0 
 CREATE OR ALTER PROCEDURE [dbo].[P_Get_ApplicationPageMapping_List]
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
	SET @sortExpression = 'APM_ID asc'  
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
  Declare @ApplcationName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ApplcationName') then 1 else 0 end)
  Declare @PageGroupName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageGroupName') then 1 else 0 end)
   Declare @PageName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageName') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
 
    ---- End Set Filter Variables

	---- Start Set Column Required Variables
  Declare @Application_MTV_CODE_Req bit = (case when @ApplcationName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application_MTV_CODE') then 0 else 1 end)
  Declare @PG_ID_CODE_Req bit = (case when @PageGroupName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PG_ID') then 0 else 1 end)
  Declare @PageName_Req bit = (case when @PageName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'P_ID') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
    ---- End Set Column Required Variables
	Declare @selectSql nvarchar(max);  
  set @selectSql = N'select APM_ID, p.P_ID, apm.Application_MTV_CODE'
  + char(10) + (case when @ApplcationName_Filtered = 1 then '' else @HideField end) + ',ApplcationName = mtv.Name'
  + char(10) + (case when @PageGroupName_Filtered = 1 then '' else @HideField end) + ',PageGroupName = pg.PageGroupName'
    + char(10) + (case when @PageName_Filtered = 1 then '' else @HideField end) + ',PageName = p.PageName'
  + char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = apm.IsActive
 FROM [dbo].[T_Application_Page_Mapping] apm
INNER JOIN [dbo].[T_Master_Type_Value] mtv ON apm.Application_MTV_CODE = mtv.MTV_CODE And mtv.MT_ID = 148
INNER JOIN [dbo].[T_Page] p ON apm.P_ID = p.P_ID
Inner Join [dbo].[T_Page_Group] pg ON p.PG_ID = pg.PG_ID
'
 
  exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT
    
   
END
GO

 CREATE OR ALTER PROCEDURE [dbo].[P_Get_ApplicationPageGroupMapping_List]
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
	SET @sortExpression = ' APGM_ID asc '  
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
  Declare @ApplcationName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ApplcationName') then 1 else 0 end)
  Declare @PageGroupName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'PageGroupName') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
    ---- End Set Filter Variables

	---- Start Set Column Required Variables
  Declare @Application_MTV_CODE_Req bit = (case when @ApplcationName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application_MTV_CODE') then 0 else 1 end)
  Declare @PG_ID_CODE_Req bit = (case when @PageGroupName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'PG_ID') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
    ---- End Set Column Required Variables
	Declare @selectSql nvarchar(max);  
  set @selectSql = N'select APGM_ID,pg.PG_ID, Application_MTV_CODE'
  + char(10) + (case when @ApplcationName_Filtered = 1 then '' else @HideField end) + ',ApplcationName = mtv.Name'
  + char(10) + (case when @PageGroupName_Filtered = 1 then '' else @HideField end) + ',PageGroupName = pg.PageGroupName'
  + char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = apgm.IsActive
  FROM [dbo].[T_Application_Page_Group_Mapping] apgm
INNER JOIN (
SELECT MTV_ID, MTV_CODE, Name FROM [dbo].[T_Master_Type_Value] WHERE MT_ID = 148
) mtv ON apgm.Application_MTV_CODE = mtv.MTV_CODE
INNER JOIN [dbo].[T_Page_Group] pg ON apgm.PG_ID = pg.PG_ID
'
  exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT
    
   
END
GO

--exec [dbo].[P_AddOrEdit_ApplicationPageMapping] 2,'148102',2,1,'Ihtisham.Ulhaq'
 CREATE OR ALTER PROCEDURE [dbo].[P_AddOrEdit_ApplicationPageMapping]
@APM_ID int,
@Application_MTV_CODE nvarchar(20),
@P_ID int,
@IsActive bit,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @APM_ID>0
 BEGIN
 IF EXISTS(SELECT 1 FROM  [dbo].[T_Application_Page_Mapping] WITH (NOLOCK) WHERE APM_ID=@APM_ID)
     BEGIN
	 DECLARE @OldApplication_MTV_CODE nvarchar(20)
	 DECLARE @OldP_ID int
	 DECLARE @OldIsActive bit

	 SELECT @OldApplication_MTV_CODE = Application_MTV_CODE, @OldP_ID = P_ID, @OldIsActive = IsActive FROM [dbo].[T_Application_Page_Mapping] WITH(NOLOCK) WHERE APM_ID=@APM_ID

	 UPDATE [dbo].[T_Application_Page_Mapping] SET Application_MTV_CODE=@Application_MTV_CODE,P_ID=@P_ID, IsActive=@IsActive, ModifiedBy = @Username , ModifiedOn=GETUTCDATE() WHERE APM_ID=@APM_ID

	 IF @OldApplication_MTV_CODE <> @Application_MTV_CODE
		BEGIN	
			exec P_Add_Audit_History 'Application_MTV_CODE' ,'T_Application_Page_Mapping', @APM_ID, 166111, @APM_ID, '', '', @OldApplication_MTV_CODE, @Application_MTV_CODE, @OldApplication_MTV_CODE, @Application_MTV_CODE, '', 0, 107100, @UserName
		END

		 IF @OldP_ID <> @P_ID
		BEGIN	

			exec P_Add_Audit_History 'PG_ID' ,'T_Application_Page_Mapping', @APM_ID, 166111, @APM_ID, '', '', @OldP_ID, @P_ID, @OldP_ID, @P_ID, '', 0, 167100, @UserName
			--exec P_Add_Audit_History 'Description' ,'T_Master_Type', @MT_ID, 166101, @MT_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 107100, @UserName
		   
		END
		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_Application_Page_Mapping', @APM_ID, 166111, @APM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'Application Page Mapping Updated Successfully!'
		SET @Return_Code = 1
		 
	  
	 END
	 ELSE
	BEGIN
		SET @Return_Text = 'Application Page Mapping does not exist!'
		SET @Return_Code = 0
	END
 END
 ElSE
 BEGIN
  IF @Application_MTV_CODE <> ''
  BEGIN
		--SELECT @APM_ID = ISNULL(MAX(APM_ID),0) + 1 FROM [dbo].[T_Application_Page_Mapping] WITH (NOLOCK) 
		INSERT INTO [dbo].[T_Application_Page_Mapping] (Application_MTV_CODE, P_ID, IsActive, AddedBy, AddedOn) VALUES (@Application_MTV_CODE, @P_ID, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Application Page Mapping Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Application Page Mapping Name Not Found!'
		set @Return_Code = 0
	END
 END
 SELECT @Return_Text Return_Text, @Return_Code Return_Code
END
GO

--exec [dbo].[P_AddOrEdit_ApplicationPageGroupMapping] 2,'148102',2,1,'Ihtisham.Ulhaq'
 CREATE OR ALTER PROCEDURE [dbo].[P_AddOrEdit_ApplicationPageGroupMapping]
@APGM_ID int,
@Application_MTV_CODE nvarchar(20),
@PG_ID int,
@IsActive bit,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @APGM_ID>0
 BEGIN
 IF EXISTS(SELECT 1 FROM  [dbo].[T_Application_Page_Group_Mapping] WITH (NOLOCK) WHERE APGM_ID=@APGM_ID)
     BEGIN
	 DECLARE @OldApplication_MTV_CODE nvarchar(20)
	 DECLARE @OldPG_ID int
	 DECLARE @OldIsActive bit

	 SELECT @OldApplication_MTV_CODE = App_ID, @OldPG_ID = PG_ID, @OldIsActive = IsActive FROM [dbo].[T_Application_Page_Group_Mapping] WITH(NOLOCK) WHERE APGM_ID=@APGM_ID

	 UPDATE [dbo].[T_Application_Page_Group_Mapping] SET App_ID=@Application_MTV_CODE,PG_ID=@PG_ID, IsActive=@IsActive, ModifiedBy = @Username , ModifiedOn=GETUTCDATE() WHERE APGM_ID=@APGM_ID

	 IF @OldApplication_MTV_CODE <> @Application_MTV_CODE
		BEGIN	
			exec P_Add_Audit_History 'App_ID' ,'T_Application_Page_Group_Mapping', @APGM_ID, 166111, @APGM_ID, '', '', @OldApplication_MTV_CODE, @Application_MTV_CODE, @OldApplication_MTV_CODE, @Application_MTV_CODE, '', 0, 107100, @UserName
		END

		 IF @OldPG_ID <> @PG_ID
		BEGIN	

			exec P_Add_Audit_History 'PG_ID' ,'T_Application_Page_Group_Mapping', @APGM_ID, 166111, @APGM_ID, '', '', @OldPG_ID, @PG_ID, @OldPG_ID, @PG_ID, '', 0, 167100, @UserName
			--exec P_Add_Audit_History 'Description' ,'T_Master_Type', @MT_ID, 166101, @MT_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 107100, @UserName
		   
		END
		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_Application_Page_Group_Mapping', @APGM_ID, 166111, @APGM_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END

		SET @Return_Text = 'Application Page Group Mapping Updated Successfully!'
		SET @Return_Code = 1
		 
	  
	 END
	 ELSE
	BEGIN
		SET @Return_Text = 'Application Page Group Mapping does not exist!'
		SET @Return_Code = 0
	END
 END
 ElSE
 BEGIN
  IF @Application_MTV_CODE <> ''
  BEGIN
		--SELECT @APGM_ID = ISNULL(MAX(APGM_ID),0) + 1 FROM [dbo].[T_Application_Page_Group_Mapping] WITH (NOLOCK) 
		INSERT INTO [dbo].[T_Application_Page_Group_Mapping] (App_ID, PG_ID, IsActive, AddedBy, AddedOn) VALUES (@Application_MTV_CODE, @PG_ID, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Application Page Group Mapping Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Application Page Group Mapping Name Not Found!'
		set @Return_Code = 0
	END
 END
 SELECT @Return_Text Return_Text, @Return_Code Return_Code
END
GO