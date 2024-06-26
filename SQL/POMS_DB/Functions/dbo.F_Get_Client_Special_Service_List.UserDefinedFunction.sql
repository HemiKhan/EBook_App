USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_Client_Special_Service_List]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_Client_Special_Service_List] ('WG', '42A988E7-12FA-48B6-BF38-EF900E6ED9AB', 'S100052', 'GlobalTranz')
-- =============================================
CREATE FUNCTION [dbo].[F_Get_Client_Special_Service_List]
(	
	@ST_CODE nvarchar(20)
	,@SELLER_KEY nvarchar(36)
	,@SELLER_CODE nvarchar(20) = null
	,@SELLER_NAME nvarchar(250) = null
)
returns @ReturnTable table
(SellerKey nvarchar(36)
,SellerCode nvarchar(20)
,SellerName nvarchar(250)
,SLSS_ID int
,ST_CODE nvarchar(20)
,SSL_CODE nvarchar(20)
,[Name] nvarchar(250)
,IsAvailableForPickup bit
,IsAvailableForDelivery bit
,IsReqMints bit
,IsFloorsRequired bit
,IsDaysRequired bit
,IsEstAmountRequired bit
,IsFromDateRequired bit
,IsToDateRequired bit
,IsManRequired bit
,IsDefaultMintsZero bit
,IsDefaultDaysZero bit
,IsDefaultEstAmountZero bit
,IsDefaultFromDateNULL bit
,IsDefaultToDateNULL bit
,IsDefaultManZero bit
,IsOpted bit
,IsActive bit
)
AS
Begin

	set @SELLER_KEY = isnull(@SELLER_KEY,'')

	Declare @SellerTable table (SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250))
	
	if @SELLER_CODE is null
	begin
		insert into @SellerTable
		select SellerKey , SellerCode , SellerName  from [POMS_DB].[dbo].[F_Get_SellToClientList] (@SELLER_KEY,null)
	end
	else
	begin
		insert into @SellerTable
		select @SELLER_KEY, @SELLER_CODE, @SELLER_NAME
	end

	insert into @ReturnTable 
	select ilv.SellerKey
	,ilv.SellerCode
	,ilv.SellerName
	,ilv.SLSS_ID
	,ilv.ST_CODE
	,ilv.SSL_CODE
	,ilv.[Name]
	,ilv.IsAvailableForPickup
	,ilv.IsAvailableForDelivery
	,ilv.IsReqMints
	,ilv.IsFloorsRequired
	,ilv.IsDaysRequired
	,ilv.IsEstAmountRequired
	,ilv.IsFromDateRequired
	,ilv.IsToDateRequired
	,ilv.IsManRequired
	,ilv.IsDefaultMintsZero
	,ilv.IsDefaultDaysZero
	,ilv.IsDefaultEstAmountZero
	,ilv.IsDefaultFromDateNULL
	,ilv.IsDefaultToDateNULL
	,ilv.IsDefaultManZero
	,ilv.IsOpted
	,ilv.IsActive
	from (Select c.SellerKey
	,c.SellerCode
	,c.SellerName
	,slss.SLSS_ID
	,slss.ST_CODE
	,slss.SSL_CODE
	,ssl_.[Name]
	,slss.IsAvailableForPickup
	,slss.IsAvailableForDelivery
	,ssl_.IsReqMints
	,ssl_.IsFloorsRequired
	,ssl_.IsDaysRequired
	,ssl_.IsEstAmountRequired
	,ssl_.IsFromDateRequired
	,ssl_.IsToDateRequired
	,ssl_.IsManRequired
	,ssl_.IsDefaultMintsZero
	,ssl_.IsDefaultFloorZero
	,ssl_.IsDefaultDaysZero
	,ssl_.IsDefaultEstAmountZero
	,ssl_.IsDefaultFromDateNULL
	,ssl_.IsDefaultToDateNULL
	,ssl_.IsDefaultManZero
	,slss.IsOpted
	,slss.IsActive
	FROM [POMS_DB].[dbo].[T_Service_Level_Special_Service] slss with (nolock)
	inner join [POMS_DB].[dbo].[T_Special_Services_List] ssl_ with (nolock) on slss.SSL_CODE = ssl_.SSL_CODE
	cross apply @SellerTable c 
	where slss.ST_CODE = @ST_CODE and ssl_.IsActive = 1 and ssl_.IsAllowed = 1
	) ilv left join [POMS_DB].[dbo].[T_Client_Service_Level_Special_Service] cslss with (nolock) on ilv.SLSS_ID = cslss.SLSS_ID and ilv.SellerCode = cslss.SELLER_CODE
	where isnull(cslss.IsActive,ilv.IsActive) = 1

	return

end
GO
