USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_LogiwaClient]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_LogiwaClient](
	[TimeStamp] [timestamp] NOT NULL,
	[LC_ID] [int] IDENTITY(1,1) NOT NULL,
	[CUSTOMER_KEY] [nvarchar](36) NOT NULL,
	[SELLER_KEY] [nvarchar](36) NOT NULL,
	[Logiwa_Name] [nvarchar](50) NOT NULL,
	[Logiwa_ID] [int] NOT NULL,
	[Logiwa_OrderType] [nvarchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Client] PRIMARY KEY CLUSTERED 
(
	[LC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_LogiwaClient] ADD  CONSTRAINT [DF_T_Client_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_LogiwaClient] ADD  CONSTRAINT [DF_T_Client_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
