USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Grid_Report_Template_Column]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [dbo].[F_Get_Grid_Report_Template_Column] ('')
-- =============================================
create FUNCTION [dbo].[F_Get_Grid_Report_Template_Column]
(	
	@Json nvarchar(max)
)
returns @ReturnTable table
(GRC_ID int
,[SortPosition] int)
AS
Begin
	
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

	insert into @ReturnTable (GRC_ID ,[SortPosition])
	select GRC_ID = isnull(GRC_ID,0)
	,[SortPosition] = isnull([SortPosition],9999)

	from OpenJson(@Json)
	WITH (
		GRC_ID int '$.GRC_ID'
		,SortPosition int '$.SortPosition'
	) ret
	
	return

end
GO
