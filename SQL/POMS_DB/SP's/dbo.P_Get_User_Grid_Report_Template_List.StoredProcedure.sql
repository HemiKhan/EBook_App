USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Get_User_Grid_Report_Template_List]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- P_Get_User_Grid_Report_Template_List 'ABDULLAH.ARSHAD', 1
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_User_Grid_Report_Template_List]
	@Username nvarchar(150)
	,@GRL_ID int
	,@GRGUID nvarchar(36) = ''

AS
BEGIN
	
	set @Username = upper(@Username)
	set @GRL_ID = isnull(@GRL_ID,0)
	set @GRGUID = isnull(@GRGUID,'')

	if (@GRL_ID = 0 and @GRGUID <> '')
	begin
		select @GRL_ID = rl.GRL_ID from [POMS_DB].[dbo].[T_Grid_Reports_List] rl with (nolock) where rl.GUID_ = @GRGUID
	end

	select [value]=urtl.GUID_ ,[text]=urtl.[Name]
	from [POMS_DB].[dbo].[T_Grid_Reports_List] rl with (nolock) 
	inner join [POMS_DB].[dbo].[T_User_Grid_Reports_Template_List] urtl with (nolock) on rl.GRL_ID = urtl.GRL_ID
	where rl.GRL_ID = @GRL_ID and rl.IsActive = 1 and urtl.IsActive = 1 and urtl.USERNAME = @Username order by urtl.[Name]

END
GO
