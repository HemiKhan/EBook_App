USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Access_Log]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Access_Log](
	[TimeStamp] [timestamp] NOT NULL,
	[OAL_ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[UserType_MTV_CODE] [nvarchar](20) NOT NULL,
	[ViewedBy] [nvarchar](150) NOT NULL,
	[ViewedOn] [datetime] NOT NULL,
	[ViewSource_MTV_ID] [int] NOT NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [PK_T_Sales_Order_Access_Log] PRIMARY KEY CLUSTERED 
(
	[OAL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Access_Log] ADD  CONSTRAINT [DF_T_Sales_Order_Access_Log_ViewedOn]  DEFAULT (getutcdate()) FOR [ViewedOn]
GO
