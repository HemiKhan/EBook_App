USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Process_Log]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Process_Log](
	[TimeStamp] [timestamp] NOT NULL,
	[OPL_ID] [int] IDENTITY(1,1) NOT NULL,
	[RequestID] [nvarchar](36) NOT NULL,
	[IsSuccess] [bit] NOT NULL,
	[UniqueID] [nvarchar](1000) NOT NULL,
	[Status_MTV_CODE] [nvarchar](20) NOT NULL,
	[ErrorJson] [nvarchar](max) NULL,
	[WarningJson] [nvarchar](max) NULL,
	[PickupServiceCode] [nvarchar](1000) NULL,
	[DeliveryServiceCode] [nvarchar](1000) NULL,
	[TotalQty] [int] NULL,
	[TotalWeight] [decimal](18, 6) NULL,
	[TotalCuft] [decimal](18, 6) NULL,
	[TotalValue] [decimal](18, 6) NULL,
	[PRO] [nvarchar](1000) NULL,
	[PONUMBER] [nvarchar](1000) NULL,
	[REF2] [nvarchar](1000) NULL,
	[CarrierCode] [nvarchar](1000) NULL,
	[ORDER_ID] [int] NULL,
	[TRACKING_NO] [nvarchar](20) NULL,
	[Message] [nvarchar](1000) NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Order_Process_Log] PRIMARY KEY CLUSTERED 
(
	[OPL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Process_Log] ADD  CONSTRAINT [DF_T_Order_Process_Log_Status_MTV_CODE]  DEFAULT ('OPEN') FOR [Status_MTV_CODE]
GO
ALTER TABLE [dbo].[T_Order_Process_Log] ADD  CONSTRAINT [DF_T_Order_Process_Log_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Order_Process_Log] ADD  CONSTRAINT [DF_T_Order_Process_Log_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
