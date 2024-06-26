USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Special_Service]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Special_Service](
	[TimeStamp] [timestamp] NOT NULL,
	[OSS_ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[SLSS_ID] [int] NOT NULL,
	[Is_Pickup] [bit] NOT NULL,
	[Description_] [nvarchar](250) NULL,
	[Mints] [int] NOT NULL,
	[Floor_] [int] NOT NULL,
	[EST_Amount] [decimal](18, 6) NOT NULL,
	[Days_] [int] NOT NULL,
	[From_Date] [date] NULL,
	[To_Date] [date] NULL,
	[Man] [int] NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Sales_Order_Special_Service] PRIMARY KEY CLUSTERED 
(
	[OSS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Special_Service] ADD  CONSTRAINT [DF_T_Order_Special_Service_IsPublic]  DEFAULT ((1)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[T_Order_Special_Service] ADD  CONSTRAINT [DF_T_Sales_Order_Special_Service_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
