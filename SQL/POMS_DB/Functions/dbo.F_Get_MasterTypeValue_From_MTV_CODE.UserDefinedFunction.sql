USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_MasterTypeValue_From_MTV_CODE]    Script Date: 4/19/2024 9:46:08 PM ******/
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
		select @Ret = [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_CODE = @MTV_CODE
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
