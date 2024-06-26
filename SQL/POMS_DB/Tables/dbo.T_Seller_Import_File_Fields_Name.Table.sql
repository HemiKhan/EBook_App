USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Seller_Import_File_Fields_Name]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Seller_Import_File_Fields_Name](
	[TimeStamp] [timestamp] NOT NULL,
	[SIFFN_ID] [int] IDENTITY(1,1) NOT NULL,
	[OIFFN_ID] [int] NOT NULL,
	[SELLER_CODE] [nvarchar](20) NOT NULL,
	[FieldName] [nvarchar](50) NOT NULL,
	[SetType_MTV_ID] [int] NOT NULL,
	[IsRequired] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Seller_Import_File_Fields_Name] PRIMARY KEY CLUSTERED 
(
	[SIFFN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Seller_Import_File_Fields_Name] ADD  CONSTRAINT [DF_T_Seller_Import_File_Fields_Name_SetType_MTV_ID]  DEFAULT ((160100)) FOR [SetType_MTV_ID]
GO
ALTER TABLE [dbo].[T_Seller_Import_File_Fields_Name] ADD  CONSTRAINT [DF_T_Seller_Import_File_Fields_Name_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Seller_Import_File_Fields_Name] ADD  CONSTRAINT [DF_T_Seller_Import_File_Fields_Name_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Seller_Import_File_Fields_Name]  WITH CHECK ADD  CONSTRAINT [FK_T_Seller_Import_File_Fields_Name_T_Order_Import_File_Fields_Name] FOREIGN KEY([OIFFN_ID])
REFERENCES [dbo].[T_Order_Import_File_Fields_Name] ([OIFFN_ID])
GO
ALTER TABLE [dbo].[T_Seller_Import_File_Fields_Name] CHECK CONSTRAINT [FK_T_Seller_Import_File_Fields_Name_T_Order_Import_File_Fields_Name]
GO
