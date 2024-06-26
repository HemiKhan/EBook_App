USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Docs]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Docs](
	[TimeStamp] [timestamp] NOT NULL,
	[OD_ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[DocumentType_MTV_ID] [int] NOT NULL,
	[AttachmentType_MTV_ID] [int] NOT NULL,
	[OriginalFileName] [nvarchar](250) NULL,
	[ImageName] [nvarchar](100) NOT NULL,
	[Description_] [nvarchar](250) NOT NULL,
	[Path_] [nvarchar](250) NOT NULL,
	[RefNo] [nvarchar](40) NULL,
	[RefNo2] [nvarchar](40) NULL,
	[RefID] [int] NULL,
	[RefID2] [int] NULL,
	[IsPublic] [bit] NOT NULL,
	[Location] [nvarchar](20) NOT NULL,
	[DRIVER_ID] [int] NOT NULL,
	[DeliveryORPickup_Name] [nvarchar](250) NOT NULL,
	[DeliveryORPickup_Date] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Sales_Order_Images] PRIMARY KEY CLUSTERED 
(
	[OD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Docs] ADD  CONSTRAINT [DF_T_Sales_Order_Images_Location]  DEFAULT ('') FOR [Location]
GO
ALTER TABLE [dbo].[T_Order_Docs] ADD  CONSTRAINT [DF_T_Sales_Order_Images_DriverID]  DEFAULT ((0)) FOR [DRIVER_ID]
GO
ALTER TABLE [dbo].[T_Order_Docs] ADD  CONSTRAINT [DF_T_Sales_Order_Images_Delivery_Pickup_Name]  DEFAULT ('') FOR [DeliveryORPickup_Name]
GO
ALTER TABLE [dbo].[T_Order_Docs] ADD  CONSTRAINT [DF_T_Sales_Order_Images_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Order_Docs] ADD  CONSTRAINT [DF_T_Sales_Order_Images_CreatedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
