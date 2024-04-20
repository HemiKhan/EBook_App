USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order](
	[TimeStamp] [timestamp] NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[PARENT_ORDER_ID] [int] NULL,
	[ORDER_CODE] [nvarchar](20) NOT NULL,
	[ORDER_CODE_GUID] [nvarchar](36) NOT NULL,
	[TRACKING_NO] [nvarchar](40) NOT NULL,
	[Pickup_OG_ID] [int] NOT NULL,
	[Delivery_OG_ID] [int] NOT NULL,
	[OrderStatus_MTV_ID] [int] NOT NULL,
	[OrderSource_MTV_ID] [int] NOT NULL,
	[OrderSubSource_MTV_CODE] [nvarchar](20) NULL,
	[OrderSubSourceFileName] [nvarchar](50) NULL,
	[OrderPriority_MTV_ID] [int] NOT NULL,
	[Carrier_MTV_CODE] [nvarchar](20) NOT NULL,
	[ShipmentRegDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[ShippingStatus_EVENT_ID] [int] NOT NULL,
	[QuoteID] [nvarchar](50) NULL,
	[QuoteAmount] [decimal](18, 6) NULL,
	[SELLER_CODE] [nvarchar](20) NOT NULL,
	[SUB_SELLER_CODE] [nvarchar](20) NULL,
	[SELLER_PARTNER_CODE] [nvarchar](20) NULL,
	[TARIFF_NO] [nvarchar](36) NULL,
	[BillingType_MTV_CODE] [nvarchar](20) NOT NULL,
	[BillTo_CUSTOMER_NO] [nvarchar](20) NOT NULL,
	[BillToSub_CUSTOMER_NO] [nvarchar](20) NULL,
	[BillTo_ADDRESS_CODE] [nvarchar](20) NULL,
	[BillTo_FirstName] [nvarchar](50) NULL,
	[BillTo_MiddleName] [nvarchar](50) NULL,
	[BillTo_LastName] [nvarchar](50) NULL,
	[BillTo_Company] [nvarchar](250) NULL,
	[BillTo_ContactPerson] [nvarchar](150) NULL,
	[BillTo_Address] [nvarchar](250) NULL,
	[BillTo_Address2] [nvarchar](250) NULL,
	[BillTo_City] [nvarchar](50) NULL,
	[BillTo_State] [nvarchar](5) NULL,
	[BillTo_ZipCode] [nvarchar](10) NULL,
	[BillTo_County] [nvarchar](50) NULL,
	[BillTo_CountryRegionCode] [nvarchar](10) NULL,
	[BillTo_Email] [nvarchar](250) NULL,
	[BillTo_Mobile] [nvarchar](30) NULL,
	[BillTo_Phone] [nvarchar](20) NULL,
	[BillTo_PhoneExt] [nvarchar](10) NULL,
	[PaymentStatus_MTV_ID] [int] NOT NULL,
	[ShipFrom_ADDRESS_CODE] [nvarchar](20) NULL,
	[ShipFrom_FirstName] [nvarchar](50) NOT NULL,
	[ShipFrom_MiddleName] [nvarchar](50) NOT NULL,
	[ShipFrom_LastName] [nvarchar](50) NOT NULL,
	[ShipFrom_Company] [nvarchar](250) NOT NULL,
	[ShipFrom_ContactPerson] [nvarchar](150) NOT NULL,
	[ShipFrom_Address] [nvarchar](250) NOT NULL,
	[ShipFrom_Address2] [nvarchar](250) NOT NULL,
	[ShipFrom_City] [nvarchar](50) NOT NULL,
	[ShipFrom_State] [nvarchar](5) NOT NULL,
	[ShipFrom_ZipCode] [nvarchar](10) NOT NULL,
	[ShipFrom_County] [nvarchar](50) NOT NULL,
	[ShipFrom_CountryRegionCode] [nvarchar](10) NOT NULL,
	[ShipFrom_Email] [nvarchar](250) NOT NULL,
	[ShipFrom_Mobile] [nvarchar](30) NOT NULL,
	[ShipFrom_Phone] [nvarchar](20) NOT NULL,
	[ShipFrom_PhoneExt] [nvarchar](10) NOT NULL,
	[IsShipFrom_ValidAddress] [bit] NOT NULL,
	[ShipFrom_Lat] [nvarchar](30) NOT NULL,
	[ShipFrom_Lng] [nvarchar](30) NOT NULL,
	[ShipFrom_PlaceID] [nvarchar](500) NOT NULL,
	[ShipFrom_AreaType_MTV_ID] [int] NOT NULL,
	[ShipFrom_HUB_CODE] [nvarchar](20) NOT NULL,
	[LiveShipFrom_HUB_CODE] [nvarchar](20) NOT NULL,
	[ShipFrom_ZONE_CODE] [nvarchar](20) NOT NULL,
	[ShipFrom_ChangeCount] [int] NOT NULL,
	[ShipTo_ADDRESS_CODE] [nvarchar](20) NULL,
	[ShipTo_FirstName] [nvarchar](50) NOT NULL,
	[ShipTo_MiddleName] [nvarchar](50) NOT NULL,
	[ShipTo_LastName] [nvarchar](50) NOT NULL,
	[ShipTo_Company] [nvarchar](250) NOT NULL,
	[ShipTo_ContactPerson] [nvarchar](50) NOT NULL,
	[ShipTo_Address] [nvarchar](250) NOT NULL,
	[ShipTo_Address2] [nvarchar](250) NOT NULL,
	[ShipTo_City] [nvarchar](50) NOT NULL,
	[ShipTo_State] [nvarchar](5) NOT NULL,
	[ShipTo_ZipCode] [nvarchar](10) NOT NULL,
	[ShipTo_County] [nvarchar](50) NOT NULL,
	[ShipTo_CountryRegionCode] [nvarchar](10) NOT NULL,
	[ShipTo_Email] [nvarchar](250) NOT NULL,
	[ShipTo_Mobile] [nvarchar](30) NOT NULL,
	[ShipTo_Phone] [nvarchar](20) NOT NULL,
	[ShipTo_PhoneExt] [nvarchar](10) NOT NULL,
	[IsShipTo_ValidAddress] [bit] NOT NULL,
	[ShipTo_Lat] [nvarchar](30) NOT NULL,
	[ShipTo_Lng] [nvarchar](30) NOT NULL,
	[ShipTo_PlaceID] [nvarchar](500) NOT NULL,
	[ShipTo_AreaType_MTV_ID] [int] NOT NULL,
	[ShipTo_HUB_CODE] [nvarchar](20) NOT NULL,
	[LiveShipTo_HUB_CODE] [nvarchar](20) NOT NULL,
	[ShipTo_ZONE_CODE] [nvarchar](20) NOT NULL,
	[IsBlindShipTo] [bit] NOT NULL,
	[ShipTo_ChangeCount] [int] NOT NULL,
	[InsuranceRequired] [bit] NULL,
	[ReqPickup_Date] [date] NULL,
	[ReqPickup_FromTime] [time](7) NULL,
	[ReqPickup_ToTime] [time](7) NULL,
	[FirstOffered_PickupDate] [date] NULL,
	[PickupScheduleType_MTV_ID] [int] NULL,
	[PickupWeekofDate] [date] NULL,
	[PromisedPickupDate] [date] NULL,
	[PkpSchByUserName] [nvarchar](150) NULL,
	[ReqPickupTimeFrame_TFL_ID] [int] NULL,
	[ConfirmedPickupTimeFrame_TFL_ID] [int] NULL,
	[PickupFMManifest] [int] NULL,
	[ConfirmedPickupDate] [date] NULL,
	[ActualPickupDate] [datetime] NULL,
	[PICKUP_ST_CODE] [nvarchar](20) NOT NULL,
	[PICKUP_SST_CODE] [nvarchar](20) NOT NULL,
	[ReqDelivery_Date] [date] NULL,
	[ReqDelivery_FromTime] [time](7) NULL,
	[ReqDelivery_ToTime] [time](7) NULL,
	[FirstOffered_DeliveryDate] [date] NULL,
	[DeliveryScheduleType_MTV_ID] [int] NULL,
	[DeliveryWeekofDate] [date] NULL,
	[PromisedDeliveryDate] [date] NULL,
	[DlvSchByUserName] [nvarchar](150) NULL,
	[ReqDeliveryTimeFrame_TFL_ID] [int] NULL,
	[ConfirmedDeliveryTimeFrame_TFL_ID] [int] NULL,
	[DeliveryFMManifest] [int] NULL,
	[ConfirmedDeliveryDate] [date] NULL,
	[ActualDeliveryDate] [datetime] NULL,
	[DELIVERY_ST_CODE] [nvarchar](20) NOT NULL,
	[DELIVERY_SST_CODE] [nvarchar](20) NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Sales_Order_Header] PRIMARY KEY CLUSTERED 
(
	[ORDER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order] ADD  CONSTRAINT [DF_T_Order_ORDER_CODE_GUID]  DEFAULT (upper(newid())) FOR [ORDER_CODE_GUID]
GO
ALTER TABLE [dbo].[T_Order] ADD  CONSTRAINT [DF_T_Order_Pickup_OG_ID]  DEFAULT ((0)) FOR [Pickup_OG_ID]
GO
ALTER TABLE [dbo].[T_Order] ADD  CONSTRAINT [DF_T_Sales_Order_Header_OG_ID]  DEFAULT ((0)) FOR [Delivery_OG_ID]
GO
ALTER TABLE [dbo].[T_Order] ADD  CONSTRAINT [DF_T_Sales_Order_Header_OrderStatus]  DEFAULT ((10000)) FOR [OrderStatus_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order] ADD  CONSTRAINT [DF_T_Order_OrderPriority_MTV_ID]  DEFAULT ((138100)) FOR [OrderPriority_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order] ADD  CONSTRAINT [DF_T_Sales_Order_Header_ShipmentRegDate]  DEFAULT (getutcdate()) FOR [ShipmentRegDate]
GO
ALTER TABLE [dbo].[T_Order] ADD  CONSTRAINT [DF_T_Sales_Order_Header_ShippingStatus]  DEFAULT ((1)) FOR [ShippingStatus_EVENT_ID]
GO
ALTER TABLE [dbo].[T_Order] ADD  CONSTRAINT [DF_T_Order_ShipTo_ChangeCount1]  DEFAULT ((0)) FOR [ShipFrom_ChangeCount]
GO
ALTER TABLE [dbo].[T_Order] ADD  CONSTRAINT [DF_T_Order_ShipTo_ChangeCount]  DEFAULT ((0)) FOR [ShipTo_ChangeCount]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'No Validation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_Order', @level2type=N'COLUMN',@level2name=N'Carrier_MTV_CODE'
GO
