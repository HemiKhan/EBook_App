USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_GetTMSDropDownGrids_Lists]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
  
 --Exec P_GetTMSDropDownGrids_Lists
CREATE Procedure [dbo].[P_GetTMSDropDownGrids_Lists]

As 
Begin

--SELECT code = T_ID, [name] = TaskName FROM [POMS_DB].[dbo].[T_TMS_Tasks] WITH (NOLOCK) WHERE IsActive = 1
-- Application 
 select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [POMS_DB].[dbo].[T_Master_Type] mt 
	left join [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 148
	order by Sort_

	--page name
	SELECT [value] = P_ID, [text] = PageName FROM [POMS_DB].[dbo].[T_Page] WITH (NOLOCK) WHERE IsActive = 1

	--priority list
	select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [POMS_DB].[dbo].[T_Master_Type] mt 
	left join [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 176
	order by Sort_

	--Status List
	 select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [POMS_DB].[dbo].[T_Master_Type] mt 
	left join [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 175
	order by Sort_

	--Task Category
	 select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [POMS_DB].[dbo].[T_Master_Type] mt 
	left join [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 177
	order by Sort_
	-- Build StatusList
	select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [POMS_DB].[dbo].[T_Master_Type] mt 
	left join [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 186
	order by Sort_

	-- Assign To Type List
	select 
	 [value] = mtv.MTV_CODE
	,[text] = mtv.[Name]
	from [POMS_DB].[dbo].[T_Master_Type] mt 
	left join [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) on mt.MT_ID = mtv.MT_ID where mt.IsActive = 1 and mtv.IsActive = 1
	and mt.MT_ID = 180
	order by Sort_

	END
GO
