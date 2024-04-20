USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Seller_To_Seller_Mapping]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Seller_To_Seller_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[STSM_ID] [int] IDENTITY(1,1) NOT NULL,
	[Parent_SELLER_KEY] [nvarchar](36) NOT NULL,
	[Child_SELLER_KEY] [nvarchar](36) NOT NULL,
	[IsViewOrder] [bit] NOT NULL,
	[IsCreateOrder] [bit] NOT NULL,
	[IsGetQuote] [bit] NOT NULL,
	[IsFinancial] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Seller_To_Seller_Mapping] PRIMARY KEY CLUSTERED 
(
	[STSM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_Seller_To_Seller_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_Seller_To_Seller_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Seller_To_Seller_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Seller_To_Seller_Mapping_T_Seller_To_Seller_Mapping] FOREIGN KEY([STSM_ID])
REFERENCES [dbo].[T_Seller_To_Seller_Mapping] ([STSM_ID])
GO
ALTER TABLE [dbo].[T_Seller_To_Seller_Mapping] CHECK CONSTRAINT [FK_T_Seller_To_Seller_Mapping_T_Seller_To_Seller_Mapping]
GO
