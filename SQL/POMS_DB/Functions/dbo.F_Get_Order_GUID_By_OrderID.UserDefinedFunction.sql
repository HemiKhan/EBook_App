USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Order_GUID_By_OrderID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Order_GUID_By_OrderID] ('',10100640,'','ABDULLAH.ARSHAD',2,1,13,1)
-- select * from [POMS_DB].[dbo].[F_Get_Order_GUID_By_OrderID] ('',0,'105488369736','ABDULLAH.ARSHAD',2,1,13,1)
-- select * from [POMS_DB].[dbo].[F_Get_Order_GUID_By_OrderID] ('',100088,'','ABDULLAH.ARSHAD',2,1,13,1)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Order_GUID_By_OrderID]
(	
	@ORDER_GUID nvarchar(36)
	,@ORDER_ID int
	,@TRACKING_NO nvarchar(40)
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@IsCheckRights bit = 0
)
RETURNS @ReturnTable table
(ORDER_ID int
,TRACKING_NO nvarchar(40)
,ORDER_CODE_GUID nvarchar(36)
,GetRecordType_MTV_ID int
)
AS
begin
	
	set @ORDER_GUID = isnull(@ORDER_GUID,'')
	set @ORDER_ID = isnull(@ORDER_ID,0)
	set @TRACKING_NO = isnull(@TRACKING_NO,'')
	--MTV_ID	MT_ID	Name
	--147100	147		POMS Data
	--147101	147		POMS Archive Data
	--147102	147		POMS & Archive Data
	--147103	147		Pinnacle Data
	--147104	147		Pinnacle Archive Data
	--147105	147		Pinnacle & Archive Data

	insert into @ReturnTable (ORDER_ID ,TRACKING_NO ,ORDER_CODE_GUID ,GetRecordType_MTV_ID)
	SELECT o.[ORDER_ID] ,o.TRACKING_NO ,o.ORDER_CODE_GUID, GetRecordType_MTV_ID=(case when oad.[ORDER_ID] is null then 147100 else 147101 end)
	FROM [POMS_DB].[dbo].[T_Order] o with (nolock) 
	left join [POMS_DB].[dbo].[T_Order_Archive_Detail] oad with (nolock) on o.[ORDER_ID] = oad.[ORDER_ID]
	where o.ORDER_ID = @ORDER_ID or o.TRACKING_NO = @TRACKING_NO or o.ORDER_CODE_GUID = @ORDER_GUID

	if not exists(select * from @ReturnTable)
	begin
		Declare @ORDER_NO nvarchar(20) = ''
		if @ORDER_GUID <> '' and @ORDER_ID = 0 and @TRACKING_NO = ''
		begin
			set @ORDER_NO = isnull((select od.OrderNo from [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) where od.GUID_ = @ORDER_GUID),'')
		end
		else if @ORDER_ID > 0
		begin
			set @ORDER_NO = cast(@ORDER_ID as nvarchar(20))
		end

		insert into @ReturnTable (ORDER_ID ,TRACKING_NO ,ORDER_CODE_GUID ,GetRecordType_MTV_ID)
		SELECT od.OrderId ,sl.[Tracking No] ,od.GUID_, GetRecordType_MTV_ID=147103
		FROM [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
		inner join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) on sh.No_ = sl.[Document No]
		inner join [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) on sh.No_ = od.OrderNo
		where sl.[Document No] = @ORDER_NO or sl.[Tracking No] = @TRACKING_NO

		if not exists(select * from @ReturnTable)
		begin
			insert into @ReturnTable (ORDER_ID ,TRACKING_NO ,ORDER_CODE_GUID ,GetRecordType_MTV_ID)
			SELECT od.OrderId ,sl.[Tracking No] ,od.GUID_, GetRecordType_MTV_ID=147104
			FROM [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
			inner join [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Linkup] sl with (nolock) on sh.No_ = sl.[Document No]
			inner join [PinnacleProd].[dbo].[Metro_OrderData] od with (nolock) on sh.No_ = od.OrderNo
			where sl.[Document No] = @ORDER_NO or sl.[Tracking No] = @TRACKING_NO
		end
	end

	if exists(select * from @ReturnTable) and @IsCheckRights = 1
	begin
		Declare @GetRecordType_MTV_ID int = 0
		Declare @AccessReturnCode bit = 0
		Declare @AccessReturnText nvarchar(250) = ''
		select @ORDER_ID = ORDER_ID ,@GetRecordType_MTV_ID = GetRecordType_MTV_ID from @ReturnTable
		select @AccessReturnCode = ReturnCode, @AccessReturnText = ReturnText from [POMS_DB].[dbo].[F_Get_OrderAccess_By_GUID] ('' ,@ORDER_ID ,@UserName ,@UserType_MTV_CODE ,@GetRecordType_MTV_ID)
		set @AccessReturnCode = isnull(@AccessReturnCode,0)
		set @AccessReturnText = isnull(@AccessReturnText,'')
		if @AccessReturnCode != 1
		begin
			delete from @ReturnTable
		end
	end

	return
	

end
GO
