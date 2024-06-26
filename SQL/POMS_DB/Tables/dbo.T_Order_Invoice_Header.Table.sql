USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Invoice_Header]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Invoice_Header](
	[TimeStamp] [timestamp] NOT NULL,
	[EstimateID] [bigint] NOT NULL,
	[EstimateNo] [nvarchar](20) NOT NULL,
	[UnpostedInvoiceNo] [nvarchar](20) NOT NULL,
	[PostedInvoiceNo] [nvarchar](20) NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[DocumentType_MTV_ID] [int] NOT NULL,
	[Amount] [decimal](18, 6) NOT NULL,
	[InvoiceStatus_MTV_ID] [int] NOT NULL,
	[ApprovalValue_MTV_ID] [int] NOT NULL,
	[PostingDate] [date] NOT NULL,
	[DocumentDate] [date] NOT NULL,
	[PaymentTermsCode] [nvarchar](20) NOT NULL,
	[DueDate] [date] NOT NULL,
	[WRDimension_HUB_CODE] [nvarchar](20) NOT NULL,
	[BLDimension_MTV_CODE] [nvarchar](20) NOT NULL,
	[SLDimension_SL_CODE] [nvarchar](20) NOT NULL,
	[PaidAmount] [decimal](18, 6) NOT NULL,
	[CMAmount] [decimal](18, 6) NOT NULL,
	[DimensionID] [int] NOT NULL,
	[QBInvoiceNo] [nvarchar](50) NOT NULL,
	[RECTXT] [nvarchar](50) NOT NULL,
	[POCustRefNo] [nvarchar](50) NOT NULL,
	[LastPaymentDate] [date] NULL,
	[UnpostedOnDatetime] [datetime] NULL,
	[PostedOnDatetime] [datetime] NULL,
	[NeedEDI_MTV_ID] [int] NOT NULL,
	[EDIStatus_MTV_ID] [int] NOT NULL,
	[UpdateWRDimensionType_MTV_ID] [int] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Order_Invoice_Header_1] PRIMARY KEY CLUSTERED 
(
	[EstimateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_UnpostedInvoiceNo]  DEFAULT ('') FOR [UnpostedInvoiceNo]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_PostedInvoiceNo]  DEFAULT ('') FOR [PostedInvoiceNo]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_DocumentType_MTV_ID]  DEFAULT ((152100)) FOR [DocumentType_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_Amount]  DEFAULT ((0)) FOR [Amount]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_InvoiceStatus_MTV_ID]  DEFAULT ((153100)) FOR [InvoiceStatus_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_ApprovalValue_MTV_ID]  DEFAULT ((154100)) FOR [ApprovalValue_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_PostingDate]  DEFAULT (CONVERT([date],getutcdate())) FOR [PostingDate]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_DocumentDate]  DEFAULT (CONVERT([date],getutcdate())) FOR [DocumentDate]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_PaidAmount]  DEFAULT ((0)) FOR [PaidAmount]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_CMAmount]  DEFAULT ((0)) FOR [CMAmount]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_DimensionID]  DEFAULT ((0)) FOR [DimensionID]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_QBInvoiceNo]  DEFAULT ('') FOR [QBInvoiceNo]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_RECTXT]  DEFAULT ('') FOR [RECTXT]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_POCustRefNo]  DEFAULT ('') FOR [POCustRefNo]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_NeedEDI_MTV_ID]  DEFAULT ((155100)) FOR [NeedEDI_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_EDIStatus_MTV_ID]  DEFAULT ((156100)) FOR [EDIStatus_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_Update Whse_ Dimension Type]  DEFAULT ((158100)) FOR [UpdateWRDimensionType_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] ADD  CONSTRAINT [DF_T_Order_Invoice_Header_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header]  WITH CHECK ADD  CONSTRAINT [const_T_Order_Invoice_Header_EstimateNoCheck] CHECK  ((('S-ESTINV'+CONVERT([nvarchar](20),[EstimateID]))=[EstimateNo]))
GO
ALTER TABLE [dbo].[T_Order_Invoice_Header] CHECK CONSTRAINT [const_T_Order_Invoice_Header_EstimateNoCheck]
GO
