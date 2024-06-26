USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_JsonClientIdentifierTable]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_JsonClientIdentifierTable] ('C100052')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_JsonClientIdentifierTable]
(	
	@Json nvarchar(max)
)
RETURNS @ReturnTable TABLE 
(OIF_CODE nvarchar(50)
,Value_ nvarchar(50)
)
AS
begin
	
	set @Json = isnull(@Json,'')

	if @Json = ''
	begin
		return
	end
	else
	begin
		if ISJSON(@Json) = 0
		begin
			return
		end
	end
	
	insert into @ReturnTable
	select RefInfo.*
	from OpenJson(@Json)
	WITH (
		OIF_CODE nvarchar(50) '$.code'
		,Value_ nvarchar(50) '$.value'
	) RefInfo

	return

end
GO
