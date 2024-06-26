USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Events_List]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Events_List](
	[TimeStamp] [timestamp] NOT NULL,
	[EL_ID] [int] IDENTITY(1,1) NOT NULL,
	[EVENT_ID] [int] NOT NULL,
	[EVENT_CODE] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[Activity_MTV_ID] [int] NOT NULL,
	[SubActivity_MTV_ID] [int] NOT NULL,
	[IsAutoTrigger] [bit] NOT NULL,
	[IsManualTrigger] [bit] NOT NULL,
	[IsOutboundRequired] [bit] NOT NULL,
	[IsNotify_Metro_Email] [bit] NOT NULL,
	[IsNotify_Metro_SMS] [bit] NOT NULL,
	[IsNotify_Client_Email] [bit] NOT NULL,
	[IsNotify_Client_SMS] [bit] NOT NULL,
	[IsNotify_OED_Email] [bit] NOT NULL,
	[IsNotify_OED_SMS] [bit] NOT NULL,
	[IsNotify_CSR_Email] [bit] NOT NULL,
	[IsNotify_CSR_SMS] [bit] NOT NULL,
	[IsNotify_Dispatch_Email] [bit] NOT NULL,
	[IsNotify_Dispatch_SMS] [bit] NOT NULL,
	[IsNotify_Accounting_Email] [bit] NOT NULL,
	[IsNotify_Accounting_SMS] [bit] NOT NULL,
	[IsNotify_Warehouse_Email] [bit] NOT NULL,
	[IsNotify_Warehouse_SMS] [bit] NOT NULL,
	[IsNotify_ShipFrom_Email] [bit] NOT NULL,
	[IsNotify_ShipFrom_SMS] [bit] NOT NULL,
	[IsNotify_ShipTo_Email] [bit] NOT NULL,
	[IsNotify_ShipTo_SMS] [bit] NOT NULL,
	[IsNotify_SellTo_Email] [bit] NOT NULL,
	[IsNotify_SellTo_SMS] [bit] NOT NULL,
	[IsNotify_SellToPartner_Email] [bit] NOT NULL,
	[IsNotify_SellToPartner_SMS] [bit] NOT NULL,
	[IsNotify_BillTo_Email] [bit] NOT NULL,
	[IsNotify_BillTo_SMS] [bit] NOT NULL,
	[IsRecurring] [bit] NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[IsTrackingAvailable] [bit] NOT NULL,
	[IsUpdateShippingStatus] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Events_List] PRIMARY KEY CLUSTERED 
(
	[EL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_SubActivity_MTV_ID]  DEFAULT ((0)) FOR [SubActivity_MTV_ID]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsOutboundRequired]  DEFAULT ((0)) FOR [IsOutboundRequired]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Metro_Email]  DEFAULT ((0)) FOR [IsNotify_Metro_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Metro_SMS]  DEFAULT ((0)) FOR [IsNotify_Metro_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Client_Email]  DEFAULT ((0)) FOR [IsNotify_Client_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Client_SMS]  DEFAULT ((0)) FOR [IsNotify_Client_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_OED_Email]  DEFAULT ((0)) FOR [IsNotify_OED_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_OED_SMS]  DEFAULT ((0)) FOR [IsNotify_OED_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_CSR_Email]  DEFAULT ((0)) FOR [IsNotify_CSR_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_CSR_SMS]  DEFAULT ((0)) FOR [IsNotify_CSR_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Dispatch_Email]  DEFAULT ((0)) FOR [IsNotify_Dispatch_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Dispatch_SMS]  DEFAULT ((0)) FOR [IsNotify_Dispatch_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Accounting_Email]  DEFAULT ((0)) FOR [IsNotify_Accounting_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Accounting_SMS]  DEFAULT ((0)) FOR [IsNotify_Accounting_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Warehouse_Email]  DEFAULT ((0)) FOR [IsNotify_Warehouse_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_Warehouse_SMS]  DEFAULT ((0)) FOR [IsNotify_Warehouse_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_ShipFrom_Email]  DEFAULT ((0)) FOR [IsNotify_ShipFrom_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_ShipFrom_SMS]  DEFAULT ((0)) FOR [IsNotify_ShipFrom_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_ShipTo_Email]  DEFAULT ((0)) FOR [IsNotify_ShipTo_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_ShipTo_SMS]  DEFAULT ((0)) FOR [IsNotify_ShipTo_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_SellTo_Email]  DEFAULT ((0)) FOR [IsNotify_SellTo_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_SellTo_SMS]  DEFAULT ((0)) FOR [IsNotify_SellTo_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_SellToPartner_Email]  DEFAULT ((0)) FOR [IsNotify_SellToPartner_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_SellToPartner_SMS]  DEFAULT ((0)) FOR [IsNotify_SellToPartner_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_BillTo_Email]  DEFAULT ((0)) FOR [IsNotify_BillTo_Email]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsNotify_BillTo_SMS]  DEFAULT ((0)) FOR [IsNotify_BillTo_SMS]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsRecurring]  DEFAULT ((1)) FOR [IsRecurring]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsPublic]  DEFAULT ((1)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsTrackingAvailable]  DEFAULT ((1)) FOR [IsTrackingAvailable]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsUpdateShippingStatus]  DEFAULT ((1)) FOR [IsUpdateShippingStatus]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Events_List] ADD  CONSTRAINT [DF_T_Events_List_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
