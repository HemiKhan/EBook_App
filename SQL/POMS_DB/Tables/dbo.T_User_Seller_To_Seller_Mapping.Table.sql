USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_User_Seller_To_Seller_Mapping]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_User_Seller_To_Seller_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[USTSM_ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](150) NOT NULL,
	[STSM_ID] [int] NOT NULL,
	[IsViewOrder] [bit] NOT NULL,
	[IsCreateOrder] [bit] NOT NULL,
	[IsGetQuote] [bit] NOT NULL,
	[IsFinancial] [bit] NOT NULL,
	[IsBlankSubSellerAllowed] [bit] NOT NULL,
	[IsAllSubSellerAllowed] [bit] NOT NULL,
	[IsBlankPartnerAllowed] [bit] NOT NULL,
	[IsAllPartnerAllowed] [bit] NOT NULL,
	[IsBlankTariffAllowed] [bit] NOT NULL,
	[IsAllTariffAllowed] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_User_Seller_To_Seller_Mapping] PRIMARY KEY CLUSTERED 
(
	[USTSM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Seller_Mapping_IsBlankSubSellerAllowed]  DEFAULT ((1)) FOR [IsBlankSubSellerAllowed]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Seller_Mapping_IsAllSubSellerAllowed]  DEFAULT ((0)) FOR [IsAllSubSellerAllowed]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Seller_Mapping_IsBlankPartnerAllowed]  DEFAULT ((1)) FOR [IsBlankPartnerAllowed]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Seller_Mapping_IsAllPartnerAllowed]  DEFAULT ((0)) FOR [IsAllPartnerAllowed]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Seller_Mapping_IsBlankTariffAllowed]  DEFAULT ((1)) FOR [IsBlankTariffAllowed]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Seller_Mapping_IsAllTariffAllowed]  DEFAULT ((0)) FOR [IsAllTariffAllowed]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Seller_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Seller_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_User_Seller_To_Seller_Mapping_T_Seller_To_Seller_Mapping] FOREIGN KEY([USTSM_ID])
REFERENCES [dbo].[T_Seller_To_Seller_Mapping] ([STSM_ID])
GO
ALTER TABLE [dbo].[T_User_Seller_To_Seller_Mapping] CHECK CONSTRAINT [FK_T_User_Seller_To_Seller_Mapping_T_Seller_To_Seller_Mapping]
GO
