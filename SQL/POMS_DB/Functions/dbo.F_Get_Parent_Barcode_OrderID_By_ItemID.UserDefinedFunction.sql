USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Parent_Barcode_OrderID_By_ItemID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Parent_Barcode_OrderID_By_ItemID] (1051212)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Parent_Barcode_OrderID_By_ItemID]
(	
	@PARENT_OI_ID int
)
RETURNS @ReturnTable TABLE 
(OrderID int, Barcode nvarchar(20))
AS
begin

	set @PARENT_OI_ID = isnull(@PARENT_OI_ID,0)

	if @PARENT_OI_ID <> 0
	begin
		insert into @ReturnTable
		select ORDER_ID, BARCODE
		from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.OI_ID = @PARENT_OI_ID
		
		if not exists(select * from @ReturnTable)
		begin
			insert into @ReturnTable
			select ORDER_ID, BARCODE
			from [POMSArchive_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.OI_ID = @PARENT_OI_ID
		end
	end

	return
	

end
GO
