USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Auto_Map_Order_Grid_Department]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[P_Auto_Map_Order_Grid_Department]
	
AS
BEGIN
	
	insert into [POMS_DB].[dbo].[T_Order_Detail_Grid_Department_Mapping] (ODGL_ID,D_ID,Sort_,IsExpand,IsActive,AddedBy)
	select odgl.ODGL_ID ,d.D_ID ,odgl.Sort_ ,odgl.IsExpand, odgl.IsActive, 'AUTOIMPORT'
	from [POMS_DB].[dbo].[T_Order_Detail_Grid_List] odgl with (nolock) 
	cross apply [POMS_DB].[dbo].[T_Department] d with (nolock)
	where not exists(select ODGL_ID from [POMS_DB].[dbo].[T_Order_Detail_Grid_Department_Mapping] odgdm with (nolock) where odgdm.D_ID = d.D_ID and odgdm.ODGL_ID = odgl.ODGL_ID)
	
END
GO
