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