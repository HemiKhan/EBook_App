USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_ShipmentType_From_ServiceLevel]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[F_Get_ShipmentType_From_ServiceLevel]  
(
	@ST_CODE nvarchar(20)
)
RETURNS int
AS
BEGIN
	
	Declare @Ret int = 0
	select @Ret = [Type_MTV_ID] from [POMS_DB].[dbo].[T_Service_Type] with (nolock) where [ST_CODE] = @ST_CODE
	set @Ret = isnull(@Ret,0)

	return @Ret
END
GO
