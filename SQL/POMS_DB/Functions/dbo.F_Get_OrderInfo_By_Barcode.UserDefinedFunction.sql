USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_OrderInfo_By_Barcode]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_OrderInfo_By_Barcode] ('1234567891234567','ABDULLAH.ARSHAD')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_OrderInfo_By_Barcode]
(	
	@BARCODE nvarchar(20)
	,@UserName nvarchar(150)
)
RETURNS @ReturnTable TABLE 
(ORDER_ID int,
TRACKING_NO nvarchar(20),
OI_ID int,
RelabelCount int,
GetRecordType_MTV_ID int
)
AS
begin
	
	--MTV_ID	MT_ID	Name
	--147100	147		POMS Data
	--147101	147		POMS Archive Data
	--147102	147		POMS & Archive Data
	--147103	147		Pinnacle Data
	--147104	147		Pinnacle Archive Data
	--147105	147		Pinnacle & Archive Data

	set @UserName = upper(@UserName)

	Declare @ORDER_ID int = 0
	Declare @OI_ID int = 0
	Declare @TRACKING_NO nvarchar(20) = ''
	Declare @GetRecordType_MTV_ID  int = 0
	Declare @RelabelCount int = null

	if (len(@BARCODE) > 12)
	begin
		set @TRACKING_NO = left(@BARCODE,12)
	end
	
	if (@GetRecordType_MTV_ID = 0)
	begin
		if (@ORDER_ID = 0)
		begin
			select @ORDER_ID = sl.[Document No] from [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) where sl.[Tracking No] = @TRACKING_NO
			set @ORDER_ID = isnull(@ORDER_ID,0)
			if (@ORDER_ID > 0)
			begin
				set @GetRecordType_MTV_ID = 147103
				select @OI_ID = sll.[ID] from [PinnacleProd].[dbo].[Metropolitan$Sales Line Link] sll with (nolock) where sll.[Item Tracking No] = @BARCODE
			end
		end

		if (@ORDER_ID = 0)
		begin
			select @ORDER_ID = sl.[Document No] from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) where sl.[Tracking No] = @TRACKING_NO
			set @ORDER_ID = isnull(@ORDER_ID,0)
			if (@ORDER_ID > 0)
			begin
				set @GetRecordType_MTV_ID = 147104
				select @OI_ID = sll.[ID] from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Line Link] sll with (nolock) where sll.[Item Tracking No] = @BARCODE
			end
		end

		if (@ORDER_ID = 0)
		begin
			select @ORDER_ID = o.[ORDER_ID] from [POMS_DB].[dbo].[T_Order] o with (nolock) where o.[TRACKING_NO] = @TRACKING_NO
			set @ORDER_ID = isnull(@ORDER_ID,0)
			if (@ORDER_ID > 0)
			begin
				set @GetRecordType_MTV_ID = 147100
				select @OI_ID = oi.OI_ID, @RelabelCount = RelabelCount from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.[BARCODE] = @BARCODE
			end
		end

		if (@ORDER_ID = 0)
		begin
			select @ORDER_ID = o.[ORDER_ID] from [POMSArchive_DB].[dbo].[T_Order] o with (nolock) where o.[TRACKING_NO] = @TRACKING_NO
			set @ORDER_ID = isnull(@ORDER_ID,0)
			if (@ORDER_ID > 0)
			begin
				set @GetRecordType_MTV_ID = 147101
				select @OI_ID = oi.OI_ID, @RelabelCount = RelabelCount from [POMSArchive_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.[BARCODE] = @BARCODE
			end
		end
	end

	if (@ORDER_ID = 0)
	begin
		set @TRACKING_NO = ''
	end

	insert into @ReturnTable (ORDER_ID, TRACKING_NO, OI_ID, GetRecordType_MTV_ID, RelabelCount)
	values (@ORDER_ID,@TRACKING_NO,@OI_ID,@GetRecordType_MTV_ID,@RelabelCount)

	return

end
GO
