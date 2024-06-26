USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Sub_OrderType_List]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Sub_OrderType_List] (146101,'ABDULLAH.ARSHAD')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Sub_OrderType_List]
(	
	@OrderType_MTV_ID int
	,@Username nvarchar(150) = null
)
returns @ReturnTable table
(MTV_ID int
,ID int
,[Name] nvarchar(100)
)
AS
Begin

	insert into @ReturnTable
	select 
	MTV_ID = sotv.OrderType_MTV_ID
	,ID = sotv.SubOrderType_ID
	,[Name] = sotv.[Name]
	from [POMS_DB].[dbo].[T_Sub_Order_Type_Value] sotv with (nolock) where sotv.IsActive = 1 and sotv.OrderType_MTV_ID = @OrderType_MTV_ID
	order by ID

	return

end
GO
