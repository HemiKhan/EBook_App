USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_UserDetail]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_UserDetail] ('ABDULLAH.ARSHAD')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_UserDetail]
(	
	@Username nvarchar(250)
)
RETURNS @UserTable TABLE 
([Username] nvarchar(150) ,[Entity type] int ,[Web Role] nvarchar(250) ,[Blocked] int ,[Customer No_] nvarchar(20) ,[Web UserID] int
,[Dynamics UserName] nvarchar(150) ,[LastSelectedClient] nvarchar(20) ,[Time Zone ID] int,[APIAccess] bit)
AS
begin

	insert into @UserTable ([Username],[Entity type],[Web Role],[Blocked],[Customer No_],[Web UserID],[Dynamics UserName],[LastSelectedClient],[Time Zone ID],[APIAccess])
	select [Username],[Entity type],[Web Role],[Blocked],[Customer No_],[Web UserID],[Dynamics UserName],[LastSelectedClient],[Time Zone ID],[APIAccess] 
	from [MetroPolitanNavProduction].[dbo].[Metropolitan$Web User Login] with (nolock) where Username = upper((@username))
	
	return
	

end
GO
