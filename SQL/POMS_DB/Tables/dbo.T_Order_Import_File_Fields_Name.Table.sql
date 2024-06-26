USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Import_File_Fields_Name]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Import_File_Fields_Name](
	[TimeStamp] [timestamp] NOT NULL,
	[OIFFN_ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderSubSource_MTV_CODE] [nvarchar](20) NOT NULL,
	[OriginalFieldName] [nvarchar](50) NOT NULL,
	[FieldName] [nvarchar](50) NULL,
	[Description] [nvarchar](1000) NULL,
	[SetType_MTV_ID] [int] NOT NULL,
	[FieldType_MTV_ID] [int] NOT NULL,
	[IsRequired] [bit] NOT NULL,
	[IsCustomAllowed] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Order_Import_File_Fields_Name] PRIMARY KEY CLUSTERED 
(
	[OIFFN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Import_File_Fields_Name] ADD  CONSTRAINT [DF_T_Order_Import_File_Fields_Name_SetType_MTV_ID]  DEFAULT ((160100)) FOR [SetType_MTV_ID]
GO
ALTER TABLE [dbo].[T_Order_Import_File_Fields_Name] ADD  CONSTRAINT [DF_T_Order_Import_File_Fields_Name_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Order_Import_File_Fields_Name] ADD  CONSTRAINT [DF_T_Order_Import_File_Fields_Name_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
