USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Sub_Order_Type_Value]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Sub_Order_Type_Value](
	[TimeStamp] [timestamp] NOT NULL,
	[SOTV_ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderType_MTV_ID] [int] NOT NULL,
	[SubOrderType_ID] [int] NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Sub_Order_Type_Value] PRIMARY KEY CLUSTERED 
(
	[SOTV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Sub_Order_Type_Value] ADD  CONSTRAINT [DF_T_Sub_Order_Type_Value_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Sub_Order_Type_Value] ADD  CONSTRAINT [DF_T_Sub_Order_Type_Value_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
