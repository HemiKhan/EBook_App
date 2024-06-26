USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Client_Identifier]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Client_Identifier](
	[TimeStamp] [timestamp] NOT NULL,
	[OCI_ID] [int] IDENTITY(1,1) NOT NULL,
	[ORDER_ID] [int] NOT NULL,
	[OIF_CODE] [nvarchar](20) NOT NULL,
	[Value_] [nvarchar](250) NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Sales_Order_Client_Identifier] PRIMARY KEY CLUSTERED 
(
	[OCI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Client_Identifier] ADD  CONSTRAINT [DF_T_Order_Client_Identifier_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Order_Client_Identifier]  WITH CHECK ADD  CONSTRAINT [FK_T_Sales_Order_Client_Identifier_T_Order_Identifier_Fields] FOREIGN KEY([OIF_CODE])
REFERENCES [dbo].[T_Order_Identifier_Fields] ([OIF_CODE])
GO
ALTER TABLE [dbo].[T_Order_Client_Identifier] CHECK CONSTRAINT [FK_T_Sales_Order_Client_Identifier_T_Order_Identifier_Fields]
GO
