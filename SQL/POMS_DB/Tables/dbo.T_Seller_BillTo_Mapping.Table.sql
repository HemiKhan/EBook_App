USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Seller_BillTo_Mapping]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Seller_BillTo_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[SBM_ID] [int] IDENTITY(1,1) NOT NULL,
	[SELLER_KEY] [nvarchar](36) NOT NULL,
	[BillTo_CUSTOMER_KEY] [nvarchar](36) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Seller_BillTo_Mapping] PRIMARY KEY CLUSTERED 
(
	[SBM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Seller_BillTo_Mapping] ADD  CONSTRAINT [DF_T_Seller_BillTo_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Seller_BillTo_Mapping] ADD  CONSTRAINT [DF_T_Seller_BillTo_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Seller_BillTo_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Seller_BillTo_Mapping_T_Seller_BillTo_Mapping] FOREIGN KEY([SBM_ID])
REFERENCES [dbo].[T_Seller_BillTo_Mapping] ([SBM_ID])
GO
ALTER TABLE [dbo].[T_Seller_BillTo_Mapping] CHECK CONSTRAINT [FK_T_Seller_BillTo_Mapping_T_Seller_BillTo_Mapping]
GO
