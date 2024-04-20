USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Tariff_List]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Tariff_List](
	[TimeStamp] [timestamp] NOT NULL,
	[TARIFF_ID] [int] NOT NULL,
	[TARIFF_NO] [nvarchar](36) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Description] [nvarchar](250) NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Traiff_List] PRIMARY KEY CLUSTERED 
(
	[TARIFF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Tariff_List] ADD  CONSTRAINT [DF_T_Traiff_List_TARIFF_NO]  DEFAULT (newid()) FOR [TARIFF_NO]
GO
ALTER TABLE [dbo].[T_Tariff_List] ADD  CONSTRAINT [DF_T_Traiff_List_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Tariff_List] ADD  CONSTRAINT [DF_T_Traiff_List_AddbyOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
