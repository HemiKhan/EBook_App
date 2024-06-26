USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_ServiceLevelName_From_ST_CODE]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_ServiceLevelName_From_ST_CODE]  
(
	@ST_CODE nvarchar(20)
)
RETURNS nvarchar(100)
AS
BEGIN
	
	Declare @Ret nvarchar(100) = ''

	if isnull(@ST_CODE,'') != ''
	begin
		select @Ret = [ServiceName] from [POMS_DB].[dbo].[T_Service_Type] with (nolock) where ST_CODE = @ST_CODE
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
