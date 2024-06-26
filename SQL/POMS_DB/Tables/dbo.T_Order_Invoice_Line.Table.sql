USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Invoice_Line]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Invoice_Line](
	[TimeStamp] [timestamp] NOT NULL,
	[OIL_ID] [int] IDENTITY(1,1) NOT NULL,
	[EstimateID] [bigint] NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[LineNo_] [int] NOT NULL,
	[InvoiceLineType] [int] NOT NULL,
	[GL_NO] [nvarchar](20) NOT NULL,
	[Quantity] [decimal](18, 6) NOT NULL,
	[UnitPrice] [decimal](18, 6) NOT NULL,
	[LineAmount] [decimal](18, 6) NOT NULL,
	[Description] [nvarchar](150) NOT NULL,
	[SalesLineType] [int] NOT NULL,
	[WRDimension_HUB_CODE] [nvarchar](20) NOT NULL,
	[BLDimension_MTV_CODE] [nvarchar](20) NOT NULL,
	[SLDimension_SL_CODE] [nvarchar](20) NOT NULL,
	[DimensionID] [int] NOT NULL,
	[UpdateWRDimensionType_MTV_ID] [int] NOT NULL,
	[GoodsType] [nvarchar](20) NOT NULL,
	[ItemsQty] [int] NOT NULL,
	[ItemsWeight] [decimal](18, 6) NOT NULL,
	[ItemsCuFt] [decimal](18, 6) NOT NULL,
	[ItemsValue] [decimal](18, 6) NOT NULL,
	[REF1] [nvarchar](150) NULL,
	[REF2] [nvarchar](150) NULL,
	[REF3] [nvarchar](150) NULL,
	[REF4] [nvarchar](150) NULL,
	[REF5] [nvarchar](150) NULL,
	[REF6] [nvarchar](150) NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Order_Invoice_Line] PRIMARY KEY CLUSTERED 
(
	[OIL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line] ADD  CONSTRAINT [DF_T_Order_Invoice_Line_Quantity]  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line] ADD  CONSTRAINT [DF_T_Order_Invoice_Line_DimensionID]  DEFAULT ((0)) FOR [DimensionID]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line] ADD  CONSTRAINT [DF_T_Order_Invoice_Line_UpdateWRDimensionType_MTV_ID]  DEFAULT ((158100)) FOR [UpdateWRDimensionType_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line] ADD  CONSTRAINT [DF_T_Order_Invoice_Line_ItemsQty]  DEFAULT ((1)) FOR [ItemsQty]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line] ADD  CONSTRAINT [DF_T_Order_Invoice_Line_ItemsWeight]  DEFAULT ((0)) FOR [ItemsWeight]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line] ADD  CONSTRAINT [DF_T_Order_Invoice_Line_ItemsCuFt]  DEFAULT ((0)) FOR [ItemsCuFt]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line] ADD  CONSTRAINT [DF_T_Order_Invoice_Line_ItemsValue]  DEFAULT ((0)) FOR [ItemsValue]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line] ADD  CONSTRAINT [DF_T_Order_Invoice_Line_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line]  WITH CHECK ADD  CONSTRAINT [FK_T_Order_Invoice_Line_T_Order_Invoice_Header] FOREIGN KEY([EstimateID])
REFERENCES [dbo].[T_Order_Invoice_Header] ([EstimateID])
GO
ALTER TABLE [dbo].[T_Order_Invoice_Line] CHECK CONSTRAINT [FK_T_Order_Invoice_Line_T_Order_Invoice_Header]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 for Invoice Line, 0 for Invoice Comment/ Extended Text' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_Order_Invoice_Line', @level2type=N'COLUMN',@level2name=N'InvoiceLineType'
GO
