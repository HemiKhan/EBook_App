USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_Pages_Info_By_User]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [dbo].[P_Get_Pages_Info_By_User] 'ABDULLAH.ARSHAD', 148100
CREATE PROCEDURE [dbo].[P_Get_Pages_Info_By_User] 
	-- Add the parameters for the stored procedure here
    @USERNAME nvarchar(150)
	,@Application_MTV_ID int 
	,@CurrentURL nvarchar(250) = ''
As
Begin
	
	DECLARE @Is_Admin bit = 0

	Declare @ROLE_ID int = 0
	Declare @IsGroupRoleID bit = 0
	
	select @ROLE_ID = ROLE_ID, @IsGroupRoleID = [IsGroupRoleID] FROM [POMS_DB].[dbo].[T_User_Role_Mapping] with (nolock) where USERNAME = @USERNAME and [IsActive] = 1

	Declare @RolesTable table (R_ID int)
	insert into @RolesTable
	select @ROLE_ID where @IsGroupRoleID = 0

	insert into @RolesTable
	select RG_ID from [POMS_DB].[dbo].[T_Role_Group_Mapping] with (nolock) where RG_ID = @ROLE_ID and @IsGroupRoleID = 1

	if exists(select * from @RolesTable where R_ID in (12,16))
	begin
		set @Is_Admin = 1
	end
	
	Declare @PageRightsTable table (P_ID int, PR_ID int, PG_ID int)
	if (@Is_Admin=0)
	begin
		insert into @PageRightsTable
		select p.P_ID, pr.PR_ID, p.PG_ID
		from [POMS_DB].[dbo].[T_Page_Rights] pr with (nolock) 
		inner join [POMS_DB].[dbo].[T_Page] p with (nolock) on pr.P_ID = p.P_ID
		where p.Application_MTV_ID in (@Application_MTV_ID,0) and pr.PageRightType_MTV_CODE='VIEW' and pr.IsActive = 1 and p.IsActive = 1
			and pr.PR_ID in (select rprm.PR_ID from [POMS_DB].[dbo].[T_Role_Page_Rights_Mapping] rprm with (nolock) where rprm.R_ID in (select * from @RolesTable))
	end

	drop table if exists #PageGroupTable
	select pg.PG_ID,pg.PageGroupName,pg.Sort_
	,FirstURL=isnull((select top 1 p.PageURL from [POMS_DB].[dbo].[T_Page] p with (nolock) where p.PG_ID = pg.PG_ID and p.Application_MTV_ID in (@Application_MTV_ID,0) order by p.Sort_),'')
	into #PageGroupTable
	from [POMS_DB].[dbo].[T_Page_Group] pg with (nolock) where pg.IsHide = 0 and pg.IsActive = 1 
		and ((pg.PG_ID in (select PG_ID from @PageRightsTable) and @Is_Admin = 0) or @Is_Admin = 1)
	Order by pg.Sort_

	set @CurrentURL = (case when left(@CurrentURL,1) = '/' then '' else '/' end) + @CurrentURL

	Declare @CurrentPG_ID int = 0
	Declare @CurrentP_ID int = 0
	select @CurrentPG_ID=p.PG_ID ,@CurrentP_ID=p.P_ID from [POMS_DB].[dbo].[T_Page] p with (nolock) where p.PageURL= @CurrentURL and p.Application_MTV_ID in (@Application_MTV_ID,0)

	select pg.PG_ID,pg.PageGroupName,pg.Sort_,pg.FirstURL
	,PageGroupSelected=(case when @CurrentPG_ID = pg.PG_ID then 'selected' else '' end)
	,PageGroupActive=(case when @CurrentPG_ID = pg.PG_ID then 'active' else '' end)
	,PageGroupActiveIn=(case when @CurrentPG_ID = pg.PG_ID then 'in' else '' end)
	,CurrentPG_ID=@CurrentPG_ID
	from #PageGroupTable pg where pg.FirstURL <> '' order by pg.Sort_

	select p.P_ID,p.PG_ID,p.PageName,p.PageURL,p.Sort_
	,PageActive=(case when @CurrentP_ID = p.P_ID then 'active' else '' end)
	,CurrentP_ID=@CurrentP_ID
	from [POMS_DB].[dbo].[T_Page] p with (nolock) 
	inner join [POMS_DB].[dbo].[T_Page_Group] pg with (nolock) on p.PG_ID = pg.PG_ID and pg.IsHide = 0 and pg.IsActive = 1
	where p.Application_MTV_ID in (@Application_MTV_ID,0) and p.IsHide = 0 and p.IsActive = 1
	and ((p.P_ID in (select P_ID from @PageRightsTable) and @Is_Admin = 0) or @Is_Admin = 1)
	Order by pg.Sort_,pg.PG_ID,p.Sort_
	
End


GO
