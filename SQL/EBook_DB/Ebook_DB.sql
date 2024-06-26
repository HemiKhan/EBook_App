USE [Ebook_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_AC_ID]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM [dbo].[F_Get_AC_ID] ('','')
CREATE   FUNCTION [dbo].[F_Get_AC_ID]
(	
	@ColumnName nvarchar(100),
	@TableName nvarchar(100)
)
RETURNS INT
AS
Begin
	DECLARE @AC_ID INT = 0
	SELECT @AC_ID = ISNULL(AC_ID,0) FROM [dbo].[T_Audit_Column] WHERE TableName = @TableName AND [Name] = @ColumnName
	return @AC_ID
end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Chat_Group_Private_Json]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT [POMS_DB].[dbo].[F_Get_Chat_Group_Private_Json] (0,'HAMMAS.KHAN')
CREATE FUNCTION [dbo].[F_Get_Chat_Group_Private_Json]
(@CR_ID int, @Username nvarchar(150))
RETURNS nvarchar(max) 
AS
begin
	
	Declare @Return_Json nvarchar(max) = ''
	
	SELECT @Return_Json = (SELECT cr.CR_ID, cr.Room_Name,
    Room_Member_Json = (
        SELECT CRUM_ID,
               ChatMemeberName = UserName,
               IsHistoryAllowed,
               IsNotificationEnabled,
               IsAdmin,
               IsUserAddedAllowed,
               IsReadOnly,
			   IsOnline
        FROM [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK)
        WHERE crum.CR_ID = cr.CR_ID AND crum.UserName <> @Username AND crum.IsActive = 1
        FOR JSON PATH
    ) 
	FROM [dbo].[T_Chat_Room] cr WITH (NOLOCK)
	WHERE cr.CR_ID = @CR_ID AND cr.IsActive = 1
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	if @Return_Json is null
		begin set @Return_Json = '' end

	return @Return_Json

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_MTV_List_By_ID]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM [dbo].[F_Get_MTV_List_By_ID] (100)
CREATE FUNCTION [dbo].[F_Get_MTV_List_By_ID]
(	
	@MT_ID int
	,@Username nvarchar(150) = null
)
returns @ReturnTable table
(MT_ID int
,[Name] nvarchar(100)
,MTV_ID int
,MTV_CODE nvarchar(20)
,[SubName] nvarchar(100)
,Sort_ int
)
AS
Begin

	insert into @ReturnTable
	select 
	MT_ID = mt.MT_ID
	,[Name] = mt.[Name]
	,MTV_ID = mtv.MTV_ID
	,MTV_CODE = mtv.MTV_CODE
	,[SubName] = mtv.[Name]
	,Sort_ = mtv.Sort_
	from [dbo].[T_Master_Type] mt 
	left join [dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = @MT_ID
	order by Sort_

	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_MTV_Name_By_CODE]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--	SELECT * FROM [dbo].[F_Get_MTV_Name_By_CODE] ("11")
CREATE FUNCTION [dbo].[F_Get_MTV_Name_By_CODE]  
(
	@MTV_CODE nvarchar(20)
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@MTV_CODE,'') != ''
	begin
		select @Ret = [Name] from [dbo].[T_Master_Type_Value] with (nolock) where MTV_CODE = @MTV_CODE
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PageChart_Json]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select [dbo].[F_Get_PageChart_Json] (null,null)

CREATE FUNCTION [dbo].[F_Get_PageChart_Json]
(	
	@RoleID int = null,
	@ApplicationID int = null
)
RETURNS nvarchar(max) 
AS
begin
	
	Declare @Return_Json nvarchar(max) = ''
	
	SELECT @Return_Json = '[' + (SELECT Distinct App_ID = a.[MTV_ID], [Application] = a.[Name],
	(
		SELECT Distinct PageGroups.PG_ID, PageGroups.PageGroupName, PGSort_= PageGroups.Sort_,
				(
					SELECT Distinct
						P_ID,
						PageName,
						PSort_=Pages.Sort_,
						(
							SELECT Distinct
								PageRights.PR_ID,
								PR_CODE,
								PageRightName,
								PageRightType_MTV_CODE,
								PRSort_=PageRights.Sort_,
								IsRightActive=isnull(rprm.IsRightActive,0)
							FROM [dbo].[T_Page_Rights] AS PageRights with (nolock)
							left join [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) on PageRights.PR_ID = rprm.PR_ID --and rprm.R_ID = r1.R_ID
							WHERE PageRights.P_ID = Pages.P_ID and PageRights.PR_ID <> 100100 order by PageRights.Sort_
							FOR JSON PATH
						) AS PageRightsInfo
					FROM [dbo].[T_Page] AS Pages with (nolock)
					INNER JOIN [dbo].[T_Master_Type_Value] a2 with (nolock) ON Pages.Application_MTV_ID = a2.MTV_ID
					WHERE Pages.PG_ID = PageGroups.PG_ID and (@ApplicationID is null or (@ApplicationID is not null and a2.MTV_ID = @ApplicationID)) order by Pages.Sort_
					FOR JSON PATH
				) AS PageInfo
		FROM [dbo].[T_Master_Type_Value] a1 with (nolock)
			cross apply [dbo].[T_Page_Group] AS PageGroups with (nolock)
			--cross apply [dbo].[T_Roles] r1 with (nolock)
			WHERE a1.MTV_ID = apgm.App_ID and (@ApplicationID is null or (@ApplicationID is not null and a1.MTV_ID = @ApplicationID))
			--and (@RoleID is null or (@RoleID is not null and r1.R_ID = @RoleID))
			order by PageGroups.Sort_
			FOR JSON PATH
	) AS PageGroupInfo

	FROM [dbo].[T_Master_Type_Value] a WITH (NOLOCK) 
	INNER JOIN [dbo].[T_Application_Page_Group_Mapping] AS apgm with (nolock) ON a.MTV_CODE = apgm.App_ID
	WHERE a.MT_ID = 148 and (@ApplicationID is null or (@ApplicationID is not null and a.MTV_ID = @ApplicationID))
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) + ']'

	if @Return_Json is null	begin set @Return_Json = '' end

	return @Return_Json

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Role_Rights_From_RoleID]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select * from [dbo].[F_Get_Role_Rights_From_RoleID] (12,0,0,0,'')
CREATE FUNCTION [dbo].[F_Get_Role_Rights_From_RoleID]
(	
	@ROLE_ID int
	,@IsGroupRoleID bit
	,@P_ID int = 0
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
)
returns @ReturnTable table
(PR_ID int
, IsRightActive bit
, PageRightName nvarchar(50)
, PageRightType_MTV_CODE nvarchar(20))
AS
Begin

	set @PR_ID = isnull(@PR_ID,0)
	set @PageRightType_MTV_CODE = isnull(upper(@PageRightType_MTV_CODE),'')

	Declare @IsAdmin bit = 0
	select @IsAdmin = [dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)
	set @IsAdmin = isnull(@IsAdmin,0)

	Declare @RolesTable table (ROLE_ID int)
	if @IsGroupRoleID = 1
	begin
		insert into @RolesTable (ROLE_ID)
		select R_ID from [dbo].[T_Role_Group_Mapping] rgm with (nolock) where rgm.RG_ID = @ROLE_ID and rgm.IsActive = 1
	end
	else
	begin
		insert into @RolesTable (ROLE_ID)
		select @ROLE_ID
	end

	if @IsAdmin = 1
	begin
		insert into @ReturnTable (PR_ID , IsRightActive , PageRightName , PageRightType_MTV_CODE )
		select pr.PR_ID , pr.IsActive , pr.PageRightName , pr.PageRightType_MTV_CODE from [dbo].[T_Page_Rights] pr with (nolock) where pr.IsActive = 1
		and ((@P_ID > 0 and pr.P_ID = @P_ID) or @P_ID = 0)
		and ((@PR_ID > 0 and pr.PR_ID = @PR_ID) or @PR_ID = 0)
		and ((@PageRightType_MTV_CODE <> '' and pr.PageRightType_MTV_CODE = @PageRightType_MTV_CODE) or @PageRightType_MTV_CODE = '')
	end
	else
	begin
		Declare @TempRoleRightsTable table (PR_ID int, IsRightActive bit)
		insert into @TempRoleRightsTable (PR_ID ,IsRightActive)
		select rprm.PR_ID,rprm.IsRightActive from [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable) and rprm.IsActive = 1 and rprm.IsRightActive = 1

		insert into @TempRoleRightsTable (PR_ID ,IsRightActive)
		select rprm.PR_ID,rprm.IsRightActive from [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable) and rprm.IsActive = 1 and rprm.IsRightActive = 0
		and rprm.PR_ID not in (select rrt.PR_ID from @TempRoleRightsTable rrt where rrt.IsRightActive = 1)

		insert into @ReturnTable (PR_ID , IsRightActive , PageRightName , PageRightType_MTV_CODE )
		select pr.PR_ID , pr.IsActive , pr.PageRightName , pr.PageRightType_MTV_CODE 
		from [dbo].[T_Page_Rights] pr with (nolock) 
		inner join @TempRoleRightsTable trrt on pr.PR_ID = trrt.PR_ID
		where pr.IsActive = 1
		and ((@P_ID > 0 and pr.P_ID = @P_ID) or @P_ID = 0)
		and ((@PR_ID > 0 and pr.PR_ID = @PR_ID) or @PR_ID = 0)
		and ((@PageRightType_MTV_CODE <> '' and pr.PageRightType_MTV_CODE = @PageRightType_MTV_CODE) or @PageRightType_MTV_CODE = '')
	end

	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Role_Rights_From_Username]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select * from [[dbo].[F_Get_Role_Rights_From_Username] ('ABDULLAH.ARSHAD',0,0,'')
CREATE FUNCTION [dbo].[F_Get_Role_Rights_From_Username]
(	
	@Username nvarchar(150)
	,@P_ID int = 0
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
)
returns @ReturnTable table
(PR_ID int
, IsRightActive bit
, PageRightName nvarchar(50)
, PageRightType_MTV_CODE nvarchar(20))
AS
Begin

	Declare @ROLE_ID int = 0
	Declare @IsGroupRoleID bit = 0
	
	select @ROLE_ID = urm.ROLE_ID ,@IsGroupRoleID = urm.IsGroupRoleID from [[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username and urm.IsActive = 1
	
	insert into @ReturnTable
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [[dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID ,@IsGroupRoleID ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Role_Rights_Json]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select [dbo].[F_Get_Role_Rights_Json] (2)
CREATE FUNCTION [dbo].[F_Get_Role_Rights_Json]
(	
	@RoleID int
)
RETURNS nvarchar(max) 
AS
begin
	
	Declare @Return_Json nvarchar(max) = ''
	
	select @Return_Json = (SELECT Distinct
		r.R_ID,
		r.RoleName,
		(
			SELECT Distinct
				PG_ID,
				PageGroupName,
				PGSort_=PageGroups.Sort_,
				(
					SELECT Distinct
						P_ID,
						PageName,
						PSort_=Pages.Sort_,
						(
							SELECT Distinct
								PageRights.PR_ID,
								PR_CODE,
								PageRightName,
								PageRightType_MTV_CODE,
								PRSort_=PageRights.Sort_,
								IsRightActive=isnull(rprm.IsRightActive,0)
							FROM [dbo].[T_Page_Rights] AS PageRights with (nolock)
							left join [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) on PageRights.PR_ID = rprm.PR_ID and rprm.R_ID = r.R_ID
							WHERE PageRights.P_ID = Pages.P_ID and PageRights.PR_ID <> 100100 order by PageRights.Sort_
							FOR JSON PATH
						) AS PageRightsInfo
					FROM [dbo].[T_Page] AS Pages with (nolock)
					WHERE Pages.PG_ID = PageGroups.PG_ID order by Pages.Sort_
					FOR JSON PATH
				) AS PageInfo
			FROM [dbo].[T_Roles] r1 with (nolock)
			cross apply [dbo].[T_Page_Group] AS PageGroups with (nolock)
			WHERE r1.R_ID = r.R_ID order by PageGroups.Sort_
			FOR JSON PATH
		) AS PageGroupInfo
	from [dbo].[T_Roles] r with (nolock)
	where r.R_ID = @RoleID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	if @Return_Json is null
		begin set @Return_Json = '' end
	--else
	--	begin set @Return_Json = replace(replace(replace(replace(@Return_Json,'{},',''),'[{}]','null'),'[]','null'),'[]','null') end

	return @Return_Json

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_RoleName_From_RoleID]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	SELECT * FROM [dbo].[F_Get_RoleName_From_RoleID] (1,true) 
CREATE FUNCTION [dbo].[F_Get_RoleName_From_RoleID]  
(
	@RoleID int
	,@IsGroupRoleID bit
)
RETURNS nvarchar(50)
AS
BEGIN
	
	set @RoleID = isnull(@RoleID,0)
	set @IsGroupRoleID = isnull(@IsGroupRoleID,0)

	Declare @Ret nvarchar(50) = ''
	
	if @IsGroupRoleID = 0
	begin
		select @Ret = R.[RoleName] from [dbo].[T_Roles] R with (nolock) where R.[R_ID] = @RoleID
		set @Ret = isnull(@Ret,'')
	end
	else
	begin
		select @Ret = RG.[RoleGroupName] from [dbo].[T_Role_Group] RG with (nolock) where RG.[RG_ID] = @RoleID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_RoleName_RoleID]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select * from [dbo].[F_Get_RoleName_RoleID] (1)
CREATE FUNCTION [dbo].[F_Get_RoleName_RoleID]
(
	@R_ID int
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @RoleName nvarchar(max)
	SELECT @RoleName = ISNULL(RoleName,'') FROM [dbo].[T_Roles] WHERE R_ID = @R_ID AND IsActive = 1
	return @RoleName
end

GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_RolePageRight_JsonTable]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM [dbo].[F_Get_RolePageRight_JsonTable]("")
CREATE FUNCTION [dbo].[F_Get_RolePageRight_JsonTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
RPRM_ID INT,
R_ID INT,
PR_ID INT,
IsRightActive INT,
Active INT
)
AS
BEGIN
	
	SET @Json = ISNULL(@Json,'')

	IF @Json = ''
	BEGIN
		return
	END
	ELSE
	BEGIN
		IF ISJSON(@Json) = 0
		BEGIN
			return
		END
	END
	
	INSERT INTO @ReturnTable
	SELECT RPRM_ID, R_ID, PR_ID, IsRightActive, Active FROM OpenJson(@Json)
	WITH (
		RPRM_ID INT '$.RPRM_ID',
		R_ID INT '$.R_ID',
		PR_ID INT '$.PR_ID',
		IsRightActive BIT '$.IsRightActive', 
		Active BIT '$.Active'
	) mch

	return

END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Sorting_JsonTable]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	SELECT * FROM [dbo].[F_Get_Sorting_JsonTable]('')
CREATE FUNCTION [dbo].[F_Get_Sorting_JsonTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
New_Sort_Value INT,
Sort_ID NVARCHAR(50),
Sort_Text NVARCHAR(100),
Old_Sort_Value INT
)
AS
BEGIN
	
	SET @Json = ISNULL(@Json,'')

	IF @Json = ''
	BEGIN
		return
	END
	ELSE
	BEGIN
		IF ISJSON(@Json) = 0
		BEGIN
			return
		END
	END
	
	INSERT INTO @ReturnTable
	SELECT New_Sort_Value, Sort_ID, Sort_Text, Old_Sort_Value FROM OpenJson(@Json)
	WITH (
		New_Sort_Value int '$.New_Sort_Value',
		Sort_ID nvarchar(50) '$.Sort_ID',
		Sort_Text nvarchar(100) '$.Sort_Text',
		Old_Sort_Value int '$.Old_Sort_Value' 
	) mch

	return

END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_T_TMS_Tasks_JsonTable]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--	SELECT * FROM [dbo].[F_Get_T_TMS_Tasks_JsonTable]()
CREATE FUNCTION [dbo].[F_Get_T_TMS_Tasks_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(		 
 T_ID int
,Application_MTV_ID int
,TaskName nvarchar(Max)
,Note nvarchar(Max)
,TaskActive bit
,TaskItemsJson nvarchar(max)		 
)
BEGIN
    SET @Json = ISNULL(@Json, '')

    IF @Json = ''
    BEGIN
        RETURN
    END
    ELSE
    BEGIN
        IF ISJSON(@Json) = 0
        BEGIN
            RETURN
        END
    END

	insert into @ReturnTable (
		 
		 T_ID
		,Application_MTV_ID 
		,TaskName 
		,Note
		,TaskActive
		,TaskItemsJson
		 
		) 
		select 
		 
		 T_ID
		,Application_MTV_ID 
		,TaskName 
		,Note 
		,TaskActive
		,TaskItemsJson
		 FROM OPENJSON(@Json)
    WITH (
		 
		 T_ID int '$.T_ID'
		,Application_MTV_ID int '$.Application_ID'
		,TaskName nvarchar(500) '$.TaskName'
		,Note nvarchar(Max) '$.Note'
		,TaskActive bit '$.Active'
		,TaskItemsJson Nvarchar(max) '$.TaskItems'  as Json 
		);
	 RETURN  ;
END;

 
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Fields_Column]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select * from [dbo].[F_Get_Table_Fields_Column] ('')
create FUNCTION [dbo].[F_Get_Table_Fields_Column]
(	
	@Json nvarchar(max)
)
returns @ReturnTable table
(Code nvarchar(150)
,[Name] nvarchar(150)
,IsColumnRequired bit
)
AS
Begin
	
	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end

	insert into @ReturnTable (Code ,[Name] ,IsColumnRequired)
	select distinct * from (
		select Code = isnull(ret.Code,'')
		,[Name] = isnull(ret.[Name],'')
		,IsColumnRequired = isnull(ret.IsColumnRequired,0)

		from OpenJson(@Json)
		WITH (
			Code nvarchar(150) '$.Code'
			,[Name] nvarchar(1000) '$.Name'
			,IsColumnRequired bit '$.IsColumnRequired'
		) ret
	) ilv where Code <> '' and IsColumnRequired = 0
	
	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Fields_Filter]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select * from [dbo].[F_Get_Table_Fields_Filter] ('')
create FUNCTION [dbo].[F_Get_Table_Fields_Filter]
(	
	@Json nvarchar(max)
)
returns @ReturnTable table
(Code nvarchar(150)
,[Name] nvarchar(150)
,IsFilterApplied bit
)
AS
Begin
	
	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end

	insert into @ReturnTable (Code ,[Name] ,IsFilterApplied)
	select distinct * from (
		select Code = isnull(ret.Code,'')
		,[Name] = isnull(ret.[Name],'')
		,IsFilterApplied = isnull(ret.IsFilterApplied,0)

		from OpenJson(@Json)
		WITH (
			Code nvarchar(150) '$.Code'
			,[Name] nvarchar(1000) '$.Name'
			,IsFilterApplied bit '$.IsFilterApplied'
		) ret
	) ilv where Code <> '' and IsFilterApplied = 1
	
	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Hidden_Fields_Filter_2]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select * from [POMS_DB].[dbo].[F_Get_Table_Hidden_Fields_Filter_2] ('')
Create FUNCTION [dbo].[F_Get_Table_Hidden_Fields_Filter_2]
(	
	@Json nvarchar(max)
)
returns @ReturnTable table
(Code nvarchar(150)
,IsFilterApplied bit
,IsList bit 
,[Value] nvarchar(1000)
,ListType int
,Logic nvarchar(50)
,[Type] nvarchar(50)
)
AS
Begin
	
	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end

	insert into @ReturnTable (Code ,IsFilterApplied ,IsList ,[Value] ,ListType ,Logic ,[Type])
	select * from (
		select Code = isnull(ret.Code,'')
		,IsFilterApplied = isnull(ret.IsFilterApplied,0)
		,IsList = isnull(IsList,0)
		,[Value] = isnull([Value],'')
		,ListType = isnull(ListType,0)
		,Logic = isnull(Logic,'')
		,[Type] = isnull([Type],'')
		from OpenJson(@Json)
		WITH (
			Code nvarchar(150) '$.Code'
			,IsFilterApplied bit '$.IsFilterApplied'
			,ReportFilterObjectArry nvarchar(max) '$.reportFilterObjectArry' as json
		) ret
		CROSS APPLY openjson (ret.ReportFilterObjectArry,'$') 
		WITH (
			IsList bit '$.IsList'
			,[Value] nvarchar(1000) '$.Value'
			,ListType int '$.ListType'
			,Logic nvarchar(50) '$.Logic'
			,[Type] nvarchar(50) '$.Type'
		) ret2
	) ilv where Code <> ''
	
	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_TMS_LinkedTaskDetail]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	SELECT * FROM [dbo].[F_Get_TMS_LinkedTaskDetail] (@TD_ID INT)(1)
CREATE FUNCTION [dbo].[F_Get_TMS_LinkedTaskDetail] (@TD_ID INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @LinkedTask NVARCHAR(MAX)
    
    SELECT @LinkedTask = COALESCE(@LinkedTask + ', ', '') +
        CASE WHEN Parent_TD = @TD_ID THEN CAST(LinkedTask_TD AS NVARCHAR(50))
             ELSE CAST(Parent_TD AS NVARCHAR(50))
        END
    FROM [dbo].[T_TMS_LinkedTasks] with (nolock)
    WHERE (Parent_TD = @TD_ID OR LinkedTask_TD = @TD_ID) AND IsActive = 1
    
    RETURN ISNULL(@LinkedTask, '')
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_TMS_TaskDetail_JsonTable]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM [dbo].[F_Get_TMS_TaskDetail_JsonTable]('')
  CREATE FUNCTION [dbo].[F_Get_TMS_TaskDetail_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(   TD_ID int,
    Task_Item nvarchar(1000),
    Task_Item_Detail nvarchar(Max),
    Application_URL int,
    Task_Start_Date Date,
    Task_End_Date Date,
	Priority_MTV_Code int,
	Status_MTV_Code int,
	BUILDCODE nvarchar(50),
    TaskCategory_MTV_ID int,
	Review_Date Date,
	ETA_Date Date,
	LeadAssignTo nvarchar(150),
    IsPrivate bit,
	TaskDetailActive bit,
    AttachmentsJson nvarchar(max)
)
BEGIN
    SET @Json = ISNULL(@Json, '')

    IF @Json = ''
    BEGIN
        RETURN
    END
    ELSE
    BEGIN
        IF ISJSON(@Json) = 0
        BEGIN
            RETURN
        END
    END

    INSERT INTO @ReturnTable (
		TD_ID,
        Task_Item,
        Task_Item_Detail,
        Application_URL,
        Task_Start_Date,
        Task_End_Date,
		Priority_MTV_Code,
		Status_MTV_Code ,
        BUILDCODE,  
		TaskCategory_MTV_ID , 
		Review_Date, 
		ETA_Date , 
		LeadAssignTo ,
		IsPrivate , 
		TaskDetailActive,
        AttachmentsJson
    ) 
    SELECT 
		TD_ID,
        Task_Item,
        Task_Item_Detail,
        Application_URL,
        Task_Start_Date,
        Task_End_Date,
		Priority_MTV_Code,
		Status_MTV_Code ,
		BUILDCODE,  
        TaskCategory_MTV_ID , 
		Review_Date, 
		ETA_Date , 
		LeadAssignTo ,
		IsPrivate , 
		TaskDetailActive,
        AttachmentsJson
    FROM OPENJSON(@Json)
    WITH (
	    TD_ID int '$.TD_ID',
        Task_Item nvarchar(1000) '$.TaskItemName',
        Task_Item_Detail nvarchar(Max) '$.TaskDetail',
		Application_URL int '$.Application_URL',
        Task_Start_Date Date '$.StartDate',
        Task_End_Date Date '$.EndDate',
		Priority_MTV_Code int '$.Priority_MTV_Code',
		Status_MTV_Code int '$.Status_MTV_Code',
		BUILDCODE nvarchar(100) '$.BUILDCODE',
        TaskCategory_MTV_ID int '$.TaskCategory_MTV_ID',
        Review_Date Date '$.Review_Date',
		ETA_Date Date '$.ETA_Date',
		LeadAssignTo nvarchar(150) '$.LeadAssignTo',
		IsPrivate bit '$.IsPrivate',
		TaskDetailActive bit '$.Active',
        AttachmentsJson nvarchar(max) '$.Attachments' AS JSON
    )

    RETURN;
END;


 
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Users_Json]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select [dbo].[F_Get_Users_Json] ('hammaass.khan')
CREATE FUNCTION [dbo].[F_Get_Users_Json]
(	
	@UserName nvarchar(300)	 
)
RETURNS nvarchar(max) 
AS
begin
	
	Declare @Return_Json nvarchar(max) = ''
	
	SELECT @Return_Json =  (SELECT
    u.[User_ID],
    u.UserName,
    u.Email,
    u.FirstName,
    u.LastName,
    u.PasswordHash,
    u.PasswordSalt,
    u.UserType_MTV_CODE,
    u.Department_MTV_CODE,
    u.Designation_MTV_CODE,
    u.BlockType_MTV_CODE,
	R_ID = CONCAT(rm.ROLE_ID, '_', CASE WHEN rm.IsGroupRoleID = 1 THEN 'true' ELSE 'false' END),
    u.IsApproved,
    u.IsActive    
	FROM [dbo].[T_Users] u WITH (NOLOCK)
	LEFT JOIN [dbo].[T_User_Role_Mapping] rm  WITH (NOLOCK) ON u.UserName = rm.USERNAME
    where u.UserName=@UserName    
	FOR JSON PATH)

	if @Return_Json is null	begin set @Return_Json = '' end

	return @Return_Json

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_GetAssignedTo]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--	SELECT * FROM [dbo].[F_GetAssignedTo] (@TD_ID INT)(1)
CREATE FUNCTION [dbo].[F_GetAssignedTo] (@TD_ID INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @AssignedTo NVARCHAR(MAX)
    
    SELECT @AssignedTo = COALESCE(@AssignedTo + ', ', '') + AssignedTo
    FROM [dbo].[T_TMS_TaskAssignedTo_Mapping] with (nolock)
    WHERE TD_ID = @TD_ID and IsActive=1
    
    RETURN ISNULL(@AssignedTo, '')
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Admin_Right_From_RoleID]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select * from [dbo].[F_Is_Admin_Right_From_RoleID] (1,true)
CREATE FUNCTION [dbo].[F_Is_Admin_Right_From_RoleID]
(
	@ROLE_ID int
	,@IsGroupRoleID bit
)
RETURNS bit
AS
BEGIN
	
	Declare @PR_ID int = 100100
	set @ROLE_ID = isnull(@ROLE_ID,0)
	set @IsGroupRoleID = isnull(@IsGroupRoleID,0)

	DECLARE @Ret bit = 0
	
	if (@ROLE_ID = 0)
	begin
		return @Ret
	end

	Declare @RolesTable table (ROLE_ID int)
	if @IsGroupRoleID = 1
	begin
		insert into @RolesTable (ROLE_ID)
		select R_ID from [dbo].[T_Role_Group_Mapping] rgm with (nolock) where rgm.RG_ID = @ROLE_ID and rgm.IsActive = 1
	end
	else
	begin
		insert into @RolesTable (ROLE_ID)
		select @ROLE_ID
	end

	if exists(Select rprm.PR_ID from [dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable) and rprm.PR_ID = 100100)
	begin
		set @Ret = 1
	end

	set @Ret = isnull(@Ret,0)

	return @Ret

end

GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Admin_Right_From_Username]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM [dbo].[F_Is_Admin_Right_From_Username]('hammas.khan')
CREATE FUNCTION [dbo].[F_Is_Admin_Right_From_Username]
(
	@Username nvarchar(150)	
)
RETURNS bit
AS
BEGIN
	
	DECLARE @Ret bit = 0
	set @Username = isnull(upper(@Username),'')
	
	if (@Username = '')
	begin
		return @Ret
	end

	Declare @ROLE_ID int = 0
	Declare @IsGroupRoleID bit = 0

	select @ROLE_ID = urm.ROLE_ID , @IsGroupRoleID = urm.IsGroupRoleID from [dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username

	select @Ret = [dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)

	set @Ret = isnull(@Ret,0)

	return @Ret

end

GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Has_Right_From_RoleID]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT * FROM [dbo].[F_Is_Has_Right_From_RoleID](1,true,0,'')
CREATE FUNCTION [dbo].[F_Is_Has_Right_From_RoleID]
(
	@ROLE_ID int
	,@IsGroupRoleID bit
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
)
RETURNS bit
AS
BEGIN
	
	DECLARE @Ret bit = 0
	set @ROLE_ID = isnull(@ROLE_ID,0)
	set @IsGroupRoleID = isnull(@IsGroupRoleID,0)
	set @PR_ID = isnull(@PR_ID,0)
	set @PageRightType_MTV_CODE = isnull(@PageRightType_MTV_CODE,'')
	
	if (@ROLE_ID = 0)
	begin
		return @Ret
	end

	if (@PR_ID = 0 and @PageRightType_MTV_CODE = '')
	begin
		return @Ret
	end

	select @Ret = [dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)
	set @Ret = isnull(@Ret,0)

	if (@Ret = 0)
	begin
		select @Ret = IsRightActive from [dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID , @IsGroupRoleID ,0 ,@PR_ID ,@PageRightType_MTV_CODE)
		set @Ret = isnull(@Ret,0)
	end

	return @Ret

end

GO
/****** Object:  Table [dbo].[T_Application]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Application](
	[TimeStamp] [timestamp] NOT NULL,
	[App_ID] [int] IDENTITY(1,1) NOT NULL,
	[App_Name] [nvarchar](50) NOT NULL,
	[AppDetail] [nvarchar](300) NULL,
	[AppType_MTV_CODE] [nvarchar](20) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[App_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Application_Page_Group_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Application_Page_Group_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[APGM_ID] [int] IDENTITY(1,1) NOT NULL,
	[App_ID] [nvarchar](20) NOT NULL,
	[PG_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Application_Page_Group_Mapping] PRIMARY KEY CLUSTERED 
(
	[APGM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Application_Page_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Application_Page_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[APM_ID] [int] IDENTITY(1,1) NOT NULL,
	[Application_MTV_CODE] [nvarchar](20) NOT NULL,
	[P_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Application_Page_Mapping] PRIMARY KEY CLUSTERED 
(
	[APM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Application_User_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Application_User_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[AUM_ID] [int] IDENTITY(1,1) NOT NULL,
	[App_ID] [int] NOT NULL,
	[User_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[AUM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Audit_Column]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Audit_Column](
	[TimeStamp] [timestamp] NOT NULL,
	[AC_ID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [nvarchar](100) NOT NULL,
	[DbName] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Audit_Column] PRIMARY KEY CLUSTERED 
(
	[AC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Audit_History]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Audit_History](
	[TimeStamp] [timestamp] NOT NULL,
	[AH_ID] [int] IDENTITY(1,1) NOT NULL,
	[AC_ID] [int] NOT NULL,
	[REF_NO] [nvarchar](150) NOT NULL,
	[AuditType_MTV_ID] [int] NOT NULL,
	[RefNo1] [nvarchar](50) NOT NULL,
	[RefNo2] [nvarchar](50) NOT NULL,
	[RefNo3] [nvarchar](50) NOT NULL,
	[OldValueHidden] [nvarchar](2000) NOT NULL,
	[NewValueHidden] [nvarchar](2000) NOT NULL,
	[OldValue] [nvarchar](2000) NOT NULL,
	[NewValue] [nvarchar](2000) NOT NULL,
	[Reason] [nvarchar](1000) NOT NULL,
	[IsAuto] [bit] NOT NULL,
	[Source_MTV_ID] [int] NOT NULL,
	[TriggerDebugInfo] [nvarchar](4000) NULL,
	[ChangedBy] [nvarchar](150) NOT NULL,
	[ChangedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_T_Audit_History] PRIMARY KEY CLUSTERED 
(
	[AH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_CacheEntries]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_CacheEntries](
	[TimeStamp] [timestamp] NOT NULL,
	[CE_ID] [int] IDENTITY(1,1) NOT NULL,
	[Key] [varchar](800) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ExpiredOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_T_CacheEntries] PRIMARY KEY CLUSTERED 
(
	[CE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Chat_Room]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Chat_Room](
	[TimeStamp] [timestamp] NOT NULL,
	[CR_ID] [int] IDENTITY(1,1) NOT NULL,
	[Room_Name] [nvarchar](150) NOT NULL,
	[Room_Type_MTV_CODE] [nvarchar](20) NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Chat_Room_User_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Chat_Room_User_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[CRUM_ID] [int] IDENTITY(1,1) NOT NULL,
	[CR_ID] [int] NOT NULL,
	[UserName] [nvarchar](150) NOT NULL,
	[IsHistoryAllowed] [bit] NOT NULL,
	[IsNotificationEnabled] [bit] NOT NULL,
	[IsAdmin] [bit] NOT NULL,
	[IsUserAddedAllowed] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[IsOnline] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CRUM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Chats]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Chats](
	[TimeStamp] [timestamp] NOT NULL,
	[C_ID] [int] IDENTITY(1,1) NOT NULL,
	[Parent_C_ID] [int] NOT NULL,
	[CRUM_ID] [int] NOT NULL,
	[Send_UserName] [nvarchar](150) NOT NULL,
	[Parent_C_ID_Image] [nvarchar](max) NULL,
	[Message] [nvarchar](max) NULL,
	[Attachment_Path] [nvarchar](250) NULL,
	[Attachment_Ext] [nvarchar](10) NULL,
	[Attachment_Name] [nvarchar](150) NULL,
	[Attachment_FileSize] [bigint] NULL,
	[IsEdited] [bit] NOT NULL,
	[EditedOn] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[C_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Chats_User_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Chats_User_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[CUM_ID] [int] IDENTITY(1,1) NOT NULL,
	[C_ID] [int] NOT NULL,
	[Recieve_UserName] [nvarchar](150) NOT NULL,
	[IsRead] [bit] NOT NULL,
	[IsBookmark] [bit] NOT NULL,
	[IsFlag] [bit] NOT NULL,
	[Read_At] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CUM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Docs]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Docs](
	[TimeStamp] [timestamp] NOT NULL,
	[DOC_ID] [int] IDENTITY(1,1) NOT NULL,
	[AttachmentType_MTV_ID] [int] NOT NULL,
	[OriginalFileName] [nvarchar](250) NULL,
	[ImageName] [nvarchar](100) NOT NULL,
	[Description_] [nvarchar](250) NOT NULL,
	[Path_] [nvarchar](250) NOT NULL,
	[RefNo] [nvarchar](40) NULL,
	[RefNo2] [nvarchar](40) NULL,
	[RefID] [int] NULL,
	[RefID2] [int] NULL,
	[IsPublic] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Docs] PRIMARY KEY CLUSTERED 
(
	[DOC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Errors_List]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Errors_List](
	[TimeStamp] [timestamp] NOT NULL,
	[EL_ID] [int] IDENTITY(1,1) NOT NULL,
	[Error_Type_MTV_ID] [int] NOT NULL,
	[Error_Sub_Type_MTV_ID] [int] NOT NULL,
	[Error_ID] [int] NOT NULL,
	[Error_CODE] [nvarchar](20) NOT NULL,
	[Error_Text] [nvarchar](250) NOT NULL,
	[Description_] [nvarchar](1000) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Errors_List] PRIMARY KEY CLUSTERED 
(
	[EL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Master_Type]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_Type](
	[TimeStamp] [timestamp] NOT NULL,
	[MT_ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](150) NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Type] PRIMARY KEY CLUSTERED 
(
	[MT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Master_Type_Value]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Master_Type_Value](
	[TimeStamp] [timestamp] NOT NULL,
	[MTV_ID] [int] NOT NULL,
	[MTV_CODE] [nvarchar](20) NOT NULL,
	[MT_ID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Sub_MTV_ID] [int] NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Master_Type_Value] PRIMARY KEY CLUSTERED 
(
	[MTV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Page]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Page](
	[TimeStamp] [timestamp] NOT NULL,
	[P_ID] [int] NOT NULL,
	[PG_ID] [int] NOT NULL,
	[PageName] [nvarchar](50) NOT NULL,
	[PageURL] [nvarchar](250) NOT NULL,
	[Application_MTV_ID] [int] NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsHide] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Page] PRIMARY KEY CLUSTERED 
(
	[P_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Page_Group]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Page_Group](
	[TimeStamp] [timestamp] NOT NULL,
	[PG_ID] [int] NOT NULL,
	[PageGroupName] [nvarchar](50) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsHide] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Page_Group] PRIMARY KEY CLUSTERED 
(
	[PG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Page_Rights]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Page_Rights](
	[TimeStamp] [timestamp] NOT NULL,
	[PR_ID] [int] NOT NULL,
	[P_ID] [int] NOT NULL,
	[PR_CODE] [nvarchar](50) NOT NULL,
	[PageRightName] [nvarchar](50) NOT NULL,
	[PageRightType_MTV_CODE] [nvarchar](20) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsHide] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Page_Rights] PRIMARY KEY CLUSTERED 
(
	[PR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Role_Group]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Role_Group](
	[TimeStamp] [timestamp] NOT NULL,
	[RG_ID] [int] NOT NULL,
	[RoleGroupName] [nvarchar](50) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Role_Group] PRIMARY KEY CLUSTERED 
(
	[RG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Role_Group_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Role_Group_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[RGM_ID] [int] IDENTITY(1,1) NOT NULL,
	[RG_ID] [int] NOT NULL,
	[R_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Role_Group_Mapping] PRIMARY KEY CLUSTERED 
(
	[RGM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Role_Page_Rights_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Role_Page_Rights_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[RPRM_ID] [int] IDENTITY(1,1) NOT NULL,
	[R_ID] [int] NOT NULL,
	[PR_ID] [int] NOT NULL,
	[IsRightActive] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Role_Page_Rights_Mapping] PRIMARY KEY CLUSTERED 
(
	[RPRM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Roles]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Roles](
	[TimeStamp] [timestamp] NOT NULL,
	[R_ID] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](50) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsCustomRole] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Roles] PRIMARY KEY CLUSTERED 
(
	[R_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_TMS_AssignedTo_List]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_AssignedTo_List](
	[TimeStamp] [timestamp] NOT NULL,
	[TAL_ID] [int] IDENTITY(1,1) NOT NULL,
	[AssignToType_MTV_CODE] [nvarchar](20) NOT NULL,
	[AssignedTo] [nvarchar](150) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_TMS_AssignedTo_List] PRIMARY KEY CLUSTERED 
(
	[TAL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_TMS_Chats_Room_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_Chats_Room_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[TCRM_ID] [int] IDENTITY(1,1) NOT NULL,
	[TD_ID] [int] NOT NULL,
	[CR_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[TCRM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_TMS_LinkedTasks]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_LinkedTasks](
	[TimeStamp] [timestamp] NOT NULL,
	[Parent_TD] [int] NOT NULL,
	[LinkedTask_TD] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](300) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](300) NULL,
	[ModifiedOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_TMS_TaskAssignedTo_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[TATM_ID] [int] IDENTITY(1,1) NOT NULL,
	[TD_ID] [int] NOT NULL,
	[AssignToType_MTV_CODE] [nvarchar](20) NOT NULL,
	[Comment] [nvarchar](max) NULL,
	[AssignedTo] [nvarchar](150) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__0342D215041BAEEC] PRIMARY KEY CLUSTERED 
(
	[TATM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_TMS_TaskAttachments]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_TaskAttachments](
	[TimeStamp] [timestamp] NOT NULL,
	[TA_ID] [int] IDENTITY(1,1) NOT NULL,
	[OriginalFileName] [nvarchar](250) NOT NULL,
	[FileName] [nvarchar](50) NOT NULL,
	[FileExt] [nvarchar](10) NOT NULL,
	[Path] [nvarchar](500) NOT NULL,
	[DocumentType_MTV_ID] [int] NOT NULL,
	[AttachmentType_MTV_ID] [int] NOT NULL,
	[REFID1] [int] NOT NULL,
	[REFID2] [int] NULL,
	[REFID3] [int] NULL,
	[REFID4] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__2F5D5550E47FC396] PRIMARY KEY CLUSTERED 
(
	[TA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_TMS_TaskComments]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_TaskComments](
	[TimeStamp] [timestamp] NOT NULL,
	[TC_ID] [int] IDENTITY(1,1) NOT NULL,
	[TD_ID] [int] NOT NULL,
	[CommentText] [nvarchar](2000) NOT NULL,
	[Application_URL] [int] NOT NULL,
	[Task_Start_Date] [date] NULL,
	[Task_End_Date] [date] NULL,
	[Priority_MTV_ID] [int] NOT NULL,
	[Status_MTV_ID] [int] NOT NULL,
	[BUILDCODE] [nvarchar](50) NULL,
	[TaskCategory_MTV_ID] [int] NOT NULL,
	[Review_Date] [date] NULL,
	[ETA_Date] [date] NULL,
	[IsPrivate] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__2A3483DE61E78521] PRIMARY KEY CLUSTERED 
(
	[TC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_TMS_TaskDetail]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_TaskDetail](
	[TimeStamp] [timestamp] NOT NULL,
	[TD_ID] [int] IDENTITY(1,1) NOT NULL,
	[T_ID] [int] NOT NULL,
	[Task_Item] [nvarchar](500) NOT NULL,
	[Task_Item_Detail] [nvarchar](2000) NOT NULL,
	[Task_Start_Date] [date] NULL,
	[Task_End_Date] [date] NULL,
	[Priority_MTV_ID] [int] NOT NULL,
	[Status_MTV_ID] [int] NOT NULL,
	[BUILDCODE] [nvarchar](50) NULL,
	[TaskCategory_MTV_ID] [int] NOT NULL,
	[Review_Date] [date] NULL,
	[ETA_Date] [date] NULL,
	[IsPrivate] [bit] NOT NULL,
	[LeadAssignTo] [nvarchar](150) NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
	[Application_URL] [int] NULL,
 CONSTRAINT [PK__T_TMS_Ta__B2EE46BBFFF3434D] PRIMARY KEY CLUSTERED 
(
	[TD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_TMS_Tasks]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_TMS_Tasks](
	[TimeStamp] [timestamp] NOT NULL,
	[T_ID] [int] IDENTITY(1,1) NOT NULL,
	[TaskName] [nvarchar](250) NOT NULL,
	[Note] [nvarchar](max) NOT NULL,
	[Application_MTV_ID] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_TMS_Ta__83BB1FB2BE169C24] PRIMARY KEY CLUSTERED 
(
	[T_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_User_Role_Mapping]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_User_Role_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[URM_ID] [int] IDENTITY(1,1) NOT NULL,
	[USERNAME] [nvarchar](150) NOT NULL,
	[ROLE_ID] [int] NOT NULL,
	[IsGroupRoleID] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_User_Role_Mapping] PRIMARY KEY CLUSTERED 
(
	[URM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Users]    Script Date: 4/20/2024 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Users](
	[TimeStamp] [timestamp] NOT NULL,
	[User_ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](250) NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[PasswordHash] [nvarchar](250) NOT NULL,
	[PasswordSalt] [nvarchar](250) NOT NULL,
	[PasswordExpiryDateTime] [datetime] NOT NULL,
	[UserType_MTV_CODE] [nvarchar](20) NULL,
	[Department_MTV_CODE] [nvarchar](20) NULL,
	[Designation_MTV_CODE] [nvarchar](20) NULL,
	[BlockType_MTV_CODE] [nvarchar](20) NULL,
	[IsApproved] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[User_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Application] ADD  CONSTRAINT [DF_T_Application_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application] ADD  CONSTRAINT [DF_T_Application_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Application_Page_Group_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Group_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application_Page_Group_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Group_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping] ADD  CONSTRAINT [DF_T_Application_Page_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Application_User_Mapping] ADD  CONSTRAINT [DF_T_Application_User_Map_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Application_User_Mapping] ADD  CONSTRAINT [DF_T_Application_User_Map_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Audit_Column] ADD  CONSTRAINT [DF_T_Audit_Column_IsPublic]  DEFAULT ((1)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Audit_Column] ADD  CONSTRAINT [DF_T_Audit_Column_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Audit_History] ADD  CONSTRAINT [DF_T_Audit_History_IsAuto]  DEFAULT ((0)) FOR [IsAuto]
GO
ALTER TABLE [dbo].[T_Audit_History] ADD  CONSTRAINT [DF_T_Audit_History_ChangedOn]  DEFAULT (getutcdate()) FOR [ChangedOn]
GO
ALTER TABLE [dbo].[T_CacheEntries] ADD  CONSTRAINT [DF_T_CacheEntries_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[T_Chat_Room] ADD  CONSTRAINT [DF_T_Chat_Room_IsPublic]  DEFAULT ((0)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Chat_Room] ADD  CONSTRAINT [DF_T_Chat_Room_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Chat_Room] ADD  CONSTRAINT [DF_T_Chat_Room_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsHistoryAllowed]  DEFAULT ((1)) FOR [IsHistoryAllowed]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsNotificationEnabled]  DEFAULT ((1)) FOR [IsNotificationEnabled]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsAdmin]  DEFAULT ((0)) FOR [IsAdmin]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsUserAddedAllowed]  DEFAULT ((1)) FOR [IsUserAddedAllowed]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsReadOnly]  DEFAULT ((0)) FOR [IsReadOnly]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsOnline]  DEFAULT ((0)) FOR [IsOnline]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping] ADD  CONSTRAINT [DF_T_Chat_Room_User_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Chats] ADD  CONSTRAINT [DF_T_Chats_IsEdited]  DEFAULT ((0)) FOR [IsEdited]
GO
ALTER TABLE [dbo].[T_Chats] ADD  CONSTRAINT [DF_T_Chats_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Chats] ADD  CONSTRAINT [DF_T_Chats_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_IsRead]  DEFAULT ((0)) FOR [IsRead]
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_IsBookmark]  DEFAULT ((0)) FOR [IsBookmark]
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_IsFlag]  DEFAULT ((0)) FOR [IsFlag]
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping] ADD  CONSTRAINT [DF_T_Chats_User_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Docs] ADD  CONSTRAINT [DF_T_Docs_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Docs] ADD  CONSTRAINT [DF_T_Docs_CreatedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Errors_List] ADD  CONSTRAINT [DF_T_Errors_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Errors_List] ADD  CONSTRAINT [DF_T_Errors_List_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[T_Master_Type] ADD  CONSTRAINT [DF_T_Master_Type_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Master_Type] ADD  CONSTRAINT [DF_T_Master_Type_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Master_Type_Value] ADD  CONSTRAINT [DF_T_Master_Type_Value_Sub_MTV_ID]  DEFAULT ((0)) FOR [Sub_MTV_ID]
GO
ALTER TABLE [dbo].[T_Master_Type_Value] ADD  CONSTRAINT [DF_T_Master_Type_Value_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Master_Type_Value] ADD  CONSTRAINT [DF_T_Master_Type_Value_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_Application_MTV_ID]  DEFAULT ((148100)) FOR [Application_MTV_ID]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_IsHide]  DEFAULT ((0)) FOR [IsHide]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Page] ADD  CONSTRAINT [DF_T_Page_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Page_Group] ADD  CONSTRAINT [DF_T_Page_Group_IsHide]  DEFAULT ((0)) FOR [IsHide]
GO
ALTER TABLE [dbo].[T_Page_Group] ADD  CONSTRAINT [DF_T_Page_Group_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Page_Group] ADD  CONSTRAINT [DF_T_Page_Group_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Page_Rights] ADD  CONSTRAINT [DF_T_Page_Rights_IsHide]  DEFAULT ((0)) FOR [IsHide]
GO
ALTER TABLE [dbo].[T_Page_Rights] ADD  CONSTRAINT [DF_T_Page_Rights_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Page_Rights] ADD  CONSTRAINT [DF_T_Page_Rights_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Role_Group] ADD  CONSTRAINT [DF_T_Role_Group_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Role_Group] ADD  CONSTRAINT [DF_T_Role_Group_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] ADD  CONSTRAINT [DF_T_Role_Group_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] ADD  CONSTRAINT [DF_T_Role_Group_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] ADD  CONSTRAINT [DF_T_Role_Page_Rights_Mapping_IsRightActive]  DEFAULT ((0)) FOR [IsRightActive]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] ADD  CONSTRAINT [DF_T_Role_Page_Rights_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] ADD  CONSTRAINT [DF_T_Role_Page_Rights_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Roles] ADD  CONSTRAINT [DF_T_Roles_IsCustomRole]  DEFAULT ((0)) FOR [IsCustomRole]
GO
ALTER TABLE [dbo].[T_Roles] ADD  CONSTRAINT [DF_T_Roles_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Roles] ADD  CONSTRAINT [DF_T_Roles_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_AssignedTo_List] ADD  CONSTRAINT [DF_T_TMS_AssignedTo_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_AssignedTo_List] ADD  CONSTRAINT [DF_T_TMS_AssignedTo_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping] ADD  CONSTRAINT [DF_T_TMS_Chats_Room_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping] ADD  CONSTRAINT [DF_T_TMS_Chats_Room_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping] ADD  CONSTRAINT [DF_T_TMS_TaskAssignedTo_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping] ADD  CONSTRAINT [DF_T_TMS_TaskAssignedTo_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_TaskAttachments] ADD  CONSTRAINT [DF_T_TMS_TaskAttachments_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_TaskAttachments] ADD  CONSTRAINT [DF_T_TMS_TaskAttachments_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_TaskComments] ADD  CONSTRAINT [DF_T_TMS_TaskComments_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_TaskComments] ADD  CONSTRAINT [DF_T_TMS_TaskComments_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail] ADD  CONSTRAINT [DF_T_TMS_TaskDetail_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail] ADD  CONSTRAINT [DF_T_TMS_TaskDetail_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail] ADD  CONSTRAINT [DF__T_TMS_Tas__Appli__4B42F62C]  DEFAULT ((0)) FOR [Application_URL]
GO
ALTER TABLE [dbo].[T_TMS_Tasks] ADD  CONSTRAINT [DF_T_Task_Management_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_TMS_Tasks] ADD  CONSTRAINT [DF_T_Task_Management_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_User_Role_Mapping] ADD  CONSTRAINT [DF_T_User_Role_Mapping_IsGroupRoleID]  DEFAULT ((0)) FOR [IsGroupRoleID]
GO
ALTER TABLE [dbo].[T_User_Role_Mapping] ADD  CONSTRAINT [DF_T_User_Role_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_User_Role_Mapping] ADD  CONSTRAINT [DF_T_User_Role_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_PasswordExpiry]  DEFAULT (getutcdate()) FOR [PasswordExpiryDateTime]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsApproved]  DEFAULT ((1)) FOR [IsApproved]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Application_Page_Group_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Application_Page_Group_Mapping_T_Page_Group] FOREIGN KEY([PG_ID])
REFERENCES [dbo].[T_Page_Group] ([PG_ID])
GO
ALTER TABLE [dbo].[T_Application_Page_Group_Mapping] CHECK CONSTRAINT [FK_T_Application_Page_Group_Mapping_T_Page_Group]
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Application_Page_Mapping_T_Page] FOREIGN KEY([P_ID])
REFERENCES [dbo].[T_Page] ([P_ID])
GO
ALTER TABLE [dbo].[T_Application_Page_Mapping] CHECK CONSTRAINT [FK_T_Application_Page_Mapping_T_Page]
GO
ALTER TABLE [dbo].[T_Application_User_Mapping]  WITH CHECK ADD FOREIGN KEY([App_ID])
REFERENCES [dbo].[T_Application] ([App_ID])
GO
ALTER TABLE [dbo].[T_Application_User_Mapping]  WITH CHECK ADD FOREIGN KEY([User_ID])
REFERENCES [dbo].[T_Users] ([User_ID])
GO
ALTER TABLE [dbo].[T_Audit_History]  WITH CHECK ADD  CONSTRAINT [FK_T_Audit_History_T_Audit_Column] FOREIGN KEY([AC_ID])
REFERENCES [dbo].[T_Audit_Column] ([AC_ID])
GO
ALTER TABLE [dbo].[T_Audit_History] CHECK CONSTRAINT [FK_T_Audit_History_T_Audit_Column]
GO
ALTER TABLE [dbo].[T_Chat_Room_User_Mapping]  WITH CHECK ADD FOREIGN KEY([CR_ID])
REFERENCES [dbo].[T_Chat_Room] ([CR_ID])
GO
ALTER TABLE [dbo].[T_Chats]  WITH CHECK ADD FOREIGN KEY([CRUM_ID])
REFERENCES [dbo].[T_Chat_Room_User_Mapping] ([CRUM_ID])
GO
ALTER TABLE [dbo].[T_Chats_User_Mapping]  WITH CHECK ADD FOREIGN KEY([C_ID])
REFERENCES [dbo].[T_Chats] ([C_ID])
GO
ALTER TABLE [dbo].[T_Master_Type_Value]  WITH CHECK ADD  CONSTRAINT [FK_T_Master_Type_Value_T_Master_Type] FOREIGN KEY([MT_ID])
REFERENCES [dbo].[T_Master_Type] ([MT_ID])
GO
ALTER TABLE [dbo].[T_Master_Type_Value] CHECK CONSTRAINT [FK_T_Master_Type_Value_T_Master_Type]
GO
ALTER TABLE [dbo].[T_Page]  WITH CHECK ADD  CONSTRAINT [FK_T_Page_T_Page_Group] FOREIGN KEY([PG_ID])
REFERENCES [dbo].[T_Page_Group] ([PG_ID])
GO
ALTER TABLE [dbo].[T_Page] CHECK CONSTRAINT [FK_T_Page_T_Page_Group]
GO
ALTER TABLE [dbo].[T_Page_Rights]  WITH CHECK ADD  CONSTRAINT [FK_T_Page_Rights_T_Page] FOREIGN KEY([P_ID])
REFERENCES [dbo].[T_Page] ([P_ID])
GO
ALTER TABLE [dbo].[T_Page_Rights] CHECK CONSTRAINT [FK_T_Page_Rights_T_Page]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Group_Mapping_T_Role_Group] FOREIGN KEY([RG_ID])
REFERENCES [dbo].[T_Role_Group] ([RG_ID])
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] CHECK CONSTRAINT [FK_T_Role_Group_Mapping_T_Role_Group]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Group_Mapping_T_Roles] FOREIGN KEY([R_ID])
REFERENCES [dbo].[T_Roles] ([R_ID])
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] CHECK CONSTRAINT [FK_T_Role_Group_Mapping_T_Roles]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Page_Rights_Mapping_T_Page_Rights] FOREIGN KEY([PR_ID])
REFERENCES [dbo].[T_Page_Rights] ([PR_ID])
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] CHECK CONSTRAINT [FK_T_Role_Page_Rights_Mapping_T_Page_Rights]
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Page_Rights_Mapping_T_Roles] FOREIGN KEY([R_ID])
REFERENCES [dbo].[T_Roles] ([R_ID])
GO
ALTER TABLE [dbo].[T_Role_Page_Rights_Mapping] CHECK CONSTRAINT [FK_T_Role_Page_Rights_Mapping_T_Roles]
GO
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping]  WITH CHECK ADD FOREIGN KEY([CR_ID])
REFERENCES [dbo].[T_Chat_Room] ([CR_ID])
GO
ALTER TABLE [dbo].[T_TMS_Chats_Room_Mapping]  WITH CHECK ADD FOREIGN KEY([TD_ID])
REFERENCES [dbo].[T_TMS_TaskDetail] ([TD_ID])
GO
ALTER TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_TMS_TaskAssignedTo_Mapping_T_TMS_TaskDetail] FOREIGN KEY([TD_ID])
REFERENCES [dbo].[T_TMS_TaskDetail] ([TD_ID])
GO
ALTER TABLE [dbo].[T_TMS_TaskAssignedTo_Mapping] CHECK CONSTRAINT [FK_T_TMS_TaskAssignedTo_Mapping_T_TMS_TaskDetail]
GO
ALTER TABLE [dbo].[T_TMS_TaskComments]  WITH CHECK ADD  CONSTRAINT [FK_T_TMS_TaskComments_T_TMS_TaskDetail] FOREIGN KEY([TD_ID])
REFERENCES [dbo].[T_TMS_TaskDetail] ([TD_ID])
GO
ALTER TABLE [dbo].[T_TMS_TaskComments] CHECK CONSTRAINT [FK_T_TMS_TaskComments_T_TMS_TaskDetail]
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail]  WITH CHECK ADD  CONSTRAINT [FK__T_TMS_Task__T_ID__6CD8F421] FOREIGN KEY([T_ID])
REFERENCES [dbo].[T_TMS_Tasks] ([T_ID])
GO
ALTER TABLE [dbo].[T_TMS_TaskDetail] CHECK CONSTRAINT [FK__T_TMS_Task__T_ID__6CD8F421]
GO
ALTER TABLE [dbo].[T_Audit_History]  WITH CHECK ADD  CONSTRAINT [const_T_Audit_History_AuditType_MTV_ID_Check] CHECK  ((substring(CONVERT([nvarchar](100),[AuditType_MTV_ID]),(1),(3))=(166)))
GO
ALTER TABLE [dbo].[T_Audit_History] CHECK CONSTRAINT [const_T_Audit_History_AuditType_MTV_ID_Check]
GO
ALTER TABLE [dbo].[T_Audit_History]  WITH CHECK ADD  CONSTRAINT [const_T_Audit_History_Source_MTV_ID_Check] CHECK  ((substring(CONVERT([nvarchar](100),[Source_MTV_ID]),(1),(3))=(167)))
GO
ALTER TABLE [dbo].[T_Audit_History] CHECK CONSTRAINT [const_T_Audit_History_Source_MTV_ID_Check]
GO
ALTER TABLE [dbo].[T_Master_Type_Value]  WITH CHECK ADD  CONSTRAINT [const_T_Master_Type_Value_ParentIDCheck] CHECK  ((substring(CONVERT([nvarchar](100),[MTV_ID]),(1),(3))=CONVERT([nvarchar](100),[MT_ID]) AND len(CONVERT([nvarchar](100),[MT_ID]))=(3)))
GO
ALTER TABLE [dbo].[T_Master_Type_Value] CHECK CONSTRAINT [const_T_Master_Type_Value_ParentIDCheck]
GO
ALTER TABLE [dbo].[T_Page]  WITH CHECK ADD  CONSTRAINT [const_T_Page_Value_ParentIDCheck] CHECK  ((format([PG_ID],'000')=left(format(CONVERT([int],left([P_ID],len([PG_ID]))),'000'),(3))))
GO
ALTER TABLE [dbo].[T_Page] CHECK CONSTRAINT [const_T_Page_Value_ParentIDCheck]
GO
ALTER TABLE [dbo].[T_Page_Rights]  WITH CHECK ADD  CONSTRAINT [const_T_Page_Rights_Value_ParentIDCheck] CHECK  ((substring(CONVERT([nvarchar](100),[PR_ID]),(1),len(CONVERT([nvarchar](100),[P_ID])))=CONVERT([nvarchar](100),[P_ID])))
GO
ALTER TABLE [dbo].[T_Page_Rights] CHECK CONSTRAINT [const_T_Page_Rights_Value_ParentIDCheck]
GO
/****** Object:  StoredProcedure [dbo].[P_Add_Audit_History]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Add_Audit_History]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ApplicationPageGroupMapping]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[P_AddOrEdit_ApplicationPageGroupMapping] 2,'148102',2,1,'Ihtisham.Ulhaq'
 CREATE   PROCEDURE [dbo].[P_AddOrEdit_ApplicationPageGroupMapping]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ApplicationPageMapping]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[P_AddOrEdit_ApplicationPageMapping] 2,'148102',2,1,'Ihtisham.Ulhaq'
 CREATE   PROCEDURE [dbo].[P_AddOrEdit_ApplicationPageMapping]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_MasterType]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [P_AddOrEdit_MasterType] 103,'Billing Type 1','',1,'HAMMAS.KHAN',''
CREATE   PROC [dbo].[P_AddOrEdit_MasterType]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_MasterTypeValue]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [P_AddOrEdit_MasterTypeValue] 0,174,'PRIMARY_DOMAIN','Primary Domain',0,1,'ABDULLAH.ARSHAD',''
CREATE   PROC [dbo].[P_AddOrEdit_MasterTypeValue]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Page]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--	EXEC P_AddOrEdit_Page 0,10,'Events Setup','/Settings/EventsSetup',148100,0,1,'HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_AddOrEdit_Page]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Page_Rights]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--	EXEC [P_AddOrEdit_Page_Rights] 4,'Test','sss','HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_AddOrEdit_Page_Rights]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_PageGroup]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	EXEC P_AddOrEdit_PageGroup 10,'Setting',0,1,'HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_AddOrEdit_PageGroup]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Role_Group]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC P_AddOrEdit_Role_Group 0,'Test',1,'HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_AddOrEdit_Role_Group]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Role_Group_Mapping]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC P_AddOrEdit_Role_Group_Mapping 'Test','HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_AddOrEdit_Role_Group_Mapping]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_RolePageRight_Json]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	EXEC [P_AddOrEdit_RolePageRight_Json] 4,'Test','sss','HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_AddOrEdit_RolePageRight_Json]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Roles]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--	EXEC P_AddOrEdit_Roles 'Test','HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_AddOrEdit_Roles]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_User_Role_Map]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	EXEC P_AddOrEdit_User_Role_Map 0,2,'ABDULLAH.ARSHAD',0,1,'HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_AddOrEdit_User_Role_Map]
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
/****** Object:  StoredProcedure [dbo].[P_Auto_Insert_Columns_In_Audit_Column_Table]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Auto_Insert_Columns_In_Audit_Column_Table]
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
/****** Object:  StoredProcedure [dbo].[P_CacheEntry_Delete]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[P_CacheEntry_Delete]
    @cacheKey VARCHAR(800)
	,@applicationID int
AS
BEGIN
    
	if exists(select * from [dbo].[T_CacheEntries] with (nolock) where [Key] = @cacheKey and ApplicationID = @applicationID)
	begin
		Delete from [dbo].[T_CacheEntries] where [Key] = @cacheKey and ApplicationID = @applicationID
	end

END
GO
/****** Object:  StoredProcedure [dbo].[P_CacheEntry_IU]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[P_CacheEntry_IU]
    @cacheKey VARCHAR(800),
	@applicationID int,
    @cacheValue NVARCHAR(MAX),
    @expirationTime DATETIME2
AS
BEGIN
    MERGE INTO [dbo].[T_CacheEntries] AS target
    USING (VALUES (@cacheKey, @applicationID, @cacheValue, @expirationTime)) AS source ([Key], ApplicationID, [Value], ExpiredOn)
    ON target.[Key] = source.[Key] and target.ApplicationID = source.ApplicationID
    WHEN MATCHED THEN
        UPDATE SET
            target.Value = source.Value,
            target.ExpiredOn = source.ExpiredOn
    WHEN NOT MATCHED THEN
        INSERT ([Key], ApplicationID, Value, ExpiredOn)
        VALUES (source.[Key], source.ApplicationID, source.Value, source.ExpiredOn);
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ApplicationPageGroupMapping_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Get_ApplicationPageGroupMapping_List]
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
/****** Object:  StoredProcedure [dbo].[P_Get_ApplicationPageMapping_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec P_Get_ApplicationPageMapping_List 'Ihtisham',0,2,'asc',' asc',0 
 CREATE   PROCEDURE [dbo].[P_Get_ApplicationPageMapping_List]
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
/****** Object:  StoredProcedure [dbo].[P_Get_Audit_History_DropDown_Lists]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Get_Audit_History_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	select [value] = MT_ID, [text]= [Name] from [dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 166 and IsActive = 1 order by [Name]
	select [value] = MT_ID, [text]= [Name] from [dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 167 and IsActive = 1 order by [Name]
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_AuditColumn_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_AuditColumn_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_AuditColumn_List] 
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
	SET @sortExpression = ' AC_ID desc '  
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
  Declare @TableName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TableName') then 1 else 0 end)
  Declare @DbName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DbName') then 1 else 0 end) 
  Declare @ColumnName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end)
   
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @TableName_Req bit = (case when @TableName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TableName') then 0 else 1 end)
  Declare @DbName_Req bit = (case when @DbName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DbName') then 0 else 1 end)
  Declare @ColumnName_Req bit = (case when @ColumnName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
  
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'select ac.AC_ID'
	+ char(10) + (case when @TableName_Filtered = 1 then '' else @HideField end) + ',TableName = ac.TableName'
	+ char(10) + (case when @DbName_Filtered = 1 then '' else @HideField end) + ',DbName = ac.DbName'
	+ char(10) + (case when @ColumnName_Filtered = 1 then '' else @HideField end) + ',Name = ac.Name,ac.IsPublic
	FROM [dbo].[T_Audit_Column] ac with (nolock)' 
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_AuditHistory_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_AuditHistory_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, -14400000, 13, '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_AuditHistory_List] 
	-- Add the parameters for the stored procedure here
	@Username nvarchar(150),
	 @pageIndex int,  
	 @pageSize int,  
	 @sortExpression nvarchar(max),  
	 @filterClause nvarchar(max),  
	 @totalRowCount int OUTPUT,
	 @Offset int = -14400000,
	 @TimeZoneID int = 13,
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
	SET @sortExpression = ' AH_ID desc '  
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

	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = 'Unknown'

	Declare @HideField nvarchar(50) = ',hidefield=0'

   ---- Start Set Filter Variables
  Declare @TableName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TableName') then 1 else 0 end)
  Declare @DbName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DbName') then 1 else 0 end) 
  Declare @ColumnName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ColumnName') then 1 else 0 end)
  Declare @REF_NO_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'REF_NO') then 1 else 0 end)
  Declare @MasterTypeValueAudit_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MasterTypeValueAudit') then 1 else 0 end)
  Declare @RefNo1_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RefNo1') then 1 else 0 end)
  Declare @RefNo2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RefNo2') then 1 else 0 end)
  Declare @RefNo3_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RefNo3') then 1 else 0 end)
  Declare @OldValueHidden_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'OldValueHidden') then 1 else 0 end)
  Declare @NewValueHidden_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'NewValueHidden') then 1 else 0 end)
  Declare @OldValue_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'OldValue') then 1 else 0 end)
  Declare @NewValue_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'NewValue') then 1 else 0 end)
  Declare @Reason_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Reason') then 1 else 0 end)
  Declare @IsAuto_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsAuto') then 1 else 0 end)
  Declare @MasterTypeValueSource_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'MasterTypeValueSource') then 1 else 0 end)
  Declare @TriggerDebugInfo_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TriggerDebugInfo') then 1 else 0 end)
  Declare @ChangedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ChangedBy') then 1 else 0 end)
  Declare @ChangedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ChangedOn') then 1 else 0 end)
  Declare @UTCChangedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UTCChangedOn') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @TableName_Req bit = (case when @TableName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TableName') then 0 else 1 end)
  Declare @DbName_Req bit = (case when @DbName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DbName') then 0 else 1 end)
  Declare @ColumnName_Req bit = (case when @ColumnName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ColumnName') then 0 else 1 end)
  Declare @REF_NO_Req bit = (case when @REF_NO_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'REF_NO') then 0 else 1 end)
  Declare @MasterTypeValueAudit_Req bit = (case when @MasterTypeValueAudit_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MasterTypeValueAudit') then 0 else 1 end)
  Declare @RefNo1_Req bit = (case when @RefNo1_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RefNo1') then 0 else 1 end)
  Declare @RefNo2_Req bit = (case when @RefNo2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RefNo2') then 0 else 1 end)
  Declare @RefNo3_Req bit = (case when @RefNo3_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RefNo3') then 0 else 1 end)
  Declare @OldValueHiddent_Req bit = (case when @OldValueHidden_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'OldValueHidden') then 0 else 1 end)
  Declare @NewValueHidden_Req bit = (case when @NewValueHidden_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'NewValueHidden') then 0 else 1 end)
  Declare @OldValue_Req bit = (case when @OldValue_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'OldValue') then 0 else 1 end)
  Declare @NewValue_Req bit = (case when @NewValue_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'NewValue') then 0 else 1 end)
  Declare @Reason_Req bit = (case when @Reason_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Reason') then 0 else 1 end)
  Declare @IsAuto_Req bit = (case when @IsAuto_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsAuto') then 0 else 1 end)
  Declare @MasterTypeValueSource_Req bit = (case when @MasterTypeValueSource_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'MasterTypeValueSource') then 0 else 1 end)
  Declare @TriggerDebugInfo_Req bit = (case when @TriggerDebugInfo_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TriggerDebugInfo') then 0 else 1 end)
  Declare @ChangedBy_Req bit = (case when @ChangedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ChangedBy') then 0 else 1 end)
  Declare @ChangedOn_Req bit = (case when @ChangedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ChangedOn') then 0 else 1 end)
  Declare @UTCChangedOn_Req bit = (case when @ChangedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UTCChangedOn') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'select AH_ID = ah.AH_ID, AC_ID = ac.AC_ID, AuditType_MTV_ID = ah.AuditType_MTV_ID, Source_MTV_ID = ah.Source_MTV_ID, TimeZoneAbbr=''' + @TimeZoneAbbr + ''''
	+ char(10) + (case when @TableName_Filtered = 1 then '' else @HideField end) + ',TableName = ac.TableName'
	+ char(10) + (case when @DbName_Filtered = 1 then '' else @HideField end) + ',DbName = ac.DbName'
	+ char(10) + (case when @ColumnName_Filtered = 1 then '' else @HideField end) + ',ColumnName = ac.Name'
	+ char(10) + (case when @REF_NO_Filtered = 1 then '' else @HideField end) + ',REF_NO'
	+ char(10) + (case when @MasterTypeValueAudit_Filtered = 1 then '' else @HideField end) + ',MasterTypeValueAudit = mtv_audit.Name'
	+ char(10) + (case when @RefNo1_Filtered = 1 then '' else @HideField end) + ',RefNo1'
	+ char(10) + (case when @RefNo2_Filtered = 1 then '' else @HideField end) + ',RefNo2'
	+ char(10) + (case when @RefNo3_Filtered = 1 then '' else @HideField end) + ',RefNo3'
	+ char(10) + (case when @OldValueHidden_Filtered = 1 then '' else @HideField end) + ',OldValueHidden'
	+ char(10) + (case when @NewValueHidden_Filtered = 1 then '' else @HideField end) + ',NewValueHidden'
	+ char(10) + (case when @OldValue_Filtered = 1 then '' else @HideField end) + ',OldValue'
	+ char(10) + (case when @NewValue_Filtered = 1 then '' else @HideField end) + ',NewValue'
	+ char(10) + (case when @Reason_Filtered = 1 then '' else @HideField end) + ',Reason'
	+ char(10) + (case when @IsAuto_Filtered = 1 then '' else @HideField end) + ',IsAuto'
	+ char(10) + (case when @MasterTypeValueSource_Filtered = 1 then '' else @HideField end) + ',MasterTypeValueSource = mtv.Name'
	+ char(10) + (case when @TriggerDebugInfo_Filtered = 1 then '' else @HideField end) + ',TriggerDebugInfo'
	+ char(10) + (case when @ChangedBy_Filtered = 1 then '' else @HideField end) + ',ChangedBy'
	+ char(10) + (case when @ChangedOn_Filtered = 1 then '' else @HideField end) + ',ChangedOn=[dbo].[F_Get_DateTime_From_UTC] ([ChangedOn],' + cast(@TimeZoneID as nvarchar(20)) + ',null,''' + @TimeZoneName + ''')'
	+ char(10) + (case when @UTCChangedOn_Filtered = 1 then '' else @HideField end) + ',UTCChangedOn=ChangedOn
	FROM [dbo].[T_Audit_History] ah with (nolock) 
	INNER JOIN [dbo].[T_Audit_Column] ac with (nolock) ON ah.AC_ID = ac.AC_ID
	left JOIN [dbo].[T_Master_Type_Value] mtv_audit with (nolock) ON ah.AuditType_MTV_ID = mtv_audit.MTV_ID
	left JOIN [dbo].[T_Master_Type_Value] mtv with (nolock) ON ah.Source_MTV_ID = mtv.MTV_ID'

	--select @selectSql

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_CacheEntry]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[P_Get_CacheEntry]
    @cacheKey VARCHAR(800),
	@applicationID int
AS
BEGIN    
	select [Key],[Value],[CreatedOn],[ExpiredOn] from [dbo].[T_CacheEntries] with (nolock) where [Key] = @cacheKey and ApplicationID = @applicationID
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Common_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Get_Common_List]
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
/****** Object:  StoredProcedure [dbo].[P_Get_Master_Setup_DropDown_Lists]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	exec [P_Get_Master_Setup_DropDown_Lists] 'HAMMAS.KHAN'
CREATE   PROCEDURE [dbo].[P_Get_Master_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	select [value] = MT_ID, [text]= [Name] from [dbo].[T_Master_Type] with (nolock) order by [Name]

	select [value] = MTV_ID , [text]= Name from [dbo].[T_Master_Type_Value] with (nolock) WHERE IsActive = 1 order by [Name]
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_MasterType_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_MasterType_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
CREATE   PROCEDURE [dbo].[P_Get_MasterType_List] 
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
/****** Object:  StoredProcedure [dbo].[P_Get_MasterTypeValue_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_MasterTypeValue_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
CREATE   PROCEDURE [dbo].[P_Get_MasterTypeValue_List] 
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
/****** Object:  StoredProcedure [dbo].[P_Get_MTV_List_By_ID]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_Get_MTV_List_By_ID] 111
 CREATE   PROCEDURE [dbo].[P_Get_MTV_List_By_ID]
	@MT_ID int
	,@Username nvarchar(150) = null
AS
BEGIN	
	select MT_ID,[Name],MTV_ID,MTV_CODE,SubName,Sort_ from [dbo].[F_Get_MTV_List_By_ID] (@MT_ID,@Username) order by Sort_
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Page_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Page_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_Page_List]
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
/****** Object:  StoredProcedure [dbo].[P_Get_Page_Rights]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Page_Rights] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_Page_Rights]
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
/****** Object:  StoredProcedure [dbo].[P_Get_Page_Rights_Struct_Class]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_Get_Page_Rights_Struct_Class] '2024-03-22','2024-03-22',null,0,0
 CREATE   PROCEDURE [dbo].[P_Get_Page_Rights_Struct_Class]
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
/****** Object:  StoredProcedure [dbo].[P_Get_Page_Setup_DropDown_Lists]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Get_Page_Setup_DropDown_Lists]
	@Username nvarchar(150)

AS
BEGIN
	
	select [value] = PG_ID, [text]= PageGroupName from [dbo].[T_Page_Group] with (nolock) order by PageGroupName

	select [value] = P_ID, [text]= PageName from [dbo].[T_Page] with (nolock) order by PageName

	SELECT [value] = [MTV_ID] ,[text]= [Name] FROM [dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 148 order by [Name]
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_PageChart_Dropdown_Lists]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Get_PageChart_Dropdown_Lists]
AS
BEGIN
	
	SELECT code = MTV_CODE, [name] = SubName FROM [dbo].[F_Get_MTV_List_By_ID] (148, null) ORDER BY Sort_
	SELECT code = R_ID, [name] = RoleName FROM [dbo].[T_Roles] WITH (NOLOCK) WHERE IsActive = 1
	SELECT code = UserName, [name] = CONCAT(FirstName, ' ', LastName) FROM [dbo].[T_Users] WITH (NOLOCK) WHERE IsActive = 1 

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_PageChart_Json]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	exec [dbo].[P_Get_PageChart_Json]
 CREATE   PROCEDURE [dbo].[P_Get_PageChart_Json]
	@RoleID int = null,
	@ApplicationID int = null
AS
BEGIN
	
	Declare @Json nvarchar(max) = ''
	select @Json = [dbo].[F_Get_PageChart_Json] (@RoleID,@ApplicationID)
	select @Json as [Json]

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_PageGroup_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_PageGroup_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '[]', '[{"Code":"RowNo","Name":"#","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"PG_ID","Name":"Page ID","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"PageGroupName","Name":"Page Group Name","IsColumnRequired":false,"IsHidden":false,"IsChecked":false},{"Code":"Sort_","Name":"Sort_","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"IsHide","Name":"IsHide","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"IsActive","Name":"IsActive","IsColumnRequired":false,"IsHidden":false,"IsChecked":false},{"Code":"Action","Name":"Action","IsColumnRequired":false,"IsHidden":false,"IsChecked":false}]' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_PageGroup_List]
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
/****** Object:  StoredProcedure [dbo].[P_Get_PageRight_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Declare @TotalCount int = 0 exec [dbo].[P_Get_PageRight_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_PageRight_List] 
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
/****** Object:  StoredProcedure [dbo].[P_Get_Pages_Info_By_User]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_Get_Pages_Info_By_User] 'HAMMA>KHAN', 148100
 CREATE   PROCEDURE [dbo].[P_Get_Pages_Info_By_User] 
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
/****** Object:  StoredProcedure [dbo].[P_Get_Rights_Setup_DropDown_Lists]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Get_Rights_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	SELECT [value] = R_ID, [text]= RoleName FROM [dbo].[T_Roles] WITH (NOLOCK) ORDER BY RoleName
	SELECT [value] = P_ID, [text]= PageName FROM [dbo].[T_Page] WITH (NOLOCK) ORDER BY PageName
	SELECT [value] = PR_ID, [text]= PageRightName FROM [dbo].[T_Page_Rights] WITH (NOLOCK) ORDER BY PageRightName

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Rights_From_RoleID]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_Get_Role_Rights_From_RoleID] 12,0,0.0,''
 CREATE   PROCEDURE [dbo].[P_Get_Role_Rights_From_RoleID]
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
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Rights_From_Username]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_Get_Role_Rights_From_Username] 'ABDULLAH.ARSHAD',0.0,''
 CREATE   PROCEDURE [dbo].[P_Get_Role_Rights_From_Username]
	@Username nvarchar(150)
	,@P_ID int = 0
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
AS
BEGIN
	
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [dbo].[F_Get_Role_Rights_From_Username] (@Username ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Setup_DropDown_Lists]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Get_Role_Setup_DropDown_Lists]
	@Username nvarchar(150)

AS
BEGIN
	
	SELECT [value] = R_ID, [text]= RoleName FROM [dbo].[T_Roles] WITH (NOLOCK) ORDER BY RoleName
	SELECT [value] = RG_ID, [text]= RoleGroupName FROM [dbo].[T_Role_Group] WITH (NOLOCK) ORDER BY RoleGroupName

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_RolePageRightMap_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--	Declare @TotalCount int = 0 exec [dbo].[P_Get_RolePageRightMap_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_RolePageRightMap_List] 
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
/****** Object:  StoredProcedure [dbo].[P_Get_Roles_Group_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Roles_Group_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_Roles_Group_List]
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
/****** Object:  StoredProcedure [dbo].[P_Get_Roles_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Roles_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_Roles_List]
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
/****** Object:  StoredProcedure [dbo].[P_Get_RolesGroupMap_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_RolesGroupMap_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_RolesGroupMap_List]
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
/****** Object:  StoredProcedure [dbo].[P_Get_User_Info]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_Get_User_Info] 'Hammas.Khan',1
 CREATE   PROCEDURE [dbo].[P_Get_User_Info]
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
/****** Object:  StoredProcedure [dbo].[P_Get_UserRoleMap_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_UserRoleMap_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_UserRoleMap_List] 
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
/****** Object:  StoredProcedure [dbo].[P_Get_Users_List]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Users_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount
 CREATE   PROCEDURE [dbo].[P_Get_Users_List]
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
/****** Object:  StoredProcedure [dbo].[P_Is_Has_Right_From_RoleID]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_Is_Has_Right_From_RoleID] 1,true,0,''
 CREATE   PROCEDURE [dbo].[P_Is_Has_Right_From_RoleID]
	@ROLE_ID int
	,@IsGroupRoleID bit
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
AS
BEGIN
	select [dbo].[F_Is_Has_Right_From_RoleID] (@ROLE_ID ,@IsGroupRoleID ,@PR_ID ,@PageRightType_MTV_CODE)
END
GO
/****** Object:  StoredProcedure [dbo].[P_Is_Has_Right_From_Username]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[P_Is_Has_Right_From_Username]
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
/****** Object:  StoredProcedure [dbo].[P_Remove_Generic]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--		EXEC [dbo].[P_Remove_Generic] '','',1,'',''
 CREATE   PROC [dbo].[P_Remove_Generic]
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
/****** Object:  StoredProcedure [dbo].[P_Sync_RolePageRights]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [P_Sync_RolePageRights] 3,2,0,0,303,NULL,'HAMMAS.KHAN'
-- EXEC [P_Sync_RolePageRights] 3,2,0,0,303,1,'HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_Sync_RolePageRights]
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
/****** Object:  StoredProcedure [dbo].[P_Update_Page_Sorting]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [P_Update_PageGroup_Sorting] '[{"New_Sort_Value":1,"Sort_ID":1,"Sort_Text":"General","Old_Sort_Value":1},{"New_Sort_Value":2,"Sort_ID":2,"Sort_Text":"Home","Old_Sort_Value":2},{"New_Sort_Value":3,"Sort_ID":3,"Sort_Text":"Medical Claim","Old_Sort_Value":3},{"New_Sort_Value":4,"Sort_ID":5,"Sort_Text":"Reports","Old_Sort_Value":4},{"New_Sort_Value":5,"Sort_ID":4,"Sort_Text":"Security","Old_Sort_Value":5}]','HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_Update_Page_Sorting]
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
/****** Object:  StoredProcedure [dbo].[P_Update_PageGroup_Sorting]    Script Date: 4/20/2024 7:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [P_Update_PageGroup_Sorting] '[{"New_Sort_Value":1,"Sort_ID":1,"Sort_Text":"General","Old_Sort_Value":1},{"New_Sort_Value":2,"Sort_ID":2,"Sort_Text":"Home","Old_Sort_Value":2},{"New_Sort_Value":3,"Sort_ID":3,"Sort_Text":"Medical Claim","Old_Sort_Value":3},{"New_Sort_Value":4,"Sort_ID":5,"Sort_Text":"Reports","Old_Sort_Value":4},{"New_Sort_Value":5,"Sort_ID":4,"Sort_Text":"Security","Old_Sort_Value":5}]','HAMMAS.KHAN'
 CREATE   PROC [dbo].[P_Update_PageGroup_Sorting]
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
