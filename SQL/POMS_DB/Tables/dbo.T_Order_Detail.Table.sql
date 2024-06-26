USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Detail]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Detail](
	[TimeStamp] [timestamp] NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[CurrentAssignToDept_MTV_CODE] [nvarchar](20) NOT NULL,
	[OEDAssignTo] [nvarchar](150) NULL,
	[OEDAssignToDateTime] [datetime] NULL,
	[OEDStatus_MTV_ID] [int] NULL,
	[OEDStatusDateTime] [datetime] NULL,
	[OEDCompletedDateTime] [datetime] NULL,
	[OEDFollowUpDateTime] [datetime] NULL,
	[OEDFollowUPCount] [int] NOT NULL,
	[CSRAssignTo] [nvarchar](150) NULL,
	[CSRAssignToDateTime] [datetime] NULL,
	[CSRStatus_MTV_ID] [int] NULL,
	[CSRStatusDateTime] [datetime] NULL,
	[CSRCompletedDateTime] [datetime] NULL,
	[CSRFollowUpDateTime] [datetime] NULL,
	[CSRFollowUpCount] [int] NOT NULL,
	[DispatchAssignTo] [nvarchar](150) NULL,
	[DispatchAssignToDateTime] [datetime] NULL,
	[DispatchStatus_MTV_ID] [int] NULL,
	[DispatchStatusDateTime] [datetime] NULL,
	[DispatchCompletedDateTime] [datetime] NULL,
	[DispatchFollowUpDateTime] [datetime] NULL,
	[DispatchFollowUpCount] [int] NOT NULL,
	[AccountAssignTo] [nvarchar](150) NULL,
	[AccountAssignToDateTime] [datetime] NULL,
	[AccountStatus_MTV_ID] [int] NULL,
	[AccountStatusDateTime] [datetime] NULL,
	[AccountCompletedDateTime] [datetime] NULL,
	[AccountFollowUpDateTime] [datetime] NULL,
	[AccountFollowUpCount] [int] NOT NULL,
	[EstimateMiles] [int] NULL,
	[EstimateRevenue] [decimal](18, 6) NULL,
	[ActualRevenue] [decimal](18, 6) NULL,
	[IsMWG] [bit] NOT NULL,
	[IsItemAdded] [bit] NOT NULL,
	[TotalQty] [int] NOT NULL,
	[TotalValue] [decimal](18, 6) NOT NULL,
	[TotalWeight] [decimal](18, 6) NOT NULL,
	[TotalCubes] [decimal](18, 6) NOT NULL,
	[TotalAssemblyMinutes] [int] NOT NULL,
	[LastGeneratedBarcode] [nvarchar](10) NOT NULL,
	[ShipFrom_MilesRadius] [decimal](18, 6) NULL,
	[ShipFrom_DrivingMiles] [decimal](18, 6) NULL,
	[ShipTo_MilesRadius] [decimal](18, 6) NULL,
	[ShipTo_DrivingMiles] [decimal](18, 6) NULL,
	[LineHaul_DrivingMiles] [decimal](18, 6) NULL,
	[Last_Pickup_PP_MIN_ID] [int] NULL,
	[Last_Delivery_PP_MIN_ID] [int] NULL,
	[InvoiceType_MTV_ID] [int] NOT NULL,
	[OrderType_MTV_ID] [int] NULL,
	[SubOrderType_ID] [int] NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Order_Detail] PRIMARY KEY CLUSTERED 
(
	[ORDER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Detail] ADD  CONSTRAINT [DF_T_Order_Detail_CurrentAssignToDept_MTV_CODE]  DEFAULT (N'OED') FOR [CurrentAssignToDept_MTV_CODE]
GO
ALTER TABLE [dbo].[T_Order_Detail] ADD  CONSTRAINT [DF_T_Order_Detail_OEDFollowUPCount]  DEFAULT ((0)) FOR [OEDFollowUPCount]
GO
ALTER TABLE [dbo].[T_Order_Detail] ADD  CONSTRAINT [DF_T_Order_Detail_CSRFollowUpCount]  DEFAULT ((0)) FOR [CSRFollowUpCount]
GO
ALTER TABLE [dbo].[T_Order_Detail] ADD  CONSTRAINT [DF_T_Order_Detail_DispatchFollowUpCount]  DEFAULT ((0)) FOR [DispatchFollowUpCount]
GO
ALTER TABLE [dbo].[T_Order_Detail] ADD  CONSTRAINT [DF_T_Order_Detail_AccountFollowUpCount]  DEFAULT ((0)) FOR [AccountFollowUpCount]
GO
ALTER TABLE [dbo].[T_Order_Detail] ADD  CONSTRAINT [DF_T_Order_Detail_IsMWG]  DEFAULT ((0)) FOR [IsMWG]
GO
ALTER TABLE [dbo].[T_Order_Detail] ADD  CONSTRAINT [DF_T_Order_Detail_IsItemAdded]  DEFAULT ((0)) FOR [IsItemAdded]
GO
ALTER TABLE [dbo].[T_Order_Detail] ADD  CONSTRAINT [DF_T_Order_Detail_InvoiceType_MTV_ID]  DEFAULT ((145100)) FOR [InvoiceType_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Detail] ADD  CONSTRAINT [DF_T_Order_Detail_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
