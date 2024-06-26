USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_FullName_And_Dept_By_Userid]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_FullName_And_Dept_By_Userid] (934)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_FullName_And_Dept_By_Userid]
(	
	@Userid int
)
RETURNS @ReturnTable TABLE 
(Username nvarchar(150), FullName nvarchar(250), DeptName nvarchar(50))
AS
begin

	set @Userid = isnull(@Userid,0)

	if @Userid <> 0
	begin
		insert into @ReturnTable
		select UserName = u.USERNAME
		,FullName = (case when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.MiddleName + ' ' + u.LastName
			when isnull(u.FirstName,'') = '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') <> '' then u.MiddleName + ' ' + u.LastName
			when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') = '' and isnull(u.LastName,'') <> '' then u.FirstName + ' ' + u.LastName
			when isnull(u.FirstName,'') <> '' and isnull(u.MiddleName,'') <> '' and isnull(u.LastName,'') = '' then u.FirstName + ' ' + u.MiddleName
			else u.USERNAME end)
		,DeptName = (select top 1 DepartmentName from [POMS_DB].[dbo].[T_Department] d with (nolock) where d.D_ID = u.D_ID) 
		from [POMS_DB].[dbo].[T_Users] u with (nolock) where u.[USER_ID] = @Userid
	end

	return
	

end
GO
