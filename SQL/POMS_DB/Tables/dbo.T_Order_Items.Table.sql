USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Items]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Items](
	[TimeStamp] [timestamp] NOT NULL,
	[OI_ID] [int] IDENTITY(1,1) NOT NULL,
	[PARENT_OI_ID] [int] NULL,
	[ORDER_ID] [int] NOT NULL,
	[BARCODE] [nvarchar](20) NOT NULL,
	[ItemToShip_MTV_CODE] [nvarchar](20) NOT NULL,
	[ItemCode_MTV_CODE] [nvarchar](20) NOT NULL,
	[PackingCode_MTV_CODE] [nvarchar](20) NOT NULL,
	[SKU_NO] [nvarchar](150) NOT NULL,
	[ItemDescription] [nvarchar](250) NOT NULL,
	[Quantity] [int] NOT NULL,
	[ItemWeight] [decimal](18, 6) NOT NULL,
	[WeightUnit_MTV_CODE] [nvarchar](20) NOT NULL,
	[ItemLength] [decimal](18, 6) NOT NULL,
	[ItemWidth] [decimal](18, 6) NOT NULL,
	[ItemHeight] [decimal](18, 6) NOT NULL,
	[Dimensions] [nvarchar](50) NOT NULL,
	[DimensionUnit_MTV_CODE] [nvarchar](20) NOT NULL,
	[Cu_Ft_] [decimal](18, 6) NOT NULL,
	[Amount] [decimal](18, 6) NOT NULL,
	[AssemblyTime] [int] NOT NULL,
	[PackageDetailsNote] [nvarchar](250) NULL,
	[ItemDeliveryStatus_MTV_ID] [int] NOT NULL,
	[ItemPickupStatus_MTV_ID] [int] NOT NULL,
	[ItemClientRef1] [nvarchar](150) NOT NULL,
	[ItemClientRef2] [nvarchar](150) NOT NULL,
	[ItemClientRef3] [nvarchar](150) NOT NULL,
	[RelabelCount] [int] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Sales_Order_Items] PRIMARY KEY CLUSTERED 
(
	[OI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Sales_Order_Items_Quantity]  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Sales_Order_Items_AssemblyTime]  DEFAULT ((0)) FOR [AssemblyTime]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Sales_Order_Items_PackageDetailsNote]  DEFAULT ('') FOR [PackageDetailsNote]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Sales_Order_Items_ItemDeliveryStatus]  DEFAULT ((0)) FOR [ItemDeliveryStatus_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Sales_Order_Items_ItemPickupStatus]  DEFAULT ((0)) FOR [ItemPickupStatus_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Sales_Order_Items_ItemClientRef1]  DEFAULT ('') FOR [ItemClientRef1]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Sales_Order_Items_ItemClientRef2]  DEFAULT ('') FOR [ItemClientRef2]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Sales_Order_Items_ItemClientRef3]  DEFAULT ('') FOR [ItemClientRef3]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Order_Items_RelabelCount]  DEFAULT ((0)) FOR [RelabelCount]
GO
ALTER TABLE [dbo].[T_Order_Items] ADD  CONSTRAINT [DF_T_Sales_Order_Items_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
