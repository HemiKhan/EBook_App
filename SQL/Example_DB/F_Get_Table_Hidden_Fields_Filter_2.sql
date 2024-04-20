
-- select * from [POMS_DB].[dbo].[F_Get_Table_Hidden_Fields_Filter_2] ('')
Create FUNCTION [dbo].[F_Get_Table_Hidden_Fields_Filter_2]
(	
	@Json nvarchar(max)
)
returns @ReturnTable table
(Code nvarchar(150)
,IsFilterApplied bit
,IsList bit 
,[Value] nvarchar(1000)
,ListType int
,Logic nvarchar(50)
,[Type] nvarchar(50)
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

	insert into @ReturnTable (Code ,IsFilterApplied ,IsList ,[Value] ,ListType ,Logic ,[Type])
	select * from (
		select Code = isnull(ret.Code,'')
		,IsFilterApplied = isnull(ret.IsFilterApplied,0)
		,IsList = isnull(IsList,0)
		,[Value] = isnull([Value],'')
		,ListType = isnull(ListType,0)
		,Logic = isnull(Logic,'')
		,[Type] = isnull([Type],'')
		from OpenJson(@Json)
		WITH (
			Code nvarchar(150) '$.Code'
			,IsFilterApplied bit '$.IsFilterApplied'
			,ReportFilterObjectArry nvarchar(max) '$.reportFilterObjectArry' as json
		) ret
		CROSS APPLY openjson (ret.ReportFilterObjectArry,'$') 
		WITH (
			IsList bit '$.IsList'
			,[Value] nvarchar(1000) '$.Value'
			,ListType int '$.ListType'
			,Logic nvarchar(50) '$.Logic'
			,[Type] nvarchar(50) '$.Type'
		) ret2
	) ilv where Code <> ''
	
	return

end
GO