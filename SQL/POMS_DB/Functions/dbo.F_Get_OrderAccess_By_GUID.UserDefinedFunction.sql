USE [POMS_DB]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Get_OrderAccess_By_GUID]    Script Date: 4/19/2024 9:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- select * from [POMS_DB].[dbo].[F_Get_OrderAccess_By_GUID] ('78524624-5DA3-4307-B911-CB396117237E',0,'ABDULLAH.ARSHAD',2,0)
-- select * from [POMS_DB].[dbo].[F_Get_OrderAccess_By_GUID] ('81476343-24DE-48B6-B53F-FDFDB66BC616',0,'ABDULLAH.ARSHAD',2,0)
-- =============================================
CREATE FUNCTION [dbo].[F_Get_OrderAccess_By_GUID]
(	
	@OrderGUID nvarchar(36)
	,@ORDER_ID int
	,@UserName nvarchar(150)
	,@UserType_MTV_CODE nvarchar(20)
	,@GetRecordType_MTV_ID int
)
RETURNS @ReturnTable TABLE 
(ReturnCode bit, 
ReturnText nvarchar(250),
ORDER_ID int,
GetRecordType_MTV_ID int,
UserName nvarchar(150),
SELLER_CODE nvarchar(20),
SELLER_NAME nvarchar(250),
BillTo_CUSTOMER_NO nvarchar(20),
SUB_SELLER_CODE nvarchar(20),
SELLER_PARTNER_CODE nvarchar(20),
TARIFF_NO nvarchar(36),
IsViewOrder bit,
IsCreateOrder bit,
IsGetQuote bit,
IsFinancial bit,
IsAdmin bit,
IsSellerMapped bit,
IsBlankSubSellerAllowed bit,
IsAllSubSellerAllowed bit,
IsBlankPartnerAllowed bit,
IsAllPartnerAllowed bit,
IsBlankTariffAllowed bit,
IsAllTariffAllowed bit)
AS
begin
	
	--MTV_ID	MT_ID	Name
	--147100	147		POMS Data
	--147101	147		POMS Archive Data
	--147102	147		POMS & Archive Data
	--147103	147		Pinnacle Data
	--147104	147		Pinnacle Archive Data
	--147105	147		Pinnacle & Archive Data

	set @ORDER_ID = isnull(@ORDER_ID,0)
	set @UserName = upper(@UserName)
	Declare @ReturnCode bit = 0
	Declare @ReturnText nvarchar(250) = ''

	if (@GetRecordType_MTV_ID = 0)
	begin
		select @ORDER_ID = Order_ID , @GetRecordType_MTV_ID = GetRecordType_MTV_ID
		from [POMS_DB].[dbo].[F_Get_Order_GUID_By_OrderID] (@OrderGUID, 0 ,'' ,@UserName ,@UserType_MTV_CODE ,1 ,13,0)
		set @ORDER_ID = isnull(@ORDER_ID,0)
	end
	
	if @ORDER_ID = 0
	begin
		select @ORDER_ID = [POMS_DB].[dbo].[F_Get_OrderID_By_OrderGUID] (@OrderGUID ,@GetRecordType_MTV_ID)
		set @ORDER_ID = isnull(@ORDER_ID,0)
	end

	if @ORDER_ID = 0
	begin
		set @ReturnText = 'Invalid Order'
	end
	
	if (@UserType_MTV_CODE = 'METRO-USER') and @ReturnText = ''
	begin
		insert into @ReturnTable
		select 1, @ReturnText, @ORDER_ID ,@GetRecordType_MTV_ID ,@UserName ,SELLER_CODE='' ,SELLER_NAME='' ,BillTo_CUSTOMER_NO='' ,SUB_SELLER_CODE='' ,SELLER_PARTNER_CODE=''
		,TARIFF_NO='' ,IsViewOrder=1 ,IsCreateOrder=1 ,IsGetQuote=1 ,IsFinancial=1 ,IsAdmin=1 ,IsSellerMapped=0 ,IsBlankSubSellerAllowed=1
		,IsAllSubSellerAllowed=1 ,IsBlankPartnerAllowed=1 ,IsAllPartnerAllowed=1 ,IsBlankTariffAllowed=1 ,IsAllTariffAllowed=1

		return
	end
	else if @ReturnText = ''
	begin
		Declare @SELLER_CODE nvarchar(20) = ''
		Declare @SUB_SELLER_CODE nvarchar(20) = ''
		Declare @SELLER_PARTNER_CODE nvarchar(20) = ''
		Declare @TARIFF_NO nvarchar(36) = ''
		Declare @BillingType_MTV_CODE nvarchar(20) = ''
		Declare @BillTo_CUSTOMER_NO nvarchar(20) = ''
		Declare @BillToSub_CUSTOMER_NO nvarchar(20) = ''

		if @GetRecordType_MTV_ID in (147100) and @OrderGUID != ''
		begin
			select @SELLER_CODE = SELLER_CODE
			,@SUB_SELLER_CODE = SUB_SELLER_CODE
			,@SELLER_PARTNER_CODE = SELLER_PARTNER_CODE
			,@TARIFF_NO = TARIFF_NO
			,@BillingType_MTV_CODE = BillingType_MTV_CODE
			,@BillTo_CUSTOMER_NO = BillTo_CUSTOMER_NO
			,@BillToSub_CUSTOMER_NO = BillToSub_CUSTOMER_NO
			from [POMS_DB].[dbo].[T_Order] o with (nolock)
			where o.ORDER_ID = @ORDER_ID
		end
		else if @GetRecordType_MTV_ID in (147101) and @OrderGUID != ''
		begin
			select @SELLER_CODE = SELLER_CODE
			,@SUB_SELLER_CODE = SUB_SELLER_CODE
			,@SELLER_PARTNER_CODE = SELLER_PARTNER_CODE
			,@TARIFF_NO = TARIFF_NO
			,@BillingType_MTV_CODE = BillingType_MTV_CODE
			,@BillTo_CUSTOMER_NO = BillTo_CUSTOMER_NO
			,@BillToSub_CUSTOMER_NO = BillToSub_CUSTOMER_NO
			from [POMS_DB].[dbo].[T_Order] o with (nolock)
			where o.ORDER_ID = @ORDER_ID
		end
		else if @GetRecordType_MTV_ID in (147102) and @OrderGUID != ''
		begin
			select @SELLER_CODE = SELLER_CODE
			,@SUB_SELLER_CODE = SUB_SELLER_CODE
			,@SELLER_PARTNER_CODE = SELLER_PARTNER_CODE
			,@TARIFF_NO = TARIFF_NO
			,@BillingType_MTV_CODE = BillingType_MTV_CODE
			,@BillTo_CUSTOMER_NO = BillTo_CUSTOMER_NO
			,@BillToSub_CUSTOMER_NO = BillToSub_CUSTOMER_NO
			from [POMS_DB].[dbo].[T_Order] o with (nolock)
			where o.ORDER_ID = @ORDER_ID
			
			if (isnull(@SELLER_CODE,'') = '')
			begin
				select @SELLER_CODE = SELLER_CODE
				,@SUB_SELLER_CODE = SUB_SELLER_CODE
				,@SELLER_PARTNER_CODE = SELLER_PARTNER_CODE
				,@TARIFF_NO = TARIFF_NO
				,@BillingType_MTV_CODE = BillingType_MTV_CODE
				,@BillTo_CUSTOMER_NO = BillTo_CUSTOMER_NO
				,@BillToSub_CUSTOMER_NO = BillToSub_CUSTOMER_NO
				from [POMS_DB].[dbo].[T_Order] o with (nolock)
				where o.ORDER_ID = @ORDER_ID
			end
		end
		else if @GetRecordType_MTV_ID in (147103) and @OrderGUID != ''
		begin
			select @SELLER_CODE = replace(sh.[Bill-to Customer No_],'C','S')
			,@SUB_SELLER_CODE = ''
			,@SELLER_PARTNER_CODE = ''
			,@TARIFF_NO = isnull(TariffID,'')
			,@BillingType_MTV_CODE = sh.[Payment Method Code]
			,@BillTo_CUSTOMER_NO = sh.[Bill-to Customer No_]
			,@BillToSub_CUSTOMER_NO = sh.SubCustomerNo
			from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
			where sh.[No_] = cast(@ORDER_ID as nvarchar(20))
		end
		else if @GetRecordType_MTV_ID in (147104) and @OrderGUID != ''
		begin
			select @SELLER_CODE = replace(sh.[Bill-to Customer No_],'C','S')
			,@SUB_SELLER_CODE = ''
			,@SELLER_PARTNER_CODE = ''
			,@TARIFF_NO = isnull(TariffID,'')
			,@BillingType_MTV_CODE = sh.[Payment Method Code]
			,@BillTo_CUSTOMER_NO = sh.[Bill-to Customer No_]
			,@BillToSub_CUSTOMER_NO = sh.SubCustomerNo
			from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
			where sh.[No_] = cast(@ORDER_ID as nvarchar(20))
		end
		else if @GetRecordType_MTV_ID in (147105) and @OrderGUID != ''
		begin
			select @SELLER_CODE = replace(sh.[Bill-to Customer No_],'C','S')
			,@SUB_SELLER_CODE = ''
			,@SELLER_PARTNER_CODE = ''
			,@TARIFF_NO = isnull(TariffID,'')
			,@BillingType_MTV_CODE = sh.[Payment Method Code]
			,@BillTo_CUSTOMER_NO = sh.[Bill-to Customer No_]
			,@BillToSub_CUSTOMER_NO = sh.SubCustomerNo
			from [PinnacleProd].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
			where sh.[No_] = cast(@ORDER_ID as nvarchar(20))

			if (isnull(@SELLER_CODE,'') = '')
			begin
				select @SELLER_CODE = replace(sh.[Bill-to Customer No_],'C','S')
				,@SUB_SELLER_CODE = ''
				,@SELLER_PARTNER_CODE = ''
				,@TARIFF_NO = isnull(TariffID,'')
				,@BillingType_MTV_CODE = sh.[Payment Method Code]
				,@BillTo_CUSTOMER_NO = sh.[Bill-to Customer No_]
				,@BillToSub_CUSTOMER_NO = sh.SubCustomerNo
				from [PinnacleArchiveDB].[dbo].[Metropolitan$Sales Header] sh with (nolock) 
				where sh.[No_] = cast(@ORDER_ID as nvarchar(20))
			end
		end

		set @SELLER_CODE = isnull(@SELLER_CODE,'')
		set @SUB_SELLER_CODE = isnull(@SUB_SELLER_CODE,'')
		set @SELLER_PARTNER_CODE = isnull(@SELLER_PARTNER_CODE,'')
		set @TARIFF_NO = isnull(@TARIFF_NO,'')
		set @BillingType_MTV_CODE = isnull(@BillingType_MTV_CODE,'')
		set @BillTo_CUSTOMER_NO = isnull(@BillTo_CUSTOMER_NO,'')
		set @BillToSub_CUSTOMER_NO = isnull(@BillToSub_CUSTOMER_NO,'')
		
		insert into @ReturnTable
		SELECT 1 ,'' ,@ORDER_ID ,@GetRecordType_MTV_ID ,[UserName] ,[SELLER_CODE] ,[SELLER_NAME] ,[BillTo_CUSTOMER_NO] ,[SUB_SELLER_CODE] ,[SELLER_PARTNER_CODE] ,[TARIFF_NO]
		,[IsViewOrder] ,[IsCreateOrder] ,[IsGetQuote] ,[IsFinancial] ,[IsAdmin] ,[IsSellerMapped] ,IsBlankSubSellerAllowed
		,IsAllSubSellerAllowed ,IsBlankPartnerAllowed ,IsAllPartnerAllowed ,IsBlankTariffAllowed ,IsAllTariffAllowed
		FROM [POMS_DB].[dbo].[V_Seller_Assigned_To_User_Full_List] satul with (nolock)
		where satul.UserName = @UserName 
		and satul.[SELLER_CODE] = @SELLER_CODE
		and ((satul.[BillTo_CUSTOMER_NO] = @BillTo_CUSTOMER_NO
		and (satul.[SUB_SELLER_CODE] = @SUB_SELLER_CODE or (satul.[SUB_SELLER_CODE] = '' and IsBlankSubSellerAllowed = 1) or IsAllSubSellerAllowed = 1)
		and (satul.[SELLER_PARTNER_CODE] = @SELLER_PARTNER_CODE or (satul.[SELLER_PARTNER_CODE] = '' and IsBlankPartnerAllowed = 1) or IsAllPartnerAllowed = 1)
		and (satul.[TARIFF_NO] = @TARIFF_NO or (satul.[TARIFF_NO] = '' and IsBlankTariffAllowed = 1) or IsAllTariffAllowed = 1))
			or [IsAdmin] = 1)

		if not exists(select * from @ReturnTable)
		begin
			insert into @ReturnTable
			select @ReturnCode, 'No Rights To Order',@ORDER_ID ,@GetRecordType_MTV_ID ,@UserName ,SELLER_CODE='' ,SELLER_NAME='' ,BillTo_CUSTOMER_NO='' ,SUB_SELLER_CODE='' ,SELLER_PARTNER_CODE=''
			,TARIFF_NO='' ,IsViewOrder=0 ,IsCreateOrder=0 ,IsGetQuote=0 ,IsFinancial=0 ,IsAdmin=0 ,IsSellerMapped=0 ,IsBlankSubSellerAllowed=0
		,IsAllSubSellerAllowed=0 ,IsBlankPartnerAllowed=0 ,IsAllPartnerAllowed=0 ,IsBlankTariffAllowed=0 ,IsAllTariffAllowed=0
		end
	end

	if not exists(select * from @ReturnTable)
	begin
		insert into @ReturnTable
		select @ReturnCode, @ReturnText ,@ORDER_ID ,@GetRecordType_MTV_ID ,@UserName ,SELLER_CODE='' ,SELLER_NAME='' ,BillTo_CUSTOMER_NO='' ,SUB_SELLER_CODE='' ,SELLER_PARTNER_CODE=''
		,TARIFF_NO='' ,IsViewOrder=0 ,IsCreateOrder=0 ,IsGetQuote=0 ,IsFinancial=0 ,IsAdmin=0 ,IsSellerMapped=0 ,IsBlankSubSellerAllowed=0
		,IsAllSubSellerAllowed=0 ,IsBlankPartnerAllowed=0 ,IsAllPartnerAllowed=0 ,IsBlankTariffAllowed=0 ,IsAllTariffAllowed=0
	end

	return

end
GO
