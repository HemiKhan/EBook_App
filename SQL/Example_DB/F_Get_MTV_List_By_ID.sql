-- SELECT * FROM [dbo].[F_Get_MTV_List_By_ID] (100)
CREATE FUNCTION [dbo].[F_Get_MTV_List_By_ID]
(	
	@MT_ID int
	,@Username nvarchar(150) = null
)
returns @ReturnTable table
(MT_ID int
,[Name] nvarchar(100)
,MTV_ID int
,MTV_CODE nvarchar(20)
,[SubName] nvarchar(100)
,Sort_ int
)
AS
Begin

	insert into @ReturnTable
	select 
	MT_ID = mt.MT_ID
	,[Name] = mt.[Name]
	,MTV_ID = mtv.MTV_ID
	,MTV_CODE = mtv.MTV_CODE
	,[SubName] = mtv.[Name]
	,Sort_ = mtv.Sort_
	from [dbo].[T_Master_Type] mt 
	left join [dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = @MT_ID
	order by Sort_

	return

end
GO