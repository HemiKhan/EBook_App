USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Order_Identifier_Fields]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Order_Identifier_Fields](
	[TimeStamp] [timestamp] NOT NULL,
	[OIF_CODE] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[IsRequired] [bit] NOT NULL,
	[IsDuplicateAllowed] [bit] NOT NULL,
	[IsModifyAllowed] [bit] NOT NULL,
	[IsHidden] [bit] NOT NULL,
	[IsAllowed] [bit] NOT NULL,
	[CharacterLimit] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Client_Identifier_Fields] PRIMARY KEY CLUSTERED 
(
	[OIF_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Order_Identifier_Fields] ADD  CONSTRAINT [DF_T_Client_Identifier_Fields_IsRequiredField]  DEFAULT ((0)) FOR [IsRequired]
GO
ALTER TABLE [dbo].[T_Order_Identifier_Fields] ADD  CONSTRAINT [DF_T_Client_Identifier_Fields_IsDuplicateValueAllowed]  DEFAULT ((1)) FOR [IsDuplicateAllowed]
GO
ALTER TABLE [dbo].[T_Order_Identifier_Fields] ADD  CONSTRAINT [DF_T_Order_Identifier_Fields_IsModifyAllowed]  DEFAULT ((1)) FOR [IsModifyAllowed]
GO
ALTER TABLE [dbo].[T_Order_Identifier_Fields] ADD  CONSTRAINT [DF_T_Order_Identifier_Fields_IsHidden]  DEFAULT ((0)) FOR [IsHidden]
GO
ALTER TABLE [dbo].[T_Order_Identifier_Fields] ADD  CONSTRAINT [DF_T_Order_Identifier_Fields_IsAllowed]  DEFAULT ((1)) FOR [IsAllowed]
GO
ALTER TABLE [dbo].[T_Order_Identifier_Fields] ADD  CONSTRAINT [DF_T_Order_Identifier_Fields_CharacterLimit]  DEFAULT ((50)) FOR [CharacterLimit]
GO
ALTER TABLE [dbo].[T_Order_Identifier_Fields] ADD  CONSTRAINT [DF_T_Client_Identifier_Fields_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Order_Identifier_Fields] ADD  CONSTRAINT [DF_T_Order_Identifier_Fields_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
