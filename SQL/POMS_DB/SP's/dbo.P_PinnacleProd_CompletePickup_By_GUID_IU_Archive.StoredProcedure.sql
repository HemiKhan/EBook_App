USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_PinnacleProd_CompletePickup_By_GUID_IU_Archive]    Script Date: 4/19/2024 9:44:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_PinnacleProd_CompletePickup_By_GUID_IU_Archive]
	-- Add the parameters for the stored procedure here
	@ORDER_ID int

	,@pUser_Name nvarchar(150)

	,@Source_MTV_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@IsPublic bit
	,@TimeZone_ID int
	,@GetRecordType_MTV_ID int
	,@pReturnCode bit output
	,@pReturnText nvarchar(250) output
AS
BEGIN
	
set @pReturnCode = 0
Declare @OrderNo nvarchar(20) = cast(@ORDER_ID as nvarchar(20))
set @UserName = upper(@UserName)

Declare @EventCode int = 18
Declare @Sch_Date date
Declare @UpdateActualDate datetime
Declare @ActualPickupDate datetime
Declare @CustomerNo nvarchar(20)
Declare @OrderStatus int = 0

if not exists(select ID from PinnacleProd.[dbo].[Metropolitan$Event Master Log] where EventID=@EventCode and [Order Number]=@OrderNo)
begin
	select @CustomerNo=SH.[Bill-to Customer No_]
		  ,@OrderStatus=SH.[Order Status]
		  ,@Sch_Date=Case When Year(SL.[Promised Pickup Date]) < 1950 Then null ELSE SL.[Promised Pickup Date] END
		--,@ActualPickupDate=Case When Year(SL.[Pickup Completed Date]) < 1950 Then null ELSE cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), SL.[Pickup Completed Date]  ) as datetime) END
	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] SH with(nolock) 
	inner join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] SL with(nolock) on SH.No_ = SL.[Document No] where SH.No_ = @OrderNo

	Select @pReturnText = (case when @OrderStatus <> 10000 then 'Order Status is Not Active'
	when cast(@Sch_Date as date) > cast(getutcdate() as date) then 'Cannot Complete Pickup In Future Date'
	when @Sch_Date is null then 'Order is Not Schedule for Pickup'
	else '' end)

	if @pReturnText = ''
	begin
		select @UpdateActualDate = DATEADD(hour,12,cast(@Sch_Date as datetime)) 						
		update PinnacleProd.[dbo].[Metropolitan$Sales Linkup] set [Pickup Completed Date]=@UpdateActualDate,[Pickup Completed]=1 where [Document No]=@OrderNo
		update [PinnacleProd].[dbo].[Metropolitan$Sales Line Link]	set [Item Pickup Status]=1 where [Sales Order No]=@OrderNo and [Document Type]=1
		EXECUTE PinnacleProd.[dbo].[Metro_InsertUpdateOrderInfoEventTriggered] @EventCode,0,0,0,@UserName,1,'10000','ShippingStatus/OrderDetail/UpdateShippingStatus',@UserName,@OrderNo,@CustomerNo,'','',''				
		set @pReturnCode = 1
	end
end
else
begin
	select 
		@CustomerNo=SH.[Bill-to Customer No_]
		,@OrderStatus=SH.[Order Status]
		,@Sch_Date=Case When Year(SL.[Promised Pickup Date]) < 1950 Then null ELSE SL.[Promised Pickup Date] END
		--,@ActualPickupDate=Case When Year(SL.[Pickup Completed Date]) < 1950 Then null ELSE cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), SL.[Pickup Completed Date]  ) as datetime) END
	from [PinnacleProd].[dbo].[Metropolitan$Sales Header] SH with(nolock) 
	inner join [PinnacleProd].[dbo].[Metropolitan$Sales Linkup] SL with(nolock) on SH.No_ = SL.[Document No] where SH.No_ = @OrderNo

	Select @pReturnText = (case when @OrderStatus <> 10000 then 'Order Status is Not Active'
	when cast(@Sch_Date as date) > cast(getutcdate() as date) then 'Cannot Complete Pickup In Future Date'
	when @Sch_Date is null then 'Order is Not Schedule for Pickup'
	else '' end)

	set @pReturnCode = 0
end

if (@pReturnCode = 1)
begin
	Select Return_Code = @pReturnCode, Return_Text = @pReturnText
	,[shippingstatus] = isnull((select top 1 evm.[Events] from [PinnacleProd].[dbo].[Metropolitan$Event Master] evm with (nolock) where evm.[Entry No] = sh.[Shipping Status]), '')
	,[actualpickupdate] = case when year(sl.[Pickup Completed Date]) < 2000 then null else [PinnacleProd].[dbo].[F_Get_Datetime_From_TZ_ID](sl.[Pickup Completed Date],@TimeZone_ID,-14400000) end
	From PinnacleProd.[dbo].[Metropolitan$Sales Linkup] sl with (nolock)
	inner join PinnacleProd.[dbo].[Metropolitan$Sales Header] sh with (nolock) on sl.[Document No] = sh.No_
	where sl.[Document No]=@OrderNo
end
else
begin
	select Return_Code = @pReturnCode, Return_Text = @pReturnText
end

END
GO
