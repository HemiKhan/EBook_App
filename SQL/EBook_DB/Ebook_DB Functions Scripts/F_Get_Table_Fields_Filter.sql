
-- select * from [dbo].[F_Get_Table_Fields_Filter] ('')
create FUNCTION [dbo].[F_Get_Table_Fields_Filter]
(	
	@Json nvarchar(max)
)
returns @ReturnTable table
(Code nvarchar(150)
,[Name] nvarchar(150)
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

	insert into @ReturnTable (Code ,[Name] ,IsFilterApplied)
	select distinct * from (
		select Code = isnull(ret.Code,'')
		,[Name] = isnull(ret.[Name],'')
		,IsFilterApplied = isnull(ret.IsFilterApplied,0)

		from OpenJson(@Json)
		WITH (
			Code nvarchar(150) '$.Code'
			,[Name] nvarchar(1000) '$.Name'
			,IsFilterApplied bit '$.IsFilterApplied'
		) ret
	) ilv where Code <> '' and IsFilterApplied = 1
	
	return

end
GO
