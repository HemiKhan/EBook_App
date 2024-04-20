USE [POMS_DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Create_Order]    Script Date: 4/19/2024 9:44:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- [dbo].[P_Create_Order] '{"guid_":"8d0d9fe8-bcd6-4ba6-afc7-b1cb218814bc","requestid":"","ordersource":101100,"shipmentregdatetime":"2023-06-19 12:11:40.594","username":"ABDULLAH.ARSHAD","quoteid":null,"quoteamount":null,"billtocustomerkey":"39180E08-7FDA-4766-B84F-1BBF2AA38C02","billtocustomerno":"C100012","billtosubcustomerno":"","billingtype":"110","shipfrominformation":{"firstname":"Abdul","middlename":"","lastname":"Mateen","company":"Self","contactperson":"Abdul Mateen","address":"12","address2":"Chaklala Scheme 3","city":"sadasdad","state":"da","zipcode":"12331","county":"","countryregioncode":"","email":"mateena946@gmail.com","mobile":"1243242344","phone":"92146","phoneext":"","lat":"","lng":"","placeid":""},"shiptoinformation":null,"isblindshipto":true,"clientidentifiers":[{"code":"CARRIER","value":""},{"code":"PONUMBER","value":""},{"code":"PRO","value":""},{"code":"TAG","value":""}],"pickupotherinfo":{"reqdate":null,"reqfromtime":null,"reqtotime":null,"servicecode":"DKBI","servicetype":"DKBI","subservicetype":"","driverinstruction":""},"pickupspecialservices":[],"deliveryotherinfo":{"reqdate":null,"reqfromtime":null,"reqtotime":null,"servicecode":"PWG-OFFICE","servicetype":"PWG","subservicetype":"OFFICE","driverinstruction":""},"deliveryspecialservices":[{"code":"WU","description":"21","ispublic":true,"minutes":0,"floor":12,"amount":0.0,"days":0,"fromdate":null,"todate":null}],"initialcomment":"","initialcommentispublic":true,"itemsdetails":[{"requestitemid":"","itemno":[1,2],"barcodes":[{"barcode":"0001","barcodeguid":"646e48ad-0140-43ae-bd4d-0ced5e3639c1"},{"barcode":"0002","barcodeguid":"c633b788-39e2-46fc-9f76-53a6da905a68"}],"rowno":1,"parentitemid":null,"itemtoship":"0","itemcode":"0","packingcode":"0","skuno":"","description":"sdfsf","quantity":2,"itemweight":12.0,"weightunit":"LB","totalweight":24.0,"boxlength":12.0,"boxwidth":122.0,"boxheight":12.0,"dimensionunit":"IN","itemcuft":10.17,"calculatedcuft":10.17,"totalcuft":20.34,"itemamount":123.0,"totalamount":246.0,"itemassemblytime":0,"totalassemblytime":0,"packagedetailsnote":"","itemclientref1":"","itemclientref2":"","itemclientref3":"","itemimages":null,"noofitemimages":0}],"totalshipmentqty":2,"totalshipmentweight":24.0,"totalshipmentcuft":20.34,"totalshipmentamount":246.0,"totalshipmentassemblytime":0,"totalnoofitemimages":0,"orderdocs":[],"nooforderdocs":0}'
-- =============================================
CREATE PROCEDURE [dbo].[P_Create_Order] 
	@CreateOrderJson nvarchar(max)

AS
BEGIN
	SET NOCOUNT ON;

--	set @Json = '{
--   "guid_":"f25ace08-e12c-4a19-b6c3-4f71eb9061c2",
--   "requestid":"",
--   "ordersource":101100,
--   "ordersubsource":null,
--   "ordersubsourcefilename":null,
--   "ordertype":146100,
--   "subordertype":0,
--   "carriercode":"MWD",
--   "shipmentregdatetime":"2023-10-26 17:16:55.665",
--   "username":"ABDULLAH.ARSHAD",
--   "quoteid":null,
--   "quoteamount":null,
--   "selltocustomerkey":"0A8B8263-C9DE-4AFD-BCC6-8FAFD12C9E08",
--   "selltocustomerno":"S100949",
--   "subselltocustomerkey":"BE75467F-81A0-4993-A90C-93824B2034B0",
--   "subselltocustomerno":"",
--   "selltopartnerkey":"B4097F62-0BBD-495A-8726-4188A3A3E36D",
--   "selltopartnercode":"SP100001",
--   "tariffno":"28181F-AD2566",
--   "billtocustomerkey":"3CBC5086-752A-44B0-8458-F7D77DF1CD45",
--   "billtocustomerno":"C100955",
--   "billtosubcustomerno":"",
--   "billingtype":"110",
--   "billtoaddresscode":null,
--   "shipfromaddresscode":null,
--   "shipfrominformation":{
--      "firstname":"oFirst",
--      "middlename":"oMiddle",
--      "lastname":"oLast",
--      "company":"oCompany",
--      "contactperson":"oContactPerson",
--      "address":"960 High Street",
--      "address2":"oAddress2",
--      "city":"Perth Amboy",
--      "state":"NJ",
--      "zipcode":"08861",
--      "county":"",
--      "countryregioncode":"",
--      "email":"oabc@example.com",
--      "mobile":"5556667777",
--      "phone":"1112223333",
--      "phoneext":"444",
--		"isvalidaddress": true,
--      "lat":"40.5278056",
--      "lng":"-74.2611237",
--      "placeid":"ChIJgVjxcXe1w4kR-cvicsURnwg"
--   },
--   "shiptoaddresscode":null,
--   "shiptoinformation":{
--      "firstname":"dFirst",
--      "middlename":"dMiddle",
--      "lastname":"dLast",
--      "company":"dCompany",
--      "contactperson":"dContactPerson",
--      "address":"5055 Goodman Road",
--      "address2":"dAddress2",
--      "city":"Eastvale",
--      "state":"CA",
--      "zipcode":"91752",
--      "county":"",
--      "countryregioncode":"",
--      "email":"dabc@example.com",
--      "mobile":"3334445555",
--      "phone":"8889991111",
--      "phoneext":"222",
--		"isvalidaddress": true,
--      "lat":"33.9913281",
--      "lng":"-117.5561501",
--      "placeid":"ChIJzYOaSIfK3IAR7JY_TOop13E"
--   },
--   "isblindshipto":false,
--   "clientidentifiers":[
--      {
--         "code":"CARRIER",
--         "value":"CarrierName"
--      },
--      {
--         "code":"PONUMBER",
--         "value":"PONumber"
--      },
--      {
--         "code":"PRO",
--         "value":"ProNumber"
--      },
--      {
--         "code":"REF2",
--         "value":"Ref2"
--      },
--      {
--         "code":"TAG",
--         "value":"CarrierTag"
--      }
--   ],
--   "pickupotherinfo":{
--      "reqdate":"2023-10-26",
--      "reqfromtime":"00:00",
--      "reqtotime":"04:00",
--      "servicecode":"OTH-SHOWROOM",
--      "servicetype":"OTH",
--      "subservicetype":"SHOWROOM",
--      "driverinstruction":"Test Pickup Instrunction"
--   },
--   "pickupspecialservices":[
--      {
--         "code":"DASM",
--         "description":"Disassembly asf",
--         "ispublic":true,
--         "minutes":12,
--         "floor":0,
--         "amount":0.0,
--         "man":0
--      },
--      {
--         "code":"EM",
--         "description":"Extra Men (After First 2 Men) aada",
--         "ispublic":true,
--         "minutes":0,
--         "floor":0,
--         "amount":0.0,
--         "man":5
--      },
--      {
--         "code":"FRY",
--         "description":"sgsg",
--         "ispublic":true,
--         "minutes":0,
--         "floor":0,
--         "amount":52.0,
--         "man":0
--      },
--      {
--         "code":"WU",
--         "description":"aafaf",
--         "ispublic":true,
--         "minutes":0,
--         "floor":0,
--         "amount":0.0,
--         "man":0
--      }
--   ],
--   "deliveryotherinfo":{
--      "reqdate":"2023-10-28",
--      "reqfromtime":"06:00",
--      "reqtotime":"12:00",
--      "servicecode":"WG-RESI",
--      "servicetype":"WG",
--      "subservicetype":"RESI",
--      "driverinstruction":"Test Delivery Instrunction"
--   },
--   "deliveryspecialservices":[
--      {
--         "code":"EM",
--         "description":"sgsg",
--         "ispublic":true,
--         "minutes":0,
--         "floor":0,
--         "amount":0.0,
--         "man":3,
--         "days":0,
--         "fromdate":null,
--         "todate":null
--      },
--      {
--         "code":"HML",
--         "description":"sgdsg",
--         "ispublic":true,
--         "minutes":0,
--         "floor":0,
--         "amount":0.0,
--         "man":0,
--         "days":1,
--         "fromdate":"2023-10-26",
--         "todate":"2023-10-27"
--      },
--      {
--         "code":"ASM",
--         "description":"sdgsgs",
--         "ispublic":true,
--         "minutes":50,
--         "floor":0,
--         "amount":0.0,
--         "man":0,
--         "days":0,
--         "fromdate":null,
--         "todate":null
--      }
--   ],
--   "initialcomment":"Test Comment",
--   "initialcommentispublic":true,
--   "initialcomment2":"Test Comment",
--   "initialcommentispublic2":true,
--   "itemsdetails":[
--      {
--         "requestitemid":"",
--         "itemno":[
--            1,
--            2,
--            3
--         ],
--         "barcodes":[
--            {
--               "barcode":"0001",
--               "barcodeguid":"6cfab707-713d-4d35-a54c-0dc692a5eb26"
--            },
--            {
--               "barcode":"0002",
--               "barcodeguid":"0791fba6-7ccc-4690-b6cd-ff1bdb691262"
--            },
--            {
--               "barcode":"0003",
--               "barcodeguid":"41782191-a0e7-4a25-ba42-be3d9ba94859"
--            }
--         ],
--         "rowno":1,
--         "parentitemid":null,
--         "itemtoship":"117100",
--         "itemcode":"118101",
--         "packingcode":"BW-PK-CR-REQ",
--         "skuno":"Style",
--         "description":"Description",
--         "quantity":3,
--         "itemweight":129.99,
--         "weightunit":"LB",
--         "totalweight":389.97,
--         "boxlength":24.5,
--         "boxwidth":60.99,
--         "boxheight":36.19,
--         "dimensionunit":"IN",
--         "itemcuft":31.29,
--         "calculatedcuft":31.29,
--         "totalcuft":93.87,
--         "itemamount":100.52,
--         "totalamount":301.56,
--         "itemassemblytime":145,
--         "totalassemblytime":435,
--         "packagedetailsnote":"Test Note",
--         "itemclientref1":"Ref",
--         "itemclientref2":"",
--         "itemclientref3":"",
--         "itemimages":[
--            {
--               "barcodes":[
--                  {
--                     "barcode":"0001",
--                     "barcodeguid":"f10d26e0-6834-44c9-9fa5-e4feabec171f",
--                     "fileguid":"28a61107-3bcf-4ff1-987f-5c3b8cf20b76"
--                  },
--                  {
--                     "barcode":"0002",
--                     "barcodeguid":"ec03ad1e-0444-4052-9b2f-c6288221a5e1",
--                     "fileguid":"39537e13-21f5-4dde-93ae-97dd8bc7e645"
--                  },
--                  {
--                     "barcode":"0003",
--                     "barcodeguid":"bf76d825-fa3c-49fa-a5b7-dfdfc8d9b2a3",
--                     "fileguid":"e60a0953-86f1-4e73-8f29-f10c31d6659b"
--                  }
--               ],
--               "itemscan":null,
--               "path":"",
--               "filename":"tempsnip",
--               "fileext":"png",
--               "documenttype":111103,
--               "description":"Test Image Description",
--               "attachmenttype":128101,
--               "ispublic":true,
--               "filebase64":""
--            }
--         ],
--         "noofitemimages":1
--      }
--   ],
--   "totalshipmentqty":3,
--   "totalshipmentweight":389.97,
--   "totalshipmentcuft":93.87,
--   "totalshipmentamount":301.56,
--   "totalshipmentassemblytime":435,
--   "totalnoofitemimages":1,
--   "orderdocs":[
--      {
--         "path":"",
--         "filename":"testststasad",
--         "fileext":"pdf",
--         "documenttype":111100,
--         "description":"Test Document Description",
--         "attachmenttype":128100,
--         "ispublic":true,
--         "filebase64":""
--      }
--   ],
--   "nooforderdocs":1
--}'

	Declare @StartDateTime datetime = getutcdate()
	Declare @EndDateTime datetime = @StartDateTime
	Declare @OrderGUID nvarchar(36) = upper(newid())
	Declare @Return_Code bit = 0
	Declare @Return_Text nvarchar(1000) = ''
	Declare @Execution_Error nvarchar(1000) = ''
	Declare @Error_Text nvarchar(max) = ''
	Declare @TempReturn_Code bit = 1
	Declare @TempReturn_Text nvarchar(1000) = ''
	Declare @TempExecution_Error nvarchar(1000) = ''
	Declare @TempError_Text nvarchar(max) = ''
	Declare @UserName nvarchar(150) = ''
	Declare @ShipFrom_AreaType_MTV_ID int = 0
	Declare @ShipFrom_HUB_CODE nvarchar(20) = ''
	Declare @ShipTo_AreaType_MTV_ID int = 0
	Declare @ShipTo_HUB_CODE nvarchar(20) = ''
	Declare @Order_ID bigint = 0
	Declare @TRACKING_NO nvarchar(40) = ''
	Declare @PreAssignedTrackingNo nvarchar(20) = ''
	Declare @Carrier_MTV_CODE nvarchar(20) = ''
	Declare @SellToCustomerKey nvarchar(36) = ''
	Declare @SellToCustomerNo nvarchar(20) = ''
	Declare @SellToCustomerName nvarchar(250) = ''
	Declare @SubSellToCustomerKey nvarchar(36) = ''
	Declare @SubSellToCustomerNo nvarchar(20) = ''
	Declare @SubSellToCustomerName nvarchar(250) = ''
	Declare @SellToPartnerKey nvarchar(36) = ''
	Declare @SellToPartnerCode nvarchar(20) = ''
	Declare @SellToPartnerName nvarchar(250) = ''
	Declare @TARIFFNO nvarchar(36) = ''
	Declare @BillToCustomerKey nvarchar(36) = ''
	Declare @BillToCustomerNo nvarchar(20) = ''
	Declare @BillToCustomerSubNo nvarchar(20) = ''
	Declare @BillToCustomerName nvarchar(250) = ''
	Declare @IsBlindShipment bit = 0
	Declare @BillToAddressCode nvarchar(50) = ''
	Declare @ShipFromAddressCode nvarchar(50) = ''
	Declare @ShipToAddressCode nvarchar(50) = ''
	Declare @PICKUP_ST_CODE nvarchar(20) = ''
	Declare @PICKUP_SST_CODE nvarchar(20) = ''
	Declare @DELIVERY_ST_CODE nvarchar(20) = ''
	Declare @DELIVERY_SST_CODE nvarchar(20) = ''
	Declare @Source_MTV_ID int = 101100
	Declare @OrderPriority_MTV_ID int = 138100
	Declare @PaymentStatus_MTV_ID int = 144100
	Declare @Currentdatetime datetime = getutcdate()
	Declare @OrderType_MTV_ID int = null
	Declare @SubOrderType_ID int = null

	Declare @AddRowCount int = 0
	Declare @EditRowCount int = 0
	Declare @DeleteRowCount int = 0

	Declare @BillToInformation_Json nvarchar(max) = ''
	Declare @ShipFromInformation_Json nvarchar(max) = ''
	Declare @ShipToInformation_Json nvarchar(max) = ''
	Declare @ClientIdentifiers_Json nvarchar(max) = ''
	Declare @PickupOtherInfo_Json nvarchar(max) = ''
	Declare @PickupSpecialServices_Json nvarchar(max) = ''
	Declare @DeliveryOtherInfo_Json nvarchar(max) = ''
	Declare @DeliverySpecialServices_Json nvarchar(max) = ''
	Declare @OrderDocs_Json nvarchar(max) = ''
	Declare @ItemsDetails_Json nvarchar(max) = ''
	Declare @BillingType_MTV_CODE nvarchar(20) = '0'
	
	Declare @Comment nvarchar(max) = ''
	Declare @IsPublicComment bit = 1
	Declare @Comment2 nvarchar(max) = ''
	Declare @IsPublicComment2 bit = 1
	Declare @PU_Instruction nvarchar(max) = ''
	Declare @DEL_Instruction nvarchar(max) = ''
	
	Declare @CurrentAssignToDept_MTV_CODE nvarchar(20) = 'OED'
	Declare @OEDAssignTo nvarchar(150) = null
	Declare @OEDAssignToDateTime datetime = null
	Declare @OEDStatus_MTV_ID int = null
	Declare @OEDStatusDateTime datetime = null
	Declare @CSRAssignTo nvarchar(150) = null
	Declare @CSRAssignToDateTime datetime = null
	Declare @CSRStatus_MTV_ID int = null
	Declare @CSRStatusDateTime datetime = null
	Declare @DispatchAssignTo nvarchar(150) = null
	Declare @DispatchAssignToDateTime datetime = null
	Declare @DispatchStatus_MTV_ID int = null
	Declare @DispatchStatusDateTime datetime = null
	Declare @AccountAssignTo nvarchar(150) = null
	Declare @AccountAssignToDateTime datetime = null
	Declare @AccountStatus_MTV_ID int = null
	Declare @AccountStatusDateTime datetime = null
	Declare @IsMWG bit = 0
	Declare @TotalQty int = 0
	Declare @TotalValue decimal(18,6) = 0
	Declare @TotalWeight decimal(18,6) = 0
	Declare @TotalCubes decimal(18,6) = 0
	Declare @TotalAssemblyMinutes int = 0
	Declare @LastGeneratedBarcode nvarchar(10) = ''
	Declare @ShipFrom_MilesRadius decimal(18,6) = 0
	Declare @ShipFrom_DrivingMiles decimal(18,6) = 0
	Declare @ShipTo_MilesRadius decimal(18,6) = 0
	Declare @ShipTo_DrivingMiles decimal(18,6) = 0
	Declare @LineHaul_DrivingMiles decimal(18,6) = 0

	Begin try

		set @CreateOrderJson = isnull(@CreateOrderJson,'')

		if @CreateOrderJson = ''
		begin
			set @Return_Text = 'Json is Required'
			select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
			return
		end
		else
		begin
			if ISJSON(@CreateOrderJson) = 0
			begin
				set @Return_Text = 'Invalid Json'
				select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text
				return
			end
		end

		drop table if exists #JsonHeaderTable
		select OrderSource_MTV_ID,OrderSubSource_MTV_CODE,OrderSubSourceFileName,OrderType_MTV_ID,SubOrderType_ID,Carrier_MTV_CODE,ShipmentRegDate,CreatedBy,PARENT_ORDER_ID,QuoteID,QuoteAmount,PreAssignedTrackingNo
			,SELLER_KEY,SELLER_CODE,SUB_SELLER_KEY,SUB_SELLER_CODE,SELLER_PARTNER_KEY,SELLER_PARTNER_CODE,TARIFF_NO,BillingType_MTV_CODE,BillTo_CUSTOMER_KEY,BillTo_CUSTOMER_NO
			,BillToSub_CUSTOMER_NO,billtoaddresscode,billtoinformation,shipfromaddresscode,shipfrominformation,shiptoaddresscode,shiptoinformation,isblindshipto,clientidentifiers
			,pickupotherinfo,pickupspecialservices,deliveryotherinfo,deliveryspecialservices,initialcomment,initialcommentispublic,initialcomment2,initialcommentispublic2,orderdocs,itemsdetails
			,@OrderGUID as OrderGUID into #JsonHeaderTable from [POMS_DB].[dbo].[F_Get_Order_JsonHeaderTable] (@CreateOrderJson)

		select @UserName = upper(CreatedBy), @SellToCustomerKey = SELLER_KEY, @SellToCustomerNo = SELLER_CODE, @SubSellToCustomerKey = SUB_SELLER_KEY
		, @Carrier_MTV_CODE = Carrier_MTV_CODE ,@OrderType_MTV_ID = OrderType_MTV_ID ,@SubOrderType_ID = SubOrderType_ID
		, @SubSellToCustomerNo = SUB_SELLER_CODE, @SellToPartnerKey = SELLER_PARTNER_KEY, @SellToPartnerCode = SELLER_PARTNER_CODE, @TARIFFNO = TARIFF_NO
		, @BillToCustomerKey = BillTo_CUSTOMER_KEY, @BillToCustomerNo = BillTo_CUSTOMER_NO, @BillToCustomerSubNo = BillToSub_CUSTOMER_NO
		, @IsBlindShipment = isblindshipto, @BillingType_MTV_CODE = BillingType_MTV_CODE, @PreAssignedTrackingNo = PreAssignedTrackingNo
		, @Comment = isnull(initialcomment,''), @IsPublicComment = isnull(initialcommentispublic,1) 
		, @Comment2 = isnull(initialcomment2,''), @IsPublicComment2 = isnull(initialcommentispublic2,1) 
		, @BillToAddressCode = billtoaddresscode , @ShipFromAddressCode = shipfromaddresscode , @ShipToAddressCode = shiptoaddresscode 
		from #JsonHeaderTable
		
		drop table if exists #SellToCustomerInfoTable
		select SellerKey,SellerCode,SellerName into #SellToCustomerInfoTable
		from [POMS_DB].[dbo].[F_Get_SellToClientList] (@selltocustomerkey,@username)

		select @SellToCustomerKey = SellerKey
		,@SellToCustomerNo = SellerCode
		,@SellToCustomerName = SellerName 
		from #SellToCustomerInfoTable 

		--drop table if exists #BillToCustomerInfoTable
		--select CustomerKey,CustomerNo,CustomerName,PaymentTermsCode,PaymentMethodCode,DepartmentCode into #BillToCustomerInfoTable 
		--from [POMS_DB].[dbo].[F_Get_BillToClientList] (@BillToCustomerKey,null)

		drop table if exists #BillToCustomerInfoTable
		select CustomerKey = billtocustomerkey 
		, CustomerNo = billtocustomerno 
		, CustomerName = billtocustomername 
		, PaymentTermsCode = PaymentTermsCode 
		, PaymentMethodCode = PaymentMethodCode 
		, DepartmentCode = DepartmentCode 
		, BillToSubCustomerNo = billtosubcustomerno 
		, IsActive = isactive 
		, IsCreateOrderAPIActive = iscreateorderapiactive 
		, IsIgnoreError = isignoreerror 
		, BillingType = billingtype 
		into #BillToCustomerInfoTable from #ClientTableInfo

		select @BillToCustomerKey = CustomerKey
		,@BillToCustomerNo = CustomerNo
		,@BillToCustomerSubNo = BillToSubCustomerNo
		,@BillToCustomerName = CustomerName 
		from #BillToCustomerInfoTable 

		select @SellToPartnerKey = SellerPartnerKey
		,@SellToPartnerCode = SellerPartnerCode
		,@SellToPartnerName = SellerPartnerName
		from #SellerPartnerMapping

		select @SubSellToCustomerKey = SubSellerKey
		,@SubSellToCustomerNo = SubSellerCode
		,@SubSellToCustomerName = SubSellerName
		from #SubSellerMapping

		--CREATE TABLE #AddressListTable ([ADDRESS_ID] [int] NOT NULL, [ADDRESS_CODE] [nvarchar](50) NULL, [ST_CODE] [nvarchar](20) NULL, [ServiceType_MTV_ID] [int] NULL
		--	, [FirstName] [nvarchar](50) NULL,	[MiddleName] [nvarchar](50) NULL, [LastName] [nvarchar](50) NULL, [Company] [nvarchar](250) NULL , [ContactPerson] [nvarchar](150) NULL
		--	, [Address] [nvarchar](250) NOT NULL, [Address2] [nvarchar](250) NULL, [City] [nvarchar](50) NOT NULL , [State] [nvarchar](5) NOT NULL, [ZipCode] [nvarchar](10) NOT NULL
		--	, [County] [nvarchar](50) NOT NULL, [CountryRegionCode] [nvarchar](10) NULL , [Email] [nvarchar](250) NULL, [Mobile] [nvarchar](30) NULL, [Phone] [nvarchar](20) NULL
		--	, [PhoneExt] [nvarchar](10) NULL, [AddressType_MTV_ID] [int] NOT NULL , [AddressStatus_MTV_ID] [int] NOT NULL ,[IsValidAddress] [bit] NOT NULL
		--	, Latitude [nvarchar](30) NOT NULL, Longitude [nvarchar](30) NOT NULL, PlaceID [nvarchar](max) NOT NULL)

		--if @BillToAddressCode is not null
		--begin
		--	insert into #AddressListTable
		--	select [ADDRESS_ID] , al.[ADDRESS_CODE] , [ST_CODE] , [ServiceType_MTV_ID] , [FirstName] ,	[MiddleName] , [LastName] , [Company] , [ContactPerson] 
		--	, [Address] , [Address2] , [City] , [State] , [ZipCode] , [County] , [CountryRegionCode] , [Email] , [Mobile] , [Phone] , [PhoneExt] , [AddressType_MTV_ID] 
		--	, [AddressStatus_MTV_ID] ,[IsValidAddress], Latitude , Longitude , PlaceID from [POMS_DB].[dbo].[T_Address_List] al with (nolock) 
		--	inner join [POMS_DB].[dbo].[T_User_Address_List] ual with (nolock) on al.[ADDRESS_CODE] = ual.[ADDRESS_CODE] and ual.IsActive = 1
		--	where ual.[UserName] = @UserName and ual.[ADDRESS_CODE] = @BillToAddressCode and al.[AddressType_MTV_ID] = 130102 and al.IsActive = 1 and al.[AddressStatus_MTV_ID] = 131101
			
		--	if not exists(select [ADDRESS_ID] from #AddressListTable where [ADDRESS_CODE] = @BillToAddressCode and [AddressType_MTV_ID] = 130102)
		--	begin
		--		set @Return_Text = 'Invalid Bill To Address Code'
		--		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		--		return
		--	end
		--end

		--if @ShipFromAddressCode is not null
		--begin
		--	insert into #AddressListTable
		--	select [ADDRESS_ID] , al.[ADDRESS_CODE] , [ST_CODE] , [ServiceType_MTV_ID] , [FirstName] ,	[MiddleName] , [LastName] , [Company] , [ContactPerson] 
		--	, [Address] , [Address2] , [City] , [State] , [ZipCode] , [County] , [CountryRegionCode] , [Email] , [Mobile] , [Phone] , [PhoneExt] , [AddressType_MTV_ID] 
		--	, [AddressStatus_MTV_ID] ,[IsValidAddress], Latitude , Longitude , PlaceID from [POMS_DB].[dbo].[T_Address_List] al with (nolock) 
		--	inner join [POMS_DB].[dbo].[T_User_Address_List] ual with (nolock) on al.[ADDRESS_CODE] = ual.[ADDRESS_CODE] and ual.IsActive = 1
		--	where ual.[UserName] = @UserName and ual.[ADDRESS_CODE] = @ShipFromAddressCode and al.[AddressType_MTV_ID] = 130100 and al.IsActive = 1 and al.[AddressStatus_MTV_ID] = 131101
			
		--	if not exists(select [ADDRESS_ID] from #AddressListTable where [ADDRESS_CODE] = @ShipFromAddressCode and [AddressType_MTV_ID] = 130100)
		--	begin
		--		set @Return_Text = 'Invalid Ship From Address Code'
		--		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		--		return
		--	end
		--end
		
		--if @ShipToAddressCode is not null
		--begin
		--	insert into #AddressListTable
		--	select [ADDRESS_ID] , al.[ADDRESS_CODE] , [ST_CODE] , [ServiceType_MTV_ID] , [FirstName] ,	[MiddleName] , [LastName] , [Company] , [ContactPerson] 
		--	, [Address] , [Address2] , [City] , [State] , [ZipCode] , [County] , [CountryRegionCode] , [Email] , [Mobile] , [Phone] , [PhoneExt] , [AddressType_MTV_ID] 
		--	, [AddressStatus_MTV_ID] ,[IsValidAddress], Latitude , Longitude , PlaceID from [POMS_DB].[dbo].[T_Address_List] al with (nolock) 
		--	inner join [POMS_DB].[dbo].[T_User_Address_List] ual with (nolock) on al.[ADDRESS_CODE] = ual.[ADDRESS_CODE] and ual.IsActive = 1
		--	where ual.[UserName] = @UserName and ual.[ADDRESS_CODE] = @ShipToAddressCode and al.[AddressType_MTV_ID] = 130101 and al.IsActive = 1 and al.[AddressStatus_MTV_ID] = 131101
			
		--	if not exists(select [ADDRESS_ID] from #AddressListTable where [ADDRESS_CODE] = @ShipToAddressCode and [AddressType_MTV_ID] = 130101)
		--	begin
		--		set @Return_Text = 'Invalid Ship To Address Code'
		--		select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text 
		--		return
		--	end
		--end

		select @BillToInformation_Json = billtoinformation
		,@ShipFromInformation_Json = shipfrominformation 
		,@ShipToInformation_Json = shiptoinformation
		,@ClientIdentifiers_Json = clientidentifiers
		,@PickupOtherInfo_Json = pickupotherinfo
		,@PickupSpecialServices_Json = pickupspecialservices
		,@DeliveryOtherInfo_Json = deliveryotherinfo
		,@DeliverySpecialServices_Json = deliveryspecialservices
		,@OrderDocs_Json = orderdocs
		,@ItemsDetails_Json = itemsdetails
		from #JsonHeaderTable

		drop table if exists #BillToAddressInfoTable
		create table #BillToAddressInfoTable
		(BillTo_FirstName nvarchar(50)
		,BillTo_MiddleName nvarchar(50)
		,BillTo_LastName nvarchar(50)
		,BillTo_Company nvarchar(250)
		,BillTo_ContactPerson nvarchar(50)
		,BillTo_Address nvarchar(250)
		,BillTo_Address2 nvarchar(250)
		,BillTo_City nvarchar(50)
		,BillTo_State nvarchar(5)
		,BillTo_ZipCode nvarchar(10)
		,BillTo_County nvarchar(50)
		,BillTo_CountryRegionCode nvarchar(10)
		,BillTo_Email nvarchar(250)
		,BillTo_Mobile nvarchar(30)
		,BillTo_Phone nvarchar(20)
		,BillTo_PhoneExt nvarchar(10)
		,BillTo_Lat nvarchar(30)
		,BillTo_Lng nvarchar(30)
		,BillTo_PlaceID nvarchar(500)
		,OrderGUID nvarchar(36))

		if @BillingType_MTV_CODE not in ('100','110') and @BillToAddressCode is null and isnull(@BillToInformation_Json,'') <> ''
		begin
			insert into #BillToAddressInfoTable (BillTo_FirstName ,BillTo_MiddleName ,BillTo_LastName ,BillTo_Company ,BillTo_ContactPerson ,BillTo_Address 
			,BillTo_Address2 ,BillTo_City ,BillTo_State ,BillTo_ZipCode ,BillTo_County ,BillTo_CountryRegionCode ,BillTo_Email ,BillTo_Mobile ,BillTo_Phone 
			,BillTo_PhoneExt ,BillTo_Lat ,BillTo_Lng ,BillTo_PlaceID ,OrderGUID)
			select FirstName ,MiddleName ,LastName ,Company ,ContactPerson ,[Address] ,Address2 ,City ,[State] ,ZipCode ,County ,CountryRegionCode ,Email ,Mobile ,Phone 
			,PhoneExt ,Lat ,Lng ,PlaceID ,@OrderGUID as OrderGUID from [POMS_DB].[dbo].[F_Get_Order_JsonAddressInfo] (@BillToInformation_Json)
		end
		--else if (isnull(@BillToInformation_Json,'') = '' and @BillingType_MTV_CODE <> '110') and @BillToAddressCode is null
		else if @BillingType_MTV_CODE not in ('100','110') and @BillToAddressCode is not null
		begin
			insert into #BillToAddressInfoTable (BillTo_FirstName ,BillTo_MiddleName ,BillTo_LastName ,BillTo_Company ,BillTo_ContactPerson ,BillTo_Address 
			,BillTo_Address2 ,BillTo_City ,BillTo_State ,BillTo_ZipCode ,BillTo_County ,BillTo_CountryRegionCode ,BillTo_Email ,BillTo_Mobile ,BillTo_Phone 
			,BillTo_PhoneExt ,BillTo_Lat ,BillTo_Lng ,BillTo_PlaceID ,OrderGUID)
			select [FirstName] , [MiddleName] , [LastName] , [Company] , [ContactPerson] , [Address] , [Address2] , [City] , [State] , [ZipCode] 
			, [County] , [CountryRegionCode] , [Email] , [Mobile] , [Phone] , [PhoneExt] , Latitude , Longitude , PlaceID ,@OrderGUID as OrderGUID 
			from #AddressListTable where [ADDRESS_CODE] = @BillToAddressCode and [AddressType_MTV_ID] = 130102
		end
		else if (@BillingType_MTV_CODE in ('100','110'))
		begin
			insert into #BillToAddressInfoTable (BillTo_FirstName ,BillTo_MiddleName ,BillTo_LastName ,BillTo_Company ,BillTo_ContactPerson ,BillTo_Address 
			,BillTo_Address2 ,BillTo_City ,BillTo_State ,BillTo_ZipCode ,BillTo_County ,BillTo_CountryRegionCode ,BillTo_Email ,BillTo_Mobile ,BillTo_Phone 
			,BillTo_PhoneExt ,BillTo_Lat ,BillTo_Lng ,BillTo_PlaceID ,OrderGUID)
			select BillTo_FirstName = null ,BillTo_MiddleName = null ,BillTo_LastName = null ,BillTo_Company = null ,BillTo_ContactPerson = null ,BillTo_Address = null
			,BillTo_Address2 = null ,BillTo_City = null ,BillTo_State = null ,BillTo_ZipCode = null ,BillTo_County = null ,BillTo_CountryRegionCode = null ,BillTo_Email = null
			,BillTo_Mobile = null ,BillTo_Phone = null ,BillTo_PhoneExt = null ,BillTo_Lat = null ,BillTo_Lng = null ,BillTo_PlaceID = null ,@OrderGUID
		end

		drop table if exists #JsonOtherInfoTable
		select [ReqPickup_Date]=vjoit.[ReqPickup_Date] , [ReqPickup_FromTime]=vjoit.[ReqPickup_FromTime] , [ReqPickup_ToTime]=vjoit.[ReqPickup_ToTime] , [PICKUP_ST_CODE]=vjoit.[PICKUP_ST_CODE] 
		, [PICKUP_SST_CODE]=vjoit.[PICKUP_SST_CODE] , PU_Instruction=vjoit.PU_Instruction , [ReqDelivery_Date]=vjoit.[ReqDelivery_Date] , [ReqDelivery_FromTime]=vjoit.[ReqDelivery_FromTime] 
		, [ReqDelivery_ToTime]=vjoit.[ReqDelivery_ToTime] , [DELIVERY_ST_CODE]=vjoit.[DELIVERY_ST_CODE] , [DELIVERY_SST_CODE]=vjoit.[DELIVERY_SST_CODE] , DEL_Instruction=vjoit.DEL_Instruction 
		, OrderGUID = @OrderGUID into #JsonOtherInfoTable from #ValidationJsonOtherInfoTable vjoit
		
		select @PICKUP_ST_CODE = isnull(PICKUP_ST_CODE,'')
		,@PICKUP_SST_CODE = isnull(PICKUP_SST_CODE,'')
		,@DELIVERY_ST_CODE = isnull(DELIVERY_ST_CODE,'')
		,@DELIVERY_SST_CODE = isnull(DELIVERY_SST_CODE,'')
		,@PU_Instruction = isnull(PU_Instruction,'')
		,@DEL_Instruction = isnull(DEL_Instruction,'')
		from #JsonOtherInfoTable

		drop table if exists #JsonShipFromAddressInfoTable
		create table #JsonShipFromAddressInfoTable
		(ShipFrom_FirstName nvarchar(50)
		,ShipFrom_MiddleName nvarchar(50)
		,ShipFrom_LastName nvarchar(50)
		,ShipFrom_Company nvarchar(250)
		,ShipFrom_ContactPerson nvarchar(50)
		,ShipFrom_Address nvarchar(250)
		,ShipFrom_Address2 nvarchar(250)
		,ShipFrom_City nvarchar(50)
		,ShipFrom_State nvarchar(5)
		,ShipFrom_ZipCode nvarchar(10)
		,ShipFrom_County nvarchar(50)
		,ShipFrom_CountryRegionCode nvarchar(10)
		,ShipFrom_Email nvarchar(250)
		,ShipFrom_Mobile nvarchar(30)
		,ShipFrom_Phone nvarchar(20)
		,ShipFrom_PhoneExt nvarchar(10)
		,IsShipFrom_ValidAddress bit
		,ShipFrom_Lat nvarchar(30)
		,ShipFrom_Lng nvarchar(30)
		,ShipFrom_PlaceID nvarchar(500)
		,OrderGUID nvarchar(36))

		drop table if exists #JsonShipToAddressInfoTable
		create table #JsonShipToAddressInfoTable
		(ShipTo_FirstName nvarchar(50)
		,ShipTo_MiddleName nvarchar(50)
		,ShipTo_LastName nvarchar(50)
		,ShipTo_Company nvarchar(250)
		,ShipTo_ContactPerson nvarchar(50)
		,ShipTo_Address nvarchar(250)
		,ShipTo_Address2 nvarchar(250)
		,ShipTo_City nvarchar(50)
		,ShipTo_State nvarchar(5)
		,ShipTo_ZipCode nvarchar(10)
		,ShipTo_County nvarchar(50)
		,ShipTo_CountryRegionCode nvarchar(10)
		,ShipTo_Email nvarchar(250)
		,ShipTo_Mobile nvarchar(30)
		,ShipTo_Phone nvarchar(20)
		,ShipTo_PhoneExt nvarchar(10)
		,IsShipTo_ValidAddress bit
		,ShipTo_Lat nvarchar(30)
		,ShipTo_Lng nvarchar(30)
		,ShipTo_PlaceID nvarchar(500)
		,OrderGUID nvarchar(36))

		if @ShipFromAddressCode is null and @ShipToInformation_Json is not null
		begin
			insert into #JsonShipFromAddressInfoTable
			select ShipFrom.FirstName ,ShipFrom.MiddleName ,ShipFrom.LastName ,ShipFrom.Company ,ShipFrom.ContactPerson ,ShipFrom.[Address] ,ShipFrom.Address2 ,ShipFrom.City 
			,ShipFrom.[State] ,ShipFrom.ZipCode ,ShipFrom.County ,ShipFrom.CountryRegionCode ,ShipFrom.Email ,ShipFrom.Mobile ,ShipFrom.Phone ,ShipFrom.PhoneExt ,ShipFrom.IsValidAddress ,ShipFrom.Lat 
			,ShipFrom.Lng ,ShipFrom.PlaceID	,OrderGUID = @OrderGUID from [POMS_DB].[dbo].[F_Get_Order_JsonAddressInfo] (@ShipFromInformation_Json) ShipFrom
		end
		else if @ShipToAddressCode is null and @ShipToInformation_Json is null and @PICKUP_ST_CODE = 'MW'
		begin
			insert into #JsonShipFromAddressInfoTable
			select FirstName = '',MiddleName = '',LastName = '',Company = '',ContactPerson = '',[Address] = '',Address2 = '',City = '',[State] = ''
			,ZipCode = '',County = '',CountryRegionCode = '',Email = '',Mobile = '',Phone = '',PhoneExt = '',IsValidAddress = 0,Lat = '',Lng = '',PlaceID = ''
			,OrderGUID = @OrderGUID 
		end
		else
		begin
			insert into #JsonShipFromAddressInfoTable
			select [FirstName] , [MiddleName] , [LastName] , [Company] , [ContactPerson] , [Address] , [Address2] , [City] , [State] , [ZipCode] 
			, [County] , [CountryRegionCode] , [Email] , [Mobile] , [Phone] , [PhoneExt] ,[IsValidAddress] , Latitude , Longitude , PlaceID ,@OrderGUID as OrderGUID 
			from #AddressListTable where [ADDRESS_CODE] = @ShipFromAddressCode and [AddressType_MTV_ID] = 130100
		end

		if @ShipToAddressCode is null
		begin
			insert into #JsonShipToAddressInfoTable
			select ShipTo.FirstName ,ShipTo.MiddleName ,ShipTo.LastName ,ShipTo.Company ,ShipTo.ContactPerson ,ShipTo.[Address] ,ShipTo.Address2 ,ShipTo.City ,ShipTo.[State] 
			,ShipTo.ZipCode ,ShipTo.County ,ShipTo.CountryRegionCode ,ShipTo.Email ,ShipTo.Mobile ,ShipTo.Phone ,ShipTo.PhoneExt ,ShipTo.IsValidAddress ,ShipTo.Lat ,ShipTo.Lng ,ShipTo.PlaceID 
			,OrderGUID = @OrderGUID from [POMS_DB].[dbo].[F_Get_Order_JsonAddressInfo] (@ShipToInformation_Json) ShipTo 
		end
		else
		begin
			insert into #JsonShipToAddressInfoTable
			select [FirstName] , [MiddleName] , [LastName] , [Company] , [ContactPerson] , [Address] , [Address2] , [City] , [State] , [ZipCode] 
			, [County] , [CountryRegionCode] , [Email] , [Mobile] , [Phone] , [PhoneExt] , Latitude , Longitude , PlaceID ,@OrderGUID as OrderGUID 
			from #AddressListTable where [ADDRESS_CODE] = @ShipToAddressCode and [AddressType_MTV_ID] = 130101
		end

		if @IsBlindShipment = 1
		begin
			insert into #JsonShipToAddressInfoTable
			select ShipTo_FirstName = '' ,ShipTo_MiddleName = '',ShipTo_LastName = '',ShipTo_Company = '',ShipTo_ContactPerson = '',ShipTo_Address = '',ShipTo_Address2 = '',ShipTo_City = '',ShipTo_State = '' 
			,ShipTo_ZipCode = '',ShipTo_County = '',ShipTo_CountryRegionCode = '',ShipTo_Email = '',ShipTo_Mobile = '',ShipTo_Phone = '',ShipTo_PhoneExt = '',ShipTo_Lat = '',ShipTo_Lng = '',ShipTo_PlaceID = ''
			,OrderGUID = @OrderGUID 
		end
		
		Declare @ZipsList_Json nvarchar(max) = ''
		Declare @BillTo_ZipCode nvarchar(10) = ''
		Declare @ShipFrom_ZipCode nvarchar(10) = ''
		Declare @ShipTo_ZipCode nvarchar(10) = ''
		--'[{"zipcode":"08861","type_": 1},{"zipcode":"27260","type_": 2},{"zipcode":"91752","type_": 3}]'

		select @BillTo_ZipCode = BillTo_ZipCode from #BillToAddressInfoTable
		select @ShipFrom_ZipCode = ShipFrom_ZipCode from #JsonShipFromAddressInfoTable
		select @ShipTo_ZipCode = ShipTo_ZipCode from #JsonShipToAddressInfoTable
		set @BillTo_ZipCode = isnull(@BillTo_ZipCode,'')
		set @ShipFrom_ZipCode = isnull(@ShipFrom_ZipCode,'')
		set @ShipTo_ZipCode = isnull(@ShipTo_ZipCode,'')

		if @BillTo_ZipCode <> ''
		begin
			set @ZipsList_Json = (case when @ZipsList_Json = '' then '{"zipcode":"' + @BillTo_ZipCode + '","type_": 1}' else @ZipsList_Json + ',{"zipcode":"' + @BillTo_ZipCode + '","type_": 1}' end)
		end
		if @ShipFrom_ZipCode <> ''
		begin
			set @ZipsList_Json = (case when @ZipsList_Json = '' then '{"zipcode":"' + @ShipFrom_ZipCode + '","type_": 2}' else @ZipsList_Json + ',{"zipcode":"' + @ShipFrom_ZipCode + '","type_": 2}' end)
		end
		if @ShipTo_ZipCode <> ''
		begin
			set @ZipsList_Json = (case when @ZipsList_Json = '' then '{"zipcode":"' + @ShipTo_ZipCode + '","type_": 3}' else @ZipsList_Json + ',{"zipcode":"' + @ShipTo_ZipCode + '","type_": 3}' end)
		end
		if @ZipsList_Json <> ''
		begin
			set @ZipsList_Json = '[' + @ZipsList_Json + ']'
		end

		drop table if exists #PostCodeDetail
		select ZipCode ,Type_ ,TypeName ,[State] ,Latitude ,Longitude ,TIMEZONE_ID ,DrivingMiles ,MilesRadius ,AreaType_MTV_ID
		 ,Area_Type_Name ,Carrier ,HubCode ,HubName ,HubAddress ,HubAddress2 ,HubCity ,HubState ,HubPostCode ,HubZone into #PostCodeDetail 
		from [POMS_DB].[dbo].[F_Get_PostCode_JsonZipsTable] (@ZipsList_Json)

		select @ShipFrom_AreaType_MTV_ID = pu_pcd.AreaType_MTV_ID ,@ShipFrom_HUB_CODE = pu_pcd.HubCode from #PostCodeDetail pu_pcd where pu_pcd.Type_ = 2
		select @ShipTo_AreaType_MTV_ID = del_pcd.AreaType_MTV_ID ,@ShipTo_HUB_CODE = del_pcd.HubCode from #PostCodeDetail del_pcd where del_pcd.Type_ = 3
		select @ShipFrom_AreaType_MTV_ID = isnull(@ShipFrom_AreaType_MTV_ID,0) ,@ShipFrom_HUB_CODE = isnull(@ShipFrom_HUB_CODE,'')
		select @ShipTo_AreaType_MTV_ID = isnull(@ShipTo_AreaType_MTV_ID,0) ,@ShipTo_HUB_CODE = isnull(@ShipTo_HUB_CODE,'')

		Begin Try

			select @Source_MTV_ID = OrderSource_MTV_ID from #JsonHeaderTable
			exec [POMS_DB].[dbo].[P_Generate_OrderID] @Ret_OrderID = @Order_ID out
			--select @Order_ID = NEXT VALUE FOR POMS_DB.dbo.Get_Last_Used_ORDER_ID
			select @TRACKING_NO = [POMS_DB].[dbo].[F_Track] (@Order_ID)
		
			Begin Transaction

			insert into [POMS_DB].[dbo].[T_Order] ([Order_ID], [PARENT_ORDER_ID] ,[ORDER_CODE] ,[ORDER_CODE_GUID] ,[TRACKING_NO] ,[OrderSource_MTV_ID] ,[OrderSubSource_MTV_CODE] ,[OrderSubSourceFileName] ,[OrderPriority_MTV_ID] ,[Carrier_MTV_CODE] ,[ShipmentRegDate] ,[CreatedBy] ,[QuoteID] ,[QuoteAmount] ,[SELLER_CODE] ,[SUB_SELLER_CODE] 
			,[SELLER_PARTNER_CODE] ,[TARIFF_NO]	,[BillingType_MTV_CODE] ,[BillTo_CUSTOMER_NO] ,[BillToSub_CUSTOMER_NO] ,[BillTo_FirstName] ,[BillTo_MiddleName] ,[BillTo_LastName] ,[BillTo_Company] ,[BillTo_ContactPerson] ,[BillTo_Address] 
			,[BillTo_Address2] ,[BillTo_City] ,[BillTo_State] ,[BillTo_ZipCode] ,[BillTo_County] ,[BillTo_CountryRegionCode] ,[BillTo_Email] ,[BillTo_Mobile] ,[BillTo_Phone] ,[BillTo_PhoneExt] ,[PaymentStatus_MTV_ID] ,[ShipFrom_FirstName] ,[ShipFrom_MiddleName] 
			,[ShipFrom_LastName] ,[ShipFrom_Company] ,[ShipFrom_ContactPerson] ,[ShipFrom_Address] ,[ShipFrom_Address2] ,[ShipFrom_City] ,[ShipFrom_State] ,[ShipFrom_ZipCode] ,[ShipFrom_County] ,[ShipFrom_CountryRegionCode] 
			,[ShipFrom_Email] ,[ShipFrom_Mobile] ,[ShipFrom_Phone] ,[ShipFrom_PhoneExt] ,[IsShipFrom_ValidAddress] ,[ShipFrom_Lat] ,[ShipFrom_Lng] ,[ShipFrom_PlaceID] ,[ShipFrom_AreaType_MTV_ID] ,[ShipFrom_HUB_CODE] ,[LiveShipFrom_HUB_CODE] ,[ShipFrom_ZONE_CODE] 
			,[ShipTo_FirstName] ,[ShipTo_MiddleName] ,[ShipTo_LastName] ,[ShipTo_Company] ,[ShipTo_ContactPerson] ,[ShipTo_Address] ,[ShipTo_Address2] ,[ShipTo_City] ,[ShipTo_State] ,[ShipTo_ZipCode] ,[ShipTo_County] 
			,[ShipTo_CountryRegionCode] ,[ShipTo_Email] ,[ShipTo_Mobile] ,[ShipTo_Phone] ,[ShipTo_PhoneExt] ,[IsShipTo_ValidAddress] ,[ShipTo_Lat] ,[ShipTo_Lng] ,[ShipTo_PlaceID] ,[ShipTo_AreaType_MTV_ID] ,[ShipTo_HUB_CODE] ,[LiveShipTo_HUB_CODE] ,[ShipTo_ZONE_CODE] 
			,[IsBlindShipTo] ,[ReqPickup_Date] ,[ReqPickup_FromTime] ,[ReqPickup_ToTime] ,[PickupScheduleType_MTV_ID] ,[PICKUP_ST_CODE] ,[PICKUP_SST_CODE] ,[ReqDelivery_Date] ,[ReqDelivery_FromTime] ,[ReqDelivery_ToTime] ,[DeliveryScheduleType_MTV_ID] ,[DELIVERY_ST_CODE] ,[DELIVERY_SST_CODE])
	
			select @Order_ID as Order_ID, PARENT_ORDER_ID, @Order_ID as ORDER_CODE, @OrderGUID as [ORDER_CODE_GUID], @TRACKING_NO as TRACKING_NO, OrderSource_MTV_ID, OrderSubSource_MTV_Code, OrderSubSourceFileName, @OrderPriority_MTV_ID, @Carrier_MTV_CODE, ShipmentRegDate, @UserName as CreatedBy, [QuoteID] ,[QuoteAmount] ,@SellToCustomerNo ,@SubSellToCustomerNo 
			,@SellToPartnerCode ,@TARIFFNO ,[BillingType_MTV_CODE] ,@BillToCustomerNo ,@BillToCustomerSubNo ,[BillTo_FirstName] ,[BillTo_MiddleName] ,[BillTo_LastName] ,[BillTo_Company] ,[BillTo_ContactPerson] ,[BillTo_Address] ,[BillTo_Address2] 
			,[BillTo_City] ,[BillTo_State] ,[BillTo_ZipCode] ,[BillTo_County] ,[BillTo_CountryRegionCode] ,[BillTo_Email] ,[BillTo_Mobile] ,[BillTo_Phone] ,[BillTo_PhoneExt] ,@PaymentStatus_MTV_ID ,[ShipFrom_FirstName] ,[ShipFrom_MiddleName] 
			,[ShipFrom_LastName] ,[ShipFrom_Company] ,[ShipFrom_ContactPerson] ,[ShipFrom_Address] ,[ShipFrom_Address2] ,[ShipFrom_City] ,[ShipFrom_State] ,[ShipFrom_ZipCode] ,[ShipFrom_County] ,[ShipFrom_CountryRegionCode]
			,[ShipFrom_Email] ,[ShipFrom_Mobile] ,[ShipFrom_Phone] ,[ShipFrom_PhoneExt] ,[IsShipFrom_ValidAddress] ,[ShipFrom_Lat] ,[ShipFrom_Lng] ,[ShipFrom_PlaceID] ,pu_pcd.AreaType_MTV_ID ,ShipFromHubCode=pu_pcd.HubCode ,ShipFromLiveHubCode=pu_pcd.HubCode ,ShipFromHubZone=pu_pcd.HubZone ,[ShipTo_FirstName] 
			,[ShipTo_MiddleName] ,[ShipTo_LastName] ,[ShipTo_Company] ,[ShipTo_ContactPerson] ,[ShipTo_Address] ,[ShipTo_Address2] ,[ShipTo_City] ,[ShipTo_State] ,[ShipTo_ZipCode] ,[ShipTo_County] ,[ShipTo_CountryRegionCode]
			,[ShipTo_Email] ,[ShipTo_Mobile] ,[ShipTo_Phone] ,[ShipTo_PhoneExt] ,[IsShipTo_ValidAddress] ,[ShipTo_Lat] ,[ShipTo_Lng] ,[ShipTo_PlaceID] ,Area_Type=isnull(del_pcd.AreaType_MTV_ID,0) ,ShipToHubCode=isnull(del_pcd.HubCode,'') ,ShipToLiveHubCode=isnull(del_pcd.HubCode,'') ,ShipToHubZone=isnull(del_pcd.HubZone,'') ,[IsBlindShipTo] 
			,[ReqPickup_Date] ,[ReqPickup_FromTime] ,[ReqPickup_ToTime] ,[PickupScheduleType_MTV_ID] = [POMS_DB].[dbo].[F_Get_ScheduleType_MTV_ID_From_ZipCode] ([ShipFrom_ZipCode]) ,[PICKUP_ST_CODE] ,[PICKUP_SST_CODE] 
			,[ReqDelivery_Date],[ReqDelivery_FromTime] ,[ReqDelivery_ToTime] ,[DeliveryScheduleType_MTV_ID] = [POMS_DB].[dbo].[F_Get_ScheduleType_MTV_ID_From_ZipCode] ([ShipTo_ZipCode]) ,[DELIVERY_ST_CODE] ,[DELIVERY_SST_CODE]
			from #JsonHeaderTable jht inner join #BillToAddressInfoTable bait on jht.OrderGUID = bait.OrderGUID 
			inner join #JsonShipFromAddressInfoTable shipfrom on jht.OrderGUID = shipfrom.OrderGUID
			inner join #JsonShipToAddressInfoTable shipto on jht.OrderGUID = shipto.OrderGUID
			inner join #JsonOtherInfoTable joit on jht.OrderGUID = joit.OrderGUID inner join #PostCodeDetail pu_pcd on shipfrom.ShipFrom_ZipCode = pu_pcd.ZipCode and pu_pcd.Type_ = 2 left join #PostCodeDetail del_pcd on shipto.ShipTo_ZipCode = del_pcd.ZipCode and del_pcd.Type_ = 3
			
			--select * from #JsonHeaderTable jht 
			--select * from #BillToAddressInfoTable bait 
			--select * from #JsonShipFromToAddressInfoTable 
			--select * from #JsonOtherInfoTable 
			--select * from #PostCodeDetail 
			--select * from #PostCodeDetail del_pcd 
			
			if (@@ROWCOUNT = 0)
			begin
				set @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + 'Order Record was not Insert'
			end
			else 
			begin
				set @TempReturn_Code = 1
				if @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''
					Declare @AddImagesCount int = 0
					
					exec [POMS_DB].[dbo].[P_Order_Items_IU] @pJson = @ItemsDetails_Json ,@pOrder_ID = @Order_ID ,@pTRACKING_NO = @TRACKING_NO ,@pUserName = @UserName 
					,@pAddRowCount = @AddRowCount output ,@pEditRowCount = @EditRowCount output ,@pDeleteRowCount = @DeleteRowCount output 	
					,@pReturn_Code = @TempReturn_Code output ,@pReturn_Text = @TempReturn_Text output ,@pExecution_Error = @TempExecution_Error output 
					,@pError_Text = @TempError_Text output ,@pAddImagesCount = @AddImagesCount ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end

				if @TempReturn_Code = 1
				begin
					Declare @CurrentUTCDateTime datetime = getutcdate()
					select --@OEDAssignTo 
					@OEDAssignToDateTime = (case when @OEDAssignTo is null then null else @CurrentUTCDateTime end)
					,@OEDStatus_MTV_ID = (case when @OEDAssignTo is null then null else 140100 end)
					,@OEDStatusDateTime = (case when @OEDAssignTo is null then null else @CurrentUTCDateTime end)
					--@CSRAssignTo
					,@CSRAssignToDateTime = (case when @CSRAssignTo is null then null else @CurrentUTCDateTime end)
					,@CSRStatus_MTV_ID = (case when @CSRAssignTo is null then null else 141100 end)
					,@CSRStatusDateTime = (case when @CSRAssignTo is null then null else @CurrentUTCDateTime end)
					--@DispatchAssignTo
					,@DispatchAssignToDateTime = (case when @DispatchAssignTo is null then null else @CurrentUTCDateTime end)
					,@DispatchStatus_MTV_ID = (case when @DispatchAssignTo is null then null else 142100 end)
					,@DispatchStatusDateTime = (case when @DispatchAssignTo is null then null else @CurrentUTCDateTime end)
					--@AccountAssignTo
					,@AccountAssignToDateTime = (case when @AccountAssignTo is null then null else @CurrentUTCDateTime end)
					,@AccountStatus_MTV_ID = (case when @AccountAssignTo is null then null else 143100 end)
					,@AccountStatusDateTime = (case when @AccountAssignTo is null then null else @CurrentUTCDateTime end)
					
					--select @IsMWG = 0
					
					select @TotalQty = sum(Quantity)
					,@TotalValue = sum(Amount)
					,@TotalWeight = sum(ItemWeight)
					,@TotalCubes = sum(Cu_Ft_)
					,@TotalAssemblyMinutes = sum(AssemblyTime)
					,@LastGeneratedBarcode = max(right(BARCODE,4))
					from [POMS_DB].[dbo].[T_Order_Items] oi with (nolock) where oi.ORDER_ID = @Order_ID

					select @ShipFrom_MilesRadius = null
					,@ShipFrom_DrivingMiles = null
					,@ShipTo_MilesRadius = null
					,@ShipTo_DrivingMiles = null
					,@LineHaul_DrivingMiles = null

					insert into [POMS_DB].[dbo].[T_Order_Detail] ([ORDER_ID],[CurrentAssignToDept_MTV_CODE],[OEDAssignTo],[OEDAssignToDateTime],[OEDStatus_MTV_ID]
					,[OEDStatusDateTime],[CSRAssignTo],[CSRAssignToDateTime],[CSRStatus_MTV_ID],[CSRStatusDateTime],[DispatchAssignTo],[DispatchAssignToDateTime]
					,[DispatchStatus_MTV_ID],[DispatchStatusDateTime],[AccountAssignTo],[AccountAssignToDateTime],[AccountStatus_MTV_ID],[AccountStatusDateTime]
					,[IsMWG],[TotalQty],[TotalValue],[TotalWeight],[TotalCubes],[TotalAssemblyMinutes],[LastGeneratedBarcode],[ShipFrom_MilesRadius],[ShipFrom_DrivingMiles]
					,[ShipTo_MilesRadius],[ShipTo_DrivingMiles],[LineHaul_DrivingMiles],OrderType_MTV_ID,SubOrderType_ID,[AddedBy])
					select @Order_ID as Order_ID, @CurrentAssignToDept_MTV_CODE,@OEDAssignTo,@OEDAssignToDateTime,@OEDStatus_MTV_ID
					,@OEDStatusDateTime,@CSRAssignTo,@CSRAssignToDateTime,@CSRStatus_MTV_ID,@CSRStatusDateTime,@DispatchAssignTo,@DispatchAssignToDateTime
					,@DispatchStatus_MTV_ID,@DispatchStatusDateTime,@AccountAssignTo,@AccountAssignToDateTime,@AccountStatus_MTV_ID,@AccountStatusDateTime
					,@IsMWG,@TotalQty,@TotalValue,@TotalWeight,@TotalCubes,@TotalAssemblyMinutes,@LastGeneratedBarcode,@ShipFrom_MilesRadius,@ShipFrom_DrivingMiles
					,@ShipTo_MilesRadius,@ShipTo_DrivingMiles,@LineHaul_DrivingMiles,@OrderType_MTV_ID,@SubOrderType_ID,@UserName

					if (@@ROWCOUNT = 0)
					begin
						set @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + 'Order Detail Record was not Insert'
					end
				end
				
				if @TempReturn_Code = 1
				begin
					insert into [POMS_DB].[dbo].[T_Order_Additional_Info] ([ORDER_ID],[AddedBy])
					select @Order_ID as Order_ID, @UserName

					if (@@ROWCOUNT = 0)
					begin
						set @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + 'Order Additional Info Record was not Insert'
					end
				end
				
				if @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''

					exec [POMS_DB].[dbo].[P_Order_Client_Identifier_IU] @pJson = @ClientIdentifiers_Json ,@pOrder_ID = @Order_ID ,@pUserName = @UserName 
					,@pAddRowCount = @AddRowCount output ,@pEditRowCount = @EditRowCount output ,@pDeleteRowCount = @DeleteRowCount output 	
					,@pReturn_Code = @TempReturn_Code output ,@pReturn_Text = @TempReturn_Text output ,@pExecution_Error = @TempExecution_Error output 
					,@pError_Text = @TempError_Text output ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end

				if isnull(@PickupSpecialServices_Json,'') <> '' and @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''

					exec [POMS_DB].[dbo].[P_Order_Special_Service_IU] @pJson = @PickupSpecialServices_Json ,@pOrder_ID = @Order_ID ,@pUserName = @UserName ,@IsPickup = 1 ,@ST_CODE = @PICKUP_ST_CODE
					,@pAddRowCount = @AddRowCount output ,@pEditRowCount = @EditRowCount output ,@pDeleteRowCount = @DeleteRowCount output 	
					,@pReturn_Code = @TempReturn_Code output ,@pReturn_Text = @TempReturn_Text output ,@pExecution_Error = @TempExecution_Error output 
					,@pError_Text = @TempError_Text output ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end

				if isnull(@DeliverySpecialServices_Json,'') <> '' and @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''

					exec [POMS_DB].[dbo].[P_Order_Special_Service_IU] @pJson = @DeliverySpecialServices_Json ,@pOrder_ID = @Order_ID ,@pUserName = @UserName ,@IsPickup = 0 ,@ST_CODE = @Delivery_ST_CODE
					,@pAddRowCount = @AddRowCount output ,@pEditRowCount = @EditRowCount output ,@pDeleteRowCount = @DeleteRowCount output 	
					,@pReturn_Code = @TempReturn_Code output ,@pReturn_Text = @TempReturn_Text output ,@pExecution_Error = @TempExecution_Error output
					,@pError_Text = @TempError_Text output ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end

				if isnull(@OrderDocs_Json,'') <> '' and @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''

					exec [POMS_DB].[dbo].[P_Order_Docs_Insert] @ppJson = @OrderDocs_Json ,@ppOrder_ID = @Order_ID ,@ppTRACKING_NO = @TRACKING_NO 
					--,@ppAttachmentType_MTV_ID = 128100 
					,@ppUserName = @UserName
					,@ppAddRowCount = @AddRowCount output ,@ppReturn_Code = @TempReturn_Code output ,@ppReturn_Text = @TempReturn_Text output 
					,@ppExecution_Error = @TempExecution_Error output ,@ppError_Text = @TempError_Text output ,@ppIsBeginTransaction = 0
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end
				
				if @Comment <> '' and @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''

					exec [POMS_DB].[dbo].[P_Order_Comments_IU] @pJson = @OrderDocs_Json ,@pOrder_ID = @Order_ID ,@pOC_ID = 0 ,@pComment = @Comment
					,@pIsPublic = @IsPublicComment ,@pUserName = @UserName ,@pIsCall = 0 ,@pIsActive = 1 ,@pImportanceLevel_MTV_ID = null
					,@pAddRowCount = @AddRowCount output ,@pEditRowCount = @EditRowCount output ,@pDeleteRowCount = @DeleteRowCount output 	
					,@pReturn_Code = @TempReturn_Code output ,@pReturn_Text = @TempReturn_Text output ,@pExecution_Error = @TempExecution_Error output 
					,@pError_Text = @TempError_Text output ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end

				if @Comment2 <> '' and @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''

					exec [POMS_DB].[dbo].[P_Order_Comments_IU] @pJson = @OrderDocs_Json ,@pOrder_ID = @Order_ID ,@pOC_ID = 0 ,@pComment = @Comment2
					,@pIsPublic = @IsPublicComment2 ,@pUserName = @UserName ,@pIsCall = 0 ,@pIsActive = 1 ,@pImportanceLevel_MTV_ID = null
					,@pAddRowCount = @AddRowCount output ,@pEditRowCount = @EditRowCount output ,@pDeleteRowCount = @DeleteRowCount output 	
					,@pReturn_Code = @TempReturn_Code output ,@pReturn_Text = @TempReturn_Text output ,@pExecution_Error = @TempExecution_Error output 
					,@pError_Text = @TempError_Text output ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end

				if isnull(@PU_Instruction,'') <> '' and @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''

					exec [POMS_DB].[dbo].[P_Order_Special_Instruction_IU] @pJson = '' ,@pOrder_ID = @Order_ID ,@pOSI_ID = 0 ,@pInstructionType_MTV_ID = 124100 ,@pInstruction = @PU_Instruction ,@pUserName  = @UserName
					,@pAddRowCount = @AddRowCount output ,@pEditRowCount = @EditRowCount output ,@pDeleteRowCount = @DeleteRowCount output 	
					,@pReturn_Code = @TempReturn_Code output ,@pReturn_Text = @TempReturn_Text output ,@pExecution_Error = @TempExecution_Error output 
					,@pError_Text = @TempError_Text output ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end
				
				if isnull(@DEL_Instruction,'') <> '' and @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''

					exec [POMS_DB].[dbo].[P_Order_Special_Instruction_IU] @pJson = '' ,@pOrder_ID = @Order_ID ,@pOSI_ID = 0 ,@pInstructionType_MTV_ID = 124101 ,@pInstruction = @DEL_Instruction ,@pUserName  = @UserName
					,@pAddRowCount = @AddRowCount output ,@pEditRowCount = @EditRowCount output ,@pDeleteRowCount = @DeleteRowCount output 	
					,@pReturn_Code = @TempReturn_Code output ,@pReturn_Text = @TempReturn_Text output ,@pExecution_Error = @TempExecution_Error output 
					,@pError_Text = @TempError_Text output ,@pIsBeginTransaction = 0 ,@pSource_MTV_ID = @Source_MTV_ID
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end

				if @TempReturn_Code = 1
				begin
					select @TempReturn_Code = 1, @TempReturn_Text = '', @TempExecution_Error = '', @TempError_Text = ''
					
					exec [POMS_DB].[dbo].[P_Process_Order_Event_IU] @pppEVENT_ID = 1 ,@pppORDER_ID = @Order_ID ,@pppSELLER_CODE = @SellToCustomerNo ,@pppTriggerDate = @Currentdatetime ,@pppIsActive = 1 ,@pppIsAuto = 1 
					,@pppHUB_CODE = @ShipTo_HUB_CODE ,@pppSource_MTV_ID = @Source_MTV_ID ,@pppTriggerDebugInfo = null ,@pppUserName = @UserName ,@pppReturn_Code = @TempReturn_Code output ,@pppReturn_Text = @TempReturn_Text output 
					,@pppExecution_Error = @TempExecution_Error output ,@pppError_Text = @TempError_Text output ,@pppIsBeginTransaction = 0
					
					select @Return_Text = @Return_Text + (case when @Return_Text <> '' then '; ' else '' end) + @TempReturn_Text
					, @Execution_Error = @Execution_Error + (case when @Execution_Error <> '' then '; ' else '' end) + @TempExecution_Error
					, @Error_Text = @Error_Text + (case when @Error_Text <> '' then '; ' else '' end) + @TempError_Text
				end
				
			end

			if @Execution_Error = '' and @Return_Text = '' and @Error_Text = ''
			begin
				set @Return_Code = 1
			end
			
			if @@TRANCOUNT > 0 and @Return_Code = 1
			begin
				COMMIT; 
			end
			else if @@TRANCOUNT > 0 and @Return_Code = 0
			begin
				ROLLBACK; 
			end

		End Try
		Begin catch
			if @@TRANCOUNT > 0
			begin
				ROLLBACK; 
			end
			Set @Error_Text = 'P_Create_Order1: ' + ERROR_MESSAGE()
		End catch
			
	End Try
	Begin catch
		Set @Error_Text = 'P_Create_Order2: ' + ERROR_MESSAGE()
	End catch
	
	select @Return_Code as Return_Code ,@Return_Text as Return_Text ,@Execution_Error as Execution_Error ,@Error_Text as Error_Text

	if @Return_Code = 1
	begin
		select ORDER_CODE,TRACKING_NO,SellToCustomerKey=@SellToCustomerKey,SellToCustomerNo=@SellToCustomerNo,SellToCustomerName=@SellToCustomerName
		,SellToPartnerKey=@SellToPartnerKey,SellToPartnerCode=@SellToPartnerCode,SellToPartnerName=@SellToPartnerName
		,BillToCustomerKey=@BillToCustomerKey,BillToCustomerNo=@BillToCustomerNo,BillToCustomerSubNo=@BillToCustomerSubNo,BillToCustomerName=@BillToCustomerName
		,ShipFrom_Lat,ShipFrom_Lng
		,[Pickup_AreaType]=isnull(psd_pu.[AreaType_MTV_ID],0)
		,Pickup_Carrier=isnull(psd_pu.Carrier,'')
		,[Pickup_AreaTypeName]=isnull(psd_pu.[Area_Type_Name],'')
		,[Pickup_HubCode]=isnull(psd_pu.[HubCode],''),Pickup_HubName=isnull(psd_pu.HubName,''),Pickup_HubAddress=isnull(psd_pu.HubAddress,''),[Pickup_HubAddress2]=isnull(psd_pu.[HubAddress2],'')
		,Pickup_HubCity=isnull(psd_pu.HubCity,''),Pickup_HubState=isnull(psd_pu.HubState,''), Pickup_HubPostCode=isnull(psd_pu.[HubPostCode],'')
		--,ShipFrom_AreaType_MTV_ID,ShipFrom_HUB_CODE
		--,ShipFrom_AreaType_Name=(SELECT top 1 [Name] FROM [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_ID = ShipFrom_AreaType_MTV_ID)
		,ShipTo_Lat,ShipTo_Lng
		,[Delivery_AreaType]=isnull(psd_del.[AreaType_MTV_ID],0)
		,Delivery_Carrier=isnull(psd_del.Carrier,'')
		,[Delivery_AreaTypeName]=isnull(psd_del.[Area_Type_Name],'')
		,[Delivery_HubCode]=isnull(psd_del.[HubCode],''),Delivery_HubName=isnull(psd_del.HubName,''),Delivery_HubAddress=isnull(psd_del.HubAddress,''),[Delivery_HubAddress2]=isnull(psd_del.[HubAddress2],'')
		,Delivery_HubCity=isnull(psd_del.HubCity,''),Delivery_HubState=isnull(psd_del.HubState,''),Delivery_HubPostCode=isnull(psd_del.[HubPostCode],'')
		--,ShipTo_AreaType_MTV_ID,ShipTo_HUB_CODE, IsBlindShipTo 
		--,ShipTo_AreaType_Name=isnull((SELECT top 1 [Name] FROM [POMS_DB].[dbo].[T_Master_Type_Value] with (nolock) where MTV_ID = ShipTo_AreaType_MTV_ID),'')
		from [POMS_DB].[dbo].[T_Order] o with (nolock)
		left join #PostCodeDetail psd_pu on o.ShipFrom_ZipCode = psd_pu.ZipCode and psd_pu.Type_ = 2
		left join #PostCodeDetail psd_del on o.ShipTo_ZipCode = psd_del.ZipCode and psd_del.Type_ = 3
		where ORDER_ID = @Order_ID
		
		select BARCODE from [T_Order_Items] with (nolock) where ORDER_ID = @Order_ID order by BARCODE
	end

END
GO
