
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
