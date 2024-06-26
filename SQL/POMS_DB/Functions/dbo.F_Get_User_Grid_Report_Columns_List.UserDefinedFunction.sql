USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_User_Grid_Report_Columns_List]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [dbo].[F_Get_User_Grid_Report_Columns_List] (1,0, '','','ABDULLAH.ARSHAD','')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_User_Grid_Report_Columns_List]
(	
	@GRL_ID int
	,@UGRTL_ID int
	,@GRGUID nvarchar(36)
	,@UGRCGUID nvarchar(36)
	,@Username nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
)
RETURNS @ReturnTable TABLE 
(NewSortID int identity(1,1), UGRTL_ID int, GRLID int, GRGUID_ nvarchar(36), GRName nvarchar(250), GRCID int, GRCGUID_ nvarchar(36), Code nvarchar(50), GRCName nvarchar(150), UGRCName nvarchar(150), IsHidden bit, IsChecked bit, SortPosition int, IsPublic bit)
AS
begin
	
	set @GRL_ID = isnull(@GRL_ID,0)
	set @UGRTL_ID = isnull(@UGRTL_ID,0)
	set @GRGUID = lower(isnull(@GRGUID,''))
	set @UGRCGUID = lower(isnull(@UGRCGUID,''))
	set @Username = upper(@Username)
	set @UserType_MTV_CODE = isnull(@UserType_MTV_CODE,'')

	if (@UserType_MTV_CODE = '')
	begin
		select @UserType_MTV_CODE = UserType_MTV_CODE from [POMS_DB].[dbo].[T_Users] u with (nolock) where u.USERNAME = @Username
		set @UserType_MTV_CODE = isnull(@UserType_MTV_CODE,'')
	end

	insert into @ReturnTable (UGRTL_ID ,GRLID ,GRGUID_ ,GRName ,GRCID ,GRCGUID_ ,Code ,GRCName ,UGRCName ,IsHidden ,IsChecked ,SortPosition ,IsPublic)
		select UGRTL_ID=urtl.UGRTL_ID
		, GRLID=rl.GRL_ID
		, GRGUID_=rl.GUID_
		, GRName=rl.[Name]
		, GRCID=rc.GRC_ID
		, GRCGUID_=rc.GUID_
		, Code=rc.Code
		, GRCName=rc.[Name]
		, UGRCName=urtl.[Name]
		, IsHidden=isnull(urc.IsHidden,rc.IsHidden)
		, IsChecked=(case when (@UGRCGUID <> '' or @UGRTL_ID <> 0) then isnull(urc.IsChecked,0) else rc.IsChecked end)
		, SortPosition=isnull(urc.SortPosition,rc.SortPosition)
		, IsPublic=rc.IsPublic
		from [POMS_DB].[dbo].[T_Grid_Reports_List] rl with (nolock) 
		inner join [POMS_DB].[dbo].[T_Grid_Report_Columns] rc with (nolock) on rl.GRL_ID = rc.GRL_ID
		left join [POMS_DB].[dbo].[T_User_Grid_Reports_Template_List] urtl with (nolock) on rl.GRL_ID = urtl.GRL_ID and (@UGRCGUID <> '' or @UGRTL_ID <> 0)
		left join [POMS_DB].[dbo].[T_User_Grid_Report_Columns] urc with (nolock) on urtl.UGRTL_ID = urc.UGRTL_ID and rc.GRC_ID = urc.GRC_ID and (@UGRCGUID <> '' or @UGRTL_ID <> 0)
		where ((rl.GRL_ID = @GRL_ID and @GRL_ID <> 0) or (rl.GUID_ = @GRGUID and @GRGUID <> '') or (urtl.UGRTL_ID = @UGRTL_ID and @UGRTL_ID <> 0) or (urtl.GUID_ = @UGRCGUID and @UGRCGUID <> ''))
		and rl.IsActive = 1 and rc.IsActive = 1 
		and (rc.IsPublic = 1 or (rc.IsPublic = 0 and @UserType_MTV_CODE = 'METRO-USER')) 
		and (urtl.USERNAME = @Username or urtl.USERNAME is null)
		order by isnull(urc.SortPosition,9999),rc.SortPosition,rc.GRC_ID
	
	return
	

end
GO
