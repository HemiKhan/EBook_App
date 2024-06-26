USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_User_Seller_To_Partner_Mapping]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_User_Seller_To_Partner_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[USTSPM_ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](150) NOT NULL,
	[SPM_ID] [int] NOT NULL,
	[IsViewOrder] [bit] NOT NULL,
	[IsCreateOrder] [bit] NOT NULL,
	[IsGetQuote] [bit] NOT NULL,
	[IsFinancial] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_User_Seller_To_Partner_Mapping] PRIMARY KEY CLUSTERED 
(
	[USTSPM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Partner_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Partner_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Partner_Mapping] ADD  CONSTRAINT [DF_T_User_Seller_To_Partner_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_User_Seller_To_Partner_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_User_Seller_To_Partner_Mapping_T_Seller_Partner_Mapping] FOREIGN KEY([SPM_ID])
REFERENCES [dbo].[T_Seller_Partner_Mapping] ([SPM_ID])
GO
ALTER TABLE [dbo].[T_User_Seller_To_Partner_Mapping] CHECK CONSTRAINT [FK_T_User_Seller_To_Partner_Mapping_T_Seller_Partner_Mapping]
GO
