USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_MasterTypeValue_From_MTV_ID_And_MT_ID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_MasterTypeValue_From_MTV_ID_And_MT_ID]  
(
	@MTV_ID int
	,@MT_ID int
	,@IsActive bit = 1
)
RETURNS nvarchar(50)
AS
BEGIN
	
	Declare @Ret nvarchar(50) = ''

	if isnull(@MTV_ID,0) != 0 and isnull(@MT_ID,0) != 0
	begin
		select @Ret = [Name] from [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_ID = @MTV_ID and MT_ID = @MT_ID and (@IsActive is null or IsActive = @IsActive)
		set @Ret = isnull(@Ret,'')
	end

	return @Ret
END
GO
