USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_DepartmentName_From_D_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[F_Get_DepartmentName_From_D_ID]  
(
	@D_ID int
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@D_ID,0) != 0
	begin
		select @Ret = [DepartmentName] from [POMS_DB].[dbo].[T_Department] with (nolock) where D_ID = @D_ID
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
