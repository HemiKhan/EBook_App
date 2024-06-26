USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Seller_All_Mapping_Price_Key]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Seller_All_Mapping_Price_Key](
	[TimeStamp] [timestamp] NOT NULL,
	[SAMPK_ID] [int] IDENTITY(1,1) NOT NULL,
	[SELLER_KEY] [nvarchar](36) NOT NULL,
	[SUB_SELLER_KEY] [nvarchar](36) NULL,
	[SELLER_PARTNER_KEY] [nvarchar](36) NULL,
	[TARIFF_NO] [nvarchar](36) NULL,
	[BillTo_CUSTOMER_NO] [nvarchar](36) NULL,
	[PRICE_KEY] [nvarchar](36) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Seller_All_Mapping_Price_Key] PRIMARY KEY CLUSTERED 
(
	[SAMPK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Seller_All_Mapping_Price_Key] ADD  CONSTRAINT [DF_T_Seller_All_Mapping_Price_Key_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Seller_All_Mapping_Price_Key] ADD  CONSTRAINT [DF_T_Seller_All_Mapping_Price_Key_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
