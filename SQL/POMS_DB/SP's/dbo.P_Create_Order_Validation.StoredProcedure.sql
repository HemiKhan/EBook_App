USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Create_Order_Validation]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> 
--exec [dbo].[P_Create_Order_Validation]
--	@ValidationJson = '{"selltocustomerkey":"66E0D120-8856-4E0C-A26F-2F95A008B1F1","subselltocustomerkey":null,"selltopartnerkey":null,"tariffno":null,"billtocustomerkey":"66E0D120-8856-4E0C-A26F-2F95A008B1F1","carriercode":"MWD","username":"ABDULLAH.ARSHAD","ordersource":101100,"pickupservicelevel":"DKBI","deliveryservicelevel":"TRHD","ispickupspecialservicesexists":true,"isdeliveryspecialservicesexists":true,"zipcodes":[{"zipcode":"08861","type_":2},{"zipcode":"08861","type_":3}],"isorderdocsexists":false,"isitemimagesexists":false,"clientidentifiers":[{"code":"CARRIER","value":""},{"code":"PONUMBER","value":""},{"code":"PRO","value":""},{"code":"REF2","value":""},{"code":"TAG","value":""}],"pickupspecialservices":[],"deliveryspecialservices":[],"billtoaddresscode":null,"shipfromaddresscode":null,"shiptoaddresscode":null,"billingtype":"110","isblindshipto":false,"pickupotherinfo":{"reqdate":null,"reqfromtime":null,"reqtotime":null,"servicecode":"DKBI","servicetype":"DKBI","subservicetype":"","driverinstruction":""},"deliveryotherinfo":{"reqdate":null,"reqfromtime":null,"reqtotime":null,"servicecode":"TRHD","servicetype":"TRHD","subservicetype":"","driverinstruction":""},"itemsdetails":[{"requestitemid":"","itemno":[1],"barcodes":[{"barcode":"0001","barcodeguid":"72787f59-6d4b-4097-8016-57f760057b42"}],"rowno":1,"parentitemid":null,"itemtoship":"NEW","itemcode":"CG","packingcode":"PK-SP","skuno":"","description":"test","quantity":1,"itemweight":129.0,"weightunit":"LB","totalweight":129.0,"boxlength":24.0,"boxwidth":60.0,"boxheight":36.0,"dimensionunit":"IN","itemcuft":30.0,"calculatedcuft":30.0,"totalcuft":30.0,"itemamount":100.0,"totalamount":100.0,"itemassemblytime":0,"totalassemblytime":0,"packagedetailsnote":"","itemclientref1":"","itemclientref2":"","itemclientref3":"","itemimages":[],"noofitemimages":0}],"ordertype":146100,"subordertype":null}'
--	,@CreateOrderJson  = null
--	,@IsCreateOrder = 0
-- =============================================
CREATE PROCEDURE [dbo].[P_Create_Order_Validation]
	@ValidationJson nvarchar(max)
	,@CreateOrderJson  nvarchar(max)
	,@IsCreateOrder bit
AS
BEGIN
	
--	set @Json = '{
--   "selltocustomerkey":"66E0D120-8856-4E0C-A26F-2F95A008B1F1",
--   "carriercode": "MWD",
--   "subselltocustomerkey":"",
--   "selltopartnerkey":null,
--   "tariffno":"",
--   "billtocustomerkey":"66E0D120-8856-4E0C-A26F-2F95A008B1F1",
--   "username":"ABDULLAH.ARSHAD",
--   "ordersource":101100,
--   "ordertype":0,
--   "subordertype":0,
--   "pickupservicelevel":"DKBI",
--   "deliveryservicelevel":"WG",
--   "ispickupspecialservicesexists":true,
--   "isdeliveryspecialservicesexists":true,
--   "zipcodes":[
--      {
--         "zipcode":"08861",
--         "type_":2
--      }
--   ],
--   "isorderdocsexists":false,
--   "isitemimagesexists":false,
--   "clientidentifiers":[
--      {
--         "code":"CARRIER",
--         "value":""
--      },
--      {
--         "code":"PONUMBER",
--         "value":""
--      },
--      {
--         "code":"PRO",
--         "value":""
--      },
--      {
--         "code":"REF2",
--         "value":""
--      },
--      {
--         "code":"TAG",
--         "value":""
--      }
--   ],
--   "pickupspecialservices":[
      
--   ],
--   "deliveryspecialservices":[
      
--   ],
--   "billtoaddresscode":null,
--   "shipfromaddresscode":null,
--   "shiptoaddresscode":null,
--   "billingtype":"110",
--   "isblindshipto":true
--}'

--	set @Json = '{
--   "selltocustomerkey":"41144328-CF59-433E-9374-E76CBDE80A11",
--   "selltopartnerkey":null,
--   "tariff":null,
--   "billtocustomerkey":null,
--   "username":"ABDULLAH.ARSHAD",
--   "ordersource":101100,
--   "pickupservicelevel":"DKBI",
--   "deliveryservicelevel":"WG",
--   "ispickupspecialservicesexists":true,
--   "billtoaddresscode":true,
--   "isdeliveryspecialservicesexists":null,
--   "shipfromaddresscode":null,
--   "shiptoaddresscode":null,
--   "zipcodes":[
--      {
--         "zipcode":"08861",
--         "type_":2
--      },
--      {
--         "zipcode":"08865",
--         "type_":3
--      }
--   ],
--   "isorderdocsexists":true,
--   "isitemimagesexists":true,
--   "clientidentifiers":[
--      {
--         "code":"CARRIER",
--         "value":"Metro"
--      }
--   ],
--   "pickupspecialservices":[
--      {
--         "code":"DASM",
--         "description":"",
--         "ispublic":true,
--         "minutes":0,
--         "floor":0,
--         "amount":0.0,
--         "man":0
--      }
--   ],
--   "deliveryspecialservices":[
--      {
--         "code":"ASM",
--         "description":"",
--         "ispublic":true,
--         "minutes":0,
--         "floor":0,
--         "amount":0.0,
--         "days":0,
--         "man":0,
--         "fromdate":null,
--         "todate":null
--      }
--   ]
--}'

--	set @Json = '{
--   "selltocustomerkey":"F2817325-D86E-44FE-B163-67FF209B5017",
--   "subselltocustomerkey":null,
--   "selltopartnerkey":null,
--   "tariffno":null,
--   "billtocustomerkey":"F2817325-D86E-44FE-B163-67FF209B5017",
--   "username":"ABDULLAH.ARSHAD",
--   "ordersource":101100,
--   "pickupservicelevel":"DKBI",
--   "deliveryservicelevel":"TRHD",
--   "ispickupspecialservicesexists":true,
--   "isdeliveryspecialservicesexists":true,
--   "zipcodes":[
--      {
--         "zipcode":"92123",
--         "type_":3
--      }
--   ],
--   "isorderdocsexists":false,
--   "isitemimagesexists":false,
--   "clientidentifiers":[
--      {
--         "code":"CARRIER",
--         "value":""
--      },
--      {
--         "code":"PONUMBER",
--         "value":""
--      },
--      {
--         "code":"PRO",
--         "value":""
--      },
--      {
--         "code":"TAG",
--         "value":""
--      }
--   ],
--   "pickupspecialservices":[
      
--   ],
--   "deliveryspecialservices":[
      
--   ],
--   "billtoaddresscode":null,
--   "shipfromaddresscode":null,
--   "shiptoaddresscode":null,
--   "billingtype":"110"
--}'

	Declare @StartDate datetime = getutcdate()
	Declare @EndDate datetime = getutcdate()

	Declare @Return_Code bit = 0
	Declare @Return_Text nvarchar(1000) = ''
	Declare @Execution_Error nvarchar(1000) = ''
	Declare @Error_Text nvarchar(max) = ''
	Declare @carriercode nvarchar(20) = ''
	Declare @selltocustomerkey nvarchar(50) = null
	Declare @subselltocustomerkey nvarchar(36) = ''
	Declare @selltopartnerkey nvarchar(50) = null
	Declare @tariffno nvarchar(36) = null
	Declare @billtocustomerkey nvarchar(50) = null
	Declare @username nvarchar(150) = ''
	Declare @ordersource int = 0
	Declare @ordertype int = 0
	Declare @subordertype int = 0
	Declare @pickupservicelevel nvarchar(20) = ''
	Declare @deliveryservicelevel nvarchar(20) = ''
	Declare @ispickupspecialservicesexists bit = 0
	Declare @isdeliveryspecialservicesexists bit = 0
	Declare @zipcodes nvarchar(max) = ''
	Declare @isorderdocsexists bit = 0
	Declare @isitemimagesexists bit = 0
	Declare @clientidentifiers nvarchar(max) = ''
	Declare @pickupspecialservices nvarchar(max) = ''
	Declare @deliveryspecialservices nvarchar(max) = ''
	Declare @pickupotherinfo nvarchar(max) = ''
	Declare @deliveryotherinfo nvarchar(max) = ''
	Declare @itemsdetails nvarchar(max) = ''
	Declare @billtoaddresscode nvarchar(50) = ''
	Declare @shipfromaddresscode nvarchar(50) = ''
	Declare @shiptoaddresscode nvarchar(50) = ''
	Declare @billingtype nvarchar(20) = ''
	Declare @isblindshipto bit = 0

	set @ValidationJson = isnull(@ValidationJson,'')

	if @ValidationJson = ''
	begin
		set @Return_Text = 'Json is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
	end
	else
	begin
		if ISJSON(@ValidationJson) = 0
		begin
			set @Return_Text = 'Invalid Json'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
		end
	end

	drop table if exists #ValidationJsonHeaderTable
	select carriercode,selltocustomerkey,selltopartnerkey,tariffno,billtocustomerkey,username,ordersource,ordertype,subordertype,pickupservicelevel,deliveryservicelevel,ispickupspecialservicesexists
	,isdeliveryspecialservicesexists,zipcodes,isorderdocsexists,isitemimagesexists,clientidentifiers,pickupspecialservices,deliveryspecialservices,pickupotherinfo,deliveryotherinfo 
	,itemsdetails,billtoaddresscode,shipfromaddresscode,shiptoaddresscode,billingtype,isblindshipto into #ValidationJsonHeaderTable
	from OpenJson(@ValidationJson)
	WITH (
		carriercode nvarchar(20) '$.carriercode' 
		,selltocustomerkey nvarchar(50) '$.selltocustomerkey' 
		,selltopartnerkey nvarchar(50) '$.selltopartnerkey' 
		,tariffno nvarchar(36) '$.tariffno' 
		,billtocustomerkey nvarchar(50) '$.billtocustomerkey' 
		,username nvarchar(150) '$.username'
		,ordersource int '$.ordersource'
		,ordertype int '$.ordertype'
		,subordertype int '$.subordertype'
		,pickupservicelevel nvarchar(20) '$.pickupservicelevel'
		,deliveryservicelevel nvarchar(20) '$.deliveryservicelevel'
		,ispickupspecialservicesexists bit '$.ispickupspecialservicesexists'
		,isdeliveryspecialservicesexists bit '$.isdeliveryspecialservicesexists'
		,zipcodes nvarchar(max) '$.zipcodes' as json
		,isorderdocsexists bit '$.isorderdocsexists'
		,isitemimagesexists bit '$.isitemimagesexists'
		,clientidentifiers nvarchar(max) '$.clientidentifiers' as json
		,pickupspecialservices nvarchar(max) '$.pickupspecialservices' as json
		,deliveryspecialservices nvarchar(max) '$.deliveryspecialservices' as json
		,pickupotherinfo nvarchar(max) '$.pickupotherinfo' as json
		,deliveryotherinfo nvarchar(max) '$.deliveryotherinfo' as json
		,itemsdetails nvarchar(max) '$.itemsdetails' as json
		,billtoaddresscode nvarchar(50) '$.billtoaddresscode'
		,shipfromaddresscode nvarchar(50) '$.shipfromaddresscode'
		,shiptoaddresscode nvarchar(50) '$.shiptoaddresscode'
		,billingtype nvarchar(20) '$.billingtype'
		,isblindshipto bit '$.isblindshipto'
	) ReqHeader

	select @carriercode = carriercode
	,@selltocustomerkey = (case when selltocustomerkey = '' then null else selltocustomerkey end)
	,@selltopartnerkey = (case when selltopartnerkey = '' then null else selltopartnerkey end)
	,@tariffno = (case when tariffno = '' then null else tariffno end)
	,@billtocustomerkey = (case when billtocustomerkey = '' then null else billtocustomerkey end)
	,@username = upper(isnull(username,''))
	,@ordersource = ordersource
	,@ordertype = ordertype
	,@subordertype = subordertype
	,@pickupservicelevel = pickupservicelevel
	,@deliveryservicelevel = deliveryservicelevel
	,@ispickupspecialservicesexists = ispickupspecialservicesexists
	,@isdeliveryspecialservicesexists = isdeliveryspecialservicesexists
	,@zipcodes = zipcodes
	,@isorderdocsexists = isorderdocsexists
	,@isitemimagesexists = isitemimagesexists
	,@clientidentifiers = clientidentifiers
	,@pickupspecialservices = pickupspecialservices
	,@deliveryspecialservices = deliveryspecialservices
	,@pickupotherinfo = pickupotherinfo
	,@deliveryotherinfo = deliveryotherinfo
	,@itemsdetails = itemsdetails
	,@billtoaddresscode = billtoaddresscode
	,@shipfromaddresscode = shipfromaddresscode 
	,@shiptoaddresscode = shiptoaddresscode
	,@billingtype = billingtype
	,@isblindshipto = isblindshipto
	from #ValidationJsonHeaderTable

	if @selltocustomerkey is null
	begin
		set @Return_Text = 'Sell To Customer Key is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
	end
	else if (@UserName is null)
	begin
		set @Return_Text = 'Username is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
		return
	end
	else if (@BillToCustomerKey is null)
	begin
		set @Return_Text = 'Bill To Customer Key is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
		return
	end
		
	if @zipcodes is null and ((@shipfromaddresscode is null and @pickupservicelevel <> 'MW') or (@shiptoaddresscode is null and @isblindshipto = 0))
	begin
		set @Execution_Error = 'Zip Code List is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
	end

	drop table if exists #SellToCustomerInfoTable
	select SellerKey,SellerCode,SellerName into #SellToCustomerInfoTable
	from [POMS_DB].[dbo].[F_Get_SellToClientList] (@selltocustomerkey,@username)
	
	if not exists(select SellerKey from #SellToCustomerInfoTable)
	begin
		set @Return_Text = 'Sell To Customer Key is Invalid'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
		return
	end

	Declare @SELLER_CODE nvarchar(20) = ''
	select @SELLER_CODE = SellerCode from #SellToCustomerInfoTable

	drop table if exists #SellerBillToMapping
	select SellerKey,SellerCode,SellerName,BillToCustomerKey,BillToCustomerNo,BillToCustomerName into #SellerBillToMapping 
	from [POMS_DB].[dbo].[F_Get_Seller_BillTo_Mapping] (@selltocustomerkey,null)
	
	Declare @TotalBillToClients int = 0
	select @TotalBillToClients = count(BillToCustomerKey) from #SellerBillToMapping 

	if @TotalBillToClients = 0
	begin
		set @Return_Text = 'Bill To Customer Key is Not Setup'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
	end
	else if @billtocustomerkey is null and @TotalBillToClients = 1
	begin
		select @billtocustomerkey = BillToCustomerKey from #SellerBillToMapping
	end
	else if @billtocustomerkey is null and @TotalBillToClients > 1
	begin
		set @Return_Text = 'Bill To Customer Key is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
	end
	else if @billtocustomerkey is not null and not exists(select BillToCustomerKey from #SellerBillToMapping where BillToCustomerKey = @billtocustomerkey) and @TotalBillToClients > 0
	begin
		set @Return_Text = 'Bill To Customer Key is Invalid'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
	end

	drop table if exists #SellerPartnerMapping
	Create table #SellerPartnerMapping (SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250) ,SellerPartnerKey nvarchar(36), SellerPartnerCode nvarchar(20), SellerPartnerName nvarchar(250))
	
	if @selltopartnerkey is not null
	begin
		insert into #SellerPartnerMapping 
		select SellerKey,SellerCode,SellerName,SellerPartnerKey,SellerPartnerCode,SellerPartnerName from [POMS_DB].[dbo].[F_Get_Seller_Partner_Mapping] (@selltocustomerkey,@selltopartnerkey)

		if not exists(select SellerKey from #SellerPartnerMapping)
		begin
			set @Return_Text = 'Sell To Partner Key is Invalid'
			select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
			return
		end
	end

	drop table if exists #SubSellerMapping
	Create table #SubSellerMapping (SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250) ,SubSellerKey nvarchar(36), SubSellerCode nvarchar(20), SubSellerName nvarchar(250))
	
	if isnull(@subselltocustomerkey,'') <> ''
	begin
		insert into #SubSellerMapping 
		select SellerKey,SellerCode,SellerName,SubSellerKey,SubSellerCode,SubSellerName 
		from [POMS_DB].[dbo].[F_Get_Seller_SubSeller_Mapping] (@selltocustomerkey,@subselltocustomerkey)

		if not exists(select SellerKey from #SubSellerMapping)
		begin
			set @Return_Text = 'Sub Sell To Key is Invalid'
			select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
			return
		end
	end

	drop table if exists #SellerTariffMapping
	Create table #SellerTariffMapping (SellerKey nvarchar(36), SellerCode nvarchar(20), SellerName nvarchar(250) ,TariffID int, TariffNo nvarchar(36), TariffName nvarchar(250))
	
	if @tariffno is not null
	begin
		insert into #SellerTariffMapping 
		select SellerKey,SellerCode,SellerName,TariffID,TariffNo,TariffName from [POMS_DB].[dbo].[F_Get_Seller_Tariff_Mapping] (@tariffno,@selltocustomerkey)

		if not exists(select SellerKey from #SellerTariffMapping)
		begin
			set @Return_Text = 'Tariff No is Invalid'
			select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
			return
		end
	end
	
	Declare @IsApplyUserCheck bit = 1
	set @IsApplyUserCheck = (case when @ordersource in (101101,101102,101105,101106,101107) then 0 else 1 end)

	CREATE TABLE #AddressListTable ([ADDRESS_ID] [int] NOT NULL, [ADDRESS_CODE] [nvarchar](50) NULL, [ST_CODE] [nvarchar](20) NULL, [ServiceType_MTV_ID] [int] NULL
		, [FirstName] [nvarchar](50) NULL,	[MiddleName] [nvarchar](50) NULL, [LastName] [nvarchar](50) NULL, [Company] [nvarchar](250) NULL , [ContactPerson] [nvarchar](150) NULL
		, [Address] [nvarchar](250) NOT NULL, [Address2] [nvarchar](250) NULL, [City] [nvarchar](50) NOT NULL , [State] [nvarchar](5) NOT NULL, [ZipCode] [nvarchar](10) NOT NULL
		, [County] [nvarchar](50) NOT NULL, [CountryRegionCode] [nvarchar](10) NULL , [Email] [nvarchar](250) NULL, [Mobile] [nvarchar](30) NULL, [Phone] [nvarchar](20) NULL
		, [PhoneExt] [nvarchar](10) NULL, [AddressType_MTV_ID] [int] NOT NULL , [AddressStatus_MTV_ID] [int] NOT NULL ,[IsValidAddress] [bit] NOT NULL
		, Latitude [nvarchar](30) NOT NULL, Longitude [nvarchar](30) NOT NULL, PlaceID [nvarchar](max) NOT NULL)
	
	if @billtoaddresscode is not null
	begin
		insert into #AddressListTable
		select [ADDRESS_ID], [ADDRESS_CODE], [ST_CODE], [ServiceType_MTV_ID], [FirstName], [MiddleName], [LastName], [Company], [ContactPerson], [Address], [Address2], [City]
		, [State], [ZipCode], [County], [CountryRegionCode], [Email], [Mobile], [Phone], [PhoneExt], [AddressType_MTV_ID], [AddressStatus_MTV_ID], [IsValidAddress]=1, Latitude, Longitude, PlaceID
		from [POMS_DB].[dbo].[F_Get_SellerAddressList] ('',@SELLER_CODE,@username,130102,@billtoaddresscode,@IsApplyUserCheck)

		if not exists(select [ADDRESS_ID] from #AddressListTable where [ADDRESS_CODE] = @billtoaddresscode and [AddressType_MTV_ID] = 130102)
		begin
			set @Return_Text = 'Invalid Bill To Address Code'
			select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
			return
		end
	end

	if @shipfromaddresscode is not null
	begin
		insert into #AddressListTable
		select [ADDRESS_ID], [ADDRESS_CODE], [ST_CODE], [ServiceType_MTV_ID], [FirstName], [MiddleName], [LastName], [Company], [ContactPerson], [Address], [Address2], [City]
		, [State], [ZipCode], [County], [CountryRegionCode], [Email], [Mobile], [Phone], [PhoneExt], [AddressType_MTV_ID], [AddressStatus_MTV_ID], [IsValidAddress]=1, Latitude, Longitude, PlaceID
		from [POMS_DB].[dbo].[F_Get_SellerAddressList] ('',@SELLER_CODE,@username,130100,@shipfromaddresscode,@IsApplyUserCheck)
			
		if not exists(select [ADDRESS_ID] from #AddressListTable where [ADDRESS_CODE] = @shipfromaddresscode and [AddressType_MTV_ID] = 130100)
		begin
			set @Return_Text = 'Invalid Ship From Address Code'
			select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
			return
		end
	end

	if @shiptoaddresscode is not null
	begin
		insert into #AddressListTable
		select [ADDRESS_ID], [ADDRESS_CODE], [ST_CODE], [ServiceType_MTV_ID], [FirstName], [MiddleName], [LastName], [Company], [ContactPerson], [Address], [Address2], [City]
		, [State], [ZipCode], [County], [CountryRegionCode], [Email], [Mobile], [Phone], [PhoneExt], [AddressType_MTV_ID], [AddressStatus_MTV_ID], [IsValidAddress]=1, Latitude, Longitude, PlaceID
		from [POMS_DB].[dbo].[F_Get_SellerAddressList] ('',@SELLER_CODE,@username,130101,@shiptoaddresscode,@IsApplyUserCheck)
		
		if not exists(select [ADDRESS_ID] from #AddressListTable where [ADDRESS_CODE] = @shiptoaddresscode and [AddressType_MTV_ID] = 130101)
		begin
			set @Return_Text = 'Invalid Ship To Address Code'
			select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
			return
		end
	end

	--if @zipcodes is null and @billtoaddresscode is not null and @shipfromaddresscode is not null and @shiptoaddresscode is not null
	--begin
	--	set @Execution_Error = 'Zip Code List is Required'
	--	select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
	--	return
	--end

	drop table if exists #JsonZipCodesTable
	select distinct zipcode,type_ into #JsonZipCodesTable
	from OpenJson(@zipcodes)
	WITH (
		zipcode nvarchar(10) collate Latin1_General_100_CS_AS '$.zipcode'
		,type_ int '$.type_'
	) zips

	--BillTo = 1;
    --ShipFrom = 2;
    --ShipTo = 3;
	if not exists(select zipcode from #JsonZipCodesTable where type_ = 1) and @billtoaddresscode is null and @billingtype not in ('100','110')
	begin
		set @Return_Text = 'Bill To Information is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
	end

	if not exists(select zipcode from #JsonZipCodesTable where type_ = 2) and @shipfromaddresscode is null and @pickupservicelevel <> 'MW' --and @carriercode <> ''
	begin
		set @Return_Text = 'Ship From Information is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
	end

	if not exists(select zipcode from #JsonZipCodesTable where type_ = 3) and @shiptoaddresscode is null and @isblindshipto = 0 --and 1 = 0
	begin
		set @Return_Text = 'Ship To Information is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		return
	end

	Declare @PICKUP_ST_CODE nvarchar(20) = ''
	Declare @PICKUP_SST_CODE nvarchar(20) = ''
	Declare @DELIVERY_ST_CODE nvarchar(20) = ''
	Declare @DELIVERY_SST_CODE nvarchar(20) = ''
	Declare @PU_Instruction nvarchar(max) = ''
	Declare @DEL_Instruction nvarchar(max) = ''

	drop table if exists #ValidationJsonOtherInfoTable
	select [ReqPickup_Date] = PU_OtherInfo.[Date_], [ReqPickup_FromTime] = PU_OtherInfo.[FromTime], [ReqPickup_ToTime] = PU_OtherInfo.[ToTime]
	, [PICKUP_ST_CODE] = PU_OtherInfo.[ST_CODE], [PICKUP_SST_CODE] = PU_OtherInfo.[SST_CODE], PU_Instruction = PU_OtherInfo.[Instruction]
	, [ReqDelivery_Date] = Del_OtherInfo.[Date_], [ReqDelivery_FromTime] = Del_OtherInfo.[FromTime], [ReqDelivery_ToTime] = Del_OtherInfo.[ToTime]
	, [DELIVERY_ST_CODE] = Del_OtherInfo.[ST_CODE], [DELIVERY_SST_CODE] = Del_OtherInfo.[SST_CODE], DEL_Instruction = Del_OtherInfo.[Instruction]
	into #ValidationJsonOtherInfoTable from [POMS_DB].[dbo].[F_Get_Order_JsonOtherInfoTable] (@pickupotherinfo) PU_OtherInfo
	full outer join [POMS_DB].[dbo].[F_Get_Order_JsonOtherInfoTable] (@deliveryotherinfo) Del_OtherInfo on 1 = 1
		
	if not exists(select [ReqPickup_Date] from #ValidationJsonOtherInfoTable) 
	begin
		set @Return_Text = 'Pickup and Delivery Info is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
		return
	end
	
	select @PICKUP_ST_CODE = isnull(PICKUP_ST_CODE,'')
	,@PICKUP_SST_CODE = isnull(PICKUP_SST_CODE,'')
	,@DELIVERY_ST_CODE = isnull(DELIVERY_ST_CODE,'')
	,@DELIVERY_SST_CODE = isnull(DELIVERY_SST_CODE,'')
	,@PU_Instruction = isnull(PU_Instruction,'')
	,@DEL_Instruction = isnull(DEL_Instruction,'')
	from #ValidationJsonOtherInfoTable

	if @PICKUP_ST_CODE = ''
	begin
		set @Return_Text = 'Pickup Service Level is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
		return
	end

	if @DELIVERY_ST_CODE = ''
	begin
		set @Return_Text = 'Delivery Service Level is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
		return
	end

	if not exists (select MTV_ID from [POMS_DB].[dbo].[T_Master_Type_Value] mtv with (nolock) where mtv.MTV_ID = @ordertype and mtv.MT_ID = 146 and mtv.IsActive = 1)
	begin
		set @Return_Text = 'Order Type is Invalid'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
		return
	end
	
	if isnull(@subordertype,0) != 0
	begin
		if not exists(select sotv.[SOTV_ID] from [POMS_DB].[dbo].[T_Sub_Order_Type_Value] sotv with (nolock) where sotv.OrderType_MTV_ID = @ordertype and sotv.SubOrderType_ID = @subordertype and sotv.IsActive = 1)
		begin
			set @Return_Text = 'Sub Order Type is Invalid'
			select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
			return
		end
	end
	
	if isnull(@itemsdetails,'') = ''
	begin
		set @Return_Text = 'Item Detail is Required'
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
		return
	end

	drop table if exists #ClientTableInfo
	select billtocustomerkey = ilv.CustomerKey
	, billtocustomerno = ilv.CustomerNo
	, billtocustomername = ilv.CustomerName
	, ilv.PaymentTermsCode
	, ilv.PaymentMethodCode
	, ilv.DepartmentCode 
	, '' as billtosubcustomerno
	, isactive = 1, iscreateorderapiactive = 1, isignoreerror = 0
	, billingtype = (case 
		when ilv.[PaymentMethodCode] = '100' then '100' 
		when ilv.[PaymentMethodCode] = '110' then '110' 
		when ilv.[PaymentMethodCode] = '120' then '120' 
		when ilv.[PaymentMethodCode] = '130' then '130' 
		when ilv.[PaymentMethodCode] = '140' then '140' 
		when ilv.[PaymentMethodCode] = 'COD' then '120' 
		when ilv.[PaymentMethodCode] = 'CBD' then '130' 
		else '110' end)
	into #ClientTableInfo
	from (
		select CustomerKey,CustomerNo,CustomerName,PaymentTermsCode,PaymentMethodCode,DepartmentCode from [POMS_DB].[dbo].[F_Get_BillToClientList] (@billtocustomerkey,@username)
	) ilv

	if @IsCreateOrder = 0
	begin
		Declare @ST_CODE_List nvarchar(max) = @pickupservicelevel + ',' + @deliveryservicelevel
		Declare @SellToCustomerNo nvarchar(20) = ''
		Declare @SellToCustomerName nvarchar(250) = ''
		select @SellToCustomerNo = SellerCode ,@SellToCustomerName = SellerName from #SellToCustomerInfoTable
	
		drop table if exists #JsonClientIdentifierTable
		select OIF_CODE,Value_ into #JsonClientIdentifierTable from [POMS_DB].[dbo].[F_Get_Order_JsonClientIdentifierTable] (@clientidentifiers)

		drop table if exists #ClientIdentifierTableInfo
		select *
		,DuplicateValueOrder=(case when ilv.[IsDuplicateAllowed] = 0 and [IsAvailable] = 1 and Value_ <> ''
			then (select top 1 o.ORDER_CODE from [POMS_DB].[dbo].[T_Order] o with (nolock)
			inner join [POMS_DB].[dbo].[T_Order_Client_Identifier] oci with (nolock) on o.ORDER_ID = oci.ORDER_ID and oci.OIF_CODE = ilv.[OIF_CODE]
			where oci.Value_ = ilv.Value_ and o.SELLER_CODE = @SellToCustomerNo order by o.ORDER_ID)
			else '' end)
		into #ClientIdentifierTableInfo
		from (
			select sett.* 
			,[IsAvailable]=cast((case when jcit.OIF_CODE is not null then 1 else 0 end) as bit)
			,[Value_]=isnull(jcit.value_,'')
			from (
				select SellerKey,SellerCode,SellerName,OIF_CODE,[Description],IsRequired,IsDuplicateAllowed,IsModifyAllowed,IsHidden,IsAllowed,CharacterLimit,IsActive 
				from [POMS_DB].[dbo].[F_Get_Order_Client_Identifier_Fields_List] (@selltocustomerkey ,@SellToCustomerNo ,@SellToCustomerName) 
			) sett left join #JsonClientIdentifierTable jcit on jcit.OIF_CODE = sett.[OIF_CODE]
		) ilv 

		drop table if exists #JsonPickupSpecialServiceTable
		select OSS_ID,SSL_CODE,Description_,IsPublic,Mints,Floor_,EST_Amount,Days_,From_Date,To_Date,Man,SLSS_ID,IsDelete into #JsonPickupSpecialServiceTable 
		from [POMS_DB].[dbo].[F_Get_Order_JsonSpecialServiceTable] (@pickupspecialservices,1,@pickupservicelevel)

		drop table if exists #JsonDeliverySpecialServiceTable
		select OSS_ID,SSL_CODE,Description_,IsPublic,Mints,Floor_,EST_Amount,Days_,From_Date,To_Date,Man,SLSS_ID,IsDelete into #JsonDeliverySpecialServiceTable 
		from [POMS_DB].[dbo].[F_Get_Order_JsonSpecialServiceTable] (@deliveryspecialservices,0,@deliveryservicelevel)

		drop table if exists #UserTableInfo
		select Username,[Entity type],[Web Role],Blocked,[Customer No_],[Web UserID],[Dynamics UserName],LastSelectedClient,[Time Zone ID],APIAccess into #UserTableInfo 
		from [POMS_DB].[dbo].[F_Get_UserDetail] (@username)
	
		drop table if exists #SLTableInfo
		select ID,SellerKey,SellerCode,SellerName,Required_CODE,ST_CODE,ServiceName,SST_CODE,SubServiceName,ServiceLevelDetails,Type_MTV_ID,[Type_Name],IsDefault
		,IsActive,IsAllowed into #SLTableInfo from [POMS_DB].[dbo].[F_Get_Client_Service_Type_List] (null ,@selltocustomerkey ,0 ,@SellToCustomerNo ,@SellToCustomerName ,@ST_CODE_List)

		drop table if exists #ZipTableInfo
		select [ZipCode], Type_, TypeName, [State], Latitude, Longitude, [TIMEZONE_ID], DrivingMiles ,MilesRadius, AreaType_MTV_ID
		, [Area_Type_Name], Carrier, [HubCode], HubName, HubAddress, [HubAddress2], HubCity, HubState, [HubPostCode], [HubZone] into #ZipTableInfo 
		from [POMS_DB].[dbo].[F_Get_PostCode_JsonZipsTable] (@zipcodes)
	
		drop table if exists #PickupSpecialServiceTableInfo
		select [SSL_CODE] ,[Name] ,[Description] ,[IsAvailableForPickup] ,[IsAvailableForDelivery] ,[IsReqMints] ,[IsFloorsRequired] ,[IsDaysRequired] ,[IsEstAmountRequired] ,[IsFromDateRequired] ,[IsToDateRequired] ,[IsManRequired] 
			,[IsDefaultMintsZero] ,[IsDefaultFloorZero] ,[IsDefaultDaysZero] ,[IsDefaultEstAmountZero] ,[IsDefaultFromDateNULL] ,[IsDefaultToDateNULL] ,[IsDefaultManZero] ,[IsAllowed] ,[IsActive] into #PickupSpecialServiceTableInfo
		FROM [POMS_DB].[dbo].[T_Special_Services_List] with (nolock) where [IsActive] = 1 and SSL_CODE in (Select SSL_CODE from #JsonPickupSpecialServiceTable)
	
		drop table if exists #DeliverySpecialServiceTableInfo
		select [SSL_CODE] ,[Name] ,[Description] ,[IsAvailableForPickup] ,[IsAvailableForDelivery] ,[IsReqMints] ,[IsFloorsRequired] ,[IsDaysRequired] ,[IsEstAmountRequired] ,[IsFromDateRequired] ,[IsToDateRequired] ,[IsManRequired] 
			,[IsDefaultMintsZero] ,[IsDefaultFloorZero] ,[IsDefaultDaysZero] ,[IsDefaultEstAmountZero] ,[IsDefaultFromDateNULL] ,[IsDefaultToDateNULL] ,[IsDefaultManZero] ,[IsAllowed] ,[IsActive] into #DeliverySpecialServiceTableInfo
		FROM [POMS_DB].[dbo].[T_Special_Services_List] with (nolock) where [IsActive] = 1 and SSL_CODE in (Select SSL_CODE from #JsonPickupSpecialServiceTable)
	
		drop table if exists #OrderDocTableList
		create table #OrderDocTableList
		(MT_ID int
		,[Name] nvarchar(50) 
		,MTV_ID int
		,MTV_CODE nvarchar(50)
		,[SubName] nvarchar(50));

		if exists(select selltocustomerkey from #ValidationJsonHeaderTable where isorderdocsexists = 1)
		begin
			insert into #OrderDocTableList
			select MT_ID,[Name],MTV_ID,MTV_CODE,SubName from [POMS_DB].[dbo].[F_Get_List_By_ID] (111, @selltocustomerkey, @SellToCustomerNo ,@SellToCustomerName)
		end

		drop table if exists #IngoreAPIErrorList
		select IAPIEL_ID,[Name],IsActive,IsIgnore into #IngoreAPIErrorList from [dbo].[F_Get_Client_Ignore_API_Errors_List] (@selltocustomerkey, @SellToCustomerNo ,@SellToCustomerName)
	end

	set @EndDate = getutcdate()
	print datediff(millisecond,@StartDate,@EndDate)
	set @Return_Code = 1

	if (@Return_Code = 1 and @IsCreateOrder = 0)
	begin
		set @Return_Code = 1
		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		select * from #SellToCustomerInfoTable
		select * from #SellerBillToMapping
		select * from #SellerPartnerMapping
		select * from #ClientTableInfo
		select * from #UserTableInfo
		select * from #SLTableInfo
		select * from #ZipTableInfo
		select * from #ClientIdentifierTableInfo where IsActive = 1 and IsAllowed = 1
		select * from #PickupSpecialServiceTableInfo where IsActive = 1
		select * from #DeliverySpecialServiceTableInfo where IsActive = 1
		select * from #OrderDocTableList
		select * from #IngoreAPIErrorList
	end
	else if (@Return_Code = 1 and @IsCreateOrder = 1)
	begin
		exec [POMS_DB].[dbo].[P_Create_Order] @CreateOrderJson 
	end

END
GO
