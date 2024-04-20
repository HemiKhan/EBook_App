USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Comments]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Comments](
	[TimeStamp] [timestamp] NOT NULL,
	[OC_ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[ShippingStatus_EVENT_ID] [int] NOT NULL,
	[OrderStatus_MTV_ID] [int] NOT NULL,
	[Comment] [nvarchar](1000) NOT NULL,
	[IsPublic] [bit] NOT NULL,
	[CreatedBy] [nvarchar](150) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[IsCall] [bit] NOT NULL,
	[ImportanceLevel_MTV_ID] [int] NULL,
 CONSTRAINT [PK_T_Sales_Order_Comments] PRIMARY KEY CLUSTERED 
(
	[OC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Comments] ADD  CONSTRAINT [DF_T_Sales_Order_Comments_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[T_Order_Comments] ADD  CONSTRAINT [DF_T_Sales_Order_Comments_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Order_Comments]  WITH CHECK ADD  CONSTRAINT [const_T_Order_Comments_EmptyCheck] CHECK  (([Comment]<>''))
GO
ALTER TABLE [dbo].[T_Order_Comments] CHECK CONSTRAINT [const_T_Order_Comments_EmptyCheck]
GO
