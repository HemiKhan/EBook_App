USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Role_Group_Mapping]    Script Date: 4/19/2024 9:47:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Role_Group_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[RGM_ID] [int] IDENTITY(1,1) NOT NULL,
	[RG_ID] [int] NOT NULL,
	[R_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Role_Group_Mapping] PRIMARY KEY CLUSTERED 
(
	[RGM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] ADD  CONSTRAINT [DF_T_Role_Group_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] ADD  CONSTRAINT [DF_T_Role_Group_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Group_Mapping_T_Role_Group] FOREIGN KEY([RG_ID])
REFERENCES [dbo].[T_Role_Group] ([RG_ID])
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] CHECK CONSTRAINT [FK_T_Role_Group_Mapping_T_Role_Group]
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Role_Group_Mapping_T_Roles] FOREIGN KEY([R_ID])
REFERENCES [dbo].[T_Roles] ([R_ID])
GO
ALTER TABLE [dbo].[T_Role_Group_Mapping] CHECK CONSTRAINT [FK_T_Role_Group_Mapping_T_Roles]
GO
