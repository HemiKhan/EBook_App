
-- select * from [POMS_DB].[dbo].[F_Get_Table_Hidden_Fields_Filter] ('')
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
