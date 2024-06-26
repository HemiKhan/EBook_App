USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_PlainText_From_HTMLString]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =========================================================================
-- ==========================================================================

create FUNCTION [dbo].[F_Get_PlainText_From_HTMLString]
(
	@HTMLString nvarchar(max)
)
RETURNS nvarchar(max)

AS

BEGIN

	Declare @Ret nvarchar(max) = ''

	set @Ret = CAST('<root>' + @HTMLString + '</root>' AS XML).value('.', 'nvarchar(max)')

	return @Ret

END
GO
