USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Table_Hidden_Fields_Filter]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Table_Hidden_Fields_Filter] ('')
-- =============================================
Create FUNCTION [dbo].[F_Get_Table_Hidden_Fields_Filter]
(	
	@Json nvarchar(max)
)
returns @ReturnTable table
(Code nvarchar(150)
,fieldvalue nvarchar(1000)
,IsFilterApplied bit
)
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

	insert into @ReturnTable (Code ,fieldvalue ,IsFilterApplied)
	select * from (
		select Code = isnull(ret.Code,'')
		,fieldvalue = isnull(ret.fieldvalue,'')
		,IsFilterApplied = isnull(ret.IsFilterApplied,0)

		from OpenJson(@Json)
		WITH (
			Code nvarchar(150) '$.Code'
			,fieldvalue nvarchar(1000) '$.fieldvalue'
			,IsFilterApplied bit '$.IsFilterApplied'
		) ret
	) ilv where Code <> ''
	
	return

end
GO
