USE [MSPL_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_General_JsonDocTable]    Script Date: 4/6/2024 6:57:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [MSPL_DB].[dbo].[F_Get_General_JsonDocTable] ('C100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_General_JsonDocTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(FileGUID nvarchar(36)
,Path_ nvarchar(250)
,OriginalFileName nvarchar(250)
,FileExt nvarchar(10)
,Description_ nvarchar(250)
,IsPublic bit
,AttachmentType_MTV_ID int
,RefNo nvarchar(40)
,RefNo2 nvarchar(40)
,RefID int
,RefID2 int
)
AS
begin
	
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
	
	insert into @ReturnTable (FileGUID ,Path_ ,OriginalFileName ,FileExt ,Description_ ,IsPublic ,AttachmentType_MTV_ID ,RefNo ,RefNo2 ,RefID ,RefID2)
	select * from (
		select FileGUID 
		,Path_ ,OriginalFileName ,FileExt ,Description_ ,IsPublic ,AttachmentType_MTV_ID
		,RefNo 
		,RefNo2 
		,RefID 
		,RefID2 
		from OpenJson(@Json)
		WITH (
			OrderFileGUID nvarchar(36) '$.fileguid'
			,Path_ nvarchar(250) '$.path'
			,OriginalFileName nvarchar(250) '$.filename'
			,FileExt nvarchar(10) '$.fileext'
			,Description_ nvarchar(250) '$.description'
			,IsPublic bit '$.ispublic'
			,AttachmentType_MTV_ID int '$.attachmenttype'
			,RefNo int '$.refno'
			,RefNo2 int '$.refno2'
			,RefID int '$.refid'
			,RefID2 int '$.refid2'
			,filelist nvarchar(max) '$.filelist' as json
		) I_Docs
		OUTER APPLY OpenJson(I_Docs.[filelist])
		WITH (
			FileGUID nvarchar(36) '$.fileguid'
		) I_Docs2
	) ilv 
	order by isnull(ilv.RefNo,''),isnull(ilv.RefID,0)

	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_List_By_ID_2]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [MSPL_DB].[dbo].[F_Get_List_By_ID_2] (100)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_List_By_ID_2]
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
	from [MSPL_DB].[dbo].[T_Master_Type] mt 
	left join [MSPL_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = @MT_ID
	order by Sort_

	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Master_List_By_MT_ID]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_Get_Master_List_By_MT_ID]
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
	from [MSPL_DB].[dbo].[T_Master_Type] mt 
	left join [MSPL_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = @MT_ID
	order by Sort_

	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_MasterTypeValue_From_MTV_CODE]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_MasterTypeValue_From_MTV_CODE]  
(
	@MTV_CODE nvarchar(20)
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@MTV_CODE,'') != ''
	begin
		select @Ret = [Name] from [MSPL_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_CODE = @MTV_CODE
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PageChart_Json]    Script Date: 4/6/2024 6:57:22 AM ******/
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
							FROM [MSPL_DB].[dbo].[T_Page_Rights] AS PageRights with (nolock)
							left join [MSPL_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) on PageRights.PR_ID = rprm.PR_ID --and rprm.R_ID = r1.R_ID
							WHERE PageRights.P_ID = Pages.P_ID and PageRights.PR_ID <> 100100 order by PageRights.Sort_
							FOR JSON PATH
						) AS PageRightsInfo
					FROM [MSPL_DB].[dbo].[T_Page] AS Pages with (nolock)
					INNER JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] a2 with (nolock) ON Pages.Application_MTV_ID = a2.MTV_ID
					WHERE Pages.PG_ID = PageGroups.PG_ID and (@ApplicationID is null or (@ApplicationID is not null and a2.MTV_ID = @ApplicationID)) order by Pages.Sort_
					FOR JSON PATH
				) AS PageInfo
		FROM [MSPL_DB].[dbo].[T_Master_Type_Value] a1 with (nolock)
			cross apply [MSPL_DB].[dbo].[T_Page_Group] AS PageGroups with (nolock)
			--cross apply [MSPL_DB].[dbo].[T_Roles] r1 with (nolock)
			WHERE a1.MTV_ID = apgm.Application_MTV_CODE and (@ApplicationID is null or (@ApplicationID is not null and a1.MTV_ID = @ApplicationID))
			--and (@RoleID is null or (@RoleID is not null and r1.R_ID = @RoleID))
			order by PageGroups.Sort_
			FOR JSON PATH
	) AS PageGroupInfo

	FROM [MSPL_DB].[dbo].[T_Master_Type_Value] a WITH (NOLOCK) 
	INNER JOIN [MSPL_DB].[dbo].[T_Application_Page_Group_Mapping] AS apgm with (nolock) ON a.MTV_CODE = apgm.Application_MTV_CODE
	WHERE a.MT_ID = 148 and (@ApplicationID is null or (@ApplicationID is not null and a.MTV_ID = @ApplicationID))
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) + ']'

	if @Return_Json is null	begin set @Return_Json = '' end

	return @Return_Json

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Role_Rights_From_RoleID]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [MSPL_DB].[dbo].[F_Get_Role_Rights_From_RoleID] (12,0,0,0,'')
-- =============================================
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
	select @IsAdmin = [MSPL_DB].[dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)
	set @IsAdmin = isnull(@IsAdmin,0)

	Declare @RolesTable table (ROLE_ID int)
	if @IsGroupRoleID = 1
	begin
		insert into @RolesTable (ROLE_ID)
		select R_ID from [MSPL_DB].[dbo].[T_Role_Group_Mapping] rgm with (nolock) where rgm.RG_ID = @ROLE_ID and rgm.IsActive = 1
	end
	else
	begin
		insert into @RolesTable (ROLE_ID)
		select @ROLE_ID
	end

	if @IsAdmin = 1
	begin
		insert into @ReturnTable (PR_ID , IsRightActive , PageRightName , PageRightType_MTV_CODE )
		select pr.PR_ID , pr.IsActive , pr.PageRightName , pr.PageRightType_MTV_CODE from [MSPL_DB].[dbo].[T_Page_Rights] pr with (nolock) where pr.IsActive = 1
		and ((@P_ID > 0 and pr.P_ID = @P_ID) or @P_ID = 0)
		and ((@PR_ID > 0 and pr.PR_ID = @PR_ID) or @PR_ID = 0)
		and ((@PageRightType_MTV_CODE <> '' and pr.PageRightType_MTV_CODE = @PageRightType_MTV_CODE) or @PageRightType_MTV_CODE = '')
	end
	else
	begin
		Declare @TempRoleRightsTable table (PR_ID int, IsRightActive bit)
		insert into @TempRoleRightsTable (PR_ID ,IsRightActive)
		select rprm.PR_ID,rprm.IsRightActive from [MSPL_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable) and rprm.IsActive = 1 and rprm.IsRightActive = 1

		insert into @TempRoleRightsTable (PR_ID ,IsRightActive)
		select rprm.PR_ID,rprm.IsRightActive from [MSPL_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable) and rprm.IsActive = 1 and rprm.IsRightActive = 0
		and rprm.PR_ID not in (select rrt.PR_ID from @TempRoleRightsTable rrt where rrt.IsRightActive = 1)

		insert into @ReturnTable (PR_ID , IsRightActive , PageRightName , PageRightType_MTV_CODE )
		select pr.PR_ID , pr.IsActive , pr.PageRightName , pr.PageRightType_MTV_CODE 
		from [MSPL_DB].[dbo].[T_Page_Rights] pr with (nolock) 
		inner join @TempRoleRightsTable trrt on pr.PR_ID = trrt.PR_ID
		where pr.IsActive = 1
		and ((@P_ID > 0 and pr.P_ID = @P_ID) or @P_ID = 0)
		and ((@PR_ID > 0 and pr.PR_ID = @PR_ID) or @PR_ID = 0)
		and ((@PageRightType_MTV_CODE <> '' and pr.PageRightType_MTV_CODE = @PageRightType_MTV_CODE) or @PageRightType_MTV_CODE = '')
	end

	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Role_Rights_From_Username]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [MSPL_DB].[dbo].[F_Get_Role_Rights_From_Username] ('ABDULLAH.ARSHAD',0,0,'')
-- =============================================
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
	
	select @ROLE_ID = urm.ROLE_ID ,@IsGroupRoleID = urm.IsGroupRoleID from [MSPL_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username and urm.IsActive = 1
	
	insert into @ReturnTable
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [MSPL_DB].[dbo].[F_Get_Role_Rights_From_RoleID] (	@ROLE_ID ,@IsGroupRoleID ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Role_Rights_Json]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
							FROM [MSPL_DB].[dbo].[T_Page_Rights] AS PageRights with (nolock)
							left join [MSPL_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) on PageRights.PR_ID = rprm.PR_ID and rprm.R_ID = r.R_ID
							WHERE PageRights.P_ID = Pages.P_ID and PageRights.PR_ID <> 100100 order by PageRights.Sort_
							FOR JSON PATH
						) AS PageRightsInfo
					FROM [MSPL_DB].[dbo].[T_Page] AS Pages with (nolock)
					WHERE Pages.PG_ID = PageGroups.PG_ID order by Pages.Sort_
					FOR JSON PATH
				) AS PageInfo
			FROM [MSPL_DB].[dbo].[T_Roles] r1 with (nolock)
			cross apply [MSPL_DB].[dbo].[T_Page_Group] AS PageGroups with (nolock)
			WHERE r1.R_ID = r.R_ID order by PageGroups.Sort_
			FOR JSON PATH
		) AS PageGroupInfo
	from [MSPL_DB].[dbo].[T_Roles] r with (nolock)
	where r.R_ID = @RoleID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	if @Return_Json is null
		begin set @Return_Json = '' end
	--else
	--	begin set @Return_Json = replace(replace(replace(replace(@Return_Json,'{},',''),'[{}]','null'),'[]','null'),'[]','null') end

	return @Return_Json

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_RoleName_From_RoleID]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
		select @Ret = R.[RoleName] from [MSPL_DB].[dbo].[T_Roles] R with (nolock) where R.[R_ID] = @RoleID
		set @Ret = isnull(@Ret,'')
	end
	else
	begin
		select @Ret = RG.[RoleGroupName] from [MSPL_DB].[dbo].[T_Role_Group] RG with (nolock) where RG.[RG_ID] = @RoleID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_RolePageRight_JsonTable]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



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
/****** Object:  UserDefinedFunction [dbo].[F_Get_T_TMS_Tasks_JsonTable]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
/****** Object:  UserDefinedFunction [dbo].[F_Get_T_UserDetials_JsonTable]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[F_Get_T_UserDetials_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
    [USER_ID] int
    ,USERNAME NVARCHAR(50)
	,UserType_MTV_CODE NVARCHAR(20)
	,PasswordHash NVARCHAR(250)
	,PasswordSalt NVARCHAR(250)
	,D_ID int
	,ROLE_ID int
	,IsGroupRoleID bit
	,Designation nvarchar(150)
	,FirstName nvarchar(50)
	,MiddleName nvarchar(50)
	,LastName nvarchar(50)
	,Company nvarchar(250)
	,[Address] nvarchar(250)
	,Address2 nvarchar(250)
	,[City] nvarchar(50)
	,[State] nvarchar(5)
	,[ZipCode] nvarchar(10)
	,Country nvarchar(50)
	,Email nvarchar(250)
	,Mobile nvarchar(30)
	,Phone nvarchar(40)
	,PhoneExt nvarchar(20)
	,SecurityQuestion_MTV_ID int
	,EncryptedAnswer nvarchar(250)
	,TIMEZONE_ID int
	,IsApproved bit
	,BlockType_MTV_ID int
	,IsAPIUser bit
	,IsActive bit
	,UserApplicationJson nvarchar(max)
)
AS
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
    
    INSERT INTO @ReturnTable ([USER_ID] ,USERNAME ,UserType_MTV_CODE ,PasswordHash ,PasswordSalt ,D_ID ,ROLE_ID ,IsGroupRoleID ,Designation ,FirstName ,MiddleName ,LastName ,Company ,[Address] ,Address2 
		,[City] ,[State] ,[ZipCode] ,Country ,Email ,Mobile ,Phone ,PhoneExt ,SecurityQuestion_MTV_ID ,EncryptedAnswer ,TIMEZONE_ID ,IsApproved ,BlockType_MTV_ID ,IsAPIUser ,IsActive ,UserApplicationJson)
    SELECT 
        UserID
        ,UserName=upper(UserName)
		,UserType_MTV_CODE
        ,PasswordHash 
        ,PasswordSalt 
		,D_ID 
		,ROLE_ID 
        ,IsGroupRoleID 
		,Designation 
        ,FirstName 
		,MiddleName 
        ,LastName 
        ,company 
        ,address1 
        ,address2 
        ,city 
        ,[state] 
        ,zipCode 
        ,country 
        ,[email] 
        ,mobile 
        ,phone 
        ,phoneExt 
        ,SecurityQuestion_MTV_ID 
        ,EncryptedAnswer 
		,timeZoneID 
        ,isApproved 
        ,blockType 
        ,isAPIUser 
		,isActive
		,UserApplicationJson
    FROM OPENJSON(@Json)
    WITH (
        UserID int '$.USER_ID',
        UserName NVARCHAR(50) '$.USERNAME',
		UserType_MTV_CODE nvarchar(20) '$.UserType_MTV_CODE',
        PasswordHash NVARCHAR(50) '$.PasswordHash',
        PasswordSalt NVARCHAR(50) '$.PasswordSalt',
		D_ID int '$.D_ID',
		ROLE_ID int '$.R_ID',
        IsGroupRoleID bit '$.IsGroupRoleID',
		Designation nvarchar(150) '$.Designation',
        FirstName NVARCHAR(50) '$.FirstName',
		MiddleName NVARCHAR(50) '$.MiddleName',
        LastName NVARCHAR(50) '$.LastName',
        company NVARCHAR(250) '$.Company',
        address1 NVARCHAR(250) '$.Address',
        address2 NVARCHAR(250) '$.Address2',
        city NVARCHAR(50) '$.City',
        [state] NVARCHAR(5) '$.State',
        zipCode NVARCHAR(10) '$.ZipCode',
        country NVARCHAR(50) '$.Country',
        [email] NVARCHAR(250) '$.Email',
        mobile NVARCHAR(30) '$.Mobile',
        phone NVARCHAR(40) '$.Phone',
        phoneExt NVARCHAR(20) '$.PhoneExt',
        SecurityQuestion_MTV_ID int '$.SecurityQuestion_MTV_ID',
        EncryptedAnswer NVARCHAR(250) '$.EncryptedAnswer',
		timeZoneID int '$.TIMEZONE_ID',
        isApproved BIT '$.IsApproved',
        blockType int '$.BlockType_MTV_ID',
        isAPIUser BIT '$.IsAPIUser',
		isActive BIT '$.IsActive',
		UserApplicationJson nvarchar(max) '$.ApplicationAccess' as json
    );

    RETURN;
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Fields_Column]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [dbo].[F_Get_Table_Fields_Column] ('')
-- =============================================
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
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Fields_Filter]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [dbo].[F_Get_Table_Fields_Filter] ('')
-- =============================================
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
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Hidden_Fields_Filter]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [MSPL_DB].[dbo].[F_Get_Table_Hidden_Fields_Filter] ('')
-- =============================================
Create FUNCTION [dbo].[F_Get_Table_Hidden_Fields_Filter]
(	
	@Json nvarchar(max)
)
returns @ReturnTable table
(Code nvarchar(150)
,fieldvalue nvarchar(1000)
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

	insert into @ReturnTable (Code ,fieldvalue ,IsFilterApplied)
	select * from (
		select Code = isnull(ret.Code,'')
		,fieldvalue = isnull(ret.fieldvalue,'')
		,IsFilterApplied = isnull(ret.IsFilterApplied,0)

		from OpenJson(@Json)
		WITH (
			Code nvarchar(150) '$.Code'
			,fieldvalue nvarchar(1000) '$.fieldvalue'
			,IsFilterApplied bit '$.IsFilterApplied'
		) ret
	) ilv where Code <> ''
	
	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Used]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_Get_Table_Used] 
(	
	@FilterObject nvarchar(max) = '',
	@ColumnObject nvarchar(max) = ''
)
RETURNS @ReturnTable TABLE 
(IsUsed bit, TableName nvarchar(100))
AS
begin
	
	Declare @Table_Fields_Filter table (Code nvarchar(150) ,Name_ nvarchar(150) ,IsFilterApplied bit)
	insert into @Table_Fields_Filter (Code ,Name_ ,IsFilterApplied )
	select [Code],[Name],[IsFilterApplied] from [MSPL_DB].[dbo].[F_Get_Table_Fields_Filter] (@FilterObject)
  
	Declare @Table_Fields_Column table (Code nvarchar(150) ,Name_ nvarchar(150) ,IsColumnRequired bit)
	insert into @Table_Fields_Column (Code ,Name_ ,IsColumnRequired )
	select [Code],[Name],[IsColumnRequired] from [MSPL_DB].[dbo].[F_Get_Table_Fields_Column] (@ColumnObject)
	
	Declare @T_Order_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('ActualDeliveryDate,ActualPickupDate,BillingType_MTV_CODE,BillTo_Address,BillTo_ADDRESS_CODE,BillTo_Address2,BillTo_City,BillTo_Company,BillTo_ContactPerson,BillTo_CountryRegionCode,BillTo_County,BillTo_CUSTOMER_NO,BillTo_Email,BillTo_FirstName,BillTo_LastName,BillTo_MiddleName,BillTo_Mobile,BillTo_Phone,BillTo_PhoneExt,BillTo_State,BillTo_ZipCode,BillToSub_CUSTOMER_NO,Carrier_MTV_CODE,ConfirmedDeliveryTimeFrame_TFL_ID,ConfirmedPickupTimeFrame_TFL_ID,Delivery_OG_ID,DELIVERY_SST_CODE,DELIVERY_ST_CODE,DeliveryScheduleType_MTV_ID,DlvSchByUserName,FirstOffered_DeliveryDate,FirstOffered_PickupDate,InsuranceRequired,IsBlindShipTo,LiveShipFrom_HUB_CODE,LiveShipTo_HUB_CODE,ORDER_CODE,ORDER_CODE_GUID,ORDER_ID,OrderPriority_MTV_ID,OrderSource_MTV_ID,OrderStatus_MTV_ID,OrderSubSource_MTV_CODE,OrderSubSourceFileName,PARENT_ORDER_ID,PaymentStatus_MTV_ID,Pickup_OG_ID,PICKUP_SST_CODE,PICKUP_ST_CODE,PickupScheduleType_MTV_ID,PkpSchByUserName,PromisedDeliveryDate,PromisedPickupDate,QuoteAmount,QuoteID,ReqDelivery_Date,ReqDelivery_FromTime,ReqDelivery_ToTime,ReqDeliveryTimeFrame_TFL_ID,ReqPickup_Date,ReqPickup_FromTime,ReqPickup_ToTime,ReqPickupTimeFrame_TFL_ID,SELLER_CODE,SELLER_PARTNER_CODE,ShipFrom_Address,ShipFrom_ADDRESS_CODE,ShipFrom_Address2,ShipFrom_AreaType_MTV_ID,ShipFrom_ChangeCount,ShipFrom_City,ShipFrom_Company,ShipFrom_ContactPerson,ShipFrom_CountryRegionCode,ShipFrom_County,ShipFrom_Email,ShipFrom_FirstName,ShipFrom_HUB_CODE,ShipFrom_LastName,ShipFrom_Lat,ShipFrom_Lng,ShipFrom_MiddleName,ShipFrom_Mobile,ShipFrom_Phone,ShipFrom_PhoneExt,ShipFrom_PlaceID,ShipFrom_State,ShipFrom_ZipCode,ShipFrom_ZONE_CODE,ShipmentRegDate,ShippingStatus_EVENT_ID,ShipTo_Address,ShipTo_ADDRESS_CODE,ShipTo_Address2,ShipTo_AreaType_MTV_ID,ShipTo_ChangeCount,ShipTo_City,ShipTo_Company,ShipTo_ContactPerson,ShipTo_CountryRegionCode,ShipTo_County,ShipTo_Email,ShipTo_FirstName,ShipTo_HUB_CODE,ShipTo_LastName,ShipTo_Lat,ShipTo_Lng,ShipTo_MiddleName,ShipTo_Mobile,ShipTo_Phone,ShipTo_PhoneExt,ShipTo_PlaceID,ShipTo_State,ShipTo_ZipCode,ShipTo_ZONE_CODE,SUB_SELLER_CODE,TARIFF_NO,TRACKING_NO')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order')
	end

	Declare @T_Order_Additional_Info_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Additional_Info_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('DlvAttemptCount,FirstFileMileFRBMDate,FirstFileMileFRBMHub,FirstFRBMDate,FirstFRBMHub,FirstScanDate,FirstScanHub,IsIndexUpdated,IsInvoiceProcessed,IsPhoneUpdated,IsPPJobDone,LastScanDate,LastScanHub,LastScanLocationID,LastViewedByUserName,LastViewedDate,OriginDepartureDate,ReSchCount,Revenue,RevenueWithCM,ShipToHub_FirstScanDate,ShipToZone_FirstScanDate')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Additional_Info_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Additional_Info_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Additional_Info')
	end

	Declare @T_Order_Archive_Detail_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Archive_Detail_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('Order_Access_Log_ArchiveDate,Order_Additional_Info_ArchiveDate,Order_ArchiveDate,Order_Audit_History_ArchiveDate,Order_Client_Identifier_ArchiveDate,Order_Comments_ArchiveDate,Order_Detail_ArchiveDate,Order_Docs_ArchiveDate,Order_Events_ArchiveDate,Order_Events_List_ArchiveDate,Order_Item_Scans_ArchiveDate,Order_Items_Additional_Info_ArchiveDate,Order_Items_ArchiveDate,Order_Related_Tickets_ArchiveDate,Order_Special_Instruction_ArchiveDate,Order_Special_Service_ArchiveDate')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Archive_Detail_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Archive_Detail_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Archive_Detail')
	end

	Declare @T_Order_Comments_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Comments_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('Comment,ImportanceLevel_MTV_ID,IsActive,IsCall,IsPublic,OC_ID,ORDER_ID,OrderStatus_MTV_ID,ShippingStatus_EVENT_ID')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Comments_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Comments_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Comments')
	end

	Declare @V_Order_Client_Identifier_Tlb_Fields table (id nvarchar(50))
	insert into  @V_Order_Client_Identifier_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('CARRIER,PONUMBER,PRO,REF2,TAG,COSTCO')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @V_Order_Client_Identifier_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @V_Order_Client_Identifier_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'V_Order_Client_Identifier')
	end

	Declare @T_Order_Client_Identifier_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Client_Identifier_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('OIF_CODE,Value_')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Client_Identifier_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Client_Identifier_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Client_Identifier')
	end

	Declare @T_Order_Events_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Events_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('EVENT_ID,HUB_CODE,IsAuto,Source_MTV_ID,TriggerDate_')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Events_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Events_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Events')
	end

	Declare @T_Order_Invoice_Header_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Invoice_Header_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('Amount,ApprovalValue_MTV_ID,BLDimension_MTV_CODE,CMAmount,DimensionID,DocumentDate,DocumentType_MTV_ID,DueDate,EDIStatus_MTV_ID,EstimateID,EstimateNo,InvoiceStatus_MTV_ID,LastPaymentDate,NeedEDI_MTV_ID,PaidAmount,PaymentTermsCode,POCustRefNo,PostedInvoiceNo,PostedOnDatetime,PostingDate,QBInvoiceNo,RECTXT,SLDimension_SL_CODE,UnpostedInvoiceNo,UnpostedOnDatetime,UpdateWRDimensionType_MTV_ID,WRDimension_HUB_CODE')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Invoice_Header_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Invoice_Header_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Invoice_Header')
	end

	Declare @T_Order_Invoice_Line_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Invoice_Line_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('BLDimension_MTV_CODE_Line,Description,DimensionID_Line,GL_NO,GoodsType,InvoiceLineType,ItemsCuFt,ItemsQty,ItemsValue,ItemsWeight,LineAmount,LineNo_,OIL_ID,Quantity,SalesLineType,SLDimension_SL_CODE_Line,UnitPrice,UpdateWRDimensionType_MTV_ID_Line,WRDimension_HUB_CODE_Line')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Invoice_Line_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Invoice_Line_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Invoice_Line')
	end

	Declare @T_Order_Items_Tlb_Fields table (id nvarchar(50))
	insert into  @T_Order_Items_Tlb_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('ItemValue,AssemblyTime,BARCODE,Cu_Ft_,Dimensions,DimensionUnit_MTV_CODE,ItemClientRef1,ItemClientRef2,ItemClientRef3,ItemCode_MTV_CODE,ItemDeliveryStatus_MTV_ID,ItemDescription,ItemHeight,ItemLength,ItemPickupStatus_MTV_ID,ItemToShip_MTV_CODE,ItemWeight,ItemWidth,ItemLineNo_,OI_ID,PackageDetailsNote,PackingCode_MTV_CODE,PARENT_OI_ID,ItemQuantity,RelabelCount,SKU_NO,Weight,WeightUnit_MTV_CODE')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Items_Tlb_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Items_Tlb_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Items')
	end

	Declare @T_Order_Items_Additional_Info_Fields table (id nvarchar(50))
	insert into  @T_Order_Items_Additional_Info_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('OIAI_BARCODE,OIAI_FirstScanDate,OIAI_FirstScanHub,OIAI_FirstScanType_MTV_ID,OIAI_IsActive,OIAI_IsDamaged,OIAI_LastScanDate,OIAI_LastScanHub,OIAI_LastScanLocationID,OIAI_LastScanType_MTV_ID,OIAI_ShipToHub_FirstScanDate,OIAI_ShipToZone_FirstScanDate,OIAI_WarehouseStatus_MTV_ID')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Items_Additional_Info_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Items_Additional_Info_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Items_Additional_Info')
	end

	Declare @T_Order_Item_Scans_Info_Fields table (id nvarchar(50))
	insert into  @T_Order_Item_Scans_Info_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('AutoScan,OIS_BARCODE,DamageNote,DeviceCode_MTV_CODE,ErrorMsg,OIS_HUB_CODE,ImageCount,OIS_IsActive,IsDamage,IsError,IsRelabelRequired,Lat,Lng,LOCATION_ID,MANIFEST_ID,ManifestType_MTV_ID,OI_GUID,OIS_ID,ScanAnytime,ScanBy,ScanTime,ScanType_MTV_ID')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Item_Scans_Info_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Item_Scans_Info_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Item_Scans')
	end

	Declare @T_Order_Item_Scans_Damage_Info_Fields table (id nvarchar(50))
	insert into  @T_Order_Item_Scans_Damage_Info_Fields (id)
	select id from [MSPL_DB].[dbo].[SplitIntoTable] ('Damage_MTV_ID')

	if exists(select Code from @Table_Fields_Filter where Code in (select id from @T_Order_Item_Scans_Damage_Info_Fields)) 
		or exists(select Code from @Table_Fields_Column where Code in (select id from @T_Order_Item_Scans_Damage_Info_Fields))
	begin
		insert into @ReturnTable (IsUsed , TableName )
		values (1, 'T_Order_Item_Scans_Damage')
	end

	return

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_TMS_TaskAttachments_JsonTable]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE FUNCTION [dbo].[F_Get_TMS_TaskAttachments_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
    TA_ID int,
	OriginalFileName nvarchar(500),
	[FileName] nvarchar(100),
	FileExt nvarchar(20),
	[Path] nvarchar(1000),
	DocumentType_MTV_ID int,
	AttachmentType_MTV_ID int ,
    REFID1 int ,
	REFID2 int,
	REFID3 int,
	REFID4 int,
	AttachmentsIsActive bit
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
     TA_ID  
	,OriginalFileName  
	,[FileName]  
	,FileExt  
	,[Path]  
	,DocumentType_MTV_ID  
	,AttachmentType_MTV_ID  
    ,REFID1  
	,REFID2  
	,REFID3  
	,REFID4  
	,AttachmentsIsActive 
		
    ) 
    SELECT 
     TA_ID  
	,OriginalFileName  
	,[FileName]  
	,FileExt  
	,[Path]  
	,DocumentType_MTV_ID  
	,AttachmentType_MTV_ID  
    ,REFID1  
	,REFID2  
	,REFID3  
	,REFID4  
	,AttachmentsIsActive 
		
    FROM OPENJSON(@Json)
    WITH (
	TA_ID int '$.TA_ID',
	OriginalFileName nvarchar(500) '$.OriginalFileName',
	[FileName] nvarchar(100) '$.FileName',
	FileExt nvarchar(20) '$.FileExt',
	[Path] nvarchar(1000) '$.Path',
	DocumentType_MTV_ID int'$.DocumentType_MTV_ID',
	AttachmentType_MTV_ID int '$.AttachmentType_MTV_ID',
    REFID1 int '$.REFID1',
	REFID2 int '$.REFID2',
	REFID3 int '$.REFID3',
	REFID4 int '$.REFID4',
	AttachmentsIsActive bit '$.Active'
		 
    )

    RETURN;
END;

 
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_TMS_TaskDetail_JsonTable]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




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
/****** Object:  UserDefinedFunction [dbo].[F_Get_UserApplicationAccess_JsonTable]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F_Get_UserApplicationAccess_JsonTable]
(   
    @Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(
    UAA_ID int, 
	USERNAME nvarchar(150), 
	Application_MTV_ID int, 
	NAV_USERNAME nvarchar(150), 
	IsActive bit
)
AS
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
    
    INSERT INTO @ReturnTable
    SELECT 
        UAA_ID,
		USERNAME,
		Application_MTV_ID,
		NAV_USERNAME=(case when NAV_USERNAME = '' then null else NAV_USERNAME end),
		IsActive
    FROM OPENJSON(@Json)
    WITH (
        UAA_ID int '$.UAA_ID',
        USERNAME NVARCHAR(150) '$.USERNAME',
		Application_MTV_ID int '$.Application_MTV_ID',
		NAV_USERNAME NVARCHAR(150) '$.NAV_USERNAME',
		IsActive bit '$.IsActive'
    );

    RETURN;
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Users_Json]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--select [dbo].[F_Get_Users_Json] ('IHTISHAMTETS')

CREATE FUNCTION [dbo].[F_Get_Users_Json]
(	
	 @UserName nvarchar(300)
	 
)
RETURNS nvarchar(max) 
AS
begin
	
	Declare @Return_Json nvarchar(max) = ''
	
	SELECT @Return_Json =  (SELECT
    USER_ID,
    u.USERNAME,
    u.UserType_MTV_CODE,
    --u.PasswordHash,
   -- u.PasswordSalt,
    u.D_ID,
	CONCAT(rm.ROLE_ID, '_', 
           CASE WHEN rm.IsGroupRoleID = 1 THEN 'true' ELSE 'false' END) AS R_ID,
    u.Designation,
    u.FirstName,
    u.MiddleName,
    u.LastName,
    u.Company,
    u.[Address],
    u.Address2,
    u.City,
    u.[State],
    u.ZipCode,
    u.Country,
    u.Email,
    u.Mobile,
    u.Phone,
    u.PhoneExt,
    u.SecurityQuestion_MTV_ID,
    --u.EncryptedAnswer,
    u.TIMEZONE_ID,
    u.IsApproved,
    u.BlockType_MTV_ID,
    u.IsAPIUser,
    u.IsActive,
	(
        SELECT
            uaa.UAA_ID,
            uaa.USERNAME,
            uaa.Application_MTV_ID,
            uaa.NAV_USERNAME,
            tmtv.name,
            uaa.IsActive
        FROM
            [MSPL_DB].[dbo].[T_User_Application_Access] uaa WITH (NOLOCK)
        INNER JOIN
            [MSPL_DB].[dbo].[T_Master_Type_Value] tmtv ON uaa.Application_MTV_ID = tmtv.MTV_ID
        WHERE
            tmtv.MT_ID = 148
            AND tmtv.IsActive = 1
            AND uaa.USERNAME = @UserName
            --AND uaa.IsActive = 1 
			for json path 
    ) AS ApplicationAccess 
    
FROM
    [MSPL_DB].[dbo].[T_Users] u WITH (NOLOCK)
	Left Join   [MSPL_DB].[dbo].[T_User_Role_Mapping] rm  WITH (NOLOCK) ON u.USERNAME = rm.USERNAME
    where u.UserName=@UserName
    
FOR JSON PATH)

	if @Return_Json is null	begin set @Return_Json = '' end

	return @Return_Json

end
GO
/****** Object:  UserDefinedFunction [dbo].[F_GetAssignedTo]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[F_GetAssignedTo] (@TD_ID INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @AssignedTo NVARCHAR(MAX)
    
    SELECT @AssignedTo = COALESCE(@AssignedTo + ', ', '') + AssignedTo
    FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] with (nolock)
    WHERE TD_ID = @TD_ID and IsActive=1
    
    RETURN ISNULL(@AssignedTo, '')
END
GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Admin_Right_From_RoleID]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





create FUNCTION [dbo].[F_Is_Admin_Right_From_RoleID]
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
		select R_ID from [MSPL_DB].[dbo].[T_Role_Group_Mapping] rgm with (nolock) where rgm.RG_ID = @ROLE_ID and rgm.IsActive = 1
	end
	else
	begin
		insert into @RolesTable (ROLE_ID)
		select @ROLE_ID
	end

	if exists(Select rprm.PR_ID from [MSPL_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable) and rprm.PR_ID = 100100)
	begin
		set @Ret = 1
	end

	set @Ret = isnull(@Ret,0)

	return @Ret

end

GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Admin_Right_From_Username]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




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

	select @ROLE_ID = urm.ROLE_ID , @IsGroupRoleID = urm.IsGroupRoleID from [MSPL_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username

	select @Ret = [MSPL_DB].[dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)

	set @Ret = isnull(@Ret,0)

	return @Ret

end

GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Has_Right_From_RoleID]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




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

	select @Ret = [MSPL_DB].[dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)
	set @Ret = isnull(@Ret,0)

	if (@Ret = 0)
	begin
		select @Ret = IsRightActive from [MSPL_DB].[dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID , @IsGroupRoleID ,0 ,@PR_ID ,@PageRightType_MTV_CODE)
		set @Ret = isnull(@Ret,0)
	end

	return @Ret

end

GO
/****** Object:  UserDefinedFunction [dbo].[F_Is_Has_Right_From_Username]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[F_Is_Has_Right_From_Username]
(
	@Username nvarchar(150)
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
)
RETURNS bit
AS
BEGIN
	
	DECLARE @Ret bit = 0
	set @Username = isnull(upper(@Username),'')
	set @PR_ID = isnull(@PR_ID,0)
	set @PageRightType_MTV_CODE = isnull(@PageRightType_MTV_CODE,'')
	
	if (@Username = '')
	begin
		return @Ret
	end

	if (@PR_ID = 0 and @PageRightType_MTV_CODE = '')
	begin
		return @Ret
	end

	Declare @ROLE_ID int = 0
	Declare @IsGroupRoleID bit = 0

	select @ROLE_ID = urm.ROLE_ID , @IsGroupRoleID = urm.IsGroupRoleID from [MSPL_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) where urm.USERNAME = @Username

	select @Ret = [MSPL_DB].[dbo].[F_Is_Admin_Right_From_RoleID] (@ROLE_ID , @IsGroupRoleID)

	set @Ret = isnull(@Ret,0)

	if (@Ret = 0)
	begin
		select @Ret = IsRightActive from [MSPL_DB].[dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID , @IsGroupRoleID ,0 ,@PR_ID ,@PageRightType_MTV_CODE)
		set @Ret = isnull(@Ret,0)
	end

	return @Ret

end

GO
/****** Object:  Table [dbo].[T_Audit_Column]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Audit_History]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Chat_Room]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Chat_Room_User_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Chats]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Chats_User_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Department]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Department](
	[TimeStamp] [timestamp] NOT NULL,
	[D_ID] [int] IDENTITY(1,1) NOT NULL,
	[DepartmentName] [nvarchar](50) NOT NULL,
	[Sort_] [int] NOT NULL,
	[IsHidden] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Department] PRIMARY KEY CLUSTERED 
(
	[D_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Department_Role_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Department_Role_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[DRM_ID] [int] IDENTITY(1,1) NOT NULL,
	[R_ID] [int] NOT NULL,
	[D_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Department_Role_Mapping] PRIMARY KEY CLUSTERED 
(
	[DRM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Docs]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Errors_List]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Events_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Events_List](
	[TimeStamp] [timestamp] NOT NULL,
	[EL_ID] [int] IDENTITY(1,1) NOT NULL,
	[EVENT_ID] [int] NOT NULL,
	[EVENT_CODE] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[Activity_MTV_ID] [int] NOT NULL,
	[IsAutoTrigger] [bit] NOT NULL,
	[IsManualTrigger] [bit] NOT NULL,
	[IsOutboundRequired] [bit] NOT NULL,
	[IsNotify_Metro_Email] [bit] NOT NULL,
	[IsNotify_Metro_SMS] [bit] NOT NULL,
	[IsNotify_Client_Email] [bit] NOT NULL,
	[IsNotify_Client_SMS] [bit] NOT NULL,
	[IsNotify_OED_Email] [bit] NOT NULL,
	[IsNotify_OED_SMS] [bit] NOT NULL,
	[IsNotify_CSR_Email] [bit] NOT NULL,
	[IsNotify_CSR_SMS] [bit] NOT NULL,
	[IsNotify_Dispatch_Email] [bit] NOT NULL,
	[IsNotify_Dispatch_SMS] [bit] NOT NULL,
	[IsNotify_Accounting_Email] [bit] NOT NULL,
	[IsNotify_Accounting_SMS] [bit] NOT NULL,
	[IsNotify_Warehouse_Email] [bit] NOT NULL,
	[IsNotify_Warehouse_SMS] [bit] NOT NULL,
	[IsNotify_ShipFrom_Email] [bit] NOT NULL,
	[IsNotify_ShipFrom_SMS] [bit] NOT NULL,
	[IsNotify_ShipTo_Email] [bit] NOT NULL,
	[IsNotify_ShipTo_SMS] [bit] NOT NULL,
	[IsNotify_SellTo_Email] [bit] NOT NULL,
	[IsNotify_SellTo_SMS] [bit] NOT NULL,
	[IsNotify_SellToPartner_Email] [bit] NOT NULL,
	[IsNotify_SellToPartner_SMS] [bit] NOT NULL,
	[IsNotify_BillTo_Email] [bit] NOT NULL,
	[IsNotify_BillTo_SMS] [bit] NOT NULL,
	[IsRecurring] [bit] NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[IsTrackingAvailable] [bit] NOT NULL,
	[IsUpdateShippingStatus] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Events_List] PRIMARY KEY CLUSTERED 
(
	[EL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Feedback]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Feedback](
	[TimeStamp] [datetime] NOT NULL,
	[FDB_ID] [int] NOT NULL,
	[MessageData] [nvarchar](150) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NOT NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK__T_Feedba__5F7254CCF1A1F180] PRIMARY KEY CLUSTERED 
(
	[FDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Master_Type]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Master_Type_Value]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Page]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Page_Group]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Page_Rights]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Report_Column_Fields]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Report_Column_Fields](
	[TimeStamp] [timestamp] NOT NULL,
	[RCF_ID] [int] IDENTITY(1,1) NOT NULL,
	[RL_ID] [int] NOT NULL,
	[ColumnName] [nvarchar](50) NOT NULL,
	[Position] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Report_Column_Fields] PRIMARY KEY CLUSTERED 
(
	[RCF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Report_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Report_List](
	[TimeStamp] [timestamp] NOT NULL,
	[RL_ID] [int] IDENTITY(1,1) NOT NULL,
	[RSP_ID] [int] NOT NULL,
	[ReportName] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
	[IsGeneral] [bit] NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Reports_List] PRIMARY KEY CLUSTERED 
(
	[RL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Report_Store_Procedure]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Report_Store_Procedure](
	[TimeStamp] [timestamp] NOT NULL,
	[RSP_ID] [int] IDENTITY(1,1) NOT NULL,
	[StoreProcedureName] [nvarchar](100) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Report_Store_Procedure] PRIMARY KEY CLUSTERED 
(
	[RSP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Report_Store_Procedure_Fields]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Report_Store_Procedure_Fields](
	[TimeStamp] [timestamp] NOT NULL,
	[RSPF_ID] [int] IDENTITY(1,1) NOT NULL,
	[RSP_ID] [int] NOT NULL,
	[FieldName] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Report_Store_Procedure_Fields] PRIMARY KEY CLUSTERED 
(
	[RSPF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Report_Store_Procedure_Where_Clause]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Report_Store_Procedure_Where_Clause](
	[TimeStamp] [timestamp] NOT NULL,
	[RSPWC_ID] [int] IDENTITY(1,1) NOT NULL,
	[RSPF_ID] [int] NOT NULL,
	[WhereClause_MTV_CODE] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[Limit] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Report_Store_Procedure_Where_Clause] PRIMARY KEY CLUSTERED 
(
	[RSPWC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_Role_Group]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Role_Group_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Role_Page_Rights_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Roles]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_TMS_AssignedTo_List]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_TMS_Chats_Room_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_TMS_TaskAssignedTo_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_TMS_TaskAttachments]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_TMS_TaskDetail]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_TMS_Tasks]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_User_Application_Access]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_User_Application_Access](
	[TimeStamp] [timestamp] NOT NULL,
	[UAA_ID] [int] IDENTITY(1,1) NOT NULL,
	[USERNAME] [nvarchar](150) NOT NULL,
	[Application_MTV_ID] [int] NOT NULL,
	[NAV_USERNAME] [nvarchar](150) NULL,
	[LastLoginDateTime] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_User_Application_Access] PRIMARY KEY CLUSTERED 
(
	[UAA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[T_User_Role_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  Table [dbo].[T_Users]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Users](
	[TimeStamp] [timestamp] NOT NULL,
	[USER_ID] [int] NOT NULL,
	[USERNAME] [nvarchar](50) NOT NULL,
	[UserType_MTV_CODE] [nvarchar](20) NOT NULL,
	[PasswordHash] [nvarchar](250) NOT NULL,
	[PasswordSalt] [nvarchar](250) NOT NULL,
	[D_ID] [int] NULL,
	[Designation] [nvarchar](150) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[Company] [nvarchar](250) NULL,
	[Address] [nvarchar](250) NULL,
	[Address2] [nvarchar](250) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](5) NULL,
	[ZipCode] [nvarchar](10) NULL,
	[Country] [nvarchar](50) NULL,
	[Email] [nvarchar](250) NULL,
	[Mobile] [nvarchar](30) NULL,
	[Phone] [nvarchar](20) NULL,
	[PhoneExt] [nvarchar](10) NULL,
	[SecurityQuestion_MTV_ID] [int] NULL,
	[EncryptedAnswer] [nvarchar](250) NULL,
	[TIMEZONE_ID] [int] NULL,
	[IsApproved] [bit] NULL,
	[BlockType_MTV_ID] [int] NULL,
	[TempBlockTillDateTime] [datetime] NULL,
	[PasswordExpiryDateTime] [datetime] NOT NULL,
	[IsAPIUser] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Users] PRIMARY KEY CLUSTERED 
(
	[USER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Audit_Column] ADD  CONSTRAINT [DF_T_Audit_Column_IsPublic]  DEFAULT ((1)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Audit_Column] ADD  CONSTRAINT [DF_T_Audit_Column_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Audit_History] ADD  CONSTRAINT [DF_T_Audit_History_IsAuto]  DEFAULT ((0)) FOR [IsAuto]
GO
ALTER TABLE [dbo].[T_Audit_History] ADD  CONSTRAINT [DF_T_Audit_History_ChangedOn]  DEFAULT (getutcdate()) FOR [ChangedOn]
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
ALTER TABLE [dbo].[T_Department] ADD  CONSTRAINT [DF_T_Department_IsHidden]  DEFAULT ((0)) FOR [IsHidden]
GO
ALTER TABLE [dbo].[T_Department] ADD  CONSTRAINT [DF_T_Department_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Department] ADD  CONSTRAINT [DF_T_Department_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping] ADD  CONSTRAINT [DF_T_Department_Role_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping] ADD  CONSTRAINT [DF_T_Department_Role_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Docs] ADD  CONSTRAINT [DF_T_Docs_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Docs] ADD  CONSTRAINT [DF_T_Docs_CreatedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Errors_List] ADD  CONSTRAINT [DF_T_Errors_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Errors_List] ADD  CONSTRAINT [DF_T_Errors_List_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsOutboundRequired]  DEFAULT ((0)) FOR [IsOutboundRequired]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Metro_Email]  DEFAULT ((0)) FOR [IsNotify_Metro_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Metro_SMS]  DEFAULT ((0)) FOR [IsNotify_Metro_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Client_Email]  DEFAULT ((0)) FOR [IsNotify_Client_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Client_SMS]  DEFAULT ((0)) FOR [IsNotify_Client_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_OED_Email]  DEFAULT ((0)) FOR [IsNotify_OED_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_OED_SMS]  DEFAULT ((0)) FOR [IsNotify_OED_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_CSR_Email]  DEFAULT ((0)) FOR [IsNotify_CSR_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_CSR_SMS]  DEFAULT ((0)) FOR [IsNotify_CSR_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Dispatch_Email]  DEFAULT ((0)) FOR [IsNotify_Dispatch_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Dispatch_SMS]  DEFAULT ((0)) FOR [IsNotify_Dispatch_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Accounting_Email]  DEFAULT ((0)) FOR [IsNotify_Accounting_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Accounting_SMS]  DEFAULT ((0)) FOR [IsNotify_Accounting_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Warehouse_Email]  DEFAULT ((0)) FOR [IsNotify_Warehouse_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Warehouse_SMS]  DEFAULT ((0)) FOR [IsNotify_Warehouse_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_ShipFrom_Email]  DEFAULT ((0)) FOR [IsNotify_ShipFrom_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_ShipFrom_SMS]  DEFAULT ((0)) FOR [IsNotify_ShipFrom_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_ShipTo_Email]  DEFAULT ((0)) FOR [IsNotify_ShipTo_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_ShipTo_SMS]  DEFAULT ((0)) FOR [IsNotify_ShipTo_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_SellTo_Email]  DEFAULT ((0)) FOR [IsNotify_SellTo_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_SellTo_SMS]  DEFAULT ((0)) FOR [IsNotify_SellTo_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_SellToPartner_Email]  DEFAULT ((0)) FOR [IsNotify_SellToPartner_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_SellToPartner_SMS]  DEFAULT ((0)) FOR [IsNotify_SellToPartner_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_BillTo_Email]  DEFAULT ((0)) FOR [IsNotify_BillTo_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_BillTo_SMS]  DEFAULT ((0)) FOR [IsNotify_BillTo_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsRecurring]  DEFAULT ((1)) FOR [IsRecurring]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsPublic]  DEFAULT ((1)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsTrackingAvailable]  DEFAULT ((1)) FOR [IsTrackingAvailable]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsUpdateShippingStatus]  DEFAULT ((1)) FOR [IsUpdateShippingStatus]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
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
ALTER TABLE [dbo].[T_Report_Column_Fields] ADD  CONSTRAINT [DF_T_Report_Column_Fields_Position]  DEFAULT ((0)) FOR [Position]
GO
ALTER TABLE [dbo].[T_Report_Column_Fields] ADD  CONSTRAINT [DF_T_Report_Column_Fields_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Report_Column_Fields] ADD  CONSTRAINT [DF_T_Report_Column_Fields_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Report_List] ADD  CONSTRAINT [DF_T_Reports_List_IsGeneral]  DEFAULT ((0)) FOR [IsGeneral]
GO
ALTER TABLE [dbo].[T_Report_List] ADD  CONSTRAINT [DF_T_Reports_List_IsPublic]  DEFAULT ((0)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Report_List] ADD  CONSTRAINT [DF_T_Reports_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Report_List] ADD  CONSTRAINT [DF_T_Reports_List_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Report_Store_Procedure] ADD  CONSTRAINT [DF_T_Report_Store_Procedure_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Report_Store_Procedure] ADD  CONSTRAINT [DF_T_Report_Store_Procedure_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Report_Store_Procedure_Fields] ADD  CONSTRAINT [DF_T_Report_Store_Procedure_Fields_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Report_Store_Procedure_Fields] ADD  CONSTRAINT [DF_T_Report_Store_Procedure_Fields_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Report_Store_Procedure_Where_Clause] ADD  CONSTRAINT [DF_T_Report_Store_Procedure_Where_Clause_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Report_Store_Procedure_Where_Clause] ADD  CONSTRAINT [DF_T_Report_Store_Procedure_Where_Clause_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
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
ALTER TABLE [dbo].[T_User_Application_Access] ADD  CONSTRAINT [DF_T_User_Application_Access_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_User_Application_Access] ADD  CONSTRAINT [DF_T_User_Application_Access_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_User_Role_Mapping] ADD  CONSTRAINT [DF_T_User_Role_Mapping_IsGroupRoleID]  DEFAULT ((0)) FOR [IsGroupRoleID]
GO
ALTER TABLE [dbo].[T_User_Role_Mapping] ADD  CONSTRAINT [DF_T_User_Role_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_User_Role_Mapping] ADD  CONSTRAINT [DF_T_User_Role_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_TIMEZONE_ID]  DEFAULT ((13)) FOR [TIMEZONE_ID]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsApproved]  DEFAULT ((1)) FOR [IsApproved]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_PasswordExpiry]  DEFAULT (getutcdate()) FOR [PasswordExpiryDateTime]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsAPIUser]  DEFAULT ((0)) FOR [IsAPIUser]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Users] ADD  CONSTRAINT [DF_T_Users_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
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
ALTER TABLE [dbo].[T_Department_Role_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Department_Role_Mapping_T_Department] FOREIGN KEY([D_ID])
REFERENCES [dbo].[T_Department] ([D_ID])
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping] CHECK CONSTRAINT [FK_T_Department_Role_Mapping_T_Department]
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Department_Role_Mapping_T_Roles] FOREIGN KEY([R_ID])
REFERENCES [dbo].[T_Roles] ([R_ID])
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping] CHECK CONSTRAINT [FK_T_Department_Role_Mapping_T_Roles]
GO
ALTER TABLE [dbo].[T_Master_Type_Value]  WITH CHECK ADD  CONSTRAINT [FK_T_Master_Type_Value_T_Master_Type] FOREIGN KEY([MT_ID])
REFERENCES [dbo].[T_Master_Type] ([MT_ID])
GO
ALTER TABLE [dbo].[T_Master_Type_Value] CHECK CONSTRAINT [FK_T_Master_Type_Value_T_Master_Type]
GO
ALTER TABLE [dbo].[T_Page_Rights]  WITH CHECK ADD  CONSTRAINT [FK_T_Page_Rights_T_Page] FOREIGN KEY([P_ID])
REFERENCES [dbo].[T_Page] ([P_ID])
GO
ALTER TABLE [dbo].[T_Page_Rights] CHECK CONSTRAINT [FK_T_Page_Rights_T_Page]
GO
ALTER TABLE [dbo].[T_Report_Column_Fields]  WITH CHECK ADD  CONSTRAINT [FK_T_Report_Column_Fields_T_Reports_List] FOREIGN KEY([RL_ID])
REFERENCES [dbo].[T_Report_List] ([RL_ID])
GO
ALTER TABLE [dbo].[T_Report_Column_Fields] CHECK CONSTRAINT [FK_T_Report_Column_Fields_T_Reports_List]
GO
ALTER TABLE [dbo].[T_Report_List]  WITH CHECK ADD  CONSTRAINT [FK_T_Report_List_T_Report_Store_Procedure] FOREIGN KEY([RSP_ID])
REFERENCES [dbo].[T_Report_Store_Procedure] ([RSP_ID])
GO
ALTER TABLE [dbo].[T_Report_List] CHECK CONSTRAINT [FK_T_Report_List_T_Report_Store_Procedure]
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
/****** Object:  StoredProcedure [dbo].[P_Add_Audit_History]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =====================================================================================================================
-- Author		: abdullah
-- Create date	: 
-- Description	: To Insert Table Columns in Table 
-- =====================================================================================================================

create PROCEDURE [dbo].[P_Add_Audit_History]
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ApplicationPageGroupMapping]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[P_AddOrEdit_ApplicationPageGroupMapping] 2,'148102',2,1,'Ihtisham.Ulhaq'
CREATE PROCEDURE [dbo].[P_AddOrEdit_ApplicationPageGroupMapping]
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
 IF EXISTS(SELECT 1 FROM  [MSPL_DB].[dbo].[T_Application_Page_Group_Mapping] WITH (NOLOCK) WHERE APGM_ID=@APGM_ID)
     BEGIN
	 DECLARE @OldApplication_MTV_CODE nvarchar(20)
	 DECLARE @OldPG_ID int
	 DECLARE @OldIsActive bit

	 SELECT @OldApplication_MTV_CODE = Application_MTV_CODE, @OldPG_ID = PG_ID, @OldIsActive = IsActive FROM [MSPL_DB].[dbo].[T_Application_Page_Group_Mapping] WITH(NOLOCK) WHERE APGM_ID=@APGM_ID

	 UPDATE [MSPL_DB].[dbo].[T_Application_Page_Group_Mapping] SET Application_MTV_CODE=@Application_MTV_CODE,PG_ID=@PG_ID, IsActive=@IsActive, ModifiedBy = @Username , ModifiedOn=GETUTCDATE() WHERE APGM_ID=@APGM_ID

	 IF @OldApplication_MTV_CODE <> @Application_MTV_CODE
		BEGIN	
			exec P_Add_Audit_History 'Application_MTV_CODE' ,'T_Application_Page_Group_Mapping', @APGM_ID, 166111, @APGM_ID, '', '', @OldApplication_MTV_CODE, @Application_MTV_CODE, @OldApplication_MTV_CODE, @Application_MTV_CODE, '', 0, 107100, @UserName
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
		--SELECT @APGM_ID = ISNULL(MAX(APGM_ID),0) + 1 FROM [MSPL_DB].[dbo].[T_Application_Page_Group_Mapping] WITH (NOLOCK) 
		INSERT INTO [MSPL_DB].[dbo].[T_Application_Page_Group_Mapping] (Application_MTV_CODE, PG_ID, IsActive, AddedBy, AddedOn) VALUES (@Application_MTV_CODE, @PG_ID, @IsActive, @Username, GETUTCDATE())
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ApplicationPageMapping]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[P_AddOrEdit_ApplicationPageMapping] 2,'148102',2,1,'Ihtisham.Ulhaq'
CREATE PROCEDURE [dbo].[P_AddOrEdit_ApplicationPageMapping]
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
 IF EXISTS(SELECT 1 FROM  [MSPL_DB].[dbo].[T_Application_Page_Mapping] WITH (NOLOCK) WHERE APM_ID=@APM_ID)
     BEGIN
	 DECLARE @OldApplication_MTV_CODE nvarchar(20)
	 DECLARE @OldP_ID int
	 DECLARE @OldIsActive bit

	 SELECT @OldApplication_MTV_CODE = Application_MTV_CODE, @OldP_ID = P_ID, @OldIsActive = IsActive FROM [MSPL_DB].[dbo].[T_Application_Page_Mapping] WITH(NOLOCK) WHERE APM_ID=@APM_ID

	 UPDATE [MSPL_DB].[dbo].[T_Application_Page_Mapping] SET Application_MTV_CODE=@Application_MTV_CODE,P_ID=@P_ID, IsActive=@IsActive, ModifiedBy = @Username , ModifiedOn=GETUTCDATE() WHERE APM_ID=@APM_ID

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
		--SELECT @APM_ID = ISNULL(MAX(APM_ID),0) + 1 FROM [MSPL_DB].[dbo].[T_Application_Page_Mapping] WITH (NOLOCK) 
		INSERT INTO [MSPL_DB].[dbo].[T_Application_Page_Mapping] (Application_MTV_CODE, P_ID, IsActive, AddedBy, AddedOn) VALUES (@Application_MTV_CODE, @P_ID, @IsActive, @Username, GETUTCDATE())
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_ApplicationSettingSetup]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--		EXEC [P_AddOrEdit_ApplicationSettingSetup]  0, 'S100000', 'PICKUP_ST_CODE', 'Only For testing Purpose', 'RN01', 'RN02', NULL, NULL, NULL,1, 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_ApplicationSettingSetup]
@ASS_ID INT,
@CONFIG_TYPE_MTV_CODE nvarchar(50),
@Description nvarchar(1000),
@REFNO1 nvarchar(50) = NULL,
@REFNO2 nvarchar(50) = NULL,
@REFNO3 nvarchar(50) = NULL,
@REFID1 int = NULL,
@REFID2 int = NULL,
@REFID3 int = NULL,
@IsActive bit = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = null
AS
BEGIN
	DECLARE @maxSortValue INT	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @ASS_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_Application_Setting_Setup] WITH (NOLOCK) WHERE ASS_ID = @ASS_ID)
	BEGIN
	    

		DECLARE @OldCONFIG_TYPE nvarchar(50)
		DECLARE @OldDescription nvarchar(1000)
		DECLARE @OldREFNO1 nvarchar(50)
		DECLARE @OldREFNO2 nvarchar(50)
		DECLARE @OldREFNO3 nvarchar(50)
		DECLARE @OldREFID1 int
		DECLARE @OldREFID2 int
		DECLARE @OldREFID3 int
		DECLARE @OldIsActive bit
		
		SELECT @OldCONFIG_TYPE = CONFIG_TYPE_MTV_CODE , @OldDescription = Description_, @OldREFNO1 = REFNO1, @OldREFNO2 = REFNO2, @OldREFNO3 = REFNO3, @OldREFID1 = REFID1, @OldREFID2 = REFID2, @OldREFID3 = REFID3, @OldIsActive = IsActive  FROM [MSPL_DB].[dbo].[T_Application_Setting_Setup] WITH (NOLOCK) WHERE ASS_ID = @ASS_ID
		
		UPDATE [MSPL_DB].[dbo].[T_Application_Setting_Setup] SET CONFIG_TYPE_MTV_CODE = @CONFIG_TYPE_MTV_CODE, Description_ = @Description, REFNO1 = @REFNO1, REFNO2 = @REFNO2, REFNO3 = @REFNO3, REFID1 = @REFID1, REFID2 = @REFID2, REFID3 = @REFID3, IsActive = @IsActive ,ModifiedOn = GETUTCDATE() WHERE ASS_ID = @ASS_ID

		IF @OldCONFIG_TYPE <> @CONFIG_TYPE_MTV_CODE
		BEGIN
			exec P_Add_Audit_History 'CONFIG_TYPE', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldCONFIG_TYPE, @CONFIG_TYPE_MTV_CODE, @OldCONFIG_TYPE, @CONFIG_TYPE_MTV_CODE, '', 0, 167100, @UserName
		END

		IF @OldDescription <> @Description
		BEGIN
			exec P_Add_Audit_History 'Description_' ,'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldDescription, @Description, @OldDescription, @Description, '', 0, 167100, @UserName
		END	
		
		IF @OldREFNO1 <> @REFNO1
		BEGIN 
			exec P_Add_Audit_History 'REFNO1', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFNO1, @REFNO1, @OldREFNO1, @REFNO1, '', 0, 167100, @UserName
		END

		IF @OldREFNO2 <> @REFNO2
		BEGIN 
			exec P_Add_Audit_History 'REFNO2', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFNO2, @REFNO2, @OldREFNO2, @REFNO2, '', 0, 167100, @UserName
		END

		IF @OldREFNO3 <> @REFNO3
		BEGIN 
			exec P_Add_Audit_History 'REFNO3', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFNO3, @REFNO3, @OldREFNO3, @REFNO3, '', 0, 167100, @UserName
		END

		IF @OldREFID1 <> @REFID1
		BEGIN 
			exec P_Add_Audit_History 'REFID1', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFID1, @REFID1, @OldREFID1, @REFID1, '', 0, 167100, @UserName
		END

		IF @OldREFID2 <> @REFID2
		BEGIN 
			exec P_Add_Audit_History 'REFID2', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFID2, @REFID2, @OldREFID2, @REFID2, '', 0, 167100, @UserName
		END

		IF @OldREFID3 <> @REFID3
		BEGIN 
			exec P_Add_Audit_History 'REFID3', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldREFID3, @REFID3, @OldREFID3, @REFID3, '', 0, 167100, @UserName
		END

		IF @OldIsActive <> @IsActive
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldIsActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @IsActive = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive', 'T_Application_Setting_Setup', @ASS_ID, 166145, @ASS_ID, '', '', @OldIsActive, @IsActive, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Application Setting Setup Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Application Setting Setup does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @CONFIG_TYPE_MTV_CODE <> '' 
	BEGIN
		INSERT INTO [MSPL_DB].[dbo].[T_Application_Setting_Setup] (CONFIG_TYPE_MTV_CODE, Description_, REFNO1, REFNO2, REFNO3, REFID1, REFID2, REFID3, IsActive, AddedBy, AddedOn) VALUES (@CONFIG_TYPE_MTV_CODE, @Description, @REFNO1, @REFNO2, @REFNO3, @REFID1 ,@REFID2, @REFID3, @IsActive, @Username, GETUTCDATE())
		SET @Return_Text = 'Application Setting Setup Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE 
	BEGIN
		SET @Return_Text = 'Application Setting Setup does not exist!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Chats]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--							EXEC [P_AddOrEdit_Chats] 0,2,1,'hIasdasd','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Chats]
@C_ID INT = NULL,
@CR_ID INT,
@CRUM_ID INT,
@Message nvarchar(MAX),
@Username nvarchar(150),
@Attachment_Path nvarchar(500) = null,
@Parent_C_ID INT = 0,
@Parent_C_ID_Image nvarchar(150) = null,
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @C_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_Chats] WITH (NOLOCK) WHERE C_ID = @C_ID)
	BEGIN
	    
		DECLARE @OldMessage nvarchar(MAX)
		
		SELECT @OldMessage = [Message] FROM [MSPL_DB].[dbo].[T_Chats] WITH (NOLOCK) WHERE C_ID = @C_ID
		
		UPDATE [MSPL_DB].[dbo].[T_Chats] SET [Message] = @Message, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE C_ID = @C_ID
		
		IF @OldMessage <> @Message
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'Message' ,'T_Chats', @CRUM_ID, 166113, @C_ID, '', '', @OldMessage, @Message, @OldMessage, @Message, '', 0, 167100, @Username
		END	

		SET @Return_Text = 'Message Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Message does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @CRUM_ID > 0 AND @Message <> '' BEGIN
		DECLARE @Recieve_UserName NVARCHAR(150)
		DECLARE @Room_Type NVARCHAR(20)
		
		INSERT INTO [MSPL_DB].[dbo].[T_Chats] (Parent_C_ID, CRUM_ID, Send_UserName, Parent_C_ID_Image, [Message], Attachment_Path, IsActive, AddedBy, AddedOn) 
		VALUES (@Parent_C_ID, @CRUM_ID, @Username, @Parent_C_ID_Image, @Message, @Attachment_Path, 1, @Username, GETUTCDATE())
		SET @C_ID = SCOPE_IDENTITY()

		SELECT @Room_Type = Room_Type_MTV_CODE FROM [dbo].[T_Chat_Room] WITH (NOLOCK) WHERE IsActive = 1 AND CR_ID = @CR_ID
		IF @Room_Type = 'PRIVATE' BEGIN 
			SELECT @Recieve_UserName = UserName FROM [dbo].[T_Chat_Room_User_Mapping] WITH (NOLOCK) WHERE CRUM_ID = @CRUM_ID
			INSERT INTO [MSPL_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) 
			VALUES (@C_ID, @Recieve_UserName, 0, 0, 0, NULL, 1, @Username, GETUTCDATE())
		END
		ELSE BEGIN 
			INSERT INTO [MSPL_DB].[dbo].[T_Chats_User_Mapping] (C_ID, Recieve_UserName, IsRead, IsBookmark, IsFlag, Read_At, IsActive, AddedBy, AddedOn) 
			SELECT C_ID = @C_ID, Recieve_UserName = UserName, IsRead = 0, IsBookmark = 0, IsFlag = 0, Read_At = NULL, IsActive = 1, AddedBy = @Username, AddedOn = GETUTCDATE()
			FROM [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK) INNER JOIN [dbo].[T_Chat_Room] cr WITH (NOLOCK) ON crum.CR_ID = cr.CR_ID 
			WHERE crum.CR_ID = @CR_ID AND UserName <> @Username
		END
		
		SET @Return_Text = 'Message Sent Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Message Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Department]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--							EXEC [P_AddOrEdit_Department] 1,'All 1',1,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Department]
@D_ID INT = NULL,
@DepartmentName nvarchar(150),
@IsHidden BIT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @D_ID > 0 
BEGIN
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_Department] WITH (NOLOCK) WHERE D_ID = @D_ID)
	BEGIN
	    
		DECLARE @OldDepartmentName nvarchar(150)
		DECLARE @OldIsHide BIT
		DECLARE @OldActive BIT
		
		SELECT @OldDepartmentName = DepartmentName, @OldIsHide = IsHidden, @OldActive = IsActive FROM [MSPL_DB].[dbo].[T_Department] WITH (NOLOCK) WHERE D_ID = @D_ID
		
		UPDATE [MSPL_DB].[dbo].[T_Department] SET DepartmentName = @DepartmentName, IsHidden = @IsHidden, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE D_ID = @D_ID
		
		IF @OldDepartmentName <> @DepartmentName
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'DepartmentName' ,'T_Department', @D_ID, 166113, @D_ID, '', '', @OldDepartmentName, @DepartmentName, @OldDepartmentName, @DepartmentName, '', 0, 167100, @Username
		END

		IF @OldIsHide <> @IsHidden
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsHide = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsHidden = 1 then 'Yes' else 'No' end)
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'IsHidden' ,'T_Department', @D_ID, 166113, @D_ID, '', '', @OldIsHide, @IsHidden, @OldIsHideText, @IsHideText, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Department', @D_ID, 166113, @D_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END		

		SET @Return_Text = 'Department Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Department does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @DepartmentName <> '' BEGIN
		DECLARE @maxSortValue INT
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [MSPL_DB].[dbo].[T_Department] WITH (NOLOCK)
		INSERT INTO [MSPL_DB].[dbo].[T_Department] (DepartmentName, Sort_, IsHidden, IsActive, AddedBy, AddedOn) VALUES (@DepartmentName, @maxSortValue, @IsHidden, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Department Added Successfully!'
		set @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Department Not Found!'
		set @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Department_Role_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--						EXEC P_AddOrEdit_Department_Role_Mapping 'Test','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Department_Role_Mapping]
@DepartmentRoleMappingID INT = NULL,
@RoleID INT,
@DepartmentID INT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN	
	Declare @Return_Code BIT  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @DepartmentRoleMappingID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].T_Department_Role_Mapping WHERE DRM_ID = @DepartmentRoleMappingID)
	BEGIN
	    
		DECLARE @OldR_ID INT
		DECLARE @OldD_ID INT
		DECLARE @OldActive BIT

		SELECT @OldR_ID = R_ID, @OldD_ID = @DepartmentID, @OldActive = IsActive FROM [MSPL_DB].[dbo].T_Department_Role_Mapping WHERE DRM_ID = @DepartmentRoleMappingID
		
		UPDATE [MSPL_DB].[dbo].T_Department_Role_Mapping SET R_ID = @RoleID, D_ID = @DepartmentID, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE DRM_ID = @DepartmentRoleMappingID
		
		IF @OldR_ID <> @RoleID
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'R_ID' ,'T_Department_Role_Mapping', @DepartmentID, 166116, @DepartmentRoleMappingID, '', '', @OldR_ID, @RoleID, @OldR_ID, @RoleID, '', 0, 167100, @UserName
		END

		IF @OldD_ID <> @DepartmentID
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'D_ID' ,'T_Department_Role_Mapping', @DepartmentID, 166116, @DepartmentRoleMappingID, '', '', @OldD_ID, @DepartmentID, @OldD_ID, @DepartmentID, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Department_Role_Mapping', @DepartmentID, 166116, @DepartmentRoleMappingID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Department Role Mapping Name Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Department Role Mapping does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @RoleID > 0 AND @DepartmentID > 0 BEGIN
		INSERT INTO [MSPL_DB].[dbo].T_Department_Role_Mapping (R_ID, D_ID, IsActive, AddedBy, AddedOn) VALUES (@RoleID, @DepartmentID, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Department Role Mapping Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Department Role Mapping Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_MasterTypeValue]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--							EXEC [P_AddOrEdit_MasterTypeValue] 0,174,'PRIMARY_DOMAIN','Primary Domain',0,1,'ABDULLAH.ARSHAD',''
CREATE PROC [dbo].[P_AddOrEdit_MasterTypeValue]
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

	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MTV_ID = @MTV_ID)
	BEGIN
	    
		DECLARE @OldMTV_Code nvarchar(20)
		DECLARE @OldMasterTypeValueName nvarchar(50)
		DECLARE @OldSub_MTV_ID int
		DECLARE @OldActive BIT

		SELECT @OldMTV_Code = MTV_CODE, @OldMasterTypeValueName = Name, @OldSub_MTV_ID = Sub_MTV_ID ,@OldActive = IsActive FROM [MSPL_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MTV_ID = @MTV_ID
		
		UPDATE [MSPL_DB].dbo.T_Master_Type_Value SET MTV_Code = @MTV_CODE, Name = @MasterTypeValueName, Sub_MTV_ID = @Sub_MTV_ID ,IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE MTV_ID = @MTV_ID
		
		IF @OldMTV_Code <> @MTV_CODE
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'MTV_Code' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldMTV_Code, @MTV_CODE, @OldMTV_Code, @MTV_CODE, '', 0, 167100, @UserName
		END

		IF @OldMasterTypeValueName <> @MasterTypeValueName
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'Name' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldMasterTypeValueName, @MasterTypeValueName, @OldMasterTypeValueName, @MasterTypeValueName, '', 0, 167100, @UserName
		END

		IF @OldSub_MTV_ID <> @Sub_MTV_ID
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'Sub_MTV_ID' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldSub_MTV_ID, @Sub_MTV_ID, @OldSub_MTV_ID, @Sub_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Master_Type_Value', @MT_ID, 166112, @MTV_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
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
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [MSPL_DB].[dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = @MT_ID
		SELECT @MTV_ID = (CASE WHEN ISNULL(MAX(MTV_ID),0) = 0 THEN cast((cast(@MT_ID as nvarchar(max)) + '100') as int) ELSE ISNULL(MAX(MTV_ID),0) + 1 END) FROM [MSPL_DB].[dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = @MT_ID
		IF @MTV_CODE = '' BEGIN SET @MTV_CODE = @MTV_ID END
		INSERT INTO [MSPL_DB].[dbo].[T_Master_Type_Value] (MTV_ID, MT_ID, MTV_CODE, Name, Sort_, Sub_MTV_ID ,IsActive, AddedBy, AddedOn) VALUES (@MTV_ID, @MT_ID, @MTV_CODE, @MasterTypeValueName, @maxSortValue, @Sub_MTV_ID ,@Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Master Type Value Added Successfully!'
		set @Return_Code = 1
	END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Page]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--						EXEC P_AddOrEdit_Page 0,10,'Events Setup','/Settings/EventsSetup',148100,0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Page]
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
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].T_Page WHERE P_ID = @P_ID)
	BEGIN
	    
		DECLARE @OldPageName nvarchar(150)
		DECLARE @OldPageUrl nvarchar(250)
		DECLARE @OldApplication_MTV_ID INT
		DECLARE @OldIsHide BIT
		DECLARE @OldActive BIT

		SELECT @OldPageName = PageName, @OldIsHide = IsHide, @OldActive = IsActive FROM [MSPL_DB].[dbo].T_Page WHERE P_ID = @P_ID
		
		UPDATE [MSPL_DB].[dbo].T_Page SET PageName = @PageName, PageUrl = @PageUrl, Application_MTV_ID = @Application_MTV_ID, IsHide = @IsHide, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE P_ID = @P_ID
		
		IF @OldPageName <> @PageName
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'PageName' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldPageName, @PageName, @OldPageName, @PageName, '', 0, 167100, @UserName
		END

		IF @OldPageUrl <> @PageUrl
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'PageUrl' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldPageUrl, @PageUrl, @OldPageUrl, @PageUrl, '', 0, 167100, @UserName
		END

		IF @OldApplication_MTV_ID <> @Application_MTV_ID
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'Application_MTV_ID' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldApplication_MTV_ID, @Application_MTV_ID, @OldApplication_MTV_ID, @Application_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldIsHide <> @IsHide
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsHide = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsHide = 1 then 'Yes' else 'No' end)
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'IsHide' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldIsHide, @IsHide, @OldIsHideText, @IsHideText, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Page', @PG_ID, 166114, @P_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
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
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [MSPL_DB].[dbo].T_Page WITH (NOLOCK) WHERE PG_ID = @PG_ID
		SELECT @P_ID = (CASE WHEN ISNULL(MAX(P_ID),0) = 0 THEN @PG_ID * 100 ELSE ISNULL(MAX(P_ID),0) + 1 END) FROM [MSPL_DB].[dbo].T_Page WITH (NOLOCK) WHERE PG_ID = @PG_ID
		INSERT INTO [MSPL_DB].[dbo].T_Page (P_ID, PG_ID, PageName, PageURL, Application_MTV_ID, Sort_, IsHide, IsActive, AddedBy, AddedOn) VALUES (@P_ID, @PG_ID, @PageName, @PageUrl, @Application_MTV_ID, @maxSortValue, @IsHide, @Active, @Username, GETUTCDATE())
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Page_Rights]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--						EXEC [P_AddOrEdit_Page_Rights] 4,'Test','sss','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Page_Rights]
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
	IF EXISTS (SELECT 1 FROM MSPL_DB.dbo.T_Page_Rights WITH (NOLOCK) WHERE PR_ID = @PR_ID)
	BEGIN
	    
		DECLARE @OldPR_CODE nvarchar(50)
		DECLARE @OldPageRightName nvarchar(50)
		DECLARE @OldPageRightType nvarchar(20)
		DECLARE @OldIsHide BIT
		DECLARE @OldActive BIT
		
		SELECT @OldPR_CODE = PR_CODE, @OldPageRightName = PageRightName, @OldPageRightType = PageRightType_MTV_CODE, @OldIsHide = IsHide, @OldActive = IsActive FROM MSPL_DB.dbo.T_Page_Rights WITH (NOLOCK) WHERE PR_ID = @PR_ID
		
		UPDATE MSPL_DB.dbo.T_Page_Rights SET PR_CODE = @PR_CODE, PageRightName = @PageRightName, PageRightType_MTV_CODE = @PageRightType, IsHide = @IsHide, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE PR_ID = @PR_ID
		
		IF @OldPR_CODE <> @PR_CODE
		BEGIN	
			exec P_Add_Audit_History 'PR_CODE' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldPR_CODE, @PR_CODE, @OldPR_CODE, @PR_CODE, '', 0, 167100, @UserName
		END

		IF @OldPageRightName <> @PageRightName
		BEGIN	
			exec P_Add_Audit_History 'PageRightName' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldPageRightName, @PageRightName, @OldPageRightName, @PageRightName, '', 0, 167100, @UserName
		END

		IF @OldPageRightType <> @PageRightType
		BEGIN	
			exec P_Add_Audit_History 'PageRightType_MTV_CODE' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldPageRightType, @PageRightType, @OldPageRightType, @PageRightType, '', 0, 167100, @UserName
		END

		IF @OldIsHide <> @IsHide
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsHide = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsHide = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsHide' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldIsHide, @IsHide, @OldIsHideText, @IsHideText, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_Page_Rights', @P_ID, 166101, @PR_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
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
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM MSPL_DB.dbo.T_Page_Rights WITH (NOLOCK) WHERE P_ID = @P_ID
		SELECT @PR_ID = (CASE WHEN ISNULL(MAX(PR_ID),0) = 0 THEN cast((cast(@P_ID as nvarchar(max)) + '100') as int) ELSE ISNULL(MAX(PR_ID),0) + 1 END) FROM MSPL_DB.dbo.T_Page_Rights WITH (NOLOCK) WHERE P_ID = @P_ID
		INSERT INTO MSPL_DB.dbo.T_Page_Rights (PR_ID, P_ID, PR_CODE, PageRightName, PageRightType_MTV_CODE, Sort_, IsHide, IsActive, AddedBy, AddedOn) VALUES (@PR_ID, @P_ID, @PR_CODE, @PageRightName, @PageRightType, @maxSortValue, @IsHide, @Active, @Username, GETUTCDATE())
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_PageGroup]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_PageGroup 10,'Setting',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_PageGroup]
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
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_Page_Group] WITH (NOLOCK) WHERE PG_ID = @PG_ID)
	BEGIN
	    
		DECLARE @OldPageGroupName nvarchar(150)
		DECLARE @OldIsHide BIT
		DECLARE @OldActive BIT
		
		SELECT @OldPageGroupName = PageGroupName, @OldIsHide = IsHide, @OldActive = IsActive FROM [MSPL_DB].[dbo].T_Page_Group WITH (NOLOCK) WHERE PG_ID = @PG_ID
		
		UPDATE [MSPL_DB].[dbo].T_Page_Group SET PageGroupName = @PageGroupName, IsHide = @IsHide, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE PG_ID = @PG_ID

		IF @OldPageGroupName <> @PageGroupName
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'PageGroupName' ,'T_Page_Group', @PG_ID, 166100, @PG_ID, '', '', @OldPageGroupName, @PageGroupName, @OldPageGroupName, @PageGroupName, '', 0, 167100, @UserName
		END

		IF @OldIsHide <> @IsHide
		BEGIN
			Declare @OldIsHideText nvarchar(10) = (case when @OldIsHide = 1 then 'Yes' else 'No' end)
			Declare @IsHideText nvarchar(10) = (case when @IsHide = 1 then 'Yes' else 'No' end)
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'IsHide' ,'T_Page_Group', @PG_ID, 166100, @PG_ID, '', '', @OldIsHide, @IsHide, @OldIsHideText, @IsHideText, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Page_Group', @PG_ID, 166100, @PG_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
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
		INSERT INTO [MSPL_DB].[dbo].T_Page_Group (PG_ID, PageGroupName, Sort_, IsHide, IsActive, AddedBy, AddedOn) VALUES (@PG_ID, @PageGroupName, @maxSortValue, @IsHide, @Active, @Username, GETUTCDATE())
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Role_Group]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_Role_Group 0,'Test',1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Role_Group]
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
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].T_Role_Group WITH (NOLOCK) WHERE RG_ID = @RoleGroupID)
	BEGIN
	    
		DECLARE @OldRoleGroupName NVARCHAR(50)
		DECLARE @OldActive BIT
		
		SELECT @OldRoleGroupName = RoleGroupName, @OldActive = IsActive FROM [MSPL_DB].[dbo].T_Role_Group WITH (NOLOCK) WHERE RG_ID = @RoleGroupID
		
		UPDATE [MSPL_DB].[dbo].T_Role_Group SET RoleGroupName = @RoleGroupName, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE RG_ID = @RoleGroupID
		
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
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [MSPL_DB].[dbo].T_Role_Group WITH (NOLOCK)
		SELECT @RoleGroupID = ISNULL(MAX(RG_ID),0) + 1 FROM [MSPL_DB].[dbo].T_Role_Group WITH (NOLOCK)
		INSERT INTO [MSPL_DB].[dbo].T_Role_Group (RG_ID, RoleGroupName, Sort_, IsActive, AddedBy, AddedOn) VALUES (@RoleGroupID,@RoleGroupName, @maxSortValue, @Active, @Username, GETUTCDATE())
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Role_Group_Mapping]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--						EXEC P_AddOrEdit_Role_Group_Mapping 'Test','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Role_Group_Mapping]
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
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].T_Role_Group_Mapping WITH (NOLOCK) WHERE RGM_ID = @RoleGroupMappingID)
	BEGIN
	    
		DECLARE @OldR_ID INT
		DECLARE @OldRG_ID INT
		DECLARE @OldActive BIT

		SELECT @OldR_ID = R_ID, @OldRG_ID = RG_ID, @OldActive = IsActive FROM [MSPL_DB].[dbo].T_Role_Group_Mapping WITH (NOLOCK) WHERE RGM_ID = @RoleGroupMappingID
				
		UPDATE [MSPL_DB].[dbo].T_Role_Group_Mapping SET R_ID = @RoleID, RG_ID = @RoleGroupID, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE RGM_ID = @RoleGroupMappingID

		IF @OldR_ID <> @RoleID
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'R_ID' ,'T_Role_Group_Mapping', @RoleID, 166115, @RoleGroupID, @RoleGroupMappingID, '', @OldR_ID, @RoleID, @OldR_ID, @RoleID, '', 0, 167100, @UserName
		END

		IF @OldRG_ID <> @RoleGroupID
		BEGIN	
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'RG_ID' ,'T_Role_Group_Mapping', @RoleID, 166115, @RoleGroupID, @RoleGroupMappingID, '', @OldRG_ID, @RoleGroupID, @OldRG_ID, @RoleGroupID, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec [MSPL_DB].[dbo].P_Add_Audit_History 'IsActive' ,'T_Role_Group_Mapping', @RoleID, 166115, @RoleGroupID, @RoleGroupMappingID, '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
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
		INSERT INTO [MSPL_DB].[dbo].T_Role_Group_Mapping (R_ID, RG_ID, IsActive, AddedBy, AddedOn) VALUES (@RoleID, @RoleGroupID, @Active, @Username, GETUTCDATE())
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_RolePageRight_Json]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--						EXEC [P_AddOrEdit_RolePageRight_Json] 4,'Test','sss','HAMMAS.KHAN'
create PROC [dbo].[P_AddOrEdit_RolePageRight_Json]
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

	DELETE MSPL_DB.dbo.T_Role_Page_Rights_Mapping WHERE R_ID = (SELECT DISTINCT R_ID FROM #RolePageRight_Temp)
		
	INSERT INTO MSPL_DB.dbo.T_Role_Page_Rights_Mapping (R_ID, PR_ID, IsRightActive, IsActive, AddedBy, AddedOn)		
	SELECT R_ID, PR_ID, IsRightActive, Active, @Username, GETUTCDATE() FROM #RolePageRight_Temp
	WHERE PR_ID NOT IN (SELECT RPR.PR_ID 
	FROM T_Role_Page_Rights_Mapping rprm WITH (NOLOCK) 
	INNER JOIN #RolePageRight_Temp rpr on  rpr.R_ID = rprm.R_ID and rpr.PR_ID = rprm.PR_ID)
		
	SET @Return_Text = 'Role Page Rights Added Successfully!'
	SET @Return_Code = 1	

	SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Roles]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--						EXEC P_AddOrEdit_Roles 'Test','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Roles]
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
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].T_Roles WHERE R_ID = @RoleID)
	BEGIN
	    
		SELECT @OldRoleName = RoleName, @OldActive = IsActive FROM [MSPL_DB].[dbo].T_Roles WHERE R_ID = @RoleID
		
		UPDATE [MSPL_DB].[dbo].T_Roles SET RoleName = @RoleName, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE R_ID = @RoleID
		
		IF @OldRoleName <> @RoleName
		BEGIN	
			exec P_Add_Audit_History 'RoleName' ,'T_Roles', @RoleID, 166103, '', '', '', @OldRoleName, @RoleName, @OldRoleName, @RoleName, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_Roles', @RoleID, 166103, '', '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
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
		SELECT @maxSortValue = ISNULL(MAX(Sort_),0) + 1 FROM [MSPL_DB].[dbo].T_Roles WITH (NOLOCK)
		INSERT INTO [MSPL_DB].[dbo].T_Roles (RoleName, Sort_, IsActive, AddedBy, AddedOn) VALUES (@RoleName, @maxSortValue, @Active, @Username, GETUTCDATE())
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
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TaskAssignedToMap]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping]  
--EXEC P_AddOrEdit_TaskAssignedToMap 0,2 ,'TAIMOOR.ALI,SAAD.QADIR,BABAR.ALI',0,'IHTISHAM.ULHAQ'
CREATE PROC [dbo].[P_AddOrEdit_TaskAssignedToMap]
@TATM_ID INT = NULL,
@TD_ID INT,
@AssignedTo NVARCHAR(max),
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

DECLARE @AssignedToTable TABLE (ID INT IDENTITY(1,1), AssignedTo NVARCHAR(100))
INSERT INTO @AssignedToTable
SELECT value FROM STRING_SPLIT(@AssignedTo, ',')

 
DECLARE @AddEditUpdateAssigneToTable TABLE (
    AssigneID INT IDENTITY(1,1),
    TempTATMID INT,
    TempTDID INT,
    TempAssigneTo NVARCHAR(100),
    TempActive BIT,
    EntreeType NVARCHAR(50)
)


 
INSERT INTO @AddEditUpdateAssigneToTable (TempTATMID, TempTDID, TempAssigneTo, TempActive, EntreeType)
SELECT tam.TATM_ID, tam.TD_ID, tam.AssignedTo, 1, 'update' AS EntreeType 
FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tam 
INNER JOIN @AssignedToTable a ON tam.AssignedTo = a.AssignedTo
WHERE tam.TD_ID = @TD_ID AND tam.IsActive = 0 
union all
SELECT tam.TATM_ID, tam.TD_ID, tam.AssignedTo, 0, 'remove'FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tam
WHERE tam.TD_ID=@TD_ID  and tam.IsActive=1 and  tam.AssignedTo NOT IN (SELECT AssignedTo FROM @AssignedToTable)
union all
select null,@TD_ID, a.AssignedTo,1,'add' from @AssignedToTable  a
where a.AssignedTo not in(select ta.AssignedTo from [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] ta where ta.TD_ID=@TD_ID )

 
if exists (select 1 from @AddEditUpdateAssigneToTable WHERE EntreeType = 'add' )
begin
insert into [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] (TD_ID,AssignedTo,IsActive,AddedBy,AddedOn)
select an.TempTDID,TempAssigneTo,TempActive,@Username,GETUTCDATE() from @AddEditUpdateAssigneToTable an WHERE an.EntreeType = 'add'

set @Return_Text= CONCAT(@Return_Text, '_Add')
set @Return_Code=1
end



if exists (select 1  from @AddEditUpdateAssigneToTable WHERE EntreeType in( 'remove','update') ) 
begin


UPDATE ar
SET  ar.IsActive = RemoveData.TempActive,
    ar.ModifiedBy = @Username, 
    ar.ModifiedOn = GETUTCDATE()
FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] AS ar
INNER JOIN (
    SELECT TempTATMID, TempActive
    FROM @AddEditUpdateAssigneToTable
    WHERE EntreeType in('remove','update')
) AS RemoveData ON ar.TATM_ID = RemoveData.TempTATMID

set @Return_Text=CONCAT(@Return_Text,'_Udated')
set @Return_Code=1
end

 
  SELECT @Return_Text Return_Text, @Return_Code Return_Code
END

 

 
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TaskComments]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_TaskComments 'Test','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_TaskComments]
@TC_ID INT = NULL,
@TD_ID INT,
@CommentText NVARCHAR(MAX),
@Application_URL int,
@Task_Start_Date DATE,
@Task_End_Date DATE,
@Priority_MTV_ID INT,
@Status_MTV_ID INT,
@BUILDCODE NVARCHAR(50),
@TaskCategory_MTV_ID INT,
@Review_Date DATE,
@ETA_Date DATE,
@IsPrivate BIT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
       
    Declare @Priority_MTV_Name nvarchar(150)
	Declare @Status_MTV_Name nvarchar(150)
	Declare @BUILDName NVARCHAR(250)
	Declare @TaskCategory_MTV_Name nvarchar(150)
  
	DECLARE @OldTD_ID INT
	DECLARE @OldCommentText NVARCHAR(MAX)
	DECLARE @OldApplication_URL int
	DECLARE @OldTask_Start_Date DATE
	DECLARE @OldTask_End_Date DATE
	DECLARE @OldPriority_MTV_ID INT
	DECLARE @OldPriority_MTV_Name nvarchar(150)
	DECLARE @OldStatus_MTV_ID INT
	DECLARE @OldStatus_MTV_Name nvarchar(150)
	DECLARE @OldBUILDCODE nvarchar(50)
	DECLARE @OldBUILDName nvarchar(250)
	DECLARE @OldTaskCategory_MTV_ID int
	DECLARE @OldTaskCategory_MTV_Name nvarchar(150)
	DECLARE @OldReview_Date DATE
	DECLARE @OldETA_Date DATE
	DECLARE @OldIsPrivate BIT
	DECLARE @OldActive BIT
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TC_ID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] WHERE TC_ID = @TC_ID)
	BEGIN
	    
		SELECT @OldTD_ID = TD_ID, @OldCommentText = CommentText, @Application_URL = Application_URL, @OldTask_Start_Date = Task_Start_Date, @OldTask_End_Date = Task_End_Date, @OldPriority_MTV_ID = Priority_MTV_ID, @OldStatus_MTV_ID = Status_MTV_ID, @OldBUILDCODE = BUILDCODE, @OldTaskCategory_MTV_ID = TaskCategory_MTV_ID
		, @OldReview_Date = Review_Date, @OldETA_Date = ETA_Date, @OldIsPrivate = IsPrivate, @OldActive = IsActive FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] WHERE TC_ID = @TC_ID
		
		UPDATE [MSPL_DB].[dbo].[T_TMS_TaskComments] 
		SET TD_ID = @TD_ID, CommentText = @CommentText, Application_URL = @Application_URL, Task_Start_Date = @Task_Start_Date, Task_End_Date = @Task_End_Date, Priority_MTV_ID = @Priority_MTV_ID, Status_MTV_ID = @Status_MTV_ID, BUILDCODE = @BUILDCODE
		,TaskCategory_MTV_ID = @TaskCategory_MTV_ID ,Review_Date = @Review_Date ,ETA_Date = @ETA_Date , IsPrivate = @IsPrivate, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE()
		WHERE TC_ID = @TC_ID
		
		IF @OldTD_ID <> @TD_ID
		BEGIN	
			exec P_Add_Audit_History 'TD_ID' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldTD_ID, @TD_ID, @OldTD_ID, @TD_ID, '', 0, 167100, @UserName
		END

		IF @OldCommentText <> @CommentText
		BEGIN	
			exec P_Add_Audit_History 'CommentText' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldCommentText, @CommentText, @OldCommentText, @CommentText, '', 0, 167100, @UserName
		END
		
		IF @OldApplication_URL <> @Application_URL
		BEGIN	
			exec P_Add_Audit_History 'Application_URL' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldApplication_URL, @Application_URL, @Application_URL, @Application_URL, '', 0, 167100, @UserName
		END

		IF @OldTask_Start_Date <> @Task_Start_Date
		BEGIN	
			exec P_Add_Audit_History 'Task_Start_Date' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldTask_Start_Date, @Task_Start_Date, @OldTask_Start_Date, @Task_Start_Date, '', 0, 167100, @UserName
		END

		IF @OldTask_End_Date <> @Task_End_Date
		BEGIN	
			exec P_Add_Audit_History 'Task_End_Date' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldTask_End_Date, @Task_End_Date, @OldTask_End_Date, @Task_End_Date, '', 0, 167100, @UserName
		END

		IF @OldTaskCategory_MTV_ID <> @TaskCategory_MTV_ID
		BEGIN
			Select @OldTaskCategory_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldTaskCategory_MTV_ID), @TaskCategory_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@TaskCategory_MTV_ID)
			exec P_Add_Audit_History 'TaskCategory_MTV_ID' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldTaskCategory_MTV_ID, @TaskCategory_MTV_ID, @OldTaskCategory_MTV_Name, @TaskCategory_MTV_Name, '', 0, 167100, @UserName
		END

		IF @OldPriority_MTV_ID <> @Priority_MTV_ID
		BEGIN
			Select @OldPriority_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldPriority_MTV_ID), @Priority_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@Priority_MTV_ID)
			exec P_Add_Audit_History 'Priority_MTV_ID' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldPriority_MTV_ID, @Priority_MTV_ID, @OldPriority_MTV_Name, @Priority_MTV_Name, '', 0, 167100, @UserName
		END

		IF @OldStatus_MTV_ID <> @Status_MTV_ID
		BEGIN	
			Select @OldStatus_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldStatus_MTV_ID), @Status_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@Status_MTV_ID)
			exec P_Add_Audit_History 'Status_MTV_ID' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldStatus_MTV_ID, @Status_MTV_ID, @OldStatus_MTV_ID, @Status_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldBUILDCODE <> @BUILDCODE
		BEGIN	
			Select @OldBUILDName = @OldBUILDCODE, @BUILDName = @BUILDCODE  -- Need to Workin On
			exec P_Add_Audit_History 'BUILDCODE' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldBUILDCODE, @BUILDCODE, @OldBUILDName, @BUILDName, '', 0, 167100, @UserName
		END

		IF @OldReview_Date <> @Review_Date
		BEGIN	
			exec P_Add_Audit_History 'Review_Date' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldReview_Date, @Review_Date, @OldReview_Date, @Review_Date, '', 0, 167100, @UserName
		END

		IF @OldETA_Date <> @ETA_Date
		BEGIN	
			exec P_Add_Audit_History 'ETA_Date' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldETA_Date, @ETA_Date, @OldETA_Date, @ETA_Date, '', 0, 167100, @UserName
		END

		IF @OldIsPrivate <> @IsPrivate
		BEGIN
			Declare @OldIsPrivateText nvarchar(10) = (case when @OldIsPrivate = 1 then 'Yes' else 'No' end)
			Declare @IsPrivateText nvarchar(10) = (case when @IsPrivate = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsPrivate' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldIsPrivate, @IsPrivate, @OldIsPrivateText, @IsPrivateText, '', 0, 167100, @UserName
		END	



		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_TMS_TaskComments', @TC_ID, 166144, @TC_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Task Assigned Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Assigned does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @TD_ID > 0 AND @CommentText <> '' BEGIN
		INSERT INTO [MSPL_DB].[dbo].[T_TMS_TaskComments] (TD_ID, CommentText,Application_URL, Task_Start_Date, Task_End_Date, Priority_MTV_ID, Status_MTV_ID, BUILDCODE, TaskCategory_MTV_ID, Review_Date, ETA_Date, IsPrivate, IsActive, AddedBy, AddedOn) 
		VALUES (@TD_ID, @CommentText,@Application_URL, @Task_Start_Date, @Task_End_Date, @Priority_MTV_ID, @Status_MTV_ID, @BUILDCODE, @TaskCategory_MTV_ID, @Review_Date, @ETA_Date, @IsPrivate, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Task Comment Added Successfully!'
		SET @Return_Code = 1
	END
	ELSE BEGIN
		SET @Return_Text = 'Task Comment Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TaskDetail]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_TaskDetail 'Test','HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_TaskDetail]
@TD_ID INT = NULL,
@T_ID INT,
@Task_Item NVARCHAR(500),
@Task_Item_Detail NVARCHAR(MAX),
@Application_URL int,
@Task_Start_Date DATE,
@Task_End_Date DATE,
@Priority_MTV_ID INT,
@Status_MTV_ID INT,
@BUILDCODE NVARCHAR(50),
@TaskCategory_MTV_ID INT,
@Review_Date DATE,
@ETA_Date DATE,
@LeadAssignTo nvarchar(150),
@IsPrivate BIT,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN

	Declare @Priority_MTV_Name nvarchar(150)
	Declare @Status_MTV_Name nvarchar(150)
	Declare @BuildName NVARCHAR(250)
	Declare @TaskCategory_MTV_Name nvarchar(150)

	DECLARE @OldT_ID INT
	DECLARE @TD_IDReturn INT
	DECLARE @OldTask_Item NVARCHAR(500)
	DECLARE @OldTask_Item_Detail NVARCHAR(MAX)
	DECLARE @OldApplication_URL int
	DECLARE @OldTask_Start_Date DATE
	DECLARE @OldTask_End_Date DATE
	DECLARE @OldPriority_MTV_ID INT
	DECLARE @OldPriority_MTV_Name nvarchar(150)
	DECLARE @OldStatus_MTV_ID INT
	DECLARE @OldStatus_MTV_Name nvarchar(150)
	DECLARE @OldBUILDCODE nvarchar(50)
	DECLARE @OldBuildName nvarchar(250)
	DECLARE @OldTaskCategory_MTV_ID int
	DECLARE @OldTaskCategory_MTV_Name nvarchar(150)
	DECLARE @OldReview_Date DATE
	DECLARE @OldETA_Date DATE
	DECLARE @OldLeadAssignTo nvarchar(150)
	DECLARE @OldIsPrivate BIT
	DECLARE @OldActive BIT
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TD_ID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_TaskDetail] WHERE TD_ID = @TD_ID)
	BEGIN
	    
		SELECT @OldT_ID = T_ID, @OldTask_Item = Task_Item, @OldTask_Item_Detail = Task_Item_Detail, @OldApplication_URL = Application_URL, @OldTask_Start_Date = Task_Start_Date, @OldTask_End_Date = Task_End_Date, @OldPriority_MTV_ID = Priority_MTV_ID, @OldStatus_MTV_ID = Status_MTV_ID, @OldBUILDCODE = BUILDCODE, @OldTaskCategory_MTV_ID = TaskCategory_MTV_ID
		, @OldReview_Date = Review_Date, @OldETA_Date = ETA_Date, @OldLeadAssignTo = LeadAssignTo, @OldIsPrivate = IsPrivate, @OldActive = IsActive FROM [MSPL_DB].[dbo].[T_TMS_TaskDetail] WHERE TD_ID = @TD_ID
		
		UPDATE [MSPL_DB].[dbo].[T_TMS_TaskDetail] 
		SET Task_Item = @Task_Item, Task_Item_Detail = @Task_Item_Detail, Application_URL = @Application_URL, Task_Start_Date = @Task_Start_Date, Task_End_Date = @Task_End_Date, Priority_MTV_ID = @Priority_MTV_ID, Status_MTV_ID = @Status_MTV_ID, BUILDCODE = @BUILDCODE
		,TaskCategory_MTV_ID = @TaskCategory_MTV_ID ,Review_Date = @Review_Date ,ETA_Date = @ETA_Date ,LeadAssignTo = @LeadAssignTo, IsPrivate = @IsPrivate, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE TD_ID = @TD_ID
		
		IF @OldT_ID <> @T_ID
		BEGIN	
			exec P_Add_Audit_History 'T_ID' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldT_ID, @T_ID, @OldT_ID, @T_ID, '', 0, 167100, @UserName
		END

		IF @OldTask_Item <> @Task_Item
		BEGIN	
			exec P_Add_Audit_History 'Task_Item' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTask_Item, @Task_Item, @OldTask_Item, @Task_Item, '', 0, 167100, @UserName
		END

		IF @OldTask_Item_Detail <> @Task_Item_Detail
		BEGIN	
			exec P_Add_Audit_History 'Task_Item_Detail' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTask_Item_Detail, @Task_Item_Detail, @OldTask_Item_Detail, @Task_Item_Detail, '', 0, 167100, @UserName
		END

		IF @OldApplication_URL <> @Application_URL
		BEGIN	
			exec P_Add_Audit_History 'Application_URL' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldApplication_URL, @Application_URL, @OldApplication_URL, @Application_URL, '', 0, 167100, @UserName
		END

		IF @OldTask_Start_Date <> @Task_Start_Date
		BEGIN	
			exec P_Add_Audit_History 'Task_Start_Date' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTask_Start_Date, @Task_Start_Date, @OldTask_Start_Date, @Task_Start_Date, '', 0, 167100, @UserName
		END

		IF @OldTask_End_Date <> @Task_End_Date
		BEGIN	
			exec P_Add_Audit_History 'Task_End_Date' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTask_End_Date, @Task_End_Date, @OldTask_End_Date, @Task_End_Date, '', 0, 167100, @UserName
		END

		IF @OldTaskCategory_MTV_ID <> @TaskCategory_MTV_ID
		BEGIN
			Select @OldTaskCategory_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldTaskCategory_MTV_ID), @TaskCategory_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@TaskCategory_MTV_ID)
			exec P_Add_Audit_History 'TaskCategory_MTV_ID' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldTaskCategory_MTV_ID, @TaskCategory_MTV_ID, @OldTaskCategory_MTV_Name, @TaskCategory_MTV_Name, '', 0, 167100, @UserName
		END

		IF @OldPriority_MTV_ID <> @Priority_MTV_ID
		BEGIN
			Select @OldPriority_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldPriority_MTV_ID), @Priority_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@Priority_MTV_ID)
			exec P_Add_Audit_History 'Priority_MTV_ID' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldPriority_MTV_ID, @Priority_MTV_ID, @OldPriority_MTV_Name, @Priority_MTV_Name, '', 0, 167100, @UserName
		END

		IF @OldStatus_MTV_ID <> @Status_MTV_ID
		BEGIN	
			Select @OldStatus_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@OldStatus_MTV_ID), @Status_MTV_Name = [MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](@Status_MTV_ID)
			exec P_Add_Audit_History 'Status_MTV_ID' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldStatus_MTV_ID, @Status_MTV_ID, @OldStatus_MTV_ID, @Status_MTV_ID, '', 0, 167100, @UserName
		END

		IF @OldBUILDCODE <> @BUILDCODE
		BEGIN	
			Select @OldBuildName = @OldBUILDCode, @BuildName = @BUILDCODE  -- Need to Workin On
			exec P_Add_Audit_History 'BUILDCODE' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldBUILDCODE, @BUILDCODE, @OldBuildName, @BuildName, '', 0, 167100, @UserName
		END

		IF @OldReview_Date <> @Review_Date
		BEGIN	
			exec P_Add_Audit_History 'Review_Date' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldReview_Date, @Review_Date, @OldReview_Date, @Review_Date, '', 0, 167100, @UserName
		END

		IF @OldETA_Date <> @ETA_Date
		BEGIN	
			exec P_Add_Audit_History 'ETA_Date' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldETA_Date, @ETA_Date, @OldETA_Date, @ETA_Date, '', 0, 167100, @UserName
		END

		IF @OldLeadAssignTo <> @LeadAssignTo
		BEGIN	
			exec P_Add_Audit_History 'LeadAssignTo' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldLeadAssignTo, @LeadAssignTo, @OldLeadAssignTo, @LeadAssignTo, '', 0, 167100, @UserName
		END

		IF @OldIsPrivate <> @IsPrivate
		BEGIN
			Declare @OldIsPrivateText nvarchar(10) = (case when @OldIsPrivate = 1 then 'Yes' else 'No' end)
			Declare @IsPrivateText nvarchar(10) = (case when @IsPrivate = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsPrivate' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldIsPrivate, @IsPrivate, @OldIsPrivateText, @IsPrivateText, '', 0, 167100, @UserName
		END	

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_TMS_TaskDetail', @T_ID, 166144, @TD_ID, '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Task Detail Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Detail does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @T_ID > 0 AND @Task_Item <> '' BEGIN
		--IF ISNULL(@TaskCategory,'') = '' BEGIN set @TaskCategory = 'Public' END
		INSERT INTO [MSPL_DB].[dbo].[T_TMS_TaskDetail] (T_ID, Task_Item, Task_Item_Detail, Application_URL, Task_Start_Date, Task_End_Date, Priority_MTV_ID, Status_MTV_ID, BUILDCODE, TaskCategory_MTV_ID, Review_Date, ETA_Date, LeadAssignTo, IsPrivate, IsActive, AddedBy, AddedOn) 
		VALUES (@T_ID, @Task_Item, @Task_Item_Detail, @Application_URL, @Task_Start_Date, @Task_End_Date, @Priority_MTV_ID, @Status_MTV_ID, @BUILDCODE, @TaskCategory_MTV_ID, @Review_Date, @ETA_Date, @LeadAssignTo, @IsPrivate, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Task Detail Added Successfully!'
		SET @Return_Code = 1
		set @TD_IDReturn=SCOPE_IDENTITY()
	END
	ELSE BEGIN
		SET @Return_Text = 'Task Detail Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code,@TD_IDReturn

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TaskManagementSystem]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      <Author Name>
-- Create date: <Create Date>
-- Description: <Description>
-- =============================================


CREATE PROCEDURE [dbo].[P_AddOrEdit_TaskManagementSystem]
    @Json nvarchar(max),
    @Username nvarchar(150),
    @IPAddress nvarchar(20)=''
AS
BEGIN
IF @Json = ''
    BEGIN
   --     set @Return_Code='No Data in Json'
		 --set  @Return_Code=0 
		 return
    END
    ELSE
    BEGIN
        IF ISJSON(@Json) = 0
        BEGIN
   --       set @Return_Code='No Data in Json'
		 --set  @Return_Code=0
		 return
        END
    END
    DECLARE @Return_Code bit = 0
    DECLARE @Return_Text nvarchar(1000) = ''
    DECLARE @Error_Text nvarchar(1000) = ''
	Declare @ReturnT_ID int
    Declare @ReturnTD_ID int
    Declare @ReturnTA_ID int
	Declare @ReturnTable Table (T_ID int, TD_ID int, TA_ID int,[FileName] nvarchar(40), Return_Code bit, Return_Text Nvarchar(1000))
    --Declare @spTA_ID int
    BEGIN TRY
        BEGIN TRANSACTION
		
		SET @Return_Code = 0
		SET @ReturnT_ID =0
        
         
        -- Variables for Task Returns
        DECLARE @TaskReturn_Code bit
        DECLARE @TaskReturn_Text nvarchar(1000)  
		
        -- Variables for Task Details Returns
        DECLARE @TaskDetailsReturn_Code bit
        DECLARE @TaskDetailsReturn_Text nvarchar(1000)  

        -- Variables for Task and Attachment Counts
        DECLARE @TaskDetailsCount int = 0
        DECLARE @TaskAttachmentsCount int = 0
        DECLARE @TaskDetailsMaxCount int = 0
        DECLARE @TaskAttachmentsMaxCount int = 0

        -- Variables for Task Details
        DECLARE @TD_ID int
        DECLARE @TaskDetailsID int
        DECLARE @Task_Item nvarchar(1000)
        DECLARE @Task_Item_Detail nvarchar(max)
        DECLARE @Application_URL nvarchar(max)
        DECLARE @Task_Start_Date Date
        DECLARE @Task_End_Date Date
        DECLARE @Priority_MTV_Code int
        DECLARE @Status_MTV_Code int
        DECLARE @BUILDCODE nvarchar(50) = ''
        DECLARE @TaskCategory_MTV_ID int
		DECLARE @Review_Date Date
		DECLARE @ETA_Date Date
		DECLARE @LeadAssignTo nvarchar(150)
        DECLARE @IsPrivate bit=0
        DECLARE @TaskDetailActive bit=1
        DECLARE @TD_IDSpReturn int=0
        DECLARE @AttachmentsJson nvarchar(max)

        -- Variables for Attachment Details
        DECLARE @TA_ID int
        DECLARE @OriginalFileName nvarchar(500)
        --DECLARE @File nvarchar(max)
        DECLARE @FileName nvarchar(40)
        DECLARE @FileExt nvarchar(20)
		Declare @Path Nvarchar(1000)
		Declare @DocumentType_MTV_ID int
		Declare @AttachmentType_MTV_ID int
		Declare @REFID1 int
		Declare @REFID2	int
		Declare @REFID3	int
		Declare @REFID4	int
        DECLARE @AttachmentsIsActive bit
        DECLARE @IsActive bit = 1

        -- Variables for Task
        DECLARE @T_ID int
        DECLARE @Application_MTV_ID int
        DECLARE @TaskName nvarchar(500)
        DECLARE @Note nvarchar(Max)
		Declare @TaskActive bit
        DECLARE @TaskItemsJson nvarchar(max)
        DECLARE @TIDSpReturn int=0;

		Declare @AttachmentsReturnCode bit
		Declare @AttachmentsReturnText Nvarchar(1000)

		set @TIDSpReturn=0;
		set @TD_IDSpReturn=0;

        -- Table Variables
        DECLARE @TaskDeatilsTabel table (
            tempTaskID int identity(1, 1),
            TD_ID int,
            T_IDReturn int,
            Task_Item nvarchar(400),
            Task_Item_Detail nvarchar(max),
            Application_URL nvarchar(max),
            Task_Start_Date DateTime,
            Task_End_Date DateTime,
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

        DECLARE @AttachmentsTabel table (
            tempAttachID int identity(1, 1),
            TA_ID int,
            FileType_ID int,
			OriginalFileName nvarchar(500),
			[FileName] nvarchar(100),
			FileExt nvarchar(100),
            --[File] nvarchar(max),
			[Path] nvarchar(1000),
			DocumentType_MTV_ID int,
			AttachmentType_MTV_ID int,
			REFID1 int ,
			REFID2 int,
			REFID3 int,
			REFID4 int,
			AttachmentsIsActive bit
        )

        -- Output Tables
        DECLARE @OutPutTasksTable table(Return_Text nvarchar(1000), Return_Code bit, T_IDReturn int)
        DECLARE @OutPutTasksDetailsTable table(Return_Text nvarchar(1000), Return_Code bit, TD_IDReturn int)

        -- Get Task details from JSON input
        SELECT @T_ID = T_ID,
               @Application_MTV_ID = Application_MTV_ID,
               @TaskName = TaskName,
               @Note = Note,
			   @TaskActive=TaskActive,
               @TaskItemsJson = TaskItemsJson
        FROM [MSPL_DB].[dbo].[F_Get_T_TMS_Tasks_JsonTable](@Json)

		  
		  
        -- Insert Task Details into Temp Table
        INSERT INTO @TaskDeatilsTabel (TD_ID,Task_Item,Task_Item_Detail,Application_URL,Task_Start_Date,Task_End_Date,Priority_MTV_Code,Status_MTV_Code ,BUILDCODE,  TaskCategory_MTV_ID , Review_Date, ETA_Date ,LeadAssignTo , IsPrivate , TaskDetailActive,AttachmentsJson)
        SELECT TD_ID,Task_Item,Task_Item_Detail,Application_URL,Task_Start_Date,Task_End_Date,Priority_MTV_Code,Status_MTV_Code ,BUILDCODE,  TaskCategory_MTV_ID , Review_Date, ETA_Date ,LeadAssignTo , IsPrivate , TaskDetailActive,AttachmentsJson
        FROM [MSPL_DB].[dbo].[F_Get_TMS_TaskDetail_JsonTable](@TaskItemsJson)

		

        -- Get the maximum Task Details Count
        SELECT @TaskDetailsMaxCount = MAX(tempTaskID) FROM @TaskDeatilsTabel
        -- Execute Task Addition or Edition Procedure and get result
        DELETE FROM @OutPutTasksTable;
        INSERT INTO @OutPutTasksTable(Return_Text, Return_Code, T_IDReturn)
        EXEC [MSPL_DB].[dbo].[P_AddOrEdit_Tasks] @T_ID, @Application_MTV_ID, @TaskName, @Note, @TaskActive, @Username
        
		SELECT @TIDSpReturn = T_IDReturn, @TaskReturn_Code = Return_Code, @TaskReturn_Text = Return_Text FROM @OutPutTasksTable
        SET @Return_Text = @TaskReturn_Text
        SET @Return_Code = @TaskReturn_Code
		
		if @TIDSpReturn=0
		begin
		Set @ReturnT_ID=@T_ID
		end
		else
		begin
		Set @ReturnT_ID=@TIDSpReturn
		end
		
        -- If Task Addition or Edition Successful
		 
        IF @TaskReturn_Code = 1
        BEGIN 
            WHILE @TaskDetailsCount < @TaskDetailsMaxCount
            BEGIN
                SET @TaskDetailsCount = @TaskDetailsCount + 1;
				SET @AttachmentsJson='';
				 SET @ReturnTD_ID=0
         
                -- Get Task Details for iteration
                SELECT @TD_ID=TD_ID,@TaskDetailsID=@TIDSpReturn, @Task_Item=Task_Item,@Task_Item_Detail=Task_Item_Detail,@Application_URL=Application_URL,@Task_Start_Date=Task_Start_Date,@Task_End_Date=Task_End_Date,@Priority_MTV_Code=Priority_MTV_Code,@Status_MTV_Code=Status_MTV_Code ,@BUILDCODE=BUILDCODE,  @TaskCategory_MTV_ID=TaskCategory_MTV_ID , @Review_Date=Review_Date, @ETA_Date=ETA_Date ,@LeadAssignTo = LeadAssignTo, @IsPrivate=IsPrivate , @TaskDetailActive=TaskDetailActive, @AttachmentsJson=AttachmentsJson
                FROM @TaskDeatilsTabel where tempTaskID=@TaskDetailsCount
               
				 
                 --Set Task ID based on existing or new Task
				--set @IsPrivate=0
                IF @TaskDetailsID = 0
                BEGIN
                    SET @T_ID = @TIDSpReturn;
                END
                ELSE
                BEGIN
                    SET @T_ID = @TaskDetailsID;
                END
				  
                -- Execute Task Details Addition or Edition Procedure
                DELETE FROM @OutPutTasksDetailsTable;
                INSERT INTO @OutPutTasksDetailsTable(Return_Text, Return_Code, TD_IDReturn)  
                EXEC P_AddOrEdit_TaskDetail @TD_ID, @T_ID, @Task_Item, @Task_Item_Detail, @Application_URL, @Task_Start_Date, @Task_End_Date, @Priority_MTV_Code, @Status_MTV_Code, @BUILDCODE, @TaskCategory_MTV_ID,@Review_Date, @ETA_Date, @LeadAssignTo ,@IsPrivate, @TaskDetailActive, @Username, @IPAddress

                -- Get Task Details result
                SELECT @TD_IDSpReturn = TD_IDReturn, @TaskDetailsReturn_Code = Return_Code, @TaskDetailsReturn_Text = Return_Text FROM @OutPutTasksDetailsTable;

                -- If Task Details Addition or Edition Successful
				 --Set @ReturnTD_ID=@ReturnTD_ID+','+cast(@TD_IDSpReturn AS nvarchar(100))
				  
				if @TD_ID=0
				 Begin
				  SET @ReturnTD_ID=@TD_IDSpReturn
				 
				  End
				  Else
				  Begin
				    SET @ReturnTD_ID=@TD_ID
				  End
         
                IF @TaskDetailsReturn_Code = 1
                BEGIN 
                    -- Get Attachment Count for iteration
				delete from @AttachmentsTabel
                insert into @AttachmentsTabel ( TA_ID  ,OriginalFileName  ,[FileName]  ,FileExt  ,[Path]  ,DocumentType_MTV_ID  ,AttachmentType_MTV_ID  ,REFID1  ,REFID2  ,REFID3  ,REFID4  ,AttachmentsIsActive )
                select TA_ID  ,OriginalFileName  ,[FileName]  ,FileExt  ,[Path]  ,DocumentType_MTV_ID  ,AttachmentType_MTV_ID  ,REFID1  ,REFID2  ,REFID3  ,REFID4  ,AttachmentsIsActive from [MSPL_DB].[dbo].[F_Get_TMS_TaskAttachments_JsonTable](@AttachmentsJson)
						 
                   SELECT @TaskAttachmentsMaxCount = MAX(tempAttachID) FROM @AttachmentsTabel

                    -- Iterate through Attachments
                    WHILE @TaskAttachmentsCount < @TaskAttachmentsMaxCount
                    BEGIN
                        SET @TaskAttachmentsCount = @TaskAttachmentsCount + 1
						SET @ReturnTA_ID =0
                        -- Get Attachment Details for iteration
                        SELECT @TA_ID = TA_ID, @OriginalFileName=OriginalFileName,@FileName = [FileName], @FileExt = FileExt,@Path=[Path],@DocumentType_MTV_ID=DocumentType_MTV_ID,@AttachmentType_MTV_ID=AttachmentType_MTV_ID,@REFID1=REFID1,@REFID2=REFID2,@REFID3=REFID3,@REFID1=REFID1,@REFID2=REFID2,@REFID4=REFID4, @AttachmentsIsActive=AttachmentsIsActive FROM @AttachmentsTabel WHERE tempAttachID = @TaskAttachmentsCount
						  --REFID1 is treated is TD_ID
						  IF @REFID2 = 0
								BEGIN
									SET @REFID2 = @TD_IDSpReturn;
									 
								END
								  
                            EXEC P_AddOrEdit_TasksAttachments @TA_ID,@OriginalFileName, @FileName, @FileExt, @Path, @DocumentType_MTV_ID,@AttachmentType_MTV_ID,@REFID1,@REFID2,@REFID3,@REFID4,@AttachmentsIsActive, @Username, @pReturn_Code=@AttachmentsReturnCode out,@pReturn_Text=@AttachmentsReturnText Out,@pReturnTA_ID= @ReturnTA_ID out
                            --SET @ReturnTA_ID = @ReturnTA_ID + ',' + CAST(@spTA_ID AS nvarchar(100));
							insert into @ReturnTable(T_ID,TD_ID,TA_ID,[FileName])
							select @ReturnT_ID,@ReturnTD_ID,@ReturnTA_ID,@FileName
							
							if(@AttachmentsReturnCode=1)
							begin
							 
								SET @Return_Text = CONCAT(@Return_Text, ',', @AttachmentsReturnText);
								SET @Return_Code = 1
                            end
							ELSE
							BEGIN
				
								-- If Task Attachment addition or edit failed
								SET @Return_Text = @Return_Text + ',' +@AttachmentsReturnText;
								SET @Return_Code = 0
								 
							END
                         
                    END

                    -- Set overall return text and code
                    SET @Return_Text = @Return_Text + ',' + @TaskDetailsReturn_Text;
                    SET @Return_Code = 1
                END
                ELSE
                BEGIN
				
                    -- If Task Details addition or edit failed
                    SET @Return_Text = @Return_Text + ',' + 'T_TMS_TaskDetail_'+@TaskDetailsReturn_Text;
                    SET @Return_Code = 0
					 
                END
            END
        END
        ELSE
        BEGIN
            -- If Task addition or edition failed
			
            SET @Return_Text = CONCAT(@Return_Text, ',', @TaskReturn_Text);
            SET @Return_Code = 0
			ROLLBACK
			
        END

        -- Finalize transaction
        IF @@TRANCOUNT > 0 AND @Return_Code = 1
        BEGIN
            COMMIT; 
        END
        ELSE IF @@TRANCOUNT > 0 AND @Return_Code = 0
        BEGIN
            ROLLBACK; 
        END
    END TRY
    BEGIN CATCH
        -- Error handling
        SET @Return_Code = 0
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK; 
        END
        SET @Return_Text = 'P_AddOrEdit_TaskManagementSystem: ' + ERROR_MESSAGE()
    END CATCH

    -- Return final result
	--@Error_Text AS Error_Text 
	if @Return_Code=0
	Begin 
	SELECT @Return_Text AS Return_Text, @Return_Code AS Return_Code, @T_ID As T_ID,@TD_ID as TD_ID ,@TA_ID as TA_ID ,@FileName As  [FileName]
	End
    else
	begin
	 IF EXISTS (SELECT 1 FROM @ReturnTable)
BEGIN
    update @ReturnTable set Return_Text=@Return_Text,Return_Code=1 
	SELECT Return_Text, Return_Code, T_ID,TD_ID,TA_ID,[FileName] from @ReturnTable 
End
Else
Begin
SELECT @Return_Text AS Return_Text, @Return_Code AS Return_Code
End
	
	end
END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_Tasks]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC P_AddOrEdit_Tasks 0, 148100,'Test','test',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_Tasks]
@T_ID INT = NULL,
@Application_MTV_ID INT,
@TaskName NVARCHAR(200),
@Note NVARCHAR(MAX),
--@OutTID int output,
@Active BIT = 1,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''

AS
BEGIN
	DECLARE @OldApplication_MTV_ID INT
	DECLARE @OldTaskName NVARCHAR(200)
    DECLARE @OldNote NVARCHAR(max)
	DECLARE @OldActive BIT
	Declare @T_ID_Return int
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @T_ID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_Tasks] with (nolock) WHERE T_ID = @T_ID)
	BEGIN
	    
		SELECT @OldTaskName = TaskName, @OldApplication_MTV_ID = Application_MTV_ID,@OldNote=Note, @OldActive = IsActive FROM [MSPL_DB].[dbo].[T_TMS_Tasks] with (nolock) WHERE T_ID = @T_ID
		
		UPDATE [MSPL_DB].[dbo].[T_TMS_Tasks] SET TaskName = @TaskName, Application_MTV_ID = @Application_MTV_ID, Note = @Note, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE T_ID = @T_ID
		
		set @T_ID_Return=0;
		IF @OldTaskName <> @TaskName
		BEGIN	
			exec P_Add_Audit_History 'TaskName' ,'T_TMS_Tasks', @T_ID, 166144, '', '', '', @OldTaskName, @TaskName, @OldTaskName, @TaskName, '', 0, 167100, @UserName
		END

		IF @OldApplication_MTV_ID <> @Application_MTV_ID
		BEGIN	
			exec P_Add_Audit_History 'Application_MTV_ID' ,'T_TMS_Tasks', @T_ID, 166144, '', '', '', @OldApplication_MTV_ID, @Application_MTV_ID, @OldApplication_MTV_ID, @Application_MTV_ID, '', 0, 167100, @UserName
		END
		IF @OldNote <> @Note
		BEGIN	
			exec P_Add_Audit_History 'Note' ,'T_TMS_Tasks', @T_ID, 166144, '', '', '', @OldNote, @Note, @OldNote, @Note, '', 0, 167100, @UserName
		END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_TMS_Tasks', @T_ID, 166144, '', '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @Return_Text = 'Task Updated Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task does not exist!'
		SET @Return_Code = 0
	END
END

ELSE
BEGIN
	IF @TaskName <> '' BEGIN
		INSERT INTO [MSPL_DB].[dbo].[T_TMS_Tasks] (Application_MTV_ID, TaskName, Note, IsActive, AddedBy, AddedOn) 
		VALUES (@Application_MTV_ID, @TaskName, @Note, @Active, @Username, GETUTCDATE())
		SET @Return_Text = 'Task Added Successfully!'
		SET @Return_Code = 1
		Set @T_ID_Return =SCOPE_IDENTITY();
	END
	ELSE BEGIN
		SET @Return_Text = 'Task Name Not Found!'
		SET @Return_Code = 0
	END
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code,@T_ID_Return As T_ID

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_TasksAttachments]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		  
CREATE PROC [dbo].[P_AddOrEdit_TasksAttachments]
@TA_ID int,
@OriginalFileName nvarchar(500),
@FileName nvarchar(100),
@FileExt nvarchar(100),
@Path nvarchar(1000),
@DocumentType_MTV_ID int,
@AttachmentType_MTV_ID int,
@REFID1 int,
@REFID2 int,
@REFID3 int,
@REFID4 int,
@Active BIT = 1,
@Username nvarchar(150),
@pReturn_Code bit output,
@pReturn_Text  nvarchar(1000)  output,
@pReturnTA_ID int output,
@IPAddress nvarchar(20) = ''

AS
BEGIN
	DECLARE  @OldFile nvarchar(max)
	DECLARE  @OldFileName nvarchar(40)
	Declare  @OldOriginalFileName nvarchar(500)
	Declare  @OldFileExt nvarchar(100)
	Declare  @OldPath nvarchar(1000)
	Declare  @OldDocumentType_MTV_ID int
	Declare  @OldAttachmentType_MTV_ID int
	Declare  @OldREFID1 int
	Declare  @OldREFID2 int
	Declare  @OldREFID3 int
	Declare  @OldREFID4 int
	Declare  @OldActive BIT
	set @pReturn_Code  = 1
	set @pReturn_Text  = ''
	set @pReturnTA_ID=0

	DECLARE @TempReturn_Code bit
	DECLARE @TempReturn_Text nvarchar(40)

	set @TempReturn_Code=1
	set @TempReturn_Text=''

IF @TA_ID > 0
BEGIN
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_TaskAttachments] WHERE TA_ID = @TA_ID)
	BEGIN
	    
		SELECT @OldActive = IsActive FROM [MSPL_DB].[dbo].[T_TMS_TaskAttachments] WHERE TA_ID = @TA_ID
		
		UPDATE [MSPL_DB].[dbo].[T_TMS_TaskAttachments] Set IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE TA_ID = @TA_ID
		
		--IF @OldFileName <> @FileName
		--BEGIN	
		--	exec P_Add_Audit_History 'FileName' ,'T_TMS_TaskAttachments', @TA_ID, 166144, '', '', '', @OldFileName, @FileName, @OldFileName, @FileName, '', 0, 167100, @UserName
		--END

		IF @OldActive <> @Active
		BEGIN
			Declare @OldIsActiveText nvarchar(10) = (case when @OldActive = 1 then 'Yes' else 'No' end)
			Declare @IsActiveText nvarchar(10) = (case when @Active = 1 then 'Yes' else 'No' end)
			exec P_Add_Audit_History 'IsActive' ,'T_TMS_TaskAttachments', @TA_ID, 166144, '', '', '', @OldActive, @Active, @OldIsActiveText, @IsActiveText, '', 0, 167100, @UserName
		END	

		SET @TempReturn_Text = 'Task Attachments Updated Successfully!'
		SET @TempReturn_Code = 1
	END
	ELSE
	BEGIN
		SET @TempReturn_Text = 'Task Attachments does not exist!'
		SET @TempReturn_Code = 0
	END
END

ELSE
BEGIN
	IF @FileName <> '' BEGIN
		INSERT INTO [MSPL_DB].[dbo].[T_TMS_TaskAttachments] (OriginalFileName,[FileName],FileExt,[Path],DocumentType_MTV_ID,AttachmentType_MTV_ID,REFID1,REFID2,REFID3,REFID4,IsActive ,AddedBy, AddedOn) 
		VALUES (@OriginalFileName,@FileName,@FileExt,@Path,@DocumentType_MTV_ID,@AttachmentType_MTV_ID,@REFID1,@REFID2,@REFID3,@REFID4,@Active, @Username, GETUTCDATE())
		SET @TempReturn_Text = 'Task Attachments Added Successfully!'
		SET @TempReturn_Code = 1
		set @pReturnTA_ID=SCOPE_IDENTITY();
		 
	END
	ELSE BEGIN
		SET @TempReturn_Text = 'Task Attachments Name Not Found!'
		SET @TempReturn_Code = 0
	END
END
set @pReturn_Text =@TempReturn_Text
set @pReturn_Code=@TempReturn_Code

--SELECT @pReturn_Text Return_Text, @pReturn_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_AddOrEdit_User_Role_Map]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--							EXEC P_AddOrEdit_User_Role_Map 0,2,'ABDULLAH.ARSHAD',0,1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_AddOrEdit_User_Role_Map]
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
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_User_Role_Mapping] WITH (NOLOCK) WHERE URM_ID = @URM_ID)
	BEGIN
	    
		DECLARE @OldR_ID INT
		DECLARE @OldUNAME nvarchar(150)
		DECLARE @OldIsGroupRoleID BIT
		DECLARE @OldActive BIT
		
		SELECT @OldR_ID = ROLE_ID, @OldUNAME = USERNAME, @OldIsGroupRoleID = IsGroupRoleID, @OldActive = IsActive FROM [MSPL_DB].[dbo].[T_User_Role_Mapping] WITH (NOLOCK) WHERE URM_ID = @URM_ID
		
		UPDATE [MSPL_DB].[dbo].[T_User_Role_Mapping] SET ROLE_ID = @R_ID, USERNAME = @UNAME, IsGroupRoleID = @IsGroupRoleID, IsActive = @Active, ModifiedBy = @Username, ModifiedOn = GETUTCDATE() WHERE URM_ID = @URM_ID
		
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
		INSERT INTO [MSPL_DB].[dbo].[T_User_Role_Mapping] (ROLE_ID, USERNAME, IsGroupRoleID, IsActive, AddedBy, AddedOn) VALUES (@R_ID, @UNAME, @IsGroupRoleID, @Active, @Username, GETUTCDATE())
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
/****** Object:  StoredProcedure [dbo].[P_Generate_UserID]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Declare @UserID int exec [MSPL_DB].[dbo].[P_Generate_UserID] @Ret_UserID = @UserID out select @UserID
-- =============================================
CREATE PROCEDURE [dbo].[P_Generate_UserID]
	@Ret_UserID int out
AS
BEGIN
	insert into [MSPL_DB].[dbo].[T_Generate_UserID] (IsGenerate)
	values (1)
	select @Ret_UserID = SCOPE_IDENTITY()
	--delete from [MSPL_DB].[dbo].[T_Generate_UserID] where USER_ID = @Ret_UserID
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ApplicationPageGroupMapping_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[P_Get_ApplicationPageGroupMapping_List]
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
  FROM [MSPL_DB].[dbo].[T_Application_Page_Group_Mapping] apgm
INNER JOIN (
SELECT MTV_ID, MTV_CODE, Name FROM [MSPL_DB].[dbo].[T_Master_Type_Value] WHERE MT_ID = 148
) mtv ON apgm.Application_MTV_CODE = mtv.MTV_CODE
INNER JOIN [MSPL_DB].[dbo].[T_Page_Group] pg ON apgm.PG_ID = pg.PG_ID
'
  exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT
    
   
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_ApplicationPageMapping_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec P_Get_ApplicationPageMapping_List 'Ihtisham',0,2,'asc',' asc',0 
CREATE PROCEDURE [dbo].[P_Get_ApplicationPageMapping_List]
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
 FROM [MSPL_DB].[dbo].[T_Application_Page_Mapping] apm
INNER JOIN
[MSPL_DB].[dbo].[T_Master_Type_Value] mtv ON apm.Application_MTV_CODE = mtv.MTV_CODE And mtv.MT_ID = 148
INNER JOIN [MSPL_DB].[dbo].[T_Page] p ON apm.P_ID = p.P_ID
Inner Join [MSPL_DB].[dbo].[T_Page_Group] pg ON p.PG_ID = pg.PG_ID
'
 
  exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT
    
   
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_AuditColumn_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--	Declare @TotalCount int = 0 exec [dbo].[P_Get_AuditColumn_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_AuditColumn_List] 
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
	FROM [MSPL_DB].[dbo].[T_Audit_Column] ac with (nolock)' 
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_AuditHistory_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--	Declare @TotalCount int = 0 exec [dbo].[P_Get_AuditHistory_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, -14400000, 13, '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_AuditHistory_List] 
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@filterobject)

	DROP TABLE IF exists #Table_Fields_Column
	CREATE TABLE #Table_Fields_Column (code nvarchar(150) ,name_ nvarchar(150) ,iscolumnrequired bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@columnobject)

	Declare @TimeZoneName nvarchar(50) = null
	Declare @TimeZoneAbbr nvarchar(10) = null
	select @TimeZoneName = tzl.TimeZoneName , @TimeZoneAbbr = TimeZoneAbbreviation from [MSPL_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where tzl.TIMEZONE_ID = @TimeZoneID

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
	+ char(10) + (case when @ChangedOn_Filtered = 1 then '' else @HideField end) + ',ChangedOn=[MSPL_DB].[dbo].[F_Get_DateTime_From_UTC] ([ChangedOn],' + cast(@TimeZoneID as nvarchar(20)) + ',null,''' + @TimeZoneName + ''')'
	+ char(10) + (case when @UTCChangedOn_Filtered = 1 then '' else @HideField end) + ',UTCChangedOn=ChangedOn
	FROM [MSPL_DB].[dbo].[T_Audit_History] ah with (nolock) 
	INNER JOIN [MSPL_DB].[dbo].[T_Audit_Column] ac with (nolock) ON ah.AC_ID = ac.AC_ID
	left JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] mtv_audit with (nolock) ON ah.AuditType_MTV_ID = mtv_audit.MTV_ID
	left JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) ON ah.Source_MTV_ID = mtv.MTV_ID'

	--select @selectSql

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Chat_Dropdown_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_Get_Chat_Dropdown_Lists]
AS
BEGIN
	
	SELECT code = MTV_CODE, [name] = [Name] FROM [dbo].[T_Master_Type_Value] WITH (NOLOCK) WHERE MT_ID = 181 AND IsActive = 1 AND Name <> 'Public' ORDER BY Sort_
	SELECT code = USERNAME, name = CONCAT(FirstName,' ',LastName) FROM [dbo].[T_Users] WITH (NOLOCK) WHERE USERNAME IN ('ABDULLAH.ARSHAD','HAMMAS.KHAN','BABAR.ALI','TAIMOOR.ALI','SAAD.QADIR','TOUSEEF.AHMAD','IHTISHAM.ULHAQ','MUSA.RAZA')
END

 
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Chat_Messages]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--- exec P_Get_Chat_Messages 2, 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Get_Chat_Messages]
	 @CR_ID INT 
	,@UserName NVARCHAR(150) 
AS
BEGIN

	SELECT cr.CR_ID, crum.CRUM_ID, c.C_ID, c.Parent_C_ID, c.Parent_C_ID_Image
	,cr.Room_Name
	,c.Send_UserName
	,UserName = @UserName
	,c.Message
	,c.Attachment_Path
	,MsgOn = FORMAT(c.AddedOn,'hh:mm tt')
	,c.IsEdited
	,c.EditedOn 
	FROM [dbo].[T_Chat_Room] cr WITH (NOLOCK)
	INNER JOIN [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK) ON cr.CR_ID = crum.CR_ID 
	INNER JOIN [dbo].[T_Chats] c WITH (NOLOCK) ON crum.CRUM_ID = c.CRUM_ID
	WHERE cr.CR_ID = @CR_ID
	ORDER BY c.AddedOn

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Chat_Room]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--- exec P_Get_Chat_Room 'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Get_Chat_Room]
	@UserName nvarchar(150) 
AS
BEGIN

	SELECT
	 cr.Room_Type_MTV_CODE
	 ,RoomType = rt.[Name]
	 ,ChatRoomDetails = (
		SELECT CR_ID, CRUM_ID, Room_Name, UserName, IsHistoryAllowed, IsNotificationEnabled, IsAdmin, IsUserAddedAllowed, IsReadOnly, IsOnline
		FROM (SELECT chatroom.Room_Type_MTV_CODE, chatroom.CR_ID,
			crum.CRUM_ID,
			--CRUM_ID = (CASE WHEN chatroom.Room_Type_MTV_CODE = 'PRIVATE' THEN crum2.CRUM_ID ELSE crum.CRUM_ID END),
			Room_Name = (CASE WHEN chatroom.Room_Type_MTV_CODE = 'PRIVATE' THEN chatroom.Room_Name ELSE crum.UserName END),
			UserName = (CASE WHEN chatroom.Room_Type_MTV_CODE = 'PRIVATE' THEN crum2.UserName ELSE chatroom.Room_Name END),
			crum.IsHistoryAllowed, crum.IsNotificationEnabled, crum.IsAdmin, crum.IsUserAddedAllowed, crum.IsReadOnly, crum.IsOnline, crum.AddedOn
		FROM [dbo].[T_Chat_Room_User_Mapping] crum WITH (NOLOCK)
		INNER JOIN [dbo].[T_Chat_Room] chatroom WITH (NOLOCK) ON crum.CR_ID = chatroom.CR_ID
		LEFT JOIN [dbo].[T_Chat_Room_User_Mapping] crum2 WITH (NOLOCK) ON chatroom.Room_Type_MTV_CODE = 'PRIVATE' AND crum.CR_ID = crum2.CR_ID AND crum2.UserName <> @UserName
		WHERE (chatroom.Room_Type_MTV_CODE = 'PRIVATE' AND crum.UserName = @UserName) OR (chatroom.Room_Type_MTV_CODE = 'GROUP' AND crum.UserName = @UserName) OR (chatroom.Room_Type_MTV_CODE = 'PUBLIC')
		GROUP BY chatroom.CR_ID,crum.CRUM_ID,crum2.CRUM_ID,chatroom.Room_Name,crum.UserName,crum2.UserName,crum.IsHistoryAllowed,crum.IsNotificationEnabled,crum.IsAdmin,crum.IsUserAddedAllowed,crum.IsReadOnly,crum.IsOnline,crum.AddedOn, chatroom.Room_Type_MTV_CODE
		) a WHERE Room_Type_MTV_CODE = cr.Room_Type_MTV_CODE ORDER BY AddedOn DESC
		FOR JSON PATH) 
	FROM [dbo].[T_Chat_Room] cr WITH (NOLOCK)
	INNER JOIN [dbo].[T_Master_Type_Value] rt WITH (NOLOCK) ON cr.Room_Type_MTV_CODE = rt.MTV_CODE
	WHERE cr.IsActive = 1 
	GROUP BY cr.Room_Type_MTV_CODE,rt.[Name]
	ORDER BY cr.Room_Type_MTV_CODE ASC 
	FOR JSON PATH

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Common_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[P_Get_Common_List]
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
/****** Object:  StoredProcedure [dbo].[P_Get_Department_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_Department_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

create PROCEDURE [dbo].[P_Get_Department_List] 
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
	SET @sortExpression = ' D_ID asc '  
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
  Declare @Sort_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Sort_') then 1 else 0 end) 
  Declare @IsHidden_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsHidden') then 1 else 0 end)
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @DepartmentName_Req bit = (case when @DepartmentName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DepartmentName') then 0 else 1 end)
  Declare @Sort_Req bit = (case when @Sort_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Sort') then 0 else 1 end)
  Declare @IsHidden_Req bit = (case when @IsHidden_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsHidden') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsHidden_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'select D_ID = d.D_ID'
	+ char(10) + (case when @DepartmentName_Filtered = 1 then '' else @HideField end) + ',DepartmentName = d.DepartmentName'
	+ char(10) + (case when @Sort_Filtered = 1 then '' else @HideField end) + ',Sort_ = d.Sort_'
	+ char(10) + (case when @IsHidden_Filtered = 1 then '' else @HideField end) + ',IsHidden = d.IsHidden'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = d.IsActive
	FROM [MSPL_DB].[dbo].[T_Department] d with (nolock)'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_DepartmentRoleMap_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Declare @TotalCount int = 0 exec [dbo].[P_Get_DepartmentRoleMap_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

create PROCEDURE [dbo].[P_Get_DepartmentRoleMap_List] 
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
	SET @sortExpression = ' DRM_ID asc '  
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
  Declare @R_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'RoleName') then 1 else 0 end)
  Declare @D_ID_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'DepartmentName') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)
  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @R_ID_Req bit = (case when @R_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'RoleName') then 0 else 1 end)
  Declare @D_ID_Req bit = (case when @D_ID_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'DepartmentName') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)

  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
   
	set @selectSql = N'SELECT DRM_ID = drm.DRM_ID, R_ID = r.R_ID, D_ID = d.D_ID'
	+ char(10) + (case when @R_ID_Filtered = 1 then '' else @HideField end) + ',RoleName = r.RoleName'
	+ char(10) + (case when @D_ID_Filtered = 1 then '' else @HideField end) + ',DepartmentName = d.DepartmentName'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = drm.IsActive
	FROM [MSPL_DB].[dbo].[T_Department_Role_Mapping] drm with (nolock) 
	INNER JOIN [MSPL_DB].[dbo].[T_Roles] r with (nolock) ON drm.R_ID = r.R_ID 
	INNER JOIN [MSPL_DB].[dbo].T_Department d with (nolock) ON drm.D_ID = d.D_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Event_Setup_DropDown_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			exec [P_Get_Event_Setup_DropDown_Lists] 'HAMMAS.KHAN'
CREATE PROCEDURE [dbo].[P_Get_Event_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	select [value] = EL_ID, [text]= EVENT_CODE from [MSPL_DB].[dbo].[T_Events_List] with (nolock) order by EVENT_CODE

	select [value] = EL_ID, [text]= Name from [MSPL_DB].[dbo].[T_Events_List] with (nolock) order by Name
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Events_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_Events_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_Events_List] 
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
	SET @sortExpression = ' EL_ID asc '  
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
  Declare @Col1_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Name') then 1 else 0 end)
  Declare @Col2_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Activity') then 1 else 0 end) 
  Declare @Col3_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsAutoTrigger') then 1 else 0 end)  
  Declare @Col4_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsManualTrigger') then 1 else 0 end)  
  Declare @Col5_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsOutboundRequired') then 1 else 0 end)  
  Declare @Col6_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Metro_Email') then 1 else 0 end)  
  Declare @Col7_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Client_Email') then 1 else 0 end)  
  Declare @Col8_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Client_SMS') then 1 else 0 end)  
  Declare @Col9_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Metro_SMS') then 1 else 0 end)  
  Declare @Col10_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_OED_Email') then 1 else 0 end)  
  Declare @Col11_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_OED_SMS') then 1 else 0 end)  
  Declare @Col12_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_CSR_Email') then 1 else 0 end)  
  Declare @Col13_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_CSR_SMS') then 1 else 0 end)  
  Declare @Col14_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Dispatch_Email') then 1 else 0 end)  
  Declare @Col15_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Dispatch_SMS') then 1 else 0 end)  
  Declare @Col16_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Accounting_Email') then 1 else 0 end)  
  Declare @Col17_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Accounting_SMS') then 1 else 0 end)  
  Declare @Col18_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Warehouse_Email') then 1 else 0 end)  
  Declare @Col19_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_Warehouse_SMS') then 1 else 0 end)  
  Declare @Col20_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_ShipFrom_Email') then 1 else 0 end)  
  Declare @Col21_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_ShipFrom_SMS') then 1 else 0 end)  
  Declare @Col22_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_ShipTo_Email') then 1 else 0 end)  
  Declare @Col23_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_ShipTo_SMS') then 1 else 0 end)  
  Declare @Col24_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_SellTo_Email') then 1 else 0 end)  
  Declare @Col25_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_SellTo_SMS') then 1 else 0 end)  
  Declare @Col26_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_BillTo_Email') then 1 else 0 end)  
  Declare @Col27_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsNotify_BillTo_SMS') then 1 else 0 end)  
  Declare @Col28_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsRecurring') then 1 else 0 end)  
  Declare @Col29_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsPublic') then 1 else 0 end)  
  Declare @Col30_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsTrackingAvailable') then 1 else 0 end)  
  Declare @Col31_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Col1_Req bit = (case when @Col1_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Name') then 0 else 1 end)
  Declare @Col2_Req bit = (case when @Col2_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Activity') then 0 else 1 end)
  Declare @Col3_Req bit = (case when @Col3_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsAutoTrigger') then 0 else 1 end)
  Declare @Col4_Req bit = (case when @Col4_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsManualTrigger') then 0 else 1 end)
  Declare @Col5_Req bit = (case when @Col5_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsOutboundRequired') then 0 else 1 end)
  Declare @Col6_Req bit = (case when @Col6_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Metro_Email') then 0 else 1 end)
  Declare @Col7_Req bit = (case when @Col7_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Metro_SMS') then 0 else 1 end)
  Declare @Col8_Req bit = (case when @Col8_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Client_Email') then 0 else 1 end)
  Declare @Col9_Req bit = (case when @Col9_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Client_SMS') then 0 else 1 end)
  Declare @Col18_Req bit = (case when @Col10_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_OED_Email') then 0 else 1 end)
  Declare @Col10_Req bit = (case when @Col11_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_OED_SMS') then 0 else 1 end)
  Declare @Col11_Req bit = (case when @Col12_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_CSR_Email') then 0 else 1 end)
  Declare @Col12_Req bit = (case when @Col13_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_CSR_SMS') then 0 else 1 end)
  Declare @Col13_Req bit = (case when @Col14_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Dispatch_Email') then 0 else 1 end)
  Declare @Col14_Req bit = (case when @Col15_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Dispatch_SMS') then 0 else 1 end)
  Declare @Col15_Req bit = (case when @Col16_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Accounting_Email') then 0 else 1 end)
  Declare @Col16_Req bit = (case when @Col17_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Accounting_SMS') then 0 else 1 end)
  Declare @Col17_Req bit = (case when @Col18_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Warehouse_Email') then 0 else 1 end)
  Declare @Col19_Req bit = (case when @Col19_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_Warehouse_SMS') then 0 else 1 end)
  Declare @Col20_Req bit = (case when @Col20_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_ShipFrom_Email') then 0 else 1 end)
  Declare @Col21_Req bit = (case when @Col21_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_ShipFrom_SMS') then 0 else 1 end)
  Declare @Col22_Req bit = (case when @Col22_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_ShipTo_Email') then 0 else 1 end)
  Declare @Col23_Req bit = (case when @Col23_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_ShipTo_SMS') then 0 else 1 end)
  Declare @Col24_Req bit = (case when @Col24_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_SellTo_Email') then 0 else 1 end)
  Declare @Col25_Req bit = (case when @Col25_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_SellTo_SMS') then 0 else 1 end)
  Declare @Col26_Req bit = (case when @Col26_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_BillTo_Email') then 0 else 1 end)
  Declare @Col27_Req bit = (case when @Col27_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsNotify_BillTo_SMS') then 0 else 1 end)
  Declare @Col28_Req bit = (case when @Col28_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsRecurring') then 0 else 1 end)
  Declare @Col29_Req bit = (case when @Col29_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsPublic') then 0 else 1 end)
  Declare @Col30_Req bit = (case when @Col30_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsTrackingAvailable') then 0 else 1 end)
  Declare @Col31_Req bit = (case when @Col31_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT EL_ID, EVENT_ID, EVENT_CODE, Activity_MTV_ID'
	+ char(10) + (case when @Col1_Filtered = 1 then '' else @HideField end) + ',e.Name, Description'
	+ char(10) + (case when @Col2_Filtered = 1 then '' else @HideField end) + ',Activity = a_mtv.Name'
	+ char(10) + (case when @Col3_Filtered = 1 then '' else @HideField end) + ',IsAutoTrigger'
	+ char(10) + (case when @Col4_Filtered = 1 then '' else @HideField end) + ',IsManualTrigger'
	+ char(10) + (case when @Col5_Filtered = 1 then '' else @HideField end) + ',IsOutboundRequired'
	+ char(10) + (case when @Col6_Filtered = 1 then '' else @HideField end) + ',IsNotify_Metro_Email'
	+ char(10) + (case when @Col7_Filtered = 1 then '' else @HideField end) + ',IsNotify_Metro_SMS'
	+ char(10) + (case when @Col8_Filtered = 1 then '' else @HideField end) + ',IsNotify_Client_Email'
	+ char(10) + (case when @Col9_Filtered = 1 then '' else @HideField end) + ',IsNotify_Client_SMS'
	+ char(10) + (case when @Col10_Filtered = 1 then '' else @HideField end) + ',IsNotify_OED_Email'
	+ char(10) + (case when @Col11_Filtered = 1 then '' else @HideField end) + ',IsNotify_OED_SMS'
	+ char(10) + (case when @Col12_Filtered = 1 then '' else @HideField end) + ',IsNotify_CSR_Email'
	+ char(10) + (case when @Col13_Filtered = 1 then '' else @HideField end) + ',IsNotify_CSR_SMS'
	+ char(10) + (case when @Col14_Filtered = 1 then '' else @HideField end) + ',IsNotify_Dispatch_Email'
	+ char(10) + (case when @Col15_Filtered = 1 then '' else @HideField end) + ',IsNotify_Dispatch_SMS'
	+ char(10) + (case when @Col16_Filtered = 1 then '' else @HideField end) + ',IsNotify_Accounting_Email'
	+ char(10) + (case when @Col17_Filtered = 1 then '' else @HideField end) + ',IsNotify_Accounting_SMS'
	+ char(10) + (case when @Col18_Filtered = 1 then '' else @HideField end) + ',IsNotify_Warehouse_Email'
	+ char(10) + (case when @Col19_Filtered = 1 then '' else @HideField end) + ',IsNotify_Warehouse_SMS'
	+ char(10) + (case when @Col20_Filtered = 1 then '' else @HideField end) + ',IsNotify_ShipFrom_Email'
	+ char(10) + (case when @Col21_Filtered = 1 then '' else @HideField end) + ',IsNotify_ShipFrom_SMS'
	+ char(10) + (case when @Col22_Filtered = 1 then '' else @HideField end) + ',IsNotify_ShipTo_Email'
	+ char(10) + (case when @Col23_Filtered = 1 then '' else @HideField end) + ',IsNotify_ShipTo_SMS'
	+ char(10) + (case when @Col24_Filtered = 1 then '' else @HideField end) + ',IsNotify_SellTo_Email'
	+ char(10) + (case when @Col25_Filtered = 1 then '' else @HideField end) + ',IsNotify_SellTo_SMS'
	+ char(10) + (case when @Col26_Filtered = 1 then '' else @HideField end) + ',IsNotify_BillTo_Email'
	+ char(10) + (case when @Col27_Filtered = 1 then '' else @HideField end) + ',IsNotify_BillTo_SMS'
	+ char(10) + (case when @Col28_Filtered = 1 then '' else @HideField end) + ',IsRecurring'
	+ char(10) + (case when @Col29_Filtered = 1 then '' else @HideField end) + ',IsPublic'
	+ char(10) + (case when @Col30_Filtered = 1 then '' else @HideField end) + ',IsTrackingAvailable'
	+ char(10) + (case when @Col31_Filtered = 1 then '' else @HideField end) + ',IsActive = e.IsActive
	FROM [MSPL_DB].[dbo].[T_Events_List] e WITH (NOLOCK)
	INNER JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] a_mtv WITH (NOLOCK) ON e.Activity_MTV_ID = a_mtv.MTV_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_List_By_ID_2]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_List_By_ID_2] 111
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_List_By_ID_2]
	-- Add the parameters for the stored procedure here
	@MT_ID int
	,@Username nvarchar(150) = null
AS
BEGIN
	
	select MT_ID,[Name],MTV_ID,MTV_CODE,SubName,Sort_ from [MSPL_DB].[dbo].[F_Get_List_By_ID_2] (@MT_ID,@Username) order by Sort_

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Master_Setup_DropDown_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			exec [P_Get_Master_Setup_DropDown_Lists] 'HAMMAS.KHAN'
CREATE PROCEDURE [dbo].[P_Get_Master_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	select [value] = MT_ID, [text]= [Name] from [MSPL_DB].[dbo].[T_Master_Type] with (nolock) order by [Name]

	select [value] = MTV_ID , [text]= Name from [MSPL_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE IsActive = 1 order by [Name]
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_MasterType_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--	Declare @TotalCount int = 0 exec [dbo].[P_Get_MasterType_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_MasterType_List] 
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
	FROM [MSPL_DB].[dbo].[T_Master_Type] mt with (nolock)'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_MasterTypeValue_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_MasterTypeValue_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_MasterTypeValue_List] 
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
	+ char(10) + (case when @Sub_MTV_ID_Filtered = 1 then '' else @HideField end) + ',Sub_MTV_Name = (case when mtv.Sub_MTV_ID = 0 then '''' else (select top 1 m.[Name] from [MSPL_DB].[dbo].[T_Master_Type_Value] m with (nolock) where m.MTV_ID = mtv.Sub_MTV_ID) end)'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = mtv.IsActive
	FROM [MSPL_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) 
	INNER JOIN [MSPL_DB].[dbo].[T_Master_Type] mt with (nolock) ON mtv.MT_ID = mt.MT_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Page_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Page_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_Page_List]
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
	FROM [MSPL_DB].[dbo].[T_Page] p with (nolock)
	INNER JOIN [MSPL_DB].[dbo].[T_Page_Group] pg with (nolock) ON p.PG_ID = pg.PG_ID
	INNER JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) ON p.Application_MTV_ID = mtv.MTV_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Page_Rights]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Page_Rights] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount


CREATE PROCEDURE [dbo].[P_Get_Page_Rights]
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
	FROM [MSPL_DB].[dbo].[T_Page_Rights] pr with (nolock) where IsActive = 1'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Page_Rights_Struct_Class]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_Page_Rights_Struct_Class] '2024-03-22','2024-03-22',null,0,0
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Page_Rights_Struct_Class]
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
	from [MSPL_DB].[dbo].[T_Page_Rights] pr with (nolock) 
	inner join [MSPL_DB].[dbo].[T_Page] p with (nolock) on pr.P_ID = p.P_ID
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
/****** Object:  StoredProcedure [dbo].[P_Get_Page_Setup_DropDown_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[P_Get_Page_Setup_DropDown_Lists]
	@Username nvarchar(150)

AS
BEGIN
	
	select [value] = PG_ID, [text]= PageGroupName from [MSPL_DB].[dbo].[T_Page_Group] with (nolock) order by PageGroupName

	select [value] = P_ID, [text]= PageName from [MSPL_DB].[dbo].[T_Page] with (nolock) order by PageName

	SELECT [value] = [MTV_ID] ,[text]= [Name] FROM [MSPL_DB].[dbo].[T_Master_Type_Value] with (nolock) where MT_ID = 148 order by [Name]
END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_PageChart_Dropdown_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_Get_PageChart_Dropdown_Lists]
	
AS
BEGIN
	
	SELECT code = MTV_CODE, [name] = SubName FROM [MSPL_DB].[dbo].[F_Get_List_By_ID_2] (148, null) ORDER BY Sort_
	SELECT code = R_ID, [name] = RoleName FROM [MSPL_DB].[dbo].[T_Roles] WITH (NOLOCK) WHERE IsActive = 1
	SELECT code = USERNAME, [name] = LOWER(USERNAME) FROM [MSPL_DB].[dbo].[T_Users] WITH (NOLOCK) WHERE IsActive = 1 

END

 
GO
/****** Object:  StoredProcedure [dbo].[P_Get_PageChart_Json]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--		exec [dbo].[P_Get_PageChart_Json]

CREATE PROCEDURE [dbo].[P_Get_PageChart_Json]
	@RoleID int = null,
	@ApplicationID int = null
AS
BEGIN
	
	Declare @Json nvarchar(max) = ''
	select @Json = [MSPL_DB].[dbo].[F_Get_PageChart_Json] (@RoleID,@ApplicationID)
	select @Json as [Json]

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_PageGroup_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_PageGroup_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '[]', '[{"Code":"RowNo","Name":"#","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"PG_ID","Name":"Page ID","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"PageGroupName","Name":"Page Group Name","IsColumnRequired":false,"IsHidden":false,"IsChecked":false},{"Code":"Sort_","Name":"Sort_","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"IsHide","Name":"IsHide","IsColumnRequired":true,"IsHidden":false,"IsChecked":false},{"Code":"IsActive","Name":"IsActive","IsColumnRequired":false,"IsHidden":false,"IsChecked":false},{"Code":"Action","Name":"Action","IsColumnRequired":false,"IsHidden":false,"IsChecked":false}]' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_PageGroup_List]
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
	+ char(10) + 'FROM [MSPL_DB].[dbo].[T_Page_Group] pg with (nolock)'
	
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Rights_Setup_DropDown_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[P_Get_Rights_Setup_DropDown_Lists]
	@Username nvarchar(150)
AS
BEGIN
	
	SELECT [value] = R_ID, [text]= RoleName FROM [dbo].[T_Roles] WITH (NOLOCK) ORDER BY RoleName
	SELECT [value] = P_ID, [text]= PageName FROM [dbo].[T_Page] WITH (NOLOCK) ORDER BY PageName
	SELECT [value] = PR_ID, [text]= PageRightName FROM [dbo].[T_Page_Rights] WITH (NOLOCK) ORDER BY PageRightName

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Rights_From_RoleID]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_Role_Rights_From_RoleID] 12,0,0.0,''
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Role_Rights_From_RoleID]
	@ROLE_ID int
	,@IsGroupRoleID bit
	,@P_ID int = 0
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
AS
BEGIN
	
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [MSPL_DB].[dbo].[F_Get_Role_Rights_From_RoleID] (@ROLE_ID ,@IsGroupRoleID ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Rights_From_Username]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Get_Role_Rights_From_Username] 'ABDULLAH.ARSHAD',0.0,''
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Role_Rights_From_Username]
	@Username nvarchar(150)
	,@P_ID int = 0
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''
AS
BEGIN
	
	select PR_ID ,IsRightActive ,PageRightName ,PageRightType_MTV_CODE from [MSPL_DB].[dbo].[F_Get_Role_Rights_From_Username] (@Username ,@P_ID ,@PR_ID ,@PageRightType_MTV_CODE)

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Rights_Json]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [P_Get_Role_Rights_Json] 1
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Role_Rights_Json]
	@RoleID int
AS
BEGIN
	
	Declare @Json nvarchar(max) = ''
	select @Json = [MSPL_DB].[dbo].[F_Get_Role_Rights_Json] (@RoleID)
	select @Json as [Json]

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Role_Setup_DropDown_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[P_Get_Role_Setup_DropDown_Lists]
	@Username nvarchar(150)

AS
BEGIN
	
	SELECT [value] = R_ID, [text]= RoleName FROM [dbo].[T_Roles] WITH (NOLOCK) ORDER BY RoleName
	SELECT [value] = RG_ID, [text]= RoleGroupName FROM [dbo].[T_Role_Group] WITH (NOLOCK) ORDER BY RoleGroupName
	SELECT [value] = D_ID, [text]= DepartmentName FROM [dbo].[T_Department] WITH (NOLOCK) ORDER BY DepartmentName

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_RolePageRightMap_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_RolePageRightMap_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_RolePageRightMap_List] 
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
		FROM [MSPL_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) 
	INNER JOIN [MSPL_DB].[dbo].[T_Roles] r with (nolock) ON rprm.R_ID = r.R_ID
	INNER JOIN [MSPL_DB].[dbo].[T_Page_Rights] pr with (nolock) ON rprm.PR_ID = pr.PR_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Roles_Group_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Roles_Group_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount


CREATE PROCEDURE [dbo].[P_Get_Roles_Group_List]
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
	FROM [MSPL_DB].[dbo].[T_Role_Group] rg with (nolock)'
	
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Roles_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_Roles_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount


CREATE PROCEDURE [dbo].[P_Get_Roles_List]
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
	FROM [MSPL_DB].[dbo].[T_Roles] r with (nolock)'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_RolesGroupMap_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_RolesGroupMap_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount


CREATE PROCEDURE [dbo].[P_Get_RolesGroupMap_List]
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
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
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
	FROM [MSPL_DB].[dbo].[T_Role_Group_Mapping] rgm with (nolock) 
	INNER JOIN [MSPL_DB].[dbo].[T_Role_Group] rg with (nolock) ON rgm.RG_ID = rg.RG_ID 
	INNER JOIN [MSPL_DB].[dbo].[T_Roles] r with (nolock) ON rgm.R_ID = r.R_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_SearchUsersName]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec P_Get_SearchUsersName 'iht'
CREATE PROCEDURE [dbo].[P_Get_SearchUsersName]
    @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT USER_ID, USERNAME
    FROM T_Users  with (nolock)
    WHERE  USERNAME LIKE '%' + @SearchTerm + '%';
END;
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskAssignedToMap_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_TaskAssignedToMap_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_TaskAssignedToMap_List] 
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
	SET @sortExpression = ' TD_ID ASC, TATM_ID asc '  
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
  Declare @Task_Item_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Item') then 1 else 0 end)
  Declare @AssignedTo_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AssignedTo') then 1 else 0 end) 
  Declare @AssignToType_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AssignToType') then 1 else 0 end) 
  Declare @Comment_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Comment') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end) 
  Declare @AddedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedBy') then 1 else 0 end) 
  Declare @AddedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedOn') then 1 else 0 end) 
  Declare @ModifiedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedBy') then 1 else 0 end) 
  Declare @ModifiedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedOn') then 1 else 0 end) 
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Task_Item_Req bit = (case when @Task_Item_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Item') then 0 else 1 end)
  Declare @AssignedTo_Req bit = (case when @AssignedTo_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AssignedTo') then 0 else 1 end)
  Declare @AssignToType_Req bit = (case when @AssignToType_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AssignToType') then 0 else 1 end)
  Declare @Comment_Req bit = (case when @Comment_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Comment') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  Declare @AddedBy_Req bit = (case when @AddedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedBy') then 0 else 1 end)
  Declare @AddedOn_Req bit = (case when @AddedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedOn') then 0 else 1 end)
  Declare @ModifiedBy_Req bit = (case when @ModifiedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedBy') then 0 else 1 end)
  Declare @ModifiedOn_Req bit = (case when @ModifiedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedOn') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  SET @selectSql = N'Select Distinct tatm.TATM_ID, tatm.TD_ID'
    + CHAR(10) + (CASE WHEN @Task_Item_Filtered = 1 THEN '' ELSE @HideField END) + ', td.Task_Item'
    + CHAR(10) + (CASE WHEN @AssignedTo_Filtered = 1 THEN '' ELSE @HideField END) + ', AssignedTo = tatm.AssignedTo'
	+ CHAR(10) + (CASE WHEN @IsActive_Filtered = 1 THEN '' ELSE @HideField END) + ', AssignToType = tatm.AssignToType_MTV_CODE'
	+ CHAR(10) + (CASE WHEN @IsActive_Filtered = 1 THEN '' ELSE @HideField END) + ', Comment = tatm.Comment'
    + CHAR(10) + (CASE WHEN @IsActive_Filtered = 1 THEN '' ELSE @HideField END) + ', IsActive = tatm.IsActive'
	+ CHAR(10) + (CASE WHEN @IsActive_Filtered = 1 THEN '' ELSE @HideField END) + ', AddedBy = tatm.AddedBy'
	+ CHAR(10) + (CASE WHEN @IsActive_Filtered = 1 THEN '' ELSE @HideField END) + ', AddedOn = tatm.AddedOn'
	+ CHAR(10) + (CASE WHEN @IsActive_Filtered = 1 THEN '' ELSE @HideField END) + ', ModifiedBy = tatm.ModifiedBy'
	+ CHAR(10) + (CASE WHEN @IsActive_Filtered = 1 THEN '' ELSE @HideField END) + ', ModifiedOn = tatm.ModifiedOn
FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tatm WITH (NOLOCK) 
INNER JOIN [MSPL_DB].[dbo].[T_TMS_TaskDetail] td WITH (NOLOCK) ON tatm.TD_ID = td.TD_ID'
	
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END

 
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskComments_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_TaskComments_List] 'Ihtisham', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_TaskComments_List] 
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
	SET @sortExpression = ' TC_ID ASC '  
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
  Declare @Task_Item_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Item') then 1 else 0 end)
  Declare @CommentText_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CommentText') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end) 
  Declare @Application_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application') then 1 else 0 end)  
  Declare @TaskName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskName') then 1 else 0 end)  
  Declare @Application_URL_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application_URL') then 1 else 0 end)  
  Declare @Task_Start_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Start_Date') then 1 else 0 end)    
  Declare @Task_End_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_End_Date') then 1 else 0 end)    
  Declare @Status_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Status') then 1 else 0 end)  
  Declare @Priority_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Priority') then 1 else 0 end)  
  Declare @BUILDCODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'BUILDCODE') then 1 else 0 end)  
  Declare @TaskCategory_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskCategory') then 1 else 0 end)  
  Declare @IsPrivate_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsPrivate') then 1 else 0 end)  
  Declare @Review_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Review_Date') then 1 else 0 end)  
  Declare @ETA_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ETA_Date') then 1 else 0 end) 
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Task_Item_Req bit = (case when @Task_Item_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Item') then 0 else 1 end)
  Declare @CommentText_Req bit = (case when @CommentText_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CommentText') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  Declare @Application_Req bit = (case when @Application_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application') then 0 else 1 end)
  Declare @TaskName_Req bit = (case when @TaskName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskName') then 0 else 1 end)
  Declare @Application_URL_Req bit = (case when @Application_URL_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application_URL') then 0 else 1 end)
  Declare @Task_Start_Date_Req bit = (case when @Task_Start_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Start_Date') then 0 else 1 end)
  Declare @Task_End_Date_Req bit = (case when @Task_End_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_End_Date') then 0 else 1 end)
  Declare @Status_Req bit = (case when @Status_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Status') then 0 else 1 end)
  Declare @Priority_Req bit = (case when @Priority_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Priority') then 0 else 1 end)
  Declare @BUILDCODE_Req bit = (case when @BUILDCODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'BUILDCODE') then 0 else 1 end)
  Declare @TaskCategory_Req bit = (case when @TaskCategory_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskCategory') then 0 else 1 end)
  Declare @IsPrivate_Req bit = (case when @IsPrivate_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsPrivate') then 0 else 1 end)
  Declare @Review_Date_Req bit = (case when @Review_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Review_Date') then 0 else 1 end)
  Declare @ETA_Date_Req bit = (case when @ETA_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ETA_Date') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT TC_ID, tc.TD_ID,tc.Status_MTV_ID,tc.Priority_MTV_ID,tc.TaskCategory_MTV_ID,Application_ID=t.Application_MTV_ID,p.P_ID'
    + char(10) + (case when @Task_Item_Filtered = 1 then '' else @HideField end) + ',td.Task_Item'
    + char(10) + (case when @CommentText_Filtered = 1 then '' else @HideField end) + ',tc.CommentText'
    + char(10) + (case when @Application_Filtered = 1 then '' else @HideField end) + ',Application=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](t.Application_MTV_ID)'
    + char(10) + (case when @TaskName_Filtered = 1 then '' else @HideField end) + ',t.TaskName'
    + char(10) + (case when @Application_URL_Filtered = 1 then '' else @HideField end) + ',Application_URL=p.PageName'
    + char(10) + (case when @Task_Start_Date_Filtered = 1 then '' else @HideField end) + ',tc.Task_Start_Date'
    + char(10) + (case when @Task_End_Date_Filtered = 1 then '' else @HideField end) + ',tc.Task_End_Date'
    + char(10) + (case when @Status_Filtered = 1 then '' else @HideField end) + ',Status=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](tc.Status_MTV_ID)'
    + char(10) + (case when @Priority_Filtered = 1 then '' else @HideField end) + ',Priority=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](tc.Priority_MTV_ID)'
    + char(10) + (case when @BUILDCODE_Filtered = 1 then '' else @HideField end) + ',BUILDCODE=tc.BUILDCODE'
    + char(10) + (case when @TaskCategory_Filtered = 1 then '' else @HideField end) + ',TaskCategory=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](tc.TaskCategory_MTV_ID)'
    + char(10) + (case when @IsPrivate_Filtered = 1 then '' else @HideField end) + ',tc.IsPrivate'
    + char(10) + (case when @Review_Date_Filtered = 1 then '' else @HideField end) + ',Review_Date = tc.Review_Date'
    + char(10) + (case when @ETA_Date_Filtered = 1 then '' else @HideField end) + ',ETA_Date = tc.ETA_Date'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = tc.IsActive
    FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] tc WITH (NOLOCK) 
    INNER JOIN [MSPL_DB].[dbo].[T_TMS_TaskDetail] td WITH (NOLOCK) ON tc.TD_ID = td.TD_ID
    INNER JOIN [MSPL_DB].[dbo].[T_TMS_Tasks]  t WITH (NOLOCK) ON td.T_ID = t.T_ID
	left Join [MSPL_DB].[dbo].[T_Page] p  WITH (NOLOCK) ON tc.Application_URL = p.P_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskCommentsForDetailGrid_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from  T_TMS_TaskComments
--	Declare @TotalCount int = 0 exec [dbo].[P_Get_TaskCommentsForDetailGrid_List] 'Ihtisham',9, 0, 30, '', '', @TotalCount out, 18000000, '', ''select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_TaskCommentsForDetailGrid_List] 
	-- Add the parameters for the stored procedure here
	 @Username nvarchar(150),
	 @TD_TD int,
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
	SET @sortExpression = ' TC_ID ASC '  
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
  Declare @Task_Item_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Item') then 1 else 0 end)
  Declare @CommentText_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'CommentText') then 1 else 0 end) 
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end) 
  Declare @Application_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application') then 1 else 0 end)  
  Declare @TaskName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskName') then 1 else 0 end)  
  Declare @Application_URL_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application_URL') then 1 else 0 end)  
  Declare @Task_Start_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Start_Date') then 1 else 0 end)    
  Declare @Task_End_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_End_Date') then 1 else 0 end)    
  Declare @Status_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Status') then 1 else 0 end)  
  Declare @Priority_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Priority') then 1 else 0 end)  
  Declare @BUILDCODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'BUILDCODE') then 1 else 0 end)  
  Declare @TaskCategory_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskCategory') then 1 else 0 end)  
  Declare @IsPrivate_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsPrivate') then 1 else 0 end)  
  Declare @Review_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Review_Date') then 1 else 0 end)  
  Declare @ETA_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ETA_Date') then 1 else 0 end) 
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Task_Item_Req bit = (case when @Task_Item_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Item') then 0 else 1 end)
  Declare @CommentText_Req bit = (case when @CommentText_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'CommentText') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  Declare @Application_Req bit = (case when @Application_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application') then 0 else 1 end)
  Declare @TaskName_Req bit = (case when @TaskName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskName') then 0 else 1 end)
  Declare @Application_URL_Req bit = (case when @Application_URL_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application_URL') then 0 else 1 end)
  Declare @Task_Start_Date_Req bit = (case when @Task_Start_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Start_Date') then 0 else 1 end)
  Declare @Task_End_Date_Req bit = (case when @Task_End_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_End_Date') then 0 else 1 end)
  Declare @Status_Req bit = (case when @Status_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Status') then 0 else 1 end)
  Declare @Priority_Req bit = (case when @Priority_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Priority') then 0 else 1 end)
  Declare @BUILDCODE_Req bit = (case when @BUILDCODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'BUILDCODE') then 0 else 1 end)
  Declare @TaskCategory_Req bit = (case when @TaskCategory_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskCategory') then 0 else 1 end)
  Declare @IsPrivate_Req bit = (case when @IsPrivate_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsPrivate') then 0 else 1 end)
  Declare @Review_Date_Req bit = (case when @Review_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Review_Date') then 0 else 1 end)
  Declare @ETA_Date_Req bit = (case when @ETA_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ETA_Date') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT TC_ID, tc.TD_ID,tc.Status_MTV_ID ,tc.Priority_MTV_ID,Application_ID=t.Application_MTV_ID,p.P_ID,tc.TaskCategory_MTV_ID'
    + char(10) + (case when @Task_Item_Filtered = 1 then '' else @HideField end) + ',td.Task_Item'
    + char(10) + (case when @CommentText_Filtered = 1 then '' else @HideField end) + ',tc.CommentText'
    + char(10) + (case when @Application_Filtered = 1 then '' else @HideField end) + ',Application=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (t.Application_MTV_ID)'
    + char(10) + (case when @TaskName_Filtered = 1 then '' else @HideField end) + ',t.TaskName'
    + char(10) + (case when @Application_URL_Filtered = 1 then '' else @HideField end) + ',Application_URL=p.PageName'
    + char(10) + (case when @Task_Start_Date_Filtered = 1 then '' else @HideField end) + ',tc.Task_Start_Date'
    + char(10) + (case when @Task_End_Date_Filtered = 1 then '' else @HideField end) + ',tc.Task_End_Date'
    + char(10) + (case when @Status_Filtered = 1 then '' else @HideField end) + ',Status=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](tc.Status_MTV_ID)'
    + char(10) + (case when @Priority_Filtered = 1 then '' else @HideField end) + ',Priority=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](tc.Priority_MTV_ID)'
    + char(10) + (case when @BUILDCODE_Filtered = 1 then '' else @HideField end) + ',BUILDCODE=tc.BUILDCODE'
    + char(10) + (case when @TaskCategory_Filtered = 1 then '' else @HideField end) + ',TaskCategory=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](tc.TaskCategory_MTV_ID)'
    + char(10) + (case when @IsPrivate_Filtered = 1 then '' else @HideField end) + ',tc.IsPrivate'
    + char(10) + (case when @Review_Date_Filtered = 1 then '' else @HideField end) + ',Review_Date = tc.Review_Date'
    + char(10) + (case when @ETA_Date_Filtered = 1 then '' else @HideField end) + ',ETA_Date = tc.ETA_Date'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = tc.IsActive
    FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] tc WITH (NOLOCK) 
    INNER JOIN [MSPL_DB].[dbo].[T_TMS_TaskDetail] td WITH (NOLOCK) ON tc.TD_ID = td.TD_ID
    INNER JOIN [MSPL_DB].[dbo].[T_TMS_Tasks]  t WITH (NOLOCK) ON td.T_ID = t.T_ID
	left Join [MSPL_DB].[dbo].[T_Page] p  WITH (NOLOCK) ON tc.Application_URL = p.P_ID
    where tc.TD_ID=' + cast(@TD_TD as nvarchar(20)); 

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskDetail_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
--	Declare @TotalCount int = 0 exec [dbo].[P_Get_TaskDetail_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_TaskDetail_List] 
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
	SET @sortExpression = ' TD_ID DESC '  
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
  Declare @TaskName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskName') then 1 else 0 end)
  Declare @Task_Item_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Item') then 1 else 0 end) 
  Declare @Task_Item_Detail_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Item_Detail') then 1 else 0 end)  
  Declare @Application_URL_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application_URL') then 1 else 0 end)  
  Declare @Task_Start_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_Start_Date') then 1 else 0 end)    
  Declare @Task_End_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Task_End_Date') then 1 else 0 end)    
  Declare @Status_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Status') then 1 else 0 end)  
  Declare @Priority_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Priority') then 1 else 0 end)  
  Declare @BUILDCODE_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'BUILDCODE') then 1 else 0 end)  
  Declare @TaskCategory_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskCategory') then 1 else 0 end)  
  Declare @IsPrivate_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsPrivate') then 1 else 0 end)  
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  Declare @Review_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Review_Date') then 1 else 0 end)  
  Declare @ETA_Date_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ETA_Date') then 1 else 0 end) 
  Declare @LeadAssignTo_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'LeadAssignTo') then 1 else 0 end) 
  Declare @AssignToUsers_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AssignToUsers') then 1 else 0 end) 
  Declare @AddedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedBy') then 1 else 0 end) 
  Declare @AddedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedOn') then 1 else 0 end) 
  Declare @ModifiedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedBy') then 1 else 0 end) 
  Declare @ModifiedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedOn') then 1 else 0 end)
  Declare @Application_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application') then 1 else 0 end) 
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @TaskName_Req bit = (case when @TaskName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskName') then 0 else 1 end)
  Declare @Task_Item_Req bit = (case when @Task_Item_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Item') then 0 else 1 end)
  Declare @Task_Item_Detail_Req bit = (case when @Task_Item_Detail_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Item_Detail') then 0 else 1 end)
  Declare @Application_URL_Req bit = (case when @Application_URL_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application_URL') then 0 else 1 end)
  Declare @Task_Start_Date_Req bit = (case when @Task_Start_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_Start_Date') then 0 else 1 end)
  Declare @Task_End_Date_Req bit = (case when @Task_End_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Task_End_Date') then 0 else 1 end)
  Declare @Status_Req bit = (case when @Status_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Status') then 0 else 1 end)
  Declare @Priority_Req bit = (case when @Priority_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Priority') then 0 else 1 end)
  Declare @BUILDCODE_Req bit = (case when @BUILDCODE_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'BUILDCODE') then 0 else 1 end)
  Declare @TaskCategory_Req bit = (case when @TaskCategory_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskCategory') then 0 else 1 end)
  Declare @IsPrivate_Req bit = (case when @IsPrivate_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsPrivate') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  Declare @Review_Date_Req bit = (case when @Review_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Review_Date') then 0 else 1 end)
  Declare @ETA_Date_Req bit = (case when @ETA_Date_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ETA_Date') then 0 else 1 end)
  Declare @LeadAssignTo_Req bit = (case when @LeadAssignTo_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'LeadAssignTo') then 0 else 1 end)
  Declare @AssignToUsers_Req bit = (case when @AssignToUsers_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AssignToUsers') then 0 else 1 end)
  Declare @AddedBy_Req bit = (case when @AddedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedBy') then 0 else 1 end)
  Declare @AddedOn_Req bit = (case when @AddedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedOn') then 0 else 1 end)
  Declare @ModifiedBy_Req bit = (case when @ModifiedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedBy') then 0 else 1 end)
  Declare @ModifiedOn_Req bit = (case when @ModifiedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedOn') then 0 else 1 end)
  Declare @Application_Req bit = (case when @Application_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT TD_ID, td.T_ID, td.Status_MTV_ID, td.Priority_MTV_ID, Application_ID=t.Application_MTV_ID,p.P_ID,td.TaskCategory_MTV_ID'
    + char(10) + (case when @Application_Filtered = 1 then '' else @HideField end) + ',Application=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](t.Application_MTV_ID)'
	+ char(10) + (case when @TaskName_Filtered = 1 then '' else @HideField end) + ',t.TaskName'
	+ char(10) + (case when @Task_Item_Filtered = 1 then '' else @HideField end) + ',Task_Item'
	+ char(10) + (case when @Task_Item_Detail_Filtered = 1 then '' else @HideField end) + ',Task_Item_Detail'
	+ char(10) + (case when @Application_URL_Filtered = 1 then '' else @HideField end) + ',Application_URL=p.PageName'
	+ char(10) + (case when @Task_Start_Date_Filtered = 1 then '' else @HideField end) + ',Task_Start_Date'
	+ char(10) + (case when @Task_End_Date_Filtered = 1 then '' else @HideField end) + ',Task_End_Date'
	+ char(10) + (case when @Status_Filtered = 1 then '' else @HideField end) + ',Status=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](td.Status_MTV_ID)'
	+ char(10) + (case when @Priority_Filtered = 1 then '' else @HideField end) + ',Priority=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](td.Priority_MTV_ID)'
	+ char(10) + (case when @BUILDCODE_Filtered = 1 then '' else @HideField end) + ',BUILDCODE=td.BUILDCODE'
	+ char(10) + (case when @TaskCategory_Filtered = 1 then '' else @HideField end) + ',TaskCategory=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID](td.TaskCategory_MTV_ID)'
	+ char(10) + (case when @IsPrivate_Filtered = 1 then '' else @HideField end) + ',IsPrivate'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = td.IsActive'
	+ char(10) + (case when @Review_Date_Filtered = 1 then '' else @HideField end) + ',Review_Date = td.Review_Date'
	+ char(10) + (case when @ETA_Date_Filtered = 1 then '' else @HideField end) + ',ETA_Date = td.ETA_Date'
	+ char(10) + (case when @LeadAssignTo_Filtered = 1 then '' else @HideField end) + ',LeadAssignTo = td.LeadAssignTo'
	+ char(10) + (case when @AssignToUsers_Filtered = 1 then '' else @HideField end) + ',AssignToUsers = [MSPL_DB].[dbo].[F_GetAssignedTo] (td.TD_ID)'
	+ char(10) + (case when @AddedBy_Filtered = 1 then '' else @HideField end) + ',AddedBy = td.AddedBy'
	+ char(10) + (case when @AddedOn_Filtered = 1 then '' else @HideField end) + ',AddedOn = td.AddedOn'
	+ char(10) + (case when @ModifiedBy_Filtered = 1 then '' else @HideField end) + ',ModifiedBy = td.ModifiedBy'
	+ char(10) + (case when @ModifiedOn_Filtered = 1 then '' else @HideField end) + ',ModifiedOn = td.ModifiedOn
	FROM [MSPL_DB].[dbo].[T_TMS_TaskDetail] td WITH (NOLOCK) 
	INNER JOIN [MSPL_DB].[dbo].[T_TMS_Tasks] t WITH (NOLOCK) ON td.T_ID = t.T_ID
	left Join [MSPL_DB].[dbo].[T_Page] p  WITH (NOLOCK) ON td.Application_URL = p.P_ID'
	
	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END

 
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskManagementSetup_Dropdown_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_Get_TaskManagementSetup_Dropdown_Lists]
	
AS
BEGIN
	-- Application
	SELECT code = MTV_CODE, [name] = SubName FROM [MSPL_DB].[dbo].[F_Get_List_By_ID_2] (148,NULL) ORDER BY Sort_
	-- Category
	SELECT code = MTV_CODE, [name] = SubName FROM [MSPL_DB].[dbo].[F_Get_List_By_ID_2] (177,NULL) ORDER BY Sort_
	-- Status
	SELECT code = MTV_CODE, [name] = SubName FROM [MSPL_DB].[dbo].[F_Get_List_By_ID_2] (175,NULL) ORDER BY Sort_
	-- Priority
	SELECT code = MTV_CODE, [name] = SubName FROM [MSPL_DB].[dbo].[F_Get_List_By_ID_2] (176,NULL) ORDER BY Sort_
	-- Memebers
	SELECT code = USERNAME, [name] = lower(USERNAME) FROM [MSPL_DB].[dbo].[T_Users] WITH (NOLOCK) WHERE IsActive = 1 AND [USER_ID] IN (9114,9119,9124,9127,8550,8019,8551)

	--Application Url
	 SELECT code = P_ID, [name] = PageName FROM [MSPL_DB].[dbo].[T_Page] WITH (NOLOCK) WHERE IsActive = 1

	 --Task Category
	 SELECT code = MTV_CODE, [name] = SubName FROM [MSPL_DB].[dbo].[F_Get_List_By_ID_2] (177,NULL) ORDER BY Sort_
END

 
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskManagementSystem_JSON]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec P_Get_TaskManagementSystem_JSON 48,63

CREATE PROCEDURE [dbo].[P_Get_TaskManagementSystem_JSON]
(
    @T_ID INT,
    @TD_TD INT
)
AS
BEGIN
    DECLARE @Return_Json NVARCHAR(MAX)

    SELECT @Return_Json = (
        SELECT  
            t.T_ID,
            t.TaskName,
            t.Note,
            Application_ID=t.Application_MTV_ID,
            (
                SELECT 
                    td.TD_ID,
                    td.T_ID AS Task_ID,
                    td.Task_Item AS Item,
                    td.Task_Item_Detail AS Item_Detail,
                    td.Application_URL,
                    td.Task_Start_Date,
                    td.Task_End_Date,
                    Priority_MTV_Code = td.Priority_MTV_ID,
                    Status_MTV_Code = td.Status_MTV_ID,
                    BUILDCODE = td.BUILDCODE,
                    TaskCategory = td.TaskCategory_MTV_ID,
					Review_Date=td.Review_Date,
					ETA_Date=td.ETA_Date,
					LeadAssignTo=td.LeadAssignTo,
                    td.IsPrivate,
                    td.IsActive,
                    (
                        SELECT 
                            ta.TA_ID,
							[path] = ta.[Path],
                            REFID2 = ta.REFID2,
                            ta.[FileName],
                            ta.FileExt,
							DocumentType_MTV_ID=ta.DocumentType_MTV_ID,
							AttachmentType_MTV_ID=ta.AttachmentType_MTV_ID
                        FROM [MSPL_DB].[dbo].[T_TMS_TaskAttachments] ta
                        WHERE ta.AttachmentType_MTV_ID = 179100 AND ta.REFID2 = @TD_TD AND ta.IsActive = 1
                        FOR JSON PATH
                    ) AS Attachments
                FROM [T_TMS_TaskDetail] td
                WHERE td.TD_ID = @TD_TD AND td.IsActive = 1
                FOR JSON PATH
            ) AS TaskItems
        FROM [MSPL_DB].[dbo].[T_TMS_Tasks] t
        WHERE t.T_ID = @T_ID AND t.IsActive = 1
        FOR JSON PATH,WITHOUT_ARRAY_WRAPPER 
    );

    IF @Return_Json IS NULL
        SET @Return_Json = ''

    SELECT @Return_Json AS Return_Json -- Return the JSON as a result set instead of using RETURN statement
END;
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TaskManagementSystem_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--			Declare @TotalCount int = 0 EXEC [dbo].[P_Get_TaskManagementSystem_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_TaskManagementSystem_List]
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
	SET @sortExpression = ' T_ID asc '  
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
  --Declare @Application_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Application') then 1 else 0 end)
  --Declare @TaskName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskName') then 1 else 0 end) 
  --Declare @Status_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Status') then 1 else 0 end)
  --Declare @Priority_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Priority') then 1 else 0 end)
  --Declare @TotalMemebers_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalMemebers') then 1 else 0 end)
  --Declare @TotalAttachments_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalAttachments') then 1 else 0 end)
  --Declare @TotalComments_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TotalComments') then 1 else 0 end)
  --Declare @ETA_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ETA') then 1 else 0 end)
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  --Declare @Application_Req bit = (case when @Application_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Application') then 0 else 1 end)
  --Declare @TaskName_Req bit = (case when @TaskName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskName') then 0 else 1 end)
  --Declare @Status_Req bit = (case when @Status_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Status') then 0 else 1 end)
  --Declare @Priority_Req bit = (case when @Priority_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Priority') then 0 else 1 end)
  --Declare @TotalMemebers_Req bit = (case when @TotalMemebers_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalMemebers') then 0 else 1 end)
  --Declare @TotalAttachments_Req bit = (case when @TotalAttachments_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalAttachments') then 0 else 1 end)
  --Declare @TotalComments_Req bit = (case when @TotalComments_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TotalComments') then 0 else 1 end)
  --Declare @ETA_Req bit = (case when @ETA_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ETA') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
   
	set @selectSql = N'SELECT t.Application_MTV_ID, t.T_ID, td.TD_ID, td.Status_MTV_ID, td.Priority_MTV_ID, 
	[Application] = mtv_a.[Name], t.TaskName, td.Task_Item, [Status] = mtv_s.[Name], [Priority] = mtv_p.[Name], td.IsActive
	,TotalMemebers = isnull((SELECT count(TATM_ID) FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tatm WITH (NOLOCK) WHERE IsActive = 1 and tatm.TD_ID = td.TD_ID),0)
	,TotalAttachments = isnull((SELECT count(TA_ID) FROM [MSPL_DB].[dbo].[T_TMS_TaskAttachments] ta WITH (NOLOCK) WHERE IsActive = 1 and ta.REFID2 = td.TD_ID),0)
	,TotalComments = isnull((SELECT count(TC_ID) FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] tc WITH (NOLOCK) WHERE IsActive = 1 and tc.TD_ID = td.TD_ID),0)
	,Task_Start_Date
	,Task_End_Date
	,AddedOn=cast(td.AddedOn as date)
	,ETA_Date
	,ETA=(case when ETA_Date is null then '''' else (CASE WHEN DATEDIFF(MONTH, Task_Start_Date, ETA_Date) > 0 
		THEN CAST(DATEDIFF(MONTH, Task_Start_Date, ETA_Date) AS nvarchar(50)) + '' Month'' 
		ELSE CAST(DATEDIFF(DAY, Task_Start_Date, ETA_Date) AS nvarchar(50)) + '' Days'' END) end)
	,LeftDays=(case when ETA_Date is null then 0 else (CASE WHEN GETDATE() > ETA_Date THEN 0 ELSE DATEDIFF(DAY, GETDATE(), ETA_Date) END) end)
	FROM [MSPL_DB].[dbo].[T_TMS_Tasks] t WITH (NOLOCK)
	INNER JOIN [MSPL_DB].[dbo].[T_TMS_TaskDetail] td WITH (NOLOCK) ON td.T_ID = t.T_ID
	LEFT JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] mtv_a WITH (NOLOCK) ON t.Application_MTV_ID = mtv_a.MTV_ID
	LEFT JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] mtv_s WITH (NOLOCK) ON td.Status_MTV_ID = mtv_s.MTV_ID
	LEFT JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] mtv_p WITH (NOLOCK) ON td.Priority_MTV_ID = mtv_p.MTV_ID
	WHERE td.IsActive = 1'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Tasks_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_Tasks_List] 'HAMMAS.KHAN', 0, 30, '', '', @TotalCount out, -14400000, 13, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_Tasks_List] 
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
	SET @sortExpression = ' T_ID DESC '  
	ELSE
	begin
		SET @sortExpression = replace(@sortExpression,'AddedOn','UTCAddedOn')
		SET @sortExpression = replace(@sortExpression,'ModifiedOn','UTCModifiedOn')
		SET @sortExpression = @sortExpression + ' '
	end
	DROP TABLE IF exists #Table_Fields_Filter
	Create TABLE #Table_Fields_Filter (code nvarchar(150) ,name_ nvarchar(150) ,isfilterapplied bit)
	INSERT INTO #Table_Fields_Filter
	SELECT [Code],[Name],[IsFilterApplied] from [dbo].[F_Get_Table_Fields_Filter] (@filterobject)

	DROP TABLE IF exists #Table_Fields_Column
	CREATE TABLE #Table_Fields_Column (code nvarchar(150) ,name_ nvarchar(150) ,iscolumnrequired bit)
	INSERT INTO #Table_Fields_Column
	SELECT [Code],[Name],[IsColumnRequired] FROM [dbo].[F_Get_Table_Fields_Column] (@columnobject)

	Declare @TimeZoneAbbr nvarchar(10) = ''
	Declare @TimeZoneName nvarchar(50) = ''
	Select @TimeZoneAbbr = TimeZoneAbbreviation, @TimeZoneName = TimeZoneName from [MSPL_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) where TIMEZONE_ID = @TimeZoneID

	Declare @HideField nvarchar(50) = ',hidefield=0'

   ---- Start Set Filter Variables
  Declare @Applicaiton_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Applicaiton') then 1 else 0 end)
  Declare @TaskName_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'TaskName') then 1 else 0 end) 
  Declare @Note_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'Note') then 1 else 0 end)    
  Declare @IsActive_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'IsActive') then 1 else 0 end)  
  Declare @AddedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedBy') then 1 else 0 end)  
  Declare @AddedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'AddedOn') then 1 else 0 end)  
  Declare @UTCAddedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UTCAddedOn') then 1 else 0 end)  
  Declare @ModifiedBy_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedBy') then 1 else 0 end)  
  Declare @ModifiedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'ModifiedOn') then 1 else 0 end)  
  Declare @UTCModifiedOn_Filtered bit = (case when exists(select code from #Table_Fields_Filter where isfilterapplied = 1 and code = 'UTCModifiedOn') then 1 else 0 end)  
  ---- End Set Filter Variables

  ---- Start Set Column Required Variables
  Declare @Applicaiton_Req bit = (case when @Applicaiton_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Applicaiton') then 0 else 1 end)
  Declare @TaskName_Req bit = (case when @TaskName_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'TaskName') then 0 else 1 end)
  Declare @Note_Req bit = (case when @Note_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'Note') then 0 else 1 end)
  Declare @IsActive_Req bit = (case when @IsActive_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'IsActive') then 0 else 1 end)
  Declare @AddedBy_Req bit = (case when @AddedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedBy') then 0 else 1 end)
  Declare @AddedOn_Req bit = (case when @AddedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'AddedOn') then 0 else 1 end)
  Declare @UTCAddedOn_Req bit = (case when @UTCAddedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UTCAddedOn') then 0 else 1 end)
  Declare @ModifiedBy_Req bit = (case when @ModifiedBy_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedBy') then 0 else 1 end)
  Declare @ModifiedOn_Req bit = (case when @ModifiedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'ModifiedOn') then 0 else 1 end)
  Declare @UTCModifiedOn_Req bit = (case when @UTCModifiedOn_Filtered = 0 and exists(select code from #Table_Fields_Column where iscolumnrequired = 0 and code = 'UTCModifiedOn') then 0 else 1 end)
  ---- End Set Column Required Variables

  Declare @selectSql nvarchar(max);  
  set @selectSql = N'SELECT T_ID, Application_ID=t.Application_MTV_ID'
	+ char(10) + (case when @Applicaiton_Filtered = 1 then '' else @HideField end) + ',Applicaiton=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (t.Application_MTV_ID)'
	+ char(10) + (case when @TaskName_Filtered = 1 then '' else @HideField end) + ',TaskName'
	+ char(10) + (case when @Note_Filtered = 1 then '' else @HideField end) + ',Note'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = t.IsActive'
	+ char(10) + (case when @AddedBy_Filtered = 1 then '' else @HideField end) + ',AddedBy = t.AddedBy'
	+ char(10) + (case when @AddedOn_Filtered = 1 then '' else @HideField end) + ',AddedOn = [MSPL_DB].[dbo].[F_Get_DateTime_From_UTC] (t.AddedOn, ' + cast(@TimeZoneID as nvarchar(20)) + ',null,''' + @TimeZoneName + ''')'
	+ char(10) + (case when @UTCAddedOn_Filtered = 1 then '' else @HideField end) + ',UTCAddedOn = t.AddedOn'
	+ char(10) + (case when @ModifiedBy_Filtered = 1 then '' else @HideField end) + ',ModifiedBy = t.ModifiedBy'
	+ char(10) + (case when @AddedOn_Filtered = 1 then '' else @HideField end) + ',ModifiedOn = [MSPL_DB].[dbo].[F_Get_DateTime_From_UTC] (t.ModifiedOn, ' + cast(@TimeZoneID as nvarchar(20)) + ',null,''' + @TimeZoneName + ''')'
	+ char(10) + (case when @UTCModifiedOn_Filtered = 1 then '' else @HideField end) + ',UTCModifiedOn = t.ModifiedOn'
	+ char(10) + ',TimeZoneAbbr = ''' + @TimeZoneAbbr + '''
	FROM [MSPL_DB].[dbo].[T_TMS_Tasks] t WITH (NOLOCK) where t.IsActive = 1'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TMS_Attachment_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--		EXEC [P_Get_TMS_Attachment_List] 9

CREATE PROCEDURE [dbo].[P_Get_TMS_Attachment_List]
    @TD_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  
	 
	  
	 ta.TA_ID
	,ta.OriginalFileName
	,ta.[FileName]
	,ta.FileExt
	,ta.[Path]
	,ta.REFID2
	From [MSPL_DB].[dbo].[T_TMS_TaskAttachments] ta  WITH (NOLOCK) 
	WHERE 	 
	ta.IsActive = 1 
	AND ta.REFID2 = @TD_ID
	
END;
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TMS_Comments_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--		EXEC [P_Get_TMS_Comments_List] 1, 'HAMMAS.KHAN'

CREATE PROCEDURE [dbo].[P_Get_TMS_Comments_List]
    @TD_ID INT,
	@Username nvarchar(150)
AS
BEGIN
    SET NOCOUNT ON;
	    
	SELECT 
		TC_ID, 
		TD_ID, 
		CommentBy = CONCAT(u.FirstName,' ',u.LastName), 
		ShortCommentBy = CONCAT(LEFT(u.FirstName,1),'',LEFT(u.LastName,1)), 
		CommentOn = FORMAT(tc.AddedOn,'dd-MMM-yy HH:mm:ss tt'),
		CommentAgo =
    CASE 
        WHEN DATEDIFF(SECOND, tc.AddedOn, GETUTCDate()) < 60 THEN 'Just Now'
        WHEN DATEDIFF(MINUTE, tc.AddedOn, GETUTCDate()) < 60 THEN CAST(DATEDIFF(MINUTE, tc.AddedOn, GETUTCDate()) AS NVARCHAR(20)) + ' min ago'
        WHEN DATEDIFF(HOUR, tc.AddedOn, GETUTCDate()) < 24 THEN CAST(DATEDIFF(HOUR, tc.AddedOn, GETUTCDate()) AS NVARCHAR(20)) + ' hour ago'
        WHEN DATEDIFF(DAY, tc.AddedOn, GETUTCDate()) < 30 THEN CAST(DATEDIFF(DAY, tc.AddedOn, GETUTCDate()) AS NVARCHAR(20)) + ' days ago'
        ELSE CAST(DATEDIFF(MONTH, tc.AddedOn, GETUTCDate()) AS NVARCHAR(20)) + ' month ago'
    END,
		MemeberActive = CASE WHEN tc.AddedBy = @Username THEN 1 ELSE 0 END,
		CommentText 
	FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] tc WITH (NOLOCK)
	LEFT JOIN [MSPL_DB].[dbo].[T_Users] u WITH (NOLOCK) ON tc.AddedBy = u.USERNAME
	WHERE tc.IsActive = 1 AND tc.TD_ID = @TD_ID
	ORDER BY tc.AddedOn ASC
	
END;
GO
/****** Object:  StoredProcedure [dbo].[P_Get_TMS_Memebers_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--		EXEC [P_Get_TMS_Memebers_List] 1

CREATE PROCEDURE [dbo].[P_Get_TMS_Memebers_List]
    @TD_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TATM_ID, TD_ID, r.R_ID, AssignedTo, u.Email, r.RoleName
	FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] tatm WITH (NOLOCK) 
	INNER JOIN [MSPL_DB].[dbo].[T_Users] u WITH (NOLOCK) on tatm.AssignedTo = u.USERNAME
	LEFT JOIN [MSPL_DB].[dbo].[T_User_Role_Mapping] urm WITH (NOLOCK) on tatm.AssignedTo = urm.USERNAME
	LEFT JOIN [MSPL_DB].[dbo].[T_Roles] r WITH (NOLOCK) on urm.ROLE_ID = r.R_ID
	WHERE tatm.IsActive = 1 AND tatm.TD_ID = @TD_ID
	
END;
GO
/****** Object:  StoredProcedure [dbo].[P_Get_User_Info]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abdullah>
-- Create date: <07-31-2021>
-- Description:	<Get User Information>
-- [dbo].[P_Get_User_Info] 'ABDULLAH.ARSHAD',148104
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_User_Info]
	-- Add the parameters for the stored procedure here
	@UserName nvarchar(100)
	,@ApplicationID int
	
AS
BEGIN
	
	Set @UserName = upper(isnull(@UserName,''))

	Declare @Usertable table
	(
		[User_ID] int
		,[UserName] nvarchar(150)
		,[FullName] nvarchar(250)
		,[Designation] nvarchar(150)
		,[DepartmentID] int
		,[DepartmentName] nvarchar(150)
		,[IsAdmin] bit
		,[IsBlocked] bit
		,[TempBlockTillDateTime] datetime
		,[PasswordExpiryDateTime] datetime
		,[TimeRegion] nvarchar(50)
		,[TimeRegionShortName] nvarchar(10)
		,[TimeZoneID] int
		,[TimeOffset] int
		,[NavUserName] nvarchar(150)
		,[NavApproverUserName] nvarchar(150)
		,[UserTypeMTVCode] nvarchar(20)
		,[RoleID] int
		,[IsGroupRoleID] int
		,[IsApplicationAccessAllowed] bit
		,[IsAPIAccessAllowed] bit
		,[PasswordHash] nvarchar(250)
		,[PasswordSalt] nvarchar(250)
	)

	if (@ApplicationID = 148104)
	begin
		insert into @Usertable ([User_ID] ,[UserName] ,[FullName] ,[Designation] ,[DepartmentID] ,[DepartmentName] ,[IsAdmin] ,[IsBlocked] ,[TempBlockTillDateTime] ,[PasswordExpiryDateTime] ,[TimeRegion] 
		,[TimeRegionShortName] ,[TimeZoneID] ,[TimeOffset] ,[NavUserName] ,[NavApproverUserName] ,[UserTypeMTVCode] ,[RoleID] ,[IsGroupRoleID] ,[IsApplicationAccessAllowed] ,[IsAPIAccessAllowed] ,[PasswordHash] ,[PasswordSalt])
		Select [USER_ID] ,u.[USERNAME]
		,FullName = (case when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.MiddleName + ' ' + u.LastName
		when isnull(u.FirstName,'') = '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.MiddleName + ' ' + u.LastName
		when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') = '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.LastName
		when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') = '' then u.FirstName + ' ' + u.MiddleName
		else u.USERNAME end)
		,[Designation]
		,[DepartmentID] = u.D_ID
		,[DepartmentName] = (select top 1 d.DepartmentName from [MSPL_DB].[dbo].[T_Department] d with (nolock) where d.D_ID = u.D_ID) 
		,[IsAdmin] = cast((case when isnull(urm.ROLE_ID,0) in (16) then 1 else 0 end) as bit)
		,[IsBlocked] = cast((case when u.BlockType_MTV_ID <> 149100 then 1 else 0 end) as bit)
		,u.[TempBlockTillDateTime]
		,u.[PasswordExpiryDateTime]
		,[TimeRegion] = isnull(tzl.TimeZoneDisplay,'Eastern Time (US & Canada)')
		,[TimeRegionShortName] = isnull(tzl.TimeZoneAbbreviation,'EST')
		,[TimeZoneID] = (case when tzl.TimeZoneDisplay is null then 13 else u.TIMEZONE_ID end)
		,[TimeOffset] = isnull(tzl.Offset,-18000000)
		,[NavUserName] = ''
		,[NavApproverUserName] = ''
		,[UserTypeMTVCode] = u.UserType_MTV_CODE
		,[RoleID] = isnull(urm.ROLE_ID,0)
		,[IsGroupRoleID] = isnull(urm.IsGroupRoleID,0)
		,[IsApplicationAccessAllowed] = isnull(uaa.IsActive,0)
		,[IsAPIAccessAllowed] = u.IsAPIUser
		,[PasswordHash] = u.PasswordHash
		,[PasswordSalt] = u.PasswordSalt
		from [MSPL_DB].[dbo].[T_Users] u with (nolock)
		left join [MSPL_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) on u.USERNAME = urm.USERNAME
		left join [MSPL_DB].[dbo].[T_User_Application_Access] uaa with (nolock) on u.USERNAME = uaa.USERNAME and uaa.Application_MTV_ID = @ApplicationID and uaa.IsActive = 1 -- Pinnacle
		left join [MSPL_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) on u.TIMEZONE_ID = tzl.TIMEZONE_ID
		where u.USERNAME = @UserName
	end
	else --if (@ApplicationID = 148107)
	begin
		insert into @Usertable ([User_ID] ,[UserName] ,[FullName] ,[Designation] ,[DepartmentID] ,[DepartmentName] ,[IsAdmin] ,[IsBlocked] ,[TempBlockTillDateTime] ,[PasswordExpiryDateTime] ,[TimeRegion] 
		,[TimeRegionShortName] ,[TimeZoneID] ,[TimeOffset] ,[NavUserName] ,[NavApproverUserName] ,[UserTypeMTVCode] ,[RoleID] ,[IsGroupRoleID] ,[IsApplicationAccessAllowed] ,[IsAPIAccessAllowed] ,[PasswordHash] ,[PasswordSalt])
		Select [USER_ID] ,u.[USERNAME]
		,FullName = (case when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.MiddleName + ' ' + u.LastName
		when isnull(u.FirstName,'') = '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.MiddleName + ' ' + u.LastName
		when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') = '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.LastName
		when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') = '' then u.FirstName + ' ' + u.MiddleName
		else u.USERNAME end)
		,[Designation]
		,[DepartmentID] = u.D_ID
		,[DepartmentName] = (select top 1 d.DepartmentName from [MSPL_DB].[dbo].[T_Department] d with (nolock) where d.D_ID = u.D_ID) 
		,[IsAdmin] = cast((case when isnull(urm.ROLE_ID,0) in (16) then 1 else 0 end) as bit)
		,[IsBlocked] = cast((case when u.BlockType_MTV_ID <> 149100 then 1 else 0 end) as bit)
		,u.[TempBlockTillDateTime]
		,u.[PasswordExpiryDateTime]
		,[TimeRegion] = isnull(tzl.TimeZoneDisplay,'Eastern Time (US & Canada)')
		,[TimeRegionShortName] = isnull(tzl.TimeZoneAbbreviation,'EST')
		,[TimeZoneID] = (case when tzl.TimeZoneDisplay is null then 13 else u.TIMEZONE_ID end)
		,[TimeOffset] = isnull(tzl.Offset,-18000000)
		,[NavUserName] = ''
		,[NavApproverUserName] = ''
		,[UserTypeMTVCode] = u.UserType_MTV_CODE
		,[RoleID] = isnull(urm.ROLE_ID,0)
		,[IsGroupRoleID] = isnull(urm.IsGroupRoleID,0)
		,[IsApplicationAccessAllowed] = isnull(uaa.IsActive,0)
		,[IsAPIAccessAllowed] = u.IsAPIUser
		,[PasswordHash] = u.PasswordHash
		,[PasswordSalt] = u.PasswordSalt
		from [MSPL_DB].[dbo].[T_Users] u with (nolock)
		left join [MSPL_DB].[dbo].[T_User_Role_Mapping] urm with (nolock) on u.USERNAME = urm.USERNAME
		left join [MSPL_DB].[dbo].[T_User_Application_Access] uaa with (nolock) on u.USERNAME = uaa.USERNAME and uaa.Application_MTV_ID = @ApplicationID and uaa.IsActive = 1 -- All
		left join [MSPL_DB].[dbo].[T_Time_Zone_List] tzl with (nolock) on u.TIMEZONE_ID = tzl.TIMEZONE_ID
		where u.USERNAME = @UserName
	end

	select * from @Usertable

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_User_List]    Script Date: 4/6/2024 6:57:22 AM ******/
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
/****** Object:  StoredProcedure [dbo].[P_Get_UserRoleMap_List]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Declare @TotalCount int = 0 exec [dbo].[P_Get_UserRoleMap_List] 'MSPL.ADMIN', 0, 30, '', '', @TotalCount out, 18000000, '', '' select @TotalCount

CREATE PROCEDURE [dbo].[P_Get_UserRoleMap_List] 
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
	FROM [MSPL_DB].[dbo].T_User_Role_Mapping urm with (nolock) 
INNER JOIN [MSPL_DB].[dbo].T_Roles r with (nolock) ON urm.ROLE_ID = r.R_ID'

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Users_List]    Script Date: 4/6/2024 6:57:22 AM ******/
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
		from [MSPL_DB].[dbo].[T_User_To_Seller_Mapping] usm with (nolock) 
		inner join [MSPL_DB].[dbo].[T_User_To_Seller_Mapping] usm1 with (nolock) on usm.SELLER_ID = usm1.SELLER_ID
		inner join [MSPL_DB].[dbo].[T_Users] u with (nolock) on usm1.UserName = u.USERNAME
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
	+ char(10) + (case when @TIMEZONE_Name_Filtered = 1 then '' else @HideField end) + ',[TIMEZONE_Name]=[MSPL_DB].[dbo].[F_Get_TimeZoneName_From_TimeZoneID] (u.TIMEZONE_ID)'
	+ char(10) + (case when @IsApproved_Filtered = 1 then '' else @HideField end) + ',IsApproved = u.IsApproved'
	+ char(10) + (case when @BlockType_Filtered = 1 then '' else @HideField end) + ',BlockType = mtv_bt.Name'
	--+ char(10) + (case when @BlockType_Filtered = 1 then '' else @HideField end) + ',PasswordExpiry = u.PasswordExpiryDateTime'
	+ char(10) + (case when @IsAPIUser_Filtered = 1 then '' else @HideField end) + ',IsAPIUser = u.IsAPIUser'
	+ char(10) + (case when @IsActive_Filtered = 1 then '' else @HideField end) + ',IsActive = u.IsActive'
	+ char(10) + 'FROM [MSPL_DB].[dbo].[T_Users] u with (nolock)'
	+ char(10) + 'left JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] mtv_ut with (nolock) ON u.UserType_MTV_CODE = mtv_ut.MTV_CODE'
	+ char(10) + 'left JOIN [MSPL_DB].[dbo].[T_Department] d with (nolock) ON u.D_ID = d.D_ID'
	--+ char(10) 'left JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] mtv_sq with (nolock) ON u.SecurityQuestion_MTV_ID = mtv_sq.MTV_ID'
	+ char(10) + 'left JOIN [MSPL_DB].[dbo].[T_Master_Type_Value] mtv_bt with (nolock) ON u.BlockType_MTV_ID = mtv_bt.MTV_ID'
	+ char(10) + 'where 1 = 1'
	+ char(10) + (case when @UserType_MTV_CODE = 'METRO-USER' then '' else 'where u.USER_ID in (select [USER_ID] from #UsersList ul)' end)

	exec P_Get_Common_List @selectSql, @pageIndex, @pageSize, @sortExpression, @filterClause , @SetTop , @totalRowCount OUTPUT

END
GO
/****** Object:  StoredProcedure [dbo].[P_Get_UserSetup_Dropdown_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [dbo].[P_Get_UserSetup_Dropdown_Lists] 'ABDULLAH.ARSHAD', 'METRO-USER'

CREATE PROCEDURE [dbo].[P_Get_UserSetup_Dropdown_Lists]
	@Username nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	
AS
BEGIN
	
	SELECT [value] = MTV_CODE, [text] = Name FROM [MSPL_DB].[dbo].[T_Master_Type_Value] with (nolock)
	where MT_ID = 106 AND IsActive = 1 ORDER BY Sort_

	SELECT [value] = D_ID, [text] = DepartmentName FROM [MSPL_DB].[dbo].[T_Department] with (nolock)
	where IsActive = 1 ORDER BY DepartmentName 

	SELECT [value] = MTV_CODE, [text] = Name FROM [MSPL_DB].[dbo].[T_Master_Type_Value] with (nolock)
	where MT_ID = 150 AND IsActive = 1 ORDER BY Sort_

	SELECT [value] = MTV_CODE, [text] = Name FROM [MSPL_DB].[dbo].[T_Master_Type_Value] with (nolock)
	where MT_ID = 149 AND IsActive = 1 ORDER BY Sort_

	SELECT [value] = TIMEZONE_ID, [text] = TimeZoneDisplay FROM [MSPL_DB].[dbo].[T_Time_Zone_List] with (nolock) WHERE IsActive = 1 and TIMEZONE_ID In (5,7,9,13) order by TimeZoneDisplay

	select [value], [text] from (
		Select [value]=CONCAT(r.R_ID,'|','0'),[text]=r.RoleName  from [MSPL_DB].[dbo].[T_Roles] r  with (nolock) WHERE r.IsActive = 1
		union 
		select [value]=CONCAT(rg.RG_ID,'|','1'),[text]=rg.RoleGroupName from  [MSPL_DB].[dbo].[T_Role_Group] rg  with (nolock) WHERE rg.IsActive = 1
	) ilv order by [text]
	 
	SELECT [value] = MTV_ID, [text] = Name FROM [MSPL_DB].[dbo].[T_Master_Type_Value] with (nolock) WHERE MT_ID=148 and IsActive = 1  ORDER BY Name

	SELECT [value] = SELLER_KEY, [text] = Company + '  -  ' + SELLER_CODE FROM [MSPL_DB].[dbo].[T_Seller_list] with (nolock) WHERE IsActive = 1  ORDER BY Company

END

 
GO
/****** Object:  StoredProcedure [dbo].[P_GetTaskAssignedToMappingForModal]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC P_GetTaskAssignedToMappingForModal 2
CREATE PROCEDURE [dbo].[P_GetTaskAssignedToMappingForModal]
    @TD_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TATM_ID, TD_ID, AssignedTo, Active = IsActive 
    FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] WITH (NOLOCK) 
    WHERE TD_ID = @TD_ID And IsActive=1
END


--CREATE PROCEDURE P_GetTaskDetailListForDropDown
--AS
--BEGIN
--    SET NOCOUNT ON;
--    SELECT TD_ID AS code, Task_Item AS [name] 
--    FROM [MSPL_DB].[dbo].[T_TMS_TaskDetail] WITH (NOLOCK) 
--    WHERE IsActive = 1
--END

--CREATE PROCEDURE P_GetAssignedToListUser
--AS
--BEGIN
--    SET NOCOUNT ON;
--    SELECT USERNAME AS code, LOWER(USERNAME) AS [name] 
--    FROM [MSPL_DB].[dbo].[T_Users] WITH (NOLOCK) 
--    WHERE IsActive = 1 
--    AND [USER_ID] IN (9114,9119,9124,9127,8550,8019,8551)
--END

-- select * from T_TMS_TaskAssignedTo_Mapping

 
GO
/****** Object:  StoredProcedure [dbo].[P_GetTaskCommentForModal]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_GetTaskCommentForModal]
@TC_ID int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TC_ID, TD_ID, CommentText, Application_URL=Application_URL
,Task_Start_Date=Task_Start_Date
,Task_End_Date=Task_End_Date
,Priority_MTV_ID=Priority_MTV_ID
,Status_MTV_ID=Status_MTV_ID
,BUILDCODE=BUILDCODE
,TaskCategory_MTV_ID=TaskCategory_MTV_ID
,Review_Date=Review_Date
,ETA_Date=ETA_Date
,IsPrivate=IsPrivate
,Active = IsActive FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] WITH (NOLOCK) 
	WHERE TC_ID = @TC_ID
END
GO
/****** Object:  StoredProcedure [dbo].[P_GetTaskModal]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[P_GetTaskModal]
@T_ID int 
As
Begin
SELECT T_ID, Application_ID=Application_MTV_ID, TaskName, Note, IsActive Active FROM [MSPL_DB].[dbo].[T_TMS_Tasks] with (nolock) WHERE T_ID = @T_ID
End
GO
/****** Object:  StoredProcedure [dbo].[P_GetTMSDropDownGrids_Lists]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
  
 --Exec P_GetTMSDropDownGrids_Lists
CREATE Procedure [dbo].[P_GetTMSDropDownGrids_Lists]

As 
Begin

--SELECT code = T_ID, [name] = TaskName FROM [MSPL_DB].[dbo].[T_TMS_Tasks] WITH (NOLOCK) WHERE IsActive = 1
-- Application 
 select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [MSPL_DB].[dbo].[T_Master_Type] mt 
	left join [MSPL_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 148
	order by Sort_

	--page name
	SELECT [value] = P_ID, [text] = PageName FROM [MSPL_DB].[dbo].[T_Page] WITH (NOLOCK) WHERE IsActive = 1

	--priority list
	select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [MSPL_DB].[dbo].[T_Master_Type] mt 
	left join [MSPL_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 176
	order by Sort_

	--Status List
	 select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [MSPL_DB].[dbo].[T_Master_Type] mt 
	left join [MSPL_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 175
	order by Sort_

	--Task Category
	 select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [MSPL_DB].[dbo].[T_Master_Type] mt 
	left join [MSPL_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 177
	order by Sort_

	END
GO
/****** Object:  StoredProcedure [dbo].[P_Insert_Feedback]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[P_Insert_Feedback]
    @MessageData NVARCHAR(MAX),
    @IsActive BIT,
    @AddedBy NVARCHAR(100),
    @AddedOn DATETIME,
    @ModifiedBy NVARCHAR(100),
    @ModifiedOn DATETIME
AS
BEGIN

    INSERT INTO T_Feedback (MessageData, IsActive, AddedBy, AddedOn, ModifiedBy, ModifiedOn)
    VALUES (@MessageData, @IsActive, @AddedBy, @AddedOn, @ModifiedBy, @ModifiedOn);
END
GO
/****** Object:  StoredProcedure [dbo].[P_Is_Has_Right_From_RoleID]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Is_Has_Right_From_RoleID]
	@ROLE_ID int
	,@IsGroupRoleID bit
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''

AS
BEGIN
	
	select [MSPL_DB].[dbo].[F_Is_Has_Right_From_RoleID] (@ROLE_ID ,@IsGroupRoleID ,@PR_ID ,@PageRightType_MTV_CODE)

END
GO
/****** Object:  StoredProcedure [dbo].[P_Is_Has_Right_From_Username]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Is_Has_Right_From_Username]
	@Username nvarchar(150)
	,@PR_ID int = 0
	,@PageRightType_MTV_CODE nvarchar(20) = ''

AS
BEGIN
	
	select [MSPL_DB].[dbo].[F_Is_Has_Right_From_Username] (@Username ,@PR_ID ,@PageRightType_MTV_CODE)

END
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_TaskAssignedToMap]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC [P_Remove_TaskAssignedToMap] 1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Remove_TaskAssignedToMap]
@TD_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TD_ID > 0 
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] WITH (NOLOCK) WHERE TD_ID = @TD_ID)
	BEGIN	    
		SELECT @IsActive = IsActive FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] WITH (NOLOCK) WHERE TD_ID = @TD_ID
		IF @IsActive = 0 BEGIN		
			UPDATE [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] SET IsActive = 1 WHERE TD_ID = @TD_ID
		SET @Return_Text = 'Task Assigned To ACTIVE Successfully!'
		SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] SET IsActive = 0 WHERE TD_ID = @TD_ID
			SET @Return_Text = 'Task Assigned To IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Assigned To does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Task Assigned To Map ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END

GO
/****** Object:  StoredProcedure [dbo].[P_Remove_TaskAttachments]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC [P_Remove_TaskAttachments] 1,'Ihtisham.Ulhaq'
CREATE PROC [dbo].[P_Remove_TaskAttachments]
@TA_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TA_ID > 0 
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_TaskAttachments] WITH (NOLOCK) WHERE TA_ID = @TA_ID)
	BEGIN	    
	    UPDATE [MSPL_DB].[dbo].[T_TMS_TaskAttachments] SET IsActive = 0 WHERE TA_ID = @TA_ID
		SET @Return_Text = 'Task Attachmen Remove Successfully!'
		SET @Return_Code = 1
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Attachment does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Task Attachment ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END

GO
/****** Object:  StoredProcedure [dbo].[P_Remove_TaskComments]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC [P_Remove_TaskComments] 1,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Remove_TaskComments]
@TC_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TC_ID > 0 
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] WITH (NOLOCK) WHERE TC_ID = @TC_ID)
	BEGIN	    
		SELECT @IsActive = IsActive FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] WITH (NOLOCK) WHERE TC_ID = @TC_ID
		IF @IsActive = 0 BEGIN		
			UPDATE [MSPL_DB].[dbo].[T_TMS_TaskComments] SET IsActive = 1 WHERE TC_ID = @TC_ID
		SET @Return_Text = 'Task Comment ACTIVE Successfully!'
		SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [MSPL_DB].[dbo].[T_TMS_TaskComments] SET IsActive = 0 WHERE TC_ID = @TC_ID
			SET @Return_Text = 'Task Comment IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Comment does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Task Comment ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_TaskDetail]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--						EXEC [P_Remove_TaskDetail] 0,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Remove_TaskDetail]
@TD_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @TD_ID > 0 
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_TaskDetail] WITH (NOLOCK) WHERE TD_ID = @TD_ID)
	BEGIN	    
		SELECT @IsActive = IsActive FROM [MSPL_DB].[dbo].[T_TMS_TaskDetail] WITH (NOLOCK) WHERE TD_ID = @TD_ID
		IF @IsActive = 0 BEGIN		
			UPDATE [MSPL_DB].[dbo].[T_TMS_TaskDetail] SET IsActive = 1 WHERE TD_ID = @TD_ID
		SET @Return_Text = 'Task Detail ACTIVE Successfully!'
		SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [MSPL_DB].[dbo].[T_TMS_TaskDetail] SET IsActive = 0 WHERE TD_ID = @TD_ID
			SET @Return_Text = 'Task Detail IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task Detail does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Task Detail ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_TaskManagementSystem]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 --		EXEC [dbo].[P_Remove_TaskManagementSystem] 1,1,'HAMMAS.KHAN',''
CREATE PROC [dbo].[P_Remove_TaskManagementSystem]
@T_ID INT,
@TD_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

	--BEGIN TRY
	--	BEGIN TRAN;
		-- Parameter validation
		IF @T_ID > 0 OR @TD_ID > 0
		BEGIN		
			-- Check if Task exists
			IF EXISTS (SELECT 1 FROM [MSPL_DB].dbo.[T_TMS_Tasks] WHERE T_ID = @T_ID)
			BEGIN
				-- Check if Task exists
				IF EXISTS (SELECT 1 FROM [MSPL_DB].dbo.[T_TMS_Tasks] WHERE T_ID = @T_ID)
				BEGIN
					-- Delete TaskAttachments
					DELETE FROM [MSPL_DB].[dbo].[T_TMS_TaskAttachments] WHERE AttachmentType_MTV_ID = 179100 AND REFID1 = @TD_ID;

					-- Delete TaskComments
					DELETE FROM [MSPL_DB].[dbo].[T_TMS_TaskComments] WHERE TD_ID = @TD_ID;

					-- Delete TaskAssignedTo_Mapping
					DELETE FROM [MSPL_DB].[dbo].[T_TMS_TaskAssignedTo_Mapping] WHERE TD_ID = @TD_ID;
										
					-- Delete TaskDetail
					DELETE FROM [MSPL_DB].[dbo].[T_TMS_TaskDetail] WHERE T_ID = @T_ID AND TD_ID = @TD_ID;
					
					-- Delete Task
					IF NOT EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_TaskDetail] WITH (NOLOCK) WHERE T_ID = @T_ID)
					BEGIN
						DELETE FROM [MSPL_DB].[dbo].[T_TMS_Tasks] WHERE T_ID = @T_ID;
					END

					SET @Return_Text = 'Task Removed Successfully!';
					SET @Return_Code = 1;
				END
				ELSE BEGIN 
					SET @Return_Text = 'TD_ID Not Exists!'
					SET @Return_Code = 0
				END			
			END
			ELSE BEGIN 
				SET @Return_Text = 'T_ID Not Exists!'
				SET @Return_Code = 0
			END			
		END
		ELSE BEGIN 
			SET @Return_Text = 'Invalid Task Ids'
			SET @Return_Code = 0
		END	

	--COMMIT;

 --   END TRY
 --   BEGIN CATCH
 --       ROLLBACK;
 --       SET @Return_Text = ERROR_MESSAGE();
 --       SET @Return_Code = 0;
 --   END CATCH

    SELECT @Return_Code AS Return_Code, @Return_Text AS Return_Text;	
END
GO
/****** Object:  StoredProcedure [dbo].[P_Remove_Tasks]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--						EXEC [P_Remove_Tasks] 0,'HAMMAS.KHAN'
CREATE PROC [dbo].[P_Remove_Tasks]
@T_ID INT,
@Username nvarchar(150),
@IPAddress nvarchar(20) = ''
AS
BEGIN
	Declare @Return_Code bit  = 1
	Declare @Return_Text nvarchar(1000)  = ''

IF @T_ID > 0 
BEGIN
	DECLARE @IsActive BIT
	IF EXISTS (SELECT 1 FROM [MSPL_DB].[dbo].[T_TMS_Tasks] WITH (NOLOCK) WHERE T_ID = @T_ID)
	BEGIN	    
		SELECT @IsActive = IsActive FROM [MSPL_DB].[dbo].[T_TMS_Tasks] WITH (NOLOCK) WHERE T_ID = @T_ID
		IF @IsActive = 0 BEGIN		
			UPDATE [MSPL_DB].[dbo].[T_TMS_Tasks] SET IsActive = 1 WHERE T_ID = @T_ID
		SET @Return_Text = 'Task ACTIVE Successfully!'
		SET @Return_Code = 1
		END
		ELSE BEGIN 
			UPDATE [MSPL_DB].[dbo].[T_TMS_Tasks] SET IsActive = 0 WHERE T_ID = @T_ID
			SET @Return_Text = 'Task IN-ACTIVE Successfully!'
			SET @Return_Code = 1
		END
	END
	ELSE
	BEGIN
		SET @Return_Text = 'Task does not exist!'
		SET @Return_Code = 0
	END
END
ELSE
BEGIN
	SET @Return_Text = 'Task ID Not Found!'
	SET @Return_Code = 0
END

SELECT @Return_Text Return_Text, @Return_Code Return_Code

END
GO
/****** Object:  StoredProcedure [dbo].[P_User_IU]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_User_IU]
	@Json nvarchar(max)
	,@pUsername nvarchar(150)
	,@pIP nvarchar(20)
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(1000) output
	,@pError_Text nvarchar(max) output
	,@pIsBeginTransaction bit = 1
	,@pSource_MTV_ID int = 167100
AS
BEGIN
	
	set @pUserName = upper(@pUserName)

	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	Declare @USER_ID int
    Declare @USERNAME NVARCHAR(50)
	Declare @UserType_MTV_CODE NVARCHAR(20)
	Declare @PasswordHash NVARCHAR(250)
	Declare @PasswordSalt NVARCHAR(250)
	Declare @D_ID int
	Declare @ROLE_ID int
	Declare @IsGroupRoleID bit
	Declare @Designation nvarchar(150)
	Declare @FirstName nvarchar(50)
	Declare @MiddleName nvarchar(50)
	Declare @LastName nvarchar(50)
	Declare @Company nvarchar(250)
	Declare @Address nvarchar(250)
	Declare @Address2 nvarchar(250)
	Declare @City nvarchar(50)
	Declare @State nvarchar(5)
	Declare @ZipCode nvarchar(10)
	Declare @Country nvarchar(50)
	Declare @Email nvarchar(250)
	Declare @Mobile nvarchar(30)
	Declare @Phone nvarchar(40)
	Declare @PhoneExt nvarchar(20)
	Declare @SecurityQuestion_MTV_ID int
	Declare @EncryptedAnswer nvarchar(250)
	Declare @TIMEZONE_ID int
	Declare @IsApproved bit
	Declare @BlockType_MTV_ID int
	Declare @IsAPIUser bit
	Declare @IsActive bit
	Declare @UserApplicationJson nvarchar(max)

	Declare @TemppReturn_Code bit = 0
	Declare @TemppReturn_Text nvarchar(1000) = ''
	Declare @TemppExecution_Error nvarchar(1000) = ''
	Declare @TemppError_Text nvarchar(max) = ''

	Begin Try
		
		select @USER_ID = [USER_ID]
		,@USERNAME = USERNAME
		,@UserType_MTV_CODE = UserType_MTV_CODE
		,@PasswordHash = PasswordHash
		,@PasswordSalt = PasswordSalt
		,@D_ID = D_ID
		,@ROLE_ID = ROLE_ID
		,@IsGroupRoleID = IsGroupRoleID
		,@Designation = Designation
		,@FirstName = FirstName
		,@MiddleName = MiddleName
		,@LastName = LastName
		,@Company = Company
		,@Address = [Address]
		,@Address2 = Address2
		,@City = City
		,@State = [State]
		,@ZipCode = ZipCode
		,@Country = Country
		,@Email = Email
		,@Mobile = Mobile
		,@Phone = Phone
		,@PhoneExt = PhoneExt
		,@SecurityQuestion_MTV_ID = SecurityQuestion_MTV_ID
		,@EncryptedAnswer = EncryptedAnswer
		,@TIMEZONE_ID = TIMEZONE_ID
		,@IsApproved = IsApproved
		,@BlockType_MTV_ID = BlockType_MTV_ID
		,@IsAPIUser = IsAPIUser
		,@IsActive = IsActive
		,@UserApplicationJson = UserApplicationJson
		from [MSPL_DB].[dbo].[F_Get_T_UserDetials_JsonTable] (@Json)
		
		if @pIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if (@USER_ID = 0)
		begin
			
			exec [MSPL_DB].[dbo].[P_Generate_UserID] @Ret_UserID = @USER_ID out

			insert into [MSPL_DB].[dbo].[T_Users] ([USER_ID] ,USERNAME ,UserType_MTV_CODE ,PasswordHash ,PasswordSalt ,D_ID ,Designation ,FirstName ,MiddleName ,LastName ,Company ,[Address] ,Address2 ,City ,[State] ,ZipCode ,Country ,Email 
				,Mobile ,Phone ,PhoneExt ,SecurityQuestion_MTV_ID ,EncryptedAnswer ,TIMEZONE_ID ,IsApproved ,BlockType_MTV_ID ,IsAPIUser ,AddedBy)
			values (@USER_ID ,@USERNAME ,@UserType_MTV_CODE ,@PasswordHash ,@PasswordSalt ,@D_ID ,@Designation ,@FirstName ,@MiddleName ,@LastName ,@Company ,@Address ,@Address2 ,@City ,@State ,@ZipCode ,@Country ,@Email 
				,@Mobile ,@Phone ,@PhoneExt ,@SecurityQuestion_MTV_ID ,@EncryptedAnswer ,@TIMEZONE_ID ,@IsApproved ,@BlockType_MTV_ID ,@IsAPIUser ,@pUsername)

			set @pReturn_Code = 1
			set @pReturn_Text = 'Inserted'

		end
		else if exists(select * from [MSPL_DB].[dbo].[T_Users] u where u.[USER_ID] = @USER_ID and u.USERNAME = @USERNAME)
		begin
			drop table if exists #JsonOldEditUserTable 
			select u.[USER_ID]
			,u.USERNAME 
			,u.UserType_MTV_CODE
			,UserType_MTV_CODE_Name=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (u.UserType_MTV_CODE)
			,u.PasswordHash
			,u.PasswordSalt
			,u.D_ID
			,D_ID_Name=[MSPL_DB].[dbo].[F_Get_DepartmentName_From_D_ID] (u.D_ID)
			,u.Designation
			,u.FirstName
			,u.MiddleName
			,u.LastName
			,u.Company
			,u.[Address]
			,u.Address2
			,u.City
			,u.[State]
			,u.ZipCode
			,u.Country
			,u.Email
			,u.Mobile
			,u.Phone
			,u.PhoneExt
			,u.SecurityQuestion_MTV_ID
			,SecurityQuestion_MTV_ID_Name=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (u.SecurityQuestion_MTV_ID)
			,u.EncryptedAnswer
			,u.TIMEZONE_ID
			,TIMEZONE_ID_Name=[MSPL_DB].[dbo].[F_Get_TimeZoneName_From_TimeZoneID] (u.TIMEZONE_ID)
			,u.IsApproved
			,IsApproved_Name=(case u.IsApproved when 1 then 'Yes' else 'No' end)
			,u.BlockType_MTV_ID
			,BlockType_MTV_ID_Name=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (u.BlockType_MTV_ID)
			,u.IsAPIUser
			,IsAPIUser_Name=(case u.IsAPIUser when 1 then 'Yes' else 'No' end)
			,u.IsActive
			,IsActive_Name=(case u.IsActive when 1 then 'Yes' else 'No' end)
			into #JsonOldEditUserTable   
			from [MSPL_DB].[dbo].[T_Users] u with (nolock)
			where u.[USER_ID] = @USER_ID and u.USERNAME = @USERNAME

			Update u 
			set u.UserType_MTV_CODE = @UserType_MTV_CODE
			,u.PasswordHash = @PasswordHash
			,u.PasswordSalt = @PasswordSalt
			,u.D_ID = @D_ID
			,u.Designation = @Designation
			,u.FirstName = @FirstName
			,u.MiddleName = @MiddleName
			,u.LastName = @LastName
			,u.Company = @Company
			,u.[Address] = @Address
			,u.Address2 = @Address2
			,u.City = @City
			,u.[State] = @State
			,u.ZipCode = @ZipCode
			,u.Country = @Country
			,u.Email = @Email
			,u.Mobile = @Mobile
			,u.Phone = @Phone
			,u.PhoneExt = @PhoneExt
			,u.SecurityQuestion_MTV_ID = @SecurityQuestion_MTV_ID
			,u.EncryptedAnswer = @EncryptedAnswer
			,u.TIMEZONE_ID = @TIMEZONE_ID
			,u.IsApproved = @IsApproved
			,u.BlockType_MTV_ID = @BlockType_MTV_ID
			,u.IsAPIUser = @IsAPIUser
			,u.IsActive = @IsActive
			,u.ModifiedBy = @pUsername
			,u.ModifiedOn = getutcdate()
			from [MSPL_DB].[dbo].[T_Users] u where u.[USER_ID] = @USER_ID and u.USERNAME = @USERNAME

			drop table if exists #JsonNewEditUserTable 
			select [USER_ID]=@USER_ID
			,USERNAME=@USERNAME
			,UserType_MTV_CODE=isnull(@UserType_MTV_CODE,'')
			,UserType_MTV_CODE_Name=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_CODE] (u.UserType_MTV_CODE)
			,PasswordHash=isnull(@PasswordHash,'')
			,PasswordSalt=isnull(@PasswordSalt,'')
			,D_ID=isnull(@D_ID,0)
			,D_ID_Name=[MSPL_DB].[dbo].[F_Get_DepartmentName_From_D_ID] (u.D_ID)
			,Designation=isnull(@Designation,'')
			,FirstName=isnull(@FirstName,'')
			,MiddleName=isnull(@MiddleName,'')
			,LastName=isnull(@LastName,'')
			,Company=isnull(@Company,'')
			,[Address]=isnull(@Address,'')
			,Address2=isnull(@Address2,'')
			,City=isnull(@City,'')
			,[State]=isnull(@State,'')
			,ZipCode=isnull(@ZipCode,'')
			,Country=isnull(@Country,'')
			,Email=isnull(@Email,'')
			,Mobile=isnull(@Mobile,'')
			,Phone=isnull(@Phone,'')
			,PhoneExt=isnull(@PhoneExt,'')
			,SecurityQuestion_MTV_ID=isnull(@SecurityQuestion_MTV_ID,0)
			,SecurityQuestion_MTV_ID_Name=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@SecurityQuestion_MTV_ID)
			,EncryptedAnswer=isnull(@EncryptedAnswer,'')
			,TIMEZONE_ID=isnull(@TIMEZONE_ID,0)
			,TIMEZONE_ID_Name=[MSPL_DB].[dbo].[F_Get_TimeZoneName_From_TimeZoneID] (@TIMEZONE_ID)
			,IsApproved=isnull(@IsApproved,0)
			,IsApproved_Name=(case @IsApproved when 1 then 'Yes' else 'No' end)
			,BlockType_MTV_ID=isnull(@BlockType_MTV_ID,0)
			,BlockType_MTV_ID_Name=[MSPL_DB].[dbo].[F_Get_MasterTypeValue_From_MTV_ID] (@BlockType_MTV_ID)
			,IsAPIUser=isnull(@IsAPIUser,0)
			,IsAPIUser_Name=(case @IsAPIUser when 1 then 'Yes' else 'No' end)
			,IsActive=isnull(@IsActive,0)
			,IsActive_Name=(case @IsActive when 1 then 'Yes' else 'No' end)
			into #JsonNewEditUserTable   
			from [MSPL_DB].[dbo].[T_Users] u with (nolock)
			where u.[USER_ID] = @USER_ID and u.USERNAME = @USERNAME

			exec [MSPL_DB].[dbo].[P_User_IU_ChangeLog] @plogIsEdit = 1 ,@plogUserName = @USERNAME ,@plogSource_MTV_ID = @pSource_MTV_ID

			set @pReturn_Code = 1
			set @pReturn_Text = 'Updated'
		end
		else 
		begin
			set @pReturn_Code = 1
			set @pReturn_Text = 'Invalid UserID and UserName'
		end

		if (@pReturn_Code = 1 and @ROLE_ID <> 0)
		begin
			select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''

			exec [MSPL_DB].[dbo].[P_User_Role_Mapping_IU] @USERNAME ,@pIP ,@ROLE_ID ,@IsGroupRoleID ,@pUsername ,@pReturn_Code = @TemppReturn_Code out ,@pReturn_Text = @TemppReturn_Text out 
				,@pExecution_Error = @TemppExecution_Error out ,@pError_Text = @TemppError_Text out ,@pIsBeginTransaction = @pIsBeginTransaction ,@pSource_MTV_ID = @pSource_MTV_ID

			select @pReturn_Code = @TemppReturn_Code
				, @pReturn_Text = @pReturn_Text + (case when @pReturn_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @pError_Text = @pError_Text + (case when @pError_Text <> '' then '; ' else '' end) + @TemppError_Text
		end

		if (@pReturn_Code = 1 and isnull(@UserApplicationJson,'') <> '')
		begin
			select @TemppReturn_Code = 1, @TemppReturn_Text = '', @TemppExecution_Error = '', @TemppError_Text = ''

			exec [MSPL_DB].[dbo].[P_User_Application_Mapping_IU] @UserApplicationJson ,@pUsername ,@pIP ,@pReturn_Code = @TemppReturn_Code out ,@pReturn_Text = @TemppReturn_Text out 
				,@pExecution_Error = @TemppExecution_Error out ,@pError_Text = @TemppError_Text out ,@pIsBeginTransaction = @pIsBeginTransaction ,@pSource_MTV_ID = @pSource_MTV_ID

			select @pReturn_Code = @TemppReturn_Code
				, @pReturn_Text = @pReturn_Text + (case when @pReturn_Text <> '' then '; ' else '' end) + @TemppReturn_Text
				, @pExecution_Error = @pExecution_Error + (case when @pExecution_Error <> '' then '; ' else '' end) + @TemppExecution_Error
				, @pError_Text = @pError_Text + (case when @pError_Text <> '' then '; ' else '' end) + @TemppError_Text
		end

		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 1
		begin
			COMMIT; 
		end
		else if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 0
		begin
			ROLLBACK; 
		end

	End Try
	Begin catch
		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @pError_Text = 'P_User_IU: ' + ERROR_MESSAGE()
	End catch


END
GO
/****** Object:  StoredProcedure [dbo].[P_User_IU_ChangeLog]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[P_User_IU_ChangeLog]
	@plogIsEdit bit 
	,@plogUserName nvarchar(150)
	,@plogSource_MTV_ID int
AS
BEGIN
	SET NOCOUNT ON;
	drop table if exists #JsonChangeLog
	Create Table #JsonChangeLog
	(ID [int] identity(1,1) NOT NULL
	,[AC_ID] [int] NOT NULL
	,[REF_NO] [nvarchar](150) NOT NULL
	,[AuditType_MTV_ID] [int] NOT NULL default 166120
	,[RefNo1] [nvarchar](50) NOT NULL
	,[RefNo2] [nvarchar](50) NOT NULL default ''
	,[RefNo3] [nvarchar](50) NOT NULL default ''
	,[OldValueHidden] [nvarchar](2000) NOT NULL
	,[NewValueHidden] [nvarchar](2000) NOT NULL
	,[OldValue] [nvarchar](2000) NOT NULL
	,[NewValue] [nvarchar](2000) NOT NULL
	,[Column_Name] [nvarchar](100) NOT NULL default ''
	,[Table_Name] [nvarchar](150) NOT NULL default ''
	,[Reason] [nvarchar](1000) NOT NULL default ''
	,[IsAuto] [bit] NOT NULL default 0
	,[Source_MTV_ID] [int] NOT NULL default 0
	,[TriggerDebugInfo] [nvarchar](4000) NULL
	,[ChangedBy] [nvarchar](150) NOT NULL)

	Begin Try
		if @plogIsEdit = 1
		begin
			insert into #JsonChangeLog ([AC_ID] ,[REF_NO] ,[RefNo1], [OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
			,[Column_Name] ,[Table_Name] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [REF_NO] , RefNo1 ,[OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_Users' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_User_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 1 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('UserType_MTV_CODE','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.UserType_MTV_CODE ,[NewValueHidden]=new.UserType_MTV_CODE
				,[OldValue]=old.UserType_MTV_CODE_Name ,[NewValue]=new.UserType_MTV_CODE_Name ,[Column_Name]='UserType_MTV_CODE'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 2 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('PasswordHash','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]='' ,[NewValue]='Changed' ,[Column_Name]='PasswordHash'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 3 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('PasswordSalt','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]='' ,[NewValue]='Changed' ,[Column_Name]='PasswordSalt'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 4 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('D_ID','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.D_ID ,[NewValueHidden]=new.D_ID
				,[OldValue]=old.D_ID_Name ,[NewValue]=new.D_ID_Name ,[Column_Name]='D_ID'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 5 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('Designation','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Designation ,[NewValue]=new.Designation ,[Column_Name]='Designation'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 6 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('FirstName','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.FirstName ,[NewValue]=new.FirstName ,[Column_Name]='FirstName'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 7 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('MiddleName','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.MiddleName ,[NewValue]=new.MiddleName ,[Column_Name]='MiddleName'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 8 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('LastName','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.LastName ,[NewValue]=new.LastName ,[Column_Name]='LastName'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 9 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('Company','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Company ,[NewValue]=new.Company ,[Column_Name]='Company'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 10 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('Address','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[Address] ,[NewValue]=new.[Address] ,[Column_Name]='Address'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 11 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('Address2','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Address2 ,[NewValue]=new.Address2 ,[Column_Name]='Address2'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 12 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('City','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.City ,[NewValue]=new.City ,[Column_Name]='City'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 13 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('State','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.[State] ,[NewValue]=new.[State] ,[Column_Name]='State'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 14 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('ZipCode','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.ZipCode ,[NewValue]=new.ZipCode ,[Column_Name]='ZipCode'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 15 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('Country','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Country ,[NewValue]=new.Country ,[Column_Name]='Country'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 16 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('Email','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Email ,[NewValue]=new.Email ,[Column_Name]='Email'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 17 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('Mobile','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Mobile ,[NewValue]=new.Mobile ,[Column_Name]='Mobile'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 18 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('Phone','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.Phone ,[NewValue]=new.Phone ,[Column_Name]='Phone'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 19 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('PhoneExt','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]=old.PhoneExt ,[NewValue]=new.PhoneExt ,[Column_Name]='PhoneExt'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 20 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('SecurityQuestion_MTV_ID','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.SecurityQuestion_MTV_ID ,[NewValueHidden]=new.SecurityQuestion_MTV_ID
				,[OldValue]=old.SecurityQuestion_MTV_ID_Name ,[NewValue]=new.SecurityQuestion_MTV_ID_Name ,[Column_Name]='SecurityQuestion_MTV_ID'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 21 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('EncryptedAnswer','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]='' ,[NewValueHidden]=''
				,[OldValue]='' ,[NewValue]='Changed' ,[Column_Name]='EncryptedAnswer'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 22 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('TIMEZONE_ID','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.TIMEZONE_ID ,[NewValueHidden]=new.TIMEZONE_ID
				,[OldValue]=old.TIMEZONE_ID_Name ,[NewValue]=new.TIMEZONE_ID_Name ,[Column_Name]='TIMEZONE_ID'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 23 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('IsApproved','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.IsApproved ,[NewValueHidden]=new.IsApproved
				,[OldValue]=old.IsApproved_Name ,[NewValue]=new.IsApproved_Name ,[Column_Name]='IsApproved'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 24 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('BlockType_MTV_ID','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.BlockType_MTV_ID ,[NewValueHidden]=new.BlockType_MTV_ID
				,[OldValue]=old.BlockType_MTV_ID_Name ,[NewValue]=new.BlockType_MTV_ID_Name ,[Column_Name]='BlockType_MTV_ID'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 25 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('IsAPIUser','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.IsAPIUser ,[NewValueHidden]=new.IsAPIUser
				,[OldValue]=old.IsAPIUser_Name ,[NewValue]=new.IsAPIUser_Name ,[Column_Name]='IsAPIUser'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
				union
				select ID = 26 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('IsActive','T_Users') , [REF_NO] = old.[USER_ID]
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.IsActive ,[NewValueHidden]=new.IsActive
				,[OldValue]=old.IsActive_Name ,[NewValue]=new.IsActive_Name ,[Column_Name]='IsActive'
				from #JsonOldEditUserTable old inner join #JsonNewEditUserTable new on old.[USER_ID] = new.[USER_ID] and old.USERNAME = new.USERNAME
			) ilv where ilv.[OldValue] <> ilv.[NewValue]
			order by ilv.RefNo1 ,ilv.ID
		end
		
		exec [MSPL_DB].[dbo].[P_Add_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_User_IU_ChangeLog Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
/****** Object:  StoredProcedure [dbo].[P_User_Role_Mapping_IU]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_User_Role_Mapping_IU]
	@pUsername nvarchar(150)
	,@pIP nvarchar(20)
	,@pROLE_ID int
	,@pIsGroupRoleID bit
	,@pAddedBy nvarchar(150)
	,@pReturn_Code bit output
	,@pReturn_Text nvarchar(1000) output
	,@pExecution_Error nvarchar(1000) output
	,@pError_Text nvarchar(max) output
	,@pIsBeginTransaction bit = 1
	,@pSource_MTV_ID int = 167100
AS
BEGIN
	
	set @pUserName = upper(@pUserName)
	set @pAddedBy = upper(@pAddedBy)

	set @pReturn_Code = 0
	set @pReturn_Text = ''
	set @pExecution_Error = ''
	set @pError_Text = ''

	Begin Try

		if @pIsBeginTransaction = 1
		begin
			Begin Transaction
		end

		if exists(select URM_ID from [MSPL_DB].[dbo].[T_User_Role_Mapping] with (nolock) where USERNAME = @pUsername)
		begin
			
			update urm
			set urm.ROLE_ID = @pROLE_ID
			,urm.IsGroupRoleID = @pIsGroupRoleID
			,urm.ModifiedBy = @pAddedBy
			,urm.ModifiedOn = getutcdate()
			from [MSPL_DB].[dbo].[T_User_Role_Mapping] urm where urm.USERNAME = @pUsername

			set @pReturn_Code = 1
			set @pReturn_Text = 'Updated'
		end
		else
		begin
			insert into [MSPL_DB].[dbo].[T_User_Role_Mapping] (USERNAME, ROLE_ID, IsGroupRoleID, AddedBy)
			values (@pUsername, @pROLE_ID, @pIsGroupRoleID, @pAddedBy)
			set @pReturn_Code = 1
			set @pReturn_Text = 'Inserted'
		end

		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 1
		begin
			COMMIT; 
		end
		else if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0 and @pReturn_Code = 0
		begin
			ROLLBACK; 
		end

	End Try
	Begin catch
		if @pIsBeginTransaction = 1 and @@TRANCOUNT > 0
		begin
			ROLLBACK; 
		end
		Set @pError_Text = 'P_User_Role_Mapping_IU: ' + ERROR_MESSAGE()
	End catch


END
GO
/****** Object:  StoredProcedure [dbo].[P_User_Role_Mapping_IU_ChangeLog]    Script Date: 4/6/2024 6:57:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_User_Role_Mapping_IU_ChangeLog]
	@plogIsEdit bit 
	,@plogUserName nvarchar(150)
	,@plogSource_MTV_ID int
AS
BEGIN
	SET NOCOUNT ON;
	drop table if exists #JsonChangeLog
	Create Table #JsonChangeLog
	(ID [int] identity(1,1) NOT NULL
	,[AC_ID] [int] NOT NULL
	,[REF_NO] [nvarchar](150) NOT NULL
	,[AuditType_MTV_ID] [int] NOT NULL default 166124
	,[RefNo1] [nvarchar](50) NOT NULL
	,[RefNo2] [nvarchar](50) NOT NULL default ''
	,[RefNo3] [nvarchar](50) NOT NULL default ''
	,[OldValueHidden] [nvarchar](2000) NOT NULL
	,[NewValueHidden] [nvarchar](2000) NOT NULL
	,[OldValue] [nvarchar](2000) NOT NULL
	,[NewValue] [nvarchar](2000) NOT NULL
	,[Column_Name] [nvarchar](100) NOT NULL default ''
	,[Table_Name] [nvarchar](150) NOT NULL default ''
	,[Reason] [nvarchar](1000) NOT NULL default ''
	,[IsAuto] [bit] NOT NULL default 0
	,[Source_MTV_ID] [int] NOT NULL default 0
	,[TriggerDebugInfo] [nvarchar](4000) NULL
	,[ChangedBy] [nvarchar](150) NOT NULL)

	Begin Try
		if @plogIsEdit = 1
		begin
			insert into #JsonChangeLog ([AC_ID] ,[REF_NO] ,[RefNo1], [OldValueHidden] ,[NewValueHidden] ,[OldValue] ,[NewValue] 
			,[Column_Name] ,[Table_Name] ,[Source_MTV_ID] ,[TriggerDebugInfo], [ChangedBy])
			select [AC_ID] , [REF_NO] , RefNo1 ,[OldValueHidden]=isnull([OldValueHidden],''),[NewValueHidden]=isnull([NewValueHidden],'')
			,[OldValue]=isnull([OldValue],'') ,[NewValue]=isnull([NewValue],'') ,[Column_Name] ,[Table_Name]='T_User_Role_Mapping' ,[Source_MTV_ID] = @plogSource_MTV_ID
			,[TriggerDebugInfo] = 'P_User_Role_Mapping_IU_ChangeLog', [ChangedBy] = @plogUserName
			from (
				select ID = 0 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('ROLE_ID','T_User_Role_Mapping') , [REF_NO] = old.USERNAME
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.ROLE_ID ,[NewValueHidden]=new.ROLE_ID
				,[OldValue]=old.ROLEID_Name ,[NewValue]=new.ROLEID_Name ,[Column_Name]='ROLE_ID'
				from #JsonOldEditUserRoleMappingTable old inner join #JsonNewEditUserRoleMappingTable new on old.USERNAME = new.USERNAME
				union
				select ID = 1 ,[AC_ID] = [MSPL_DB].[dbo].[F_Get_AC_ID] ('IsGroupRoleID','T_User_Role_Mapping') , [REF_NO] = old.USERNAME
				,RefNo1=old.USERNAME ,[OldValueHidden]=old.IsGroupRoleID ,[NewValueHidden]=new.IsGroupRoleID
				,[OldValue]=old.IsGroupRoleID_Name ,[NewValue]=new.IsGroupRoleID_Name ,[Column_Name]='IsGroupRoleID'
				from #JsonOldEditUserRoleMappingTable old inner join #JsonNewEditUserRoleMappingTable new on old.USERNAME = new.USERNAME
			) ilv where ilv.[OldValue] <> ilv.[NewValue]
			order by ilv.RefNo1 ,ilv.ID
		end
		
		exec [MSPL_DB].[dbo].[P_Add_Change_Log_From_JsonChangeLog_Table]
	
	End Try
	Begin Catch
		exec [PPlus_DB].[dbo].[P_Auto_Emails_Send_IU_2] @AE_ID = 598,@Email_Subject = 'Add JsonChangeLog Table Error',@Email_Body = 'P_User_Role_Mapping_IU_ChangeLog Add JsonChangeLog Table Error' ,@Is_Error = 1,@Is_HTML = 1
		,@AEP_ID = 1,@Is_Attachment = 0,@Priority = 1,@Email_To = 'abdullah@gomwd.com',@Email_BCC = '',@Email_CC = '',@Is_Email_Ready = 1
	End Catch

END
GO
