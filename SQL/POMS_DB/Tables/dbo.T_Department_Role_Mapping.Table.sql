USE [POMS_DB]
GO
/****** Object:  Table [dbo].[T_Department_Role_Mapping]    Script Date: 4/19/2024 9:47:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[T_Department_Role_Mapping](
	[TimeStamp] [timestamp] NOT NULL,
	[DRM_ID] [int] IDENTITY(1,1) NOT NULL,
	[R_ID] [int] NOT NULL,
	[D_ID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[AddedBy] [nvarchar](150) NOT NULL,
	[AddedOn] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](150) NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_T_Department_Role_Mapping] PRIMARY KEY CLUSTERED 
(
	[DRM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping] ADD  CONSTRAINT [DF_T_Department_Role_Mapping_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping] ADD  CONSTRAINT [DF_T_Department_Role_Mapping_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Department_Role_Mapping_T_Department] FOREIGN KEY([D_ID])
REFERENCES [dbo].[T_Department] ([D_ID])
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping] CHECK CONSTRAINT [FK_T_Department_Role_Mapping_T_Department]
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_T_Department_Role_Mapping_T_Roles] FOREIGN KEY([R_ID])
REFERENCES [dbo].[T_Roles] ([R_ID])
GO
ALTER TABLE [dbo].[T_Department_Role_Mapping] CHECK CONSTRAINT [FK_T_Department_Role_Mapping_T_Roles]
GO
