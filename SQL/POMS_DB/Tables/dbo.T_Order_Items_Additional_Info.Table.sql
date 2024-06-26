USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Items_Additional_Info]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Items_Additional_Info](
	[TimeStamp] [timestamp] NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[BARCODE] [nvarchar](20) NOT NULL,
	[FirstScanDate] [datetime] NULL,
	[FirstScanHub] [nvarchar](20) NULL,
	[FirstScanType_MTV_ID] [int] NULL,
	[LastScanDate] [datetime] NULL,
	[LastScanHub] [nvarchar](20) NULL,
	[LastScanLocationID] [nvarchar](20) NULL,
	[LastScanType_MTV_ID] [int] NULL,
	[ShipToHub_FirstScanDate] [datetime] NULL,
	[ShipToZone_FirstScanDate] [datetime] NULL,
	[WarehouseStatus_MTV_ID] [int] NOT NULL,
	[IsDamaged] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Order_Items_Additional_Info] PRIMARY KEY CLUSTERED 
(
	[BARCODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Items_Additional_Info] ADD  CONSTRAINT [DF_T_Order_Items_Additional_Info_WarehouseStatus_MTV_ID]  DEFAULT ((151100)) FOR [WarehouseStatus_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Items_Additional_Info] ADD  CONSTRAINT [DF_T_Order_Items_Additional_Info_IsDamaged]  DEFAULT ((0)) FOR [IsDamaged]
GO
ALTER TABLE [dbo].[T_Order_Items_Additional_Info] ADD  CONSTRAINT [DF_T_Order_Items_Additional_Info_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Order_Items_Additional_Info] ADD  CONSTRAINT [DF_T_Order_Items_Additional_Info_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
