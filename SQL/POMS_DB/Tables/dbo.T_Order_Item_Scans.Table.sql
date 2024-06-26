USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Item_Scans]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Item_Scans](
	[TimeStamp] [timestamp] NOT NULL,
	[OIS_ID] [int] IDENTITY(1,1) NOT NULL,
	[BARCODE] [nvarchar](20) NOT NULL,
	[OI_ID] [int] NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[OIS_GUID] [nvarchar](36) NOT NULL,
	[ScanType_MTV_ID] [int] NOT NULL,
	[LOCATION_ID] [nvarchar](20) NOT NULL,
	[HUB_CODE] [nvarchar](20) NOT NULL,
	[DeviceCode_MTV_CODE] [nvarchar](20) NOT NULL,
	[ScanBy] [nvarchar](150) NOT NULL,
	[ScanTime] [datetime] NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[MANIFEST_ID] [int] NOT NULL,
	[ManifestType_MTV_ID] [int] NOT NULL,
	[Lat] [nvarchar](30) NULL,
	[Lng] [nvarchar](30) NULL,
	[ScanAnytime] [bit] NOT NULL,
	[AutoScan] [bit] NOT NULL,
	[IsRelabelRequired] [bit] NOT NULL,
	[ImageCount] [int] NOT NULL,
	[IsDamage] [bit] NOT NULL,
	[DamageNote] [nvarchar](1000) NULL,
	[IsActive] [bit] NOT NULL,
	[IsError] [bit] NOT NULL,
	[ErrorMsg] [nvarchar](1000) NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Barcode_Scan_History] PRIMARY KEY CLUSTERED 
(
	[OIS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Item_Scans] ADD  CONSTRAINT [DF_T_Order_Item_Scans_OI_GUID]  DEFAULT (lower(newid())) FOR [OIS_GUID]
GO
ALTER TABLE [dbo].[T_Order_Item_Scans] ADD  CONSTRAINT [DF_T_Barcode_Scan_History_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[T_Order_Item_Scans] ADD  CONSTRAINT [DF_T_Barcode_Scan_History_ManifestID]  DEFAULT ((0)) FOR [MANIFEST_ID]
GO
ALTER TABLE [dbo].[T_Order_Item_Scans] ADD  CONSTRAINT [DF_T_Barcode_Scan_History_ManifestType]  DEFAULT ((0)) FOR [ManifestType_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Item_Scans] ADD  CONSTRAINT [DF_T_Order_Item_Scans_IsRelabelRequired]  DEFAULT ((0)) FOR [IsRelabelRequired]
GO
ALTER TABLE [dbo].[T_Order_Item_Scans] ADD  CONSTRAINT [DF_T_Order_Item_Scans_ImageCount]  DEFAULT ((0)) FOR [ImageCount]
GO
ALTER TABLE [dbo].[T_Order_Item_Scans] ADD  CONSTRAINT [DF_T_Order_Item_Scans_IsDamage]  DEFAULT ((0)) FOR [IsDamage]
GO
ALTER TABLE [dbo].[T_Order_Item_Scans] ADD  CONSTRAINT [DF_T_Order_Item_Scans_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Order_Item_Scans] ADD  CONSTRAINT [DF_T_Order_Item_Scans_IsError]  DEFAULT ((0)) FOR [IsError]
GO
