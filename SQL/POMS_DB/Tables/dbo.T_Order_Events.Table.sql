USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Events]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Events](
	[TimeStamp] [timestamp] NOT NULL,
	[OE_ID] [int] IDENTITY(1,1) NOT NULL,
	[EVENT_ID] [int] NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[SELLER_CODE] [nvarchar](20) NOT NULL,
	[TriggerDate] [datetime] NOT NULL,
	[Source_MTV_ID] [int] NOT NULL,
	[TriggerDebugInfo] [nvarchar](4000) NULL,
	[IsActive] [bit] NOT NULL,
	[IsAuto] [bit] NOT NULL,
	[HUB_CODE] [nvarchar](20) NOT NULL,
	[IsChangesProcessed] [bit] NOT NULL,
	[TIMEZONE_ID] [int] NULL,
	[TimeZoneName] [nvarchar](50) NULL,
	[TimeZoneAbbreviation] [nvarchar](10) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](5) NULL,
	[ZipCode] [nvarchar](10) NULL,
	[REF1] [nvarchar](150) NULL,
	[REF2] [nvarchar](150) NULL,
	[REF3] [nvarchar](150) NULL,
	[REF4] [nvarchar](150) NULL,
	[REF1KEY] [nvarchar](150) NULL,
	[REF2KEY] [nvarchar](150) NULL,
	[REF3KEY] [nvarchar](150) NULL,
	[REF4KEY] [nvarchar](150) NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Event_Master_Log] PRIMARY KEY CLUSTERED 
(
	[OE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Events] ADD  CONSTRAINT [DF_T_Event_Master_Log_TriggerDate]  DEFAULT (getutcdate()) FOR [TriggerDate]
GO
ALTER TABLE [dbo].[T_Order_Events] ADD  CONSTRAINT [DF_T_Event_Master_Log_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Order_Events] ADD  CONSTRAINT [DF_T_Order_Events_IsAuto]  DEFAULT ((0)) FOR [IsAuto]
GO
ALTER TABLE [dbo].[T_Order_Events] ADD  CONSTRAINT [DF_T_Order_Events_IsChangesProcessed]  DEFAULT ((0)) FOR [IsChangesProcessed]
GO
ALTER TABLE [dbo].[T_Order_Events] ADD  CONSTRAINT [DF_T_Event_Master_Log_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
