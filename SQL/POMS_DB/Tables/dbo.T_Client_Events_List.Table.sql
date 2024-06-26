USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Client_Events_List]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Client_Events_List](
	[TimeStamp] [timestamp] NOT NULL,
	[CEL_ID] [int] IDENTITY(1,1) NOT NULL,
	[SELLER_CODE] [nvarchar](20) NOT NULL,
	[EVENT_ID] [int] NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[IsOutboundRequired] [bit] NULL,
	[IsNotify_Metro_Email] [bit] NULL,
	[IsNotify_Metro_SMS] [bit] NULL,
	[IsNotify_Client_Email] [bit] NULL,
	[IsNotify_Client_SMS] [bit] NULL,
	[IsNotify_OED_Email] [bit] NULL,
	[IsNotify_OED_SMS] [bit] NULL,
	[IsNotify_CSR_Email] [bit] NULL,
	[IsNotify_CSR_SMS] [bit] NULL,
	[IsNotify_Dispatch_Email] [bit] NULL,
	[IsNotify_Dispatch_SMS] [bit] NULL,
	[IsNotify_Accounting_Email] [bit] NULL,
	[IsNotify_Accounting_SMS] [bit] NULL,
	[IsNotify_Warehouse_Email] [bit] NULL,
	[IsNotify_Warehouse_SMS] [bit] NULL,
	[IsNotify_ShipFrom_Email] [bit] NULL,
	[IsNotify_ShipFrom_SMS] [bit] NULL,
	[IsNotify_ShipTo_Email] [bit] NULL,
	[IsNotify_ShipTo_SMS] [bit] NULL,
	[IsNotify_SellTo_Email] [bit] NULL,
	[IsNotify_SellTo_SMS] [bit] NULL,
	[IsNotify_SellToPartner_Email] [bit] NULL,
	[IsNotify_SellToPartner_SMS] [bit] NULL,
	[IsNotify_BillTo_Email] [bit] NULL,
	[IsNotify_BillTo_SMS] [bit] NULL,
	[IsPublic] [bit] NULL,
	[IsTrackingAvailable] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Client_Events_List] PRIMARY KEY CLUSTERED 
(
	[CEL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Client_Events_List] ADD  CONSTRAINT [DF_T_Client_Events_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Client_Events_List] ADD  CONSTRAINT [DF_T_Client_Events_List_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[T_Client_Events_List]  WITH CHECK ADD  CONSTRAINT [FK_T_Client_Events_List_T_Events_List] FOREIGN KEY([EVENT_ID])
REFERENCES [dbo].[T_Events_List] ([EVENT_ID])
GO
ALTER TABLE [dbo].[T_Client_Events_List] CHECK CONSTRAINT [FK_T_Client_Events_List_T_Events_List]
GO
