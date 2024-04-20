USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Additional_Info]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Additional_Info](
	[TimeStamp] [timestamp] NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[FirstScanDate] [datetime] NULL,
	[FirstScanHub] [nvarchar](20) NULL,
	[FirstFRBMDate] [datetime] NULL,
	[FirstFRBMHub] [nvarchar](20) NULL,
	[FirstFileMileFRBMDate] [datetime] NULL,
	[FirstFileMileFRBMHub] [nvarchar](20) NULL,
	[LastScanDate] [datetime] NULL,
	[LastScanHub] [nvarchar](20) NULL,
	[LastScanLocationID] [nvarchar](20) NULL,
	[ShipToHub_FirstScanDate] [datetime] NULL,
	[ShipToZone_FirstScanDate] [datetime] NULL,
	[OriginDepartureDate] [datetime] NULL,
	[DlvAttemptCount] [int] NULL,
	[Revenue] [decimal](18, 6) NULL,
	[RevenueWithCM] [decimal](18, 6) NULL,
	[LastViewedDate] [datetime] NULL,
	[LastViewedByUserName] [nvarchar](150) NULL,
	[IsIndexUpdated] [bit] NULL,
	[IsPhoneUpdated] [bit] NULL,
	[IsPPJobDone] [bit] NULL,
	[IsInvoiceProcessed] [bit] NULL,
	[ReSchCount] [int] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Order_Additional_Info] PRIMARY KEY CLUSTERED 
(
	[ORDER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Additional_Info] ADD  CONSTRAINT [DF_T_Order_Additional_Info_ReSchCount]  DEFAULT ((0)) FOR [ReSchCount]
GO
ALTER TABLE [dbo].[T_Order_Additional_Info] ADD  CONSTRAINT [DF_T_Order_Additional_Info_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
